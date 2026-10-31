#!/bin/bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
source "$root/scripts/path-safety.sh"
[[ "$EUID" -ne 0 ]] || { printf '%s\n' 'Install without sudo.' >&2; exit 1; }
destination="${1:-$HOME/Applications/SideHustle.app}"
[[ "$destination" == /* && "$destination" == *.app ]] || { printf '%s\n' 'Choose an absolute .app destination.' >&2; exit 1; }
reject_symlink_path "$destination"
if [[ -e "$destination" || -L "$destination" ]]; then
  printf '%s\n' 'Destination already exists. Move the previous app aside first.' >&2; exit 1
fi
if [[ ! -d "$root/build/SideHustle.app" ]]; then bash "$root/scripts/build.sh"; fi
reject_symlink_path "$root/build/SideHustle.app"
codesign --verify --strict "$root/build/SideHustle.app"
mkdir -p "$(dirname "$destination")"
# mkdir exclusively claims the destination; never merge into an existing app.
mkdir "$destination"
if ! ditto "$root/build/SideHustle.app" "$destination" || ! codesign --verify --strict "$destination"; then
  printf '%s\n' 'Installation incomplete. Move the newly created destination aside before retrying. No app was launched.' >&2
  exit 1
fi
printf '%s\n' "Installed: $destination" 'Open the app, then optionally enable Open at login. No login item was registered by this script.'
