#!/bin/bash
PID_FILE="/tmp/dms-whisper-record.pid"
CURRENT_FILE_TRACKER="/tmp/dms-whisper-current.txt"

OUT_DIR="$HOME/Documents/Whisper"
LOG_FILE="$OUT_DIR/WhisperNotes.md"

start_recording() {
    if [ -f "$PID_FILE" ]; then
        return
    fi
    
    mkdir -p "$OUT_DIR"
    
    TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
    AUDIO_FILE="$OUT_DIR/Whisper_$TIMESTAMP.wav"
    
    echo "$AUDIO_FILE" > "$CURRENT_FILE_TRACKER"
    
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
    
    AUDIO_FILE=$(cat "$CURRENT_FILE_TRACKER")
    rm "$CURRENT_FILE_TRACKER"
    
    # Run whisper
    whisper "$AUDIO_FILE" --model base --output_format txt --output_dir "$OUT_DIR" >/dev/null 2>&1
    
    BASE_NAME=$(basename "$AUDIO_FILE" .wav)
    TXT_FILE="$OUT_DIR/$BASE_NAME.txt"
    
    TEXT=$(cat "$TXT_FILE" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    
    if [ -n "$TEXT" ]; then
        echo "$TEXT" | wl-copy
        echo "- **$(date '+%Y-%m-%d %H:%M:%S')** [$BASE_NAME.wav]: $TEXT" >> "$LOG_FILE"
        notify-send "Whisper" "$TEXT" -i edit-paste
    else
        notify-send "Whisper" "No voice detected or an error occurred." -i dialog-error
    fi
}

case "$1" in
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
