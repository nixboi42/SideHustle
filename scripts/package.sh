#!/bin/bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
source "$root/scripts/path-safety.sh"
prepare_build_directory
reject_symlink_path "$root/dist"
python3 "$root/scripts/source-archive.py" --check
bash "$root/scripts/test.sh"
bash "$root/scripts/build.sh"
mkdir -p "$root/dist"
# A new directory avoids merging stale artifacts or following existing output links.
release="$(mktemp -d "$root/dist/preview.XXXXXX")"
version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$root/build/SideHustle.app/Contents/Info.plist")"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
ditto -c -k --norsrc --noextattr --keepParent "$root/build/SideHustle.app" "$release/SideHustle-${version}-arm64.zip"
COPYFILE_DISABLE=1 python3 "$root/scripts/source-archive.py" "$release/SideHustle-${version}-source.tar.gz"
(cd "$release" && shasum -a 256 SideHustle-${version}-arm64.zip SideHustle-${version}-source.tar.gz > SHA256SUMS)
printf '%s\n' "Preview artifacts prepared in $release. Nothing uploaded. Signing/notarization requires separate authorization."
