# Dank Material Shell (DMS) Whisper Plugin

A [Dank Material Shell](https://github.com/AvengeMedia/DankMaterialShell) plugin that brings the power of **Whisper** AI transcription directly to your status bar.

Record voice notes with a single click (or via IPC keybinds), have them transcribed in the background using Whisper, copied automatically to your clipboard, and cleanly backed up locally (both the audio and the generated text).

## Features

- **Minimalist Design**: A teal pre-Hispanic conch icon that blinks and highlights when recording, seamlessly integrating with your DMS theme.
- **Silent Workflow**: Notifies you of recording start and successful transcription using native system notifications.
- **IPC Controlled**: Easily integrate it into your window manager (Hyprland, Niri, Sway, etc.) via global keybinds.
- **Organized History**: Saves separate timestamped audio and text files, and maintains a centralized chronological markdown log.

---

## Requirements and Dependencies

Before installing the plugin, ensure you have the necessary recording utilities, clipboard managers, and the Whisper engine installed on your system.

### Arch Linux (CachyOS, EndeavourOS, etc.)

1. **Install system utilities:**
   ```bash
   sudo pacman -S alsa-utils wl-clipboard ffmpeg
   ```

2. **Install a Whisper backend:**
   ```bash
   # OpenAI Whisper CLI
   sudo pacman -S python-pipx
   pipx install openai-whisper

   # Optional: faster-whisper-compatible CLI
   pipx install whisper-ctranslate2

   # Optional: whisper.cpp CLI (GPU-accelerated via Vulkan, works on any GPU)
   # CachyOS ships a prebuilt binary in its repos:
   sudo pacman -S whisper-cpp-vulkan
   # On plain Arch without those repos, build from the AUR instead:
   # yay -S whisper.cpp
   ```

### Ubuntu / Debian

1. **Install system utilities and pipx:**
   ```bash
   sudo apt update
   sudo apt install alsa-utils wl-clipboard ffmpeg pipx
   ```

2. **Install a Whisper backend:**
   ```bash
   # OpenAI Whisper CLI
   pipx install openai-whisper

   # Optional: faster-whisper-compatible CLI
   pipx install whisper-ctranslate2

   # Optional: whisper.cpp CLI
   # Install from your distro packages or build from https://github.com/ggerganov/whisper.cpp
   ```

### Fedora

1. **Install system utilities and pipx:**
   ```bash
   sudo dnf install alsa-utils wl-clipboard ffmpeg pipx
   ```

2. **Install a Whisper backend:**
   ```bash
   # OpenAI Whisper CLI
   pipx install openai-whisper

   # Optional: faster-whisper-compatible CLI
   pipx install whisper-ctranslate2

   # Optional: whisper.cpp CLI
   sudo dnf install whisper.cpp
   ```

*(Note: `alsa-utils` provides the `arecord` tool, `wl-clipboard` provides `wl-copy`, and `ffmpeg` is required by the `openai-whisper` and `whisper-ctranslate2` backends to decode the recorded audio. Make sure `~/.local/bin` is in your `$PATH` environment variable so CLI backends installed via pipx are recognized. For `whisper.cpp`, set the command and model path in plugin settings.)*

---

## Plugin Installation

1. Clone this repository into your local Dank Material Shell plugins folder:
   ```bash
   git clone https://github.com/arqueon/dms-whisper.git ~/.config/DankMaterialShell/plugins/dms-whisper
   ```
   
2. Make the main script executable:
   ```bash
   chmod +x ~/.config/DankMaterialShell/plugins/dms-whisper/whisper-action.sh
   ```

3. Open Dank Material Shell settings (usually by pressing `Mod + ,`), go to the **Plugins** tab, click the **Scan** button, and enable the plugin named **DMS Whisper**.

4. To fully load the plugin and its IPC handler for the first time, restart your DMS environment:
   ```bash
   dms restart
   ```

---

## Usage

### Via Graphical Interface (Dankbar)
Simply left-click the pre-Hispanic conch icon located on your top or vertical panel. The icon will blink and highlight to indicate that recording is active. Click it again to stop capturing audio and start the automatic transcription.

### Via IPC Commands (Keybinds)
The plugin registers a command in the Dank Material Shell IPC bus that allows you to toggle the recording state without relying on mouse clicks.

You can bind this command in your compositor's configuration file:

**Hyprland** (`hyprland.conf`):
```bash
# Bind to SUPER + W
bind = SUPER, W, exec, dms ipc whisper toggle
```

**Niri** (`config.kdl`):
```kdl
// Bind to Mod + W
binds {
    Mod+W { spawn "dms" "ipc" "whisper" "toggle"; }
}
```

### Where are my notes and audio files saved?
The plugin automatically organizes everything in your Documents folder:
- **Base Directory:** `~/Documents/Whisper/`
- **Original Audio:** `Whisper_YYYY-MM-DD_HH-MM-SS.wav`
- **Raw Extracted Text:** `Whisper_YYYY-MM-DD_HH-MM-SS.txt`
- **Global Record (The Log):** `WhisperNotes.md`. This is a living document where all your transcriptions are sequentially appended as bullet points with their exact date and time.

---

## Advanced Customization
Use the DMS plugin settings to change the Whisper backend, model, output directory, language, prompt context, or translation behavior.

The plugin supports three backend choices:
- `openai-whisper`: default `whisper` command.
- `faster-whisper`: default `whisper-ctranslate2` command. The `faster-whisper` Python package itself is primarily a library; use a compatible CLI wrapper or change the command in settings.
- `whisper.cpp`: default `whisper-cli` command, plus a required local model path. If your build exposes `main` or another binary name, change it in settings.

By default, Whisper auto-detects the spoken language. Common model sizes, ordered by precision and weight, are: `tiny`, `base`, `small`, `medium`, `large`.

If transcription fails, check the last backend error at:
```bash
cat "${XDG_RUNTIME_DIR:-/tmp}/dms-whisper/last-error.log"
```
