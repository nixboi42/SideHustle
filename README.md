# SideHustle

A small Mac menu bar app that connects a genuinely discovered iPad through Apple's installed native Sidecar APIs. No system patch, device spoofing or iPad app is required.

**v0.1.0 — experimental source preview; not yet published.** Currently enabled only on Apple silicon with macOS build **26B123**, SidecarCore UUID `0892FBEC-B253-34DF-946C-BC97FC532F00`. Connection controls stop if the build, framework UUID or checked API signatures differ. A newer macOS update needs a fresh compatibility review; do not remove these guards to force it to run.

## What it does

- Choose an iPad and connect or disconnect from a native Mac window.
- Keep the app in the menu bar; closing its window leaves it available.
- Remember the chosen iPad locally.
- Optionally connect **once per app launch** when that iPad becomes available, waiting up to ten minutes.
- Optionally open at login through the normal macOS Login Items service.
- Open Display Settings and save a small diagnostic report without account details, device names/IDs or raw logs.

Both convenience options are off on a fresh installation. Startup connection checks for an existing Sidecar session and refuses a new request when one is reported. That check is not an atomic lock against other Sidecar clients. Connection errors do not trigger automatic retries. Quitting the app leaves established Sidecar sessions running.

Login Items and one-shot startup are implemented but have not been hardware validated. They do **not** permanently modify Apple's eligibility rules or guarantee that the standard menu will keep showing an unsupported model.

## Requirements and supported devices

- Apple silicon Mac on the exact reviewed build above, with Apple's Sidecar components present.
- The same Apple Account on both devices, using two-factor authentication.
- For USB: unlock the iPad and use the ordinary “Trust This Computer” flow yourself.
- A genuine iPad object returned by native Sidecar discovery. Finder visibility by itself is insufficient.

Apple-supported iPads retain Apple's native eligibility decision. The app additionally permits choosing `iPad6,11` and `iPad6,12` in its own caller logic. It does not rewrite their model or any identifier. **Physical validation covers only iPad6,11 / iPadOS 16.7.16 (20H392).** The cellular iPad 5 variant and other models have not received physical validation here.

See Apple's [Sidecar requirements and interaction guide](https://support.apple.com/en-ie/102597). iPadOS 16 supports limited finger gestures rather than general single-finger clicking of Mac windows. The app does not add touchscreen support or change iPadOS.

## Build and install

Install Apple's Xcode Command Line Tools or Xcode, and Python 3 (used only for release checks and packaging), then:

```sh
bash scripts/test.sh
bash scripts/build.sh
bash scripts/install.sh
```

The installer copies the app into `~/Applications/SideHustle.app`. It refuses to overwrite an existing app. It neither opens the app nor registers a login item. You can instead copy `build/SideHustle.app` into `/Applications` yourself.

Open the installed app. Choose your iPad and press **Connect**. Move a window onto the extended display to confirm changing content. If the standard screen-extension menu already works, you can keep using it.

To configure the experimental startup features (not hardware validated):

1. Select your iPad, then enable **Connect to this iPad once when the app opens**.
2. Enable **Open at login** in the installed app.
3. If macOS requests Login Items approval, use its normal settings panel. Denied registration is reported; the app does not work around it.

The startup preference applies on the next launch. It makes at most one connection attempt. If the iPad is absent, the app checks every 15 seconds for up to ten minutes; after a failure it waits for manual action. A successful session stays connected until you disconnect it through this app or the standard Sidecar controls.

### Signing

The default local build is **ad-hoc signed, not Developer ID signed or notarized**. It is suitable for building and testing on your own Mac. A downloadable public release still needs a maintainer's Developer ID signing and Apple notarization before a normal Gatekeeper-friendly installation can be claimed. Do not disable Gatekeeper or strip quarantine as an installation step.

For a maintainer-owned signing identity:

```sh
SIDECAR_SIGNING_IDENTITY='Developer ID Application: YOUR NAME (TEAMID)' bash scripts/build.sh
```

No entitlements are forged or requested. The app loads private APIs and is not intended for the Mac App Store. Signing does not turn those APIs into a supported public interface.

## Safe diagnostics

