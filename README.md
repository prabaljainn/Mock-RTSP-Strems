# Mock RTSP Streams

A tiny Docker Compose setup that publishes 3 looping mock video streams over **RTSP**, **HLS**, and **WebRTC** — useful for testing video pipelines, NVR/VMS software, ML inference services, or anything that consumes an RTSP feed.

Built on [bluenviron/mediamtx](https://github.com/bluenviron/mediamtx) + ffmpeg.

---

## Quick start (local)

```bash
git clone https://github.com/prabaljainn/Mock-RTSP-Strems.git
cd Mock-RTSP-Strems
docker compose up -d
```

That's it. Streams are now live at:

| Protocol | URL | Notes |
|---|---|---|
| **RTSP** | `rtsp://localhost:8554/stream1` | For VLC, ffplay, OpenCV, NVRs |
| **HLS** | `http://localhost:8888/stream1` | Plays in any browser |
| **WebRTC** | `http://localhost:8889/stream1` | Lowest latency, browser only |

Replace `stream1` with `stream2` or `stream3` for the other two feeds.

**Test it:**
```bash
ffplay rtsp://localhost:8554/stream1
# or open http://localhost:8888/stream1 in a browser
```

**Stop it:**
```bash
docker compose down
```

---

## Deploy to a server

Anywhere that can run Docker and expose TCP/8554 will work. Cheapest reliable options:

- **Hetzner CX22** — €4/mo, 2 vCPU / 4 GB (recommended)
- **DigitalOcean** — $6/mo basic droplet
- **Vultr / Linode / Oracle Free Tier** — similar

> Most "easy" PaaS platforms (Vercel, Netlify, Render free, Cloudflare Pages) **won't work** — RTSP isn't HTTP and they only proxy HTTP traffic. You need a VM with raw TCP access.

### Steps

1. **Provision a VPS** (Ubuntu 24.04). Note the public IP.

2. **Install Docker:**
   ```bash
   curl -fsSL https://get.docker.com | sh
   ```

3. **Open firewall ports:**
   ```bash
   ufw allow 8554/tcp    # RTSP
   ufw allow 8888/tcp    # HLS
   ufw allow 8889/tcp    # WebRTC signaling
   ufw allow 8189/udp    # WebRTC media
   ```

4. **Clone and run:**
   ```bash
   git clone https://github.com/prabaljainn/Mock-RTSP-Strems.git
   cd Mock-RTSP-Strems
   docker compose pull        # pulls prebuilt streamer image from GHCR
   docker compose up -d
   ```

5. **Connect from anywhere:**
   ```
   rtsp://<server-ip>:8554/stream1
   ```

### Optional: domain name

Buy a domain (Namecheap, Porkbun, Cloudflare Registrar — ~$10/yr), then add an `A` record:

```
stream.yourdomain.com  →  <server-ip>
```

Streams are then available at `rtsp://stream.yourdomain.com:8554/stream1` etc. You don't *need* a domain — IP works fine — it just makes the URL prettier and lets you migrate servers without breaking clients.

---

## Resource budget

| Streams | CPU (re-encode) | RAM | Bandwidth (per active viewer) |
|---|---|---|---|
| 1 | ~0.15–0.30 vCPU | ~120 MB | ~1–4 Mbps |
| 2 | ~0.30–0.60 vCPU | ~170 MB | ~1–4 Mbps each |
| 3 | ~0.45–0.90 vCPU | ~220 MB | ~1–4 Mbps each |

Add ~50 MB RAM for mediamtx. A $4/mo VPS handles all 3 streams + dozens of viewers easily.

**Performance tip:** the source mp4s are already h264, so the re-encode in `stream.sh` is wasteful. Change `-c:v libx264 -preset ultrafast -tune zerolatency` to `-c:v copy` and CPU drops to near-zero.

---

## Customize

### Use your own videos

Drop `.mp4` files into `assets/mock-videos/`, then edit `docker-compose.yml`:

```yaml
environment:
  - VIDEO_FILE_1=my-video.mp4
  - STREAM_PATH_1=mystream
```

### Run fewer/more streams

Edit `docker-compose.yml` and `rtsp-streamer/stream.sh` — the script currently hardcodes 3 streams. Comment out the `start_stream` lines you don't need.

### Authentication

By default mediamtx allows publish/read from anywhere with no auth. To add auth, mount a config file — see [mediamtx config docs](https://github.com/bluenviron/mediamtx#configuration).

---

## Troubleshooting

**Stream URL works locally but not from outside the server**
→ Check firewall (`ufw status`). Cloud providers often have a separate security group / firewall layer (DigitalOcean, AWS, GCP) — open 8554/tcp there too.

**Container is "up" but no stream**
→ `docker compose logs rtsp-streamer` — ffmpeg may have failed to find the input file or connect to mediamtx.

**High CPU**
→ Switch to `-c:v copy` in `stream.sh` (see Performance tip above).

**Browser can't play HLS**
→ HLS needs a few seconds to buffer. Try `http://<server>:8888/stream1` and wait 5–10 seconds.

---

## What's in here

```
.
├── docker-compose.yml        # mediamtx + streamer
├── rtsp-streamer/
│   ├── Dockerfile            # ffmpeg-alpine
│   └── stream.sh             # spawns 3 ffmpeg loops
├── assets/mock-videos/       # 3 sample mp4s
└── .github/workflows/        # builds & pushes streamer image to GHCR
```

## License

See `LICENSE`.
