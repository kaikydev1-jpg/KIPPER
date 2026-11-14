import QtQuick
import QtQuick.Window
import Drift

Window {
    id: root

    function openFor(index) {
        view.openFor(index)
        root.show()
        root.raise()
        root.requestActivate()
    }

    function openClip(track, index) {
        view.openClip(track, index)
        root.show()
        root.raise()
        root.requestActivate()
    }

    width: 920
    height: 680
    minimumWidth: 640
    minimumHeight: 480
    title: view.clipId.length > 0
           ? (view.assetName.length > 0 ? qsTr("Crop — %1").arg(view.assetName) : qsTr("Crop"))
           : (view.assetName.length > 0 ? qsTr("Preview — %1").arg(view.assetName) : qsTr("Preview"))
    color: {
        const opacity = ThemeManager.window.backgroundOpacity
        const multiplier = (opacity === undefined || opacity === null) ? 1 : opacity
        return WindowBackdrop.windowBackground(Theme.c.mediaPreviewWindow.background, multiplier)
    }

    Component.onCompleted: {
        WindowChrome.setup(root) // Kipper: barra de título integrada
        WindowBackdrop.attach(root)
    }

    onClosing: view.release()

    WindowTitleBar {
        id: titleBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
    }

    MediaPreviewView {
        id: view
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: titleBar.bottom
        anchors.bottom: parent.bottom
        onCloseRequested: root.close()
    }
}
