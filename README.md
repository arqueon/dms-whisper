# Dank Material Shell (DMS) Whisper Plugin

A [Dank Material Shell](https://github.com/AvengeMedia/DankMaterialShell) plugin that brings the power of **Whisper** AI transcription directly to your status bar.

Record voice notes with a single click (or via IPC keybinds), have them transcribed in the background using Whisper, copied automatically to your clipboard, and cleanly backed up locally (both the audio and the generated text).

## Features

- **Minimalist Design**: A discreet microphone icon (`mic_none`) that turns red (`mic`) when recording, seamlessly integrating with your DMS theme.
- **Silent Workflow**: Notifies you of recording start and successful transcription using native system notifications.
- **IPC Controlled**: Easily integrate it into your window manager (Hyprland, Niri, Sway, etc.) via global keybinds.
- **Organized History**: Saves separate timestamped audio and text files, and maintains a centralized chronological markdown log.

---

## Requirements and Dependencies

Before installing the plugin, ensure you have the necessary recording utilities, clipboard managers, and the Whisper engine installed on your system.

On **Arch Linux** based distributions (CachyOS, EndeavourOS, etc.):

1. **Install system utilities:**
   ```bash
   sudo pacman -S alsa-utils wl-clipboard
   ```
   *(Note: `alsa-utils` provides the `arecord` tool, and `wl-clipboard` provides `wl-copy`)*

2. **Install Whisper (OpenAI):**
   The cleanest method is using `pipx` to make the `whisper` executable available globally without creating package conflicts:
   ```bash
   sudo pacman -S python-pipx
   pipx install openai-whisper
   ```
   *(Make sure `~/.local/bin` is in your `$PATH` environment variable)*

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
Simply left-click the microphone icon located on your top or vertical panel. The icon will change to red to indicate that recording is active. Click it again to stop capturing audio and start the automatic transcription.

### Via IPC Commands (Keybinds)
The plugin registers a command in the Dank Material Shell IPC bus that allows you to toggle the recording state without relying on mouse clicks.

You can bind this command in your compositor's configuration file (e.g., in `hyprland.conf`):

```bash
# Bind to SUPER + W
bind = SUPER, W, exec, dms ipc whisper toggle
```

### Where are my notes and audio files saved?
The plugin automatically organizes everything in your Documents folder:
- **Base Directory:** `~/Documents/Whisper/`
- **Original Audio:** `Whisper_YYYY-MM-DD_HH-MM-SS.wav`
- **Raw Extracted Text:** `Whisper_YYYY-MM-DD_HH-MM-SS.txt`
- **Global Record (The Log):** `WhisperNotes.md`. This is a living document where all your transcriptions are sequentially appended as bullet points with their exact date and time.

---

## Advanced Customization
If you wish to change the default model, specify a strict language, or change the save path, you can edit the following variables by opening the `whisper-action.sh` file:

```bash
OUT_DIR="$HOME/Documents/Whisper"
# ...
whisper "$AUDIO_FILE" --model base --output_format txt --output_dir "$OUT_DIR" >/dev/null 2>&1
```

*(By default, Whisper will auto-detect the spoken language. The available models in OpenAI Whisper, ordered by precision and weight, are: `tiny`, `base`, `small`, `medium`, `large`)*
