import QtQuick
import QtQuick.Controls.Basic
import Drift

ThemedDialog {
    id: root

    title: qsTr("About Kipper")
    preferredWidth: 420
    showFooter: true
    showReject: false
    acceptText: qsTr("Close")

    contentItem: Column {
        spacing: Theme.spacingXl
        width: parent ? parent.width : 420

        Row {
            spacing: Theme.spacingXl
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                source: "qrc:/app/drift.png"
                width: 64
                height: 64
                fillMode: Image.PreserveAspectFit
                mipmap: true
            }

            Column {
                spacing: Theme.spacingXs
                anchors.verticalCenter: parent.verticalCenter

                ThemedLabel {
                    text: qsTr("Kipper")
                    size: "xl"
                    font.weight: Font.DemiBold
                }

                ThemedLabel {
                    text: qsTr("Version %1").arg(Updates.currentVersion)
                    tone: "muted"
                    size: "sm"
                }
            }
        }

        ThemedLabel {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            size: "sm"
            text: qsTr("Free, open-source video editor, from your first cut to a whole film.")
        }

        // Créditos exigidos pela licença: o Kipper é baseado no Drift (GPLv3).
        ThemedLabel {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            size: "xs"
            tone: "muted"
            textFormat: Text.RichText
            linkColor: Theme.c.debugInfoDialog.link
            text: qsTr("Based on %1 by CutWire Studios, with design ideas from %2.")
                  .arg("<a href=\"https://github.com/CutWire-Studios/Drift\">Drift</a>")
                  .arg("<a href=\"https://github.com/jub0t/Concat\">Concat</a>")
            onLinkActivated: (link) => Qt.openUrlExternally(link)
            HoverHandler {
                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
            }
        }

        ThemedLabel {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            size: "xs"
            tone: "muted"
            textFormat: Text.RichText
            linkColor: Theme.c.debugInfoDialog.link
            text: qsTr("Licensed under GPLv3. Copyright © CutWire Studios and the Kipper contributors. %1")
                  .arg("<a href=\"https://github.com/kaikydev1-jpg/KIPPER\">" + qsTr("Source code") + "</a>")
            onLinkActivated: (link) => Qt.openUrlExternally(link)
            HoverHandler {
                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
            }
        }
    }
}
