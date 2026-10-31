# Compatibility

| Configuration | Status | Evidence/limit |
|---|---|---|
| Apple silicon, macOS build 26B123 + exact checked framework UUID, iPad6,11 / iPadOS 16.7.16 (20H392) | Verified working historically | Original harness and later user session; see HARDWARE-VALIDATION.md. Hardened app not physically retested. |
| Hardened app discovery validation and connect lifecycle with fake backend | Partially tested | Compilation and simulated lifecycle only in this audit; no new discovery or connection requests. |
| iPad6,12 (cellular iPad 5) on reviewed host | Experimental | Explicit local allowlist; no physical validation. |
| Natively eligible iPads on reviewed host | Untested | Native eligibility retained; no broader hardware claim. |
| Wi-Fi-only or exclusively wired media routing | Untested | USB trust is historical evidence, not transport proof. |
| Other macOS builds/framework UUIDs; Intel Mac | Unsupported | Preview build/ABI/architecture guards; no bypass option. |
| Other natively ineligible models | Unsupported | Excluded by caller policy. |
| Login registration, approval, reboot persistence, automatic startup on hardware | Untested | User opt-in features, not exercised by this audit. |

No jailbreak or security reduction is implemented. Apple Account/2FA and ordinary
trust are prerequisites. No legacy iOS receiver is included. Native Sidecar owns
video, input and authentication. OS updates may break this private API integration.
The original report labels the host macOS 27.2 with build 26B123; this audit relies
on the exact build guard and has not independently certified the marketing version.
