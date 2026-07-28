local compatibility = _G.EnhancedWidgetControlCompatibility
if not compatibility or not compatibility.compatible then return end

local E, L, V, P, G = unpack(ElvUI)
local addonName = ...
local EWC = E:NewModule("EnhancedWidgetControl", "AceEvent-3.0")

local UIWidgetContainerMixin = UIWidgetContainerMixin
local hooksecurefunc = hooksecurefunc
local ipairs = ipairs
local pairs = pairs
local tostring = tostring
local type = type
local Serializer = LibStub("AceSerializer-3.0")
local Deflate = LibStub("LibDeflate")

E.Libs.LSM:Register(
    "statusbar",
    "__BLIZZARD",
    "Interface\\Buttons\\WHITE8X8"
)

P.enhancedWidgetControl = {
    enabled = true,
    global = {
        barWidth = 200,
        barHeight = 20,
        barScale = 1,
        widgetScale = 1,
        font = "Expressway",
        fontSize = 12,
        fontOutline = "DEFAULT",
        useTextColor = false,
        textColor = { 1, 1, 1, 1 },
        barTexture = "__BLIZZARD",
        useBarColor = false,
        barColor = { 0.2, 0.6, 1, 1 },
        useBarBackground = false,
        barBackgroundColor = { 0, 0, 0, 0.65 },
        useBorder = false,
        borderColor = { 0, 0, 0, 1 },
        borderSize = 1,
        alpha = 1,
        positionOverride = false,
        anchor = "CENTER",
        xOffset = 0,
        yOffset = 0,
        barPositionOverride = false,
        barAnchor = "CENTER",
        barRelativeAnchor = "CENTER",
        barXOffset = 0,
        barYOffset = 0,
        textPositionOverride = false,
        textAnchor = "CENTER",
        textRelativeAnchor = "CENTER",
        textXOffset = 0,
        textYOffset = 0,
        separateValueText = false,
        valueFont = "Expressway",
        valueFontSize = 12,
        valueFontOutline = "DEFAULT",
        useValueTextColor = false,
        valueTextColor = { 1, 1, 1, 1 },
        valueTextPositionOverride = false,
        valueTextAnchor = "CENTER",
        valueTextRelativeAnchor = "CENTER",
        valueTextXOffset = 0,
        valueTextYOffset = 0,
    },
    ignored = {},
    widgets = {},
}

EWC.addonName = addonName
EWC.widgets = {}
EWC.detected = {}
EWC.valueTexts = {}
EWC.metadata = {}
EWC.originals = setmetatable({}, { __mode = "k" })
EWC.decorations = setmetatable({}, { __mode = "k" })
EWC.appliedStates = setmetatable({}, { __mode = "k" })
EWC.selectedWidgetID = nil
EWC.testMode = false

local function CopyValue(value)
    if type(value) ~= "table" then
        return value
    end

    local copy = {}
    for key, child in pairs(value) do
        copy[key] = CopyValue(child)
    end
    return copy
end

EWC.builtinPresets = {
    ["EWC Default"] = {
        barWidth = 145,
        barHeight = 8,
        barScale = 1,
        widgetScale = 1,
        font = "EWC Play Bold",
        fontSize = 8,
        fontOutline = "OUTLINE",
        useTextColor = false,
        textColor = { 1, 1, 1, 1 },
        barTexture = "EWC Dark",
        useBarColor = false,
        barColor = { 0.2, 0.6, 1, 1 },
        useBarBackground = false,
        barBackgroundColor = { 0, 0, 0, 0.65 },
        useBorder = false,
        borderColor = { 0, 0, 0, 1 },
        borderSize = 1,
        alpha = 1,
        positionOverride = true,
        anchor = "CENTER",
        xOffset = 0,
        yOffset = 30,
        barPositionOverride = false,
        barAnchor = "CENTER",
        barRelativeAnchor = "CENTER",
        barXOffset = 0,
        barYOffset = 0,
        textPositionOverride = false,
        textAnchor = "CENTER",
        textRelativeAnchor = "CENTER",
        textXOffset = 0,
        textYOffset = 0,
        separateValueText = true,
        valueFont = "EWC Play Bold",
        valueFontSize = 6,
        valueFontOutline = "OUTLINE",
        useValueTextColor = false,
        valueTextColor = { 1, 1, 1, 1 },
        valueTextPositionOverride = false,
        valueTextAnchor = "CENTER",
        valueTextRelativeAnchor = "CENTER",
        valueTextXOffset = 0,
        valueTextYOffset = 0,
    },
    ["Blizzard"] = {
        barWidth = 200, barHeight = 20, barScale = 1, widgetScale = 1,
        font = "Expressway", fontSize = 12, fontOutline = "DEFAULT",
        barTexture = "__BLIZZARD", useBarColor = false,
        useBarBackground = false, useBorder = false, alpha = 1,
        positionOverride = false, barPositionOverride = false,
        textPositionOverride = false, separateValueText = false,
    },
    ["ElvUI"] = {
        barWidth = 260, barHeight = 18, barScale = 1, widgetScale = 1,
        font = "Expressway", fontSize = 14, fontOutline = "OUTLINE",
        barTexture = "ElvUI Norm", useBarColor = false,
        useBarBackground = true, barBackgroundColor = { 0.05, 0.05, 0.05, 0.8 },
        useBorder = true, borderColor = { 0, 0, 0, 1 }, borderSize = 1,
        alpha = 1,
    },
    ["Minimal"] = {
        barWidth = 220, barHeight = 8, barScale = 1, widgetScale = 1,
        font = "Expressway", fontSize = 12, fontOutline = "OUTLINE",
        barTexture = "ElvUI Norm", useBarColor = false,
        useBarBackground = true, barBackgroundColor = { 0, 0, 0, 0.55 },
        useBorder = false, alpha = 0.95,
    },
    ["Compact"] = {
        barWidth = 180, barHeight = 12, barScale = 1, widgetScale = 0.9,
        font = "Expressway", fontSize = 11, fontOutline = "OUTLINE",
        barTexture = "ElvUI Norm", useBarColor = false,
        useBarBackground = true, barBackgroundColor = { 0, 0, 0, 0.7 },
        useBorder = true, borderColor = { 0, 0, 0, 1 }, borderSize = 1,
        alpha = 1,
    },
    ["Large"] = {
        barWidth = 420, barHeight = 32, barScale = 1, widgetScale = 1,
        font = "Expressway", fontSize = 22, fontOutline = "THICKOUTLINE",
        barTexture = "ElvUI Norm", useBarColor = false,
        useBarBackground = true, barBackgroundColor = { 0, 0, 0, 0.75 },
        useBorder = true, borderColor = { 0, 0, 0, 1 }, borderSize = 2,
        alpha = 1,
    },
    ["Boss"] = {
        barWidth = 500, barHeight = 26, barScale = 1, widgetScale = 1,
        font = "Expressway", fontSize = 18, fontOutline = "THICKOUTLINE",
        barTexture = "ElvUI Norm", useBarColor = true,
        barColor = { 0.75, 0.12, 0.12, 1 },
        useBarBackground = true, barBackgroundColor = { 0.04, 0.01, 0.01, 0.85 },
        useBorder = true, borderColor = { 0, 0, 0, 1 }, borderSize = 2,
        alpha = 1,
    },
}

