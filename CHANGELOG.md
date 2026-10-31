# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `make check`: `bash -n`, shellcheck when it is installed, and three test
  scripts. `tests/static.sh` fails if anything that changes the system moves
  above the confirmation prompt; `tests/smoke.sh` covers `--help`, an unknown
  option, and the non-root refusal; `tests/docs.sh` fails when the README stops
  documenting a flag the script accepts.
- CI runs `make check` on every push and pull request.
- `AGENTS.md` and `AUDIT.md`.

### Changed
- The README said the script "asks before touching anything". It refreshes the
  package lists before the prompt, so the sentence now says what actually
  happens: nothing is installed, removed or purged until you answer.
- The banner, the clone URL, the badge, the author credit, and the changelog
  links used the account's previous login. They use the current one.

### Fixed
- The `[1.0.0]` changelog link pointed at a tag that does not exist. The heading
  is plain text now.


## [1.1.0] - 2026-10-29

### Added
- Confirmation prompt before anything is installed, removed or purged. It prints how many packages would be upgraded and names the ones that would be removed or purged.
- `-y`/`--yes` to skip the prompt and `-h`/`--help` to show usage.
- The script refuses to run without a terminal unless `--yes` is given, so a cron job fails loudly instead of upgrading silently.
- Demo GIF and screenshots in the README, recorded from a real run in a `debian:12.1` container.

### Changed
- `apt-get update` now runs before the dpkg repair, so the preview is based on current package lists.
- README restructured around tables and short sections, with the demo at the top.
- The script is stored with the executable bit set, so `git clone` then `sudo ./system-maintenance.sh` works without a manual `chmod`.

### Fixed
- Unknown options now exit with status 2 and print usage to stderr.


## [1.0.1] - 2026-10-29

### Fixed
- Banner and footer no longer crash when the output is piped or redirected. With colors disabled the separator started with `-`, so `printf` parsed it as an option and the script aborted before doing any work.
- The error trap now reports the failing command and its exit status. `$LINENO` inside a trap always expanded to the trap's own line, so every failure reported the same line number.
- `full-upgrade` no longer stops on dpkg configuration-file prompts: `--force-confdef` and `--force-confold` are passed to apt, and `NEEDRESTART_MODE=a` keeps the `needrestart` hook on Debian 12+ from prompting.

### Changed
- `apt-get update` is retried up to 3 times before giving up, instead of aborting on the first transient mirror failure.
- Banner and footer use a `SYSTEM MAINTENANCE` heading instead of the leftover `README` placeholder.

### Documentation
- README step order now matches the script.
- Removed the documented `apt upgrade -y` step, which the script never ran.
- Documented that `autoremove` runs with `--purge`.
- Replaced the example output with real output from the script.


## 1.0.0 - 2026-10-09

### Added
- Initial release.
- System package list refresh via `apt update`.
- Package upgrade via `apt upgrade -y`.
- Full upgrade handling new and removed dependencies via `apt full-upgrade -y`.
- Removal of unused packages via `apt autoremove -y`.
- Package cache cleanup via `apt autoclean`.
- Broken dependency repair via `apt --fix-broken install -y`.
- Interrupted `dpkg` state recovery via `dpkg --configure -a`.
- Reboot-required detection using `/var/run/reboot-required`.
- Color-coded terminal output with automatic disabling when piped.
- Error trapping with line-number reporting via `trap ERR` and `$LINENO`.
- Root privilege check with a clear error message.
- Strict mode enabled (`set -euo pipefail`) for safe execution.
- Banner and footer with project branding and author links.


[Unreleased]: https://github.com/vezeqs/debian-system-maintenance/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/vezeqs/debian-system-maintenance/releases/tag/v1.1.0
[1.0.1]: https://github.com/vezeqs/debian-system-maintenance/releases/tag/v1.0.1
