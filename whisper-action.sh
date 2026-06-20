#!/bin/bash
PID_FILE="/tmp/dms-whisper-record.pid"
AUDIO_FILE="/tmp/dms-whisper-record.wav"
LOG_FILE="$HOME/Documents/WhisperNotes.md"

start_recording() {
    if [ -f "$PID_FILE" ]; then
        return
    fi
    # Record audio 16kHz, mono
    arecord -f S16_LE -c 1 -r 16000 "$AUDIO_FILE" -q &
    echo $! > "$PID_FILE"
    notify-send "Whisper" "Recording started..." -i audio-input-microphone
}

stop_recording() {
    if [ ! -f "$PID_FILE" ]; then
        return
    fi
    kill $(cat "$PID_FILE")
    rm "$PID_FILE"
    notify-send "Whisper" "Transcribing..." -i audio-input-microphone
    
    # Run whisper (assumes openai-whisper or whisper.cpp with wrapper is in PATH)
    # Output is directed to /tmp
    whisper "$AUDIO_FILE" --model base --language es --output_format txt --output_dir /tmp >/dev/null 2>&1
    
    TEXT=$(cat "/tmp/dms-whisper-record.txt" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    
    if [ -n "$TEXT" ]; then
        echo "$TEXT" | wl-copy
        echo "- **$(date '+%Y-%m-%d %H:%M:%S')**: $TEXT" >> "$LOG_FILE"
        notify-send "Whisper Transcription" "$TEXT" -i edit-paste
    else
        notify-send "Whisper" "Could not recognize speech." -i dialog-error
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