local function SafeObjectType(object)
    return object and object.GetObjectType and object:GetObjectType()
end

local function GetDisplayText(widget)
    if widget.Label and SafeObjectType(widget.Label) == "FontString" then
        local text = widget.Label:GetText()
        if text and text ~= "" then
            return text
        end
    end

    for _, region in ipairs({ widget:GetRegions() }) do
        if SafeObjectType(region) == "FontString" then
            local text = region:GetText()
            if text and text ~= "" then
                return text
            end
        end
    end
end

local function FindStatusBar(frame)
    if not frame then
        return nil
    end

    if SafeObjectType(frame) == "StatusBar" then
        return frame
    end

    if frame.Bar and SafeObjectType(frame.Bar) == "StatusBar" then
        return frame.Bar
    end

    for _, child in ipairs({ frame:GetChildren() }) do
        local bar = FindStatusBar(child)
        if bar then
            return bar
        end
    end
end

local function CollectFontStrings(frame, output)
    if not frame then
        return
    end

    for _, region in ipairs({ frame:GetRegions() }) do
        if SafeObjectType(region) == "FontString" then
            output[#output + 1] = region
        end
    end

    for _, child in ipairs({ frame:GetChildren() }) do
        CollectFontStrings(child, output)
    end
end

function EWC:GetDatabase()
    local db = E.db.enhancedWidgetControl
    db.widgets = db.widgets or {}
    db.ignored = db.ignored or {}
    db.global = db.global or {}
    db.presets = db.presets or {}

    if db.schemaVersion ~= 6 then
        if db.global and db.global.useBarTexture == false then
            db.global.barTexture = "__BLIZZARD"
        end

        if db.global then
            db.global.useBarTexture = nil
        end

        for _, settings in pairs(db.widgets) do
            if settings.useBarTexture == false then
                settings.barTexture = "__BLIZZARD"
            end

            settings.useBarTexture = nil
        end

        db.schemaVersion = 6
    end

    return db
end

function EWC:GetPresetValues()
    local values = {}

    for name in pairs(self.builtinPresets) do
        values["builtin:" .. name] = name .. " (Built-in)"
    end

    for name in pairs(self:GetDatabase().presets) do
        values["custom:" .. name] = name
    end

    return values
end

function EWC:CreateExport(kind, idOrName)
    local data
    local name

    if kind == "global" then
        data = self:GetGlobalSnapshot()
        name = "Global"
    elseif kind == "preset" then
        local presetKind, presetName = idOrName
            and idOrName:match("^(.-):(.*)$")
        if presetKind == "builtin" then
            data = self.builtinPresets[presetName]
            name = presetName
        elseif presetKind == "custom" then
            data = self:GetDatabase().presets[presetName]
            name = presetName
        else
            data = self:GetDatabase().presets[idOrName]
                or self.builtinPresets[idOrName]
            name = idOrName
        end
    elseif kind == "widget" then
        data = self:GetWidgetSettings(idOrName, false)
        name = tostring(idOrName)
    end

    if not data then return nil end

    local payload = {
        addon = "EnhancedWidgetControl",
        format = 1,
        kind = kind,
        name = name,
        data = CopyValue(data),
    }

    local serialized = Serializer:Serialize(payload)
    local compressed = Deflate:CompressDeflate(serialized, { level = 9 })
    return "EWC1:" .. Deflate:EncodeForPrint(compressed)
end

function EWC:ReadImport(text)
    if type(text) ~= "string" or text:sub(1, 5) ~= "EWC1:" then
        return nil, "Not a valid EWC export string."
    end

    local decoded = Deflate:DecodeForPrint(text:sub(6))
    if not decoded then return nil, "The export string could not be decoded." end

    local decompressed = Deflate:DecompressDeflate(decoded)
    if not decompressed then return nil, "The export string could not be decompressed." end

    local success, payload = Serializer:Deserialize(decompressed)
    if not success or type(payload) ~= "table" then
        return nil, "The export data is damaged."
    end

    if payload.addon ~= "EnhancedWidgetControl"
        or payload.format ~= 1
        or type(payload.data) ~= "table"
        or not ({ global = true, preset = true, widget = true })[payload.kind] then
        return nil, "The export data has an unsupported format."
    end

    return payload
end

function EWC:CreateImportBackup()
    local db = self:GetDatabase()
    db.importBackups = db.importBackups or {}

    table.insert(db.importBackups, 1, {
        timestamp = time(),
        global = self:GetGlobalSnapshot(),
        widgets = CopyValue(db.widgets),
        presets = CopyValue(db.presets),
    })

    while #db.importBackups > 5 do
        table.remove(db.importBackups)
    end
end

function EWC:ApplyImport(payload, destination, target)
    if not payload or type(payload.data) ~= "table" then return false end

    local db = self:GetDatabase()
    local resolvedTarget

    if destination == "preset" then
        resolvedTarget = target and target:match("^%s*(.-)%s*$")
        if not resolvedTarget or resolvedTarget == "" then return false end
    elseif destination == "widget" then
        resolvedTarget = tonumber(target)
        if not resolvedTarget then return false end
    elseif destination ~= "global" then
        return false
    end

    self:CreateImportBackup()

    if destination == "global" then
        for key, value in pairs(payload.data) do
            db.global[key] = CopyValue(value)
        end
        self:ApplyAll()
        self:UpdatePreview()
    elseif destination == "preset" then
        db.presets[resolvedTarget] = CopyValue(payload.data)
    elseif destination == "widget" then
        local settings = self:GetWidgetSettings(resolvedTarget, true)
        for key, value in pairs(payload.data) do
            settings[key] = CopyValue(value)
        end
        local widget = self.widgets[resolvedTarget]
        if widget then self:ApplyWidget(widget, resolvedTarget) end
    end

    if E.Libs.AceConfigRegistry then
        E.Libs.AceConfigRegistry:NotifyChange("ElvUI")
    end

    return true
end

function EWC:RestoreLatestImportBackup()
    local backup = self:GetDatabase().importBackups
        and self:GetDatabase().importBackups[1]
    if not backup then return false end

    local db = self:GetDatabase()
    db.global = CopyValue(backup.global)
    db.widgets = CopyValue(backup.widgets)
    db.presets = CopyValue(backup.presets)
    self:ApplyAll()
    self:UpdatePreview()
    self:RefreshWidgetOptions()
    return true
end

function EWC:ApplyPreset(key)
    if not key then return end

    local kind, name = key:match("^(.-):(.*)$")
    local preset = kind == "builtin" and self.builtinPresets[name]
        or (kind == "custom" and self:GetDatabase().presets[name])

    if not preset then return end

    local global = self:GetDatabase().global
    for setting, value in pairs(preset) do
        global[setting] = CopyValue(value)
    end

    self:ApplyAll()
    self:UpdatePreview()
end

function EWC:GetGlobalSnapshot()
    local snapshot = CopyValue(P.enhancedWidgetControl.global)

    for key, value in pairs(self:GetDatabase().global) do
        snapshot[key] = CopyValue(value)
    end

    return snapshot
end

function EWC:SavePreset(name)
    name = name and name:match("^%s*(.-)%s*$")
    if not name or name == "" then return false end

    self:GetDatabase().presets[name] = self:GetGlobalSnapshot()
    return true
end

function EWC:UpdatePreset(key)
    local kind, name = key and key:match("^(.-):(.*)$")
    if kind ~= "custom" or not name then return false end

    self:GetDatabase().presets[name] = self:GetGlobalSnapshot()
    return true
end

function EWC:DeletePreset(key)
    local kind, name = key and key:match("^(.-):(.*)$")
    if kind ~= "custom" or not name then return false end

    self:GetDatabase().presets[name] = nil
    return true
end

function EWC:CreatePreview()
    if self.preview then return self.preview end

    local frame = CreateFrame("Frame", "EWCPreviewFrame", UIParent)
    frame:SetSize(920, 610)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
    frame:SetFrameStrata("TOOLTIP")
    frame:SetFrameLevel(500)
    frame:SetClampedToScreen(true)
    frame:SetToplevel(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)

    local background = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
    background:SetAllPoints(frame)
    background:SetColorTexture(0.03, 0.03, 0.03, 0.92)

    local topBorder = frame:CreateTexture(nil, "BORDER")
    topBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    topBorder:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    topBorder:SetHeight(2)
    topBorder:SetColorTexture(0.2, 0.6, 1, 1)

    local bottomBorder = frame:CreateTexture(nil, "BORDER")
    bottomBorder:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    bottomBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    bottomBorder:SetHeight(2)
    bottomBorder:SetColorTexture(0.2, 0.6, 1, 1)

    local title = frame:CreateFontString(nil, "OVERLAY", nil, 7)
    title:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
    title:SetPoint("TOP", frame, "TOP", 0, -12)
    title:SetTextColor(0.2, 0.75, 1, 1)
    title:SetText("Enhanced Widget Control - Widget Gallery")

    local subtitle = frame:CreateFontString(nil, "OVERLAY", nil, 7)
    subtitle:SetFont(STANDARD_TEXT_FONT, 10, "")
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -3)
    subtitle:SetTextColor(0.65, 0.65, 0.65, 1)
    subtitle:SetText(
        "1:1 screen size - default colors vary on live widgets - drag to move"
    )

    local closeButton = CreateFrame(
        "Button", nil, frame, "UIPanelCloseButton"
    )
    closeButton:SetSize(28, 28)
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)
    closeButton:SetFrameStrata("TOOLTIP")
    closeButton:SetFrameLevel(550)
    closeButton:SetScript("OnClick", function()
        EWC:SetTestMode(false)

        if E.Libs.AceConfigRegistry then
            E.Libs.AceConfigRegistry:NotifyChange("ElvUI")
        end
    end)

    local sampleData = {
        { "Full Progress Layout", "Objective complete", "100%", 100,
            { 0.2, 0.6, 1, 1 } },
        { "Counter Layout", "Objective progress", "17 / 28", 61,
            { 0.2, 0.6, 1, 1 } },
        { "Timer Layout", "Time remaining", "0:42", 42,
            { 0.2, 0.6, 1, 1 } },
        { "Percentage Layout", "Progress percentage", "73%", 73,
            { 0.2, 0.6, 1, 1 } },
    }

    local samples = {}
    for index, data in ipairs(sampleData) do
        local row = CreateFrame("Frame", nil, frame)
        row:SetSize(860, 125)
        row:SetPoint("TOP", frame, "TOP", 0, -70 - ((index - 1) * 132))

        local rowLabel = row:CreateFontString(nil, "OVERLAY", nil, 7)
        rowLabel:SetFont(STANDARD_TEXT_FONT, 12, "")
        rowLabel:SetPoint("TOPLEFT", row, "TOPLEFT", 4, 0)
        rowLabel:SetTextColor(0.55, 0.75, 0.9, 1)
        rowLabel:SetText(data[1])

        local content = CreateFrame("Frame", nil, row)
        content:SetSize(860, 125)
        content:SetPoint("CENTER", row, "CENTER", 0, 0)
        content:SetFrameStrata("TOOLTIP")
        content:SetFrameLevel(504 + index)

        local bar = CreateFrame("StatusBar", nil, content)
        bar:SetFrameStrata("TOOLTIP")
        bar:SetFrameLevel(505 + index)
        bar:SetPoint("CENTER", row, "CENTER", 0, -12)
        bar:SetMinMaxValues(0, 100)
        bar:SetValue(data[4])
        bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        bar:SetStatusBarColor(unpack(data[5]))

        local textLayer = CreateFrame("Frame", nil, content)
        textLayer:SetAllPoints(content)
        textLayer:SetFrameStrata("TOOLTIP")
        textLayer:SetFrameLevel(520 + index)

        local primary = textLayer:CreateFontString(nil, "OVERLAY", nil, 7)
        primary:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
        primary:SetTextColor(1, 1, 1, 1)
        primary:SetText(data[2])

        local value = textLayer:CreateFontString(nil, "OVERLAY", nil, 7)
        value:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
        value:SetTextColor(1, 1, 1, 1)
        value:SetText(data[3])

        samples[index] = {
            row = row,
            content = content,
            bar = bar,
            primary = primary,
            value = value,
            defaultColor = data[5],
        }
    end

    self.preview = {
        frame = frame,
        samples = samples,
        title = title,
        subtitle = subtitle,
        closeButton = closeButton,
    }
    frame:Hide()
    return self.preview
