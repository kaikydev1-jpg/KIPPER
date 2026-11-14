#pragma once

#include <QList>
#include <QObject>
#include <QPointer>
#include <QQuickItem>
#include <QQuickWindow>
#include <QStringList>
#include <QtQml/qqmlregistration.h>

#include <utility>

namespace QWK {
class QuickWindowAgent;
}

// Barra de título integrada do Kipper (padrão dos apps do criador, seção 4).
//
// A janela não usa a barra cinza do sistema: o próprio app vai até o topo e desenha os botões
// de minimizar, maximizar e fechar. Esta classe decide COMO desenhar esses botões e liga a
// QWindowKit, que cuida do que tem que continuar igual a uma janela normal: arrastar pela
// faixa de cima, duplo clique para maximizar, redimensionar pelas bordas e cantos e, no
// Windows 11, sombra, cantos arredondados e o encaixe (Aero Snap / Snap Layouts).
//
// Estilo dos botões:
//   - Windows: sempre no estilo do Windows 11, à direita.
//   - Linux: lado, ordem e quais botões vêm de gtk-decoration-layout (o GNOME e o KDE
//     preenchem; no Flatpak chega pelo portal de configurações). Tema estilo Mac ou botões à
//     esquerda viram bolinhas; GNOME usa os redondos do Adwaita; KDE, o estilo Breeze.
//   - Matsu OS (sistema do criador, reconhecido pelo os-release): as bolinhas dele, com as
//     cores exatas, no lado que o sistema usa. É automático, não é opção nas configurações.
//   - Nas configurações a pessoa pode forçar: Automático, Windows, GNOME, KDE ou Mac.
//
// No macOS, no Android e no navegador a janela continua com a barra do sistema: `integrated`
// fica falso e todas as chamadas abaixo viram nada.
class WindowChrome : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool integrated READ integrated CONSTANT)
    Q_PROPERTY(bool matsu READ matsu CONSTANT)
    Q_PROPERTY(QString styleSetting READ styleSetting WRITE setStyleSetting NOTIFY styleChanged)
    Q_PROPERTY(QString style READ style NOTIFY styleChanged)
    Q_PROPERTY(QStringList leftButtons READ leftButtons NOTIFY styleChanged)
    Q_PROPERTY(QStringList rightButtons READ rightButtons NOTIFY styleChanged)
    Q_PROPERTY(QStringList styleOptions READ styleOptions CONSTANT)

public:
    static WindowChrome *shared();
    static void registerSingleton();

    // O que o sistema informa; vazio quando não se sabe. Público para os testes.
    struct System
    {
        QString os;      // "windows", "linux" ou "mac"
        QString layout;  // gtk-decoration-layout, ex.: "appmenu:close" ou "close,minimize,maximize:"
        QString theme;   // tema GTK, ex.: "Adwaita-dark", "WhiteSur-Dark"
        QString desktop; // XDG_CURRENT_DESKTOP, ex.: "GNOME", "KDE"
        bool matsu = false;
    };
    struct Buttons
    {
        QString style;
        QStringList left;
        QStringList right;
    };

    // Escolhe estilo e lado. `preferred` vem da configuração ("auto" segue o sistema).
    static Buttons choose(const System &system, const QString &preferred);
    // "esquerda:direita", só com close, minimize e maximize, sem repetir.
    static std::pair<QStringList, QStringList> parseLayout(const QString &layout);
    // Matsu OS: ID, NAME ou PRETTY_NAME do os-release contém "matsu" (ignora maiúsculas,
    // espaços, hífen, sublinhado e aspas).
    static bool osReleaseIsMatsu(const QString &osReleaseText);

    bool integrated() const { return m_integrated; }
    bool matsu() const { return m_system.matsu; }
    QString styleSetting() const { return m_styleSetting; }
    void setStyleSetting(const QString &setting);
    QString style() const { return m_buttons.style; }
    QStringList leftButtons() const { return m_buttons.left; }
    QStringList rightButtons() const { return m_buttons.right; }
    QStringList styleOptions() const;

    // Liga a barra integrada nesta janela. Chamar antes de mostrar a janela.
    Q_INVOKABLE bool setup(QQuickWindow *window);
    // A faixa de cima que arrasta a janela.
    Q_INVOKABLE void setTitleBar(QQuickItem *item);
    // "minimize", "maximize" ou "close": no Windows 11 o maximizar abre o Snap Layouts.
    Q_INVOKABLE void setSystemButton(const QString &role, QQuickItem *item);
    // Partes da faixa que são clicáveis (botões, campos) e não arrastam.
    Q_INVOKABLE void setHitTestVisible(QQuickItem *item, bool visible = true);
    // Relê o sistema (lado dos botões, tema). Barato; chamado quando o tema muda.
    Q_INVOKABLE void refresh();

signals:
    void styleChanged();

private:
    explicit WindowChrome(QObject *parent = nullptr);
    ~WindowChrome() override;

    System readSystem() const;
    void recompute();

    bool m_integrated = false;
    QString m_styleSetting;
    System m_system;
    Buttons m_buttons;
    QPointer<QQuickWindow> m_window;
    QWK::QuickWindowAgent *m_agent = nullptr;
    // Pedidos feitos antes de setup() (os itens da tela terminam de carregar antes da janela).
    QPointer<QQuickItem> m_pendingTitleBar;
    QList<std::pair<QString, QPointer<QQuickItem>>> m_pendingButtons;
    QList<std::pair<QPointer<QQuickItem>, bool>> m_pendingHitTest;
};
