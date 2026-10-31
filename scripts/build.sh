#!/bin/bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
source "$root/scripts/path-safety.sh"
prepare_build_directory
reject_symlink_path "$root/build/SideHustle.app"
work="$(mktemp -d "$root/build/compile.XXXXXX")"
trap 'rm -rf "$work"' EXIT
app="$work/SideHustle.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
xcrun clang -arch arm64 -mmacosx-version-min=13.0 -fobjc-arc -fblocks \
  -Wall -Wextra -Werror -O2 \
  -framework Cocoa -framework CoreGraphics -framework UniformTypeIdentifiers -framework ServiceManagement \
  "$root/Sources/main.m" "$root/Sources/SCBridge.m" -o "$app/Contents/MacOS/SideHustle"
cp "$root/Info.plist" "$app/Contents/Info.plist"
cp "$root/LICENSE" "$app/Contents/Resources/LICENSE.txt"
mkdir -p "$work/AppIcon.iconset"
xcrun clang -fobjc-arc -Wall -Wextra -Werror -framework AppKit \
  "$root/scripts/make-icon.m" -o "$work/make-icon"
"$work/make-icon" "$work/AppIcon.iconset"
iconutil -c icns "$work/AppIcon.iconset" -o "$app/Contents/Resources/AppIcon.icns"
# Local builds are ad-hoc signed. A public release can supply a Developer ID.
identity="${SIDECAR_SIGNING_IDENTITY:--}"
if [[ "$identity" == "-" ]]; then
  codesign --force --sign - "$app"
else
  codesign --force --options runtime --timestamp --sign "$identity" "$app"
fi
codesign --verify --strict --verbose=2 "$app"
# Replace only this generated app after the fresh build verifies successfully.
rm -rf "$root/build/SideHustle.app"
mv "$app" "$root/build/SideHustle.app"
printf '%s\n' "$root/build/SideHustle.app"
