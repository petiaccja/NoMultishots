nms_WarningFrame = {}


local clogState = NMS_WARNING_NONE
local clogEffect = NMS_EFFECT_NONE
local unitState = NMS_WARNING_NONE
local unitEffect = NMS_EFFECT_NONE
local numPolymorphed = 0
local numAttackable = 0
local frame = nil
local frameMovable = false
local clearButtonModifier = "ALT"
local showOptions = {
    ["enableFrame"] = true,
    ["showAlone"] = true,
    ["showInParty"] = true,
    ["showInRaid"] = true,
    ["showInBattleground"] = true,
    ["showOnlyInstance"] = false,
}

local texFileWarnPoly = "Interface/Addons/NoMultishots/images/warn_sheep.blp"
local texFileWarnFF = "Interface/Addons/NoMultishots/images/warn_friend.blp"
local texFileBlockPoly = "Interface/Addons/NoMultishots/images/block_sheep.blp"
local texFileBlockFF = "Interface/Addons/NoMultishots/images/block_friend.blp"
local texChecker = "Interface/Addons/NoMultishots/images/move_placeholder.blp"

local colorIdle = {["r"] = 255/255, ["g"] = 255/255, ["b"] = 255/255}
local colorWarning = {["r"] = 255/255, ["g"] = 240/255, ["b"] = 0/255}
local colorBlock = {["r"] = 255/255, ["g"] = 0/255, ["b"] = 0/255}


function nms_WarningFrame:Init()
    frame = self:CreateFrame()
    self:AlignCounters(frame, "BOTTOM")
    frame:Hide()
end


function nms_WarningFrame:CreateFrame()
    local frame = CreateFrame("Frame", "nms_WarningFrame")
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetSize(128, 128)

    frame.icon = CreateFrame("Frame", "nms_DisplayFrame")
    frame.icon:SetSize(128, 128)
    frame.icon:SetPoint("CENTER", frame, "CENTER", 0, 0)
    frame.icon.texture = frame.icon:CreateTexture(nil, "OVERLAY")
    frame.icon.texture:SetAllPoints(frame.icon)
    frame.icon.texture:SetTexture(texChecker)
    frame.icon:SetAlpha(0.5)

    frame.labelPolyCount = nms_Interface:CreateLabel(frame, "1", 12)
    frame.labelTotalCount = nms_Interface:CreateLabel(frame, "3", 12)
    frame.labelFriendCount = nms_Interface:CreateLabel(frame, "2", 12)

    frame.labelPolyCount:SetShadowColor(0, 0, 0)
    frame.labelTotalCount:SetShadowColor(0, 0, 0)
    frame.labelFriendCount:SetShadowColor(0, 0, 0)

    frame.clearButton = CreateFrame("Button", "nms_WarningFrame_HideButton", frame)
    frame.clearButton:SetSize(25, 25)
    frame.clearButton:SetNormalTexture("interface/buttons/arrow-down-up.blp")
    frame.clearButton:SetHighlightTexture("interface/buttons/arrow-down-up.blp")
    frame.clearButton:SetPushedTexture("interface/buttons/arrow-down-down.blp")
    frame.clearButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
    frame.clearButton:SetScript("OnClick", function () self:ClearWarnings() end)

    return frame
end


function nms_WarningFrame:AlignCounters(frame, location)
    local refp, reft, reff
    local relp, relt, relf
    if location == "TOP" then
        refp, reft, reff = "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"
        relp, relt, relf = "TOPLEFT", "TOP", "TOPRIGHT"
    elseif location == "BOTTOM" then
        refp, reft, reff = "TOPLEFT", "TOP", "TOPRIGHT"
        relp, relt, relf = "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"
    elseif location == "LEFT" then
        refp, reft, reff = "TOPRIGHT", "RIGHT", "BOTTOMRIGHT"
        relp, relt, relf = "TOPLEFT", "LEFT", "BOTTOMLEFT"
    elseif location == "RIGHT" then
        refp, reft, reff = "TOPLEFT", "LEFT", "BOTTOMLEFT"
        relp, relt, relf = "TOPRIGHT", "RIGHT", "BOTTOMRIGHT"
    else
        error("Invalid location for counters.")
    end

    frame.labelPolyCount:ClearAllPoints()
    frame.labelTotalCount:ClearAllPoints()
    frame.labelFriendCount:ClearAllPoints()
    frame.labelPolyCount:SetPoint(refp, frame, relp, 0, 0)
    frame.labelTotalCount:SetPoint(reft, frame, relt, 0, 0)
    frame.labelFriendCount:SetPoint(reff, frame, relf, 0, 0)
    frame.labelPolyCount:SetJustifyH("CENTER")
    frame.labelTotalCount:SetJustifyH("CENTER")
    frame.labelFriendCount:SetJustifyH("CENTER")
