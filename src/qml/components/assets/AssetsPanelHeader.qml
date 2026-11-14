import QtQuick
import Drift
// Panel title and the media-tab import actions. Catalog tabs hide this bar:
// their search field names the tab and carries its actions.
Rectangle {
    id: root

    property string title: ""
    property bool showTitle: true
    property bool showActions: false
    property bool importing: false

    signal newFolderRequested()
    signal newTimelineRequested()
    signal importFilesRequested()
    signal importFolderRequested()
    signal collectMediaRequested()

    // Matches the surrounding PanelFrame; it used to paint the app
    // background, so the header read as a different surface than the
    // panel it belongs to.
    color: Theme.c.assetsPanelHeader.background

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: Theme.c.assetsPanelHeader.borderWidth
        color: Theme.c.assetsPanelHeader.border
    }

    Text {
        anchors.left: parent.left
        anchors.leftMargin: Theme.pagePadding
        anchors.right: root.showActions ? undefined : parent.right
        anchors.rightMargin: Theme.pagePadding
        anchors.verticalCenter: parent.verticalCenter
        elide: Text.ElideRight
        // Sheet chrome already shows the tab title.
        visible: root.showTitle
        text: root.title
        color: Theme.c.assetsPanelHeader.foregroundMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSm
    }

    // Kipper: em painel estreito os botões secundários ficam só com o ícone (a dica mantém o
    // nome) e o Importar continua inteiro, em vez de a fileira sair cortada pela esquerda.
    readonly property bool compactActions: root.width < 440

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6
        visible: root.showActions

        ThemedButton {
            text: root.compactActions ? "" : qsTr("New Folder")
            variant: "ghost"
            glyph: Theme.icons.folder
            tooltip: qsTr("Create a new folder here")
            anchors.verticalCenter: parent.verticalCenter
            onClicked: root.newFolderRequested()
        }

        ThemedButton {
            text: root.compactActions ? "" : qsTr("New timeline")
            variant: "ghost"
            glyph: Theme.icons.layers
            tooltip: qsTr("Create an empty timeline and open it")
            anchors.verticalCenter: parent.verticalCenter
            onClicked: root.newTimelineRequested()
        }

        AssetsPanelImportSplit {
            anchors.verticalCenter: parent.verticalCenter
            importing: root.importing
            onImportFilesRequested: root.importFilesRequested()
            onImportFolderRequested: root.importFolderRequested()
            onCollectMediaRequested: root.collectMediaRequested()
        }
    }
}
