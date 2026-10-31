#!/usr/bin/env bash
# Structural checks. No root, no network, no package manager.
set -euo pipefail

script=${1:?usage: static.sh <script>}

bash -n "$script"

# The safety net the README promises.
grep -q 'set -euo pipefail' "$script"
grep -q 'trap .* ERR' "$script"
grep -q 'EUID' "$script"
grep -q -- '--force-confdef' "$script"
grep -q -- '--force-confold' "$script"
grep -q 'NEEDRESTART_MODE=a' "$script"

if grep -q 'rm -rf' "$script"; then
  echo "rm -rf is not allowed in this repository" >&2
  exit 1
fi

# Nothing that changes the system may run before the confirmation gate.
# The preview calls are safe: they carry -s.
confirm=$(grep -n 'read -r reply' "$script" | head -1 | cut -d: -f1 || true)
if [[ -z ${confirm:-} ]]; then
  echo "no confirmation prompt found" >&2
  exit 1
fi

while IFS= read -r call; do
  line=$(grep -nF -- "$call" "$script" | head -1 | cut -d: -f1 || true)
  if [[ -z $line ]]; then
    echo "missing call: $call" >&2
    exit 1
  fi
  if (( line < confirm )); then
    echo "$call runs at line $line, before the confirmation gate at line $confirm" >&2
    exit 1
  fi
done <<'CALLS'
}" full-upgrade
}" --fix-broken install
}" autoremove --purge
dpkg --configure -a
CALLS

echo "ok $script"
