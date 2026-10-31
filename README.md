# SideHustle

**Use native Sidecar on an unsupported iPad.**

SideHustle brings Apple's Sidecar to iPads that Apple leaves off its supported-device list, starting with **iPad 5**. Turn your iPad into a second display for your Mac using the built-in Sidecar experience—without installing an iPad app, patching system files or disabling SIP.

**Tested on iPad 5 running iPadOS 16.7.16.** Other device and OS combinations have not been verified. See [compatibility](#compatibility) before installing.

## Features

- Connect and disconnect your iPad from a Mac menu bar app.
- Extend your Mac's desktop using native Sidecar.
- Remember your selected iPad.
- Optionally open at login and make one connection attempt when your iPad becomes available.
- Keep using macOS Display Settings and the standard Sidecar controls.

No jailbreak or administrator privileges are required by SideHustle. Normal Apple Account and device-trust requirements still apply.

## Compatibility

| Device or system | Current status |
|---|---|
| **iPad 5, Wi-Fi (`iPad6,11`), iPadOS 16.7.16** | The only physically tested iPad/OS combination; native connection and a working second display were observed. |
| iPad 5, cellular (`iPad6,12`) | Enabled in the app, but untested. |
| Other unsupported iPads | Not enabled by the current release. |
| Apple-supported iPads | Apple's eligibility decision is retained; not separately tested with SideHustle. |
| **Apple silicon Mac, macOS 27.2 / build `26B123`** | Current runtime target. The app also checks the installed Sidecar framework for compatibility. |
| Other macOS builds or Intel Macs | Not supported by v0.1.0. |

SideHustle is intended to make Sidecar available on unsupported iPads. **The current release does not yet support a general macOS or iPadOS version range:** it deliberately stops on Mac builds other than `26B123`, and its additional device support is limited to iPad 5. The app's macOS 13 deployment target is not a claim that it runs on macOS 13–27.

The iPad 5 result comes from the original connection flow and a subsequent user session. Later hardening changes have automated test coverage but have not been physically retested. Login/startup behavior, Wi-Fi-only operation and reboot persistence are also unverified. USB attachment and trust were tested; that does not establish that all display traffic used USB.

See the [full compatibility matrix](docs/COMPATIBILITY.md) for details.

## Install

[v0.1.0](https://github.com/nixboi42/SideHustle/releases/tag/v0.1.0) is distributed as source. There is no prebuilt app download yet.

On a compatible Mac, install Xcode or Apple's Command Line Tools, then build and install:

```sh
git clone https://github.com/nixboi42/SideHustle.git
cd SideHustle
bash scripts/build.sh
bash scripts/install.sh
```

The installer places **SideHustle.app** in `~/Applications`. It refuses to overwrite an existing app and does not launch it or enable startup options automatically.

Local builds use ad-hoc code signing. An Apple Developer ID and notarization are not needed to build from source; no Developer ID signature or notarization is claimed for these builds. Do not disable macOS security protections to install the app.

## Connect your iPad

1. Sign in to the **same Apple Account** on your Mac and iPad, with **two-factor authentication** enabled.
2. Connect and unlock your iPad. If using USB, complete the normal **Trust This Computer** prompt.
3. Open **SideHustle** from `~/Applications`.
4. Select your iPad and click **Connect**.
5. Move a Mac window onto the iPad to use the extra display.

These are the normal [Apple Sidecar account and USB-trust requirements](https://support.apple.com/en-ie/102597); SideHustle does not bypass authentication or pairing.

To disconnect, use **Disconnect** in SideHustle or the standard macOS Sidecar controls. Closing the app window keeps it in the menu bar. **Quitting SideHustle leaves an established Sidecar session running.**

### Optional startup settings

After selecting your iPad, you can enable **Connect to this iPad once when the app opens** and **Open at login**. Both are off by default. Approve the login item in macOS settings if prompted.

Startup connection waits up to ten minutes for the selected iPad and makes one attempt. It checks for an existing Sidecar session before connecting and does not automatically retry failures. These convenience features are implemented, but their login/reboot behavior has not been hardware tested.

## Good to know

- SideHustle uses Apple's native Sidecar services. It does not permanently change Apple's supported-device list or guarantee that an unsupported iPad will appear in the standard menu after a reboot.
- macOS updates can change private Sidecar APIs. If the app reports an unsupported build or framework, use a compatible release rather than removing its checks.
- On iPadOS 16, Sidecar offers limited touch gestures; SideHustle does not add general finger-touch control of Mac apps.
- A connection timeout requests native cleanup and blocks further attempts in that app session. Check Display Settings before reopening. A stalled Apple service can also delay the app's UI and timers.

For connection problems, see [troubleshooting](docs/TROUBLESHOOTING.md). **Save Diagnostics** exports a limited report for you to review before sharing. Report vulnerabilities privately as described in [SECURITY.md](SECURITY.md); never post account credentials, device identifiers or pairing records.

## Uninstall

Disable **Open at login** in SideHustle or macOS Login Items, disconnect your display, quit the app and move **SideHustle.app** to Trash. No Apple system files or pairing records need restoring. See [installation and removal](docs/INSTALLATION.md) for optional preference cleanup.

## Privacy and development

SideHustle has no telemetry or automatic diagnostic uploads. Your preferred device UUID is stored locally. Apple's services handle Sidecar discovery, authentication and display transport. See [PRIVACY.md](PRIVACY.md).

Build/test instructions are in [CONTRIBUTING.md](CONTRIBUTING.md). The [security audit](release-audit/FINAL-REPORT.md) and [hardware validation notes](docs/HARDWARE-VALIDATION.md) document the implementation and testing limits. Hosted build/audit and secret-scanning checks passed for the initial source release; they do not replace physical-device testing.

## License

[MIT](LICENSE) for SideHustle's original code. Apple frameworks are supplied by macOS and are not redistributed.

SideHustle is independent and is not affiliated with or endorsed by Apple. Apple, Sidecar, macOS and iPad are trademarks of Apple Inc.
