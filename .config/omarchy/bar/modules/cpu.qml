import QtQuick
import Quickshell.Io
import qs.Ui

Item {
  id: root

  property var bar
  property string moduleName
  property var settings
  property string tooltip: "CPU"
  property bool urgent: false

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function refresh() {
    if (!status.running) status.running = true
  }

  function update(raw) {
    try {
      var data = JSON.parse(String(raw || "").trim())
      tooltip = String(data.tooltip || "CPU")
      urgent = data.class === "active"
    } catch (error) {
      tooltip = "CPU data unavailable"
      urgent = false
    }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰍛"
    fontSize: 14
    active: root.urgent
    tooltipText: root.tooltip
    horizontalMargin: 7.5
    onPressed: function() {
      if (root.bar) root.bar.run("omarchy-launch-or-focus-tui btop")
    }
  }

  Process {
    id: status
    command: ["bash", "-lc", "~/.config/omarchy/bar/scripts/cpu-status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.update(text)
    }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }
}
