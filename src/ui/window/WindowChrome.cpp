#include "WindowChrome.h"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QProcess>
#include <QQmlEngine>
#include <QRegularExpression>
#include <QSettings>
#include <QStandardPaths>

#ifdef KIPPER_HAS_QWK
#include <QWKQuick/quickwindowagent.h>
#endif

#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID) && __has_include(<QtDBus/QDBusConnection>)
#include <QtDBus/QDBusConnection>
#include <QtDBus/QDBusMessage>
#include <QtDBus/QDBusVariant>
#define KIPPER_HAS_DBUS 1
#endif

namespace {

const QString kSettingKey = QStringLiteral("ui/windowButtonStyle");
const QStringList kButtons = {QStringLiteral("close"), QStringLiteral("minimize"), QStringLiteral("maximize")};
// Padrão do GTK quando o sistema não diz nada.
const QString kLayoutGtkDefault = QStringLiteral("menu:minimize,maximize,close");
const QString kLayoutWindows = QStringLiteral(":minimize,maximize,close");
const QString kLayoutMac = QStringLiteral("close,minimize,maximize:");

bool themeLooksLikeMac(const QString &theme)
{
    QString t = theme.toLower();
    t.remove(QRegularExpression(QStringLiteral("[\\s_-]")));
    static const QStringList marks = {
        QStringLiteral("whitesur"), QStringLiteral("mojave"), QStringLiteral("catalina"), QStringLiteral("bigsur"),
        QStringLiteral("monterey"), QStringLiteral("ventura"), QStringLiteral("sonoma"), QStringLiteral("sequoia"),
        QStringLiteral("macos"), QStringLiteral("cupertino"), QStringLiteral("mcos"), QStringLiteral("osx")};
    for (const QString &m : marks) {
        if (t.contains(m))
            return true;
    }
    return false;
}

WindowChrome::Buttons build(const QString &style, const QString &layout)
{
    auto [left, right] = WindowChrome::parseLayout(layout);
    if (left.isEmpty() && right.isEmpty())
        right << QStringLiteral("close"); // sistema sem nenhum botão: deixa ao menos o fechar
    return {style, left, right};
}

#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
bool insideFlatpak()
{
    return QFile::exists(QStringLiteral("/.flatpak-info"));
}

QString readFile(const QString &path)
{
    QFile f(path);
    if (!f.open(QIODevice::ReadOnly | QIODevice::Text))
        return {};
    return QString::fromUtf8(f.readAll());
}

// Portal de configurações (org.freedesktop.portal.Settings): funciona dentro e fora do Flatpak.
QString portalSetting(const QString &ns, const QString &key)
{
#ifdef KIPPER_HAS_DBUS
    auto bus = QDBusConnection::sessionBus();
    if (!bus.isConnected())
        return {};
    for (const char *method : {"ReadOne", "Read"}) {
        QDBusMessage msg = QDBusMessage::createMethodCall(QStringLiteral("org.freedesktop.portal.Desktop"),
                                                          QStringLiteral("/org/freedesktop/portal/desktop"),
                                                          QStringLiteral("org.freedesktop.portal.Settings"),
                                                          QString::fromLatin1(method));
        msg << ns << key;
        const QDBusMessage reply = bus.call(msg, QDBus::Block, 400);
        if (reply.type() != QDBusMessage::ReplyMessage || reply.arguments().isEmpty())
            continue;
        QVariant v = reply.arguments().constFirst();
        // Read devolve variante dentro de variante; ReadOne, uma só.
        for (int i = 0; i < 3 && v.metaType() == QMetaType::fromType<QDBusVariant>(); ++i)
            v = v.value<QDBusVariant>().variant();
        const QString s = v.toString().trimmed();
        if (!s.isEmpty())
            return s;
    }
#else
    Q_UNUSED(ns);
    Q_UNUSED(key);
#endif
    return {};
}

QString gsetting(const QString &schema, const QString &key)
{
    if (insideFlatpak() || QStandardPaths::findExecutable(QStringLiteral("gsettings")).isEmpty())
        return {};
    QProcess p;
    p.start(QStringLiteral("gsettings"), {QStringLiteral("get"), schema, key});
    if (!p.waitForFinished(800) || p.exitCode() != 0)
        return {};
    QString out = QString::fromUtf8(p.readAllStandardOutput()).trimmed();
    if (out.size() >= 2 && (out.startsWith(QLatin1Char('\'')) || out.startsWith(QLatin1Char('"'))))
        out = out.mid(1, out.size() - 2);
    return out;
}

// ~/.config/gtk-4.0/settings.ini e gtk-3.0 (o KDE escreve aqui pelo kde-gtk-config).
QString gtkIni(const QString &key)
{
    const QString config = QStandardPaths::writableLocation(QStandardPaths::GenericConfigLocation);
    for (const QString &dir : {QStringLiteral("gtk-4.0"), QStringLiteral("gtk-3.0")}) {
        const QString text = readFile(config + QLatin1Char('/') + dir + QStringLiteral("/settings.ini"));
        const QRegularExpression re(QStringLiteral("^\\s*") + QRegularExpression::escape(key)
                                        + QStringLiteral("\\s*=\\s*(.*?)\\s*$"),
                                    QRegularExpression::MultilineOption);
        const auto m = re.match(text);
        if (m.hasMatch() && !m.captured(1).isEmpty())
            return m.captured(1);
    }
    return {};
}

// KDE: ~/.config/kwinrc, [org.kde.kdecoration2] ButtonsOnLeft / ButtonsOnRight e o tema.
QString kwinValue(const QString &key)
{
    const QString config = QStandardPaths::writableLocation(QStandardPaths::GenericConfigLocation);
    const QString text = readFile(config + QStringLiteral("/kwinrc"));
    const int section = text.indexOf(QStringLiteral("[org.kde.kdecoration2]"));
    if (section < 0)
        return {};
    const QString rest = text.mid(section);
    const QRegularExpression re(QStringLiteral("^") + QRegularExpression::escape(key) + QStringLiteral("=(.*)$"),
                                QRegularExpression::MultilineOption);
    const auto m = re.match(rest);
    return m.hasMatch() ? m.captured(1).trimmed() : QString();
}

QString kwinLayout()
{
    const QString left = kwinValue(QStringLiteral("ButtonsOnLeft"));
    const QString right = kwinValue(QStringLiteral("ButtonsOnRight"));
    if (left.isEmpty() && right.isEmpty())
        return {};
    auto side = [](const QString &letters) {
        QStringList out;
        for (const QChar c : letters) {
            if (c == QLatin1Char('X'))
                out << QStringLiteral("close");
            else if (c == QLatin1Char('I'))
                out << QStringLiteral("minimize");
            else if (c == QLatin1Char('A'))
                out << QStringLiteral("maximize");
        }
        return out.join(QLatin1Char(','));
    };
    // O KDE de fábrica só grava o que mudou; sem a direita, vale o padrão dele.
    return side(left) + QLatin1Char(':') + (right.isEmpty() ? QStringLiteral("minimize,maximize,close") : side(right));
}
#endif

} // namespace

