#!/usr/bin/env bash
#
# FOR DEBIAN / DEBIAN-BASED SYSTEMS!!
# System Maintenance - slopmanufacturer
#

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

APT_OPTS=(-y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold)
ASSUME_YES=0

#color
if [[ -t 1 ]]; then
  RED=$'\033[0;31m'; NC=$'\033[0m'; BLUE=$'\033[0;34m'
  YELLOW=$'\033[1;33m'; PURPLE=$'\033[0;35m'; PINK=$'\033[38;5;213m';
  GREEN=$'\033[0;32m'
else
  RED=''; NC=''; BLUE=''; YELLOW=''; PURPLE=''; PINK=''; GREEN='';
fi

#message
info()  { printf "${BLUE}[INFO]${NC}  %s\n" "$*"; }
error() { printf "${RED}[ERROR]${NC} %s\n" "$*" >&2; }
warn() { printf "${YELLOW}[WARNING]${NC} %s\n" "$*" >&2; }
ok() { printf "${PURPLE}[OK]${NC} %s\n" "$*"; }
yay() { printf "${PINK}[SYS]${NC} %s\n" "$*"; }
success() { printf "${GREEN}[SUCCESS]${NC} %s\n" "$*"; }

#options
usage() {
  printf 'Usage: sudo %s [-y|--yes] [-h|--help]\n' "$0"
  printf '  -y, --yes   skip the confirmation prompt (unattended runs)\n'
  printf '  -h, --help  show this help\n'
}

while (( $# )); do
  case "$1" in
    -y|--yes) ASSUME_YES=1 ;;
    -h|--help) usage; exit 0 ;;
    *) error "Unknown option: $1"; usage >&2; exit 2 ;;
  esac
  shift
done

#runs checks
if [[ $EUID -ne 0 ]]; then
  error "Please run as root: sudo $0"
  exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
    error "apt-get not found. This script is for Debian-based operating systems"
    exit 1
fi

#banner
printf '%s\n' "${YELLOW}-------- SYSTEM MAINTENANCE --------${NC}"
info "==> Made by ${RED}slopmanufacturer${NC}"
info "==> Please check more of my scripts and code in https://github.com/slopmanufacturer"
yay "Thanks for using this! ${PINK}( ˶⚈Ɛ⚈˵)${NC}"
printf '%s\n' "${YELLOW}------------------------------------${NC}"

#Reports errors
trap 'error "Aborted (status $?): $BASH_COMMAND"' ERR

info "[$(date -Is)] starting maintenance"

info "==> Grabbing the new package lists"
for attempt in 1 2 3; do
  if apt-get update; then break; fi
  if (( attempt < 3 )); then
    warn "==> apt-get update failed, retrying in 5s (attempt $attempt/3)"
    sleep 5
  else
    error "==> apt-get update failed 3 times, giving up"
    exit 1
  fi
done

info "==> Checking what would change"
if preview=$(apt-get "${APT_OPTS[@]}" -s full-upgrade 2>/dev/null); then
  info "==> Packages to upgrade: $(grep -c '^Inst ' <<<"$preview" || true)"
  removals=$(awk '/^Remv /{printf "%s ", $2}' <<<"$preview")
  if [[ -n $removals ]]; then
    warn "==> Packages to remove: $removals"
  fi
  if autorm=$(apt-get "${APT_OPTS[@]}" -s autoremove 2>/dev/null); then
    purged=$(awk '/^Remv /{printf "%s ", $2}' <<<"$autorm")
    if [[ -n $purged ]]; then
      warn "==> Unused packages to purge: $purged"
    fi
  fi
else
  warn "==> Could not preview the upgrade, the dpkg state will be repaired first"
fi

if (( ASSUME_YES )); then
  info "==> Running unattended (--yes)"
else
  if [[ ! -t 0 ]]; then
    error "==> No terminal to confirm on, re-run with --yes for unattended use"
    exit 1
  fi
  printf '%s' "${YELLOW}==> Proceed with these changes? [y/N] ${NC}"
  read -r reply || reply=""
  case "$reply" in
    y|Y|yes|YES) ;;
    *) info "==> Aborted, nothing was changed."; exit 0 ;;
  esac
fi

#the updating part
info "==> Fixing the dpkg state"
dpkg --configure -a

info "==> Fixing any broken files or packages"
apt-get "${APT_OPTS[@]}" --fix-broken install

info "==> Fully upgrading the system"
apt-get "${APT_OPTS[@]}" full-upgrade


info "==> Removing useless ahh files"
apt-get "${APT_OPTS[@]}" autoremove --purge

info "==> Taking out cache from the packages"
apt-get autoclean


if [[ -f /var/run/reboot-required ]]; then
  if [[ -f /var/run/reboot-required.pkgs ]]; then
    warn "==> Reboot required for: ${RED}$(tr '\n' ' ' < /var/run/reboot-required.pkgs)${NC}"
  else
    warn "==> Reboot required."
  fi
else
  ok "==> No reboot required."
fi


success "Maintenance completed with no errors."

printf '%s\n' "${YELLOW}------------------------------------${NC}"

info "==> System update is over."
info "==> Find more scripts in ${PINK}https://github.com/slopmanufacturer${NC}"
yay "Thanks for using this! ${PINK}( ˶⚈Ɛ⚈˵)${NC}"
