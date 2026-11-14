// Kipper: escolha do estilo e do lado dos botões da janela (barra de título integrada) e
// reconhecimento do Matsu OS pelo os-release. Mesmos casos do Ignis (janela.rs).
#include <QtTest>

#include "ui/window/WindowChrome.h"

namespace {

WindowChrome::System linuxSystem(const QString &layout, const QString &theme = {}, const QString &desktop = {})
{
    WindowChrome::System s;
    s.os = QStringLiteral("linux");
    s.layout = layout;
    s.theme = theme;
    s.desktop = desktop;
    return s;
}

QStringList list(std::initializer_list<const char *> items)
{
    QStringList out;
    for (const char *i : items)
        out << QString::fromLatin1(i);
    return out;
}

} // namespace

class TestWindowChrome : public QObject
{
    Q_OBJECT

private slots:
    void windowsIsAlwaysWindowsOnTheRight()
    {
        WindowChrome::System s;
        s.os = QStringLiteral("windows");
        const auto b = WindowChrome::choose(s, QStringLiteral("auto"));
        QCOMPARE(b.style, QStringLiteral("windows"));
        QVERIFY(b.left.isEmpty());
        QCOMPARE(b.right, list({"minimize", "maximize", "close"}));
    }

    void gnomeFollowsTheSystem()
    {
        // GNOME de fábrica mostra só o fechar.
        auto b = WindowChrome::choose(linuxSystem(QStringLiteral("appmenu:close"), QStringLiteral("Adwaita"),
                                                  QStringLiteral("GNOME")), QStringLiteral("auto"));
        QCOMPARE(b.style, QStringLiteral("gnome"));
        QCOMPARE(b.right, list({"close"}));
        b = WindowChrome::choose(linuxSystem(QStringLiteral("appmenu:minimize,maximize,close"),
                                             QStringLiteral("Adwaita-dark"), QStringLiteral("GNOME")),
                                 QStringLiteral("auto"));
        QCOMPARE(b.style, QStringLiteral("gnome"));
        QCOMPARE(b.right, list({"minimize", "maximize", "close"}));
    }

    void leftButtonsBecomeMacDotsInSystemOrder()
    {
        const auto b = WindowChrome::choose(linuxSystem(QStringLiteral("close,minimize,maximize:"),
                                                        QStringLiteral("Adwaita"), QStringLiteral("GNOME")),
                                            QStringLiteral("auto"));
        QCOMPARE(b.style, QStringLiteral("mac"));
        QCOMPARE(b.left, list({"close", "minimize", "maximize"}));
        QVERIFY(b.right.isEmpty());
    }

    void macLikeThemeBecomesDotsEvenOnTheRight()
    {
        const auto b = WindowChrome::choose(linuxSystem(QStringLiteral(":minimize,maximize,close"),
                                                        QStringLiteral("WhiteSur-Dark"), QStringLiteral("GNOME")),
                                            QStringLiteral("auto"));
        QCOMPARE(b.style, QStringLiteral("mac"));
        QCOMPARE(b.right, list({"minimize", "maximize", "close"}));
    }

    void kdeUsesKdeStyle()
    {
        const auto b = WindowChrome::choose(linuxSystem(QStringLiteral("icon:minimize,maximize,close"),
                                                        QStringLiteral("Breeze"), QStringLiteral("KDE")),
                                            QStringLiteral("auto"));
        QCOMPARE(b.style, QStringLiteral("kde"));
        QCOMPARE(b.right, list({"minimize", "maximize", "close"}));
    }

    void withoutInformationUsesGtkDefault()
    {
        auto b = WindowChrome::choose(linuxSystem({}), QStringLiteral("auto"));
        QCOMPARE(b.style, QStringLiteral("gnome"));
        QCOMPARE(b.right, list({"minimize", "maximize", "close"}));
        // Layout sem botões conhecidos também cai no padrão.
        b = WindowChrome::choose(linuxSystem(QStringLiteral("menu:")), QStringLiteral("auto"));
        QCOMPARE(b.right, list({"minimize", "maximize", "close"}));
    }

    void manualChoiceWinsOverAutomatic()
    {
        const auto s = linuxSystem(QStringLiteral(":minimize,maximize,close"), QStringLiteral("Adwaita"),
                                   QStringLiteral("GNOME"));
        auto b = WindowChrome::choose(s, QStringLiteral("mac"));
        QCOMPARE(b.style, QStringLiteral("mac"));
        QCOMPARE(b.left, list({"close", "minimize", "maximize"}));
        b = WindowChrome::choose(linuxSystem(QStringLiteral("close,minimize,maximize:")), QStringLiteral("windows"));
        QCOMPARE(b.style, QStringLiteral("windows"));
        QCOMPARE(b.right, list({"minimize", "maximize", "close"}));
        // GNOME/KDE escolhidos à mão continuam no lado do sistema.
        b = WindowChrome::choose(linuxSystem(QStringLiteral("close,minimize,maximize:")), QStringLiteral("kde"));
        QCOMPARE(b.style, QStringLiteral("kde"));
        QCOMPARE(b.left, list({"close", "minimize", "maximize"}));
    }

    void oddLayoutNeitherRepeatsNorInventsButtons()
    {
        auto [l, r] = WindowChrome::parseLayout(QStringLiteral(" close , close,spacer,icon : maximize,close,xyz"));
        QCOMPARE(l, list({"close"}));
        QCOMPARE(r, list({"maximize"}));
        std::tie(l, r) = WindowChrome::parseLayout(QStringLiteral("minimize,close"));
        QVERIFY(l.isEmpty());
        QCOMPARE(r, list({"minimize", "close"}));
    }

    void matsuUsesItsOwnStyleOnTheSystemSide()
    {
        auto s = linuxSystem(QStringLiteral("close,minimize,maximize:"), QStringLiteral("Adwaita-dark"),
                             QStringLiteral("GNOME"));
        s.matsu = true;
        auto b = WindowChrome::choose(s, QStringLiteral("auto"));
        QCOMPARE(b.style, QStringLiteral("matsu"));
        QCOMPARE(b.left, list({"close", "minimize", "maximize"}));
        // Botões à direita no Matsu OS continuam sendo as bolinhas dele.
        s.layout = QStringLiteral(":minimize,maximize,close");
        b = WindowChrome::choose(s, QStringLiteral("auto"));
        QCOMPARE(b.style, QStringLiteral("matsu"));
        QCOMPARE(b.right, list({"minimize", "maximize", "close"}));
    }

    void recognisesMatsuFromOsRelease()
    {
        QVERIFY(WindowChrome::osReleaseIsMatsu(QStringLiteral("NAME=\"Matsu 27 OS\"\nID=matsu\n")));
        QVERIFY(WindowChrome::osReleaseIsMatsu(QStringLiteral("PRETTY_NAME=\"Matsu 28 OS (Atomic)\"\n")));
        QVERIFY(WindowChrome::osReleaseIsMatsu(QStringLiteral("NAME=\"M-a_t s u\"\n")));
        QVERIFY(WindowChrome::osReleaseIsMatsu(QStringLiteral("ID=MATSU\n")));
        QVERIFY(!WindowChrome::osReleaseIsMatsu(QStringLiteral("NAME=\"Fedora Linux\"\nID=fedora\n")));
        // Só ID, NAME e PRETTY_NAME contam.
        QVERIFY(!WindowChrome::osReleaseIsMatsu(QStringLiteral("HOME_URL=\"https://matsu.example\"\n")));
    }
};

QTEST_GUILESS_MAIN(TestWindowChrome)
#include "tst_windowchrome.moc"
