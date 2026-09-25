# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

BagelTracker is a Phoenix 1.5 / Elixir app that tracks upcoming concerts for artists played on SomaFM's Bagel Radio station. It scrapes the SomaFM artist list, looks up each artist via the Bands in Town API, imports their upcoming events, then lets users search for concerts near a location.

## Dev environment

The app runs locally without Docker — you need Postgres running and the dev database set up:

```bash
mix deps.get
mix ecto.setup        # create + migrate + seed
mix phx.server        # starts on port 4000
```

DB config (dev): `postgres`/`postgres` @ `0.0.0.0:5432`, database `bagel_tracker_dev`.

Assets use webpack:
```bash
cd assets && npm install && npm run watch
```

## Common commands

```bash
mix test                          # run all tests (auto-creates/migrates test DB)
mix test test/path/to/file_test.exs  # run a single test file
mix ecto.migrate                  # run pending migrations
mix ecto.reset                    # drop, recreate, migrate, seed
```

## Production build & deploy

```bash
make build                        # builds Docker image tagged bagel-tracker:latest
make run                          # runs it locally on port 4000
# Deploy to DO Container Registry:
docker tag bagel-tracker:latest registry.digitalocean.com/docker-apps/bagel-tracker:latest
docker push registry.digitalocean.com/docker-apps/bagel-tracker:latest
```

Cron (production) runs the full pipeline daily: `MIX_ENV=prod mix run -e UpdateSiteData.start_data_update`.

## Pulling production data into local dev

Requires `BAGEL_DB_PASSWORD` and PostgreSQL 16 client tools (`brew install postgresql@16`):

```bash
PGPASSWORD="<bagel_db_password>" PGSSLMODE=require /opt/homebrew/opt/postgresql@16/bin/pg_dump \
  -h db-postgresql-nyc3-53985-do-user-1826027-0.b.db.ondigitalocean.com -p 25060 \
  -U concert_finder -d bagel_tracker_prod --no-privileges --no-owner -c > datadump.sql

docker exec postgresqldb psql -U postgres -c 'CREATE DATABASE bagel_tracker_dev;'  # if it doesn't exist
psql -U postgres -h 127.0.0.1 -d bagel_tracker_dev < datadump.sql
```

## Data pipeline

The full data refresh pipeline is triggered manually or via cron:

```elixir
# In iex -S mix (with BAGEL_DB_PASSWORD set in env):
BagelTracker.Artist.process_new_artists()   # reads bagel_radio_band_list.txt → upserts artists
BagelTracker.Artist.check_remote_data()     # enriches artists with Bands in Town metadata
BagelTracker.Event.import_remote_events()   # imports upcoming events for all known artists
BagelTracker.Statistic.update_counts()      # refreshes artist/event count stats
```

`UpdateSiteData.start_data_update/0` chains all four steps — this is what the crontab calls.

## Architecture

- **`lib/bagel_tracker/`** — core domain logic (no Phoenix)
  - `FetchRemoteData` — scrapes SomaFM artist list HTML; deduplicates by MD5 hash into `raw_data_entries`
  - `ProcessRemoteData` — parses raw HTML into `{artist, play_count}` tuples; upserts `Artist` records
  - `BandsInTownAPI` — wraps the Bands in Town REST API (artist info + events); API key is hardcoded
  - `Artist` — Ecto schema; `check_remote_data/0` fills in BIT metadata for artists missing `bit_id`
  - `Event` — Ecto schema; `import_remote_events/0` fetches, stages, and swaps in fresh events using `is_active` (see below)
  - `Venue` — belongs to Event (one-to-one); stores lat/lng for distance filtering
  - `GeoLocation` — logs user search locations (via Google Geocoding API)
  - `Statistic` — simple key/value counts updated after each pipeline run
  - `UpdateSiteData` — orchestration entry point

- **`lib/bagel_tracker_web/`** — Phoenix web layer
  - Single controller (`PageController`) with routes: `/` (index), `/process_search` (redirect), `/fetch_concerts/:location/:range` (results), `/test_locations` (dev helper)
  - Concert search geocodes the input via `GoogleGeocodingApi`, then filters events by great-circle distance using the `distance` library

## Key schema relationships

```
Artist -< Event >- Venue
Artist.bit_id: unique (different band-list names can resolve to the same BIT artist; only the first gets the bit_id)
Event.is_active: false = staged by an in-progress import, true = live on the site
```

## Event import (staged swap)

`import_remote_events/0`: delete leftover inactive events (from a crashed run) → insert every artist's events with `is_active: false` (a failure for one artist is logged and skipped) → in one transaction, delete the old active events + their venues and flip the staged ones to active. A crash mid-run leaves the previous data live.

## External dependencies

- **Bands in Town API** — API key hardcoded in `BandsInTownAPI` (`@api_key`)
- **Google Geocoding API** — the `google_geocoding_api` hex dep (module `GoogleGeocodingApi`, used by `PageController`), key configured via `config :google_geocoding_api` in `config/config.exs`. Note: `lib/bagel_tracker/geo_code_a_p_i.ex` (module `GeoCodeAPI`, reads `GEOAPI_KEY` env var) is a separate, unused implementation of the same idea — don't confuse the two.
- **SomaFM** — `http://somafm.com/bagel/allartists.inc` (plain HTTP, parsed with Floki)
- **`bagel_radio_band_list.txt`** — local file listing band names; read by `FetchRemoteData.read_band_list_file/0`

## Dead code

- `BagelTracker.Offer` (schema + `offers` migration) has no references anywhere else in the app — likely vestigial.
