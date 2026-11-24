#!/bin/sh
# Grist wrapper entrypoint for Railway.
#
# - Derives APP_HOME_URL from the live public domain so links, forms
#   and embeds resolve behind the Railway proxy. Only set when the
#   deployer has not set one already, and only when a public domain
#   exists yet (a baked template expression would resolve to a bare
#   https:// on first deploy and break Grist's base URL).
# - Hands off to the upstream entrypoint, which chowns /persist to the
#   grist user, de-elevates from root, and execs the server via tini.
#   GRIST reads $PORT directly (Railway injects it); no port mapping
#   is needed here.
set -eu

if [ -z "${APP_HOME_URL:-}" ] && [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]; then
  export APP_HOME_URL="https://${RAILWAY_PUBLIC_DOMAIN}"
fi

exec ./sandbox/docker_entrypoint.sh ./sandbox/run.sh
