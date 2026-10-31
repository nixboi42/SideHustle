#!/usr/bin/env python3
"""Filesystem regression tests; operates exclusively in temporary directories."""
import importlib.util
import pathlib
import shutil
import subprocess
import tarfile
import tempfile

root = pathlib.Path(__file__).resolve().parent.parent
with tempfile.TemporaryDirectory(prefix='sidehustle-release-') as temporary:
    work = pathlib.Path(temporary).resolve()
    copy = work / 'project'
    shutil.copytree(root / 'scripts', copy / 'scripts')
    (copy / 'public-files.txt').write_text('public-files.txt\nscripts/source-archive.py\n')
    (copy / 'scripts' / 'PRIVATE-NOT-FOR-PACKAGE.txt').write_text('fixture only')
    output = work / 'source.tar.gz'
    subprocess.run(['python3', str(copy / 'scripts/source-archive.py'), str(output)], check=True)
    with tarfile.open(output) as archive:
        assert archive.getnames() == ['public-files.txt', 'scripts/source-archive.py']
        assert all(m.uid == 0 and m.gid == 0 and m.uname == '' for m in archive)
    # A listed link must fail, even when its target exists.
    (copy / 'public-files.txt').unlink()
    (work / 'manifest').write_text('public-files.txt\nscripts/source-archive.py\n')
    (copy / 'public-files.txt').symlink_to(work / 'manifest')
    result = subprocess.run(['python3', str(copy / 'scripts/source-archive.py'), '--check'], capture_output=True)
    assert result.returncode != 0
    destination = work / 'existing.app'
    destination.mkdir()
    marker = destination / 'keep'; marker.write_text('preserve')
    result = subprocess.run(['bash', str(copy / 'scripts/install.sh'), str(destination)], capture_output=True)
    assert result.returncode != 0 and marker.read_text() == 'preserve'
    destination = work / 'dangling.app'; target = work / 'must-not-exist'
    destination.symlink_to(target)
    result = subprocess.run(['bash', str(copy / 'scripts/install.sh'), str(destination)], capture_output=True)
    assert result.returncode != 0 and not target.exists()
    parent = work / 'linked'; parent.symlink_to(work)
    result = subprocess.run(['bash', str(copy / 'scripts/install.sh'), str(parent / 'target.app')], capture_output=True)
    assert result.returncode != 0 and not (work / 'target.app').exists()
    (copy / 'build').symlink_to(work)
    result = subprocess.run(['bash', str(copy / 'scripts/build.sh')], capture_output=True)
    assert result.returncode != 0
print('PASS: exact archive, anonymous archive metadata, manifest symlink, existing destination, dangling link, linked parent, linked build output')
