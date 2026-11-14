import QtQuick
import QtQuick.Window
import Drift

// Kipper: faixa de título das janelas secundárias (assistente inicial, avisos, painéis soltos,
// prévia de mídia). Mesma barra integrada da janela principal: o app vai até o topo, os botões
// seguem o sistema e a faixa arrasta, maximiza no duplo clique e redimensiona pelas bordas.
// Sem a barra integrada (macOS, Android), some e não ocupa espaço.
Item {
    id: root

    property string title: Window.window ? Window.window.title : ""
    property bool showTitle: true
    property var allowed: ["close", "minimize", "maximize"]
    property color background: "transparent"
    property color foreground: Theme.c.appWindow.paletteText

    readonly property real leftInset: leftControls.shown ? leftControls.implicitWidth : 0
    readonly property real rightInset: rightControls.shown ? rightControls.implicitWidth : 0
    // Não ler `visible` para o tamanho: ele fica falso enquanto a janela ainda está escondida.
    property bool shown: WindowChrome.integrated

    visible: shown
    height: shown ? 40 : 0
    implicitHeight: height

    Component.onCompleted: WindowChrome.setTitleBar(root)

    Rectangle {
        anchors.fill: parent
        color: root.background
    }

    Text {
        visible: root.showTitle
        anchors.centerIn: parent
        width: Math.min(implicitWidth, parent.width - 2 * Math.max(root.leftInset, root.rightInset) - 24)
        elide: Text.ElideRight
        text: root.title
        color: root.foreground
        opacity: Window.window && Window.window.active ? 0.9 : 0.5
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeBase * 0.92
        font.weight: Font.DemiBold
    }

    WindowControls {
        id: leftControls
        side: "left"
        allowed: root.allowed
        anchors.left: parent.left
        anchors.top: parent.top
        height: parent.height
        width: implicitWidth
    }

    WindowControls {
        id: rightControls
        side: "right"
        allowed: root.allowed
        anchors.right: parent.right
        anchors.top: parent.top
        height: parent.height
        width: implicitWidth
    }
}
