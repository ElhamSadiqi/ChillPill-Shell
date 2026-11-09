import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Item {
  id: root
  implicitWidth: 680
  implicitHeight: 175

  signal closeRequested()
  signal applyRequested(string name)

  property string searchQuery: ""
  property string currentName: ""
  property bool userMoved: false
  property bool applying: false

  // filter themeNames live by searchQuery
  readonly property var filteredNames: {
    const q = searchQuery.trim().toLowerCase()
    if (!q) return Theme.themeNames
    return Theme.themeNames.filter(n => n.toLowerCase().includes(q))
  }

  readonly property int count: filteredNames.length
  readonly property int current: {
    if (count === 0) return -1
    const i = filteredNames.indexOf(currentName)
    return i < 0 ? 0 : i
  }

  // keep currentName synced if search filters out the previously selected item
  onFilteredNamesChanged: {
    if (count > 0 && filteredNames.indexOf(currentName) < 0) {
      currentName = filteredNames[0]
    }
    syncPathIndex()
  }

  onCurrentChanged: syncPathIndex()

  function syncPathIndex() {
    if (count > 0 && current >= 0 && carousel.currentIndex !== current) {
      carousel.currentIndex = current
    }
  }

  // staged reveal animation
  property real reveal: 0
  Behavior on reveal { NumberAnimation { duration: 380; easing.type: Easing.OutCubic } }

  function step(d) {
    if (count <= 1 || applying) return
    userMoved = true
    if (d > 0) carousel.incrementCurrentIndex()
    else carousel.decrementCurrentIndex()
  }

  function jumpTo(i) {
    if (count === 0 || applying) return
    userMoved = true
    const idx = Math.max(0, Math.min(count - 1, i))
    carousel.currentIndex = idx
  }

  function applyName(name) {
    if (applying) return
    applying = true
    applyRequested(name)
    closeTimer.restart()
  }

  function applyAt(i) {
    if (i < 0 || i >= count) return
    applyName(filteredNames[i])
  }

  function resetTheme() {
    applyName("")
  }

  Timer { id: closeTimer; interval: 60; onTriggered: { root.closeRequested(); root.applying = false } }

  Component.onCompleted: {
    Theme.scanThemes()
    currentName = Theme.activeTheme || (Theme.themeNames.length > 0 ? Theme.themeNames[0] : "")
    reveal = 1
    Qt.callLater(() => {
      searchInput.forceActiveFocus()
      syncPathIndex()
    })
  }

  Connections {
    target: Theme
    function onThemeNamesChanged() {
      if (!root.userMoved) {
        root.currentName = Theme.activeTheme || (Theme.themeNames.length > 0 ? Theme.themeNames[0] : "")
        Qt.callLater(() => root.syncPathIndex())
      }
    }
  }

  // global keyboard navigation (works even while typing in the search bar)
  Keys.onPressed: (e) => {
    const k = e.key
    e.accepted = true
    if (k === Qt.Key_Escape) {
      if (searchQuery.length > 0) {
        searchQuery = ""
      } else {
        closeRequested()
      }
    } else if (k === Qt.Key_Left || (k === Qt.Key_H && searchQuery.length === 0)) {
      step(-1)
    } else if (k === Qt.Key_Right || (k === Qt.Key_L && searchQuery.length === 0)) {
      step(1)
    } else if (k === Qt.Key_Home) {
      jumpTo(0)
    } else if (k === Qt.Key_End) {
      jumpTo(count - 1)
    } else if (k === Qt.Key_Return || k === Qt.Key_Enter) {
      applyAt(current)
    } else if (k === Qt.Key_R && (e.modifiers & Qt.ControlModifier)) {
      resetTheme()
    } else {
      e.accepted = false
    }
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.leftMargin: 18
    anchors.rightMargin: 18
    anchors.topMargin: 10
    anchors.bottomMargin: 10
    spacing: 8
    opacity: root.reveal

    // ── Top Bar: Search Input + Counter + Reset ──────────────────────────────
    RowLayout {
      Layout.fillWidth: true
      spacing: 10

      Text {
        text: "\uf002" // nf-fa-search
        color: searchInput.activeFocus ? Theme.accent : Theme.fg4
        font { family: Theme.nerdFontFamily; pixelSize: 13 }
        Behavior on color { ColorAnimation { duration: 150 } }
      }

      Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 24

        TextInput {
          id: searchInput
          anchors.fill: parent
          verticalAlignment: TextInput.AlignVCenter
          color: Theme.fg
          selectionColor: Theme.accent
          selectedTextColor: Theme.bg
          clip: true
          font { family: Theme.fontFamily; pixelSize: 13 }
          text: root.searchQuery
          onTextChanged: root.searchQuery = text

          Keys.forwardTo: [root]
        }

        Text {
          anchors.fill: parent
          verticalAlignment: Text.AlignVCenter
          visible: searchInput.text.length === 0
          text: "Search themes..."
          color: Theme.fg5
          font { family: Theme.fontFamily; pixelSize: 13 }
        }
      }

      // Clear search button (visible when typing)
      Text {
        visible: root.searchQuery.length > 0
        text: "\uf00d" // nf-fa-times
        color: clearMa.containsMouse ? Theme.fg : Theme.fg4
        font { family: Theme.nerdFontFamily; pixelSize: 12 }
        MouseArea {
          id: clearMa
          anchors.fill: parent
          anchors.margins: -4
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            root.searchQuery = ""
            searchInput.forceActiveFocus()
          }
        }
      }

      // Reset to default theme button
      Rectangle {
        implicitWidth: 24
        implicitHeight: 24
        radius: 12
        color: resetMa.containsMouse ? Theme.bg3 : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }

        Text {
          anchors.centerIn: parent
          text: "\uf0e2" // nf-fa-rotate_left
          color: resetMa.containsMouse ? Theme.fg : Theme.fg4
          font { family: Theme.nerdFontFamily; pixelSize: 11 }
        }

        MouseArea {
          id: resetMa
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.resetTheme()
        }
      }

      // Index counter (e.g., 1/10)
      Text {
        text: root.count > 0 ? ((root.current + 1) + "/" + root.count) : "0/0"
        color: Theme.fg4
        font { family: Theme.fontFamily; pixelSize: 12; weight: 500 }
      }
    }

    // ── Infinite Wrap-Around Carousel (PathView) ─────────────────────────────
    Item {
      Layout.fillWidth: true
      Layout.fillHeight: true
      clip: true

      PathView {
        id: carousel
        anchors.fill: parent
        visible: root.count > 0
        model: root.filteredNames

        readonly property real cardW: 300
        readonly property real cardH: height - 50
        readonly property real cardSpacing: 14
        readonly property real step: cardW + cardSpacing
        readonly property int visibleSlots: Math.min(root.count, 5)

        // Show up to 5 slots on the track so left & right peeks stay filled seamlessly
        pathItemCount: visibleSlots
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        highlightRangeMode: PathView.StrictlyEnforceRange
        highlightMoveDuration: 240
        snapMode: PathView.SnapToItem
        dragMargin: height / 2

        // Keep root.currentName synced when user drags or steps the PathView
        onCurrentIndexChanged: {
          if (currentIndex >= 0 && currentIndex < root.count) {
            const name = root.filteredNames[currentIndex]
            if (root.currentName !== name) {
              root.currentName = name
            }
          }
        }

        // Horizontal track centered at width / 2
        path: Path {
          startX: (carousel.width / 2) - (carousel.visibleSlots * carousel.step) / 2
          startY: carousel.height / 2
          PathLine {
            x: (carousel.width / 2) + (carousel.visibleSlots * carousel.step) / 2
            y: carousel.height / 2
          }
        }

        // Mouse wheel scrolls smoothly through the endless loop
        WheelHandler {
          onWheel: (event) => {
            if (event.angleDelta.y > 0 || event.angleDelta.x > 0) root.step(-1)
            else if (event.angleDelta.y < 0 || event.angleDelta.x < 0) root.step(1)
          }
        }

        delegate: Item {
          id: cardSlot
          required property int index
          required property string modelData

          readonly property bool selected: PathView.isCurrentItem
          readonly property bool isActive: Theme.activeTheme === modelData

          width: carousel.cardW
          height: carousel.height
          z: selected ? 10 : 1

          property var d: ({})
          readonly property color pvBg: d.bg || Theme.bg2
          readonly property color pvFg: d.fg || Theme.fg
          readonly property color pvAccent: d.accent || Theme.accent

          readonly property var dotColors: {
            if (Array.isArray(d.burstPalette) && d.burstPalette.length >= 6) {
              return d.burstPalette.slice(0, 6)
            }
            return [
              d.danger || d.mutedFg || "#ff6b6b",
              d.ok || d.vpnFg || "#63e6be",
              d.warnMed || d.warning || "#ffd43b",
              d.netFg || d.ccActiveFg || "#4490ee",
              d.powerSleep || "#b197fc",
              d.accent || "#63e6be"
            ]
          }

          FileView {
            id: presetView
            path: Theme.themeDir + "/" + cardSlot.modelData + ".json"
            preload: true
            onLoaded: cardSlot.refresh()
            onFileChanged: cardSlot.refresh()
          }

          function refresh() {
            let o = {}
            try { o = JSON.parse(presetView.text()) } catch (e) { o = {} }
            cardSlot.d = o
          }
          Component.onCompleted: refresh()

          Rectangle {
            id: card
            anchors.centerIn: parent
            width: carousel.cardW
            height: carousel.cardH
            radius: 14
            color: cardSlot.pvBg
            scale: cardMa.pressed ? 0.96 : (cardSlot.selected ? 1.03 : 0.96)
            opacity: cardSlot.selected ? 1.0 : 0.72

            border.width: cardSlot.selected ? 2 : 1
            border.color: cardSlot.selected
              ? cardSlot.pvAccent
              : Qt.rgba(cardSlot.pvFg.r, cardSlot.pvFg.g, cardSlot.pvFg.b, 0.14)

            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 180 } }
            Behavior on border.color { ColorAnimation { duration: 180 } }

            // Active theme dot badge in top-right
            Rectangle {
              visible: cardSlot.isActive
              width: 7
              height: 7
              radius: 3.5
              anchors.top: parent.top
              anchors.right: parent.right
              anchors.margins: 10
              color: cardSlot.pvAccent
            }

            Column {
              anchors.centerIn: parent
              spacing: 10
              width: parent.width - 20

              Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 6

                Repeater {
                  model: cardSlot.dotColors
                  delegate: Rectangle {
                    required property var modelData
                    width: 11
                    height: 11
                    radius: 5.5
                    color: modelData
                  }
                }
              }

              Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: cardSlot.d.name || cardSlot.modelData
                color: cardSlot.pvFg
                elide: Text.ElideRight
                font {
                  family: Theme.fontFamily
                  pixelSize: 12
                  weight: cardSlot.selected ? 600 : 400
                }
              }
            }

            MouseArea {
              id: cardMa
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                if (cardSlot.selected) {
                  root.applyName(cardSlot.modelData)
                } else {
                  root.userMoved = true
                  carousel.currentIndex = cardSlot.index
                }
              }
              onDoubleClicked: root.applyName(cardSlot.modelData)
            }
          }
        }
      }

      // Left & right edge fade masks (always active when looping > 2 themes)
      Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 28
        visible: root.count > 2
        gradient: Gradient {
          orientation: Gradient.Horizontal
          GradientStop { position: 0.0; color: Theme.bg }
          GradientStop { position: 1.0; color: "transparent" }
        }
      }

      Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 28
        visible: root.count > 2
        gradient: Gradient {
          orientation: Gradient.Horizontal
          GradientStop { position: 0.0; color: "transparent" }
          GradientStop { position: 1.0; color: Theme.bg }
        }
      }

      // Empty state
      Text {
        visible: root.count === 0
        anchors.centerIn: parent
        text: root.searchQuery.length > 0
          ? ("No themes matching \"" + root.searchQuery + "\"")
          : "No presets found in ~/.cache/chillpill-shell/themes/"
        color: Theme.fg4
        font { family: Theme.fontFamily; pixelSize: 12 }
      }
    }

    // ── Bottom Bar: Key Hints ────────────────────────────────────────────────
    RowLayout {
      Layout.fillWidth: true

      Text {
        text: "\u2190/\u2192 navigate \u2022 Ctrl+R reset \u2022 ESC close"
        color: Theme.fg5
        font { family: Theme.fontFamily; pixelSize: 10 }
      }

      Item { Layout.fillWidth: true }

      Text {
        text: "Enter to apply"
        color: Theme.fg4
        font { family: Theme.fontFamily; pixelSize: 10; weight: 500 }
      }
    }
  }
}
