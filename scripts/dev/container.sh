#!/usr/bin/env bash
set -euo pipefail
if [[ ! -f /data/sample.sqlite ]]; then
  cp /seed/sample.sqlite /data/sample.sqlite
fi
exec /app/admin_panel-cli start -b 0.0.0.0
