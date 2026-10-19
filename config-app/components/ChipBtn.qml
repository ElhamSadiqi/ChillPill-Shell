import QtQuick
import "../"

Rectangle {
    id: cb
    property string label: ""
    property bool dim: false
    property bool danger: false
    signal clicked()
    readonly property bool hovered: cma.containsMouse

    width: 20
    height: 22
    radius: 5
    antialiasing: true
    opacity: cb.dim ? 0.45 : 1

    color: cma.containsMouse ? (cb.danger ? Theme.dangerBg2 : Theme.bg7) : Theme.transparent
    Behavior on color { ColorAnimation { duration: Theme.durFast } }
    Behavior on opacity { NumberAnimation { duration: Theme.durFast } }

    Text {
        anchors.centerIn: parent
        text: cb.label
        color: cb.dim ? Theme.fg8
            : (cb.danger ? (cb.hovered ? Theme.deleting : Theme.fg5)
            : (cb.hovered ? Theme.fg1 : Theme.fg4))
        font.family: Theme.fontFamily
        font.pixelSize: 11
        Behavior on color { ColorAnimation { duration: Theme.durFast } }
    }

    MouseArea {
        id: cma
        anchors.fill: parent
        enabled: !cb.dim
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: cb.clicked()
    }
}