"""Real generated data + mocked client tests; not an in-game visual certification."""
from pathlib import Path
from lupa.lua51 import LuaRuntime
ROOT = Path(__file__).resolve().parents[1]
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute((ROOT / 'tests/wow_mock.lua').read_text())
lua.execute('''
A = {}; SHIFT=false
local create=CreateFrame
function CreateFrame(kind,name,parent,template)
 local frame=create(kind,name,parent)
 if template=='OptionsSliderTemplate' then frame.Low=create(); frame.High=create(); frame.Text=create() end
 function frame:SetChecked(value) self.checked=value end
 function frame:GetChecked() return self.checked end
 return frame
end
function IsShiftKeyDown() return SHIFT end
function UnitFactionGroup() return 'Horde' end
C_Item={GetItemInfo=function(id)
 if id==3371 then return 'Empty Vial','item:3371',1,1,1,'Trade Goods','Other',20,'',134793,1 end
end}
function GameTooltip:GetItem() return 'Empty Vial','item:3371' end
''')
folder = ROOT / 'RaynnaCodex'
for line in (folder / 'RaynnaCodex.toc').read_text().splitlines():
    if line and not line.startswith('#'):
        lua.execute('assert(loadstring(...))("RaynnaCodex", A)', (folder / line).read_text(encoding='utf8'))