end

local function SetPreviewTextPoint(fontString, bar, anchor, relativeAnchor, x, y)
    fontString:ClearAllPoints()
    fontString:SetPoint(anchor, bar, relativeAnchor, x or 0, y or 0)
    fontString:SetJustifyH(anchor:find("RIGHT") and "RIGHT"
        or (anchor:find("LEFT") and "LEFT" or "CENTER"))
end

function EWC:UpdatePreview()
    if not self.testMode then return end

    local preview = self:CreatePreview()
    local appearance = self:GetDatabase().global
    local uiScale = UIParent:GetEffectiveScale() or 1
    local pixelCorrection = uiScale > 0 and (1 / uiScale) or 1

    preview.frame:Show()
    preview.frame:Raise()
    local texture = appearance.barTexture ~= "__BLIZZARD"
        and E.LSM:Fetch("statusbar", appearance.barTexture)
        or "Interface\\TargetingFrame\\UI-StatusBar"
    texture = texture or "Interface\\TargetingFrame\\UI-StatusBar"

    local fontPath = E.LSM:Fetch("font", appearance.font) or STANDARD_TEXT_FONT
    local flags = appearance.fontOutline == "DEFAULT" and "OUTLINE"
        or (appearance.fontOutline == "NONE" and "" or appearance.fontOutline)

    for _, sample in ipairs(preview.samples) do
        local bar = sample.bar
        local widgetScale = appearance.widgetScale or 1
        local previewWidth = math.max(1, appearance.barWidth or 200)
        local previewHeight = math.max(1, appearance.barHeight or 20)
        sample.content:SetScale(widgetScale * pixelCorrection)
        bar:SetSize(previewWidth, previewHeight)
        bar:SetScale(appearance.barScale or 1)
        bar:SetAlpha(appearance.alpha or 1)
        bar:SetStatusBarTexture(texture)

        local color = appearance.useBarColor and appearance.barColor
            or sample.defaultColor
        bar:SetStatusBarColor(color[1], color[2], color[3], color[4] or 1)
        self:ApplyBarDecorations(bar, appearance)

        bar:ClearAllPoints()
        if appearance.barPositionOverride then
            bar:SetPoint(
                appearance.barAnchor or "CENTER",
                sample.content,
                appearance.barRelativeAnchor or "CENTER",
                appearance.barXOffset or 0,
                (appearance.barYOffset or 0) - 8
            )
        else
            bar:SetPoint("CENTER", sample.content, "CENTER", 0, -8)
        end

        local galleryFontSize = math.max(1, appearance.fontSize or 12)
        sample.primary:SetFont(fontPath, galleryFontSize, flags)
        sample.primary:SetAlpha(appearance.alpha or 1)
        sample.value:SetAlpha(appearance.alpha or 1)
        if appearance.useTextColor then
            local textColor = appearance.textColor
            sample.primary:SetTextColor(
                textColor[1], textColor[2], textColor[3], textColor[4] or 1
            )
        else
            sample.primary:SetTextColor(1, 1, 1, 1)
        end

        if appearance.textPositionOverride then
            SetPreviewTextPoint(
                sample.primary, bar,
                appearance.textAnchor or "TOP",
                appearance.textRelativeAnchor or "TOP",
                appearance.textXOffset or 0,
                appearance.textYOffset or 8
            )
        else
            SetPreviewTextPoint(sample.primary, bar, "BOTTOM", "TOP", 0, 8)
        end

        if appearance.separateValueText then
            local valueFont = E.LSM:Fetch("font", appearance.valueFont) or fontPath
            local valueFlags = appearance.valueFontOutline == "DEFAULT" and "OUTLINE"
                or (appearance.valueFontOutline == "NONE" and ""
                    or appearance.valueFontOutline)
            local galleryValueSize = math.max(
                1, appearance.valueFontSize or 12
            )
            sample.value:SetFont(valueFont, galleryValueSize, valueFlags)

            if appearance.useValueTextColor then
                local valueColor = appearance.valueTextColor
                sample.value:SetTextColor(
                    valueColor[1], valueColor[2], valueColor[3], valueColor[4] or 1
                )
            else
                sample.value:SetTextColor(1, 1, 1, 1)
            end

            if appearance.valueTextPositionOverride then
                SetPreviewTextPoint(
                    sample.value, bar,
                    appearance.valueTextAnchor or "CENTER",
                    appearance.valueTextRelativeAnchor or "CENTER",
                    appearance.valueTextXOffset or 0,
                    appearance.valueTextYOffset or 0
                )
            else
                SetPreviewTextPoint(sample.value, bar, "CENTER", "CENTER", 0, 0)
            end
        else
            sample.value:SetFont(fontPath, galleryFontSize, flags)
            sample.value:SetTextColor(1, 1, 1, 1)
            SetPreviewTextPoint(sample.value, bar, "CENTER", "CENTER", 0, 0)
        end
    end
