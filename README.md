# kvb-ha-map

Home Assistant Supervisor Add-on: a live map of **KVB** (Kölner
Verkehrs-Betriebe, Cologne public transit) vehicles, plus a stop
departure board and vehicle-history/delay stats — built on top of the
[`kvb-hafas-client`](https://github.com/christoph-teichmeister/kvb-hafas-client)
Python library.

## ⚠️ Unofficial, use at your own risk

This add-on depends entirely on `kvb-hafas-client`, itself an **unofficial**,
reverse-engineered client for KVB's HAFAS backend — not an officially
published API. The same caveats apply here:

- **Not officially released or supported by KVB.**
- Use at your own risk. The underlying endpoint can change or be blocked at
  any time.
- **Do not use commercially.**
- **Respect KVB's rate limits** — this talks to KVB's production
  infrastructure; don't hammer it with requests or run many instances.
- Don't use KVB branding/logos in derived work.
- If in doubt, contact KVB directly and ask for official access.

This add-on adds no authentication, no multi-user accounts and no
notifications — it is a single-user local dashboard, matching the scope of
the source prototype it's built from.

## What it does

- **Live Map** (`map.html`) — all KVB vehicles currently in view, animated
  between polls, with line/route geometry, stop markers and service alerts.
  Ported from `kvb-hafas-client`'s `map_server.py`/`map.html` prototype.
- **Departures** (`departures.html`) — search KVB stops, star favorites, and
  watch a live, auto-refreshing departure board (planned/realtime time,
  delay, platform, cancellations).
- **Dashboard** (`dashboard.html`) — live fleet stats (busiest line, current
  max delay, delayed-vehicle count) and historical stats aggregated from this
  add-on's own vehicle-history database (least-punctual lines, average delay
  per line, punctuality rate).

Unlike the source prototype, this add-on persists every vehicle position it
polls into a local **SQLite** database (`vehicle_observations`), separate
from Home Assistant's own Recorder (which isn't built for this kind of
high-frequency sampling). History sampling reuses whatever the last
`/api/vehicles` poll already fetched — it never makes an extra KVB request
just to keep history.

## Installing as a Home Assistant Add-on

1. In Home Assistant: **Settings → Add-ons → Add-on Store → ⋮ → Repositories**,
   add the URL of this repo (or add it as a local folder under
   `/addons/kvb-ha-map` on the HA host if you're not using a Git repo add-on
   store).
2. Refresh the store, find **KVB Live Map** under "Local add-ons", install it.
3. Configure options (see below), then **Start**. The add-on's panel appears
   in the HA sidebar via Ingress — no exposed port, no separate auth needed.

## Add-on options

| Option | Default | Description |
| --- | --- | --- |
| `history_enabled` | `true` | Persist vehicle observations to SQLite. |
| `history_sample_interval_seconds` | `60` | How often to snapshot the fleet into history. |
| `history_retention_days` | `365` | Delete observations older than this. |
| `history_filter_local_only` | `true` | Only persist KVB tram/bus vehicles, not passing S-Bahn/RE/IC traffic. |
| `vehicle_poll_cache_ttl_seconds` | `15` | Cache TTL for `/api/vehicles`. |
| `alert_cache_ttl_seconds` | `300` | Cache TTL for `/api/alerts`. |
| `default_map_center_lat` / `_lon` | Cologne center | Initial map view. |
| `default_zoom` | `13` | Initial map zoom. |
| `favorite_stop_ids` | `[]` | Stop `ext_id`s shown as favorites on the departures page. |
| `dashboard_refresh_seconds` | `15` | Auto-refresh interval for the dashboard page. |

## Standalone / local development (no Home Assistant)

The server reads the exact same options from environment variables (with the
same defaults) so it also runs directly, outside HA:

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
python3 app/server.py       # http://localhost:8099
```

Env vars mirror the option names above, upper-cased
(`HISTORY_ENABLED`, `VEHICLE_POLL_CACHE_TTL_SECONDS`, `FAVORITE_STOP_IDS` as a
JSON array or comma-separated list, etc.) — see `app/server.py` for the exact
list and defaults.

## Repository layout

```
config.yaml       HA add-on manifest (options schema, ingress config)
Dockerfile         Add-on image build
run.sh             Entrypoint: options.json -> env vars -> server.py
requirements.txt   kvb-hafas-client (from GitHub) + requests
app/
  server.py         stdlib http.server app: vehicle/alert/network/stop APIs,
                     stop search + departures, live/historical stats,
                     HA Ingress-safe (relative URLs throughout)
  history_store.py   SQLite vehicle_observations table + queries
  stats.py            live snapshot stats + delegate to history_store
  is_kvb_local.py      port of map.html's cssClass() bucketing helper
  static/
    index.html, map.html, departures.html, dashboard.html
    vendor/            vendored Leaflet (from kvb-hafas-client)
data/
  rail_geometry.json  OSM-derived rail geometry (from kvb-hafas-client)
```

## License

MIT, matching `kvb-hafas-client`. See [LICENSE](LICENSE).
