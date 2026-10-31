#!/usr/bin/env bash
# The README has to document every flag the script accepts.
set -euo pipefail

script=${1:?usage: docs.sh <script>}
readme=$(dirname "$script")/README.md

if [[ ! -f $readme ]]; then
  echo "missing $readme" >&2
  exit 1
fi

mapfile -t flags < <(sed -n '/^usage()/,/^}/p' "$script" | grep -o -- '--[a-z-]*' | sort -u)
if (( ${#flags[@]} == 0 )); then
  echo "no flags found in usage()" >&2
  exit 1
fi

for flag in "${flags[@]}"; do
  if ! grep -q -- "$flag" "$readme"; then
    echo "README does not document $flag" >&2
    exit 1
  fi
done

# The confirmation behaviour is the product; it has to stay described.
grep -q 'y/N' "$readme"
grep -q -- '--force-confold' "$readme"

echo "ok $readme (${#flags[@]} flags documented)"
