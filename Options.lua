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
    if not self:Verify(options) then
        options = self:Defaults()
        g_noMultishotsConfig[charName] = options
    end
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
    return options
end


function nms_Options:Verify(options)
    if not options then
        return false
    end
    if type(options.positionX) ~= "number" then
        return false
    end
    if type(options.positionY) ~= "number" then
        return false
    end
    if type(options.alpha) ~= "number" then
        return false
    end
    if type(options.size) ~= "number" then
        return false
    end
    return true
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
end


function nms_Options:ReadPanel()
    local options = {}
    options.enableMove = self.panel.enableMove:GetChecked()
    options.alpha = self.panel.alphaSlider:GetValue()
    options.positionX = self.panel.coordX:GetNumber()
    options.positionY = self.panel.coordY:GetNumber()
    options.size = self.panel.size:GetNumber()
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

    panel.enableMove = self:CreateCheckButton("EnableMove", panel.frame, "Unlock frame", "Check this to make the warning frame draggable with the mouse.")
    panel.alphaSlider = self:CreateSlider("AlphaSlider", panel.frame, "Frame alpha")
    panel.labelCoord = self:CreateLabel(panel.frame, "Frame coordinates:", 12)
    panel.coordX = self:CreateEditBox("EditCoordX", panel.frame, "X", 60, 25, function() self:Update() end)
    panel.coordY = self:CreateEditBox("EditCoordY", panel.frame, "Y", 60, 25, function() self:Update() end)
    panel.resetCoords = self:CreateButton("ResetCoords", panel.frame, "Reset", 60, 25)
    panel.labelSize = self:CreateLabel(panel.frame, "Frame size:", 12)
    panel.size = self:CreateEditBox("EditSize", panel.frame, "", 60, 25, function () self:Update() end)
    
    panel.enableMove:SetPoint("TOPLEFT", panel.frame, "TOPLEFT", 15, -15)
    panel.alphaSlider:SetPoint("TOPLEFT", panel.enableMove, "BOTTOMLEFT", 0, -15)
    panel.labelCoord:SetPoint("TOPLEFT", panel.alphaSlider, "BOTTOMLEFT", 0, -30)
    panel.coordX:SetPoint("LEFT", panel.labelCoord, "RIGHT", 10, 0)
    panel.coordY:SetPoint("LEFT", panel.coordX, "RIGHT", 10, 0)
    panel.resetCoords:SetPoint("LEFT", panel.coordY, "RIGHT", 10, 0)
    panel.labelSize:SetPoint("TOPLEFT", panel.labelCoord, "BOTTOMLEFT", 0, -20)
    panel.size:SetPoint("LEFT", panel.labelSize, "RIGHT", 10, 0)

    panel.coordX:SetNumeric()
    panel.coordY:SetNumeric()
    panel.size:SetNumeric()

    panel.alphaSlider.tooltip = "Set to zero if you don't want any displays."

    return panel
end


function nms_Options:RegisterUpdateTriggers()
    self.panel.enableMove:SetScript("OnClick", function () self:Update() end)
    self.panel.alphaSlider:SetScript("OnMouseUp", function () self:Update() end)
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


function nms_Options:CreateLabel(parent, text, size)
    local control = parent:CreateFontString(nil, "ARTWORK")
    control:SetFont("Fonts/FRIZQT__.ttf", size)
    control:SetJustifyV("CENTER")
    control:SetJustifyH("CENTER")
    control:SetText(text)
    return control
end


function nms_Options:CreateButton(name, parent, title, width, height)
    local control = CreateFrame("Button", "nms_" .. name, parent)
    local font = control:CreateFontString()
	font:SetFont("Fonts/FRIZQT__.TTF", 12)
	font:SetPoint("CENTER", control, "CENTER", 0, 0)
    font:SetJustifyV("CENTER")
    font:SetJustifyH("CENTER")
    control:SetFontString(font)
    control:SetText(title)
    control:SetSize(width, height)
    control:SetNormalTexture('Interface/Buttons/UI-Panel-Button-Up')
    control:SetHighlightTexture("Interface/Buttons/UI-Panel-Button-Highlight")
    control:SetPushedTexture("Interface/Buttons/UI-Panel-Button-Down")
    return control
end


function nms_Options:CreateCheckButton(name, parent, title, hint)
    local control = CreateFrame("CheckButton", "nms_" .. name, parent, "ChatConfigCheckButtonTemplate")
    control:SetChecked(false)
    getglobal(control:GetName() .. 'Text'):SetText(title);
    if hint then
        control.tooltip = hint
    end
    return control
end


function nms_Options:CreateSlider(name, parent, title)
    local control = CreateFrame("Slider", "nms_" .. name, parent, "OptionsSliderTemplate")
    control:SetOrientation('HORIZONTAL')
    control:SetMinMaxValues(0, 1)
    control:SetValue(0.5)
    getglobal(control:GetName() .. "Low"):SetText("0.0")
    getglobal(control:GetName() .. "High"):SetText("1.0")
    getglobal(control:GetName() .. "Text"):SetText(title)
    return control
end


function nms_Options:CreateEditBox(name, parent, title, width, height, onEnterCallback)
    local control = CreateFrame("EditBox", "nms_" .. name, parent)
    control.title_text = self:CreateLabel(control, title, 12)
    control.title_text:SetPoint("TOP", 0, 12)
    control:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 26,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4}
    })
    control:SetBackdropColor(0,0,0,1)
    control:SetSize(width, height)
    control:SetMultiLine(false)
    control:SetAutoFocus(false)
    control:SetMaxLetters(6)
    control:SetJustifyH("CENTER")
    control:SetJustifyV("CENTER")
    control:SetFontObject(GameFontNormal)
    control:SetText("")
    control:SetScript("OnEnterPressed", function(self)
        onEnterCallback(self)
        self:ClearFocus()
    end)
    control:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    return control
end