import QtQuick
import Drift

Column {
    width: parent.width
    spacing: Theme.spacingXs

    Image {
        source: "qrc:/app/drift.png"
        width: 56
        height: 56
        fillMode: Image.PreserveAspectFit
        mipmap: true
        smooth: true
    }

    Text {
        text: "Kipper"
        color: Theme.c.startScreenTitle.foreground
        font.family: Theme.fontFamily
        font.pixelSize: 26
        font.weight: Font.Bold
    }

    Text {
        text: qsTr("Create polished videos fast")
        color: Theme.c.startScreenTitle.foregroundMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeBase
    }
}