end


function nms_WarningFrame:SetOptions(options)
    self:SetMovable(options.enableMove)
    frameMovable = options.enableMove

    frame:SetSize(options.size, options.size)
    frame:ClearAllPoints()
    local uiScale = UIParent:GetEffectiveScale()
    frame:SetPoint("CENTER", UIParent, "CENTER", options.positionX*uiScale, options.positionY*uiScale)
    
    frame.icon:SetAlpha(options.alpha)
    frame.icon:SetSize(options.size, options.size)

    local smallFontSize = options.size * 0.14
    local largeFontSize = options.size * 0.18
    local shadowOffsetX = smallFontSize * 0.12
    local shadowOffsetY = -smallFontSize * 0.07
    local largeFontSize = math.max(12, largeFontSize)
    frame.labelPolyCount:SetFont("Fonts/FRIZQT__.ttf", smallFontSize)
    frame.labelTotalCount:SetFont("Fonts/FRIZQT__.ttf", largeFontSize)
    frame.labelFriendCount:SetFont("Fonts/FRIZQT__.ttf", smallFontSize)
    frame.labelPolyCount:SetShadowOffset(shadowOffsetX, shadowOffsetY)
    frame.labelTotalCount:SetShadowOffset(shadowOffsetX, shadowOffsetY)
    frame.labelFriendCount:SetShadowOffset(shadowOffsetX, shadowOffsetY)

    if options.showCounts then
        frame.labelPolyCount:Show()
        frame.labelTotalCount:Show()
        frame.labelFriendCount:Show()
    else        
        frame.labelPolyCount:Hide()
        frame.labelTotalCount:Hide()
        frame.labelFriendCount:Hide()
    end
    if smallFontSize < 12 then
        frame.labelPolyCount:Hide()
        frame.labelFriendCount:Hide()
    end
    self:AlignCounters(frame, options.countAlignment)

    if options.showClearButton then
        frame.clearButton:Show()
    else
        frame.clearButton:Hide()
    end
    clearButtonModifier = options.clearButtonModifier
    local clearButtonSize = math.max(12, math.min(30, options.size * 0.18))
    frame.clearButton:SetSize(clearButtonSize, clearButtonSize)
    frame.clearButton:SetAlpha(options.alpha)

    showOptions.enableFrame = options.enableFrame
    showOptions.showAlone = options.showAlone
    showOptions.showInParty = options.showInParty
    showOptions.showInRaid = options.showInRaid
    showOptions.showInBattleground = options.showInBattleground
    showOptions.showOnlyInstance = options.showOnlyInstance

    self:UpdateDisplay()
end


function nms_WarningFrame:GetFramePosition()
    local refX, refY = UIParent:GetCenter()
    local x, y = frame:GetCenter()    
    local uiScale = UIParent:GetEffectiveScale()
    return x/uiScale - refX, y/uiScale - refY
end


function nms_WarningFrame:SetMovable(enable)
    if enable then
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" and not self.isMoving then
                self:StartMoving();
                self.isMoving = true;
            end
        end)
        frame:SetScript("OnMouseUp", function(self, button)
            if button == "LeftButton" and self.isMoving then
                self:StopMovingOrSizing();
                self.isMoving = false;
                if nms_WarningFrame.moveCallback then
                    nms_WarningFrame.moveCallback()
                end
            end
        end)
        frame:SetScript("OnHide", function(self)
            if self.isMoving then
                self:StopMovingOrSizing();
                self.isMoving = false;
            end
        end)
    else
        frame:SetMovable(false)
        frame:EnableMouse(false)
    end
