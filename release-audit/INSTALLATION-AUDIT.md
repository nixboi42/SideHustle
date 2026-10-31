# Installation, removal and rollback audit

Build writes only build/; packaging writes a fresh dist/preview.XXXXXX directory. Fresh temporary build bundles prevent old extra resources being signed into a new app. The installer defaults to ~/Applications/SideHustle.app or an explicit absolute .app destination. It rejects root, existing destinations, dangling symlinks and symlink ancestors, verifies source before copying, and exclusively creates the destination. All shell arguments are quoted; no device strings enter a shell command.

No app launch, login registration, credential access, network download, Apple file replacement or global security change occurs during install. A failed/interrupted copy may leave a partial newly created app and parent directories; recovery is manual and documented. This avoids silently deleting another user's files. Scripts assume a trusted user-owned checkout; they are not a privileged installer secure against an attacker controlling the same writable directories. No automatic updater or privileged service.

Removal: disconnect with standard controls, unregister Login Item if enabled, quit, Trash only this app; optionally delete its own defaults domain and user-saved diagnostics. Do not delete Apple frameworks, pairing data or other Continuity files. Upgrades preserve a manually moved old app for rollback. No system restore required.

Negative tests exercise existing destinations, dangling links, linked parents and build outputs. A clean ad-hoc build/install into a temporary user-owned destination is verified without launching. Real Login Items approval, actual Applications installation, failed-disk-copy recovery and reboot behavior were not exercised; see TEST-RESULTS.md and docs/INSTALLATION.md.
