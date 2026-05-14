# JELE Freshy แตงโม 2026 — KOL Marketing Dashboard

Live: https://araveevong-pixel.github.io/jele-freshy-watermelon-dashboard/

## Stack
- Static HTML + Chart.js (loaded via CDN)
- yt-dlp scraper (runs every 30 min via GitHub Actions)
- Cookies authentication for TikTok sensitive content gate
- Manual override for Facebook KOL

## KOLs
7 KOLs across 3 categories:
- **Page FB** (1) — Facebook (manual override)
- **Mom And Baby** (3) — TikTok
- **สายชอบของน่ารัก/Note** (3) — TikTok

## Auto-update
GitHub Actions cron `*/30 * * * *` — uses TIKTOK_COOKIES secret to bypass content gate.

Generated from skill `kol-dashboard-generator`.
