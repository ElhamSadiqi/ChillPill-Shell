import QtQuick
import QtQuick.Layouts
import "components"
import "."

Item {
    id: pg
    default property alias items: col.data
    property string title: ""
    readonly property alias flickable: flick
    readonly property alias scrollbar: vbar

    // ── search ──
    // Query from the sidebar. Rows match on label + hint; a matching Heading
    // reveals its whole section, a matching row only itself. Label-less
    // controls (ModulesEditor, NumChips) follow their section.
    property string filter: ""
    property int matchCount: 0

    onFilterChanged: { flick.contentY = 0; applyFilter() }
    Component.onCompleted: applyFilter()
    // a hidden page can't read back its rows' visible, so re-apply on show
    onVisibleChanged: if (visible) applyFilter()

    function applyFilter() {
        if (!col) return // ids resolve after creation
        var q = filter.trim().toLowerCase()
        var list = col.data
        var i, it
        if (q === "") {
            for (i = 0; i < list.length; i++) if (list[i].visible !== undefined) list[i].visible = true
            matchCount = 0
            return
        }

        // 2 = heading, 1 = labelled row, 0 = section control
        var kind = [], hay = []
        for (i = 0; i < list.length; i++) {
            it = list[i]
            if (it.label !== undefined) {
                kind.push(1)
                hay.push((it.label + " " + (it.hint || "")).toLowerCase())
            } else if (it.text !== undefined) {
                kind.push(2)
                hay.push(it.text.toLowerCase())
            } else {
                kind.push(0)
                hay.push("")
            }
        }

        // per heading: own text hit? section hit?
        var headText = [], headHit = []
        var cur = -1
        for (i = 0; i < list.length; i++) {
            if (kind[i] === 2) {
                cur = i
                headText[i] = hay[i].indexOf(q) >= 0
                headHit[i] = headText[i]
            } else if (cur >= 0 && kind[i] === 1 && hay[i].indexOf(q) >= 0) {
                headHit[cur] = true
            }
        }

        // decide then write; reading visible back gives false on hidden pages
        var show = [], n = 0
        cur = -1
        for (i = 0; i < list.length; i++) {
            var s
            if (kind[i] === 2) {
                cur = i
                s = headHit[i]
            } else if (cur < 0) {
                // rows above the first heading stand alone
                s = kind[i] === 1 && hay[i].indexOf(q) >= 0
            } else if (kind[i] === 1) {
                s = headText[cur] || hay[i].indexOf(q) >= 0
            } else {
                // no label of its own, follow the section
                s = headHit[cur]
            }
            show[i] = s
            if (s && kind[i] !== 2) n++
        }
        for (i = 0; i < list.length; i++) if (list[i].visible !== undefined) list[i].visible = show[i]
        matchCount = n
    }

    readonly property bool empty: filter !== "" && matchCount === 0

    Flickable {
        id: flick
        anchors.fill: parent
        visible: !pg.empty
        contentHeight: col.implicitHeight + 60
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        // filtering shrinks the content; never leave the view past the end,
        // that used to strand the thumb outside its track
        onContentHeightChanged: contentY = Math.max(0, Math.min(contentY, Math.max(0, contentHeight - height)))
        ColumnLayout {
            id: col
            x: 28; y: 24
            width: Math.min(flick.width - 56, 760)
            spacing: 0
        }
    }
    // empty state
    Text {
        anchors.centerIn: parent
        visible: pg.empty
        text: "No settings match \u201C" + pg.filter + "\u201D"
        color: Theme.fg5
        font.family: Theme.fontFamily
        font.pixelSize: 13
    }
    Item {
        id: vbar
        // scrollable range, guarded so the thumb never divides by zero
        readonly property real range: Math.max(0, flick.contentHeight - flick.height)
        readonly property bool needed: flick.visible && range > 1 && height > 40
        visible: needed
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 6
        width: 8
        opacity: vbarHover.hovered || thumbDrag.active || flick.flicking ? 1 : 0.6
        Behavior on opacity { NumberAnimation { duration: 140 } }

        Rectangle {
            anchors.fill: parent
            radius: 4
            color: Theme.bg3
            opacity: vbar.needed ? 0.6 : 0
        }
        // click the track to page; wheel over the bar scrolls too
        MouseArea {
            id: trackMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: (mouse) => {
                if (vbar.range <= 0) return
                var dir = mouse.y < thumb.y ? -1 : 1
                flick.contentY = Math.max(0, Math.min(vbar.range, flick.contentY + dir * flick.height * 0.85))
            }
        }
        // wheel over the bar scrolls too; touchpads send pixelDelta, so keep
        // the leftover fraction or slow two-finger scrolls come out choppy
        WheelHandler {
            property real accum: 0
            onWheel: (event) => {
                if (!vbar.needed) return
                var d = event.angleDelta.y !== 0 ? event.angleDelta.y / 120
                        : event.pixelDelta.y / 48
                accum += d * 48
                var step = Math.trunc(accum)
                accum -= step
                if (step !== 0) flick.contentY = Math.max(0, Math.min(vbar.range, flick.contentY - step))
            }
        }

        Rectangle {
            id: thumb
            x: 1
            width: parent.width - 2
            radius: 3
            color: Theme.bg8
            // exact visible fraction, clamped so a short window can't
            // produce a thumb taller than its own track
            readonly property real maxY: Math.max(0, vbar.height - height)
            readonly property real ratio: flick.height / Math.max(1, flick.contentHeight)
            readonly property real trackY: maxY * (vbar.range > 0
                ? Math.max(0, Math.min(1, flick.contentY / vbar.range)) : 0)
            height: Math.max(24, Math.min(vbar.height, vbar.height * ratio))
            // bound straight to contentY: it already ticks every frame while
            // the flickable is moving, and an animation here restarted each
            // frame just made the thumb crawl behind the content
            y: thumbDrag.active ? thumbDrag.dragY : trackY

            DragHandler {
                id: thumbDrag
                target: null
                xAxis.enabled: false
                cursorShape: Qt.PointingHandCursor
                property real dragY: 0
                property real baseY: 0
                onActiveChanged: {
                    if (active) {
                        // flickable has no writable velocity in qt 6.12; going
                        // non-interactive kills the kinetic timer and the fling
                        flick.interactive = false
                        baseY = thumb.trackY
                        dragY = thumb.trackY
                    } else {
                        flick.interactive = true
                    }
                }
                onActiveTranslationChanged: {
                    if (!active || vbar.range <= 0) return
                    var ny = Math.max(0, Math.min(thumb.maxY, baseY + activeTranslation.y))
                    dragY = ny
                    flick.contentY = (ny / Math.max(1, thumb.maxY)) * vbar.range
                }
            }
        }
        HoverHandler { id: vbarHover }
    }
}
