# Troubleshooting

Unsupported build/framework/API: stop and report redacted build/model information.
Do not remove the guards or patch Apple system components.

No iPad: use the same Apple Account with 2FA, unlock the iPad, and complete ordinary
USB trust if using USB. Refresh once. Finder visibility does not prove Sidecar
discovery. Service calls are synchronous; a stalled Apple service can freeze the
main UI despite the asynchronous session completion deadline.

An existing Sidecar display: manage it with Displays settings. SideHustle refuses
to take it over. Discovery validates collection types/counts, metadata lengths and
unique UUIDs; a malformed reply stops discovery rather than guessing a device.

Connection error: inspect redacted domain/code; the app does not automatically
retry. Timeout: one native disconnect is requested; further connects are blocked.
A late remote session is possible. Check Displays and manually disconnect before
reopening. Cleanup itself is bounded to ten seconds only when the main run loop
continues to run. Multiple-device races with other Apple clients are not atomic.

Login Item: move the app into Applications and approve it using normal macOS
settings. This audit did not register any login item or test automatic startup.

Private security reports: see SECURITY.md. Do not post raw syslogs, packet captures,
credentials, device dumps, firmware or private framework binaries in public issues.
