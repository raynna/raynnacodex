local _, A = ...
function A.RegisterSettings()
    local registry = RaynnaModsSettingsRegistry
    registry:Register('codex', 'Codex', function(panel)
        A.Label(panel, 12, 24, -24, 450):SetText("Raynna's Codex / saved per character")
        local enabled = CreateFrame('CheckButton', nil, panel, 'UICheckButtonTemplate')
        enabled:SetPoint('TOPLEFT', 24, -55)
        enabled:SetSize(24, 24)
        A.Label(panel, 12, 55, -61, 450):SetText('Show item reference on Shift-hover')
        enabled:SetScript('OnClick', function(self)
            A.db.enabled = self:GetChecked() and true or false
        end)
        A.Label(panel, 12, 24, -100, 440):SetText('UI scale / Ctrl+scroll over Codex also changes scale')
        local scale = CreateFrame('EditBox', nil, panel, 'InputBoxTemplate')
        scale:SetSize(70, 24)
        scale:SetPoint('TOPLEFT', 60, -126)
        scale:SetAutoFocus(false)
        local function refresh()
            enabled:SetChecked(A.db.enabled)
            scale:SetText(math.floor(A.db.scale * 100 + 0.5) .. '%')
        end
        scale:SetScript('OnEnterPressed', function(self)
            local value = tonumber(((self:GetText() or ''):gsub('%%', '')))
            if value then
                A.SetScale(value / 100)
            end
            refresh()
            self:ClearFocus()
        end)
        scale:SetScript('OnEscapePressed', function(self)
            refresh()
            self:ClearFocus()
        end)
        A.Button(panel, '-', 25, 24, -128, function()
            A.SetScale(A.db.scale - 0.05)
            refresh()
        end)
        A.Button(panel, '+', 25, 140, -128, function()
            A.SetScale(A.db.scale + 0.05)
            refresh()
        end)
        A.Button(panel, 'Open Codex', 140, 24, -174, function()
            A.ShowItem(A.db.lastItem or 3371, true)
        end)
        A.Button(panel, 'Center window', 140, 172, -174, function()
            A.db.position = nil
            A.frame:ClearAllPoints()
            A.frame:SetPoint('CENTER')
            A.ShowItem(A.db.lastItem or 3371, true)
        end)
        local paper = CreateFrame('CheckButton', nil, panel, 'UICheckButtonTemplate')
        paper:SetPoint('TOPLEFT', 24, -215)
        paper:SetSize(24, 24)
        A.Label(panel, 12, 55, -222, 420):SetText('Parchment background')
        paper:SetScript('OnClick', function(self)
            A.db.appearance.paper = self:GetChecked() and true or false
            A.ApplyAppearance()
        end)
        A.Label(panel, 12, 24, -260, 440):SetText(
            'Shift locks the first hovered item. Release Shift and leave the panel to hide. Pin keeps it open. /rc opens; /rc settings configures.'
        )
        A.Label(panel, 12, 24, -320, 440):SetText(
            'Forever client crafting snapshot; no website requests in-game. Loot references retain their own source labels. Newer QuestieDB metadata is optional; bundled data works standalone.'
        )
        return function()
            refresh()
            paper:SetChecked(A.db.appearance.paper ~= false)
        end
    end)
    registry:RegisterAppearance('codex', function()
        return A.db.appearance
    end, function(key, value)
        A.db.appearance[key] = value
        A.ApplyAppearance()
    end)
end
