local _, A = ...
local frame, rows, entries, offset = nil, {}, {}, 0
local tab = 'uses'
local view, activeRecipe, navigation = 'item', nil, {}
local function rememberView()
    navigation[#navigation + 1] = {
        item = A.currentItem,
        tab = tab,
        view = view,
        recipe = activeRecipe,
        entries = entries,
        offset = offset,
    }
    if #navigation > 40 then
        table.remove(navigation, 1)
    end
end
local function text(parent, size, x, y, width)
    local label = parent:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
    label:SetPoint('TOPLEFT', x, y)
    label:SetWidth(width)
    label:SetJustifyH('LEFT')
    label:SetTextColor(unpack(A.Theme.text))
    return label
end
local function button(parent, title, width, x, y, callback)
    local control = CreateFrame('Button', nil, parent, 'UIPanelButtonTemplate')
    control:SetSize(width, 20)
    control:SetPoint('TOPLEFT', x, y)
    control:SetText(title)
    control:SetScript('OnClick', callback)
    return control
end
A.Button = button
A.Label = text

local function rowTooltip(row)
    local entry = row.entry
    if not entry then
        return
    end
    local tip = A.tooltip
    tip:SetOwner(row, 'ANCHOR_LEFT')
    if entry.itemID and not entry.recipe then
        tip:SetHyperlink('item:' .. entry.itemID)
    else
        tip:AddLine(entry.title, 1, 0.82, 0)
        tip:AddLine(entry.detail or '', 0.9, 0.85, 0.7, true)
        if entry.recipe then
            tip:AddLine('Materials / Forever client data', 1, 0.82, 0)
            for _, reagent in ipairs(entry.recipe[6]) do
                tip:AddLine(A.Green(reagent[2]) .. ' x ' .. A.ItemInfo(reagent[1]), 0.9, 0.85, 0.7, true)
            end
            tip:AddLine(
                entry.action == 'ingredients' and 'Click to browse ingredients'
                    or 'Click to inspect the crafted item',
                0.6,
                0.8,
                1
            )
            if entry.recipe[9] then
                tip:AddLine(
                    'Yellow at ' .. entry.recipe[9] .. ' / grey at ' .. entry.recipe[10],
                    0.8,
                    0.75,
                    0.6,
                    true
                )
            end
            if entry.recipe[11] and #entry.recipe[11] > 0 then
                tip:AddLine('Required tools: ' .. table.concat(entry.recipe[11], ', '), 1, 0.7, 0.3, true)
            end
            tip:AddLine('Source: Forever client ' .. A.RecipeBuild, 0.8, 0.75, 0.6, true)
        end
        if entry.extra then
            tip:AddLine(entry.extra, 0.8, 0.75, 0.6, true)
        end
        if entry.npcID or entry.objectID then
            local locations = A.SourceLocations(entry.npcID, entry.objectID)
            if #locations > 0 then
                tip:AddLine('Click: map pin + open map', 0.45, 0.85, 1)
                local first = locations[1]
                local zone = C_Map and C_Map.GetAreaInfo and C_Map.GetAreaInfo(first.area) or 'Location'
                tip:AddLine(zone .. string.format(' / %.1f, %.1f', first.x, first.y), 0.8, 0.75, 0.6)
                tip:AddLine(
                    #locations .. ' recorded locations; repeat clicks cycle them.',
                    0.8,
                    0.75,
                    0.6,
                    true
                )
            else
                tip:AddLine('No recorded coordinates', 0.8, 0.75, 0.6)
            end
        end
    end
    tip:SetFrameStrata('TOOLTIP')
    tip:SetFrameLevel(frame:GetFrameLevel() + 20)
    tip:Show()
end

