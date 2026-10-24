import QtQuick
import PillBackend

// Password card that grows under a network row (see WifiPanel.qml)
// Same pill field + round arrow button as the lockscreen password box.
Item {
  id: prompt

  property bool shown: false
  property string ssid: ""
  property color accent: Theme.netConnected   // kept for the host, field uses the neutral hi colour

  signal opened()                    // grow animation finished
  signal submitted(string password)
  signal cancelled()
  signal edited(string text)         // lets the panel keep a draft

  property bool reveal: false
  readonly property real fullHeight: 44

  readonly property color fieldFill: Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.10)
  readonly property color fieldEdge: Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.06)

  function focusField() { Qt.callLater(() => field.forceActiveFocus()) }
  function setText(t) { field.text = t }
  function submit() { if (field.text.length > 0) prompt.submitted(field.text) }

  height: shown ? fullHeight : 0
  visible: height > 0
  clip: true

  Behavior on height {
    NumberAnimation {
      duration: 200
      easing.type: Easing.OutExpo
      onRunningChanged: if (!running && prompt.shown) prompt.opened()
    }
  }

  onShownChanged: if (!shown) { field.text = ""; reveal = false }

  Rectangle {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    height: prompt.fullHeight
    radius: height / 2
    color: prompt.fieldFill
    border.width: 1
    border.color: field.activeFocus ? Theme.fg3 : prompt.fieldEdge
    Behavior on border.color { ColorAnimation { duration: 160 } }

    Text {
      id: keyIcon
      anchors.left: parent.left
      anchors.leftMargin: 18
      anchors.verticalCenter: parent.verticalCenter
      text: "\uf084" // nf-fa-key
      color: field.activeFocus ? Theme.fg3 : Theme.fg5
      renderType: Text.NativeRendering
      font { family: Theme.nerdFontFamily; pixelSize: 12 }
      Behavior on color { ColorAnimation { duration: 120 } }
    }

    Text {
      anchors.left: keyIcon.right
      anchors.leftMargin: 10
      anchors.verticalCenter: parent.verticalCenter
      visible: field.text.length === 0
      text: "password"
      color: Theme.fg4
      renderType: Text.NativeRendering
      font { family: Theme.fontFamily; pixelSize: 12 }
    }

    TextInput {
      id: field
      anchors.left: keyIcon.right
      anchors.leftMargin: 10
      anchors.right: eye.left
      anchors.rightMargin: 8
      anchors.verticalCenter: parent.verticalCenter
      clip: true
      color: Theme.fg
      selectByMouse: true
      echoMode: prompt.reveal ? TextInput.Normal : TextInput.Password
      passwordCharacter: "•"
      renderType: Text.NativeRendering
      font { family: Theme.fontFamily; pixelSize: 12 }
      onTextEdited: prompt.edited(text)
      Keys.onReturnPressed: prompt.submit()
      Keys.onEnterPressed: prompt.submit()
      Keys.onEscapePressed: prompt.cancelled()
    }

    Text {
      id: eye
      anchors.right: joinBtn.left
      anchors.rightMargin: 12
      anchors.verticalCenter: parent.verticalCenter
      text: prompt.reveal ? "\uf070" : "\uf06e" // eye-slash / eye
      color: eyeMouse.containsMouse ? Theme.fg : Theme.fg5
      renderType: Text.NativeRendering
      font { family: Theme.nerdFontFamily; pixelSize: 12 }
      Behavior on color { ColorAnimation { duration: 120 } }

      MouseArea {
        id: eyeMouse
        anchors.fill: parent
        anchors.margins: -7
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: prompt.reveal = !prompt.reveal
      }
    }

    // round arrow, same as the lockscreen go button
    Rectangle {
      id: joinBtn
      anchors.right: parent.right
      anchors.rightMargin: 7
      anchors.verticalCenter: parent.verticalCenter
      width: 30; height: 30; radius: 15
      color: Theme.fg3
      opacity: field.text.length > 0 ? 1 : 0
      scale: joinMouse.pressed ? 0.9 : (field.text.length > 0 ? 1 : 0.6)
      Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
      Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

      Text {
        anchors.centerIn: parent
        text: "\uf061" // nf-fa-arrow_right
        color: Theme.bg
        renderType: Text.NativeRendering
        font { family: Theme.nerdFontFamily; pixelSize: 14 }
      }

      MouseArea {
        id: joinMouse
        anchors.fill: parent
        enabled: field.text.length > 0
        cursorShape: Qt.PointingHandCursor
        onClicked: prompt.submit()
      }
    }
  }
}
