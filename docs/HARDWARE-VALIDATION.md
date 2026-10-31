# Physical validation — 2026-10-31

| Item | Observed result |
|---|---|
| Mac | Apple silicon, macOS 27.2, build 26B123 |
| Installed SidecarCore UUID | 0892FBEC-B253-34DF-946C-BC97FC532F00 |
| iPad | iPad 5, iPad6,11 / J71tAP |
| iPadOS | 16.7.16 / 20H392 |
| Authentication | Same Apple Account and 2FA confirmed; Mac settings showed trusted devices |
| USB | Interface type 1, pairing validation success, TrustedHostAttached true |
| Discovery | Genuine SidecarDevice returned by native Display service |
| Native eligibility | False on the physical object; initial normal display list omitted it |
| Harness connection | One normal native API request, unchanged genuine object, nil/default config; completion success |
| Display | Added 960×768 external display as reported by CoreGraphics |
| Receiver | Opened on physical iPad; user saw Mac wallpaper/desktop |
| Cleanup | Native disconnect succeeded after 15 seconds; connected count returned to zero |
| Subsequent manual session | User connected from standard menu and confirmed changing window/pointer content |
| App preview | App compiled and launched; genuine-device discovery/self-check passed; UI subsequently showed successful native connection and connected state |

The original harness window contained no controlled changing-content stimulus. The explicit moving-window/pointer confirmation came from the subsequent user-started standard-menu session. No claim of instrumented frame-rate or latency measurement is made.

Mac logs showed successful media negotiation and AVCVideoStream-didStart with didSucceed=1 and null error. The iPad syslog diagnostic service opened normally but yielded no usable Sidecar events; receiver-side decoding, log receive/filter coverage and codec were not established. Anri1/UDPNWPath appeared in Mac logs; USB attachment/trust does not by itself prove exclusive wired media routing.

No patch was deployed and no security/identity/iPadOS changes were made. Standard-menu availability after the first connection is observed, but its persistence across reboot/replug and exact mechanism remain unproven.

The app has been visually inspected on this Mac. Login registration and automatic startup connection have not been agent-tested by changing system preferences or initiating additional sessions. They use the normal SMAppService path and require separate user choices. The original one-shot connection limit was respected by the agent; later user-driven sessions are separate.

This document intentionally omits device names, identifiers, serial numbers, Apple Account information, raw logs, private disassembly and Apple executable files. Local private research evidence is not part of the public package.

## Source-release cross-check

The retained private connection event evidence was reread during source preparation:
build/UUID guard passed; the original connection completed with success and error
code 0; a non-builtin 960×768 display appeared; connected count became 1; native
disconnect completed successfully and cleanup reported count 0. Separate preflight
evidence later still contained an external display, consistent with a separate
session but not proof of its origin. User observations remain attributed reports.
No new device request or live discovery was made during this verification. Raw
records and identifiers remain outside the public repository. These observations
do not validate the hardened app's new parser/discovery checks on physical hardware.
