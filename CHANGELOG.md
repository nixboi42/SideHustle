# Changelog

> Releases are experimental. See [README](README.md) for current installation,
> compatibility and validation status.

## 0.4.0 — improved wireless stability

- Improve wireless connection stability; user-tested over wired and wireless
  connections.
- Increase the native cleanup timeout and unblock the session if Sidecar reports
  that the remote device has already ended the session.
- Add per-device connect/disconnect actions to the menu bar menu.
- Bump the app to version 0.4.0 / build 6.

## 0.3.2 — release packaging correction

- Correct the architecture-verification command that stopped the v0.3.1 workflow before publication.
- Publish the app preview under a new tag without moving the failed tag.
- Bump application version to 0.3.2 / build 5.

## 0.3.1 — downloadable app preview

- Publish an ad-hoc signed Apple silicon app ZIP, source archive and SHA-256 checksums from tag-triggered GitHub CI.
- Verify the packaged app before publication; require build/audit checks before the release job.
- Replace source-only installation wording with app download and installation instructions.
- Bump application version to 0.3.1 / build 4. Developer ID signing and notarization are not included.

## 0.3.0 — macOS runtime compatibility

- Accept macOS 13 or later on Apple silicon without a fixed build or framework UUID.
- Validate required native symbols, classes and callable method types at runtime.
- Ignore compiler stack sizes/offsets while rejecting incompatible argument/return types.
- Keep build numbers as diagnostics, with a fallback if the build cannot be read.
- Add type-check regression tests and macOS 15/26 CI coverage.
- Bump application version to 0.3.0 / build 3; additional OS versions remain physically unverified.

## 0.2.0 — expanded legacy iPad eligibility

- Enable iPad Air 2 and iPad mini 4, Wi-Fi and cellular, alongside iPad (5th generation).
- Cover every iPad model capable of iPadOS 13 or later without official Sidecar support.
- Preserve native eligibility and exact Mac build/framework/ABI guards.
- Add model-policy regression coverage and document model identifiers and receiver OS limits.
- Bump the app to version 0.2.0 / build 2. Newly enabled models remain experimentally allowlisted, not physically verified.

## 0.1.0 — initial experimental preview

- Native menu bar app with device selection and connect/disconnect controls.
- Caller-local support for genuine iPad 5 discovery objects; no system patch.
- Runtime compatibility checks for the native API.
- Remembered device, optional one-shot startup connection and normal Login Items integration.
- Existing-session protection, bounded request/cleanup and stale-callback handling.
- Privacy-limited diagnostics, read-only self-check and safe UI preview.
- Source build, install and release packaging scripts; mock lifecycle tests and CI.

Historical physical validation covers iPad (5th generation) on iPadOS 16.7.16. Version 0.4.0 has been user-tested over wired and wireless connections. Public Developer ID signing/notarization and further compatibility testing remain outstanding.

### Release audit hardening (2026-10-31)

- Reject malformed/oversized discovery metadata and ambiguous identifiers.
- Bound and fuzz-check framework UUID load-command parsing.
- Prevent preferred-device writes in safe preview.
- Refuse installer symlinks and existing destinations; verify before copying.
- Build in a fresh temporary bundle, avoiding stale executable resources.
- Package individual reviewed source files with anonymous archive ownership.
- Add sanitizer, negative filesystem and static-analysis checks, privacy and
  provenance documentation, and a credential-free public-source CI bootstrap.

### Release audit hardening (2026-10-31)

- Reject malformed/oversized discovery metadata and ambiguous identifiers.
- Bound and validate framework UUID load-command parsing.
- Prevent preferred-device writes in safe preview.
- Refuse installer symlinks and existing destinations; verify before copying.
- Build in a fresh temporary bundle, avoiding stale executable resources.
- Package individual reviewed source files with anonymous archive ownership.
- Add sanitizer, negative filesystem and static-analysis checks, privacy and
  provenance documentation, and a credential-free public-source CI bootstrap.