end

function EWC:SetTestMode(enabled)
    self.testMode = enabled
    local preview = self:CreatePreview()

    if enabled then
        self:UpdatePreview()
    else
        preview.frame:Hide()
    end
end

function EWC:GetWidgetSettings(id, create)
    id = tonumber(id)
    if not id then
        return nil
    end

    local db = self:GetDatabase()
    db.widgets = db.widgets or {}

    if not db.widgets[id] and create then
        db.widgets[id] = {
            enabled = true,
            overrideGlobal = false,
            favorite = false,
            barWidth = 200,
            barHeight = 20,
            barScale = 1,
            widgetScale = 1,
            font = E.db.general.font,
            fontSize = E.db.general.fontSize or 12,
            fontOutline = "DEFAULT",
            useTextColor = false,
            textColor = { 1, 1, 1, 1 },
            barTexture = "__BLIZZARD",
            useBarColor = false,
            barColor = { 0.2, 0.6, 1, 1 },
            useBarBackground = false,
            barBackgroundColor = { 0, 0, 0, 0.65 },
            useBorder = false,
            borderColor = { 0, 0, 0, 1 },
            borderSize = 1,
            alpha = 1,
            positionOverride = false,
            anchor = "CENTER",
            xOffset = 0,
            yOffset = 0,
            barPositionOverride = false,
            barAnchor = "CENTER",
            barRelativeAnchor = "CENTER",
            barXOffset = 0,
            barYOffset = 0,
            textPositionOverride = false,
            textAnchor = "CENTER",
            textRelativeAnchor = "CENTER",
            textXOffset = 0,
            textYOffset = 0,
            separateValueText = false,
            valueFont = E.db.general.font,
            valueFontSize = E.db.general.fontSize or 12,
            valueFontOutline = "DEFAULT",
            useValueTextColor = false,
            valueTextColor = { 1, 1, 1, 1 },
            valueTextPositionOverride = false,
            valueTextAnchor = "CENTER",
            valueTextRelativeAnchor = "CENTER",
            valueTextXOffset = 0,
            valueTextYOffset = 0,
        }
    end

    local settings = db.widgets[id]

    if settings then
        local defaults = {
            enabled = true,
            overrideGlobal = false,
            favorite = false,
            barWidth = 200,
            barHeight = 20,
            barScale = 1,
            widgetScale = 1,
            font = E.db.general.font,
            fontSize = E.db.general.fontSize or 12,
            fontOutline = "DEFAULT",
            useTextColor = false,
            textColor = { 1, 1, 1, 1 },
            barTexture = "__BLIZZARD",
            useBarColor = false,
            barColor = { 0.2, 0.6, 1, 1 },
            useBarBackground = false,
            barBackgroundColor = { 0, 0, 0, 0.65 },
            useBorder = false,
            borderColor = { 0, 0, 0, 1 },
            borderSize = 1,
            alpha = 1,
            positionOverride = false,
            anchor = "CENTER",
            xOffset = 0,
            yOffset = 0,
            barPositionOverride = false,
            barAnchor = "CENTER",
            barRelativeAnchor = "CENTER",
            barXOffset = 0,
            barYOffset = 0,
            textPositionOverride = false,
            textAnchor = "CENTER",
            textRelativeAnchor = "CENTER",
            textXOffset = 0,
            textYOffset = 0,
        }

        for key, value in pairs(defaults) do
            if settings[key] == nil then
                if type(value) == "table" then
                    settings[key] = { value[1], value[2], value[3], value[4] }
                else
                    settings[key] = value
                end
            end
        end
    end

    return settings
