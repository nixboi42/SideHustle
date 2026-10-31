# Secrets and personal-data audit

Gitleaks 8.30.1 and TruffleHog 3.99.7 ran locally. Downloads were verified against SHA-256 digests from GitHub release metadata. No credential verification requests, scanner update checks or source uploads were made. Raw scanner output is outside the proposed repository.

Scanned original current/ignored files, archive-expanded source and ZIP payloads, and every stored blob including nine dangling objects. At the original audit there was no Git commit history or branch/tag content to omit: the repository was unborn. No submodules, LFS objects or remote configuration found. Final exact manifest, staged source bytes and generated artifacts were rescanned; see TEST-RESULTS.md. Git metadata is not a release artifact.

Results: no confirmed secrets and no Gitleaks/TruffleHog credential candidates. Targeted binary/text checks covered credential markers, private key/certificate/profile formats, personal home paths, email addresses, private IPs, device-ID forms and debug artifacts. Manual source review checked logs, persistence, credentials and endpoint usage. Device model/build/framework UUID values are public compatibility constants, not device serials or secrets.

Confirmed personal data: the original ignored dist source archive has local account/group names in all 24 tar headers. Do not publish that old archive. Fixed packaging zeros uid/gid, clears names and removes extended source metadata. Original source files did not reveal personal email, phone, serial, ECID, UDID, pairing record or credentials. Surrounding private hardware evidence contains identifying device/account context and is excluded; it was not comprehensively secret-audited for publication.

No revocation/rotation is currently indicated because no real exposed credential was found. If another scanner or human finds a credential, stop release, revoke/rotate through its issuer and separately decide history remediation. Ignoring a file never erases history. No Git history was rewritten. Scanner silence is bounded evidence, not proof of absence.

## Source-preparation rescan

Before first-commit preparation, 56 non-Git files, two existing release archives
(47 source members with no named owners; 10 app ZIP members), and all 95 stored
Git objects (77 blobs and 18 trees) were inventoried. Current files/archives and
offline TruffleHog returned no finding. Gitleaks identified the already triaged
generic-key false positive in one obsolete audit-prose blob; it is not a credential.
That unreachable blob is preserved privately and excluded from publication transport. These counts describe the input audit repository,
not the later reachable-only publication bundle. Authorized public GitHub handle
and noreply metadata are intentionally public; private local identities are not
used. A private receipt records final commit/object/archive scan results.
