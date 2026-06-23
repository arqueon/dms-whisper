#!/bin/bash

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}/dms-whisper"
PID_FILE="$RUNTIME_DIR/record.pid"
CURRENT_FILE_TRACKER="$RUNTIME_DIR/current.env"
LOG_FILE="$RUNTIME_DIR/last-error.log"
FASTER_WHISPER_MODE="cli"

ACTION="$1"
BACKEND="${2:-openai-whisper}"
MODEL="${3:-base}"
OUT_DIR="${4:-$HOME/Documents/Whisper}"
LANGUAGE="${5:-auto}"
TRANSLATE="${6:-no}"
INITIAL_PROMPT="${7:-}"
OPENAI_WHISPER_COMMAND="${8:-whisper}"
FASTER_WHISPER_COMMAND="${9:-whisper-ctranslate2}"
WHISPER_CPP_COMMAND="${10:-whisper-cli}"
WHISPER_CPP_MODEL_PATH="${11:-}"

notify() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "$@"
    fi
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        notify "Whisper" "Missing dependency: $1" -i dialog-error
        exit 1
    fi
}

require_backend_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        notify "Whisper" "Missing backend command: $1" -i dialog-error
        return 1
    fi
}

resolve_faster_whisper_command() {
    if command -v "$FASTER_WHISPER_COMMAND" >/dev/null 2>&1; then
        FASTER_WHISPER_MODE="cli"
        return 0
    fi

    if [ "$FASTER_WHISPER_COMMAND" = "faster-whisper" ] && command -v whisper-ctranslate2 >/dev/null 2>&1; then
        FASTER_WHISPER_COMMAND="whisper-ctranslate2"
        FASTER_WHISPER_MODE="cli"
        return 0
    fi

    if python3 -c "import faster_whisper" >/dev/null 2>&1; then
        FASTER_WHISPER_MODE="python"
        return 0
    fi

    notify "Whisper" "Missing faster-whisper backend. Install whisper-ctranslate2 or the faster-whisper Python package." -i dialog-error
    return 1
}

transcribe_with_faster_whisper_python() {
    python3 - "$AUDIO_FILE" "$MODEL" "$OUT_DIR" "$BASE_NAME" "$LANGUAGE" "$TRANSLATE" "$INITIAL_PROMPT" <<'PY'
import sys
from pathlib import Path

from faster_whisper import WhisperModel

audio_file, model_name, out_dir, base_name, language, translate, initial_prompt = sys.argv[1:]

options = {}
if language != "auto":
    options["language"] = language
if translate == "yes":
    options["task"] = "translate"
if initial_prompt:
    options["initial_prompt"] = initial_prompt

model = WhisperModel(model_name, device="auto", compute_type="default")
segments, _ = model.transcribe(audio_file, **options)

out_path = Path(out_dir) / f"{base_name}.txt"
with out_path.open("w", encoding="utf-8") as handle:
    for segment in segments:
        text = segment.text.strip()
        if text:
            handle.write(text + "\n")
PY
}

is_recording() {
    local pid

    [ -f "$PID_FILE" ] || return 1
    pid=$(cat "$PID_FILE" 2>/dev/null) || return 1
    [ -n "$pid" ] || return 1
    kill -0 "$pid" 2>/dev/null
}

cleanup_state() {
    rm -f "$PID_FILE" "$CURRENT_FILE_TRACKER"
}

append_common_cli_options() {
    if [ "$LANGUAGE" != "auto" ]; then
        cmd+=(--language "$LANGUAGE")
    fi

    if [ "$TRANSLATE" = "yes" ]; then
        cmd+=(--task translate)
    fi

    if [ -n "$INITIAL_PROMPT" ]; then
        cmd+=(--initial_prompt "$INITIAL_PROMPT")
    fi
}

build_transcription_command() {
    local output_prefix

    case "$BACKEND" in
        openai-whisper)
            require_backend_command "$OPENAI_WHISPER_COMMAND" || return 1
            cmd=("$OPENAI_WHISPER_COMMAND" "$AUDIO_FILE" --model "$MODEL" --output_format txt --output_dir "$OUT_DIR")
            append_common_cli_options
            TXT_FILE="$OUT_DIR/$BASE_NAME.txt"
            ;;
        faster-whisper)
            resolve_faster_whisper_command || return 1
            if [ "$FASTER_WHISPER_MODE" = "cli" ]; then
                cmd=("$FASTER_WHISPER_COMMAND" "$AUDIO_FILE" --model "$MODEL" --output_format txt --output_dir "$OUT_DIR")
                append_common_cli_options
            else
                cmd=(transcribe_with_faster_whisper_python)
            fi
            TXT_FILE="$OUT_DIR/$BASE_NAME.txt"
            ;;
        whisper-cpp)
            require_backend_command "$WHISPER_CPP_COMMAND" || return 1

            if [ -z "$WHISPER_CPP_MODEL_PATH" ]; then
                notify "Whisper" "whisper.cpp model path is required." -i dialog-error
                return 1
            fi

            if [ ! -f "$WHISPER_CPP_MODEL_PATH" ]; then
                notify "Whisper" "whisper.cpp model file was not found." -i dialog-error
                return 1
            fi

            output_prefix="$OUT_DIR/$BASE_NAME"
            cmd=("$WHISPER_CPP_COMMAND" -m "$WHISPER_CPP_MODEL_PATH" -f "$AUDIO_FILE" -otxt -of "$output_prefix")

            # whisper.cpp defaults to English when -l is omitted, so always pass
            # the language explicitly ("auto" triggers its own auto-detection).
            cmd+=(-l "$LANGUAGE")

            if [ "$TRANSLATE" = "yes" ]; then
                cmd+=(-tr)
            fi

            if [ -n "$INITIAL_PROMPT" ]; then
                cmd+=(--prompt "$INITIAL_PROMPT")
            fi

            TXT_FILE="$output_prefix.txt"
            ;;
        *)
            notify "Whisper" "Unsupported backend: $BACKEND" -i dialog-error
            return 1
            ;;
    esac
}

