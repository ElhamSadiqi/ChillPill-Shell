import QtQuick
import "../components"
import ".."

Page {
    Heading { text: "APPLICATIONS" }
    TextRow { label: "Default terminal"; hint: "To open Console-Only apps in the Terminal"; fieldWidth: 200; value: ConfigStore.get("defaultTerminal", ""); onEdited: (v) => ConfigStore.set("defaultTerminal", v) }
    TextRow { label: "Screen lock app command"; placeholder: "chillpill-lock"; fieldWidth: 200; value: ConfigStore.get("screenLockAppCommand", ""); onEdited: (v) => ConfigStore.set("screenLockAppCommand", v) }
    ToggleRow { label: "Lockscreen power buttons"; hint: "Show suspend / restart / shutdown on the lockscreen surface (hide them on shared machines)"; value: ConfigStore.get("lockscreenPowerActions", true); onEdited: (v) => ConfigStore.set("lockscreenPowerActions", v) }
    ToggleRow { label: "Lockscreen media player"; hint: "Show the media card on the lockscreen card (only when something plays)"; value: ConfigStore.get("lockscreenMedia", true); onEdited: (v) => ConfigStore.set("lockscreenMedia", v) }
    ToggleRow { label: "Confirm power actions"; hint: "Confirm the power action prompt (Shutdown, Restart, Logout)"; value: ConfigStore.get("confirmPowerActions", true); onEdited: (v) => ConfigStore.set("confirmPowerActions", v) }
    Heading { text: "CLIPBOARD" }
    ToggleRow { label: "Auto delete cliphist image cache"; hint: "Delete the image cache also as you delete the image from the Cliphist (Clipboard Manager) state"; value: ConfigStore.get("deleteCliphistImgCache", true); onEdited: (v) => ConfigStore.set("deleteCliphistImgCache", v) }
    ToggleRow { label: "Separate preview tab types"; hint: "Skip the previous/next clipboard item if it doesn't match with the current selected item"; value: ConfigStore.get("separatePreviewTabTypes", true); onEdited: (v) => ConfigStore.set("separatePreviewTabTypes", v) }
    ToggleRow { label: "Fuzzy search"; hint: "Match clipboard items with non-consecutive characters"; value: ConfigStore.get("cliphistFuzzySearch", false); onEdited: (v) => ConfigStore.set("cliphistFuzzySearch", v) }
    Heading { text: "SPOTLIGHT" }
    ToggleRow { label: "Fuzzy search"; hint: "Match app names with non-consecutive characters"; value: ConfigStore.get("appLauncherFuzzySearch", false); onEdited: (v) => ConfigStore.set("appLauncherFuzzySearch", v) }
    TextRow { label: "Web search URL"; hint: "Spotlight '?' mode, %s is replaced by the query"; fieldWidth: 260; value: ConfigStore.get("webSearchUrl", "https://duckduckgo.com/?q=%s"); onEdited: (v) => ConfigStore.set("webSearchUrl", v) }
}
