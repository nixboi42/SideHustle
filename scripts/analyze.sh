#!/bin/bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
source "$root/scripts/path-safety.sh"
prepare_build_directory
work="$(mktemp -d "$root/build/analyze.XXXXXX")"
trap 'rm -rf "$work"' EXIT
for source in Sources/SCBridge.m Sources/main.m Tests/session-tests.m scripts/make-icon.m; do
  xcrun clang --analyze -fobjc-arc -fblocks -Wall -Wextra -Werror \
    -mmacosx-version-min=13.0 -I "$root/Sources" \
    -Xanalyzer -analyzer-output=text "$root/$source" -o "$work/result.plist"
done