end

function EWC:CaptureWidget(widget)
    local original = self.originals[widget]
    if original then
        return original
    end

    local bar = FindStatusBar(widget)
    local fonts = {}
    CollectFontStrings(widget, fonts)

    original = {
        bar = bar,
        barColor = bar and { bar:GetStatusBarColor() } or nil,
        fonts = {},
    }

    for index, fontString in ipairs(fonts) do
        local font, size, flags = fontString:GetFont()
        original.fonts[index] = {
            object = fontString,
            font = font,
            size = size,
            flags = flags,
            text = fontString:GetText(),
            color = { fontString:GetTextColor() },
        }
    end

    self.originals[widget] = original
    return original
end

local KIT_COLORS = {
    green = { 0.15, 0.85, 0.25, 1 },
    red = { 0.9, 0.15, 0.15, 1 },
    blue = { 0.2, 0.55, 1, 1 },
    yellow = { 1, 0.82, 0.1, 1 },
    gold = { 1, 0.72, 0.1, 1 },
    orange = { 1, 0.42, 0.1, 1 },
    purple = { 0.65, 0.3, 0.9, 1 },
    white = { 1, 1, 1, 1 },
    gray = { 0.55, 0.55, 0.55, 1 },
    grey = { 0.55, 0.55, 0.55, 1 },
}

local function GetWidgetKitColor(widget, original)
    local kit = tostring(widget.textureKit or widget.frameTextureKit or ""):lower()

    for name, color in pairs(KIT_COLORS) do
        if kit:find(name, 1, true) then
            return color
        end
    end

    return original.barColor
end

function EWC:GetBarDecorations(bar)
    local decorations = self.decorations[bar]
    if decorations then
        return decorations
    end

    decorations = {
        background = bar:CreateTexture(nil, "BACKGROUND"),
        top = bar:CreateTexture(nil, "BORDER"),
        bottom = bar:CreateTexture(nil, "BORDER"),
        left = bar:CreateTexture(nil, "BORDER"),
        right = bar:CreateTexture(nil, "BORDER"),
    }

    decorations.background:SetAllPoints(bar)
    self.decorations[bar] = decorations
    return decorations
end

function EWC:ApplyBarDecorations(bar, appearance)
    local decorations = self:GetBarDecorations(bar)

    if appearance.useBarBackground and appearance.barBackgroundColor then
        local color = appearance.barBackgroundColor
        decorations.background:SetColorTexture(
            color[1] or 0,
            color[2] or 0,
            color[3] or 0,
            color[4] or 0.65
        )
        decorations.background:Show()
    else
        decorations.background:Hide()
    end

    local borders = {
        decorations.top,
        decorations.bottom,
        decorations.left,
        decorations.right,
    }

    if appearance.useBorder and appearance.borderColor then
        local color = appearance.borderColor
        local size = appearance.borderSize or 1

        for _, texture in ipairs(borders) do
            texture:SetColorTexture(
                color[1] or 0,
                color[2] or 0,
                color[3] or 0,
                color[4] or 1
            )
            texture:ClearAllPoints()
            texture:Show()
        end

        decorations.top:SetPoint("TOPLEFT", bar, "TOPLEFT", -size, size)
        decorations.top:SetPoint("TOPRIGHT", bar, "TOPRIGHT", size, size)
        decorations.top:SetHeight(size)

        decorations.bottom:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", -size, -size)
        decorations.bottom:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", size, -size)
        decorations.bottom:SetHeight(size)

        decorations.left:SetPoint("TOPLEFT", bar, "TOPLEFT", -size, 0)
        decorations.left:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", -size, 0)
        decorations.left:SetWidth(size)

        decorations.right:SetPoint("TOPRIGHT", bar, "TOPRIGHT", size, 0)
        decorations.right:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", size, 0)
        decorations.right:SetWidth(size)
    else
        for _, texture in ipairs(borders) do
            texture:Hide()
        end
    end
