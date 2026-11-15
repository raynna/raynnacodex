# Raynna's Codex

Standalone WoW Forever item reference, version 0.3.0. Hold **Shift** while hovering
an item in bags, equipment, a shop or a normal item tooltip. The first item stays
locked until Shift is released. Move into the panel to scroll; Pin keeps it open.
Existing Shift-click actions are not intercepted.

- **Uses:** related quests, how an item is crafted, recipes that consume it and
  camp actions. Hover a recipe for materials, tools and skill-up thresholds;
  click a Made with row to inspect its ingredients. A single material opens
  directly; multiple materials open a clickable quantity list. Back restores the
  previous item or ingredient list. Thresholds are not minimum learning requirements.
- **Sources:** monsters, vendors and quest rewards, including reference chances
  where known. Conditional and unknown probabilities are explicit.
- **Recent:** last 40 item IDs, saved per character across normal logout/reload.
  Clicking Recent does not pin the window or change an existing pin preference.
- NPC source portraits reuse Bestiary's session cache. Known display IDs and
  recent NPCs persist; rendered textures need to warm up again after reload.
  Unknown portraits show a question mark, never a guessed picture.
- Click an NPC/vendor source to add a waypoint and open its map. Repeat clicks
  cycle locations. Missing coordinates remain unknown; combat blocks map actions.
- Item descriptions prefer current client use/equip effects, with short sourced
  summaries for selected items. Numbers/chances are green, headings gold, item
  names use quality colors and failures/restrictions are red.
- Search item names or IDs. `/rc`, `/rc 3371`, `/rc Empty Vial`, `/rc settings`.
- Only the Pin button pins the window. Dragging, Recent, Links, search and item
  navigation preserve pin state. Manually opening with /rc keeps a normal browser
  window open without marking it pinned; Shift-hover panels retain hover dismissal.
- Ctrl+wheel scales; normal wheel scrolls. Drag to move. Preferences and
  dragged position persist. Escape → Settings → AddOns → Raynna's mods → Codex.
- Links lists the item page and reference providers; select one to copy its URL.

## Coverage and accuracy

This is an item encyclopedia foundation, not complete coverage of every game
system. **2,090 Forever crafting recipes and 8 camp uses** come from the Forever
1.60.1.70888 client/hotfix snapshot distributed by MIT-licensed DwarfExplorersBible.
The old Classic recipe index is no longer loaded. Recipe-book acquisition and
non-item enchantments are not fully covered. Classic loot remains a separately
labeled fallback, not verified Forever probabilities.
QuestieDB Forever metadata and selected Forever drop corrections are bundled.
A newer compatible installed QuestieDB can improve quest/vendor metadata; it does
not update the separately bundled crafting recipes or drop probabilities.
Locations cover 8,288 NPCs from QuestieDB Forever; newer installed coordinates
take precedence. Community coordinates do not guarantee an NPC is present in
the player's current phase.
Unknown items are never labeled useless or safe to sell.

Version 0.3.0 also imports omitted QuestieDB Forever relationships:
986 quest-supplied items, 173 prerequisite items and 3,716 items with object,
container or recipe-teaching fields. Object reference records cover 7,045 IDs.
Crafted products now list their ingredients under Sources as well as Uses.
Kodo Skin Scroll is given on accepting Frostmaw from Melor Stonehoof, rather than
being an ordinary monster drop. Its summary was cross-checked against
https://www.wowhead.com/forever/quest=1136/frostmaw .
`tools/build_codex_relations.py` rebuilds these relationships from QuestieDB's
Forever TOC; the input hash is recorded in Relations.lua. Newer optional provider
fields override bundled values, including explicit removals. Completely new
reverse quest associations still require rebuilding the snapshot.

WoW's addon environment does not provide general HTTP access. No wiki is scraped
in-game, no external service runs in the background, and no online freshness is
promised. The reproducible build tool `tools/build_codex_forever.py --refresh` fetches
the latest licensed Forever source outside the game; review and package the
output as an addon update. The normal build uses the cached revision. Existing
Bestiary generators maintain the quest and loot snapshots. Runtime files contain
the database, so reload does not require downloading anything.

Crafting source: https://github.com/masterred92/DwarfExplorersBible
Snapshot revision: ForeverRecipes.lua. MIT notice: LICENSE-ForeverRecipes.txt.
Selected description facts checked against Wowhead Forever on 2026-11-15:
https://www.wowhead.com/forever/item=1708/sweet-nectar
https://www.wowhead.com/forever/item=3371/empty-vial
https://www.wowhead.com/forever/item=118/minor-healing-potion
Quest and loot provenance and notices: REFERENCE-SOURCES.txt, LICENSE-QuestieDB.txt,
LICENSE-ClassicDB.txt and GPL-3.0.txt. Original Codex code is GPL-3.0-or-later.
No CraftLib (All Rights Reserved) code or data is redistributed.

Install the RaynnaCodex folder into Interface/AddOns. A new addon may require
restarting WoW before it appears in the AddOns list. No other addon is required.
