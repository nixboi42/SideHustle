# Compatibility

| Configuration | Status | Evidence/limit |
|---|---|---|
| Apple silicon, macOS build 26B123 + exact checked framework UUID, iPad6,11 / iPadOS 16.7.16 (20H392) | Verified working historically | Original harness and later user session; see HARDWARE-VALIDATION.md. Hardened app not physically retested. |
| Hardened app discovery validation and connect lifecycle with fake backend | Partially tested | Compilation and simulated lifecycle only in this audit; no new discovery or connection requests. |
| iPad6,12 (cellular iPad 5) on reviewed host | Experimental | Explicit local allowlist; no physical validation. |
| Natively eligible iPads on reviewed host | Untested | Native eligibility retained; no broader hardware claim. |
| Wi-Fi-only or exclusively wired media routing | Untested | USB trust is historical evidence, not transport proof. |
| Other macOS builds/framework UUIDs; Intel Mac | Unsupported | Preview build/ABI/architecture guards; no bypass option. |
| iPad Air 2 (`iPad5,3`, `iPad5,4`) on reviewed host | Experimental | Wi-Fi/cellular allowlisted; no physical validation. |
| iPad mini 4 (`iPad5,1`, `iPad5,2`) on reviewed host | Experimental | Wi-Fi/cellular allowlisted; no physical validation. |
| Other natively ineligible models | Unsupported | Excluded by caller policy. |
| Login registration, approval, reboot persistence, automatic startup on hardware | Untested | User opt-in features, not exercised by this audit. |

No jailbreak or security reduction is implemented. Apple Account/2FA and ordinary
trust are prerequisites. No legacy iOS receiver is included. Native Sidecar owns
video, input and authentication. OS updates may break this private API integration.
The original report labels the host macOS 27.2 with build 26B123; this audit relies
on the exact build guard and has not independently certified the marketing version.


## Receiver model scope (v0.2.0)

The additional allowlist is the complete intersection of iPads capable of running
iPadOS 13 or later and models without official Sidecar support:

| Model name | Wi-Fi identifier | Cellular identifier |
|---|---|---|
| iPad Air 2 | `iPad5,3` | `iPad5,4` |
| iPad mini 4 | `iPad5,1` | `iPad5,2` |
| iPad (5th generation) | `iPad6,11` | `iPad6,12` |

Apple's [Sidecar requirements](https://support.apple.com/102597) include all iPad
Pro models, iPad (6th generation) or later, iPad mini (5th generation) or later,
and iPad Air (3rd generation) or later. The Air 2, mini 4 and iPad (5th generation)
can run iPadOS 13; earlier Air/mini/standard models cannot. See also Apple's
[iPad identification guide](https://support.apple.com/108043).

Install iPadOS 13 or later on the receiver. This is a model-capability allowlist,
not an OS-version check: the checked discovery API supplies no receiver OS version.
Native eligibility is still honored for other iPads. No model name is spoofed and
no framework is patched. Only the historical iPad6,11/iPadOS 16.7.16 combination
has physical evidence; newly enabled models and other receiver OS versions need
hardware testing. All existing host build/UUID/ABI guards remain mandatory.
