# macOS privilege audit

No root helper, daemon, LaunchAgent plist, custom XPC service, entitlement file, injection, interposition or system patch exists in the source. dlopen uses a fixed absolute installed SidecarCore path with RTLD_LOCAL. No plugin search path or user-supplied library path is accepted. Library remains loaded while native objects/callbacks can use it; no dangling dlclose lifecycle.

Normal Apple Account/2FA, trust and service authorization remain prerequisites. The compatibility override is caller-local, limited to genuine native iPads matching native eligibility or iPad6,11/iPad6,12; identity and unrelated Continuity state are not modified. No XPC caller-validation code is applicable because no custom server is exposed.

Build/install scripts reject root execution and linked output paths. App installation is user-space. Open-at-login is explicit SMAppService opt-in, with OS approval status shown. It is the only persistence feature, and can be disabled through normal Login Items. No Accessibility or Screen Recording request is made by this wrapper; native service permission behavior remains Apple's responsibility.

Local builds use ad-hoc signing, without Hardened Runtime by default; Developer ID branch requests runtime/timestamp, with no bypass entitlements. Developer ID, notarization, library-validation behavior under distribution and clean Gatekeeper launch remain untested. No assertion of notarization readiness. SIP/authenticated root/AMFI/Gatekeeper and the current Mac's security configuration were not changed. Do not weaken protections to make unsupported builds work.
