# Grist v1.7.22 wrapper for Railway (one-click template).
#
# Upstream: gristlabs/grist-core, Apache-2.0. Grist is a relational
# spreadsheet / Airtable alternative — Python formulas, reference
# columns, linked records, attachments, REST API, access rules.
# Documents are SQLite files; users, orgs and settings live in
# /persist/home.sqlite3. No companion database service needed.
#
# Pin: manifest-list digest for the 1.7.22 tag (released 2026-10-29;
# amd64 manifest sha256:3350862517c2526d36e0df17e3ab89258081b8454b34530bce59a9e19a039819).
# Digest-only FROM (no tag) — Railpack 0.43.0 fails to detect a Dockerfile
# whose FROM carries both a tag and a digest (proven 2026-11-05, TimeTagger).
#
# What the wrapper adds over the stock image:
# - APP_HOME_URL is derived at boot from the live Railway public domain,
#   so links, forms and embeds resolve. A baked template expression
#   would resolve to a bare https:// on first deploy (no domain yet).
# - PORT is honored natively: Grist reads $PORT (Railway injects it);
#   the stock image listens on 8484 by default.
# - Single Railway volume at /persist: documents (/persist/docs), the
#   home database (/persist/home.sqlite3) and instance config all live
#   there. The upstream entrypoint (./sandbox/docker_entrypoint.sh)
#   chowns /persist to the grist user and de-elevates itself, so the
#   root-owned Railway volume mount works without a wrapper chown.
# - GRIST_BOOT_KEY and GRIST_SESSION_SECRET come from the deploy form
#   as generated secrets (see template-vars.json). The boot key is what
#   the deployer pastes at /boot to sign in as install admin — no
#   log-diving required, unlike the stock image which prints a random
#   key to stdout on every boot.
#
# First run: open the public URL, paste the generated GRIST_BOOT_KEY at
# /boot, and complete Quick setup (admin email, sign-in method,
# permission preset). Healthcheck is /boot (the boot-key sign-in page,
# unauthenticated 200).
FROM gristlabs/grist@sha256:c2221950675081c79a06a44c27f8c65cc96c43d93d76f2b3214d8dbdff709355

USER root

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

LABEL org.opencontainers.image.source="https://github.com/INAPP-Mobile/grist"

# Upstream ENTRYPOINT is ./sandbox/docker_entrypoint.sh and CMD is
# ./sandbox/run.sh; entrypoint.sh execs them after deriving
# APP_HOME_URL. Do NOT set CMD here: Docker runs ENTRYPOINT + CMD, so
# CMD ["/entrypoint.sh"] would pass the script path to the upstream
# entrypoint as an argument.
EXPOSE 8484
ENTRYPOINT ["/entrypoint.sh"]
