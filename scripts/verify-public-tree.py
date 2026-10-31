#!/usr/bin/env python3
"""Compare the exact Git index with the individually reviewed source manifest."""
import hashlib
import pathlib
import subprocess
import sys
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from importlib import util
spec = util.spec_from_file_location('source_archive', pathlib.Path(__file__).with_name('source-archive.py'))
module = util.module_from_spec(spec)
spec.loader.exec_module(module)
root = module.root
names = module.reviewed_files()
tracked = subprocess.check_output(['git', '-C', str(root), 'ls-files', '-z']).decode().split('\0')[:-1]
if sorted(tracked) != names:
    raise SystemExit('FAIL: index differs from public-files.txt; review and stage the intended files')
for name in names:
    staged = subprocess.check_output(['git', '-C', str(root), 'show', ':' + name])
    if staged != (root / name).read_bytes():
        raise SystemExit('FAIL: unstaged changes in a public file')
print(f'PASS: index and working contents match all {len(names)} reviewed public paths')
