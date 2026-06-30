# BagelTracker

## Crontab Daily
```
@daily cd "/home/bandtracker/deployed_application/bagel_tracker/"; MIX_ENV=prod mix run -e UpdateSiteData.start_data_update
```

## To buid the image
```
docker build -t bagel-tracker .
```

## To deploy the image
- See [Digital Ocean's Doc](https://docs.digitalocean.com/products/container-registry/quickstart/#push-to-your-registry) on deployment.

The basic idea is to do push to docker like:

```docker push registry.digitalocean.com/<my-registry>/<my-image>```

In our case:

Tag the image we just build:
```docker tag bagel-tracker:latest registry.digitalocean.com/docker-apps/bagel-tracker:latest```

Then push
```docker push registry.digitalocean.com/docker-apps/bagel-tracker:latest```

## To pull production database into local dev

Requires the `BAGEL_DB_PASSWORD` for the production DB and PostgreSQL 16 client tools (`brew install postgresql@16`).

Dump from production:
```bash
PGPASSWORD="<bagel_db_password>" PGSSLMODE=require /opt/homebrew/opt/postgresql@16/bin/pg_dump \
  -h db-postgresql-nyc3-53985-do-user-1826027-0.b.db.ondigitalocean.com \
  -p 25060 \
  -U concert_finder \
  -d bagel_tracker_prod \
  --no-privileges --no-owner \
  -c \
  > datadump.sql
```

Create the local dev database if it doesn't exist:
```bash
docker exec postgresqldb psql -U postgres -c 'CREATE DATABASE bagel_tracker_dev;'
```

Restore into local dev:
```bash
psql -U postgres -h 127.0.0.1 -d bagel_tracker_dev < datadump.sql
```

## To run a data update locally

Start the REPL:
```bash
iex -S mix
```

Run the full pipeline:
```elixir
UpdateSiteData.start_data_update()
```

Or run steps individually:
```elixir
BagelTracker.Artist.process_new_artists()   # load artists from bagel_radio_band_list.txt
BagelTracker.Artist.check_remote_data()     # enrich artists with Bands in Town metadata
BagelTracker.Event.import_remote_events()   # import upcoming events
BagelTracker.Statistic.update_counts()      # refresh artist/event counts
```

To clear all artist and event data:
```elixir
UpdateSiteData.clear_transient_data()
```