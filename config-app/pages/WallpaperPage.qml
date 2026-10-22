import QtQuick
import "../components"
import ".."

Page {
    Heading { text: "WALLPAPER" }
    TextRow { label: "Wallpapers directory"; fieldWidth: 320; value: ConfigStore.get("wallpapersDir", ""); onEdited: (v) => ConfigStore.set("wallpapersDir", v) }
    TextRow { label: "Custom wallpaper script"; hint: "Empty = awww (Wallpaper backend)"; fieldWidth: 320; placeholder: "/path/to/script.sh"; value: ConfigStore.get("customWallpaperScript", ""); onEdited: (v) => ConfigStore.set("customWallpaperScript", v) }
    Heading { text: "SWITCHER" }
    ToggleRow { label: "Close switcher after picking a wallpaper"; value: ConfigStore.get("wsCloseOnWallpaperSet", true); onEdited: (v) => ConfigStore.set("wsCloseOnWallpaperSet", v) }
    ToggleRow { label: "Wallpaper switcher animation"; hint: "Wallpaper previews pops in-animation"; value: ConfigStore.get("wsAnimation", true); onEdited: (v) => ConfigStore.set("wsAnimation", v) }
}
