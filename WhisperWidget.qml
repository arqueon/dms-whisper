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
        const model = pluginData.whisperModel || "base";
        const dir = pluginData.outputDirectory || (homeDir + "/Documents/Whisper");
        const lang = pluginData.language || "auto";
        const translate = pluginData.translateToEnglish ? "yes" : "no";

        Quickshell.execDetached(["/bin/sh", scriptPath, "toggle", model, dir, lang, translate]);
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
        Item {
            implicitWidth: volutaIcon.width
            implicitHeight: Theme.iconSize
            anchors.verticalCenter: parent ? parent.verticalCenter : undefined

            Image {
                id: volutaIcon
                source: "file://" + root.homeDir + "/Projects/dms-whisper/tlahtolli.svg"
                sourceSize.width: Theme.iconSizeSmall * 3
                sourceSize.height: Theme.iconSizeSmall * 3
                width: Theme.iconSizeSmall
                height: Theme.iconSizeSmall
                anchors.centerIn: parent
                smooth: true
                antialiasing: true

                scale: root.isRecording ? 1.2 : 1.0
                Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

                SequentialAnimation on opacity {
                    running: root.isRecording
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.4; duration: 700; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 700; easing.type: Easing.InOutSine }
                }
            }
        }
    }

    pillClickAction: function() { root.toggleRecording(); }

    horizontalBarPill: widgetContent
    verticalBarPill: widgetContent
}
