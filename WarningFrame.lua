nms_WarningFrame = {}


local clogState = NMS_WARNING_NONE
local clogEffect = NMS_EFFECT_NONE
local unitState = NMS_WARNING_NONE
local unitEffect = NMS_EFFECT_NONE
local displayFrame = nil

local texFileWarnPoly = "Interface/Addons/NoMultishots/images/warn_poly.blp"
local texFileWarnFF = "Interface/Addons/NoMultishots/images/warn_ff.blp"
local texFileBlockPoly = "Interface/Addons/NoMultishots/images/block_poly.blp"
local texFileBlockFF = "Interface/Addons/NoMultishots/images/block_ff.blp"
local texChecker = "Interface/Addons/NoMultishots/images/checker.blp"


function nms_WarningFrame:Init()
    displayFrame = CreateFrame("Frame", "nms_DisplayFrame")
    displayFrame:SetSize(128, 128)
    displayFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

    displayFrame.texture = displayFrame:CreateTexture(nil, "OVERLAY")
    displayFrame.texture:SetAllPoints(displayFrame)
    displayFrame.texture:SetTexture(texChecker)

    displayFrame:Hide()
    displayFrame:SetAlpha(0.5)
end


function nms_WarningFrame:SetOptions(options)
    self:SetMovable(options.enableMove)
    self.movable = options.enableMove

    displayFrame:SetAlpha(options.alpha)
    displayFrame:ClearAllPoints()
    local uiScale = UIParent:GetEffectiveScale()
    displayFrame:SetPoint("CENTER", UIParent, "CENTER", options.positionX*uiScale, options.positionY*uiScale)

    if self.movable then
        displayFrame:Show()
    end
end


function nms_WarningFrame:GetFramePosition()
    local refX, refY = UIParent:GetCenter()
    local x, y = displayFrame:GetCenter()    
    local uiScale = UIParent:GetEffectiveScale()
    return x/uiScale - refX, y/uiScale - refY
end


function nms_WarningFrame:SetMovable(enable)
    if enable then
        displayFrame:SetMovable(true)
        displayFrame:EnableMouse(true)
        displayFrame:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" and not self.isMoving then
                self:StartMoving();
                self.isMoving = true;
            end
        end)
        displayFrame:SetScript("OnMouseUp", function(self, button)
            if button == "LeftButton" and self.isMoving then
                self:StopMovingOrSizing();
                self.isMoving = false;
                if nms_WarningFrame.moveCallback then
                    nms_WarningFrame.moveCallback()
                end
            end
        end)
        displayFrame:SetScript("OnHide", function(self)
            if self.isMoving then
                self:StopMovingOrSizing();
                self.isMoving = false;
            end
        end)
    else
        displayFrame:SetMovable(false)
        displayFrame:EnableMouse(false)
    end
end


function nms_WarningFrame:SetMoveCallback(callback)
    self.moveCallback = callback
end


function nms_WarningFrame:UpdateDisplay()
    local state = NMS_WARNING_NONE
    local effect = NMS_EFFECT_NONE

    -- Select more severe warning.
    if clogState > unitState then
        state = clogState
        effect = clogEffect
    else
        state = unitState
        effect = unitEffect
    end

    if state == NMS_WARNING_NONE then
        displayFrame.texture:SetTexture(texChecker)
    elseif state <= NMS_WARNING_NEARBY then
        if effect == NMS_EFFECT_FRIENDLY_FIRE then
            displayFrame.texture:SetTexture(texFileWarnFF)
        else
            displayFrame.texture:SetTexture(texFileWarnPoly)
        end
    else
        if effect == NMS_EFFECT_FRIENDLY_FIRE then
            displayFrame.texture:SetTexture(texFileBlockFF)
        else
            displayFrame.texture:SetTexture(texFileBlockPoly)
        end
    end

    if state ~= NMS_WARNING_NONE then
        displayFrame:Show()
    elseif not self.movable then
        displayFrame:Hide()
    end
end


function nms_WarningFrame:UpdateCombatLog(warningState, warningEffect)
    clogState = warningState
    clogEffect = warningEffect
    self:UpdateDisplay()
end


function nms_WarningFrame:UpdateUnit(warningState, warningEffect)    
    unitState = warningState
    unitEffect = warningEffect
    self:UpdateDisplay()
end