start_recording() {
    mkdir -p "$RUNTIME_DIR"

    if is_recording; then
        notify "Whisper" "Recording is already active." -i audio-input-microphone
        return
    fi

    cleanup_state
    require_command arecord
    mkdir -p "$OUT_DIR"

    TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
    AUDIO_FILE="$OUT_DIR/Whisper_$TIMESTAMP.wav"

    printf '%s\0' \
        "$AUDIO_FILE" \
        "$BACKEND" \
        "$MODEL" \
        "$OUT_DIR" \
        "$LANGUAGE" \
        "$TRANSLATE" \
        "$INITIAL_PROMPT" \
        "$OPENAI_WHISPER_COMMAND" \
        "$FASTER_WHISPER_COMMAND" \
        "$WHISPER_CPP_COMMAND" \
        "$WHISPER_CPP_MODEL_PATH" > "$CURRENT_FILE_TRACKER"

    # Record audio 16kHz, mono
    arecord -f S16_LE -c 1 -r 16000 "$AUDIO_FILE" -q &
    echo $! > "$PID_FILE"
    notify "Whisper" "Recording: Whisper_$TIMESTAMP.wav" -i audio-input-microphone
}

stop_recording() {
    local pid cmd text
    local tracker=()

    if ! is_recording; then
        cleanup_state
        return
    fi

    pid=$(cat "$PID_FILE")
    kill "$pid" 2>/dev/null || true
    for _ in {1..20}; do
        kill -0 "$pid" 2>/dev/null || break
        sleep 0.1
    done
    if kill -0 "$pid" 2>/dev/null; then
        kill -KILL "$pid" 2>/dev/null || true
    fi
    rm -f "$PID_FILE"
    notify "Whisper" "Transcribing..." -i audio-input-microphone

    if [ ! -f "$CURRENT_FILE_TRACKER" ]; then
        notify "Whisper" "Recording metadata was not found." -i dialog-error
        return
    fi

    readarray -d '' -t tracker < "$CURRENT_FILE_TRACKER"
    rm -f "$CURRENT_FILE_TRACKER"

    if [ "${#tracker[@]}" -lt 11 ]; then
        notify "Whisper" "Recording metadata is incomplete." -i dialog-error
        return 1
    fi

    AUDIO_FILE="${tracker[0]}"
    BACKEND="${tracker[1]}"
    MODEL="${tracker[2]}"
    OUT_DIR="${tracker[3]}"
    LANGUAGE="${tracker[4]}"
    TRANSLATE="${tracker[5]}"
    INITIAL_PROMPT="${tracker[6]}"
    OPENAI_WHISPER_COMMAND="${tracker[7]}"
    FASTER_WHISPER_COMMAND="${tracker[8]}"
    WHISPER_CPP_COMMAND="${tracker[9]}"
    WHISPER_CPP_MODEL_PATH="${tracker[10]}"

    require_command wl-copy

    BASE_NAME=$(basename "$AUDIO_FILE" .wav)

    if ! build_transcription_command; then
        return 1
    fi

    # Run whisper
    if ! "${cmd[@]}" >"$LOG_FILE" 2>&1; then
        notify "Whisper" "Transcription failed. See $LOG_FILE" -i dialog-error
        return 1
    fi

    if [ ! -f "$TXT_FILE" ]; then
        notify "Whisper" "Transcription output was not created." -i dialog-error
        return 1
    fi

    text=$(sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' "$TXT_FILE")

    if [ -n "$text" ]; then
        printf '%s\n' "$text" | wl-copy
        printf -- '- **%s** [%s.wav, %s]: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$BASE_NAME" "$BACKEND" "$text" >> "$OUT_DIR/WhisperNotes.md"
        notify "Whisper" "$text" -i edit-paste
    else
        notify "Whisper" "No voice detected or an error occurred." -i dialog-error
    fi
}

case "$ACTION" in
    start)
        start_recording
        ;;
    stop)
        stop_recording
        ;;
    toggle)
        if is_recording; then
            stop_recording
        else
            start_recording
        fi
        ;;
    status)
        is_recording
        ;;
esac