end

function EWC:InitializeWidgetSettings(id, widget)
    local settings = self:GetWidgetSettings(id, true)
    local original = self:CaptureWidget(widget)

    if not settings.initialized then
        local firstFont = original.fonts[1]
        if firstFont then
            settings.fontSize = firstFont.size or settings.fontSize
        end

        settings.initialized = true
    end

    return settings, original
end

function EWC:RestoreWidget(widget, original)
    if not widget or not original then
        return
    end

    if original.bar then
        if original.barColor then
            original.bar:SetStatusBarColor(
                original.barColor[1] or 1,
                original.barColor[2] or 1,
                original.barColor[3] or 1,
                original.barColor[4] or 1
            )
        end
    end

    for _, data in ipairs(original.fonts) do
        if data.object and data.font then
            data.object:SetFont(data.font, data.size or 12, data.flags or "")
        end
    end
end

function EWC:ApplyWidget(widget, id)
    if not widget or not id then
        return
    end

    local settings, original = self:InitializeWidgetSettings(id, widget)

    if not self:GetDatabase().enabled or not settings.enabled then
        self:RestoreWidget(widget, original)
        return
    end

    local db = self:GetDatabase()
    local appearance = settings.overrideGlobal and settings or db.global

    widget:SetScale(appearance.widgetScale or 1)
    widget:SetAlpha(appearance.alpha or 1)

    if appearance.positionOverride then
        if InCombatLockdown() then
            self.pendingPositionUpdate = true
        else
            local parent = widget:GetParent()
            local anchor = appearance.anchor or "CENTER"

            if parent then
                widget:ClearAllPoints()
                widget:SetPoint(
                    anchor,
                    parent,
                    anchor,
                    appearance.xOffset or 0,
                    appearance.yOffset or 0
                )
            end
        end
    end

    local bar = original.bar or FindStatusBar(widget)
    if bar then
        if appearance.barPositionOverride then
            if InCombatLockdown() then
                self.pendingPositionUpdate = true
            else
                bar:ClearAllPoints()
                bar:SetPoint(
                    appearance.barAnchor or "CENTER",
                    widget,
                    appearance.barRelativeAnchor or "CENTER",
                    appearance.barXOffset or 0,
                    appearance.barYOffset or 0
                )
            end
        end

        bar:SetScale(appearance.barScale or 1)
        if appearance.barWidth then bar:SetWidth(appearance.barWidth) end
        if appearance.barHeight then bar:SetHeight(appearance.barHeight) end

        local customTexture = appearance.barTexture
            and appearance.barTexture ~= "__BLIZZARD"

        if customTexture then
            local texture = E.LSM:Fetch("statusbar", appearance.barTexture)
            if texture then
                bar:SetStatusBarTexture(texture)
            end
        end

        if appearance.useBarColor and appearance.barColor then
            bar:SetStatusBarColor(
                appearance.barColor[1] or 1,
                appearance.barColor[2] or 1,
                appearance.barColor[3] or 1,
                appearance.barColor[4] or 1
            )
        elseif customTexture then
            local color = GetWidgetKitColor(widget, original)
            if color then
                bar:SetStatusBarColor(
                    color[1] or 1,
                    color[2] or 1,
                    color[3] or 1,
                    color[4] or 1
                )
            end
        elseif original.barColor then
            bar:SetStatusBarColor(
                original.barColor[1] or 1,
                original.barColor[2] or 1,
                original.barColor[3] or 1,
                original.barColor[4] or 1
            )
        end

        self:ApplyBarDecorations(bar, appearance)
    end

    local primaryText = widget.Label
        or (original.fonts[1] and original.fonts[1].object)
    local valueText
    local appliedState = self.appliedStates[widget]

    if not appliedState then
        appliedState = {}
        self.appliedStates[widget] = appliedState
    end

    for _, data in ipairs(original.fonts) do
        local currentText = data.object and data.object:GetText()

        if data.object ~= primaryText
            and currentText
            and currentText ~= "" then
            valueText = data.object
            self.valueTexts[id] = currentText
            break
        end
    end

    for _, data in ipairs(original.fonts) do
        local fontString = data.object
        if fontString then
            local isValue = fontString == valueText and appearance.separateValueText
            local fontName = isValue and appearance.valueFont or appearance.font
            local fontSize = isValue and appearance.valueFontSize or appearance.fontSize
            local outline = isValue and appearance.valueFontOutline or appearance.fontOutline
            local useColor = isValue and appearance.useValueTextColor
                or (not isValue and appearance.useTextColor)
            local color = isValue and appearance.valueTextColor or appearance.textColor
            local fontPath = fontName and E.LSM:Fetch("font", fontName)
            local flags = outline
            if not flags or flags == "DEFAULT" then
                flags = data.flags or ""
            elseif flags == "NONE" then
                flags = ""
            end

            fontString:SetFont(
                fontPath or data.font,
                fontSize or data.size or 12,
                flags
            )

            if useColor and color then
                fontString:SetTextColor(
                    color[1] or 1,
                    color[2] or 1,
                    color[3] or 1,
                    color[4] or 1
                )
            elseif data.color then
                fontString:SetTextColor(
                    data.color[1] or 1,
                    data.color[2] or 1,
                    data.color[3] or 1,
                    data.color[4] or 1
                )
            end

            local movePrimary = appearance.textPositionOverride
                and fontString == primaryText
            local moveValue = isValue and appearance.valueTextPositionOverride

            if bar and (movePrimary or moveValue) then
                if InCombatLockdown() then
                    self.pendingPositionUpdate = true
                else
                    local anchor = moveValue
                        and (appearance.valueTextAnchor or "CENTER")
                        or (appearance.textAnchor or "CENTER")
                    local relativeAnchor = moveValue
                        and (appearance.valueTextRelativeAnchor or "CENTER")
                        or (appearance.textRelativeAnchor or "CENTER")
                    local xOffset = moveValue
                        and (appearance.valueTextXOffset or 0)
                        or (appearance.textXOffset or 0)
                    local yOffset = moveValue
                        and (appearance.valueTextYOffset or 0)
                        or (appearance.textYOffset or 0)

                    fontString:ClearAllPoints()
                    fontString:SetPoint(
                        anchor,
                        bar,
                        relativeAnchor,
                        xOffset,
                        yOffset
                    )

                    if fontString.SetJustifyH then
                        if anchor:find("RIGHT") then
                            fontString:SetJustifyH("RIGHT")
                        elseif anchor:find("LEFT") then
                            fontString:SetJustifyH("LEFT")
                        else
                            fontString:SetJustifyH("CENTER")
                        end
                    end

                    if fontString.SetJustifyV then
                        if anchor:find("TOP") then
                            fontString:SetJustifyV("TOP")
                        elseif anchor:find("BOTTOM") then
                            fontString:SetJustifyV("BOTTOM")
                        else
                            fontString:SetJustifyV("MIDDLE")
                        end
                    end

                    if moveValue then
                        appliedState.valueTextPosition = true
                    end
                end
            elseif fontString == valueText
                and appliedState.valueTextPosition
                and bar then
                if InCombatLockdown() then
                    self.pendingPositionUpdate = true
                else
                    fontString:ClearAllPoints()
                    fontString:SetPoint("CENTER", bar, "CENTER", 0, 0)
                    fontString:SetJustifyH("CENTER")
                    fontString:SetJustifyV("MIDDLE")
                    appliedState.valueTextPosition = nil
                end
            end
        end
    end
