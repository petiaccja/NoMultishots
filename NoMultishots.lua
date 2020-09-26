nms_Main = {}


function nms_Main:Init()
    nms_CombatLogTracker:Init()
    nms_UnitTracker:Init()
    nms_WarningFrame:Init()
    nms_Options:Init()

    nms_CombatLogTracker:SetCallback(function(...) nms_WarningFrame:UpdateCombatLog(...) end)
    nms_UnitTracker:SetCallback(function(...) nms_WarningFrame:UpdateUnit(...) end)
end


function nms_Main:GetAllAuras(unit, filter)
    local auras = {}
    for i=1,40 do 
        local name, _, _, _, duration, expirationTime, unitCaster, _, _, _, _ = UnitAura(unit, i, filter)
        if name then
            aura = {}
            aura.name = name
            aura.duration = duration
            aura.expirationTime = expirationTime
            aura.unitCaster = unitCaster
            table.insert(auras, aura)
        end
    end
    return auras
end


function nms_Main:HasPlayerSpell(spellName)
    local name = GetSpellInfo(spellName)
    return name ~= nil
end


function nms_Main:IsUnitInSpellRange(unit)
    local playerClass = UnitClass("player")
    local checkSpell = nms_Data.rangeCheckSpellList[playerClass]
    if checkSpell then
        return IsSpellInRange(checkSpell, unit)
    end
    return false
end


function nms_Main:TableSize(table)
    local count = 0
    for k,v in pairs(table) do
        count = count + 1
    end
    return count    
end

nms_Main:Init()