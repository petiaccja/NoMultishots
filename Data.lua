nms_Data = {}

NMS_WARNING_NONE = 0
NMS_WARNING_NEARBY = 1
NMS_WARNING_IN_RANGE = 2
NMS_WARNING_TARGET = 3

NMS_EFFECT_NONE = 0
NMS_EFFECT_POLYMORPH = 1
NMS_EFFECT_FRIENDLY_FIRE = 2


function nms_Data:AuraInfo(duration)
    local auraInfo = {}
    auraInfo.duration = duration
    return auraInfo
end


nms_Data["spellList"] = {
    -- druid
    ["Hibernate"] = nms_Data:AuraInfo(40),
    -- hunter
    ["Freezing Trap Effect"] = nms_Data:AuraInfo(20),
    ["Scare Beast"] = nms_Data:AuraInfo(20),
    -- mage
    ["Polymorph"] = nms_Data:AuraInfo(50),
    -- paladin
    ["Turn Undead"] = nms_Data:AuraInfo(20),
    -- priest
    ["Psychic Scream"] = nms_Data:AuraInfo(8),
    ["Shackle Undead"] = nms_Data:AuraInfo(50),
    -- rogue
    ["Sap"] = nms_Data:AuraInfo(45),
    ["Blind"] = nms_Data:AuraInfo(10),
    -- shaman
    -- warlock
    ["Fear"] = nms_Data:AuraInfo(20),
    ["Howl of Terror"] = nms_Data:AuraInfo(15),
    -- warrior
    -- DEBUG:
    -- ["Hunter's Mark"] = AuraInfo(120),
}


nms_Data["rangeCheckSpellList"] = {
    ["Druid"] = "Wrath",
    ["Hunter"] = "Auto Shot",
    ["Mage"] = "Fireball",
    ["Warlock"] = "Shadow Bolt",
    ["Priest"] = "Smite",
    ["Rogue"] = "Sinister Strike",
    ["Shaman"] = "Lightning Bolt",
    ["Paladin"] = nil,
    ["Warrior"] = nil,
}