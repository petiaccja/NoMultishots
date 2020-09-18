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
    local isAnyAttackable = false
    local isAnyInRange = false
    for i=1,40 do
        local unitId = "raid" .. i
        local isAttackable = UnitCanAttack("player",unitId)
        local isInRange = nms_Main:IsUnitInSpellRange(unitId)
        isAnyAttackable = isAnyAttackable or isAttackable
        isAnyInRange = isAnyInRange or isInRange
    end
    return isAnyAttackable, isAnyInRange
end


function nms_UnitTracker:IsPartyMemberAttackable()
    local isAnyAttackable = false
    local isAnyInRange = false
    for i=1,4 do
        local unitId = "party" .. i
        local isAttackable = UnitCanAttack("player",unitId)
        local isInRange = nms_Main:IsUnitInSpellRange(unitId)
        isAnyAttackable = isAnyAttackable or isAttackable
        isAnyInRange = isAnyInRange or isInRange
    end
    return isAnyAttackable, isAnyInRange
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
    local isPartyAttackable, isPartyInRange = nms_UnitTracker:IsPartyMemberAttackable()
    local isRaidAttackable, isRaidInRange = nms_UnitTracker:IsRaidMemberAttackable()

    -- Merge raid and party status.
    isRaidAttackable = isRaidAttackable or isPartyAttackable
    isRaidInRange = isRaidInRange or isPartyInRange

    local warningState = NMS_WARNING_NONE
    local warningEffect = NMS_EFFECT_NONE

    if isTargetPolymorphed then
        warningState = NMS_WARNING_TARGET
        warningEffect = NMS_EFFECT_POLYMORPH
    end
    if isRaidAttackable then
        warningEffect = NMS_EFFECT_FRIENDLY_FIRE
        if isRaidInRange then
            warningState = NMS_WARNING_IN_RANGE
        else
            warningState = NMS_WARNING_NEARBY
        end
    end

    if self.callback ~= nil then
        self.callback(warningState, warningEffect)
    end
end


function eventHandlers:UNIT_AURA()
    nms_UnitTracker:Update()
end


function eventHandlers:PLAYER_TARGET_CHANGED()
    nms_UnitTracker:Update()
end