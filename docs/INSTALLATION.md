# Install, remove and recover

Build as an ordinary user, without sudo, using Xcode/Command Line Tools:
`bash scripts/test.sh`, then `bash scripts/build.sh`. The build creates only
application-owned output under build/. Local signatures are ad-hoc. Python 3 is
also needed for release packaging and filesystem regression tests.

`bash scripts/install.sh` verifies the source signature and copies the app to
~/Applications/SideHustle.app. An optional absolute .app path selects another
user-writable location. Existing destinations and symlink ancestors are rejected.
No system files are changed and nothing is opened or registered automatically.
The scripts are intended for a trusted user-owned checkout, not a hostile shared
writable directory. They do not provide a privileged cross-user installation service.

If copying/verification fails, the new destination may be incomplete. Move only
that newly created SideHustle app aside, rebuild and retry. An interrupted install
may also leave created parent directories. There is no automatic deletion or
rollback of user files. For an upgrade, quit, move the previous app to a safe
location and install into the now-absent path. Restore the old app manually if
needed, preserving its bundle identifier and normal OS security checks.

To remove: disconnect in the app or standard Displays settings, disable Open at
login in the app or macOS Login Items, quit and move the installed app to Trash.
Quitting alone leaves an established native session running. Optional preference
cleanup: `defaults delete io.github.sidecarbridge.app` as the same user, after quit.
This removes only this bundle's preferred UUID/startup setting. Remove diagnostic
exports and local build/dist outputs yourself if no longer needed. No pairing
records, Apple frameworks or Continuity settings need deleting or restoring.

No SIP, authenticated-root, AMFI, Gatekeeper, library-validation, screen-recording
or Accessibility changes are installation steps. Do not disable them to work
around errors. Signed/notarized binary distribution is a separate release gate.
