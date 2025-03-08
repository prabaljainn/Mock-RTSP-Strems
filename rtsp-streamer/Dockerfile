FROM jrottenberg/ffmpeg:4.4-alpine

WORKDIR /app

# Override the default 'ffmpeg' entrypoint from the base image
ENTRYPOINT []

# Copy in our custom streaming script
COPY stream.sh .
RUN chmod +x stream.sh

# Let Docker run this script by default
CMD ["./stream.sh"]
