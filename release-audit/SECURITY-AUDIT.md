# Application security audit — 2026-10-31

Scope: all original 18 indexed files, all 39 original non-Git files including ignored build/dist files, all 27 Git blob objects (18 staged + 9 dangling), and the final individually enumerated source snapshot. No commits, tags, remotes, submodules or LFS were present. Surrounding private research was inventoried for exclusion and provenance, not treated as distributable source.

| ID | Priority | Original issue and impact | Remediation |
|---|---|---|---|
| SH-01 | P1 | Recursive directory allowlist could ship a new private file; source tar retained local account ownership in all 24 member headers. | Individual regular-file manifest; refuse links; anonymous uid/gid/names and zero source mtimes. Negative archive tests. |
| SH-02 | P2 | Existing-destination check missed dangling symlinks and permitted merging during a race; failed copy left an undocumented partial app. | Reject link ancestors/existing targets; verify source first; exclusive mkdir; document interrupted-copy recovery. Filesystem regressions. |
| SH-03 | P2 | Safe-preview selection wrote preferred UUID despite read-only claim. | Guard selection before preference write. Source/UI-path review; physical UI automation not performed. |
| SH-04 | P2 | Native discovery collections/names were not type/size checked, and duplicate UUIDs were ambiguous. | Fail closed, cap collections at 128, model/name lengths at 128/256, validate metadata, reject duplicate identities; invalid connected collection blocks connect. Unit boundary tests. |
| SH-05 | P2 | UUID load-command parser used pointer arithmetic with lengths before fully validating commands. | Bounded byte-span parser using memcpy; reject malformed/truncated/duplicate UUID commands and oversized spans; 10,000 deterministic malformed inputs under sanitizers. Validate sysctl string termination. |
| SH-06 | P2 | Build reused the prior app bundle and could retain extra executable/resources. | Compile/icon/sign into fresh temporary bundle, verify, replace only generated app; reject linked output paths. |
| SH-07 | P2 | Mutable checkout action introduced affected undici runtime dependency; OSV returned 11 advisories. Exploitability not established. | Remove Node checkout action; reviewed Git-only credential-free public fetch. No third-party Actions remain. |
| SH-08 | P3 | Incomplete release/privacy/compatibility documentation and floating runner label. | Add release documents, source gate, CI checks and explicit macos-15 runner scope. |

Totals: 0 P0, 1 P1, 6 P2, 1 P3; all eight repository remediations applied. No confirmed exploitable remote-code-execution or credential exposure found. Severity assesses the original issue, not proof of exploitation.

Reviewed ARC/block lifetimes, weak callbacks, generation invalidation, duplicate requests, existing-session guard, startup single attempt, timeout/cleanup and bounded diagnostic memory. No custom socket parser, decoder, XPC listener, privileged helper or subprocess invocation exists in the app. Native private calls remain synchronous at entry: a hung Apple service can block the main run loop and defeat timer deadlines. State can race with another Sidecar client; this wrapper has no atomic global session lock. These limitations need hardware review, not a claim of guaranteed cleanup.

System Mach-O bytes are trusted installed loader input; the parser accepts an explicitly readable span, not arbitrary pointers. Fuzz smoke coverage is not exhaustive fuzzing. No warning suppression added. Apple services own protocol authentication, video and input; they were not reverse-audited for vulnerabilities.