end

function EWC:QueueApply(widget, id)
    C_Timer.After(0, function()
        if self.widgets[id] == widget then
            self:ApplyWidget(widget, id)
        end
    end)
end

function EWC:RegisterWidget(widget, category)
    if not widget or not widget.widgetID then
        return
    end

    local id = tonumber(widget.widgetID)
    if not id then
        return
    end

    if self:GetDatabase().ignored[id] then
        return
    end

    self.widgets[id] = widget
    self.detected[id] = GetDisplayText(widget) or ("Widget " .. tostring(id))
    self.metadata[id] = {
        category = category or "Unknown",
        widgetType = widget.widgetType,
        widgetSetID = widget.widgetSetID,
        textureKit = widget.textureKit or widget.frameTextureKit,
    }
    self.seenThisSession = self.seenThisSession or {}
    self.seenThisSession[id] = true

    if not self.selectedWidgetID then
        self.selectedWidgetID = id
    end

    self:InitializeWidgetSettings(id, widget)
    self:RefreshWidgetOptions()
    self:QueueApply(widget, id)
end

function EWC:ScanContainer(container, category)
    if not container or not container.GetChildren then
        return
    end

    for _, child in ipairs({ container:GetChildren() }) do
        if child.widgetID then
            self:RegisterWidget(child, category)
        end
    end
end

function EWC:ScanWidgets()
    if C_NamePlate and C_NamePlate.GetNamePlates then
        for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
            local unitFrame = plate.UnitFrame
            self:ScanContainer(unitFrame and unitFrame.WidgetContainer, "Nameplates")
        end
    end

    self:ScanContainer(_G.UIWidgetTopCenterContainerFrame, "Top Center")
    self:ScanContainer(_G.UIWidgetBelowMinimapContainerFrame, "Below Minimap")
    self:ScanContainer(_G.UIWidgetPowerBarContainerFrame, "Power Bar")
end

function EWC:GetContainerCategory(container)
    if container == _G.UIWidgetTopCenterContainerFrame then return "Top Center" end
    if container == _G.UIWidgetBelowMinimapContainerFrame then return "Below Minimap" end
    if container == _G.UIWidgetPowerBarContainerFrame then return "Power Bar" end
    return "Nameplates / Other"
end

function EWC:ApplyAll()
    for id, widget in pairs(self.widgets) do
        self:ApplyWidget(widget, id)
    end
end

function EWC:ResetSelected()
    local id = self.selectedWidgetID
    if not id then
        return
    end

    local widget = self.widgets[id]
    local original = widget and self:CaptureWidget(widget)
    local settings = self:GetWidgetSettings(id, true)

    settings.enabled = false
    settings.overrideGlobal = false
    settings.barWidth = 200
    settings.barHeight = 20
    settings.barScale = 1
    settings.widgetScale = 1
    settings.font = E.db.general.font
    settings.fontSize = original and original.fonts[1]
        and original.fonts[1].size or (E.db.general.fontSize or 12)
    settings.positionOverride = false
    settings.anchor = "CENTER"
    settings.xOffset = 0
    settings.yOffset = 0
    settings.barPositionOverride = false
    settings.barAnchor = "CENTER"
    settings.barRelativeAnchor = "CENTER"
    settings.barXOffset = 0
    settings.barYOffset = 0
    settings.textPositionOverride = false
    settings.textAnchor = "CENTER"
    settings.textRelativeAnchor = "CENTER"
    settings.textXOffset = 0
    settings.textYOffset = 0
    settings.separateValueText = false
    settings.valueFont = E.db.general.font
    settings.valueFontSize = E.db.general.fontSize or 12
    settings.valueFontOutline = "DEFAULT"
    settings.useValueTextColor = false
    settings.valueTextColor = { 1, 1, 1, 1 }
    settings.valueTextPositionOverride = false
    settings.valueTextAnchor = "CENTER"
    settings.valueTextRelativeAnchor = "CENTER"
    settings.valueTextXOffset = 0
    settings.valueTextYOffset = 0
    settings.fontOutline = "DEFAULT"
    settings.useTextColor = false
    settings.textColor = { 1, 1, 1, 1 }
    settings.barTexture = "__BLIZZARD"
    settings.useBarColor = false
    settings.barColor = { 0.2, 0.6, 1, 1 }
    settings.useBarBackground = false
    settings.barBackgroundColor = { 0, 0, 0, 0.65 }
    settings.useBorder = false
    settings.borderColor = { 0, 0, 0, 1 }
    settings.borderSize = 1
    settings.alpha = 1
    settings.initialized = true

    if widget then
        self:ApplyWidget(widget, id)
    end
