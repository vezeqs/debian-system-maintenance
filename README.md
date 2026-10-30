# Debian System Maintenance Script

A simple, safe Bash script that updates, cleans, and repairs packages on Debian and Debian-based Linux systems (Ubuntu, Linux Mint, Pop!_OS, etc.).

## Features

- Refreshes package lists (retries up to 3 times on mirror hiccups) and performs a full system upgrade.
- Removes unused packages including their leftover config files, and cleans the package cache.
- Fixes broken package dependencies and interrupted `dpkg` states *before* upgrading.
- Never stops on a prompt: keeps your existing config files and lets `needrestart` run unattended.
- Checks if a system reboot is required.
- Clear, color-coded output that auto-disables when piped.
- Fails fast with `set -euo pipefail` and reports the failing command and exit status.
- Safe to run repeatedly (idempotent).

## Prerequisites

- A Debian-based Linux distribution (Debian, Ubuntu, Mint, Pop!_OS, …)
- `sudo` or root privileges
- Bash 4.0 or newer (default on all modern Debian systems)

## Installation

```bash
git clone https://github.com/slopmanufacturer/debian-system-maintenance.git
cd debian-system-maintenance
chmod +x system-maintenance.sh
```

## Usage

Run with root privileges:

```bash
sudo ./system-maintenance.sh
```

It is safe to pipe or redirect the output (`sudo ./system-maintenance.sh | tee maintenance.log`), which also disables the colors.

## What It Does

The script runs these steps in order:

1. `dpkg --configure -a` — finish any interrupted package configuration
2. `apt-get update` — refresh the list of available packages (up to 3 attempts)
3. `apt-get --fix-broken install -y` — repair broken dependencies
4. `apt-get full-upgrade -y` — upgrade everything, including packages that need new or removed dependencies
5. `apt-get autoremove --purge -y` — remove unused dependencies **and their config files**
6. `apt-get autoclean` — delete obsolete downloaded package files
7. Check `/var/run/reboot-required` and warn if a restart is needed

Every `apt-get` call passes `-o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold`, so `dpkg` keeps your existing configuration files instead of stopping to ask. `NEEDRESTART_MODE=a` does the same for the `needrestart` hook on Debian 12+.

Note that step 5 uses `--purge`: configuration files of removed packages are deleted too. If you want to keep them, drop `--purge` from that line.

## Example Output

```
-------- SYSTEM MAINTENANCE --------
[INFO]  ==> Made by slopmanufacturer
[INFO]  ==> Please check more of my scripts and code in https://github.com/slopmanufacturer
[SYS] Thanks for using this! ( ˶⚈Ɛ⚈˵)
------------------------------------
[INFO]  [2026-10-29T21:23:20-05:00] starting maintenance
[INFO]  ==> Fixing the dpkg state
[INFO]  ==> Grabbing the new package lists
[INFO]  ==> Fixing any broken files or packages
[INFO]  ==> Fully upgrading the system
[INFO]  ==> Removing useless ahh files
[INFO]  ==> Taking out cache from the packages
[OK] ==> No reboot required.
[SUCCESS] Maintenance completed with no errors.
------------------------------------
[INFO]  ==> System update is over.
[INFO]  ==> Find more scripts in https://github.com/slopmanufacturer
[SYS] Thanks for using this! ( ˶⚈Ɛ⚈˵)
```

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Author

**slopmanufacturer** — [github.com/slopmanufacturer](https://github.com/slopmanufacturer)

More scripts and projects: [github.com/slopmanufacturer](https://github.com/slopmanufacturer)
