#!/bin/bash
# Shared by local developer scripts. Never run these scripts with sudo.
reject_symlink_path() {
  local candidate="$1"
  while [[ "$candidate" != / && "$candidate" != . && -n "$candidate" ]]; do
    if [[ -L "$candidate" ]]; then
      printf '%s\n' 'Refusing a symlink in an output path.' >&2; return 1
    fi
    candidate="$(dirname "$candidate")"
  done
}
prepare_build_directory() {
  [[ "$EUID" -ne 0 ]] || { printf '%s\n' 'Run as an ordinary user, without sudo.' >&2; return 1; }
  reject_symlink_path "$root/build"
  mkdir -p "$root/build"
}
