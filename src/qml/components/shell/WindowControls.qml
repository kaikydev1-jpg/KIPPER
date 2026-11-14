import QtQuick
import QtQuick.Shapes
import QtQuick.Window
import Drift

// Botões da janela da barra de título integrada do Kipper (minimizar, maximizar, fechar).
//
// Um grupo por lado da janela (`side`: "left" ou "right"). Quais botões e em que ordem vêm do
// WindowChrome, que segue o sistema (gtk-decoration-layout no Linux) ou a escolha feita nas
// configurações. Estilos:
//   windows  Windows 11: 46 px de largura, ícones finos de 10 px, fechar vermelho #C42B1C.
//   gnome    redondos do Adwaita.
//   kde      Breeze: só o símbolo; ao passar o mouse, um círculo (vermelho no fechar).
//   mac      bolinhas coloridas no estilo do macOS.
//   matsu    bolinhas do Matsu OS: 12 px, 8 px entre elas, 14 px de margem; símbolos só com o
//            mouse em cima do grupo; cinza sem foco (#59545d escuro, #c9c9cf claro).
Item {
    id: root

    property string side: "right"
    // Janelas de tamanho fixo (avisos, por exemplo) mostram só o que faz sentido nelas.
    property var allowed: ["close", "minimize", "maximize"]

    readonly property var buttons: (side === "left" ? WindowChrome.leftButtons : WindowChrome.rightButtons)
                                   .filter(b => allowed.indexOf(b) >= 0)
    readonly property string chromeStyle: WindowChrome.style
    readonly property bool dots: chromeStyle === "mac" || chromeStyle === "matsu"
    readonly property var win: Window.window
    readonly property bool windowActive: win ? win.active : true
    readonly property bool maximized: win ? win.visibility === Window.Maximized : false
    readonly property bool dark: Theme.darkMode
    readonly property color foreground: Theme.c.appWindow.paletteText
    // Bolinhas: o grupo todo reage junto ao mouse, como no Mac.
    readonly property bool groupHovered: groupHover.hovered

    // Espaço entre o grupo e a borda da janela.
    readonly property real edgeMargin: chromeStyle === "windows" ? 0
                                      : dots ? 14
                                      : chromeStyle === "kde" ? 8 : 10
    readonly property real spacing: chromeStyle === "windows" ? 0
                                   : dots ? 8
                                   : chromeStyle === "kde" ? 6 : 12

    // Não ler `visible` para o tamanho: ele fica falso enquanto a janela ainda está escondida.
    readonly property bool shown: WindowChrome.integrated && buttons.length > 0
    visible: shown
    implicitWidth: shown ? row.implicitWidth + edgeMargin + (chromeStyle === "windows" ? 0 : edgeMargin * 0.5) : 0
    implicitHeight: Theme.headerHeight

    function trigger(role) {
        if (!root.win)
            return
        if (role === "close")
            root.win.close()
        else if (role === "minimize")
            root.win.showMinimized()
        else if (role === "maximize")
            root.maximized ? root.win.showNormal() : root.win.showMaximized()
    }

    function label(role) {
        if (role === "close")
            return qsTr("Close")
        if (role === "minimize")
            return qsTr("Minimize")
        return root.maximized ? qsTr("Restore") : qsTr("Maximize")
    }

    HoverHandler {
        id: groupHover
        target: row
    }

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: root.side === "left" ? parent.left : undefined
        anchors.right: root.side === "right" ? parent.right : undefined
        anchors.leftMargin: root.side === "left" ? root.edgeMargin : 0
        anchors.rightMargin: root.side === "right" ? root.edgeMargin : 0
        spacing: root.spacing
        height: root.chromeStyle === "windows" ? root.height : 24
        layoutDirection: Qt.LeftToRight
        LayoutMirroring.enabled: false
        LayoutMirroring.childrenInherit: true

        Repeater {
            model: root.buttons

            delegate: Item {
                id: button

                required property string modelData
                readonly property string role: modelData
                readonly property bool hovered: mouse.containsMouse
                readonly property bool pressed: mouse.pressed

                width: root.chromeStyle === "windows" ? 46
                       : root.dots ? 12
                       : root.chromeStyle === "kde" ? 18 : 24
                height: root.chromeStyle === "windows" ? row.height : width
                anchors.verticalCenter: parent.verticalCenter

                Accessible.role: Accessible.Button
                Accessible.name: root.label(role)

                Component.onCompleted: WindowChrome.setSystemButton(role, button)

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    // Bolinhas pequenas: um pouco de folga para acertar o clique.
                    anchors.margins: root.dots ? -3 : 0
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton
                    onClicked: root.trigger(button.role)
                }

                // --- Windows 11 ---------------------------------------------------------
                Rectangle {
                    anchors.fill: parent
                    visible: root.chromeStyle === "windows"
                    color: {
                        if (button.role === "close" && (button.hovered || button.pressed))
                            return button.pressed ? Qt.rgba(0.769, 0.169, 0.110, 0.9) : "#C42B1C"
                        if (button.pressed)
                            return Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.05)
                        if (button.hovered)
                            return Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.08)
                        return "transparent"
                    }
                }

                // --- GNOME (Adwaita) e KDE (Breeze) --------------------------------------
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width
                    height: width
                    radius: width / 2
                    visible: root.chromeStyle === "gnome" || root.chromeStyle === "kde"
                    color: {
                        const f = root.foreground
                        if (root.chromeStyle === "kde") {
                            if (button.role === "close" && (button.hovered || button.pressed))
                                return button.pressed ? "#c0392b" : "#da4453"
                            if (button.pressed)
                                return Qt.rgba(f.r, f.g, f.b, 0.30)
                            return button.hovered ? Qt.rgba(f.r, f.g, f.b, 0.18) : "transparent"
                        }
                        if (button.pressed)
                            return Qt.rgba(f.r, f.g, f.b, 0.28)
                        return Qt.rgba(f.r, f.g, f.b, button.hovered ? 0.15 : 0.10)
                    }
                }

                // --- Mac e Matsu OS: bolinhas --------------------------------------------
                Rectangle {
                    id: dot
                    anchors.centerIn: parent
                    width: 12
                    height: 12
                    radius: 6
                    visible: root.dots
                    readonly property bool lit: root.windowActive || root.groupHovered
                    readonly property color base: {
                        if (!lit)
                            return root.dark ? "#59545d" : "#c9c9cf"
                        if (button.role === "close")
                            return "#ff5f57"
                        if (button.role === "minimize")
                            return "#febc2e"
                        return "#28c840"
                    }
                    // Apertando: a bolinha escurece um pouco (brilho 82%).
                    color: button.pressed ? Qt.rgba(base.r * 0.82, base.g * 0.82, base.b * 0.82, 1) : base
                }

                // --- Símbolos -----------------------------------------------------------
                Shape {
                    id: glyph
                    anchors.centerIn: parent
                    width: root.dots ? 12 : 10
                    height: width
                    preferredRendererType: Shape.CurveRenderer
                    antialiasing: true
                    visible: root.dots ? root.groupHovered : true
                    opacity: root.dots ? 1 : (root.windowActive || button.hovered ? 1 : 0.45)

                    readonly property color ink: {
                        if (root.dots) {
                            const c = button.role === "close" ? Qt.color("#4d0000")
                                    : button.role === "minimize" ? Qt.color("#995700")
                                    : Qt.color("#006500")
                            return button.pressed ? Qt.rgba(c.r * 0.82, c.g * 0.82, c.b * 0.82, 1) : c
                        }
                        const redHover = button.role === "close" && (button.hovered || button.pressed)
                                         && (root.chromeStyle === "windows" || root.chromeStyle === "kde")
                        return redHover ? "#ffffff" : root.foreground
                    }
                    readonly property real stroke: root.dots ? 1.35 : root.chromeStyle === "windows" ? 1 : 1.5
                    readonly property string kind: {
                        if (button.role === "close")
                            return "close"
                        if (button.role === "minimize")
                            return root.chromeStyle === "kde" ? "chevronDown" : "minimize"
                        if (root.dots)
                            return "fullscreen"
                        if (root.chromeStyle === "kde")
                            return root.maximized ? "diamond" : "chevronUp"
                        return root.maximized ? "restore" : "maximize"
                    }

                    // × (fechar)
                    ShapePath {
                        strokeColor: glyph.kind === "close" ? glyph.ink : "transparent"
                        strokeWidth: glyph.stroke
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap
                        startX: root.dots ? 4 : 0.5; startY: root.dots ? 4 : 0.5
                        PathLine { x: glyph.width - (root.dots ? 4 : 0.5); y: glyph.width - (root.dots ? 4 : 0.5) }
                        PathMove { x: glyph.width - (root.dots ? 4 : 0.5); y: root.dots ? 4 : 0.5 }
                        PathLine { x: root.dots ? 4 : 0.5; y: glyph.width - (root.dots ? 4 : 0.5) }
                    }

                    // − (minimizar)
                    ShapePath {
                        strokeColor: glyph.kind === "minimize" ? glyph.ink : "transparent"
                        strokeWidth: glyph.stroke
                        fillColor: "transparent"
                        capStyle: root.chromeStyle === "windows" ? ShapePath.FlatCap : ShapePath.RoundCap
                        startX: root.dots ? 3.5 : 0; startY: glyph.height / 2
                        PathLine { x: glyph.width - (root.dots ? 3.5 : 0); y: glyph.height / 2 }
                    }

                    // □ (maximizar)
                    ShapePath {
                        strokeColor: glyph.kind === "maximize" ? glyph.ink : "transparent"
                        strokeWidth: glyph.stroke
                        fillColor: "transparent"
                        joinStyle: ShapePath.MiterJoin
                        startX: root.chromeStyle === "gnome" ? 1.5 : 0.5
                        startY: root.chromeStyle === "gnome" ? 1.5 : 0.5
                        PathLine { x: glyph.width - (root.chromeStyle === "gnome" ? 1.5 : 0.5); y: root.chromeStyle === "gnome" ? 1.5 : 0.5 }
                        PathLine { x: glyph.width - (root.chromeStyle === "gnome" ? 1.5 : 0.5); y: glyph.height - (root.chromeStyle === "gnome" ? 1.5 : 0.5) }
                        PathLine { x: root.chromeStyle === "gnome" ? 1.5 : 0.5; y: glyph.height - (root.chromeStyle === "gnome" ? 1.5 : 0.5) }
                        PathLine { x: root.chromeStyle === "gnome" ? 1.5 : 0.5; y: root.chromeStyle === "gnome" ? 1.5 : 0.5 }
                    }

                    // ⧉ (restaurar): dois quadradinhos
                    ShapePath {
                        strokeColor: glyph.kind === "restore" ? glyph.ink : "transparent"
                        strokeWidth: glyph.stroke
                        fillColor: "transparent"
                        joinStyle: ShapePath.MiterJoin
                        // da frente
                        startX: 0.5; startY: 2.5
                        PathLine { x: 7.5; y: 2.5 }
                        PathLine { x: 7.5; y: 9.5 }
                        PathLine { x: 0.5; y: 9.5 }
                        PathLine { x: 0.5; y: 2.5 }
                        // de trás
                        PathMove { x: 2.5; y: 2.5 }
                        PathLine { x: 2.5; y: 0.5 }
                        PathLine { x: 9.5; y: 0.5 }
                        PathLine { x: 9.5; y: 7.5 }
                        PathLine { x: 7.5; y: 7.5 }
                    }

                    // ˅ e ˄ (Breeze) e ◇ (Breeze restaurar)
                    ShapePath {
                        strokeColor: glyph.kind === "chevronDown" || glyph.kind === "chevronUp"
                                     || glyph.kind === "diamond" ? glyph.ink : "transparent"
                        strokeWidth: glyph.stroke
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap
                        joinStyle: ShapePath.RoundJoin
                        startX: glyph.kind === "diamond" ? 5 : 1
                        startY: glyph.kind === "chevronDown" ? 3 : glyph.kind === "chevronUp" ? 7 : 1
                        PathLine {
                            x: glyph.kind === "diamond" ? 9 : 5
                            y: glyph.kind === "chevronDown" ? 7 : glyph.kind === "chevronUp" ? 3 : 5
                        }
                        PathLine {
                            x: glyph.kind === "diamond" ? 5 : 9
                            y: glyph.kind === "chevronDown" ? 3 : glyph.kind === "chevronUp" ? 7 : 9
                        }
                        PathLine { x: glyph.kind === "diamond" ? 1 : 9; y: glyph.kind === "diamond" ? 5 : (glyph.kind === "chevronDown" ? 3 : 7) }
                        PathLine { x: glyph.kind === "diamond" ? 5 : 9; y: glyph.kind === "diamond" ? 1 : (glyph.kind === "chevronDown" ? 3 : 7) }
                    }

                    // Tela cheia (Mac e Matsu OS): dois triângulos
                    ShapePath {
                        strokeColor: "transparent"
                        fillColor: glyph.kind === "fullscreen" ? glyph.ink : "transparent"
                        startX: 3.4; startY: 3.4
                        PathLine { x: 7.3; y: 3.4 }
                        PathLine { x: 3.4; y: 7.3 }
                        PathLine { x: 3.4; y: 3.4 }
                        PathMove { x: 8.6; y: 8.6 }
                        PathLine { x: 4.7; y: 8.6 }
                        PathLine { x: 8.6; y: 4.7 }
                        PathLine { x: 8.6; y: 8.6 }
                    }
                }
            }
        }
    }
}
