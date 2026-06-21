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
    readonly property string scriptPath: decodeURIComponent(Qt.resolvedUrl("whisper-action.sh").toString().replace(/^file:\/\//, ""))

    Process {
        id: checkStateProcess
        command: ["/bin/bash", scriptPath, "status"]
        onExited: root.isRecording = (exitCode === 0)
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: checkStateProcess.running = true
    }

    function toggleRecording() {
        const backend = pluginData.whisperBackend || "openai-whisper";
        const model = pluginData.whisperModel || "base";
        const dir = pluginData.outputDirectory || (homeDir + "/Documents/Whisper");
        const lang = pluginData.language || "auto";
        const translate = pluginData.translateToEnglish ? "yes" : "no";
        const initialPrompt = pluginData.initialPrompt || "";
        const openaiCommand = pluginData.openaiWhisperCommand || "whisper";
        const fasterCommand = pluginData.fasterWhisperCommand || "faster-whisper";
        const whisperCppCommand = pluginData.whisperCppCommand || "whisper-cli";
        const whisperCppModelPath = pluginData.whisperCppModelPath || "";

        Quickshell.execDetached([
            "/bin/bash",
            scriptPath,
            "toggle",
            backend,
            model,
            dir,
            lang,
            translate,
            initialPrompt,
            openaiCommand,
            fasterCommand,
            whisperCppCommand,
            whisperCppModelPath
        ]);
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

            property string iconColor: root.isRecording ? Theme.errorText.toString() : "#00d4c7"
            property string encodedColor: iconColor.replace("#", "%23")
            property string svgData: `data:image/svg+xml;utf8,<svg version="1.0" xmlns="http://www.w3.org/2000/svg" width="400pt" height="400pt" viewBox="0 0 400 400" preserveAspectRatio="xMidYMid meet"><g transform="translate(0,400) scale(0.1,-0.1)" fill="${encodedColor}" stroke="${encodedColor}" stroke-width="110" stroke-linejoin="round" stroke-linecap="round"><path d="M2364 2705 c-182 -62 -316 -188 -379 -357 l-18 -48 -41 26 c-82 50 -160 86 -261 120 -93 31 -113 34 -218 34 -128 0 -214 -15 -351 -61 -109 -36 -292 -122 -323 -151 -32 -30 -31 -81 3 -115 25 -25 28 -25 102 -17 139 16 268 9 357 -20 158 -51 253 -125 494 -386 276 -300 376 -377 566 -440 60 -20 90 -24 205 -24 125 0 142 3 222 31 248 86 443 287 513 526 26 89 24 263 -3 360 -71 250 -255 453 -474 522 -67 21 -98 25 -201 25 -102 0 -133 -4 -193 -25z m266 -145 c103 -15 215 -76 290 -157 75 -82 135 -199 157 -308 42 -209 -63 -431 -269 -568 -138 -91 -307 -120 -449 -77 -157 47 -223 98 -493 385 -94 99 -199 206 -234 239 -84 75 -194 147 -282 183 -38 15 -70 31 -70 35 0 11 88 22 175 21 134 -1 323 -79 434 -180 52 -46 70 -73 111 -157 41 -87 59 -112 123 -173 197 -187 442 -202 603 -37 77 78 109 151 109 244 0 64 -5 83 -27 121 -58 98 -145 149 -261 152 -60 2 -79 -2 -117 -23 -135 -76 -139 -271 -5 -251 29 4 53 29 65 67 11 31 15 34 53 34 49 0 103 -29 119 -65 15 -33 -4 -97 -43 -147 -91 -114 -249 -100 -383 34 -52 52 -67 75 -86 132 -28 86 -25 186 9 258 58 120 184 214 321 238 63 11 77 11 150 0z"/></g></svg>`

            Image {
                id: volutaIcon
                source: svgData
                sourceSize.width: Theme.iconSize * 3
                sourceSize.height: Theme.iconSize * 3
                width: Theme.iconSize
                height: Theme.iconSize
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
