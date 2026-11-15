# Development and releases

Run `python -m pip install lupa cbor2 Pillow` for tests and data/documentation tools.
Run `python tests/test_codex.py` for Lua 5.1 regression tests with a mocked client.
Run `python tools/package_codex.py` for a runtime-only CurseForge ZIP in dist.
Saved variables, tests, documentation pictures and build caches are excluded.

`tools/build_codex_forever.py --refresh --questie-toc PATH` updates the MIT-licensed
Forever crafting snapshot and QuestieDB coordinate snapshot outside the game.
`tools/build_codex_relations.py --questie-toc PATH` regenerates expanded relationships.
Use the Forever TOC from a compatible QuestieDB installation. These scripts require
git, lupa and cbor2; retain all source/license notices and review generated diffs.
Other reference snapshots are bundled with their provenance in
RaynnaCodex/REFERENCE-SOURCES.txt. They are not refreshed by the crafting importer.
The preview renderer uses Windows Segoe UI fonts and produces illustrative images,
not screenshots. In-game UI checks still require a real client.

Do not distribute a repository source ZIP as an addon install. Use the player ZIP.
