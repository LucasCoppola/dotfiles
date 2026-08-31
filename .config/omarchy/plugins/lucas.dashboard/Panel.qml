import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "lucas.dashboard"
  ipcTarget: "lucas.dashboard"
  manageIpc: false

  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color urgent: bar ? bar.urgent : Color.urgent
  readonly property color dim: Color.muted
  readonly property color trackColor: alpha(foreground, 0.13)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property string home: Quickshell.env("HOME") || ""
  readonly property string pluginDir: home + "/.config/omarchy/plugins/lucas.dashboard"

  property var weather: ({ ready: false })
  property var systemStatus: ({ cpuPercent: 0, memoryPercent: 0 })
  property var codex: null
  property double nowMs: Date.now()

  function alpha(color, opacity) { return Qt.rgba(color.r, color.g, color.b, opacity) }
  function clamp(value, low, high) { return Math.max(low, Math.min(high, value)) }
  function parseRecord(raw, fallback, sourceName) {
    try {
      var parsed = JSON.parse(String(raw || ""))
      return parsed && typeof parsed === "object" ? parsed : fallback
    } catch (error) {
      console.warn("lucas.dashboard", "Invalid " + sourceName + " data", error)
      return fallback
    }
  }

  function refreshDashboard() {
    refreshSystem()
    refreshWeather()
    refreshCodex()
  }
  function refreshSystem() {
    if (!systemProcess.running) systemProcess.running = true
  }
  function refreshWeather() {
    if (!weatherProcess.running) weatherProcess.running = true
  }
  function refreshCodex() {
    if (!codexProcess.running) codexProcess.running = true
  }

  function codexLimit(longWindow) {
    var limits = codex && Array.isArray(codex.limits) ? codex.limits : []
    for (var i = 0; i < limits.length; i++) {
      var label = String(limits[i].label || "").toLowerCase()
      var isLong = label.indexOf("week") >= 0 || label.indexOf("7-day") >= 0
      if (isLong === longWindow) return limits[i]
    }
    return null
  }
  function remainingRatio(limit) {
    if (!limit) return -1
    return clamp(1 - Number(limit.percent || 0), 0, 1)
  }
  function resetRemainingMs(limit) {
    if (!limit || !limit.resetsAt) return -1
    var resetAt = new Date(limit.resetsAt).getTime()
    return isFinite(resetAt) ? resetAt - nowMs : -1
  }
  function formatDuration(milliseconds) {
    if (!(milliseconds > 0)) return ""
    var minutes = Math.floor(milliseconds / 60000)
    var hours = Math.floor(minutes / 60)
    var days = Math.floor(hours / 24)
    if (days > 0) return days + "d " + (hours % 24) + "h"
    if (hours > 0) return hours + "h " + (minutes % 60) + "m"
    return Math.max(1, minutes) + "m"
  }
  function resetText(limit) {
    var duration = formatDuration(resetRemainingMs(limit))
    return duration === "" ? "" : "Resets in " + duration
  }
  function weatherIcon(code) {
    var value = parseInt(String(code || "0"), 10)
    switch (value) {
      case 113: return ""
      case 116: return ""
      case 119: case 122: return ""
      case 143: case 248: case 260: return ""
      case 176: case 263: case 353: return ""
      case 179: case 227: case 230: case 323: case 326: case 368: return ""
      case 182: case 185: case 281: case 284: case 311: case 314:
      case 317: case 320: case 350: case 362: case 365: case 374: case 377: return ""
      case 200: case 386: case 389: case 392: case 395: return ""
      case 266: case 293: case 296: case 299: case 302: case 305: case 308:
      case 356: case 359: return ""
      case 329: case 332: case 335: case 338: case 371: return ""
      default: return ""
    }
  }

  onOpenedChanged: if (opened) {
    nowMs = Date.now()
    refreshDashboard()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  visible: true
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  IpcHandler {
    target: root.ipcTarget
    function open(): void { root.open() }
    function close(): void { root.close() }
    function toggle(): void { root.toggle() }
    function refresh(): string { root.refreshDashboard(); return "ok" }
  }

  FileView {
    id: codexRecord
    path: root.home + "/.local/state/omarchy/agents/usage/codex.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.codex = root.parseRecord(text(), null, "Codex")
    onLoadFailed: root.codex = null
  }

  Process {
    id: systemProcess
    command: [root.pluginDir + "/scripts/dashboard-system-status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.systemStatus = root.parseRecord(text, root.systemStatus, "system")
    }
  }

  Process {
    id: weatherProcess
    command: [root.pluginDir + "/scripts/dashboard-weather-status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.weather = root.parseRecord(text, root.weather, "weather")
    }
  }

  Process {
    id: codexProcess
    command: [root.pluginDir + "/scripts/codex-usage-update", "--limits-only"]
    onExited: codexRecord.reload()
  }

  Timer {
    interval: 5000
    running: root.opened
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refreshSystem()
  }
  Component.onCompleted: {
    // Prime slow network-backed data once per shell session. After that it
    // refreshes only when the dashboard opens or the user requests it.
    root.refreshWeather()
    root.refreshCodex()
  }
  Timer {
    interval: 30000
    running: root.opened
    repeat: true
    onTriggered: root.nowMs = Date.now()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰣇"
    fontSize: 15
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton && root.bar) root.bar.run("xdg-terminal-exec")
      else if (buttonCode === Qt.MiddleButton) root.refreshDashboard()
      else root.toggle()
    }
  }

  KeyboardPanel {
    id: dashboardPanel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: fittedContentWidth(Style.space(396))
    contentHeight: fittedContentHeight(dashboardColumn.implicitHeight, Style.space(520))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onActivateRequested: root.refreshDashboard()
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(text) {
        if (text === "r" || text === "R") root.refreshDashboard()
      }

      Column {
        id: dashboardColumn
        width: parent.width
        spacing: 0

        Item {
          id: weatherSection
          width: parent.width
          height: Style.space(76)

          Text {
            x: 0
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: Style.space(2)
            text: root.weather.ready ? root.weatherIcon(root.weather.weatherCode) : "—"
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: 58
          }

          Row {
            x: Style.space(70)
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(2)

            Text {
              id: weatherTemperature
              text: root.weather.ready ? String(root.weather.temperature) : "—"
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: 52
              font.bold: true
            }
            Text {
              text: root.weather.ready ? "°C" : ""
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.title
              anchors.top: weatherTemperature.top
              anchors.topMargin: Style.space(7)
            }
          }

          Text {
            x: Style.space(188)
            y: Style.space(5)
            width: parent.width - x
            text: root.weather.ready ? "  " + String(root.weather.location || "").toUpperCase() : "WEATHER UNAVAILABLE"
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            font.letterSpacing: 0.8
            elide: Text.ElideRight
          }

          WeatherStat {
            x: Style.space(188)
            y: Style.space(33)
            width: Style.space(50)
            label: "FEELS"
            value: root.weather.ready ? root.weather.feelsLike + "°C" : "—"
          }
          WeatherStat {
            x: Style.space(246)
            y: Style.space(33)
            width: Style.space(72)
            label: "WIND"
            value: root.weather.ready ? root.weather.windSpeed + " km/h" : "—"
          }
          WeatherStat {
            x: Style.space(326)
            y: Style.space(33)
            width: parent.width - x
            label: "HUMID"
            value: root.weather.ready ? root.weather.humidity + "%" : "—"
          }
        }

        Item {
          width: parent.width
          height: Style.space(16)
          Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 1
            color: root.trackColor
          }
        }

        Row {
          width: parent.width
          height: Style.space(158)
          spacing: 0

          Item {
            id: systemSection
            width: (dashboardColumn.width - 1) / 2
            height: parent.height

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: if (root.bar) root.bar.run("omarchy-launch-or-focus-tui btop")
            }

            Text {
              x: 0
              y: 0
              text: "SYSTEM"
              color: root.dim
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
              font.letterSpacing: 1.2
            }

            MetricBlock {
              x: 0
              y: Style.space(27)
              width: parent.width - Style.space(20)
              title: "CPU"
              valueText: Math.round(Number(root.systemStatus.cpuPercent || 0)) + "%"
              ratio: Number(root.systemStatus.cpuPercent || 0) / 100
              detail: (String(root.systemStatus.cpuTemperature || "") !== "" ? root.systemStatus.cpuTemperature + "°C  ·  " : "")
                + "load " + String(root.systemStatus.load || "—")
              alarming: ratio >= 0.9 || Number(root.systemStatus.cpuTemperature || 0) >= 90
            }

            MetricBlock {
              x: 0
              y: Style.space(92)
              width: parent.width - Style.space(20)
              title: "Memory"
              valueText: Math.round(Number(root.systemStatus.memoryPercent || 0)) + "%"
              ratio: Number(root.systemStatus.memoryPercent || 0) / 100
              detail: String(root.systemStatus.memoryUsedGiB || "—") + " of "
                + String(root.systemStatus.memoryTotalGiB || "—") + " GiB"
              alarming: ratio >= 0.9
            }
          }

          Rectangle {
            width: 1
            height: Style.space(152)
            color: root.trackColor
          }

          Item {
            id: codexSection
            width: (dashboardColumn.width - 1) / 2
            height: parent.height

            readonly property var sessionLimit: root.codexLimit(false)
            readonly property var weeklyLimit: root.codexLimit(true)

            Text {
              x: Style.space(20)
              y: 0
              text: "CODEX"
              color: root.dim
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
              font.letterSpacing: 1.2
            }

            LimitBlock {
              x: Style.space(20)
              y: Style.space(27)
              width: parent.width - Style.space(20)
              title: "5-hour"
              limit: codexSection.sessionLimit
            }
            LimitBlock {
              x: Style.space(20)
              y: Style.space(92)
              width: parent.width - Style.space(20)
              title: "Weekly"
              limit: codexSection.weeklyLimit
            }
          }
        }
      }
    }
  }

  component WeatherStat: Column {
    property string label: ""
    property string value: ""
    spacing: Style.space(5)

    Text {
      text: parent.label
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      font.letterSpacing: 0.8
    }
    Text {
      text: parent.value
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.body
    }
  }

  component MetricBlock: Item {
    id: metricBlock
    property string title: ""
    property string valueText: ""
    property string detail: ""
    property real ratio: 0
    property bool alarming: false
    height: Style.space(58)

    Text {
      anchors.left: parent.left
      anchors.top: parent.top
      text: metricBlock.title
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.body
    }
    Text {
      anchors.right: parent.right
      anchors.top: parent.top
      text: metricBlock.valueText
      color: metricBlock.alarming ? root.urgent : root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      font.bold: true
    }
    DashboardMeter {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.topMargin: Style.space(22)
      value: metricBlock.ratio
      alarming: metricBlock.alarming
    }
    Text {
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.topMargin: Style.space(35)
      text: metricBlock.detail
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
    }
  }

  component LimitBlock: Item {
    id: limitBlock
    property string title: ""
    property var limit: null
    readonly property real remaining: root.remainingRatio(limit)
    readonly property bool alarming: remaining >= 0 && remaining <= 0.1
    height: Style.space(58)

    Text {
      anchors.left: parent.left
      anchors.top: parent.top
      text: limitBlock.title
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.body
    }
    Text {
      anchors.right: parent.right
      anchors.top: parent.top
      text: limitBlock.remaining >= 0 ? Math.round(limitBlock.remaining * 100) + "% left" : "—"
      color: limitBlock.alarming ? root.urgent : root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      font.bold: true
    }
    DashboardMeter {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.topMargin: Style.space(22)
      value: limitBlock.remaining
      alarming: limitBlock.alarming
    }
    Text {
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.topMargin: Style.space(35)
      text: root.resetText(limitBlock.limit)
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
    }
  }

  component DashboardMeter: Item {
    id: dashboardMeter
    property real value: 0
    property bool alarming: false
    height: Math.max(Style.space(4), 4)

    Rectangle {
      anchors.fill: parent
      radius: height / 2
      color: root.trackColor
    }
    Rectangle {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width * root.clamp(dashboardMeter.value, 0, 1)
      height: parent.height
      radius: height / 2
      color: dashboardMeter.alarming ? root.urgent : Color.accent
      Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
    }
  }
}
