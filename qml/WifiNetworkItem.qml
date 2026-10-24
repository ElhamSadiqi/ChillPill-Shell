import QtQuick
import PillBackend

// One wifi list row. Tap = connect / disconnect / ask for password.
// Style follows Lockscreen.qml: panel fill, hairline stroke, one accent touch for "connected"

Rectangle {
  id: row

  property string ssid: ""
  property string displayName: ""
  property int signalStrength: -1
  property bool secure: false
  property bool savedConnection: false
  property bool connected: false
  property bool selected: false

  property color accent: Theme.netConnected

  signal activated()

  readonly property int bars: signalStrength < 0 ? 0
      : signalStrength >= 75 ? 4
      : signalStrength >= 50 ? 3
      : signalStrength >= 25 ? 2 : 1

  height: 44
  radius: 14
  color: mouse.containsMouse ? Theme.bg3 : selected ? Theme.bg2 : Qt.lighter(Theme.bg, 1.10)
  scale: mouse.pressed ? 0.985 : 1

  Behavior on color { ColorAnimation { duration: 100 } }
  Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

  Row {
    id: barsRow
    anchors.left: parent.left
    anchors.leftMargin: 16
    anchors.verticalCenter: parent.verticalCenter
    height: 12
    spacing: 2

    Repeater {
      model: 4
      Rectangle {
        required property int index
        width: 3
        height: 4 + index * 3
        y: barsRow.height - height
        radius: 1.5
        color: index < row.bars
            ? (row.connected ? row.accent : Theme.fg3)
            : Theme.fg7
        Behavior on color { ColorAnimation { duration: 150 } }
      }
    }
  }

  Column {
    anchors.left: barsRow.right
    anchors.leftMargin: 14
    anchors.right: tail.left
    anchors.rightMargin: 8
    anchors.verticalCenter: parent.verticalCenter
    spacing: 2

    Text {
      width: parent.width
      text: row.displayName || row.ssid
      color: row.connected ? Theme.fg : Theme.fg1
      elide: Text.ElideRight
      font { family: Theme.fontFamily; pixelSize: 12 }
    }

    Text {
      width: parent.width
      text: row.connected ? "connected"
          : row.savedConnection ? "saved"
          : row.secure ? "secured" : "open"
      color: row.connected ? row.accent : Theme.fg4
      elide: Text.ElideRight
      font { family: Theme.fontFamily; pixelSize: 10 }
    }
  }

  // check when connected, otherwise lock / open lock
  Text {
    id: tail
    anchors.right: parent.right
    anchors.rightMargin: 16
    anchors.verticalCenter: parent.verticalCenter
    text: row.connected ? "\uf00c" : (row.secure ? "\uf023" : "\uf09c")
    color: row.connected ? row.accent : Theme.fg5
    font { family: Theme.nerdFontFamily; pixelSize: 12 }
  }

  MouseArea {
    id: mouse
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    enabled: !WifiController.busy && WifiController.enabled
    onClicked: row.activated()
  }
}
