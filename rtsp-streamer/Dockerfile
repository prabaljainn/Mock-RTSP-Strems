FROM alpine:3.20

RUN apk add --no-cache ffmpeg

WORKDIR /app

COPY --chmod=0755 stream.sh .

CMD ["./stream.sh"]
