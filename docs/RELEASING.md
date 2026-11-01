# Releasing SideHustle

GitHub Releases distributes an experimental prebuilt Apple silicon `.app` inside
a ZIP, a reviewed source archive and `SHA256SUMS`. The app targets macOS 13 or
later. Binaries are ad-hoc signed; no Developer ID signature, notarization or
clean-Mac Gatekeeper validation is claimed. Historical audit reports describe
the initial source snapshot, not the current distribution status.

## Publish a version

1. Update Info.plist's version/build, the changelog and README download link.
2. Push the reviewed commit and inspect the build/audit checks.
3. Tag that commit `v` followed by the application version and push the tag.
4. The tag-triggered release job waits for both macOS validation jobs and secret
   scanning, rebuilds on macOS 15, and packages the app with scripts/package.sh.
5. It extracts the ZIP and verifies the packaged app's signature, architecture,
   version and minimum OS, then checks SHA256SUMS. It creates a draft release,
   uploads the three assets, verifies their names and sizes, and publishes the
   release as an experimental prerelease only after the uploads succeed.

The release job has contents:write permission and uses GitHub's short-lived
workflow token only for the publish step. Pull requests and branch pushes cannot
run that job. Builds and audits have no write token. No third-party actions,
external signing credentials or notarization services are used.

If a publish step fails, inspect the draft and workflow logs before retrying.
Do not move a published tag or silently replace an existing release asset.
For local packaging, run `bash scripts/package.sh`; this creates artifacts under
dist/ without uploading them. The app version determines artifact names.

## Validation limits

CI covers mock lifecycle/type checks, static analysis, build/signature checks and
packaging. It does not initiate Sidecar sessions or prove physical compatibility
across all OS/device combinations. See COMPATIBILITY.md and HARDWARE-VALIDATION.md.
Developer ID signing and notarization require configured credentials and their
own validation; the current release workflow performs neither.
