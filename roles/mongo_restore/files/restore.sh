#!/usr/bin/env bash
# Usage: restore.sh USER PASSWORD AUTHDB DB INPUT TLS_ARGS EXTRA_FLAGS
#  - DB:         "" for full restore, or a database name (limits with --nsInclude DB.*)
#  - INPUT:      "-" for stdin (gunzip streamed), or a .gz/.archive file path
#  - TLS_ARGS:   e.g. '--ssl --sslCAFile /path/ca.pem' (or empty)
#  - EXTRA_FLAGS: e.g. '--drop' or '--oplogReplay' (or empty)

set -euo pipefail

USER="$1"
PASS="$2"
AUTHDB="$3"
DB="${4:-}"
INPUT="$5"
TLS_ARGS="${6:-}"
EXTRA_FLAGS="${7:-}"

cmd=( mongorestore
  --username "$USER"
  --password "$PASS"
  --authenticationDatabase "$AUTHDB"
  --archive
)

# limit to a single DB if provided
if [[ -n "$DB" ]]; then
  cmd+=( --nsInclude "${DB}.*" )
fi

# stdin vs file
if [[ "$INPUT" == "-" ]]; then
  : # stdin: do NOT add --gzip (already gunzipped upstream)
else
  # file path + gzip flag
  cmd+=( --archive="$INPUT" --gzip )
fi

# append TLS args (split safely)
if [[ -n "${TLS_ARGS// }" ]]; then
  # shellcheck disable=SC2206
  TA=( $TLS_ARGS )
  cmd+=( "${TA[@]}" )
fi

# append extra flags (e.g. --drop, --oplogReplay)
if [[ -n "${EXTRA_FLAGS// }" ]]; then
  # shellcheck disable=SC2206
  EF=( $EXTRA_FLAGS )
  cmd+=( "${EF[@]}" )
fi

# optional debug
if [[ "${DEBUG:-0}" = "1" ]]; then
  printf 'DEBUG mongorestore cmd:\n  '
  printf '%q ' "${cmd[@]}"; echo
fi

exec "${cmd[@]}"