import QtQuick
import QtQuick.Controls.Basic
import Drift

ThemedDialog {
    id: root

    title: qsTr("Help")
    preferredWidth: 460
    showFooter: true
    showReject: false
    acceptText: qsTr("Close")

    // Kipper: ajuda e contato pelo GitHub do projeto.
    readonly property var links: [
        { glyph: Theme.icons.bug, title: qsTr("Open an issue on GitHub"),
          url: "https://github.com/kaikydev1-jpg/KIPPER/issues",
          label: "github.com/kaikydev1-jpg/KIPPER/issues" },
        { glyph: Theme.icons.bookOpen, title: qsTr("Read the docs"),
          url: "https://github.com/kaikydev1-jpg/KIPPER#readme", label: "github.com/kaikydev1-jpg/KIPPER" }
    ]

    contentItem: Column {
        spacing: Theme.spacingXl
        width: parent ? parent.width : 460

        Repeater {
            model: root.links

            delegate: Item {
                required property var modelData
                width: parent.width
                height: Math.max(linkText.implicitHeight, openButton.implicitHeight)

                IconGlyph {
                    id: linkIcon
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: modelData.glyph
                    iconSize: Theme.iconSizeMd
                }

                Column {
                    id: linkText
                    anchors.left: linkIcon.right
                    anchors.right: openButton.left
                    anchors.leftMargin: Theme.spacingLg
                    anchors.rightMargin: Theme.spacingLg
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacingXs

                    ThemedLabel {
                        width: parent.width
                        text: modelData.title
                        size: "sm"
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                    }

                    ThemedLabel {
                        width: parent.width
                        text: modelData.label
                        size: "xs"
                        tone: "muted"
                        elide: Text.ElideRight
                    }
                }

                ThemedButton {
                    id: openButton
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    variant: "secondary"
                    text: qsTr("Open")
                    onClicked: Qt.openUrlExternally(modelData.url)
                }
            }
        }
    }
}
