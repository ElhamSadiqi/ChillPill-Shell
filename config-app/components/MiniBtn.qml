import QtQuick
import "../"

Rectangle {
    id: b
    property string label: ""
    property int fontSize: 12
    property bool textBold: false
    property int rectRadius: 6
    property int btnHeight: 26
    property bool danger: false
    property bool disabled: false
    signal clicked()

    width: btnHeight
    height: btnHeight
    radius: rectRadius
    antialiasing: true
    opacity: b.disabled ? 0.4 : 1

    border.width: 1
    border.color: ma.containsMouse ? Theme.borderBg1 : Theme.borderBg3
    Behavior on border.color { ColorAnimation { duration: Theme.durFast } }

    scale: ma.pressed && !b.disabled ? 0.9 : 1
    Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }

    color: {
        if (b.danger) {
            if (ma.pressed) return Theme.dangerBg2
            if (ma.containsMouse) return Theme.dangerBg
            return Theme.bg2
        }
        if (ma.pressed) return Theme.bg9
        if (ma.containsMouse) return Theme.bg8
        return Theme.bg6
    }
    Behavior on color { ColorAnimation { duration: Theme.durFast } }

    Text {
        anchors.centerIn: parent
        text: b.label
        font.family: Theme.fontFamily
        font.pixelSize: b.fontSize
        font.bold: b.textBold
        color: b.disabled ? Theme.fg5
            : b.danger ? (ma.containsMouse ? Theme.deleting : Theme.fg3)
            : (ma.containsMouse ? Theme.fg1 : Theme.fg)
        Behavior on color { ColorAnimation { duration: Theme.durFast } }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        enabled: !b.disabled
        cursorShape: Qt.PointingHandCursor
        onClicked: b.clicked()
    }
}