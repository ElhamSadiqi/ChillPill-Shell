pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string configPath: Quickshell.env("HOME") + "/.config/chillpill-shell/config.jsonc"

    property var cfg: ({})
    property bool loaded: false
    property string status: ""
    property bool statusError: false
    property string lastWritten: ""

    function get(key, fallback) {
        return root.cfg[key] === undefined ? fallback : root.cfg[key]
    }

    function set(key, value) {
        var c = Object.assign({}, root.cfg)
        c[key] = value
        root.cfg = c
        saveTimer.restart()
    }

    function setStatus(msg, isError) {
        root.status = msg
        root.statusError = isError === true
    }

    // custom module library, kept out of the user config at
    // ~/.cache/chillpill-shell/custom-modules.json
    readonly property string cacheDir: Quickshell.env("HOME") + "/.cache/chillpill-shell"
    readonly property string customModulesPath: cacheDir + "/custom-modules.json"
    property var customCache: []
    property bool customCacheLoaded: false
    property string lastCacheWritten: ""

    function setCustomCache(v) {
        if (JSON.stringify(v) === JSON.stringify(root.customCache)) return
        root.customCache = v
        cacheSaveTimer.restart()
    }

    Process {
        id: cacheDirProc
        running: false
        command: ["mkdir", "-p", root.cacheDir]
        Component.onCompleted: running = true
    }

    Timer {
        id: cacheSaveTimer
        interval: 150
        onTriggered: {
            var s = JSON.stringify(root.customCache, null, 2) + "\n"
            root.lastCacheWritten = s
            customFile.setText(s)
        }
    }

    FileView {
        id: customFile
        path: root.customModulesPath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            var t = text()
            if (t === root.lastCacheWritten) return
            try {
                var d = JSON.parse(t)
                root.customCache = Array.isArray(d) ? d : []
            } catch (e) {
                root.customCache = []
            }
            root.customCacheLoaded = true
        }
        onLoadFailed: {
            root.customCache = []
            root.customCacheLoaded = true
        }
    }

    function reload() { file.reload() }

    FileView {
        id: file
        path: root.configPath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            var t = text()
            if (t === root.lastWritten) return
            try {
                root.cfg = JSON.parse(t)
                root.setStatus("Loaded")
            } catch (e) {
                root.setStatus("Parse error: " + e, true)
                return
            }
            root.loaded = true
            statusTimer.restart()
        }
        onLoadFailed: {
            root.loaded = true
            root.setStatus("No config found, will create one")
        }
        onSaved: { root.setStatus("Saved"); statusTimer.restart() }
        onSaveFailed: root.setStatus("Save failed", true)
    }

    Timer {
        id: saveTimer
        interval: 400
        onTriggered: {
            var s = JSON.stringify(root.cfg, null, 2) + "\n"
            root.lastWritten = s
            file.setText(s)
        }
    }
    Timer { id: statusTimer; interval: 2500; onTriggered: root.status = "" }
}
