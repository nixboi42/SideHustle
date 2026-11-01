# Compatibility

| Configuration | Status | Evidence/limit |
|---|---|---|
| Apple silicon, macOS build 26B123 (historical evidence), iPad6,11 / iPadOS 16.7.16 (20H392) | Verified working historically | Original harness and later user session; see HARDWARE-VALIDATION.md. Hardened app not physically retested. |
| Hardened app discovery validation and connect lifecycle with fake backend | Partially tested | Compilation and simulated lifecycle only in this audit; no new discovery or connection requests. |
| iPad6,12 (cellular iPad 5) on reviewed host | Experimental | Explicit local allowlist; no physical validation. |
| Natively eligible iPads on reviewed host | Untested | Native eligibility retained; no broader hardware claim. |
| Wi-Fi-only or exclusively wired media routing | Untested | USB trust is historical evidence, not transport proof. |
| Apple silicon, macOS 13 or later, other builds/framework UUIDs | Enabled with runtime API checks | Required symbols/classes/method types must match; no physical validation on additional OS versions. |
| macOS earlier than 13; Intel Mac | Unsupported | Minimum OS and arm64 build target. |
| iPad Air 2 (`iPad5,3`, `iPad5,4`) on reviewed host | Experimental | Wi-Fi/cellular allowlisted; no physical validation. |
| iPad mini 4 (`iPad5,1`, `iPad5,2`) on reviewed host | Experimental | Wi-Fi/cellular allowlisted; no physical validation. |
| Other natively ineligible models | Unsupported | Excluded by caller policy. |
| Login registration, approval, reboot persistence, automatic startup on hardware | Untested | User opt-in features, not exercised by this audit. |

No jailbreak or security reduction is implemented. Apple Account/2FA and ordinary
trust are prerequisites. No legacy iOS receiver is included. Native Sidecar owns
video, input and authentication. OS updates may break this private API integration.
The original report labels the host macOS 27.2 with build 26B123; the marketing version has not been independently certified. Version 0.3.0 no longer
uses that build or framework UUID to gate compatibility.


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
hardware testing. Runtime API/type checks and the macOS 13 minimum remain mandatory.

## Host compatibility (v0.3.0)

The arm64 app targets macOS 13.0 and later. Build numbers and framework UUIDs are
not compatibility requirements. Initialization requires SidecarCore, the native
eligibility and display-service symbols, the Sidecar service/manager/device
classes and the methods used for discovery and connection. Method checks compare
return/argument types and argument count, including block parameters; compiler
stack-frame sizes and argument offsets are ignored. Missing or incompatible APIs
disable connection controls before creating a service or requesting discovery.

CI runs mock lifecycle/type checks, static analysis and an arm64 app build on
macOS 15 and 26 runners. macOS 13 remains the deployment minimum. macOS 13
has no hosted runner in this matrix; the macOS 14 runner was removed after GitHub
cancelled it during its scheduled retirement brownout (retirement November 2, 2026).
Neither macOS 13 nor 14 has hosted test coverage. CI does not establish physical receiver compatibility or
validate private API behavior on every supported OS. The only physical evidence
remains the historical configuration above.
