# Source release updates

## v0.2.0

The owner requested the expanded legacy-iPad allowlist, a push to GitHub and a new
tag. Version 0.2.0 / build 2 includes Air 2, mini 4 and iPad (5th generation), both
radio variants. This remains a source-only experimental preview. No new hardware
validation, signing or notarization is claimed. Inspect hosted CI for the exact
source commit before tagging; document any unavailable checks explicitly.

The following section records the historical initial-publication procedure and
its original gates; it is not a new approval requirement for this authorized update.

---

# Source publication procedure — v0.1.0

Status: locally prepared, not published. Proposed title: **SideHustle v0.1.0 —
experimental source preview**. Keep application version 0.1.0 / build 1. Do not
create the tag until the final source commit is approved.

Proposed GitHub repository description:

> Experimental macOS menu bar app for native Sidecar on a narrowly reviewed iPad 5 configuration. Source-only preview; private APIs, no system patch.

## Owner gates

1. Confirm rights/authorship for code, tests, scripts, documentation and icon;
   authorize the existing MIT license for those contributions. Apple components
   and external research licenses are excluded from that grant.
2. Decide whether to retain SideHustle after naming/provenance/legal review.
3. Choose repository owner/name and accept the current stable bundle identifier
   `io.github.sidecarbridge.app`, or request a reviewed pre-publication change.
4. Designate a monitored private vulnerability-reporting channel and enable it
   before accepting security reports. No security email has been invented.
5. Approve the exact root commit and its public GitHub noreply metadata; then
   separately authorize repository creation, push and source release.

Physical retesting of the hardened app is recommended. This source preview must
retain explicit unverified labels. No new device operation is part of this gate.
Signing/notarization/clean-Mac Gatekeeper and hosted CI have not passed.

## Local preparation already authorized

Inspect the 47-file manifest, staged bytes, source archive, all stored Git objects
and the prospective commit metadata. Create a single unsigned local root commit,
using the authenticated GitHub public handle and noreply address for both author
and committer. No global Git identity or signing setting is changed.

Only the commit's reachable object closure belongs in publication transport.
Generate a bundle containing only the reviewed branch, clone that bundle into a
fresh local directory, and verify one root commit, exactly the 47 manifest paths,
no alternates/shallow history, and no unreferenced objects. Build/mock-test that
clean clone using installed SDKs. Never copy the audit repository's .git directory,
use a mirror push, or import research archives. Older unreachable objects remain
preserved in the audit copy and are not part of the bundle.

A private preparation receipt outside the public tree records the exact commit,
tree, bundle checksum, clone location and fresh scan/build results. The source-only
archive contains the same 47 committed file contents with normalized tar ownership.
Build outputs, private evidence and binary ZIPs do not enter the commit or bundle.

## Exact future publication commands — NOT EXECUTED

Run only after the owner gates and explicit publication authorization. Substitute
the approved OWNER/REPOSITORY and the clean publication-clone path from the private
preparation receipt. Do not run this in the surrounding research workspace.

```sh
cd /ABSOLUTE/PATH/TO/CLEAN-PUBLICATION-CLONE
repo='OWNER/REPOSITORY'
description='Experimental macOS menu bar app for native Sidecar on a narrowly reviewed iPad 5 configuration. Source-only preview; private APIs, no system patch.'
# Obtain the expected immutable commit from the private preparation receipt.
expected='REVIEWED_COMMIT_SHA'
test "$(git rev-parse HEAD)" = "$expected"
test "$(git rev-list --count HEAD)" = 1
test -z "$(git status --porcelain)"
python3 scripts/verify-public-tree.py
git show --no-patch --format=fuller HEAD
git ls-tree -r --name-only HEAD
# Re-run the installed, reviewed secret scanner before publication.
gitleaks git --log-opts=--all --redact=100 --ignore-gitleaks-allow .
# Do not auto-initialize the remote with a README/license/gitignore.
gh repo create "$repo" --public --description "$description"
git remote add github "https://github.com/$repo.git"
git push github HEAD:refs/heads/main
```

After the push, enable private vulnerability reporting, secret scanning/push
protection as available, branch protection and required CI. Inspect actual hosted
run results; do not infer success from local tests. Before tagging, require the
hosted checks to pass or explicitly document failures/limitations and resolve them.
Confirm the default branch is main; set it using repository settings if necessary.

Only after the owner approves the source release and CI gate:

```sh
# Lightweight tag avoids introducing new annotated-tag identity metadata.
git tag v0.1.0 "$expected"
git push github refs/tags/v0.1.0:refs/tags/v0.1.0
gh release create v0.1.0 --repo "$repo" --verify-tag --prerelease \
  --title 'SideHustle v0.1.0 — experimental source preview' \
  --notes 'Experimental source-only preview for the exact reviewed macOS build and historical iPad6,11 evidence. The hardened candidate has local mock/build validation only; see README and CHANGELOG for tested and unverified capabilities. No app binary is distributed.'
```

No assets are attached: GitHub supplies tag source archives automatically. The
reviewed source commit is the authoritative snapshot. Do not upload local app ZIPs,
research, .git, raw audit evidence, signing identities or original archives. An
optional normalized source archive/checksum can be reviewed separately before any
additional upload authorization.

## Binary distribution — separate, deferred

Local builds are ad-hoc signed. scripts/package.sh rebuilds and creates local
preview binaries; do not use it as the source publication path. Developer ID
signing, notarization submission and distribution need separate authorization and
credentials. After a future signed build, notarize, inspect the log, staple and
validate, assess Gatekeeper on a clean Mac, then ZIP that same stapled app and
regenerate checksums. Rebuilding after stapling changes the artifact. No binary
readiness or byte-for-byte reproducible toolchain claim is made here.
