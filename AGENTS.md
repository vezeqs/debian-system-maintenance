# AGENTS.md

## What this is

One bash script that updates, repairs, and cleans a Debian-based system with
`apt-get`. It previews the upgrade, asks for confirmation, then runs the
mutating steps. `tests/` checks the parts that can be checked without root; CI
runs them on every push.

## Entry points

| Question | Where |
| --- | --- |
| What does a run do, in order? | `system-maintenance.sh`, top to bottom |
| What is the gate before changes? | the `read -r reply` block |
| What is tested? | `tests/static.sh`, `tests/smoke.sh`, `tests/docs.sh` |
| How do I run the checks? | `make check` |

## Invariants

1. **Nothing that changes the system runs before the confirmation gate.** The
   previews carry `-s`; the mutating calls come after `read -r reply`.
   `tests/static.sh` compares line numbers.
2. **`set -euo pipefail` and the `ERR` trap stay.** They are the reason a failed
   step stops the run with the command and status named.
3. **Every `apt-get` call keeps `--force-confdef --force-confold`.** Without
   them dpkg stops at a config-file prompt in the middle of an unattended run.
4. **No `rm -rf`.** `tests/static.sh` fails on it.
5. **`--yes` is the only way to skip the prompt, and it is required when stdin
   is not a terminal.** A cron job must fail loudly, not upgrade silently.
6. **The README documents every flag `usage()` accepts.** `tests/docs.sh` fails
   otherwise.

## Commands

```bash
make check     # bash -n, shellcheck if installed, then the three test scripts
make lint
make test
```

The one command that proves the work: `make check`.

## Sharp edges

- **`apt-get update` runs before the prompt, on purpose.** The preview must use
  current lists. It writes `/var/lib/apt/lists`, so the README says "nothing is
  installed, removed or purged", not "nothing is touched".
- **`autoremove --purge` deletes config files.** The README says how to opt out;
  do not silently drop `--purge` or silently keep it.
- **`grep -c` exits 1 when it counts zero.** The count is wrapped in `|| true`
  for that reason; removing it makes `set -e` abort on a system with nothing to
  upgrade.
- **`(( expr ))` returns 1 when the expression is 0.** Both arithmetic tests
  (`attempt < 3`, `ASSUME_YES`) are inside `if`/`for` conditions where that is
  harmless. Do not move them to bare statements.
- **The confirmation reads stdin, so a pipe changes the behaviour.** The script
  refuses when stdin is not a terminal; that is the documented cron behaviour.
- **Tests must not need root.** CI runs as a normal user, so anything that needs
  root belongs in a container test, not in `tests/`.
- **A test that cannot fail is worse than none.** `tests/static.sh` was checked
  by moving `full-upgrade` above the gate and by appending an `rm -rf`; both are
  reported by name.

## Definition of done

- [ ] `make check` passes.
- [ ] A new flag is added to `usage()` and to the README's options table.
- [ ] A new mutating command is added below the confirmation gate, and to the
      list in `tests/static.sh`.
- [ ] `CHANGELOG.md` has an entry under `[Unreleased]` or a new version.

## Do not touch

- `LICENSE`.
- The order of the steps: update lists, preview, confirm, repair, upgrade,
  autoremove, clean, reboot check.
- The `apt-get` option list. `--force-confold` is the documented safety
  property, not a preference.
- `assets/` screenshots by hand; they are recorded from real runs.
