# Apple IP and provenance review

| Material | Classification | Publication treatment |
|---|---|---|
| App UI, session state machine, tests, build/install/package scripts and generated geometric icon | 1 — original SideHustle implementation | Include, subject to owner authorship/MIT confirmation. |
| SCBridge private selector/type declarations, native device policy, ABI/UUID checks | 2 — independently written interoperability code | Include technically reviewed small caller-side wrapper; jurisdiction-specific legal review remains. |
| SidecarPatcher/free-sidecar (GPL-3.0), FeatureUnlock/FeatureUnlock-Tahoe (BSD-3-Clause) research checkouts | 3 — third-party open source | Excluded; inspect licenses again before importing any code. No runtime dependency. |
| Original local harnesses, behavioral reports, assembly analysis | 4 — generated/original analysis | Raw evidence excluded. Sanitized historical validation documentation retained. |
| Extracted SidecarCore, SidecarUI, Sidecar, SidecarRelay, ContinuityDisplay, patched NONDEPLOYABLE prototype, Apple bundle metadata and disassembly | 5 — proprietary material/legal review | Preserve privately outside repository; exclude from Git and source artifacts. |

The local research/extracted directory contains 16 files, including macOS and iPadOS 16.4/16.7.16 components. A second private research location contains related evidence. No firmware, dyld cache, Apple executable, extracted library/resource/private header file or copied disassembled implementation was found in the app's indexed source. The existing generated app links installed Apple frameworks; those libraries are not bundled. No iPad-side receiver is shipped.

All app source and its local research harness were read. Common code implements API calls, ABI validation and caller policy rather than the disassembled Apple implementation. This is a technical provenance assessment; it cannot prove independent authorship or license ownership. Obtain owner attestation for code/icon origin and retain external human legal review for reverse-engineering/private-API publication as appropriate.

THIRD-PARTY-NOTICES.md records reviewed research licenses. The MIT license already existed and was preserved, not newly selected by the auditor. Confirm ownership/choice or select a compatible alternative before publishing.

Name screening found prior software using SideHustle App: an [SEC-hosted company filing](https://www.sec.gov/Archives/edgar/data/1789874/000167025420000668/document_5.pdf) discusses the app and related IP. This is an obvious naming-review item, not a determination of active trademark rights, classes, territory or infringement. Owner must decide on naming/formal clearance. Apple logos/Sidecar artwork are absent; the icon comes from original geometric drawing code and the UI references an installed system symbol. Non-affiliation/non-endorsement is explicit. This report is not legal advice or trademark clearance.
