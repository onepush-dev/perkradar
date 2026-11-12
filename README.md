# PerkRadar — self-hosted deal/perk feed aggregator with search, filters, favourites and "claimed" tracking. Deploy on Railway with one click.

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.com/deploy/WlJLKB)

[PerkRadar](https://github.com/luobinger/PerkRadar) (MIT, by luobinger) polls a fixed set of public RSS, Atom, JSON and Markdown
deal sources on a schedule, stores titles, links and short summaries in one SQLite file, and gives you a web board to search,
filter by source/category, favourite items and mark them claimed. (The UI is in Chinese.)

This repo builds upstream commit `92c68cb` with upstream's own Dockerfile steps, app files unmodified, as
`ghcr.io/onepush-dev/perkradar:92c68cb`. Railway-only changes: listens on 8080, `PERKRADAR_SECURE_COOKIE=1`,
`DATA_DIR=/data`, and a start script that chowns the Railway volume and drops to the `node` user.

## What the template sets up
- One service `perkradar` on port 8080 with a public domain and a health check on `/login`
- A volume at `/data` (`deals.db` SQLite)
- `PERKRADAR_ACCESS_TOKEN`: a generated 48-character access token. Copy it from the service Variables tab and paste it on `/login`
  (8-hour signed session). Scripts can use `Authorization: Bearer <token>` (e.g. `/api/health`).

## Optional
- `JINA_API_KEY`: Jina credential used for the LINUX DO source (anonymous requests may be rate-limited).

## Notes
- Single instance only (SQLite + in-process scheduler). To sign out every session, change the token and redeploy.
- Items come from public feeds and are not verified deals; always check the original post.