function A.Render()
    local visible = 7
    offset = math.max(0, math.min(offset, math.max(0, #entries - visible)))
    for index, row in ipairs(rows) do
        local entry = entries[index + offset]
        row.entry = entry
        row:SetShown(entry ~= nil)
        if entry then
            row.title:SetText(entry.title)
            row.detail:SetText(entry.detail or '')
            local icon = 'Interface\\Icons\\INV_Misc_Book_09'
            if entry.itemID then
                local _, itemIcon = A.ItemInfo(entry.itemID)
                icon = itemIcon
            end
            row.icon:SetTexture(icon)
            row.portrait:SetShown(entry.npcID ~= nil)
            A.SetBestiaryPortrait(row.portrait, entry.npcID, nil)
            row.icon:SetShown(entry.npcID == nil)
            row.title:SetTextColor(unpack(A.Theme.gold))
            if entry.itemID and ITEM_QUALITY_COLORS then
                local _, _, _, _, _, _, quality = A.ItemInfo(entry.itemID)
                local color = quality and A.Readable(quality) and ITEM_QUALITY_COLORS[quality]
                if color then
                    row.title:SetTextColor(color.r, color.g, color.b)
                end
            end
        end
    end
    frame.scroll:SetMinMaxValues(0, math.max(0, #entries - visible))
    frame.scroll:SetValue(offset)
    frame.scroll:SetShown(#entries > visible)
    frame.count:SetText(
        #entries > 0 and ((offset + 1) .. '-' .. math.min(offset + visible, #entries) .. ' / ' .. #entries)
            or 'No matches'
    )
end

function A.Refresh()
    if not frame or not A.currentItem then
        return
    end
    local id = A.currentItem
    local name, icon, _, _, _, _, quality = A.ItemInfo(id)
    frame.name:SetText(name)
    local color = quality and A.Readable(quality) and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality]
    if color then
        frame.name:SetTextColor(color.r, color.g, color.b)
    else
        frame.name:SetTextColor(unpack(A.Theme.gold))
    end
    frame.icon:SetTexture(icon)
    frame.summary:SetText(
        view == 'ingredients'
                and ('Ingredients for ' .. activeRecipe[2] .. '. Click any material to browse its uses and sources.')
            or A.Summary(id)
    )
    if view == 'item' then
        entries = tab == 'sources' and A.BuildSources(id) or A.BuildUses(id)
    end
    frame.source:SetText('Forever recipes / source-specific loot references')
    A.Render()
end

function A.ShowItem(id, manual, keepPosition)
    id = A.ItemID(id)
    if not id then
        return
    end
    A.currentItem = id
    A.manualOpen = manual or false
    view, activeRecipe = 'item', nil
    if not keepPosition then
        navigation = {}
    end
    A.Remember(id)
    offset = 0
    frame.pin:SetText(A.pinned and 'Unpin' or 'Pin')
    local level = GameTooltip and GameTooltip:GetFrameLevel() or 1
    for _, compare in ipairs({ ShoppingTooltip1, ShoppingTooltip2 }) do
        level = math.max(level, compare:GetFrameLevel())
    end
    frame:SetFrameLevel(level + 20)
    if not manual and not keepPosition then
        local x, y = GetCursorPosition()
        local scale = frame:GetEffectiveScale()
        frame:ClearAllPoints()
        frame:SetPoint('TOPLEFT', UIParent, 'BOTTOMLEFT', x / scale + 8, y / scale + 8)
    end
    A.Refresh()
    frame:Show()
end

function A.NavigateItem(id)
    rememberView()
    A.ShowItem(id, A.manualOpen, true)
end

function A.ShowIngredients(recipe)
    if #recipe[6] == 1 then
        A.NavigateItem(recipe[6][1][1])
        return
    end
    rememberView()
    view, activeRecipe = 'ingredients', recipe
    entries, offset = A.IngredientRows(recipe), 0
    A.Refresh()
end

function A.GoBack()
    local previous = table.remove(navigation)
    if not previous then
        return
    end
    A.currentItem = previous.item
    tab, view, activeRecipe = previous.tab, previous.view, previous.recipe
    entries, offset = previous.entries, previous.offset
    A.Refresh()
end

function A.SetScale(value)
    local left, top, previousScale
    if frame:IsShown() then
        left, top, previousScale = frame:GetLeft(), frame:GetTop(), frame:GetEffectiveScale()
    end
    A.db.scale = math.max(0.4, math.min(1.8, value))
    frame:SetScale(A.db.scale)
    if left and top then
        local ratio = previousScale / frame:GetEffectiveScale()
        frame:ClearAllPoints()
        frame:SetPoint('TOPLEFT', UIParent, 'BOTTOMLEFT', left * ratio, top * ratio)
        if A.pinned then
            A.db.position = { 'TOPLEFT', 'BOTTOMLEFT', left * ratio, top * ratio }
        end
    end
end

function A.CreateUI()
    frame = CreateFrame('Frame', 'RaynnaCodexWindow', UIParent, 'BackdropTemplate')
    A.frame = frame
    frame:SetSize(350, 462)
    frame:SetPoint('CENTER')
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata('TOOLTIP')
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag('LeftButton')
    frame:SetScript('OnDragStart', function()
        A.dragging = true
        frame:StartMoving()
    end)
    frame:SetScript('OnDragStop', function()
        A.dragging = false
        frame:StopMovingOrSizing()
        local point, _, relative, x, y = frame:GetPoint()
        A.db.position = { point, relative, x, y }
    end)
    local position = A.db.position
    if position then
        frame:ClearAllPoints()
        frame:SetPoint(position[1], UIParent, position[2], position[3], position[4])
    end
    A.SkinPanel(frame, true)
    text(frame, 12, 12, -9, 200):SetText("RAYNNA'S CODEX")
    button(frame, 'Back', 43, 220, -5, A.GoBack)
    frame.pin = button(frame, 'Pin', 45, 267, -5, function()
        A.pinned = not A.pinned
        A.manualOpen = false
        frame.pin:SetText(A.pinned and 'Unpin' or 'Pin')
    end)
    button(frame, 'x', 20, 317, -5, function()
        A.pinned = false
        A.manualOpen = false
        A.dismissed = true
        frame:Hide()
    end)
    frame.icon = frame:CreateTexture(nil, 'ARTWORK')
    frame.icon:SetSize(30, 30)
    frame.icon:SetPoint('TOPLEFT', 12, -34)
    frame.name = text(frame, 12, 49, -35, 284)
    frame.summary = text(frame, 11, 12, -72, 321)
    frame.summary:SetHeight(48)
    frame.summary:SetJustifyV('TOP')
    button(frame, 'Uses', 70, 12, -125, function()
        view = 'item'
        tab = 'uses'
        offset = 0
        A.Refresh()
    end)
    button(frame, 'Sources', 70, 86, -125, function()
        view = 'item'
        tab = 'sources'
        offset = 0
        A.Refresh()
    end)
    button(frame, 'Recent', 70, 160, -125, function()
        view = 'recent'
        entries = A.Search('')
        offset = 0
        A.Render()
    end)
    button(frame, 'Links', 70, 234, -125, function()
        view = 'links'
        entries = {
            {
                title = 'Wowhead Forever / this item',
                detail = 'Select to copy its web address',
                url = 'https://www.wowhead.com/forever/item=' .. (A.currentItem or 3371),
            },
            {
                title = 'Forever client crafting data',
                detail = 'Client build ' .. A.RecipeBuild,
                url = 'https://github.com/masterred92/DwarfExplorersBible/tree/' .. A.RecipeRevision,
            },
            {
                title = 'Quest and vendor metadata / QuestieDB',
                detail = 'Bundled 1.0.13; newer installed data when compatible',
                url = 'https://github.com/Questie/QuestieDB',
            },
            {
                title = 'Classic drop reference / cMaNGOS',
                detail = 'Classic 1.12; not verified Forever probabilities',
                url = 'https://github.com/cmangos/classic-db',
            },
        }
        offset = 0
        A.Render()
    end)
    for index = 1, 7 do
        local row = CreateFrame('Button', nil, frame)
        row:SetPoint('TOPLEFT', 12, -151 - (index - 1) * 35)
        row:SetSize(309, 34)
        row:SetHighlightTexture('Interface\\QuestFrame\\UI-QuestTitleHighlight', 'ADD')
        row.icon = row:CreateTexture(nil, 'ARTWORK')
        row.icon:SetPoint('TOPLEFT', 0, -4)
        row.icon:SetSize(24, 24)
        row.portrait = CreateFrame('Frame', nil, row)
        row.portrait:SetPoint('TOPLEFT', 0, -4)
        row.portrait:SetSize(24, 24)
        row.title = text(row, 11, 30, -3, 278)
        row.title:SetHeight(14)
        row.detail = text(row, 10, 30, -18, 278)
        row.detail:SetHeight(13)
        row.detail:SetTextColor(unpack(A.Theme.muted))
        row:SetScript('OnEnter', rowTooltip)
        row:SetScript('OnLeave', function()
            A.tooltip:Hide()
        end)
        row:SetScript('OnClick', function()
            if row.entry and row.entry.url then
                frame.search:SetText(row.entry.url)
                frame.search:SetFocus()
                frame.search:HighlightText()
            elseif row.entry and row.entry.action == 'ingredients' then
                A.ShowIngredients(row.entry.recipe)
            elseif row.entry and row.entry.itemID then
                A.NavigateItem(row.entry.itemID)
            elseif row.entry and (row.entry.npcID or row.entry.objectID) then
                local ok, message = A.ShowSourceLocation(row.entry)
                frame.source:SetText((ok and '|cff78df87' or '|cffff7070') .. message .. '|r')
                if ok then
                    frame:Hide()
                end
            end
        end)
        rows[index] = row
    end
    frame.scroll = CreateFrame('Slider', nil, frame, 'OptionsSliderTemplate')
    frame.scroll:SetPoint('TOPLEFT', 329, -153)
    frame.scroll:SetSize(12, 237)
    frame.scroll:SetOrientation('VERTICAL')
    frame.scroll:SetValueStep(1)
    for _, region in ipairs({ 'Low', 'High', 'Text' }) do
        if frame.scroll[region] then
            frame.scroll[region]:Hide()
        end
    end
    frame.scroll:SetScript('OnValueChanged', function(_, value)
        value = math.floor(value + 0.5)
        if offset ~= value then
            offset = value
            A.Render()
        end
    end)
    frame:EnableMouseWheel(true)
    frame:SetScript('OnMouseWheel', function(_, delta)
        if IsControlKeyDown() then
            A.SetScale(A.db.scale + delta * 0.05)
        else
            offset = offset - delta
            A.Render()
        end
    end)
    frame.count = text(frame, 10, 12, -399, 120)
    frame.source = text(frame, 10, 12, -416, 325)
    frame.search = CreateFrame('EditBox', nil, frame, 'InputBoxTemplate')
    frame.search:SetSize(320, 20)
    frame.search:SetPoint('TOPLEFT', 17, -435)
    frame.search:SetAutoFocus(false)
    frame.search:SetText('Search item name or ID')
    frame.search:SetScript('OnEnterPressed', function(self)
        view = 'search'
        entries = A.Search(self:GetText())
        offset = 0
        A.Render()
        self:ClearFocus()
    end)
    frame.search:SetScript('OnEscapePressed', function(self)
        self:ClearFocus()
    end)
    A.tooltip = CreateFrame('GameTooltip', 'RaynnaCodexDetailTooltip', UIParent, 'GameTooltipTemplate')
    frame:SetScript('OnHide', function()
        A.tooltip:Hide()
    end)
    A.SetScale(A.db.scale)
    frame:Hide()
end
