# Audit — 2026-10-31

Scope: `system-maintenance.sh`, README, CHANGELOG, repo hygiene.
Baseline before any change:

```
$ bash -n system-maintenance.sh
(no output)
$ ./system-maintenance.sh --help
Usage: sudo ./system-maintenance.sh [-y|--yes] [-h|--help]
$ ./system-maintenance.sh --bogus
exit 2
$ ./system-maintenance.sh          # as a normal user
exit 1, "Please run as root"
```

No test suite, no CI, no `AGENTS.md`. Every other maintenance script in the
account has all three.

| # | Finding | Severity | Status |
| --- | --- | --- | --- |
| F1 | The README claims the script asks "before touching anything"; `apt-get update` runs first | Low | fixed |
| F2 | Nothing tests the ordering that makes the confirmation prompt a gate | Medium | fixed, `tests/static.sh` |
| F3 | No CI | Medium | fixed |
| F4 | The `[1.0.0]` changelog link points at a tag that does not exist | Low | fixed |
| F5 | The banner, badge, clone URL, author credit, and changelog links use the previous login | Low | fixed |
| F6 | No `AGENTS.md` | Low | fixed |

## F1 — "Asks before touching anything" is not what happens (Low)

**Claim:** README line 4, "It shows you what will change, **asks before touching
anything**".
**Evidence:** the script runs `apt-get update` at the top, before the prompt. That
writes `/var/lib/apt/lists`. The README's own step table lists it as step 1,
before the confirmation at step 3, so the prose and the table disagree.
**Cause:** the sentence was written for "installs, removes, purges", then
generalised.
**Fix:** the README now says "asks before installing, removing or purging
anything", and states that the lists are refreshed first.
**Status:** fixed. `tests/docs.sh` keeps the confirmation described.

## F2 — Nothing guards the gate (Medium)

**Claim:** "Nothing is installed, removed or purged until you answer `y`."
**Evidence:** true today by construction, and nothing would notice if a future
edit moved `apt-get full-upgrade` above the `read`. This is the one property the
whole confirmation prompt exists for.
**Fix:** `tests/static.sh` parses the line number of `read -r reply` and fails if
any mutating call — `full-upgrade`, `--fix-broken install`,
`autoremove --purge`, `dpkg --configure -a` — appears above it. Verified by
moving `full-upgrade` above the prompt: the test reports
`}" full-upgrade runs at line 107, before the confirmation gate at line 108`.
**Status:** fixed, `tests/static.sh`.

## F3 — No CI (Medium)

`make check` did not exist. **Fix:** `Makefile` with `lint` and `test`, and
`.github/workflows/checks.yml` running `make check` with shellcheck installed.
**Status:** fixed.

## F4 — A dead changelog link (Low)

**Evidence:** `curl -o /dev/null -w '%{http_code}' -L
https://github.com/vezeqs/debian-system-maintenance/releases/tag/v1.0.0` → 404.
Tags exist for `v1.1.0` and `v1.0.1`; there is no `v1.0.0` tag.
**Fix:** the `1.0.0` heading is plain text and the reference is gone.
**Status:** fixed.

## F5 — Stale account identity (Low)

**Evidence:** the banner printed `Made by slopmanufacturer`, the footer linked
`github.com/slopmanufacturer`, the README badge and clone URL used the old
login, and the author credit named it. The account is now `vezeqs`
(`codefactory`).
**Status:** fixed everywhere; `grep -rn slopmanufacturer` is empty.

## F6 — No AGENTS.md (Low)

**Status:** fixed.

## Verified, no finding

- `bash -n` clean; `--help` exits 0; an unknown option exits 2 with usage on
  stderr; a non-root run exits 1 with the right message. (An earlier observation
  of exit 141 was my own `| head`, which closed the pipe — not the script.)
- `set -euo pipefail` is present, and the `ERR` trap reports the failing command
  and status.
- The preview commands use `-s`, so they cannot change anything.
- `autoremove --purge` is described in the README's safety notes, including how
  to opt out.
- No `rm -rf` anywhere; `tests/static.sh` enforces that.

## Not run

The script was not executed against a real apt, because that needs root and a
throwaway Debian container. The behaviour covered here is argument parsing,
refusal paths, and the ordering of the confirmation gate.
