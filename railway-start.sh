#!/bin/sh
# Railway volumes are mounted root-owned: hand /data to the node user (uid 1000), then run the upstream
# start command as that user (exec, so SIGTERM reaches the server and it releases its scheduler lease).
set -e
mkdir -p "${DATA_DIR:-/data}"
chown -R node:node "${DATA_DIR:-/data}"
exec setpriv --reuid=node --regid=node --init-groups node scripts/serve.mjs start
