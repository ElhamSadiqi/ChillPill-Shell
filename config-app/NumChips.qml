import QtQuick
import QtQuick.Layouts
import "components"
import "."

ColumnLayout {
    id: nc
    property var value: []
    property string suffix: ""
    signal edited(var v)
    Layout.fillWidth: true

    Flow {
        Layout.fillWidth: true
        spacing: 6
        Repeater {
            model: nc.value
            Rectangle {
                id: nchip
                required property int index
                required property var modelData
                width: nl.implicitWidth + 40; height: 30; radius: 15
                antialiasing: true
                color: rmMa.containsMouse ? Theme.bg4 : Theme.bg2
                Behavior on color { ColorAnimation { duration: Theme.durFast } }
                Text { id: nl; x: 12; anchors.verticalCenter: parent.verticalCenter; text: nchip.modelData + nc.suffix; color: Theme.fg; font.family: Theme.fontFamily }
                Text {
                    anchors.right: parent.right; anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: "\u2715"
                    color: rmMa.containsMouse ? Theme.deleting : Theme.fg5
                    font.family: Theme.fontFamily
                    Behavior on color { ColorAnimation { duration: Theme.durFast } }
                    MouseArea {
                        id: rmMa
                        anchors.fill: parent; anchors.margins: -6
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { var a = nc.value.slice(); a.splice(nchip.index, 1); nc.edited(a) }
                    }
                }
            }
        }
        Rectangle {
            id: addBox
            width: addHint.implicitWidth + 32
            height: 30
            radius: 15
            antialiasing: true
            color: ni.activeFocus ? Theme.inputBgFocus : (afma.containsMouse ? Theme.inputBgHover : Theme.inputBg)
            Behavior on color { ColorAnimation { duration: Theme.durFast } }

            border.width: 1
            border.color: ni.activeFocus ? Theme.accent : (afma.containsMouse ? Theme.borderBg1 : Theme.borderBg3)
            Behavior on border.color { ColorAnimation { duration: Theme.durFast } }

            TextInput {
                id: ni
                anchors.fill: parent
                anchors.leftMargin: 16; anchors.rightMargin: 16
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.fg
                font.family: Theme.fontFamily
                selectionColor: Theme.accent
                selectedTextColor: Theme.bgD
                selectByMouse: true
                inputMethodHints: Qt.ImhDigitsOnly
                onAccepted: {
                    var v = Number(text)
                    if (!isNaN(v) && v > 0 && nc.value.indexOf(v) < 0)
                        nc.edited(nc.value.concat([v]).sort((a, b) => a - b))
                    text = ""
                }
            }
            Text {
                id: addHint
                anchors.fill: parent
                anchors.leftMargin: 16
                verticalAlignment: Text.AlignVCenter
                visible: ni.text === "" && !ni.activeFocus
                text: "add + Enter"
                color: Theme.fg6
                font.family: Theme.fontFamily
            }

            MouseArea {
                id: afma
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                cursorShape: Qt.IBeamCursor
            }
        }
    }
    Text {
        Layout.fillWidth: true
        visible: nc.value.length === 0
        text: "No presets — type a number and press Enter"
        color: Theme.fg6
        font.family: Theme.fontFamily
    }
}