lua.execute('''
assert(#A.Recipes == 2090 and A.RecipeBuild=='1.60.1.70888')
RaynnaCodexDB={scale=0.8, history={765,3371}, enabled=true}
for _,frame in ipairs(Frames) do
 if frame.events and frame.events.ADDON_LOADED then frame.OnEvent(frame,'ADDON_LOADED','RaynnaCodex') end
end
assert(A.db.scale == 0.8 and A.db.history[1] == 765)
assert(RaynnaModsSettingsRegistry.pages.codex)
assert(A.ItemID('|Hitem:3371:0|h[Empty Vial]|h')==3371)
assert(A.ItemID(-1)==nil)
local uses=A.BuildUses(3371)
local minor=false
for _,row in ipairs(uses) do
 if row.recipe and row.recipe[1]==1244431 then
   minor=true
   assert(row.recipe[3]=='First Aid' and row.recipe[5]==118)
   local materials={}; for _,m in ipairs(row.recipe[6]) do materials[m[1]]=m[2] end
   assert(materials[3371]==1 and materials[2678]==1 and materials[2447]==1 and not materials[765])
 end
end
assert(minor, 'Empty Vial must explain Minor Healing Potion')
for _,recipe in ipairs(A.Recipes) do assert(recipe[1]~=57111, 'Turtle recipe contamination') end
assert(A.Summary(3371):find('several professions'))
assert(A.Summary(1708):find('1,345'))
local sources=A.BuildSources(3371)
local vendor=false
for _,row in ipairs(sources) do if row.kind=='Vendor' then vendor=true end end
assert(vendor, 'Vial vendors should be available standalone')
assert(A.BuildUses(99999999)[1].title=='No specific use recorded')
assert(#A.Search('Empty Vial')>0)
assert(A.Search('3371')[1].itemID==3371)
SHIFT=true
A.HandleHover(3371)
assert(A.currentItem==3371 and A.frame:IsShown())
A.HandleHover(765)
assert(A.currentItem==3371, 'Shift locks original item while crossing other items')
SHIFT=false
for _,frame in ipairs(Frames) do
 if frame.events and frame.events.MODIFIER_STATE_CHANGED then frame.OnEvent(frame,'MODIFIER_STATE_CHANGED') end
end
assert(not A.frame:IsShown())
SHIFT=true; A.HandleHover(765)
assert(A.currentItem==765)
A.ShowItem(3371,true); SHIFT=false; A.frame.OnUpdate(A.frame,0.1)
assert(A.frame:IsShown(), 'Pinned panel remains visible')
assert(A.db.history[1]==3371)
for id=1,60 do A.Remember(id) end
assert(#A.db.history==40 and A.db.history[1]==60)
A.SetScale(5); assert(A.db.scale==1.8)
A.SetScale(0); assert(A.db.scale==0.4)
SlashCmdList.RAYNNACODEX('3371'); assert(A.currentItem==3371)
SlashCmdList.RAYNNACODEX('hide'); assert(not A.frame:IsShown())
SlashCmdList.RAYNNACODEX('settings')
assert(RaynnaModsSettingsRegistry.selected=='codex')
local panel=RaynnaModsSettingsRegistry.pages.codex.frame
local scaleFound, toggleFound=false,false
for _,control in ipairs(Frames) do
 if control.parent==panel and control.kind=='EditBox' then
  control:SetText('125%'); control.OnEnterPressed(control); assert(A.db.scale==1.25)
  control:SetText('bad'); control.OnEnterPressed(control); assert(A.db.scale==1.25 and control:GetText()=='125%')
  control:SetText('150%'); control.OnEscapePressed(control); assert(control:GetText()=='125%')
  scaleFound=true
 elseif control.parent==panel and control.kind=='CheckButton' and control.pointArgs[2]==-55 then
  control:SetChecked(false); control.OnClick(control); assert(A.db.enabled==false)
  control:SetChecked(true); control.OnClick(control); assert(A.db.enabled==true)
  toggleFound=true
 end
end
assert(scaleFound and toggleFound)
RaynnaModsSettingsRegistry:SetAppearance('opacity',0.8)
assert(A.db.appearance.opacity==0.8)
A.ShowItem(3371,false)
for _,control in ipairs(Frames) do
 if control.parent==A.frame and control.labelText=='Recent' then control.OnClick() end
end
assert(not A.pinned, 'Recent must not pin the panel')
C_Map={GetAreaInfo=function(id) return id==12 and 'Elwynn Forest' end,
 GetMapInfo=function(id) if id==37 then return {name='Elwynn Forest',mapType=3} end end,
 CanSetUserWaypointOnMap=function(id) return id==37 end,
 SetUserWaypoint=function(point) WAYPOINT=point end,
 OpenWorldMap=function(id) OPEN_MAP=id end}
UiMapPoint={CreateFromCoordinates=function(map,x,y) return {map=map,x=x,y=y} end}
local ok=A.ShowSourceLocation({npcID=66})
assert(ok and OPEN_MAP==37 and WAYPOINT.map==37)
assert(math.abs(WAYPOINT.x-0.4182)<0.00001 and math.abs(WAYPOINT.y-0.6716)<0.00001)
assert(not A.ShowSourceLocation({npcID=99999999}))
local get=A.ReferenceMetadata.Npc.Get
A.ReferenceMetadata.Npc.Get=function() return {} end
assert(#A.SourceLocations(66)==0,'Preserve explicit empty provider corrections')
A.ReferenceMetadata.Npc.Get=get
local sources=A.BuildSources(3371); local found=false
for _,row in ipairs(sources) do if row.npcID==66 then found=true end end
assert(found,'Vendor IDs must reach portrait and waypoint lookups')
InCombatLockdown=function() return true end
assert(not A.ShowSourceLocation({npcID=66}), 'Map actions must not run during combat')
InCombatLockdown=function() return false end
C_Map.CanSetUserWaypointOnMap=function() return false end
WAYPOINT=nil
assert(A.ShowSourceLocation({npcID=66}) and WAYPOINT==nil,'Unsupported pins still open the zone map')
C_TooltipInfo={GetItemByID=function() return {lines={{leftText='Use: Client-provided effect.'}}} end}
assert(A.ItemDescription(1708)=='Use: Client-provided effect.','Client description takes priority')
for _,control in ipairs(Frames) do
 if control.parent==A.frame and control.labelText=='Sources' then control.OnClick() end
end
local portrait=false
for _,row in ipairs(Frames) do
 if row.entry and row.entry.npcID then assert(row.portrait.portraitKey); portrait=true end
end
assert(portrait,'Visible source rows must bind NPC portraits')
local supplies=A.BuildSources(5838); local scroll=false
for _,row in ipairs(supplies) do
 if row.questID==1136 and row.kind=='Quest supply' then assert(row.npcID); scroll=true end
end
assert(scroll,'Kodo Skin Scroll must show its quest acceptance source')
assert(A.Summary(5838):find('Melor Stonehoof'))
local trout
for _,recipe in ipairs(A.Recipes) do if recipe[2]=='Mithril Head Trout' then trout=recipe end end
assert(trout and #trout[6]==1)
local rows=A.BuildUses(trout[5]); local made
for _,row in ipairs(rows) do if row.action=='ingredients' then made=row end end
assert(made and made.title:find('Raw Mithril Head Trout',1,true))
A.pinned=false
A.ShowItem(trout[5],false)
A.ShowIngredients(trout)
assert(A.currentItem==trout[6][1][1] and not A.pinned)
A.GoBack(); assert(A.currentItem==trout[5])
local mana
for _,recipe in ipairs(A.Recipes) do if recipe[2]=='Lesser Mana Potion' then mana=recipe end end
assert(mana and #mana[6]>1)
A.ShowItem(mana[5],false); A.ShowIngredients(mana)
local materials=A.IngredientRows(mana)
assert(#materials==#mana[6] and materials[1].quantity==mana[6][1][2])
A.NavigateItem(materials[1].itemID)
assert(A.currentItem==materials[1].itemID and not A.pinned)
A.GoBack(); assert(A.currentItem==mana[5])
local visibleMaterials=0
for _,row in ipairs(Frames) do if row.entry and row.entry.quantity then visibleMaterials=visibleMaterials+1 end end
assert(visibleMaterials==#mana[6], 'Back restores clickable ingredient list')
A.frame.OnDragStart(); assert(not A.pinned and A.dragging)
A.frame.OnDragStop(); assert(not A.pinned and not A.dragging)
for _,control in ipairs(Frames) do
 if control.parent==A.frame and control.labelText=='Links' then control.OnClick(); assert(not A.pinned) end
end
A.frame.search:SetText('Empty Vial'); A.frame.search.OnEnterPressed(A.frame.search); assert(not A.pinned)
A.frame.pin.OnClick(); assert(A.pinned)
A.frame.pin.OnClick(); assert(not A.pinned)
local containers,objects=0,0
for id in pairs(A.ExtraItems) do
 for _,row in ipairs(A.AdditionalSources(id)) do
  if row.kind=='Container' then assert(row.itemID); containers=containers+1 end
  if row.kind=='Object' then assert(row.objectID); objects=objects+1 end
 end
end
assert(containers>0 and objects>0)
''')
print('PASS: recipe data, vial uses/vendors, unknown coverage, search, persistence, hover locking, pinning, scale, settings and commands')
# Compile every shipped Lua file under the actual target language version.
for file in folder.glob('*.lua'):
    lua.execute('assert(loadstring(...))', file.read_text(encoding='utf8'))
print('PASS: all runtime files compile in Lua 5.1')
if (ROOT/'RaynnaTracker/SettingsRegistry.lua').exists():
    assert (folder/'SettingsRegistry.lua').read_bytes() == (ROOT/'RaynnaTracker/SettingsRegistry.lua').read_bytes()
else:
    assert lua.globals().RaynnaModsSettingsRegistry.version == 2
print('PASS: shared settings bootstrap matches the existing packages')
