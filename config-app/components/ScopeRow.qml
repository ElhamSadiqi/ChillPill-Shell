import QtQuick
import "../"

// three-way scope switch for a media feature, plus an explicit "none":
//   [control center] | [lockscreen] | [both] | [none]
// self-contained (builds its own buttons) because SRow's slot is not a layout
SRow {
    id: row

    property string optionKey: ""
    property string legacyKey: ""
    property string fallback: "both"

    // padding around the button strip, inside the box
    readonly property int padH: 2
    readonly property int padV: 2

    property var choices: ["Control Center", "Lockscreen", "Both", "None"]
    property var scopeValues: ["controlCenter", "lockscreen", "both", "none"]

    // empty key -> derive from the legacy boolean, mirroring Config.qml
    function currentScope() {
        const raw = ConfigStore.get(optionKey, "");
        if (raw !== undefined && raw !== null && raw !== "")
            return raw;
        if (legacyKey !== "")
            return ConfigStore.get(legacyKey, false) ? "both" : "none";
        return fallback;
    }

    readonly property string scope: currentScope()
    readonly property int selected: {
        const i = scopeValues.indexOf(scope);
        return i >= 0 ? i : scopeValues.indexOf(fallback);
    }

    // padded box that hugs the buttons
    Rectangle {
        id: pad
        width: strip.width + row.padH * 2
        height: strip.height + row.padV * 2
        radius: 10
        antialiasing: true
        color: Theme.bg2
        border.width: 1
        border.color: Theme.borderBg3

        // plain Item (not a Row) so the marker never affects the measured width
        Item {
            id: strip
            x: row.padH
            y: row.padV
            // symmetric inset: the row sits `x` inside the strip on both sides,
            // otherwise it overflows on the right and the padding looks lopsided
            width: btnRow.x * 2 + btnRow.width
            height: btnRow.y * 2 + btnRow.height

            // sliding selection pill behind the buttons
            Rectangle {
                id: marker
                y: btnRow.y
                height: btnRow.height
                radius: 6
                antialiasing: true
                color: Theme.accent
                readonly property var target: btnRow.children[row.selected] || btnRow.children[0]
                x: btnRow.x + (target ? target.x : 0)
                width: target ? target.width : btnRow.width

                Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutQuint } }
                Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutQuint } }
            }

            Row {
                id: btnRow
                x: 3
                y: 3
                spacing: 3

                Repeater {
                    model: row.choices

                    Rectangle {
                        id: btn
                        required property string modelData
                        required property int index

                        readonly property bool sel: index === row.selected

                        width: blbl.implicitWidth + 22
                        height: 30
                        radius: 6
                        antialiasing: true

                        // weight stays constant so selecting never resizes a button
                        color: btn.sel ? Theme.transparent : (bma.containsMouse ? Theme.bg4 : Theme.transparent)
                        Behavior on color { ColorAnimation { duration: 140 } }

                        scale: bma.pressed ? 0.95 : 1
                        Behavior on scale { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }

                        Text {
                            id: blbl
                            anchors.centerIn: parent
                            text: btn.modelData
                            color: btn.sel ? Theme.bgD : (bma.containsMouse ? Theme.fg2 : Theme.fg4)
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.Medium
                            Behavior on color { ColorAnimation { duration: 140 } }
                        }

                        MouseArea {
                            id: bma
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ConfigStore.set(row.optionKey, row.scopeValues[btn.index])
                        }
                    }
                }
            }
        }
    }
}
