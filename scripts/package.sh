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
ditto -c -k --norsrc --noextattr --keepParent "$root/build/SideHustle.app" "$release/SideHustle-0.1.0-arm64.zip"
COPYFILE_DISABLE=1 python3 "$root/scripts/source-archive.py" "$release/SideHustle-0.1.0-source.tar.gz"
(cd "$release" && shasum -a 256 SideHustle-0.1.0-arm64.zip SideHustle-0.1.0-source.tar.gz > SHA256SUMS)
printf '%s\n' "Preview artifacts prepared in $release. Nothing uploaded. Signing/notarization requires separate authorization."
