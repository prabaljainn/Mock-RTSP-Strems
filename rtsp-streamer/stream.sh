#!/bin/sh
LOG_FILE="/app/stream.log"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

VIDEO_FILE=${VIDEO_FILE:-video2.mp4}
STREAM_PATH=${STREAM_PATH:-mystream2}

log "Starting RTSP streamer service..."
log "Using video file: /videos/${VIDEO_FILE}"
sleep 5

STREAM_URL="rtsp://mediamtx:8554/${STREAM_PATH}"
log "Streaming to URL: ${STREAM_URL}"

# -an removes audio; -r 30 enforces 30 fps output
ffmpeg -re -stream_loop -1 \
  -i "/videos/${VIDEO_FILE}" \
  -c:v libx264 -preset ultrafast -tune zerolatency \
  -r 30 \
  -an \
  -f rtsp "${STREAM_URL}" 2>&1 | tee -a "$LOG_FILE"
