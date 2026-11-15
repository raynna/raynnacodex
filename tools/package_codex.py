"""Package runtime-only Codex files and optionally install them without touching saves."""
import argparse
import re
import shutil
import zipfile
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
addon = ROOT / 'RaynnaCodex'
parser = argparse.ArgumentParser()
parser.add_argument('--install', type=Path)
args = parser.parse_args()
toc = addon / 'RaynnaCodex.toc'
version = re.search(r'^## Version: (.+)$', toc.read_text(), re.M)[1].strip()
files = [toc] + [addon / line for line in toc.read_text().splitlines() if line and not line.startswith('#')]
files += [addon / name for name in ('README.md', 'REFERENCE-SOURCES.txt', 'GPL-3.0.txt', 'LICENSE-ClassicDB.txt', 'LICENSE-QuestieDB.txt', 'LICENSE-ForeverRecipes.txt', 'Media/RaynnaParchment.tga')]
destination = ROOT / 'dist' / f'RaynnaCodex-{version}-CurseForge.zip'
destination.parent.mkdir(exist_ok=True)
with zipfile.ZipFile(destination, 'w', zipfile.ZIP_DEFLATED) as archive:
    for file in files:
        assert file.is_file(), file
        archive.write(file, 'RaynnaCodex/' + file.relative_to(addon).as_posix())
with zipfile.ZipFile(destination) as archive:
    assert archive.testzip() is None
    for file in files:
        assert archive.read('RaynnaCodex/' + file.relative_to(addon).as_posix()) == file.read_bytes()
if args.install:
    for file in files:
        target = args.install / 'RaynnaCodex' / file.relative_to(addon)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(file, target)
        assert target.read_bytes() == file.read_bytes()
print(f'{destination}: {len(files)} verified runtime files')