WindowChrome *WindowChrome::shared()
{
    static WindowChrome *instance = new WindowChrome(QCoreApplication::instance());
    return instance;
}

void WindowChrome::registerSingleton()
{
    static bool registered = false;
    if (registered)
        return;
    registered = true;
    qmlRegisterSingletonInstance("Drift", 1, 0, "WindowChrome", shared());
}

WindowChrome::WindowChrome(QObject *parent)
    : QObject(parent)
{
#if defined(KIPPER_HAS_QWK) && (defined(Q_OS_WIN) || (defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)))
    // KIPPER_SYSTEM_TITLEBAR=1 volta para a barra do sistema (só para diagnóstico).
    m_integrated = qEnvironmentVariableIntValue("KIPPER_SYSTEM_TITLEBAR") != 1;
#endif
    m_styleSetting = QSettings().value(kSettingKey, QStringLiteral("auto")).toString();
    if (!styleOptions().contains(m_styleSetting))
        m_styleSetting = QStringLiteral("auto");
    m_system = readSystem();
    recompute();
}

WindowChrome::~WindowChrome() = default;

QStringList WindowChrome::styleOptions() const
{
    // Matsu OS não entra aqui de propósito: é reconhecido sozinho.
    return {QStringLiteral("auto"), QStringLiteral("windows"), QStringLiteral("gnome"), QStringLiteral("kde"),
            QStringLiteral("mac")};
}

