#!/usr/bin/env python3
"""Package only individually reviewed files, without following symlinks."""
import pathlib
import sys
import tarfile

root = pathlib.Path(__file__).resolve().parent.parent

def reviewed_files():
    names = (root / 'public-files.txt').read_text().splitlines()
    if names != sorted(set(names)) or 'public-files.txt' not in names:
        raise ValueError('Manifest must be sorted, unique, and include itself')
    for name in names:
        path = pathlib.PurePosixPath(name)
        if not name or path.is_absolute() or '..' in path.parts or str(path) != name:
            raise ValueError('Invalid manifest path')
        target = root / name
        if any(p.is_symlink() for p in (target, *target.parents)) or not target.is_file():
            raise ValueError('Manifest requires regular, non-symlink files')
    return names

if __name__ == '__main__':
    names = reviewed_files()
    if len(sys.argv) == 2 and sys.argv[1] == '--check':
        print(f'PASS: {len(names)} individually allowlisted public files')
    elif len(sys.argv) == 2:
        output = pathlib.Path(sys.argv[1]).absolute()
        if any(p.is_symlink() for p in (output, *output.parents)):
            raise ValueError('Refusing symlink output')
        with tarfile.open(output, 'x:gz', format=tarfile.PAX_FORMAT) as archive:
            for name in names:
                info = archive.gettarinfo(str(root / name), arcname=name)
                info.uid = info.gid = 0
                info.uname = info.gname = ''
                info.mtime = 0
                info.pax_headers = {}
                with (root / name).open('rb') as stream:
                    archive.addfile(info, stream)
    else:
        raise SystemExit('Usage: source-archive.py --check | OUTPUT.tar.gz (new file)')
