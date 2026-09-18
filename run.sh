#!/usr/bin/env bash
# Entrypoint for the HA Supervisor add-on. Reads /data/options.json (written by
# Supervisor from config.yaml's `options`/`schema`) and exports it as env vars
# consumed by app/server.py. Falls back to the same defaults server.py itself
# uses when /data/options.json doesn't exist (e.g. local `docker run` without
# Supervisor, or plain `python3 app/server.py` for standalone dev).
set -euo pipefail

OPTIONS_FILE="/data/options.json"

if [ -f "$OPTIONS_FILE" ]; then
  echo "[run.sh] reading options from ${OPTIONS_FILE}"

  json_get() {
    # $1 = jq filter, $2 = default
    jq -r "$1 // empty" "$OPTIONS_FILE" 2>/dev/null || true
  }

  HISTORY_ENABLED=$(json_get '.history_enabled')
  HISTORY_SAMPLE_INTERVAL_SECONDS=$(json_get '.history_sample_interval_seconds')
  HISTORY_RETENTION_DAYS=$(json_get '.history_retention_days')
  HISTORY_FILTER_LOCAL_ONLY=$(json_get '.history_filter_local_only')
  VEHICLE_POLL_CACHE_TTL_SECONDS=$(json_get '.vehicle_poll_cache_ttl_seconds')
  ALERT_CACHE_TTL_SECONDS=$(json_get '.alert_cache_ttl_seconds')
  DEFAULT_MAP_CENTER_LAT=$(json_get '.default_map_center_lat')
  DEFAULT_MAP_CENTER_LON=$(json_get '.default_map_center_lon')
  DEFAULT_ZOOM=$(json_get '.default_zoom')
  FAVORITE_STOP_IDS=$(jq -c '.favorite_stop_ids // []' "$OPTIONS_FILE" 2>/dev/null || echo '[]')
  DASHBOARD_REFRESH_SECONDS=$(json_get '.dashboard_refresh_seconds')

  export HISTORY_ENABLED HISTORY_SAMPLE_INTERVAL_SECONDS HISTORY_RETENTION_DAYS \
    HISTORY_FILTER_LOCAL_ONLY VEHICLE_POLL_CACHE_TTL_SECONDS ALERT_CACHE_TTL_SECONDS \
    DEFAULT_MAP_CENTER_LAT DEFAULT_MAP_CENTER_LON DEFAULT_ZOOM FAVORITE_STOP_IDS \
    DASHBOARD_REFRESH_SECONDS
else
  echo "[run.sh] ${OPTIONS_FILE} not found — running with server.py built-in defaults (standalone/dev mode)"
fi

export DATA_DIR="${DATA_DIR:-/app/data}"
export PORT="${PORT:-8099}"

echo "[run.sh] starting KVB Live Map server on port ${PORT}"
exec python3 -u /app/app/server.py
