# Dependencies and supply chain

No package manager manifests, vendored code, external runtime libraries, submodules, LFS or downloaded runtime executables exist in the proposed source. Runtime dependencies are installed macOS frameworks/services and libc/libobjc. Build dependencies are Apple's compiler/SDK, shell utilities, iconutil, codesign, ditto and Python 3 standard library for packaging/tests. No install-time downloads or curl-to-shell steps.

The original workflow used actions/checkout v7.0.1. The GitHub API resolved it to commit 3d3c42e5aac5ba805825da76410c181273ba90b1. Its package-lock listed 24 production components. A live OSV batch query returned 11 advisories on undici 6.27.0. Advisory classes include TLS-option loss, HTTP injection/splitting and WebSocket/EventSource/encoding DoS. Version matching does not establish reachability through checkout; no exploit test was attempted.

The final workflow removes the action and its entire Node dependency tree. It uses installed Git, validated public GitHub repository/SHA environment values and HTTPS without a token. This supports public github.com repositories only; private repositories and GHES need a new reviewed checkout design. No third-party action pins remain. Dependabot's github-actions configuration is prepared but currently has no action dependencies to update.

Advisories removed with checkout: GHSA-2m5v-pch6-74hx, GHSA-3wwx-pv8p-q78v, GHSA-4qv8-2p9j-2685, GHSA-8xcm-r25x-g524, GHSA-9fm3-97px-rjf6, GHSA-m8rv-5g2x-5cg5, GHSA-qrxm-fqhp-jwvm, GHSA-r53p-7pc4-xj5r, GHSA-rfgv-xxqx-mfg5, GHSA-v3r7-h72x-cjcm, GHSA-xjj6-f33q-929c. Details: [OSV](https://osv.dev/list?q=undici).

CI downloads Gitleaks 8.30.1 from its official release and verifies a fixed Linux archive digest before execution. Updating the scanner version/digest requires review; Dependabot does not cover that literal download. Local Gitleaks/TruffleHog tools are not distributed. SHA checks prove agreement with retrieved release metadata, not independent publisher identity attestation. No Apple signing credentials were used.

No unresolved known advisory on a retained third-party package was identified, because none is retained. Apple/macOS, compiler, Git, Python, hosted-runner and scanner internals are platform/toolchain trust dependencies, not fully audited transitive components; maintain supported patched versions. No claim is made that the host OS or every scanner's internal dependencies are vulnerability-free. A platform-component CycloneDX inventory is included; exact platform versions belong to each build's evidence.
