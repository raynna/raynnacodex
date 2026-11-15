local _, A = ...
local eventFrame = CreateFrame('Frame')
local lockedItem, shiftHeld

local function tooltipItem()
    if not GameTooltip or not GameTooltip:IsShown() then
        return nil
    end
    local ok, _, link = pcall(GameTooltip.GetItem, GameTooltip)
    return ok and A.ItemID(link) or nil
end

function A.HandleHover(item)
    if not A.db or not A.db.enabled or not IsShiftKeyDown() or A.dismissed or A.pinned then
        return
    end
    if lockedItem or (A.frame:IsShown() and A.frame:IsMouseOver()) then
        return
    end
    item = A.ItemID(item) or tooltipItem()
    if item then
        lockedItem = item
        A.ShowItem(item, false)
    end
end

local function releaseHover()
    if not IsShiftKeyDown() then
        lockedItem = nil
        A.dismissed = false
    end
    if
        not A.pinned
        and not A.manualOpen
        and not A.dragging
        and not IsShiftKeyDown()
        and not A.frame:IsMouseOver()
        and not A.tooltip:IsMouseOver()
    then
        A.frame:Hide()
    end
end

local function initialize()
    RaynnaCodexDB = RaynnaCodexDB or {}
    A.db = RaynnaCodexDB
    if A.db.enabled == nil then
        A.db.enabled = true
    end
    A.db.scale = tonumber(A.db.scale) or 1
    A.db.history = A.db.history or {}
    A.db.appearance = A.db.appearance or { paper = true, opacity = 0.97 }
    A.db.schema = 1
    A.CreateUI()
    A.PreloadTrackerPortraits()
    A.RegisterSettings()
    if TooltipDataProcessor and Enum and Enum.TooltipDataType then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
            if tooltip == GameTooltip then
                A.HandleHover(data and data.id)
            end
        end)
    elseif GameTooltip and hooksecurefunc then
        for _, method in ipairs({ 'SetBagItem', 'SetInventoryItem', 'SetMerchantItem', 'SetHyperlink' }) do
            if GameTooltip[method] then
                hooksecurefunc(GameTooltip, method, function()
                    A.HandleHover()
                end)
            end
        end
    end
    -- Poll only while the reference is visible, to bridge the tooltip-to-panel gap.
    local elapsed = 0
    A.frame:SetScript('OnUpdate', function(_, delta)
        elapsed = elapsed + delta
        if elapsed >= 0.08 then
            elapsed = 0
            releaseHover()
        end
    end)
    SLASH_RAYNNACODEX1 = '/rc'
    SLASH_RAYNNACODEX2 = '/raynnacodex'
    SlashCmdList.RAYNNACODEX = function(message)
        message = (message or ''):match('^%s*(.-)%s*$')
        if message == 'settings' then
            RaynnaModsSettingsRegistry:Open('codex')
        elseif message == 'hide' then
            A.pinned = false
            A.manualOpen = false
            A.dismissed = true
            A.frame:Hide()
        else
            local id = A.ItemID(message)
            A.ShowItem(id or A.db.lastItem or 3371, true)
            if message ~= '' and not id then
                A.frame.search:SetText(message)
                A.frame.search:GetScript('OnEnterPressed')(A.frame.search)
            end
        end
    end
end
eventFrame:RegisterEvent('ADDON_LOADED')
eventFrame:SetScript('OnEvent', function(_, event, value, success)
    if event == 'ADDON_LOADED' and value == 'RaynnaCodex' then
        initialize()
        eventFrame:UnregisterEvent('ADDON_LOADED')
        eventFrame:RegisterEvent('MODIFIER_STATE_CHANGED')
        eventFrame:RegisterEvent('GET_ITEM_INFO_RECEIVED')
    elseif A.db and event == 'MODIFIER_STATE_CHANGED' then
        shiftHeld = IsShiftKeyDown()
        if shiftHeld then
            A.HandleHover()
        else
            releaseHover()
        end
    elseif A.db and event == 'GET_ITEM_INFO_RECEIVED' and success and A.frame:IsShown() then
        if value == A.currentItem then
            A.Refresh()
        else
            A.Render()
        end
    end
end)
