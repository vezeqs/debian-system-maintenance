#!/usr/bin/env bash
# Behaviour that needs no root: help, bad options, and the refusal path.
set -euo pipefail

script=${1:?usage: smoke.sh <script>}

if [[ ! -x $script ]]; then
  echo "not executable: $script" >&2
  exit 1
fi

help=$("$script" --help) || {
  echo "--help failed" >&2
  exit 1
}
grep -q 'Usage:' <<<"$help"
grep -q -- '--yes' <<<"$help"

status=0
"$script" --definitely-not-an-option >/dev/null 2>&1 || status=$?
if [[ $status -ne 2 ]]; then
  echo "unknown option exited $status, expected 2" >&2
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
  status=0
  out=$("$script" 2>&1) || status=$?
  if [[ $status -ne 1 ]]; then
    echo "a non-root run exited $status, expected 1" >&2
    exit 1
  fi
  grep -q 'run as root' <<<"$out"
fi

echo "ok $script"
