import QtQuick
import Drift

// Kipper: abas do painel de recursos no alto, com ícone em cima e nome embaixo, como no
// CapCut e no Concat (Mídia, Texto, Legendas, Figurinhas, Efeitos, Transições...). Rola para o
// lado quando o painel fica estreito. Setas do teclado trocam de aba depois de ganhar foco.
ScrollStrip {
    id: root

    property int activeTab: 0
    property int tabCount: 0
    property var tabLabels: ({})
    property var tabIcons: []
    property var tabs: null

    signal tabSelected(int index)

    readonly property real cellWidth: 60
    height: 58
    vertical: false

    Accessible.role: Accessible.PageTabList

    function step(delta) {
        const next = (root.activeTab + delta + root.tabCount) % root.tabCount
        root.tabSelected(next)
    }

    function revealActive() {
        const item = tabRepeater.itemAt(root.activeTab)
        if (!item)
            return
        const left = tabRow.x + item.x
        const right = left + item.width
        if (left < root._pos)
            root.scrollTo(left - Theme.spacingSm)
        else if (right > root._pos + root.width)
            root.scrollTo(right - root.width + Theme.spacingSm)
    }

    onActiveTabChanged: Qt.callLater(revealActive)

    Keys.onLeftPressed: function(event) {
        root.step(-1)
        event.accepted = true
    }
    Keys.onRightPressed: function(event) {
        root.step(1)
        event.accepted = true
    }

    Row {
        id: tabRow
        x: Theme.spacingXs
        height: root.height
        spacing: 0

        Repeater {
            id: tabRepeater
            model: root.tabs

            delegate: Item {
                id: cell

                required property int index
                required property var model
                readonly property bool current: root.activeTab === index
                readonly property string label: root.tabLabels[model.tabId] ?? ""

                width: Math.max(root.cellWidth, labelText.implicitWidth + Theme.spacingMd * 2)
                height: tabRow.height

                Accessible.role: Accessible.PageTab
                Accessible.name: label
                Accessible.checked: current

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 4
                    radius: Theme.c.iconButton.radius
                    color: cell.current ? Theme.c.iconButton.backgroundActive
                           : tap.containsMouse ? Theme.c.iconButton.ghostBackgroundHover : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 3

                    IconGlyph {
                        anchors.horizontalCenter: parent.horizontalCenter
                        glyph: root.tabIcons[cell.model.icon]
                        iconSize: 18
                        iconColor: cell.current ? Theme.c.iconButton.foregroundActive
                                   : tap.containsMouse ? Theme.c.iconButton.labelForeground
                                   : Theme.c.iconButton.foreground
                    }

                    Text {
                        id: labelText
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: cell.label
                        color: cell.current ? Theme.c.iconButton.foregroundActive
                               : tap.containsMouse ? Theme.c.iconButton.labelForeground
                               : Theme.c.iconButton.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBase * 0.82
                        font.weight: cell.current ? Font.DemiBold : Font.Normal
                    }
                }

                MouseArea {
                    id: tap
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.tabSelected(cell.index)
                }
            }
        }
    }
}
