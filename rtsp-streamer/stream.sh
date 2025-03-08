#!/bin/sh
LOG_FILE="/app/stream.log"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# ENV variables or defaults. Adjust as needed.
VIDEO_FILE_1=${VIDEO_FILE_1:-video1.mp4}
VIDEO_FILE_2=${VIDEO_FILE_2:-video2.mp4}
VIDEO_FILE_3=${VIDEO_FILE_3:-video3.mp4}

STREAM_PATH_1=${STREAM_PATH_1:-mystream1}
STREAM_PATH_2=${STREAM_PATH_2:-mystream2}
STREAM_PATH_3=${STREAM_PATH_3:-mystream3}

# Wait for the RTSP server to come up
log "Starting RTSP streamer service..."
sleep 5

# A helper function to start one FFmpeg stream in the background
start_stream() {
  local inputFile="$1"
  local pathName="$2"
  local fps=30  # or pass as a parameter if you want it adjustable

  STREAM_URL="rtsp://mediamtx:8554/${pathName}"
  log "Launching FFmpeg for file '${inputFile}' -> ${STREAM_URL}"

  ffmpeg -re -stream_loop -1 \
    -i "/videos/${inputFile}" \
    -c:v libx264 -preset ultrafast -tune zerolatency \
    -r $fps \
    -an \
    -f rtsp "${STREAM_URL}" \
    2>&1 | tee -a "$LOG_FILE" &
}

# Start each stream in the background
start_stream "$VIDEO_FILE_1" "$STREAM_PATH_1"
start_stream "$VIDEO_FILE_2" "$STREAM_PATH_2"
start_stream "$VIDEO_FILE_3" "$STREAM_PATH_3"

# Wait for all background FFmpeg processes to exit before this script ends
wait
