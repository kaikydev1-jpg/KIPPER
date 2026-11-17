import QtQuick
import Drift
import QtQuick.Layouts

// ---- GIF mode ----
Column {
    id: section
    required property var dialog
    property alias gifFrameRateCombo: gifFrameRateCombo

    width: parent.width
    spacing: Theme.spacingXl
    visible: dialog.isGifExport
    height: visible ? implicitHeight : 0
    clip: true

    ThemedLabel {
        width: parent.width
        size: "sm"
        text: qsTr("Animated GIF — no audio. Mark a work area for short loops, or export up to 60 seconds.")
    }

    ThemedLabel {
        text: qsTr("Downscale")
    }

    Flow {
        width: parent.width
        spacing: Theme.spacingMd

        Repeater {
            // Kipper: GIF só no tamanho do projeto ou menor (um GIF em 2K/4K fica enorme).
            model: {
                const all = dialog.scaleOptions
                const src = all.length > 0 ? all[0] : null
                return src ? all.filter(o => o.id === "source" || o.height * o.width <= src.height * src.width)
                           : all
            }

            delegate: ThemedChip {
                required property var modelData
                text: modelData.label
                selected: dialog.scaleId === modelData.id
                tooltip: qsTr("Export at %1×%2").arg(modelData.width).arg(modelData.height)
                onClicked: {
                    dialog.scaleId = modelData.id
                    dialog.targetHeight = modelData.targetHeight
                }
            }
        }
    }

    Column {
        width: parent.width
        spacing: Theme.spacingSm

        ThemedLabel {
            text: qsTr("Frame rate")
        }

        RowLayout {
            width: parent.width
            spacing: Theme.spacingMd

            ThemedComboBox {
                id: gifFrameRateCombo
                Layout.fillWidth: true
                textRole: "label"
                valueRole: "id"
                model: dialog.frameRateModel
                onActivated: function (index) {
                    dialog.applyFrameRateChoice(dialog.frameRateModel[index])
                }
            }

            ThemedNumberField {
                Layout.preferredWidth: 120
                visible: dialog.frameRateCustom
                from: 1
                to: 30
                step: 1
                unit: qsTr("fps")
                value: dialog.fpsNum > 0 ? dialog.fpsNum : 15
                onEdited: function (v) {
                    dialog.fpsNum = Math.round(v)
                    dialog.fpsDen = 1
                }
            }
        }

        ThemedLabel {
            width: parent.width
            size: "sm"
            text: qsTr("15 fps is a good default for small file sizes. GIF export is limited to 60 seconds.")
        }
    }
    }
