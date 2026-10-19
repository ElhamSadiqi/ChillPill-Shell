pragma Singleton
import Quickshell
import QtQuick
import "./Config.qml"

Singleton {
    // more darker (descending)
    property string bg: "#111111"
    property string bg1: "#141414"
    property string bg2: "#191919"
    property string bg3: "#242424"
    property string bg4: "#292929"
    property string bg5: "#323232"
    property string bg6: "#363636"
    property string bg7: "#404040"
    property string bg8: "#444444"
    property string bg9: "#505050"

    property string bgD: "#0b0b0b"
    property string bgD1: "#101010"

    // more darker (ascending)
    property string fg: "#dadada"
    property string fg1: "#e7e7e7"
    property string fg2: "#dfdfdf"
    property string fg3: "#c4c4c4"
    property string fg4: "#9e9e9e"
    property string fg5: "#777777"
    property string fg6: "#6a6a6a"
    property string fg7: "#484848"
    property string fg8: "#313131"
    property string fgL: "#e9e9e9"

    // CC sliders
    property string sliderBg: "#c9c9c9"

    property string fg3D: "#a7a7a7"
    property string fg4D: "#c5c4c4" // d == darker

    property string borderBg: "#6a6a6a"
    property string borderBg1: "#484848"
    property string borderBg2: "#323232"
    property string borderBg3: "#282828"
    property string borderBg4: "#242424"
    property string borderBgFocus: "#555555"
    property string borderBgFocus1: "#4f4f4f"

    // focus bg
    property string focusBg: "#252525"
    property string focusBg1: "#2e2e2e"
    property string focusBgD: "#222222"
    property string focusBgL: "#353535" // L == lighter

    property string focusFg: "#d1d1d1"
    property string focusFg1: "#bcbcbc"
    property string focusFg2: "#a8a8a8"

    property string fontFamily: Config.textFontFamily
    property string nerdFontFamily: Config.nerdFontFamily

    // base literals
    property string white: "#ffffff"
    property string black: "#000000"
    property string transparent: "#00000000"

    // shadows and scrims
    property string shadowSoft: "#7a000000"
    property string shadowPill: "#b0000000"
    property string fadeBottom: "#cc000000"

    // semantic status
    property string ok: "#4bd25c" // battery good, success
    property string okShell: "#46e03b" // shell exit 0
    property string warnMed: "#eecc47" // battery medium
    property string danger: "#e22323" // battery low, error, shutdown confirm
    property string mutedFg: "#fb2a2a" // volume pill muted icon
    property string mutedFgSlider: "#fd2222" // cc slider muted icon
    property string fgMuted: "#8a8a8a"

    // connectivity
    property string netFg: "#6791dc" // network / bluetooth pill icon
    property string netFgOff: "#9ea9bd" // disconnected icon
    property string netConnected: "#4173c4"
    property string netConnectedFg: "#c8d7ef"
    property string netFail: "#e94545"
    property string netBtn: "#3874d7"
    property string netBtnHover: "#3065be"
    property string btDeviceOff: "#949494"
    property string vpnFg: "#48cc47" // vpn pill icon
    property string vpnOkFg: "#64d667" // ip status vpn glyph
    property string ipFg: "#6496dd" // ip status glyph

    // control center
    property string ccActiveBg: "#181d23" // wifi / bluetooth button active
    property string ccActiveBg2: "#20232a" // timer button active
    property string ccDndBg: "#262626"
    property string ccActiveFg: "#4888ef"
    property string ccDndFg: "#fff9eb"
    property string timerFg: "#5892f3" // timer osd icon
    property string burstFg: "#ff922b"
    property string timerRunningFg: "#4490ee"
    property var burstPalette: ["#ffd43b", "#ff6b6b", "#4490ee", "#b197fc", "#f783ac", "#63e6be"]

    // power actions
    property string powerLock: "#628ae2"
    property string powerSleep: "#9d6fff"
    property string powerLogout: "#f4a232"
    property string powerRestart: "#ff6b35"
    property string powerShutdown: "#d62828"
    property string powerLogoutPending: "#ea9d34"
    property string powerRestartConfirm: "#ff6c25"
    property string powerLogoutConfirm: "#e07e20"

    // weather
    property string weatherText: "#ecebeb"
    property string weatherCondition: "#7e7e7e"
    property string weatherTemp: "#a0a0a0"
    property string weatherDay: "#6e6e6e"
    property string weatherFeels: "#f18d41"
    property string weatherHumidity: "#5f99fa"
    property string weatherWind: "#54e04b"
    property string weatherSunrise: "#ffcd58"
    property string weatherSunset: "#ff904d"
    property string weatherClear: "#f4c542"
    property string weatherCloudy: "#9aa0a6"
    property string weatherRain: "#4a9de8"
    property string weatherThunder: "#e8b84a"
    property string weatherSnow: "#d8e8f4"
    property string weatherFog: fgMuted

    // widgets
    property string notificationFg: "#9b9b9b"
    property string notifFg: "#d8ad5c"
    property string dateFg: "#9d9d9d"
    property string todayFg: "#ec3737"
    property string calendarBg: "#1c1c1c"
    property string osdBarBg: "#333333"
    property string scrollIdle: "#3a3a3a"
    property string scrollHover: "#6f6f6f"
    property string scrollPressed: "#888888"
    property string wsActiveBg: "#4d5258"
    property string wsInactiveBg: "#393c41"
    property string wsActiveFg: "#dae0ea"

    property string warning: "#fac94a"
    property string deleting: "#e32626"

    property string accent: "#979797"
    property string coverArtGlowShadow: "#80aae6" // hardcored for now

    property int fontSizeBase: 13
    property int fontSize: Math.round(fontSizeBase * Config.pillScale)
}
