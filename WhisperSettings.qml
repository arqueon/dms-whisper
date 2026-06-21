import QtQuick
import Quickshell
import qs.Common
import qs.Modules.Plugins
import qs.Services
import qs.Widgets

PluginSettings {
    id: root
    pluginId: "dmsWhisper"

    StyledText {
        width: parent.width
        text: "DMS Whisper Configuration"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        wrapMode: Text.WordWrap
        text: "Configure the backend behavior for Whisper transcription."
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
    }

    StyledRect {
        width: parent.width
        height: 1
        color: Theme.surfaceVariant
    }

    SelectionSetting {
        settingKey: "whisperBackend"
        label: "Whisper Backend"
        options: [
            {label: "OpenAI Whisper CLI", value: "openai-whisper"},
            {label: "faster-whisper", value: "faster-whisper"},
            {label: "whisper.cpp", value: "whisper-cpp"}
        ]
        defaultValue: pluginData.whisperBackend || "openai-whisper"
    }

    SelectionSetting {
        settingKey: "whisperModel"
        label: "Transcription Model"
        options: [
            {label: "Tiny (Fastest, least accurate)", value: "tiny"},
            {label: "Base (Balanced)", value: "base"},
            {label: "Small", value: "small"},
            {label: "Medium", value: "medium"},
            {label: "Large (Slowest, most accurate)", value: "large"}
        ]
        defaultValue: pluginData.whisperModel || "base"
    }

    StringSetting {
        settingKey: "outputDirectory"
        label: "Output Directory (where wav and txt are saved)"
        defaultValue: pluginData.outputDirectory || (Quickshell.env("HOME") + "/Documents/Whisper")
    }

    SelectionSetting {
        settingKey: "language"
        label: "Language (leave Auto to detect)"
        options: [
            {label: "Auto Detect", value: "auto"},
            {label: "English", value: "en"},
            {label: "Spanish", value: "es"},
            {label: "French", value: "fr"},
            {label: "German", value: "de"}
        ]
        defaultValue: pluginData.language || "auto"
    }

    ToggleSetting {
        settingKey: "translateToEnglish"
        label: "Translate to English (if speaking another language)"
        defaultValue: pluginData.translateToEnglish === true
    }

    StringSetting {
        settingKey: "initialPrompt"
        label: "Initial Prompt"
        description: "Optional context for names, acronyms, technical terms, or preferred spelling."
        placeholder: "Example: Spanish from Mexico. Names: UdeG, DMS, Quickshell."
        defaultValue: pluginData.initialPrompt || ""
    }

    StyledText {
        text: "Backend Commands"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.DemiBold
        color: Theme.surfaceText
    }

    StringSetting {
        settingKey: "openaiWhisperCommand"
        label: "OpenAI Whisper Command"
        description: "Command used by the OpenAI Whisper backend."
        defaultValue: pluginData.openaiWhisperCommand || "whisper"
    }

    StringSetting {
        settingKey: "fasterWhisperCommand"
        label: "faster-whisper Command"
        description: "Command used by the faster-whisper backend."
        defaultValue: pluginData.fasterWhisperCommand || "faster-whisper"
    }

    StringSetting {
        settingKey: "whisperCppCommand"
        label: "whisper.cpp Command"
        description: "Command used by the whisper.cpp backend, usually whisper-cli."
        defaultValue: pluginData.whisperCppCommand || "whisper-cli"
    }

    StringSetting {
        settingKey: "whisperCppModelPath"
        label: "whisper.cpp Model Path"
        description: "Path to a whisper.cpp GGML/GGUF model file."
        placeholder: "/path/to/ggml-base.bin"
        defaultValue: pluginData.whisperCppModelPath || ""
    }

    StyledRect {
        width: parent.width
        height: 1
        color: Theme.surfaceVariant
    }

    StyledText {
        text: "IPC Commands"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.DemiBold
        color: Theme.surfaceText
    }

    StyledRect {
        width: parent.width
        height: commandsCol.implicitHeight + Theme.spacingL * 2
        radius: Theme.cornerRadius
        color: Theme.surfaceContainerHigh

        Column {
            id: commandsCol
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingS

            StyledText {
                width: parent.width
                text: "dms ipc whisper toggle"
                font.pixelSize: Theme.fontSizeMedium
                font.family: "monospace"
                color: Theme.surfaceText
                wrapMode: Text.WrapAnywhere
            }
            
            StyledText {
                width: parent.width
                text: "Start or stop recording. Useful for binding to a hotkey in Hyprland, Niri, or Sway."
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                wrapMode: Text.WrapAnywhere
            }
        }
    }
}
