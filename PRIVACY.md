# Privacy

SideHustle's wrapper has no telemetry, analytics SDK, updater, HTTP client, network
listener or upload function. It calls installed Apple Sidecar services. Those
services discover devices, authenticate sessions and transmit desktop video/input;
this audit does not establish their endpoints, routing, retention or offline behavior.
Apple Account, two-factor authentication and normal pairing/trust remain required.
The wrapper never requests or stores Apple Account passwords or pairing records.

Device names, model and UUID are obtained from native discovery. Names appear in
the local UI. The selected UUID and optional connect-on-launch setting persist in
NSUserDefaults for `io.github.sidecarbridge.app` until removed by the user.
Open-at-login uses Apple's user-approved SMAppService registration.

At most 100 events remain in process memory, including UTC times, counts and
error domain/code. They disappear on quit. Save Diagnostics explicitly writes a
JSON file chosen by the user; no automatic upload occurs. Names, UUIDs, raw logs,
NSError descriptions/userInfo and stream configuration are excluded. Review even
these limited diagnostics before sharing: error domains originate in Apple services.
The saved file persists until its owner removes it; the app cannot delete copies.

Read-only self-check prints model/eligibility/connection state and contacts local
Apple services. Safe preview permits discovery and viewing Login Items status,
but blocks explicit preference writes and connection/login changes. Cocoa and
Apple services may maintain their own ordinary process state or logs.
