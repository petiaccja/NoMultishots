nms_Options = {}

local panel = nil
local variablesLoadedFrame = CreateFrame("Frame", "nms_VarsLoaded", UIParent)
variablesLoadedFrame:SetScript("OnEvent", function () nms_Options:VariablesLoaded() end)
variablesLoadedFrame:RegisterEvent("VARIABLES_LOADED")

local Round = function (arg)
    return math.floor(arg + 0.5)
end

function nms_Options:Init()
    if self.init then
        return 
    end
    self.init = true

    self.panel = nms_Options:CreatePanel()
    self.panel.frame.name = "NoMultishots"
    InterfaceOptions_AddCategory(self.panel.frame)
    self:RegisterUpdateTriggers()
    self:RegisterScripts()
end


function nms_Options:VariablesLoaded()
    self:Init()

    if not g_noMultishotsConfig then
        g_noMultishotsConfig = {}
    end

    local charName = UnitName("player")
    local options = g_noMultishotsConfig[charName]
    options = self:Verify(options)
    g_noMultishotsConfig[charName] = options
    self:WritePanel(options)
    nms_WarningFrame:SetOptions(options)
end


function nms_Options:Defaults()
    local options = {}
    options.unlocked = false
    options.positionX = 0
    options.positionY = 0
    options.alpha = 0.6
    options.size = 128
    options.showCounts = true
    options.countAlignment = "BOTTOM"
    return options
end


function nms_Options:Verify(options)
    local defaults = self:Defaults()

    if not options then
        return defaults
    end

    for k,v in pairs(defaults) do
        if options[k] == nil or type(options[k]) ~= type(v) then
            options[k] = v
        end
    end
    return options
end


function nms_Options:WritePanel(options)
    self.panel.enableMove:SetChecked(options.enableMove)
    self.panel.alphaSlider:SetValue(options.alpha)
    self.panel.coordX:SetNumber(Round(options.positionX))
    self.panel.coordY:SetNumber(Round(options.positionY))
    self.panel.size:SetNumber(Round(options.size))

    self.panel.coordX:SetCursorPosition(0)
    self.panel.coordY:SetCursorPosition(0)
    self.panel.size:SetCursorPosition(0)

    self.panel.showCounts:SetChecked(options.showCounts)
    local alignStr = string.lower(options.countAlignment)
    alignStr = alignStr:sub(1,1):upper() .. alignStr:sub(2)
    UIDropDownMenu_SetText(self.panel.countAlignment, alignStr)
end


function nms_Options:ReadPanel()
    local options = {}
    options.enableMove = self.panel.enableMove:GetChecked()
    options.alpha = self.panel.alphaSlider:GetValue()
    options.positionX = self.panel.coordX:GetNumber()
    options.positionY = self.panel.coordY:GetNumber()
    options.size = self.panel.size:GetNumber()
    options.showCounts = self.panel.showCounts:GetChecked()
    options.countAlignment = string.upper(UIDropDownMenu_GetText(self.panel.countAlignment))
    return options
end


function nms_Options:Update()
    local charName = UnitName("player")
    local options = self:ReadPanel()
    g_noMultishotsConfig[charName] = options
    nms_WarningFrame:SetOptions(options)
end


function nms_Options:CreatePanel()
    local panel = {}

    panel.frame = CreateFrame("Frame", "nms_OptionsFrame")

    panel.enableMove = nms_Interface:CreateCheckButton("EnableMove", panel.frame, "Unlock frame", "Check this to make the warning frame draggable with the mouse.")
    panel.alphaSlider = nms_Interface:CreateSlider("AlphaSlider", panel.frame, "Frame alpha")

    panel.labelCoord = nms_Interface:CreateLabel(panel.frame, "Frame coordinates:", 12)
    panel.coordX = nms_Interface:CreateEditBox("EditCoordX", panel.frame, "X", 60, 25, function() self:Update() end)
    panel.coordY = nms_Interface:CreateEditBox("EditCoordY", panel.frame, "Y", 60, 25, function() self:Update() end)
    panel.resetCoords = nms_Interface:CreateButton("ResetCoords", panel.frame, "Reset", 60, 25)

    panel.labelSize = nms_Interface:CreateLabel(panel.frame, "Frame size:", 12)
    panel.size = nms_Interface:CreateEditBox("EditSize", panel.frame, "", 60, 25, function () self:Update() end)

    panel.showCounts = nms_Interface:CreateCheckButton("ShowCounts", panel.frame, "Show number of hazards")
    panel.countAlignment = nms_Interface:CreateDropdownMenu("CountAlignment", panel.frame, 85, 25, {"Bottom", "Top", "Left", "Right"}, function (info, control, key, checked)
        UIDropDownMenu_SetSelectedValue(control, info.value, info.value)
        self:Update()
    end)
    
    panel.enableMove:SetPoint("TOPLEFT", panel.frame, "TOPLEFT", 15, -15)
    panel.alphaSlider:SetPoint("TOPLEFT", panel.enableMove, "BOTTOMLEFT", 0, -15)
    panel.labelCoord:SetPoint("TOPLEFT", panel.alphaSlider, "BOTTOMLEFT", 0, -30)
    panel.coordX:SetPoint("LEFT", panel.labelCoord, "RIGHT", 10, 0)
    panel.coordY:SetPoint("LEFT", panel.coordX, "RIGHT", 10, 0)
    panel.resetCoords:SetPoint("LEFT", panel.coordY, "RIGHT", 10, 0)
    panel.labelSize:SetPoint("TOPLEFT", panel.labelCoord, "BOTTOMLEFT", 0, -20)
    panel.size:SetPoint("LEFT", panel.labelSize, "RIGHT", 10, 0)
    panel.showCounts:SetPoint("TOPLEFT", panel.labelSize, "BOTTOMLEFT", 0, -15)
    panel.countAlignment:SetPoint("LEFT", panel.showCounts, "RIGHT", 135, 0)

    panel.coordX:SetNumeric()
    panel.coordY:SetNumeric()
    panel.size:SetNumeric()

    panel.alphaSlider.tooltip = "Set to zero if you don't want any displays."

    return panel
end


function nms_Options:RegisterUpdateTriggers()
    self.panel.enableMove:SetScript("OnClick", function () self:Update() end)
    self.panel.alphaSlider:SetScript("OnMouseUp", function () self:Update() end)
    self.panel.showCounts:SetScript("OnClick", function () self:Update() end)
end


function nms_Options:RegisterScripts()
    nms_WarningFrame:SetMoveCallback(function ()
        local x, y = nms_WarningFrame:GetFramePosition()
        self.panel.coordX:SetNumber(Round(x))
        self.panel.coordY:SetNumber(Round(y))
        self.panel.coordX:SetCursorPosition(0)
        self.panel.coordY:SetCursorPosition(0)
        self:Update()
    end)
    self.panel.resetCoords:SetScript("OnClick", function ()
        local x, y = 0, 0
        self.panel.coordX:SetNumber(Round(x))
        self.panel.coordY:SetNumber(Round(y))
        self.panel.coordX:SetCursorPosition(0)
        self.panel.coordY:SetCursorPosition(0)
        self:Update()
    end)
end