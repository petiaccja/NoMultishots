nms_UnitTracker = {}

local eventHandlers = {}
local eventFrame = nil


function nms_UnitTracker:Init()
    eventFrame = CreateFrame("Frame", "nms_UnitTrackerFrame")
    eventFrame:SetScript("OnEvent", nms_UnitTracker.OnEvent)
    eventFrame:RegisterEvent("UNIT_AURA")
    eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
end


function nms_UnitTracker:OnEvent(event, ...)
    if eventHandlers[event] ~= nil then
        eventHandlers[event](...)
    end
end


function nms_UnitTracker:IsRaidMemberAttackable()
    local numAttackable = 0
    local isAnyInRange = false
    for i=1,40 do
        local unitId = "raid" .. i
        local isAttackable = UnitCanAttack("player",unitId)
        local isInRange = nms_Main:IsUnitInSpellRange(unitId)
        if isAttackable then
            numAttackable = numAttackable + 1
        end
        isAnyInRange = isAnyInRange or isInRange
    end
    return numAttackable, isAnyInRange
end


function nms_UnitTracker:IsPartyMemberAttackable()
    local numAttackable = 0
    local isAnyInRange = false
    for i=1,4 do
        local unitId = "party" .. i
        local isAttackable = UnitCanAttack("player",unitId)
        local isInRange = nms_Main:IsUnitInSpellRange(unitId)
        if isAttackable then
            numAttackable = numAttackable + 1
        end
        isAnyInRange = isAnyInRange or isInRange
    end
    return numAttackable, isAnyInRange
end


function nms_UnitTracker:IsTargetPolymorphed()
    local attackable = UnitCanAttack("player","target")
    if not attackable then
        return false
    end
    local auras = nms_Main:GetAllAuras("target", "HARMFUL")
    for k,aura in pairs(auras) do
        if nms_Data.spellList[aura.name] ~= nil then
            return true
        end
    end
    return false
end


function nms_UnitTracker:SetCallback(callback)
    self.callback = callback
end


function nms_UnitTracker:Update()
    local isTargetPolymorphed = nms_UnitTracker:IsTargetPolymorphed()
    local numPartyAttackable, isPartyInRange = nms_UnitTracker:IsPartyMemberAttackable()
    local numRaidAttackable, isRaidInRange = nms_UnitTracker:IsRaidMemberAttackable()

    local numPolymorphed = (function() if isTargetPolymorphed then return 1 else return 0 end end)()
    local numAttackable = math.max(numPartyAttackable, numRaidAttackable)
    local inRange = isRaidInRange or isPartyInRange

    local warningState = NMS_WARNING_NONE
    local warningEffect = NMS_EFFECT_NONE

    if isTargetPolymorphed then
        warningState = NMS_WARNING_TARGET
        warningEffect = NMS_EFFECT_POLYMORPH
    end
    if numAttackable > 0 then
        warningEffect = NMS_EFFECT_FRIENDLY_FIRE
        if isRaidInRange then
            warningState = NMS_WARNING_IN_RANGE
        else
            warningState = NMS_WARNING_NEARBY
        end
    end

    if self.callback ~= nil then
        self.callback(warningState, warningEffect, numPolymorphed, numAttackable)
    end
end


function eventHandlers:UNIT_AURA()
    nms_UnitTracker:Update()
end


function eventHandlers:PLAYER_TARGET_CHANGED()
    nms_UnitTracker:Update()
end