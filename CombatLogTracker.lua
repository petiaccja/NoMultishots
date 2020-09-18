nms_CombatLogTracker = {}

local COMBATLOG_OBJECT_REACTION_HOSTILE	= 0x00000040
local COMBATLOG_OBJECT_REACTION_NEUTRAL	= 0x00000020
local COMBATLOG_OBJECT_REACTION_FRIENDLY = 0x00000010

local eventHandlers = {}
local trackedUnits = {}
local eventFrame = nil

function nms_CombatLogTracker:Init()
    eventFrame = CreateFrame("Frame", "nms_CombatLogFrame")
    eventFrame:SetScript("OnEvent", nms_CombatLogTracker.OnEvent)
    eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    nms_CombatLogTracker.sweepTicker = C_Timer.NewTicker(0.5, nms_CombatLogTracker.SweepExpired)
end


function nms_CombatLogTracker:OnEvent(event, ...)
    if eventHandlers[event] ~= nil then
        eventHandlers[event](...)
    end
end


function nms_CombatLogTracker:OnAuraApplied(destGUID, destName, destFlags, spellName)
    local isDestAttackable = bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE
    or bit.band(destFlags, COMBATLOG_OBJECT_REACTION_NEUTRAL) == COMBATLOG_OBJECT_REACTION_NEUTRAL
    local isSpellTracked = nms_Data.spellList[spellName] ~= nil
    if isDestAttackable and isSpellTracked then
        if trackedUnits[destGUID] == nil then
            trackedUnits[destGUID] = {}
        end
        trackedUnits[destGUID][spellName] = GetTime() + nms_Data.spellList[spellName].duration;
    end
end


function nms_CombatLogTracker:OnAuraRemoved(destGUID, destName, destFlags, spellName)
    if trackedUnits[destGUID] ~= nil then
        if trackedUnits[destGUID][spellName] ~= nil then
            trackedUnits[destGUID][spellName] = nil
        end
        if next(trackedUnits[destGUID]) == nil then
            trackedUnits[destGUID] = nil
        end
    end
end


function nms_CombatLogTracker:SweepExpired()
    local time = GetTime()
    for unitGUID, auras in pairs(trackedUnits) do
        for spellName, expirationTime in pairs(auras) do
            if time > expirationTime then
                trackedUnits[unitGUID][spellName] = nil
            end
        end
        if next(trackedUnits[unitGUID]) == nil then
            trackedUnits[unitGUID] = nil
        end
    end
    nms_CombatLogTracker:Update()
end


function nms_CombatLogTracker:SetCallback(callback)
    self.callback = callback
end


function nms_CombatLogTracker:Update()
    local warningState = NMS_WARNING_NONE
    if next(trackedUnits) ~= nil then
        warningState = NMS_WARNING_NEARBY
    end
    if self.callback ~= nil then
        self.callback(warningState, NMS_EFFECT_POLYMORPH)
    end
end


function eventHandlers:COMBAT_LOG_EVENT_UNFILTERED()
    local timestamp, event, hiding, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellID, spellName, spellSchool,
          sp1, sp2, sp3, sp4, sp5, sp6, sp7, sp8, sp9 
        = CombatLogGetCurrentEventInfo()

    if (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH") then
        nms_CombatLogTracker:OnAuraApplied(destGUID, destName, destFlags, spellName)
    elseif (event == "SPELL_AURA_REMOVED" or event == "SPELL_AURA_BROKEN") then
        nms_CombatLogTracker:OnAuraRemoved(destGUID, destName, destFlags, spellName)
    end

    nms_CombatLogTracker:Update()
end

