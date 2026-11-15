-- Short factual summaries, checked against Wowhead Forever on 2026-11-15.
-- Prefer the running client's item effect text when available. No wiki prose copied.
local _, A = ...
A.DescriptionSources = {
    [5838] = 'https://www.wowhead.com/forever/quest=1136/frostmaw',
    [1708] = 'https://www.wowhead.com/forever/item=1708/sweet-nectar',
    [3371] = 'https://www.wowhead.com/forever/item=3371/empty-vial',
    [118] = 'https://www.wowhead.com/forever/item=118/minor-healing-potion',
}
function A.Green(value)
    return '|cff78df87' .. tostring(value) .. '|r'
end
function A.ItemDescription(id)
    if id == 5838 then
        return 'Quest instructions for luring Frostmaw. Melor Stonehoof gives you this scroll when you accept Frostmaw; it is not a normal monster drop.'
    end
    if C_TooltipInfo and C_TooltipInfo.GetItemByID then
        local ok, data = pcall(C_TooltipInfo.GetItemByID, id)
        if ok and type(data) == 'table' and type(data.lines) == 'table' then
            for _, line in ipairs(data.lines) do
                local value = line.leftText
                if
                    (not issecretvalue or not issecretvalue(value))
                    and type(value) == 'string'
                    and (value:find('^Use:') or value:find('^Equip:'))
                then
                    return value
                end
            end
        end
    end
    if id == 1708 then
        local requirement = 'Requires level 25.'
        if UnitLevel and UnitLevel('player') < 25 then
            requirement = '|cffff7070' .. requirement .. '|r'
        end
        return 'Drink to recover '
            .. A.Green('1,345 mana')
            .. ' over '
            .. A.Green('27 seconds')
            .. ' while seated. '
            .. requirement
    elseif id == 118 then
        return 'A healing consumable restoring '
            .. A.Green('70-90 health')
            .. '. Cooldown: 2 minutes. Crafted with First Aid in Forever.'
    elseif id == 3371 then
        return 'A disposable crafting container for potions, oils and other recipes. Used by several professions in Forever; sold by supply vendors.'
    end
end
