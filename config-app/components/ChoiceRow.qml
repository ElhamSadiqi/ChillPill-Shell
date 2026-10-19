import QtQuick
import "../"

SRow {
    id: c
    property var options: []
    property string value: ""
    signal edited(string v)
    Row {
        spacing: 4
        Repeater {
            model: c.options
            Rectangle {
                id: opt
                required property string modelData
                readonly property bool sel: opt.modelData === c.value

                width: lbl.implicitWidth + 24
                height: 30
                radius: 7
                antialiasing: true

                border.width: 1
                border.color: opt.sel ? Theme.transparent : (optMa.containsMouse ? Theme.borderBg1 : Theme.borderBg3)
                Behavior on border.color { ColorAnimation { duration: Theme.durFast } }

                scale: optMa.pressed ? 0.96 : 1
                Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }

                color: opt.sel
                    ? (optMa.pressed ? Theme.accentLo : Theme.accent)
                    : (optMa.pressed ? Theme.bg8 : (optMa.containsMouse ? Theme.bg7 : Theme.bg3))
                Behavior on color { ColorAnimation { duration: Theme.durFast } }

                Text {
                    id: lbl
                    anchors.centerIn: parent
                    text: opt.modelData
                    color: opt.sel ? Theme.bgD : (optMa.containsMouse ? Theme.fg1 : Theme.fg3)
                    font.family: Theme.fontFamily
                    Behavior on color { ColorAnimation { duration: Theme.durFast } }
                }
                MouseArea {
                    id: optMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: c.edited(opt.modelData)
                }
            }
        }
    }
}