void WindowChrome::setStyleSetting(const QString &setting)
{
    const QString value = styleOptions().contains(setting) ? setting : QStringLiteral("auto");
    if (value == m_styleSetting)
        return;
    m_styleSetting = value;
    QSettings().setValue(kSettingKey, value);
    recompute();
}

void WindowChrome::refresh()
{
    m_system = readSystem();
    recompute();
}

void WindowChrome::recompute()
{
    // KIPPER_WINDOW_STYLE força um estilo (inclusive "matsu"), para testes e capturas de tela.
    const QString forced = qEnvironmentVariable("KIPPER_WINDOW_STYLE").trimmed().toLower();
    const Buttons next = choose(m_system, forced.isEmpty() ? m_styleSetting : forced);
    if (next.style == m_buttons.style && next.left == m_buttons.left && next.right == m_buttons.right)
        return;
    m_buttons = next;
    emit styleChanged();
}

std::pair<QStringList, QStringList> WindowChrome::parseLayout(const QString &layout)
{
    const int colon = layout.indexOf(QLatin1Char(':'));
    const QString leftText = colon >= 0 ? layout.left(colon) : QString();
    const QString rightText = colon >= 0 ? layout.mid(colon + 1) : layout;
    auto side = [](const QString &s) {
        QStringList out;
        for (const QString &part : s.split(QLatin1Char(','))) {
            const QString b = part.trimmed();
            if (kButtons.contains(b) && !out.contains(b))
                out << b;
        }
        return out;
    };
    const QStringList left = side(leftText);
    QStringList right;
    for (const QString &b : side(rightText)) {
        if (!left.contains(b))
            right << b;
    }
    return {left, right};
}

WindowChrome::Buttons WindowChrome::choose(const System &sys, const QString &preferred)
{
    QString systemLayout = sys.layout.trimmed();
    {
        const auto [l, r] = parseLayout(systemLayout);
        if (l.isEmpty() && r.isEmpty())
            systemLayout.clear();
    }
    const bool onLinux = sys.os != QLatin1String("windows") && sys.os != QLatin1String("mac");

    if (preferred == QLatin1String("windows"))
        return build(QStringLiteral("windows"), kLayoutWindows);
    if (preferred == QLatin1String("mac"))
        return build(QStringLiteral("mac"), kLayoutMac);
    if (preferred == QLatin1String("matsu"))
        return build(QStringLiteral("matsu"), onLinux && !systemLayout.isEmpty() ? systemLayout : kLayoutMac);
    if (preferred == QLatin1String("gnome") || preferred == QLatin1String("kde")) {
        return build(preferred, onLinux ? (systemLayout.isEmpty() ? kLayoutGtkDefault : systemLayout) : kLayoutWindows);
    }

    // Automático.
    if (sys.os == QLatin1String("windows"))
        return build(QStringLiteral("windows"), kLayoutWindows);
    if (sys.os == QLatin1String("mac"))
        return build(QStringLiteral("mac"), kLayoutMac);
    if (sys.matsu)
        return build(QStringLiteral("matsu"), systemLayout.isEmpty() ? kLayoutMac : systemLayout);

    const QString layout = systemLayout.isEmpty() ? kLayoutGtkDefault : systemLayout;
    const QString desktop = sys.desktop.toUpper();
    const QStringList left = parseLayout(layout).first;
    QString style;
    if (desktop.contains(QLatin1String("PANTHEON")))
        style = QStringLiteral("gnome");
    else if (themeLooksLikeMac(sys.theme) || left.contains(QLatin1String("close")))
        style = QStringLiteral("mac");
    else if (desktop.contains(QLatin1String("KDE")))
        style = QStringLiteral("kde");
    else
        style = QStringLiteral("gnome");
    return build(style, layout);
}

