import QtQuick
import QtQuick.Controls.Basic
import Drift

// Title, author and description — the metadata stamped into the .drift bundle. Author defaults
// from the last one used, so it is typed once rather than per project.
ThemedDialog {
    id: root

    title: qsTr("Project properties")
    acceptText: qsTr("Save")
    preferredWidth: Theme.dialogWidthMd
    // Return would commit while the user is still in the description.
    acceptOnReturn: false

    function shortDate(value) {
        const d = new Date(value)
        return isNaN(d.getTime()) ? "" : d.toLocaleString(Qt.locale(), Locale.ShortFormat)
    }

    function openDialog() {
        const meta = EditorState.projectFile.projectMetadata
        titleField.text = meta.title
        authorField.text = meta.author
        descriptionField.text = meta.description
        // Kipper: no formato curto do idioma (Qt.formatDateTime com Locale.ShortFormat saía em ISO).
        createdLabel.text = root.shortDate(meta.createdAt)
        modifiedLabel.text = root.shortDate(meta.modifiedAt)
        open()
    }

    onAccepted: EditorState.projectFile.setProjectMetadata(titleField.text, authorField.text,
                                               descriptionField.text)

    contentItem: Column {
        spacing: Theme.spacingLg
        width: parent ? parent.width : 400

        ThemedLabel {
            text: qsTr("Title")
        }

        ThemedTextField {
            id: titleField
            width: parent.width
            placeholderText: qsTr("Untitled Project")
        }

        ThemedLabel {
            text: qsTr("Author")
        }

        ThemedTextField {
            id: authorField
            width: parent.width
            placeholderText: qsTr("Your name")
        }

        ThemedLabel {
            text: qsTr("Description")
        }

        ThemedTextArea {
            id: descriptionField
            width: parent.width
            height: 96
            placeholderText: qsTr("What this project is")
        }

        Row {
            spacing: Theme.spacingLg

            ThemedLabel {
                size: "sm"
                text: qsTr("Created")
            }

            ThemedLabel {
                id: createdLabel
                size: "sm"
                tone: "default"
            }

            ThemedLabel {
                size: "sm"
                text: qsTr("Modified")
            }

            ThemedLabel {
                id: modifiedLabel
                size: "sm"
                tone: "default"
            }
        }
    }
}