Optional compatibility/discovery check (contacts Apple's local services; zero connection requests or preference writes):

```sh
'build/SideHustle.app/Contents/MacOS/SideHustle' --self-check
```

Preview the app without allowing connect, disconnect, preference writes, startup-connection or login-item changes:

```sh
'build/SideHustle.app/Contents/MacOS/SideHustle' --safe-preview
```

Run diagnostics with ordinary local access. A sandbox can prevent native service discovery; empty results inside a sandbox are not a hardware-compatibility conclusion.

The wrapper itself does not capture your desktop, inspect account stores, access credentials, collect telemetry or upload anything. Apple’s native Sidecar services handle desktop streaming, discovery, authentication and transport; their network and privacy behavior is outside this wrapper’s implementation. Device names appear only in local UI; the preferred device UUID is saved in this app's local preferences. Diagnostic export is explicit and includes only build, event names, counts, timestamps and error domain/code. It excludes NSError descriptions/userInfo and stream configuration.

## Timeout and cleanup

Asynchronous completions have a 30-second deadline while the main run loop remains responsive. Entry into Apple's private API is synchronous; a hung service can stall the UI and its timers. A timeout issues one normal native disconnect, allows ten seconds for cleanup and disables further connection attempts in that process. A late remote connection is still possible: inspect standard Display Settings before reopening. Quit is deferred while an operation or its bounded cleanup is pending. The app never kills Apple's services or changes security settings.

## Validation

The original genuine-object one-shot harness successfully connected the physical iPad 5, created a 960×768 CoreGraphics-reported external display, opened the native receiver and disconnected cleanly. The user subsequently connected using the standard menu and confirmed visibly changing window/pointer content. These are historical observations from the original harness and user session,
not physical validation of the hardened release candidate. iPad6,12, natively
eligible models, Wi-Fi-only transport, startup/login behavior and reboot
persistence remain unverified. See [hardware validation](docs/HARDWARE-VALIDATION.md)
and the [compatibility matrix](docs/COMPATIBILITY.md) for evidence and limits.

The app has deterministic backend tests for existing-session protection, duplicate requests, failure/no automatic retry, timeout cleanup and late callbacks. GitHub Actions is configured to compile the app and run mock tests, but hosted CI has not run. It cannot validate real Sidecar hardware or Apple Account state.

## Source release preparation

The initial release is a source-only preview. Its exact 47-file manifest is
`public-files.txt`. Prepare a source archive without building or packaging an app:

```sh
mkdir -p dist
python3 scripts/source-archive.py dist/SideHustle-0.1.0-source.tar.gz
```

The archive command refuses an existing output. It uploads nothing. See the
[publication procedure](docs/RELEASING.md). Publish only the reviewed root commit;
the surrounding research and ignored build/dist directories are excluded.

`scripts/package.sh` separately builds a local app ZIP plus source/checksums. That
ad-hoc binary is not part of the initial public source release. Developer ID
signing, notarization and binary distribution have separate gates.

## Remove

Disable **Open at login** before removing the installed app, or disable it in macOS Login Items. Turn off the startup connection checkbox if desired. Quit, then move the app to Trash. An established Sidecar session can be disconnected using the standard menu. No system files need restoring.

## License

The existing MIT license is proposed only for contributions whose rightsholders authorize that grant; owner confirmation of authorship, rights and license choice is still required. It does not license Apple software or external research projects. Apple frameworks are loaded from the user's Mac and are not redistributed. This independent project is not affiliated with Apple.

## Compatibility, privacy and release status

No jailbreak, admin privileges or SIP changes are required by the implementation.
USB attachment/trust was observed; exclusive wired streaming and Wi-Fi-only operation
were not established. Do not weaken system security to attempt a connection.
See [compatibility](docs/COMPATIBILITY.md), [installation and removal](docs/INSTALLATION.md),
[troubleshooting](docs/TROUBLESHOOTING.md), [privacy](PRIVACY.md), and the
[release audit](release-audit/FINAL-REPORT.md). Historical physical tests precede
this audit; patched-source connection behavior has only been mock tested.

This project is independent and is not affiliated with or endorsed by Apple.
Apple, iPad, macOS and Sidecar are trademarks of their respective owner.
