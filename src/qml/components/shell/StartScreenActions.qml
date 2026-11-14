import QtQuick
import Drift

// Kipper: começo de projeto no estilo do CapCut. Um cartão grande "Criar projeto" e, embaixo,
// os formatos prontos (em pé para TikTok/Reels/Shorts, deitado para YouTube, quadrado), que já
// abrem o projeto no tamanho certo. "Abrir projeto…" fica ao lado, mais discreto.
Column {
    id: actions

    signal newProjectRequested()
    signal openProjectRequested()
    // Projeto novo já com largura e altura (e 30 quadros por segundo).
    signal newProjectWithFormatRequested(int width, int height)

    width: parent.width
    spacing: Theme.spacingXl

    readonly property color cardColor: Theme.c.assetsPanel.background
    readonly property color cardHover: Theme.c.iconButton.ghostBackgroundHover
    readonly property color cardBorder: Theme.c.assetsPanel.border
    readonly property color accent: Theme.c.iconButton.foregroundActive
    readonly property color strong: Theme.c.iconButton.labelForeground
    readonly property color muted: Theme.c.iconButton.foreground

    // --- Criar projeto ---------------------------------------------------------------
    Rectangle {
        id: hero
        width: parent.width
        height: 132
        radius: 14
        color: heroArea.containsMouse ? actions.cardHover : actions.cardColor
        border.width: 1
        border.color: heroArea.containsMouse ? actions.accent : actions.cardBorder
        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }
        transform: Translate { y: heroArea.containsMouse ? -2 : 0; Behavior on y { NumberAnimation { duration: Theme.durationFast } } }

        Accessible.role: Accessible.Button
        Accessible.name: qsTr("Create project")

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 28
            anchors.verticalCenter: parent.verticalCenter
            spacing: 20

            Rectangle {
                width: 60
                height: 60
                radius: 30
                color: actions.accent
                anchors.verticalCenter: parent.verticalCenter
                scale: heroArea.pressed ? 0.94 : 1
                Behavior on scale { NumberAnimation { duration: Theme.durationFast } }

                IconGlyph {
                    anchors.centerIn: parent
                    glyph: Theme.icons.plus
                    iconSize: 28
                    iconColor: Theme.c.appWindow.paletteHighlightedText
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    text: qsTr("Create project")
                    color: actions.strong
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeBase * 1.45
                    font.weight: Font.DemiBold
                }
                Text {
                    text: qsTr("Start from scratch. Drop in your videos, photos and music.")
                    color: actions.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeBase
                }
            }
        }

        MouseArea {
            id: heroArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: actions.newProjectRequested()
        }
    }

    // --- Formatos prontos ------------------------------------------------------------
    Row {
        id: formats
        width: parent.width
        spacing: Theme.spacingXl
        readonly property real cardWidth: (width - spacing * 2) / 3

        Repeater {
            model: [
                { w: 1080, h: 1920, title: qsTr("Vertical · 9:16"), detail: qsTr("TikTok, Reels and Shorts") },
                { w: 1920, h: 1080, title: qsTr("Landscape · 16:9"), detail: qsTr("YouTube and TV") },
                { w: 1080, h: 1080, title: qsTr("Square · 1:1"), detail: qsTr("Instagram feed") }
            ]

            delegate: Rectangle {
                id: card
                required property var modelData
                width: formats.cardWidth
                height: 112
                radius: 12
                color: cardArea.containsMouse ? actions.cardHover : actions.cardColor
                border.width: 1
                border.color: cardArea.containsMouse ? actions.accent : actions.cardBorder
                Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }
                transform: Translate { y: cardArea.containsMouse ? -2 : 0; Behavior on y { NumberAnimation { duration: Theme.durationFast } } }

                Accessible.role: Accessible.Button
                Accessible.name: card.modelData.title

                // Desenho do formato: um retângulo com a proporção certa.
                Item {
                    id: shapeBox
                    width: 52
                    height: 52
                    anchors.left: parent.left
                    anchors.leftMargin: 18
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        readonly property real ratio: card.modelData.w / card.modelData.h
                        width: ratio >= 1 ? shapeBox.width : shapeBox.height * ratio
                        height: ratio >= 1 ? shapeBox.width / ratio : shapeBox.height
                        anchors.centerIn: parent
                        radius: 4
                        color: "transparent"
                        border.width: 2
                        border.color: cardArea.containsMouse ? actions.accent : actions.muted
                        Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }
                    }
                }

                Column {
                    anchors.left: shapeBox.right
                    anchors.leftMargin: 16
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Text {
                        width: parent.width
                        elide: Text.ElideRight
                        text: card.modelData.title
                        color: actions.strong
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBase * 1.05
                        font.weight: Font.DemiBold
                    }
                    Text {
                        width: parent.width
                        elide: Text.ElideRight
                        text: card.modelData.detail
                        color: actions.muted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBase * 0.9
                    }
                }

                MouseArea {
                    id: cardArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: actions.newProjectWithFormatRequested(card.modelData.w, card.modelData.h)
                }
            }
        }
    }

    ThemedButton {
        variant: "ghost"
        glyph: Theme.icons.folder
        text: qsTr("Open Project…")
        onClicked: actions.openProjectRequested()
    }
}