bool WindowChrome::osReleaseIsMatsu(const QString &text)
{
    static const QRegularExpression strip(QStringLiteral("[\\s_\"'-]"));
    for (const QString &line : text.split(QLatin1Char('\n'))) {
        const int eq = line.indexOf(QLatin1Char('='));
        if (eq <= 0)
            continue;
        const QString key = line.left(eq).trimmed();
        if (key != QLatin1String("ID") && key != QLatin1String("NAME") && key != QLatin1String("PRETTY_NAME"))
            continue;
        QString value = line.mid(eq + 1).toLower();
        value.remove(strip);
        if (value.contains(QLatin1String("matsu")))
            return true;
    }
    return false;
}

WindowChrome::System WindowChrome::readSystem() const
{
    System sys;
#if defined(Q_OS_WIN)
    sys.os = QStringLiteral("windows");
#elif defined(Q_OS_MACOS)
    sys.os = QStringLiteral("mac");
#elif defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
    sys.os = QStringLiteral("linux");
    sys.desktop = qEnvironmentVariable("XDG_CURRENT_DESKTOP");

    // Matsu OS: os-release do sistema de verdade (no Flatpak, /run/host/os-release).
    QStringList releases = {QStringLiteral("/run/host/os-release"), QStringLiteral("/etc/os-release"),
                            QStringLiteral("/usr/lib/os-release")};
    if (const QString overridePath = qEnvironmentVariable("KIPPER_OS_RELEASE"); !overridePath.isEmpty())
        releases.prepend(overridePath);
    for (const QString &path : std::as_const(releases)) {
        const QString text = readFile(path);
        if (!text.isEmpty()) {
            sys.matsu = osReleaseIsMatsu(text);
            break;
        }
    }

    const bool kde = sys.desktop.toUpper().contains(QLatin1String("KDE"));
    const QString wm = QStringLiteral("org.gnome.desktop.wm.preferences");
    const QString iface = QStringLiteral("org.gnome.desktop.interface");
    if (const QString envLayout = qEnvironmentVariable("KIPPER_DECORATION_LAYOUT"); !envLayout.isEmpty()) {
        sys.layout = envLayout;
    } else if (kde) {
        sys.layout = kwinLayout();
        if (sys.layout.isEmpty())
            sys.layout = gtkIni(QStringLiteral("gtk-decoration-layout"));
        if (sys.layout.isEmpty())
            sys.layout = portalSetting(wm, QStringLiteral("button-layout"));
    } else {
        sys.layout = portalSetting(wm, QStringLiteral("button-layout"));
        if (sys.layout.isEmpty())
            sys.layout = gsetting(wm, QStringLiteral("button-layout"));
        if (sys.layout.isEmpty())
            sys.layout = gtkIni(QStringLiteral("gtk-decoration-layout"));
    }

    sys.theme = portalSetting(iface, QStringLiteral("gtk-theme"));
    if (sys.theme.isEmpty())
        sys.theme = gsetting(iface, QStringLiteral("gtk-theme"));
    if (sys.theme.isEmpty())
        sys.theme = gtkIni(QStringLiteral("gtk-theme-name"));
    if (kde) // tema da decoração do KWin (ex.: __aurorae__svg__WhiteSur)
        sys.theme += QLatin1Char(' ') + kwinValue(QStringLiteral("theme"));
#endif
    return sys;
}

