# Test results — 2026-10-31

Audit host: Apple silicon macOS, Xcode macOS SDK 27.2. Validation is local, without Apple signing credentials or device connection requests. Logs and raw evidence are retained privately outside the source tree.

| Check | Result | Scope |
|---|---|---|
| Original 18 source files + 39 non-Git files, refs and all 27 blob objects | PASS | Source/manual review; unborn repo, zero commits/tags/remotes. |
| Gitleaks 8.30.1 and TruffleHog 3.99.7 | PASS | No credential candidates in original files, expanded original archives and all stored blobs; final source/artifact rescan separately recorded. |
| Lifecycle unit/negative tests | PASS | Model policy, prior session, double connect/disconnect, errors/no retry, success/disconnect, stale/duplicate/background callback, 25 repeated cycles, connect/cleanup timeout. |
| ASan + UBSan | PASS | Same tests and 10,000 deterministic malformed load-command spans, no sanitizer finding. This is fuzz smoke testing, not exhaustive coverage. |
| Discovery boundaries | PASS | Nil/wrong collection type, 129 entries, wrong name/identity type, empty model, 257-character name, valid nil-name fallback. |
| UUID parser bounds | PASS | Expected/changed UUID, null span, truncated/zero/oversized command plus deterministic malformed spans. |
| Clang static analyzer | PASS | All four Objective-C implementation/test/icon translation units; no diagnostics. |
| Filesystem regression suite | PASS | Exact archive content, normalized owner metadata, manifest-link rejection, existing/dangling/ancestor/install/build link refusal. |
| Clean source extraction build/tests | PASS | Built from only the 47 public-files.txt paths in an independent temporary directory; ordinary tests and temporary install/signature verification passed. |
| Generated ad-hoc arm64 signature | PASS | codesign --verify --strict; no Developer ID identity used. |
| iconutil inside restricted sandbox | FAILED ENVIRONMENT ATTEMPT | Reported Invalid Iconset; same build passed outside sandbox. Not counted as successful sandbox execution. |
| CI hosted runs | SKIPPED | No GitHub upload/account modification authorized. Local workflow shell/syntax review only. |
| New physical iPad connections, sleep/unplug, multiple iPads, reconnection transport | SKIPPED | No device actions authorized; historical evidence only, not patched-source results. |
| Login registration / startup / reboot | SKIPPED | No host preference/service changes. |
| Developer ID, notarization, Gatekeeper distribution | SKIPPED | Separate credentials/authorization and clean-Mac validation needed. |
| LeakSanitizer/Instruments, exhaustive fuzzing, every OS version | SKIPPED | ASan/UBSan and lifecycle smoke coverage do not replace them. |

Private Apple entry calls are synchronous; no simulated test proves they cannot hang the main queue. Transport/authentication/decoding are in Apple services and were not fuzzed. User-driven native display behavior from the historical report is not a new audit test.

Final verification: the 47-file manifest and exact staged bytes were checked, all
source archive entries matched those bytes, and archive owner names/IDs were empty/zero.
Bash syntax, Python compilation and workflow YAML parsing passed. Final source,
archive payloads and generated app were checked with both secret scanners; no
credential candidate was found. Manual checks found no personal owner metadata in
the new source archive. The clean-build and audit-build app executable bytes matched
in this one local comparison; independent toolchain reproducibility is not claimed.

An initial packaging attempt after remediation failed on macOS Bash 3's treatment
of an empty array under nounset; the test-script flags array was corrected and
packaging was rerun successfully. Initial negative test development also exposed a
nullable-annotation compiler error and intentional symlink rejection of /var's
system alias; both harness issues were corrected before the passing final runs.
Those failed attempts are not counted as passed checks.

The first final-document scan flagged audit prose as a generic API key. Manual
triage confirmed it was the scanner names in an audit sentence, not a credential;
the prose was rewritten without adding a scanner exemption. A fresh scan was run.
The app ZIP omits resource-fork/extended-attribute payloads; its extracted signature
is verified to ensure the normal app files suffice.

## Final source-release preparation

Fresh checks are run against a clean clone of the single-root-commit publication
bundle. Exact commands, exit codes, final scanner results, source archive hashes
and commit/tree closure counts are kept in a private receipt outside this tree.
The publication procedure does not claim hosted CI, new hardware, Developer ID,
notarization or Gatekeeper results. Public documentation changes do not alter the
previously audited native implementation. No hardware request is made.
