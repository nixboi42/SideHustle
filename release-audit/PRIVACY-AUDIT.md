# Privacy audit

Source review identified no telemetry, analytics, updater, HTTP client, socket listener or upload feature. The only explicit URL is a local System Settings deep link. Apple native services perform discovery/authentication/video/input and may communicate beyond the wrapper; their remote endpoints and routing were not captured. The product must not claim the whole Sidecar system is offline or handles no personal data.

Data: device name/model/type/UUID and connection state in memory; preferred UUID plus connect-on-launch preference in the app's NSUserDefaults domain; user-opted SMAppService login registration; at most 100 timestamped diagnostic events with counts and error domain/code. Explicit Save Diagnostics writes only the selected JSON file; no automatic retention beyond process memory for events, but exported files persist until manually removed. Error descriptions/userInfo, stream config, raw logs, names and identifiers are not exported. Error domains come from native services; review even limited diagnostics before sharing.

SH-03 fixed a preview-mode preference write. The original source archive leaked local account names via tar metadata (SH-01); new source archive normalizes ownership and omits xattrs. No real Apple Account secret, pairing record or serial/UDID found in project source. Surrounding logs are private and excluded.

PRIVACY.md describes actual implementation and Apple service limits. No network interception, physical-device action, permission change or automatic diagnostic upload was performed in this audit.
