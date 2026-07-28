local compatibility = _G.EnhancedWidgetControlCompatibility
if not compatibility or not compatibility.compatible then return end

local LSM = LibStub("LibSharedMedia-3.0")
local mediaPath = [[Interface\AddOns\EnhancedWidgetControl\Media\]]
local localeMask = (LSM.LOCALE_BIT_western or 0)
    + (LSM.LOCALE_BIT_ruRU or 0)

LSM:Register(
    "font",
    "EWC Play Bold",
    mediaPath .. "Play-Bold.ttf",
    localeMask
)

LSM:Register(
    "statusbar",
    "EWC Dark",
    mediaPath .. "EWCDark.tga"
)
