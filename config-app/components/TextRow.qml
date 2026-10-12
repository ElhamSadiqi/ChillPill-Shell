import QtQuick
import "../"

SRow {
    id: tr
    property string value: ""
    property string placeholder: ""
    property int fieldWidth: 280
    property alias input: ti
    signal edited(string v)

    Rectangle {
        id: field
        width: tr.fieldWidth
        height: 32
        radius: 7
        antialiasing: true

        color: ti.activeFocus ? Theme.inputBgFocus : (fma.containsMouse ? Theme.inputBgHover : Theme.inputBg)
        Behavior on color { ColorAnimation { duration: Theme.durFast } }

        border.width: 1
        border.color: ti.activeFocus ? Theme.accent
            : (fma.containsMouse ? Theme.borderBg1 : Theme.borderBg3)
        Behavior on border.color { ColorAnimation { duration: Theme.durFast } }

        TextInput {
            id: ti
            anchors.fill: parent
            anchors.margins: 9
            verticalAlignment: TextInput.AlignVCenter
            color: Theme.fg
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeBase - 1
            selectionColor: Theme.accent
            selectedTextColor: Theme.bgD
            selectByMouse: true
            clip: true
            text: tr.value
            onEditingFinished: tr.edited(text)
        }

        Text {
            anchors.fill: parent
            anchors.margins: 9
            verticalAlignment: Text.AlignVCenter
            visible: ti.text === "" && !ti.activeFocus
            text: tr.placeholder
            color: Theme.fg4
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeBase - 1
            elide: Text.ElideRight
        }

        MouseArea {
            id: fma
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.IBeamCursor
        }
    }
}
