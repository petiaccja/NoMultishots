nms_Interface = {}


function nms_Interface:CreateLabel(parent, text, size)
    local control = parent:CreateFontString(nil, "ARTWORK")
    control:SetFont("Fonts/FRIZQT__.ttf", size)
    control:SetJustifyV("CENTER")
    control:SetJustifyH("CENTER")
    control:SetText(text)
    return control
end


function nms_Interface:CreateButton(name, parent, title, width, height)
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


function nms_Interface:CreateCheckButton(name, parent, title, hint)
    local control = CreateFrame("CheckButton", "nms_" .. name, parent, "ChatConfigCheckButtonTemplate")
    control:SetChecked(false)
    getglobal(control:GetName() .. 'Text'):SetText(title);
    if hint then
        control.tooltip = hint
    end
    return control
end


function nms_Interface:CreateSlider(name, parent, title)
    local control = CreateFrame("Slider", "nms_" .. name, parent, "OptionsSliderTemplate")
    control:SetOrientation('HORIZONTAL')
    control:SetMinMaxValues(0, 1)
    control:SetValue(0.5)
    getglobal(control:GetName() .. "Low"):SetText("0.0")
    getglobal(control:GetName() .. "High"):SetText("1.0")
    getglobal(control:GetName() .. "Text"):SetText(title)
    return control
end


function nms_Interface:CreateEditBox(name, parent, title, width, height, onEnterCallback)
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


local function InitDropdown(control, callback)
    local info = UIDropDownMenu_CreateInfo()
    info.func = callback
    for k,v in pairs(control.options) do
        info.text, info.checked = tostring(v), false
        info.arg1, info.arg2 = control, k
        UIDropDownMenu_AddButton(info)
    end
end


function nms_Interface:CreateDropdownMenu(name, parent, width, height, options, onChangeCallback)
    local control = CreateFrame("Frame", "nms_" .. name, parent, "UIDropDownMenuTemplate")
    control.options = options
        
    UIDropDownMenu_Initialize(control, function () InitDropdown(control, onChangeCallback) end)
    UIDropDownMenu_SetWidth(control, width)
    control:SetHeight(height)
    UIDropDownMenu_SetText(control, "")

    return control
end