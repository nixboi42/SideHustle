Experimental prebuilt SideHustle for Apple silicon Macs running macOS 13 or later.

Download the `SideHustle-<version>-arm64.zip` asset, extract **SideHustle.app**, and move it to `~/Applications` or `/Applications`. The source archive and `SHA256SUMS` are attached separately.

The app is **ad-hoc signed, without Developer ID signing or notarization**. If macOS blocks it, review this release and use the normal Privacy & Security → Open Anyway option if available. Do not disable Gatekeeper or SIP.

- Runtime Sidecar API checks replace the old single-build/UUID restriction.
- Enables iPad Air 2, iPad mini 4 and iPad (5th generation), Wi-Fi and cellular variants, alongside Apple's native eligibility.
- Normal Apple Account, two-factor authentication and device trust are required.
- Additional models and OS versions remain physically unverified. See the compatibility matrix and hardware-validation notes in the tagged source.
- CI builds, tests and packages the app; no new physical connection, Developer ID signature or notarization is claimed.

SideHustle uses the Sidecar services installed with macOS. It does not redistribute Apple frameworks or patch system files. Private APIs may change after OS updates. This independent project is not affiliated with or endorsed by Apple.
