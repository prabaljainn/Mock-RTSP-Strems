#!/bin/sh
LOG_FILE="/app/stream.log"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Use provided env variables or defaults
VIDEO_FILE=${VIDEO_FILE:-example_stream.mp4}
STREAM_PATH=${STREAM_PATH:-mystream}

log "Starting RTSP streamer service..."
log "Using video file: /videos/${VIDEO_FILE}"
log "Waiting 5 seconds for the RTSP server to become available..."
sleep 5

STREAM_URL="rtsp://rtsp-server:8554/${STREAM_PATH}"
log "Streaming URL: ${STREAM_URL}"

# Loop the video indefinitely and pipe all output to log
ffmpeg -re -stream_loop -1 -i "/videos/${VIDEO_FILE}" -c copy -f rtsp "${STREAM_URL}" 2>&1 | tee -a $LOG_FILE
