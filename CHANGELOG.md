# Changelog

All notable changes to this add-on are documented here. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [2026.9.1] - 2026-09-19

### Changed
- Synced bundled UI/library to kvb-hafas-client@be12938.

## [2026.9.0] - 2026-09-19

### Changed
- Switched versioning scheme from SemVer to CalVer (`yyyy.mm.patch`), to
  match the companion `kvb-hafas-client` repo. The auto-sync workflow now
  resets `patch` to `0` on month rollover instead of incrementing an
  arbitrary third SemVer field forever.

## [0.1.6] - 2026-09-18

### Changed
- Synced bundled UI/library to kvb-hafas-client@63c2961.

## [0.1.5] - 2026-09-18

### Changed
- Web UI (HTML pages, `shared.css`, vendored Leaflet, the `is_kvb_local`
  helper) moved out of this repo into `kvb-hafas-client`'s `kvb_hafas.webui`
  package, so it lives in one place instead of drifting between two repos.
  This repo is now a thin HA add-on shell: `server.py` serves those
  pages/assets via `importlib.resources` at runtime instead of shipping its
  own `app/static/` copy.

## [0.1.4] - 2026-09-18

### Fixed
- Surface a banner on the map when tiles fail to load, after Wikimedia
  started rejecting this add-on's tile requests (403, "restricted to
  Wikimedia and affiliated sites only").

### Docs
- Rewrote the README's tile-provider section to document Stadia Maps' free
  tier (with API key) as the working setup, dropping the history of
  Wikimedia/OSM/CARTO tile blocks.

## [0.1.3] - 2026-09-18

### Added
- `/api/stops/details` endpoint.

### Changed
- Redesigned the UI: inline styles extracted into a shared `shared.css`,
  dashboard/departures/index pages reworked with a new layout and German
  copy, map tiles switched to Wikimedia OSM (CARTO Voyager started requiring
  an API key).

### Fixed
- Favorite stop names now resolve via `/api/stops/details` instead of
  showing the raw `ext_id`.
- Departure-list click handler now covers the whole row instead of only the
  narrow name span (the surrounding whitespace was a dead click zone).
- Service-alert ticker scroll duration now scales with text length instead
  of a fixed 16s.
- Departure board now renders one board per platform instead of one mixed
  list.
- Fixed ETA calculation: `minutesUntil()` wrongly required 8+ character
  HAFAS time strings, but real HAFAS strings are 6 characters ("HHMMSS") —
  every row showed "-" instead of a countdown.

## [0.1.2] - 2026-09-18

### Changed
- Default map tile source switched from raw `tile.openstreetmap.org` to
  CARTO's free Voyager basemap — OSM's tile usage policy forbids embedding
  their tile servers in software distributed to many independently-run
  machines, which is exactly this add-on's install pattern. `tile_url` and
  `tile_attribution` options let users point at a different provider.
- Stop search results now show each stop's `ext_id`, since
  `favorite_stop_ids` needs the opaque HAFAS id (not the stop name) and
  there was previously no way to discover it in the UI.

## [0.1.1] - 2026-09-18

### Fixed
- Force unbuffered stdout (`python3 -u`) so startup/status logs actually
  appear under HA's s6-overlay base image, where the Dockerfile's
  `PYTHONUNBUFFERED` env never reached the CMD process and Python's default
  block-buffering on non-tty stdout silently swallowed `print()` calls.

## [0.1.0] - 2026-09-18

### Added
- Initial release: Home Assistant Supervisor add-on (Docker + Ingress)
  wrapping `kvb-hafas-client` — live vehicle map (ported from the source
  repo's `map_server.py`/`map.html` prototype), stop search + live
  departure board, and a stats dashboard backed by a SQLite vehicle-history
  store (`vehicle_observations`, sampled from the same `/api/vehicles`
  polls, no extra KVB requests).
- All options (history sampling/retention, cache TTLs, map defaults,
  favorite stops) exposed via `config.yaml`'s schema and read through env
  vars, with matching defaults so the server also runs standalone for local
  dev.
- Switched dependency management to `uv` (`pyproject.toml` + `uv.lock`)
  instead of `requirements.txt`/pip.
- Added `repository.yaml` and `build.yaml` (per-arch `BUILD_FROM` base
  images, dropped unsupported `i386`), required for Home Assistant's add-on
  repository validation.
