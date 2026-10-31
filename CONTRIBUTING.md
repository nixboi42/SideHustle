# Contributing

Use Xcode or Command Line Tools and Python 3. Run `bash scripts/test.sh`,
`SANITIZERS=1 bash scripts/test.sh`, `python3 Tests/release-tests.py`,
`bash scripts/analyze.sh` and `bash scripts/build.sh`. Tests use a fake backend,
never a connected device. Do not initiate physical sessions or change security
settings as part of automated tests.

Keep changes small. Preserve exact build/UUID/ABI guards, normal Apple trust and
one-request/timeout semantics. Describe private API and privacy changes explicitly.
Do not contribute firmware, Apple executables, copied disassembly implementations,
extracted headers, pairing records or personal diagnostics. Document independently
written interoperability behavior and provenance. Add new public files explicitly
to `public-files.txt`, stage intended changes and run `python3 scripts/verify-public-tree.py`.
Never stage the surrounding research workspace. Report vulnerabilities privately
as described in SECURITY.md. Be respectful and constructive in collaboration.
