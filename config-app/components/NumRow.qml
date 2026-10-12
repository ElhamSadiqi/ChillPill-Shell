import QtQuick
import "../"

SRow {
    id: n
    property real value: 0
    property real from: 0
    property real to: 1e9
    property real step: 1
    property real divisor: 1
    property string suffix: ""
    property int decimals: 0
    property alias input: inp
    signal edited(real v)

    function clamp(v) { return Math.max(n.from, Math.min(n.to, v)) }
    function commit(shown) {
        var s = Number(shown)
        if (isNaN(s)) return
        n.edited(n.clamp(Math.round(s * n.divisor)))
    }

    readonly property int rowH: 30

    Row {
        spacing: 6
        height: n.rowH

        MiniBtn {
            label: "\u2212"
            btnHeight: n.rowH
            onClicked: n.edited(n.clamp(n.value - n.step))
        }

        Rectangle {
            width: 84
            height: n.rowH
            radius: 7
            antialiasing: true

            color: inp.activeFocus ? Theme.inputBgFocus : (nfma.containsMouse ? Theme.inputBgHover : Theme.inputBg)
            Behavior on color { ColorAnimation { duration: Theme.durFast } }

            border.width: 1
            border.color: inp.activeFocus ? Theme.accent
                : (nfma.containsMouse ? Theme.borderBg1 : Theme.borderBg3)
            Behavior on border.color { ColorAnimation { duration: Theme.durFast } }

            TextInput {
                id: inp
                anchors.fill: parent
                anchors.margins: 7
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeBase - 1
                selectionColor: Theme.accent
                selectedTextColor: Theme.bgD
                selectByMouse: true
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                text: (n.value / n.divisor).toFixed(n.decimals)
                onEditingFinished: n.commit(text)
            }

            MouseArea {
                id: nfma
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                cursorShape: Qt.IBeamCursor
            }
        }

        MiniBtn {
            label: "+"
            btnHeight: n.rowH
            onClicked: n.edited(n.clamp(n.value + n.step))
        }

        Text {
            visible: n.suffix !== ""
            text: n.suffix
            color: Theme.fg4
            font.family: Theme.fontFamily
            width: 28
            height: n.rowH
            verticalAlignment: Text.AlignVCenter
        }
    }
}