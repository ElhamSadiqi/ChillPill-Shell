import Quickshell
import Quickshell.Io
import QtQuick

// contents of the control center, instantiated by shell.qml
Item {
  id: root

  // must read the raw list content height, not notificationStack.height:
  // height is notifBox.height (contentHeight + 7) and is animated, which both
  // adds a stray 7px gap and restarts the pill's height animation every frame
  readonly property real notifBump: notificationModule.notifications.length > 0
    ? Math.min(notificationStack.listContentHeight + 40, 130) : 0

  Process { id: brightnessSetProc; running: false }

  // media player
  MediaPlayer {
    active: box.controlCenter
    visualizerValues: shellRoot.visualizerValues
    cavaAvailable: shellRoot.cavaAvailable
  }

  // control center buttons
  CcButtons {
    buttonWidth: box.ccButtonWidth
    buttonHeight: box.ccButtonHeight
    buttonRadius: box.ccButtonRadius
    buttonBgOff: box.ccButtonBgOff
    buttonFgOff: box.ccButtonFgOff
    controlCenterOpen: box.controlCenter
    mediaAutoOpened: shellRoot.mediaPopupShown
    hasPlayer: mprisModule.hasPlayer
    playerHeight: box.ccButtonHeight
    notificationPopup: notificationModule.active
    onWifiPanelToggleRequested: box.wifiPanelOpen = !box.wifiPanelOpen
  }

  CcSliders {
    id: sliderColumn
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.topMargin: mprisModule.hasPlayer ? box.ccButtonHeight + 137 : 50
    anchors.leftMargin: 15
    anchors.rightMargin: 2

    sliderHeight: box.sliderHeight
    sliderRadius: box.sliderRadius
    sliderColor: box.sliderColor
    sliderHitSlop: box.sliderHitSlop
    volIcon: box.volumeModule ? box.volumeModule.icon : ""
    volMuted: box.volumeModule ? box.volumeModule.muted : false
    volPercent: box.volumeModule ? box.volumeModule.intendedVol : 0
    volMax: Config.maxVolume
    brightnessIcon: brightnessModule.icon
    brightnessPercent: brightnessModule.percent

    onVolumeChangeRequested: (fraction) => {
      if (box.volumeModule)
        box.volumeModule.setVolume(Math.round(Math.max(0, Math.min(1, fraction)) * Config.maxVolume))
    }
    onBrightnessChangeRequested: (fraction) => {
      let pct = Math.round(Math.max(0, Math.min(1, fraction)) * 100)
      brightnessSetProc.command = ["brightnessctl", "set", pct + "%"]
      brightnessSetProc.running = false
      brightnessSetProc.running = true
    }
  }

  NotificationStack {
    id: notificationStack
    anchors.top: sliderColumn.bottom
    anchors.topMargin: 32
    anchors.left: parent.left
    anchors.right: parent.right
    notifMaxHeight: 98
    dpi: box.dpi
    controlCenterOpen: box.controlCenter
  }
}