end

function EWC:ResetAll()
    local db = self:GetDatabase()

    for _, settings in pairs(db.widgets or {}) do
        settings.enabled = false
        settings.positionOverride = false
        settings.xOffset = 0
        settings.yOffset = 0
    end

    self:ApplyAll()
end

function EWC:ResetEverything()
    local db = self:GetDatabase()

    db.enabled = true
    db.schemaVersion = 6
    db.global = {
        barWidth = 200,
        barHeight = 20,
        barScale = 1,
        widgetScale = 1,
        font = E.db.general.font or "Expressway",
        fontSize = E.db.general.fontSize or 12,
        fontOutline = "DEFAULT",
        useTextColor = false,
        textColor = { 1, 1, 1, 1 },
        barTexture = "__BLIZZARD",
        useBarColor = false,
        barColor = { 0.2, 0.6, 1, 1 },
        useBarBackground = false,
        barBackgroundColor = { 0, 0, 0, 0.65 },
        useBorder = false,
        borderColor = { 0, 0, 0, 1 },
        borderSize = 1,
        alpha = 1,
        positionOverride = false,
        anchor = "CENTER",
        xOffset = 0,
        yOffset = 0,
        barPositionOverride = false,
        barAnchor = "CENTER",
        barRelativeAnchor = "CENTER",
        barXOffset = 0,
        barYOffset = 0,
        textPositionOverride = false,
        textAnchor = "CENTER",
        textRelativeAnchor = "CENTER",
        textXOffset = 0,
        textYOffset = 0,
        separateValueText = false,
        valueFont = E.db.general.font or "Expressway",
        valueFontSize = E.db.general.fontSize or 12,
        valueFontOutline = "DEFAULT",
        useValueTextColor = false,
        valueTextColor = { 1, 1, 1, 1 },
        valueTextPositionOverride = false,
        valueTextAnchor = "CENTER",
        valueTextRelativeAnchor = "CENTER",
        valueTextXOffset = 0,
        valueTextYOffset = 0,
    }
    db.widgets = {}
    db.ignored = {}
    db.presets = {}
    db.importBackups = {}

    self.widgets = {}
    self.detected = {}
    self.metadata = {}
    self.valueTexts = {}
    self.seenThisSession = {}
    self.originals = setmetatable({}, { __mode = "k" })
    self.decorations = setmetatable({}, { __mode = "k" })
    self.appliedStates = setmetatable({}, { __mode = "k" })

    ReloadUI()
end

function EWC:CopyWidgetSettings(sourceID, targetID)
    local source = self:GetWidgetSettings(sourceID, false)
    local target = self:GetWidgetSettings(targetID, true)

    if not source or not target then
        return false
    end

    local keys = {
        "enabled", "overrideGlobal",
        "barWidth", "barHeight", "barScale", "widgetScale",
        "font", "fontSize", "fontOutline", "useTextColor", "textColor",
        "barTexture", "useBarColor", "barColor", "alpha",
        "useBarBackground", "barBackgroundColor",
        "useBorder", "borderColor", "borderSize",
        "positionOverride", "anchor", "xOffset", "yOffset",
        "barPositionOverride", "barAnchor", "barRelativeAnchor",
        "barXOffset", "barYOffset",
        "textPositionOverride", "textAnchor", "textRelativeAnchor",
        "textXOffset", "textYOffset",
        "separateValueText", "valueFont", "valueFontSize", "valueFontOutline",
        "useValueTextColor", "valueTextColor",
        "valueTextPositionOverride", "valueTextAnchor", "valueTextRelativeAnchor",
        "valueTextXOffset", "valueTextYOffset",
    }

    for _, key in ipairs(keys) do
        if type(source[key]) == "table" then
            target[key] = {
                source[key][1],
                source[key][2],
                source[key][3],
                source[key][4],
            }
        else
            target[key] = source[key]
        end
    end

    local widget = self.widgets[targetID]
    if widget then
        self:ApplyWidget(widget, targetID)
    end

    return true
end

function EWC:CleanupUnused()
    local db = self:GetDatabase()
    local removed = 0

    for id in pairs(db.widgets) do
        if not (self.seenThisSession and self.seenThisSession[id]) then
            db.widgets[id] = nil
            removed = removed + 1
        end
    end

    self:RefreshWidgetOptions()
    return removed
end

function EWC:IgnoreWidget(id)
    local db = self:GetDatabase()
    db.ignored[id] = true
    db.widgets[id] = nil
    self.widgets[id] = nil
    self.detected[id] = nil
    self.metadata[id] = nil
    self.valueTexts[id] = nil

    if self.seenThisSession then
        self.seenThisSession[id] = nil
    end

    self:RefreshWidgetOptions()
end

function EWC:ClearIgnored()
    self:GetDatabase().ignored = {}
    self:ScanWidgets()
    self:RefreshWidgetOptions()
end

function EWC:PLAYER_REGEN_ENABLED()
    if self.pendingPositionUpdate then
        self.pendingPositionUpdate = nil
        self:ApplyAll()
    end
end

function EWC:OnNamePlateAdded()
    C_Timer.After(0, function()
        self:ScanWidgets()
    end)
end

function EWC:InitializeHooks()
    if self.hooksInitialized then
        return
    end

    self.hooksInitialized = true

    if UIWidgetContainerMixin and UIWidgetContainerMixin.CreateWidget then
        hooksecurefunc(UIWidgetContainerMixin, "CreateWidget", function(container)
            C_Timer.After(0, function()
                EWC:ScanContainer(container, EWC:GetContainerCategory(container))
            end)
        end)
    end

    if UIWidgetContainerMixin and UIWidgetContainerMixin.ProcessWidget then
        hooksecurefunc(UIWidgetContainerMixin, "ProcessWidget", function(container)
            C_Timer.After(0, function()
                EWC:ScanContainer(container, EWC:GetContainerCategory(container))
            end)
        end)
    end
end

function EWC:Initialize()
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED", "OnNamePlateAdded")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnNamePlateAdded")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:InitializeHooks()
    E.Libs.EP:RegisterPlugin(addonName, function()
        self:AddOptions()
    end)

    C_Timer.After(1, function()
        self:ScanWidgets()
    end)
end

_G.EnhancedWidgetControl = EWC
E:RegisterModule(EWC:GetName())
