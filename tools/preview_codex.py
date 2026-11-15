"""Illustrative documentation images, using actual Codex records (not game captures)."""
from pathlib import Path
import re
from lupa.lua51 import LuaRuntime
from PIL import Image, ImageDraw, ImageFont
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'dist/codex-previews'; OUT.mkdir(parents=True,exist_ok=True)
lua=LuaRuntime(unpack_returned_tuples=True)
lua.execute("A={}; function UnitFactionGroup() return 'Horde' end")
for name in ['ForeverRecipes.lua','Metadata.lua','MetadataQueries.lua','Relations.lua','Relationships.lua','LootReference.lua','ForeverReference.lua','LootSources.lua','Descriptions.lua','Data.lua']:
    lua.execute('assert(loadstring(...))("RaynnaCodex",A)',(ROOT/'RaynnaCodex'/name).read_text(encoding='utf8'))
A=lua.globals().A
recipes=list(A.Recipes.values())
mana=next(r for r in recipes if r[2]=='Lesser Mana Potion')
def plain(s): return re.sub(r'\|c[0-9a-fA-F]{8}|\|r','',str(s))
def values(rows): return [(plain(r.title),plain(r.detail or '')) for r in rows.values()]
font_path=Path('C:/Windows/Fonts')
def font(size,bold=False): return ImageFont.truetype(str(font_path/('segoeuib.ttf' if bold else 'segoeui.ttf')),size)
def image(name,title,summary,tab,rows,caption):
    canvas=Image.new('RGB',(960,910),'#11171b'); d=ImageDraw.Draw(canvas)
    gold='#e7c474'; beige='#e8dcc3'; muted='#b5a88d'; green='#84db94'
    d.text((48,26),"RAYNNA'S CODEX",font=font(28,True),fill=gold)
    d.text((48,66),caption,font=font(20),fill=beige)
    box=(90,115,870,822)
    d.rounded_rectangle(box,8,fill='#241b10',outline='#9f7734',width=3)
    d.rectangle((95,120,865,161),fill='#4b270c')
    d.text((112,127),"Raynna's Codex",font=font(20,True),fill=gold)
    d.text((695,127),'Back     Pin     x',font=font(18),fill=gold)
    d.rounded_rectangle((113,181,163,231),5,fill='#5a4930',outline=gold)
    d.text((126,192),'?',font=font(24,True),fill=gold)
    d.text((181,180),title,font=font(25,True),fill=beige)
    y=249
    for line in summary:
        d.text((113,y),line,font=font(19),fill=beige); y+=27
    for i,label in enumerate(['Uses','Sources','Recent','Links']):
        x=113+i*180
        d.rounded_rectangle((x,339,x+163,376),4,fill='#7a410f' if label==tab else '#4b1712',outline=gold)
        d.text((x+44,345),label,font=font(19,True),fill=gold)
    for i,(label,detail) in enumerate(rows[:6]):
        y=394+i*57
        if i==0: d.rectangle((106,y-3,846,y+50),fill='#51431b')
        d.rounded_rectangle((116,y+6,145,y+35),3,fill='#6a5738',outline=muted)
        d.text((158,y),label[:60],font=font(18,True),fill=green if tab=='Ingredients' else beige)
        d.text((158,y+25),detail[:78],font=font(15),fill=muted)
    d.text((113,753),'Forever reference data  |  Hold Shift to browse',font=font(17),fill=muted)
    d.rounded_rectangle((113,782,846,810),3,outline='#8b7450')
    d.text((125,783),'Search item name or ID',font=font(16),fill=muted)
    d.text((90,847),'Illustrative UI preview • real addon records • placeholder icons',font=font(17),fill=muted)
    canvas.save(OUT/name)
image('quest-sources.png','Kodo Skin Scroll',['Instructions for luring Frostmaw.','Given when accepting the quest; see its source below.'],'Sources',values(A.BuildSources(5838)), 'Quest connections and recorded sources')
image('recipe-ingredients.png','Lesser Mana Potion',['Ingredients for Lesser Mana Potion.','Click a material to explore its uses and sources.'],'Ingredients',values(A.IngredientRows(mana)),'Follow recipes into their individual materials')
uses=[row for row in values(A.BuildUses(3371)) if not row[0].startswith('[Quest]')]
image('material-uses.png','Empty Vial',['A crafting container used by several professions in Forever.','Browse recipes and the materials they consume.'],'Uses',uses,'Discover what a crafting material is used for')
print(OUT)
