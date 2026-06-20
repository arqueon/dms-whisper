#!/bin/bash
PID_FILE="/tmp/dms-whisper-record.pid"
CURRENT_FILE_TRACKER="/tmp/dms-whisper-current.txt"

ACTION="$1"
MODEL="${2:-base}"
OUT_DIR="${3:-$HOME/Documents/Whisper}"
LANGUAGE="${4:-auto}"
TRANSLATE="${5:-no}"

start_recording() {
    if [ -f "$PID_FILE" ]; then
        return
    fi
    
    mkdir -p "$OUT_DIR"
    
    TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
    AUDIO_FILE="$OUT_DIR/Whisper_$TIMESTAMP.wav"
    
    echo "$AUDIO_FILE|$MODEL|$OUT_DIR|$LANGUAGE|$TRANSLATE" > "$CURRENT_FILE_TRACKER"
    
    # Record audio 16kHz, mono
    arecord -f S16_LE -c 1 -r 16000 "$AUDIO_FILE" -q &
    echo $! > "$PID_FILE"
    notify-send "Whisper" "Recording: Whisper_$TIMESTAMP.wav" -i audio-input-microphone
}

stop_recording() {
    if [ ! -f "$PID_FILE" ]; then
        return
    fi
    kill $(cat "$PID_FILE")
    rm "$PID_FILE"
    notify-send "Whisper" "Transcribing..." -i audio-input-microphone
    
    if [ ! -f "$CURRENT_FILE_TRACKER" ]; then
        return
    fi
    
    TRACKER_DATA=$(cat "$CURRENT_FILE_TRACKER")
    rm "$CURRENT_FILE_TRACKER"
    
    # Parse tracker data (format: file|model|outdir|lang|trans)
    IFS='|' read -r AUDIO_FILE R_MODEL R_OUT_DIR R_LANG R_TRANS <<< "$TRACKER_DATA"
    
    CMD="whisper \"$AUDIO_FILE\" --model \"$R_MODEL\" --output_format txt --output_dir \"$R_OUT_DIR\""
    
    if [ "$R_LANG" != "auto" ]; then
        CMD="$CMD --language \"$R_LANG\""
    fi
    
    if [ "$R_TRANS" = "yes" ]; then
        CMD="$CMD --task translate"
    fi
    
    # Run whisper
    eval "$CMD >/dev/null 2>&1"
    
    BASE_NAME=$(basename "$AUDIO_FILE" .wav)
    TXT_FILE="$R_OUT_DIR/$BASE_NAME.txt"
    
    TEXT=$(cat "$TXT_FILE" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    
    if [ -n "$TEXT" ]; then
        echo "$TEXT" | wl-copy
        echo "- **$(date '+%Y-%m-%d %H:%M:%S')** [$BASE_NAME.wav]: $TEXT" >> "$R_OUT_DIR/WhisperNotes.md"
        notify-send "Whisper" "$TEXT" -i edit-paste
    else
        notify-send "Whisper" "No voice detected or an error occurred." -i dialog-error
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
        if [ -f "$PID_FILE" ]; then
            stop_recording
        else
            start_recording
        fi
        ;;
esac
