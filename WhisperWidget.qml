import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Modules.Plugins
import qs.Services
import qs.Widgets

PluginComponent {
    id: root

    property bool isRecording: false
    readonly property string pluginIdValue: "dmsWhisper"
    readonly property string homeDir: Quickshell.env("HOME") || ""
    readonly property string scriptPath: homeDir + "/Projects/dms-whisper/whisper-action.sh"

    Process {
        id: checkStateProcess
        command: ["test", "-f", "/tmp/dms-whisper-record.pid"]
        onExited: root.isRecording = (exitCode === 0)
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: checkStateProcess.running = true
    }

    function toggleRecording() {
        Quickshell.execDetached(["/bin/sh", scriptPath, "toggle"]);
        Qt.callLater(() => {
            recordingCheckTimer.start();
        });
    }

    Timer {
        id: recordingCheckTimer
        interval: 500
        onTriggered: checkStateProcess.running = true
    }

    IpcHandler {
        target: "whisper"
        function toggle(): string {
            root.toggleRecording();
            return "queued";
        }
    }

    Component {
        id: widgetContent
        Row {
            spacing: Theme.spacingS

            DankIcon {
                name: root.isRecording ? "mic" : "mic_none"
                color: root.isRecording ? Theme.errorText : Theme.surfaceText
                size: Theme.fontSizeLarge
                anchors.verticalCenter: parent.verticalCenter
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.toggleRecording()
                cursorShape: Qt.PointingHandCursor
            }
        }
    }

    horizontalBarPill: widgetContent
    verticalBarPill: widgetContent
}
