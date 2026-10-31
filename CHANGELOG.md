# Changelog

## 0.1.0 — experimental source preview (publication pending)

- Native menu bar app with device selection and connect/disconnect controls.
- Caller-local support for genuine iPad 5 discovery objects; no system patch.
- Exact 26B123 build, core UUID and API signature guards.
- Remembered device, optional one-shot startup connection and normal Login Items integration.
- Existing-session protection, bounded request/cleanup and stale-callback handling.
- Privacy-limited diagnostics, read-only self-check and safe UI preview.
- Source build, install and release packaging scripts; mock lifecycle tests and CI.

Physical validation currently covers iPad6,11 on iPadOS 16.7.16 only. Public Developer ID signing/notarization and further compatibility testing remain outstanding.

### Release audit hardening (2026-10-31)

- Reject malformed/oversized discovery metadata and ambiguous identifiers.
- Bound and fuzz-check framework UUID load-command parsing.
- Prevent preferred-device writes in safe preview.
- Refuse installer symlinks and existing destinations; verify before copying.
- Build in a fresh temporary bundle, avoiding stale executable resources.
- Package individual reviewed source files with anonymous archive ownership.
- Add sanitizer, negative filesystem and static-analysis checks, privacy and
  provenance documentation, and a credential-free public-source CI bootstrap.

### Initial source-release preparation

- Retain application version 0.1.0 / build 1; propose tag v0.1.0 only after approval.
- Tighten CI, timeout, existing-session and startup claims to match test evidence.
- Limit the proposed MIT grant to rights-authorized contributions; keep ownership
  and private-API legal questions open for owner review.
- Prepare a single root commit containing exactly 47 reviewed files, with GitHub
  noreply identity and a separate reachable-object-only publication bundle.
- Verify a clean clone locally; no hosted CI, new hardware test, signed binary,
  notarization, public repository or release is claimed.
