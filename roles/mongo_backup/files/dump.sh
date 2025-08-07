#!/usr/bin/env bash
set -euo pipefail

# Arguments
# $1  username
# $2  password
# $3  authentication database
# $4  db name  (empty = all DBs)
# $5  archive file path
# $6  oplog flag            ("--oplog" or "")
# $7  extra TLS flags       ("" or as needed)
# $8  host / replica-set member (optional, defaults to localhost)

USER="$1"
PASS="$2"
AUTHDB="$3"
DBNAME="$4"
ARCHIVE="$5"
OPLOG="${6:-}"
TLS_FLAGS="${7:-}"
HOST="${8:-localhost}"

#
# Build common part of the command
#
CMD=(mongodump
     --host "$HOST"
     --username "$USER"
     --password "$PASS"
     --authenticationDatabase "$AUTHDB"
     --archive --gzip)

# oplog?
[[ -n "$OPLOG" ]]   && CMD+=("$OPLOG")
# TLS?
[[ -n "$TLS_FLAGS" ]] && CMD+=($TLS_FLAGS)

# whole cluster or single DB?
if [[ -n "$DBNAME" ]]; then
  CMD+=(--db "$DBNAME")
fi

#
# Execute
#
"${CMD[@]}"  >"$ARCHIVE"