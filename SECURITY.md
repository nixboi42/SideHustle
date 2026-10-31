# Security and boundaries

The app preserves normal Apple Account, two-factor authentication, device trust and service authorization requirements. It stops on errors; it does not forge entitlements, read credentials, alter pairing records, inject code, patch Apple binaries, change SIP, modify global device identity or change iPadOS.

Native connection APIs are private. Build/UUID/method checks restrict the preview to the reviewed runtime. New-build support requires ABI and lifecycle review plus separately authorized hardware validation. Do not add an “ignore compatibility” switch.

No automatic retries follow a failed connection. A timeout requests native cleanup, blocks new connections and warns that remote completion may still occur. Quit does not disconnect an already established session. Login registration uses macOS SMAppService and remains subject to its approval state.

Device names and the remembered device UUID remain local. The UUID is a preference, not a rewritten device identity. There are no network upload, analytics, updater or embedded credential features. Error descriptions, userInfo and raw stream configuration are excluded from diagnostics.

Before reporting a problem, review any attachment for personal data. Share model, macOS build, iPadOS version and redacted diagnostic domain/code; do not attach account databases, pairing records, stream keys or firmware images. No security contact address has been designated for this unpublished preview. Use a repository's private reporting channel once one exists, rather than posting secrets in a public issue.
