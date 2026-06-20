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
        Item {
            implicitWidth: volutaIcon.width
            implicitHeight: Theme.iconSize
            anchors.verticalCenter: parent ? parent.verticalCenter : undefined

            property string iconColor: root.isRecording ? Theme.errorText.toString() : Theme.surfaceText.toString()
            property string encodedColor: iconColor.replace("#", "%23")
            property string svgData: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='" + encodedColor + "' stroke-width='2' stroke-linecap='round'><path d='M 4 21 C 4 12 10 4 14 4 A 7 7 0 1 1 14 18 A 5 5 0 1 1 14 8 A 3 3 0 1 1 14 14 A 1 1 0 1 1 14 12'/></svg>"

            Image {
                id: volutaIcon
                source: svgData
                sourceSize.width: Theme.iconSizeSmall * 2
                sourceSize.height: Theme.iconSizeSmall * 2
                width: Theme.iconSizeSmall
                height: Theme.iconSizeSmall
                anchors.centerIn: parent
                smooth: true
                antialiasing: true

                scale: root.isRecording ? 1.15 : 1.0
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
