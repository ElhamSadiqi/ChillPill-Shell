import QtQuick
import "../"

// toggle for the lockscreen-only media features. those have no scope choice to
// make (the control center always shows them), so a plain on/off reads better
// than the 4way selector. Stored as "lockscreen" / "none" so Config.qml keeps
// one mechanism for every media feature.

ToggleRow {
    id: t

    property string optionKey: ""
    property bool defaultOn: true

    function isOn() {
        const v = ConfigStore.get(optionKey, "");
        if (v === "" || v === undefined || v === null)
            return t.defaultOn;
        return v !== "none" && v !== "controlCenter";
    }

    value: isOn()
    onEdited: (v) => ConfigStore.set(optionKey, v ? "lockscreen" : "none")
}
