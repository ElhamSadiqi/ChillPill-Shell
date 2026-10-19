import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "components"
import "pages"

// ChillPill Settings — standalone editor for chillpill-shell's config.jsonc
//
// The pieces this window is assembled from live next to it: config read/write
// is ConfigStore.qml, colours and fonts are Theme.qml, the reusable setting
// rows are under components/, and each sidebar section is a Page under pages/.
// The section order must match the `pages` list on the window below.

ShellRoot {
    id: root

    // ───────────────────────────── window ─────────────────────────────

    FloatingWindow {
        id: win
        title: "ChillPill Settings"
        color: Theme.bgD
        implicitWidth: 940
        implicitHeight: 660
        minimumSize: Qt.size(720, 480)
        visible: true

        property int current: 0
        // query from the sidebar; each page filters itself and counts the hits
        property string search: ""

        function matches(index) {
            var p = stack.children[index]
            return p && p.matchCount !== undefined ? p.matchCount : 0
        }
        // jump to a page that has hits; 0ms lets every page's filter settle
        onSearchChanged: jumpTimer.restart()
        Timer {
            id: jumpTimer
            interval: 0
            onTriggered: {
                if (win.search.trim() === "" || win.matches(win.current) > 0) return
                for (var i = 0; i < win.pages.length; i++)
                    if (win.matches(i) > 0) { win.current = i; return }
            }
        }
        // "/" summons the box; inert while focused so "/" can still be typed
        Shortcut {
            sequence: "/"
            enabled: !si.activeFocus
            onActivated: { si.forceActiveFocus(); si.selectAll() }
        }
        // fade the content in when switching sections; the sidebar highlight
        // already eases via its own color animation
        onCurrentChanged: pageFade.restart()
        NumberAnimation {
            id: pageFade
            target: stack
            property: "opacity"
            from: 0
            to: 1
            duration: 170
            easing.type: Easing.OutCubic
        }
        // icon codepoints verified present in the configured nerd font
        readonly property var pages: [
            { name: "Appearance",     icon: String.fromCodePoint(0xf03d8) }, // md-palette
            { name: "Pill",           icon: String.fromCodePoint(0xf0402) }, // md-pill
            { name: "Notifications",  icon: String.fromCodePoint(0xf0f3)  }, // fa-bell
            { name: "Media & OSD",    icon: String.fromCodePoint(0xf0387) }, // md-music_note
            { name: "Weather & Data", icon: String.fromCodePoint(0xf015f) }, // md-cloud
            { name: "System",         icon: String.fromCodePoint(0xf0493) }, // md-cog
            { name: "Dependencies",   icon: String.fromCodePoint(0xf21e)  }, // fa-heartbeat
            { name: "Keybinds",        icon: String.fromCodePoint(0xf11c)  }, // fa-keyboard
            { name: "Wallpaper",      icon: String.fromCodePoint(0xf0e09) }  // md-wallpaper
        ]

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // sidebar
            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: 200
                color: Theme.bg
                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: 20
                    anchors.margins: 12
                    spacing: 4
                    // wordmark, aligned with the nav rows below
                    ColumnLayout {
                        Layout.leftMargin: 12
                        Layout.bottomMargin: 10
                        spacing: 1
                        Text {
                            text: "ChillPill"
                            color: Theme.fgL
                            font.family: Theme.fontFamily
                            font.pixelSize: 19
                            font.bold: true
                        }
                        Text {
                            text: "SETTINGS"
                            color: Theme.accent
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.letterSpacing: 3
                        }
                    }
                    // one query filters every page; badges show the hits per page
                    Rectangle {
                        id: searchBox
                        Layout.fillWidth: true
                        height: 32
                        radius: 7
                        antialiasing: true
                        color: si.activeFocus ? Theme.inputBgFocus : (sbMa.containsMouse ? Theme.inputBgHover : Theme.inputBg)
                        Behavior on color { ColorAnimation { duration: Theme.durFast } }
                        border.width: 1
                        border.color: si.activeFocus ? Theme.accent : (sbMa.containsMouse ? Theme.borderBg1 : Theme.borderBg3)
                        Behavior on border.color { ColorAnimation { duration: Theme.durFast } }
                        MouseArea {
                            id: sbMa
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.NoButton
                            cursorShape: Qt.IBeamCursor
                        }
                        // idle hint
                        Text {
                            id: hint
                            anchors.left: srow.left
                            anchors.leftMargin: sic.width + srow.spacing
                            anchors.verticalCenter: srow.verticalCenter
                            visible: si.text === "" && !si.activeFocus
                            text: "/ to search"
                            color: Theme.fg4
                            font.family: Theme.nerdFontFamily
                            font.pixelSize: 12
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { si.forceActiveFocus(); si.selectAll() }
                            }
                        }
                        RowLayout {
                            id: srow
                            anchors.fill: parent
                            anchors.leftMargin: 9
                            anchors.rightMargin: 8
                            spacing: 7
                            Text {
                                id: sic
                                text: String.fromCodePoint(0xf002) // fa-search
                                color: si.activeFocus || sbMa.containsMouse ? Theme.accent : Theme.fg5
                                font.family: Theme.nerdFontFamily
                                font.pixelSize: 11
                                Behavior on color { ColorAnimation { duration: Theme.durFast } }
                            }
                            TextInput {
                                id: si
                                Layout.fillWidth: true
                                verticalAlignment: TextInput.AlignVCenter
                                color: Theme.fg
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeBase - 1
                                selectionColor: Theme.accent
                                selectedTextColor: Theme.bgD
                                selectByMouse: true
                                clip: true
                                // no text: binding; typing writes win.search directly
                                onTextChanged: win.search = text
                                // clear and unfocus
                                Keys.onEscapePressed: { si.text = ""; si.focus = false; event.accepted = true }
                            }
                            Text {
                                visible: si.text !== ""
                                text: "\u2715"
                                color: clrMa.containsMouse ? Theme.fg1 : Theme.fg5
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                Behavior on color { ColorAnimation { duration: Theme.durFast } }
                                MouseArea {
                                    id: clrMa
                                    anchors.fill: parent
                                    anchors.margins: -5
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: { si.text = ""; si.focus = false }
                                }
                            }
                        }
                    }
                    // section list: the only part allowed to shrink. it scrolls
                    // rather than pushing the footer below it out of the window
                    Flickable {
                        id: navFlick
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 0
                        clip: true
                        contentWidth: width
                        contentHeight: navCol.implicitHeight
                        boundsBehavior: Flickable.StopAtBounds
                        flickableDirection: Flickable.VerticalFlick

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                            width: 4
                            contentItem: Rectangle {
                                implicitWidth: 4
                                radius: 2
                                color: Theme.fg6
                                opacity: navFlick.moving || navFlick.flicking ? 0.9 : 0.35
                                Behavior on opacity { NumberAnimation { duration: Theme.durMed } }
                            }
                        }

                        Column {
                            id: navCol
                            width: navFlick.width
                            spacing: 4
                            Repeater {
                                model: win.pages
                                Rectangle {
                                    id: nav
                                    required property int index
                                    required property var modelData
                                    width: navCol.width
                                    height: 38; radius: 8
                                    antialiasing: true
                                    color: win.current === nav.index ? Theme.bg5 : (nma.containsMouse ? Theme.bg2 : Theme.transparent)
                                    Behavior on color { ColorAnimation { duration: 90 } }
                                    // dim pages the query misses
                                    opacity: win.search !== "" && win.matches(nav.index) === 0 ? 0.35 : 1
                                    Behavior on opacity { NumberAnimation { duration: 90 } }
                                    Rectangle {
                                        // active-page indicator
                                        x: 2
                                        width: 3; height: 20; radius: 1.5
                                        anchors.verticalCenter: parent.verticalCenter
                                        visible: win.current === nav.index
                                        color: Theme.accent
                                    }
                                    Row {
                                        anchors.verticalCenter: parent.verticalCenter
                                        x: 12
                                        spacing: 10
                                        Text {
                                            text: nav.modelData.icon
                                            color: win.current === nav.index ? Theme.fg : Theme.fg3
                                            font.family: Theme.nerdFontFamily
                                            font.pixelSize: 14
                                        }
                                        Text {
                                            text: nav.modelData.name
                                            color: win.current === nav.index ? Theme.fg : Theme.fg3
                                            font.family: Theme.fontFamily
                                        }
                                    }
                                    // hits on this page
                                    Text {
                                        anchors.right: parent.right
                                        anchors.rightMargin: 10
                                        anchors.verticalCenter: parent.verticalCenter
                                        visible: win.search !== "" && win.matches(nav.index) > 0
                                        text: win.matches(nav.index)
                                        color: Theme.accent
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 10
                                    }
                                    MouseArea {
                                        id: nma
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: win.current = nav.index
                                    }
                                }
                            }
                        }
                    }
                    // footer: fixed height, pinned under the list, never overlapped by it
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        Layout.minimumHeight: 1
                        color: Theme.bg3
                        Layout.topMargin: 8
                        Layout.bottomMargin: 8
                    }
                    Text {
                        text: ConfigStore.configPath
                        color: Theme.fg5
                        font.family: Theme.nerdFontFamily
                        font.pixelSize: 10
                        wrapMode: Text.WrapAnywhere
                        Layout.fillWidth: true
                        Layout.minimumHeight: implicitHeight
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        Layout.minimumHeight: 26
                        Layout.bottomMargin: 6
                        spacing: 8
                        Text {
                            text: ConfigStore.status
                            color: ConfigStore.statusError ? Theme.deleting : Theme.fg3
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        MiniBtn { label: ""; onClicked: ConfigStore.reload(); fontSize: 15; rectRadius: 8 }
                    }
                }
            }

            // content
            StackLayout {
                id: stack
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: win.current
                enabled: ConfigStore.loaded

                AppearancePage { filter: win.search }
                PillPage { filter: win.search }
                NotificationsPage { filter: win.search }
                MediaOsdPage { filter: win.search }
                WeatherDataPage { filter: win.search }
                SystemPage { filter: win.search }
                HealthPage { filter: win.search }
                KeybindsPage { filter: win.search }
                WallpaperPage { filter: win.search }
            }
        }
    }
}