bool WindowChrome::setup(QQuickWindow *window)
{
    if (!m_integrated || !window)
        return false;
#ifdef KIPPER_HAS_QWK
    if (m_agents.contains(window))
        return true;
    auto *agent = new QWK::QuickWindowAgent(window);
    if (!agent->setup(window)) {
        delete agent;
        return false;
    }
    m_agents.insert(window, agent);
    QObject::connect(window, &QObject::destroyed, this, [this, window] { m_agents.remove(window); });
    // Sem moldura, a janela perde os avisos de "tem minimizar/maximizar/fechar", e sem eles
    // a QWindowKit não maximiza no duplo clique. Devolve os avisos (a moldura continua fora).
    window->setFlags(window->flags() | Qt::WindowTitleHint | Qt::WindowSystemMenuHint
                     | Qt::WindowMinMaxButtonsHint | Qt::WindowCloseButtonHint);
    applyPending(window);
    return true;
#else
    return false;
#endif
}

#ifdef KIPPER_HAS_QWK
QWK::QuickWindowAgent *WindowChrome::agentFor(QQuickItem *item) const
{
    if (!item)
        return nullptr;
    if (auto *w = item->window())
        return m_agents.value(w, nullptr);
    return nullptr;
}

void WindowChrome::applyPending(QQuickWindow *window)
{
    auto belongs = [window](QQuickItem *item) { return item && (item->window() == window || !item->window()); };
    for (int i = m_pendingTitleBars.size() - 1; i >= 0; --i) {
        QQuickItem *item = m_pendingTitleBars.at(i);
        if (!item) {
            m_pendingTitleBars.removeAt(i);
        } else if (belongs(item)) {
            m_agents.value(window)->setTitleBar(item);
            m_pendingTitleBars.removeAt(i);
        }
    }
    for (int i = m_pendingButtons.size() - 1; i >= 0; --i) {
        const auto [role, item] = m_pendingButtons.at(i);
        if (!item) {
            m_pendingButtons.removeAt(i);
        } else if (belongs(item)) {
            m_pendingButtons.removeAt(i);
            applySystemButton(m_agents.value(window), role, item);
        }
    }
    for (int i = 0; i < m_pendingHitTest.size();) {
        const auto [item, visible] = m_pendingHitTest.at(i);
        if (!item) {
            m_pendingHitTest.removeAt(i);
        } else if (belongs(item)) {
            m_agents.value(window)->setHitTestVisible(item, visible);
            m_pendingHitTest.removeAt(i);
        } else {
            ++i;
        }
    }
}

void WindowChrome::applySystemButton(QWK::QuickWindowAgent *agent, const QString &role, QQuickItem *item)
{
    if (!agent)
        return;
    if (role == QLatin1String("minimize"))
        agent->setSystemButton(QWK::WindowAgentBase::Minimize, item);
    else if (role == QLatin1String("maximize"))
        agent->setSystemButton(QWK::WindowAgentBase::Maximize, item);
    else if (role == QLatin1String("close"))
        agent->setSystemButton(QWK::WindowAgentBase::Close, item);
}
#endif

void WindowChrome::setTitleBar(QQuickItem *item)
{
#ifdef KIPPER_HAS_QWK
    if (!item || !m_integrated)
        return;
    if (auto *agent = agentFor(item))
        agent->setTitleBar(item);
    else
        m_pendingTitleBars.append(item);
#else
    Q_UNUSED(item);
#endif
}

void WindowChrome::setSystemButton(const QString &role, QQuickItem *item)
{
#ifdef KIPPER_HAS_QWK
    if (!item || !m_integrated)
        return;
    if (auto *agent = agentFor(item))
        applySystemButton(agent, role, item);
    else
        m_pendingButtons.append({role, item});
#else
    Q_UNUSED(role);
    Q_UNUSED(item);
#endif
}

void WindowChrome::setHitTestVisible(QQuickItem *item, bool visible)
{
#ifdef KIPPER_HAS_QWK
    if (!item || !m_integrated)
        return;
    if (auto *agent = agentFor(item))
        agent->setHitTestVisible(item, visible);
    else
        m_pendingHitTest.append({item, visible});
#else
    Q_UNUSED(item);
    Q_UNUSED(visible);
#endif
}
