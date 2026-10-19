import QtQuick
import "../"

Rectangle {
    id: fb
    property string label: ""
    property bool primary: false
    property bool danger: false
    property bool disabled: false
    signal clicked()

    implicitWidth: lbl.implicitWidth + 30
    height: 30
    radius: 7
    antialiasing: true
    opacity: fb.disabled ? 0.45 : 1

    border.width: (fb.primary || fb.danger) ? 0 : 1
    border.color: fbMa.containsMouse ? Theme.borderBg1 : Theme.borderBg3

    scale: fbMa.pressed && !fb.disabled ? 0.96 : 1
    Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
    Behavior on border.color { ColorAnimation { duration: Theme.durFast } }

    color: {
        if (fb.primary) return fbMa.pressed ? Theme.accentLo : (fbMa.containsMouse ? Theme.accentHi : Theme.accent)
        if (fb.danger) {
            if (fbMa.pressed) return Theme.dangerBg2
            if (fbMa.containsMouse) return Theme.dangerBg
            return Theme.transparent
        }
        if (fbMa.pressed) return Theme.bg5
        if (fbMa.containsMouse) return Theme.bg4
        return Theme.bg2
    }
    Behavior on color { ColorAnimation { duration: Theme.durFast } }

    Text {
        id: lbl
        anchors.centerIn: parent
        text: fb.label
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeBase - 1
        color: {
            if (fb.disabled) return Theme.fg5
            if (fb.primary) return Theme.bgD
            if (fb.danger) return fbMa.containsMouse ? Theme.deleting : Theme.fg4
            return fbMa.containsMouse ? Theme.fg1 : Theme.fg3
        }
        Behavior on color { ColorAnimation { duration: Theme.durFast } }
    }

    MouseArea {
        id: fbMa
        anchors.fill: parent
        hoverEnabled: true
        enabled: !fb.disabled
        cursorShape: Qt.PointingHandCursor
        onClicked: fb.clicked()
    }
}