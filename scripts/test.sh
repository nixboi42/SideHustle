#!/bin/bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
source "$root/scripts/path-safety.sh"
prepare_build_directory
reject_symlink_path "$root/build/session-tests"
flags=(-O0)
if [[ "${SANITIZERS:-0}" == 1 ]]; then flags+=(-fsanitize=address,undefined -fno-omit-frame-pointer); fi
xcrun clang -mmacosx-version-min=13.0 -fobjc-arc -fblocks \
  "${flags[@]}" -Wall -Wextra -Werror -framework Foundation -framework UniformTypeIdentifiers \
  -I "$root/Sources" "$root/Tests/session-tests.m" "$root/Sources/SCBridge.m" \
  -o "$root/build/session-tests"
"$root/build/session-tests"
plutil -lint "$root/Info.plist"
