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

# If your service is named 'mediamtx', then:
STREAM_URL="rtsp://mediamtx:8554/${STREAM_PATH}"
log "Streaming to URL: ${STREAM_URL}"

# Re-encode the video from AV1 to H.264, audio to AAC:
ffmpeg -re -stream_loop -1 \
  -i "/videos/${VIDEO_FILE}" \
  -c:v libx264 -preset ultrafast -tune zerolatency \
  -c:a aac -ar 44100 \
  -f rtsp "${STREAM_URL}" 2>&1 | tee -a "$LOG_FILE"
