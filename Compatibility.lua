local minimumVersion = "15.18"
local state = {
    compatible = false,
    minimumVersion = minimumVersion,
}

_G.EnhancedWidgetControlCompatibility = state

local function ParseVersion(value)
    local major, minor = tostring(value or ""):match("(%d+)%.(%d+)")
    return tonumber(major), tonumber(minor)
end

local function IsVersionSupported(current)
    local currentMajor, currentMinor = ParseVersion(current)
    local minimumMajor, minimumMinor = ParseVersion(minimumVersion)

    if not currentMajor or not currentMinor then
        return false
    end

    return currentMajor > minimumMajor
        or (currentMajor == minimumMajor and currentMinor >= minimumMinor)
end

local E = ElvUI and ElvUI[1]
if not E then
    state.reason = "ElvUI is not installed or enabled."
else
    state.currentVersion = E.versionString or E.version

    if IsVersionSupported(state.currentVersion) then
        state.compatible = true
        return
    end

    state.reason = "ElvUI " .. minimumVersion
        .. " or newer is required. Detected version: "
        .. tostring(state.currentVersion or "unknown") .. "."
end

local notifier = CreateFrame("Frame")
notifier:RegisterEvent("PLAYER_LOGIN")
notifier:SetScript("OnEvent", function(self)
    self:UnregisterAllEvents()

    local message = "|cffff3333Enhanced Widget Control disabled:|r "
        .. state.reason

    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage(message)
    else
        print(message)
    end
end)
