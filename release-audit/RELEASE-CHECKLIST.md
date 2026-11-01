# Release checklist

> Historical audit of the initial source snapshot. Statements below about withheld publication, source-only distribution or pending owner authorization record that earlier audit. Current app downloads and release procedures are documented in [README](../README.md) and [Releasing](../docs/RELEASING.md). Current experimental binaries are ad-hoc signed, without Developer ID signing or notarization.


- [x] Preserve original source, staged index and private research.
- [x] Work in isolated audit copy on codex/release-security-audit.
- [x] Inspect all original source, ignored artifacts, refs and stored blobs.
- [x] Run established secret scanners without credential verification/uploads.
- [x] Exclude Apple binaries/disassembly/private diagnostics; record provenance.
- [x] Apply and regression-check eight repository findings.
- [x] Add privacy, install/uninstall, compatibility, contribution and security docs.
- [x] Review CI permissions/dependencies and add non-device validation.
- [x] Enumerate exact public files; review staged index and source archive.
- [ ] Owner confirms original authorship, MIT license and branding/legal decisions.
- [ ] Owner chooses final repository/security contact and stable bundle identity.
- [ ] Verify the locally prepared first root commit and private preparation receipt; approve its public noreply metadata before publication.
- [ ] Run GitHub CI only after explicit publication/account authorization.
- [ ] Independently test patched native behavior, multiple-device/sleep/error scenarios and Login Items with separate device authorization.
- [ ] For binaries: separately authorize Developer ID/notarization; validate on clean Mac; package the same reviewed signed/stapled app, regenerate checksums.
- [ ] Explicit final authorization before push, repository creation, uploads or release.