end


function nms_WarningFrame:SetMoveCallback(callback)
    self.moveCallback = callback
end


function nms_WarningFrame:GetMostImportantState()
    if clogState > unitState then
        return clogState, clogEffect
    else
        return unitState, unitEffect
    end
end


function nms_WarningFrame:GetIconTexture(state, effect)
    local texturePath
    local textColor

    if state == NMS_WARNING_NONE then
        textColor = colorIdle
        texturePath = texChecker
    elseif state <= NMS_WARNING_NEARBY then
        textColor = colorWarning
        if effect == NMS_EFFECT_FRIENDLY_FIRE then
            texturePath = texFileWarnFF
        else
            texturePath = texFileWarnPoly
        end
    else
        textColor = colorBlock
        if effect == NMS_EFFECT_FRIENDLY_FIRE then
            texturePath = texFileBlockFF
        else
            texturePath = texFileBlockPoly
        end
    end
    return texturePath, textColor
end


function nms_WarningFrame:IsShown()
    -- showOptions.enableFrame
    -- showOptions.showAlone
    -- showOptions.showInParty
    -- showOptions.showInRaid
    -- showOptions.showInBattleground
    -- showOptions.showOnlyInstance

    local isInInstance, instanceType = IsInInstance()
    local isInBattleground = instanceType == "pvp" or instanceType == "arena"
    local isInParty = UnitPlayerOrPetInParty("player") and not UnitPlayerOrPetInRaid("player")
    local isInRaid = UnitPlayerOrPetInRaid("player")
    local isAlone = not isInParty and not isInRaid and not isInBattleground

    if not showOptions.enableFrame then
        return false
    end
    if (showOptions.showOnlyInstance and not isInInstance) then
        return false
    end

    if (isAlone and showOptions.showAlone) 
        or (isInParty and showOptions.showInParty)
        or (isInRaid and showOptions.showInRaid)
        or (isInBattleground and showOptions.showInBattleground)
        then
        return true
    end
    return false
end


function nms_WarningFrame:ClearWarnings()
    local perform = (clearButtonModifier == "ALT" and IsAltKeyDown())
        or (clearButtonModifier == "SHIFT" and IsShiftKeyDown())
        or (clearButtonModifier == "CONTROL" and IsControlKeyDown())
        or (clearButtonModifier == "NONE")
    if perform then
        nms_CombatLogTracker:Clear()
    end
end


function nms_WarningFrame:UpdateDisplay()
    local state, effect = self:GetMostImportantState()
    local texturePath, textColor = self:GetIconTexture(state, effect)

    frame.icon.texture:SetTexture(texturePath)
    frame.labelPolyCount:SetTextColor(textColor.r, textColor.g, textColor.b, frame.icon:GetAlpha())
    frame.labelTotalCount:SetTextColor(textColor.r, textColor.g, textColor.b, frame.icon:GetAlpha())
    frame.labelFriendCount:SetTextColor(textColor.r, textColor.g, textColor.b, frame.icon:GetAlpha())

    frame.labelPolyCount:SetText(tostring(numPolymorphed))
    frame.labelTotalCount:SetText(tostring(numPolymorphed + numAttackable))
    frame.labelFriendCount:SetText(tostring(numAttackable))

    if (state ~= NMS_WARNING_NONE and self:IsShown()) or frameMovable then
        frame:Show()
        frame.icon:Show()
    else
        frame:Hide()
        frame.icon:Hide()
    end
end


function nms_WarningFrame:UpdateCombatLog(warningState, warningEffect, polyCount, ffCount)
    clogState = warningState
    clogEffect = warningEffect
    numPolymorphed = polyCount
    self:UpdateDisplay()
end


function nms_WarningFrame:UpdateUnit(warningState, warningEffect, polyCount, ffCount)
    unitState = warningState
    unitEffect = warningEffect
    numAttackable = ffCount
    self:UpdateDisplay()
end