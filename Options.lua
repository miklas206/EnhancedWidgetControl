local compatibility = _G.EnhancedWidgetControlCompatibility
if not compatibility or not compatibility.compatible then return end

local E, L, V, P, G = unpack(ElvUI)
local EWC = E:GetModule("EnhancedWidgetControl")

local ANCHORS = {
    TOPLEFT = "Top left",
    TOP = "Top",
    TOPRIGHT = "Top right",
    LEFT = "Left",
    CENTER = "Center",
    RIGHT = "Right",
    BOTTOMLEFT = "Bottom left",
    BOTTOM = "Bottom",
    BOTTOMRIGHT = "Bottom right",
}

local OUTLINES = {
    DEFAULT = "Blizzard default",
    NONE = "None",
    OUTLINE = "Outline",
    THICKOUTLINE = "Thick outline",
    ["MONOCHROME,OUTLINE"] = "Monochrome outline",
}

local function ApplyWidget(id)
    local widget = EWC.widgets[id]
    if widget then
        EWC:ApplyWidget(widget, id)
    end
end

local function WidgetSettings(id)
    return EWC:GetWidgetSettings(id, true)
end

local function WidgetGet(id, key)
    return WidgetSettings(id)[key]
end

local function WidgetSet(id, key, value)
    WidgetSettings(id)[key] = value
    ApplyWidget(id)
end

local function GlobalGet(key)
    return EWC:GetDatabase().global[key]
end

local function GlobalSet(key, value)
    EWC:GetDatabase().global[key] = value
    EWC:ApplyAll()
    EWC:UpdatePreview()
end

local function WidgetColorGet(id, key)
    local color = WidgetGet(id, key) or { 1, 1, 1, 1 }
    return color[1], color[2], color[3], color[4]
end

local function WidgetColorSet(id, key, r, g, b, a)
    WidgetSet(id, key, { r, g, b, a })
end

local function GlobalColorGet(key)
    local color = GlobalGet(key) or { 1, 1, 1, 1 }
    return color[1], color[2], color[3], color[4]
end

local function GlobalColorSet(key, r, g, b, a)
    GlobalSet(key, { r, g, b, a })
end

local function BarTextureValues()
    local values = {
        __BLIZZARD = "Blizzard Default",
    }

    for _, name in ipairs(E.LSM:List("statusbar")) do
        values[name] = name
    end

    return values
end

local function CopyValues(targetID)
    local values = {}

    for id, name in pairs(EWC.detected) do
        if id ~= targetID then
            values[id] = tostring(id) .. " — " .. tostring(name)
        end
    end

    for id in pairs(EWC:GetDatabase().widgets or {}) do
        if id ~= targetID and not values[id] then
            values[id] = tostring(id) .. " — Saved widget"
        end
    end

    return values
end

local function CreateWidgetOptions(id)
    local settings = WidgetSettings(id)
    local detectedName = EWC.detected[id] or ("Saved widget " .. tostring(id))
    local displayName = settings.customName and settings.customName ~= ""
        and settings.customName or detectedName
    local metadata = EWC.metadata[id] or {}

    return {
        order = id,
        type = "group",
        name = tostring(id) .. " — " .. displayName,
        args = {
            information = {
                order = 1,
                type = "description",
                name = "Widget ID: |cff00c0fa" .. tostring(id) .. "|r\n"
                    .. "Detected text: |cffffffff" .. detectedName .. "|r\n"
                    .. "Container: |cffffffff" .. tostring(metadata.category or "Unknown") .. "|r\n"
                    .. "Widget type: |cffffffff" .. tostring(metadata.widgetType or "Unknown") .. "|r\n"
                    .. "Widget set: |cffffffff" .. tostring(metadata.widgetSetID or "Unknown") .. "|r\n"
                    .. "Texture kit: |cffffffff" .. tostring(metadata.textureKit or "Unknown") .. "|r",
            },
            customName = {
                order = 1.2,
                type = "input",
                name = "Custom name",
                get = function() return WidgetGet(id, "customName") or "" end,
                set = function(_, value)
                    WidgetSettings(id).customName = value ~= "" and value or nil
                    EWC:RefreshWidgetOptions()
                end,
            },
            favorite = {
                order = 1.3,
                type = "toggle",
                name = "Favorite",
                get = function() return WidgetGet(id, "favorite") end,
                set = function(_, value)
                    WidgetSettings(id).favorite = value
                    EWC:RefreshWidgetOptions()
                end,
            },
            enabled = {
                order = 2,
                type = "toggle",
                name = "Customize this widget",
                desc = "Enable Enhanced Widget Control for this widget.",
                get = function() return WidgetGet(id, "enabled") end,
                set = function(_, value) WidgetSet(id, "enabled", value) end,
            },
            overrideGlobal = {
                order = 3,
                type = "toggle",
                name = "Override global appearance",
                desc = "Use unique bar, font and internal positioning settings for this widget.",
                disabled = function() return not WidgetGet(id, "enabled") end,
                get = function() return WidgetGet(id, "overrideGlobal") end,
                set = function(_, value) WidgetSet(id, "overrideGlobal", value) end,
            },
            bar = {
                order = 10,
                type = "group",
                name = "Bar",
                inline = true,
                disabled = function()
                    return not WidgetGet(id, "enabled")
                        or not WidgetGet(id, "overrideGlobal")
                end,
                args = {
                    barWidth = {
                        order = 1,
                        type = "range",
                        name = "Width",
                        min = 20,
                        max = 1000,
                        step = 1,
                        get = function() return WidgetGet(id, "barWidth") or 200 end,
                        set = function(_, value) WidgetSet(id, "barWidth", value) end,
                    },
                    barHeight = {
                        order = 2,
                        type = "range",
                        name = "Height",
                        min = 2,
                        max = 200,
                        step = 1,
                        get = function() return WidgetGet(id, "barHeight") or 20 end,
                        set = function(_, value) WidgetSet(id, "barHeight", value) end,
                    },
                    barScale = {
                        order = 3,
                        type = "range",
                        name = "Bar scale",
                        min = 0.1,
                        max = 5,
                        step = 0.01,
                        isPercent = true,
                        get = function() return WidgetGet(id, "barScale") or 1 end,
                        set = function(_, value) WidgetSet(id, "barScale", value) end,
                    },
                    barTexture = {
                        order = 4,
                        type = "select",
                        dialogControl = "LSM30_Statusbar",
                        name = "Bar texture",
                        values = BarTextureValues,
                        get = function()
                            return WidgetGet(id, "barTexture") or "__BLIZZARD"
                        end,
                        set = function(_, value) WidgetSet(id, "barTexture", value) end,
                    },
                    useBarColor = {
                        order = 5,
                        type = "toggle",
                        name = "Override bar color",
                        get = function() return WidgetGet(id, "useBarColor") end,
                        set = function(_, value) WidgetSet(id, "useBarColor", value) end,
                    },
                    barColor = {
                        order = 6,
                        type = "color",
                        name = "Bar color",
                        hasAlpha = true,
                        disabled = function() return not WidgetGet(id, "useBarColor") end,
                        get = function() return WidgetColorGet(id, "barColor") end,
                        set = function(_, r, g, b, a)
                            WidgetColorSet(id, "barColor", r, g, b, a)
                        end,
                    },
                    useBarBackground = {
                        order = 7,
                        type = "toggle",
                        name = "Custom bar background",
                        get = function() return WidgetGet(id, "useBarBackground") end,
                        set = function(_, value)
                            WidgetSet(id, "useBarBackground", value)
                        end,
                    },
                    barBackgroundColor = {
                        order = 8,
                        type = "color",
                        name = "Background color",
                        hasAlpha = true,
                        disabled = function()
                            return not WidgetGet(id, "useBarBackground")
                        end,
                        get = function()
                            return WidgetColorGet(id, "barBackgroundColor")
                        end,
                        set = function(_, r, g, b, a)
                            WidgetColorSet(id, "barBackgroundColor", r, g, b, a)
                        end,
                    },
                    useBorder = {
                        order = 9,
                        type = "toggle",
                        name = "Custom border",
                        get = function() return WidgetGet(id, "useBorder") end,
                        set = function(_, value) WidgetSet(id, "useBorder", value) end,
                    },
                    borderColor = {
                        order = 10,
                        type = "color",
                        name = "Border color",
                        hasAlpha = true,
                        disabled = function() return not WidgetGet(id, "useBorder") end,
                        get = function() return WidgetColorGet(id, "borderColor") end,
                        set = function(_, r, g, b, a)
                            WidgetColorSet(id, "borderColor", r, g, b, a)
                        end,
                    },
                    borderSize = {
                        order = 11,
                        type = "range",
                        name = "Border size",
                        min = 1, max = 8, step = 1,
                        disabled = function() return not WidgetGet(id, "useBorder") end,
                        get = function() return WidgetGet(id, "borderSize") or 1 end,
                        set = function(_, value) WidgetSet(id, "borderSize", value) end,
                    },
                },
            },
            text = {
                order = 20,
                type = "group",
                name = "Text",
                inline = true,
                disabled = function()
                    return not WidgetGet(id, "enabled")
                        or not WidgetGet(id, "overrideGlobal")
                end,
                args = {
                    font = {
                        order = 1,
                        type = "select",
                        dialogControl = "LSM30_Font",
                        name = "Font",
                        values = AceGUIWidgetLSMlists.font,
                        get = function() return WidgetGet(id, "font") end,
                        set = function(_, value) WidgetSet(id, "font", value) end,
                    },
                    fontSize = {
                        order = 2,
                        type = "range",
                        name = "Font size",
                        min = 6,
                        max = 72,
                        step = 1,
                        get = function() return WidgetGet(id, "fontSize") or 12 end,
                        set = function(_, value) WidgetSet(id, "fontSize", value) end,
                    },
                    fontOutline = {
                        order = 3,
                        type = "select",
                        name = "Font outline",
                        values = OUTLINES,
                        get = function() return WidgetGet(id, "fontOutline") or "DEFAULT" end,
                        set = function(_, value) WidgetSet(id, "fontOutline", value) end,
                    },
                    useTextColor = {
                        order = 4,
                        type = "toggle",
                        name = "Override text color",
                        get = function() return WidgetGet(id, "useTextColor") end,
                        set = function(_, value) WidgetSet(id, "useTextColor", value) end,
                    },
                    textColor = {
                        order = 5,
                        type = "color",
                        name = "Text color",
                        hasAlpha = true,
                        disabled = function() return not WidgetGet(id, "useTextColor") end,
                        get = function() return WidgetColorGet(id, "textColor") end,
                        set = function(_, r, g, b, a)
                            WidgetColorSet(id, "textColor", r, g, b, a)
                        end,
                    },
                    widgetScale = {
                        order = 6,
                        type = "range",
                        name = "Whole widget scale",
                        min = 0.1,
                        max = 5,
                        step = 0.01,
                        isPercent = true,
                        get = function() return WidgetGet(id, "widgetScale") or 1 end,
                        set = function(_, value) WidgetSet(id, "widgetScale", value) end,
                    },
                    alpha = {
                        order = 7,
                        type = "range",
                        name = "Widget opacity",
                        min = 0.05,
                        max = 1,
                        step = 0.01,
                        isPercent = true,
                        get = function() return WidgetGet(id, "alpha") or 1 end,
                        set = function(_, value) WidgetSet(id, "alpha", value) end,
                    },
                },
            },
            valueText = {
                order = 25,
                type = "group",
                name = "Value text",
                inline = true,
                hidden = function() return not EWC.valueTexts[id] end,
                disabled = function()
                    return not WidgetGet(id, "enabled")
                        or not WidgetGet(id, "overrideGlobal")
                end,
                args = {
                    detected = {
                        order = 1,
                        type = "description",
                        name = function()
                            return "Detected value: |cffffffff"
                                .. tostring(EWC.valueTexts[id] or "None") .. "|r"
                        end,
                    },
                    separateValueText = {
                        order = 2,
                        type = "toggle",
                        name = "Style value text separately",
                        desc = "Turning this off restores inherited styling but keeps your custom values for later.",
                        get = function() return WidgetGet(id, "separateValueText") end,
                        set = function(_, value)
                            WidgetSet(id, "separateValueText", value)
                        end,
                    },
                    valueFont = {
                        order = 3,
                        type = "select",
                        dialogControl = "LSM30_Font",
                        name = "Value font",
                        values = AceGUIWidgetLSMlists.font,
                        disabled = function()
                            return not WidgetGet(id, "separateValueText")
                        end,
                        get = function() return WidgetGet(id, "valueFont") end,
                        set = function(_, value) WidgetSet(id, "valueFont", value) end,
                    },
                    valueFontSize = {
                        order = 4,
                        type = "range",
                        name = "Value font size",
                        min = 6, max = 72, step = 1,
                        disabled = function()
                            return not WidgetGet(id, "separateValueText")
                        end,
                        get = function() return WidgetGet(id, "valueFontSize") or 12 end,
                        set = function(_, value) WidgetSet(id, "valueFontSize", value) end,
                    },
                    valueFontOutline = {
                        order = 5,
                        type = "select",
                        name = "Value outline",
                        values = OUTLINES,
                        disabled = function()
                            return not WidgetGet(id, "separateValueText")
                        end,
                        get = function()
                            return WidgetGet(id, "valueFontOutline") or "DEFAULT"
                        end,
                        set = function(_, value)
                            WidgetSet(id, "valueFontOutline", value)
                        end,
                    },
                    useValueTextColor = {
                        order = 6,
                        type = "toggle",
                        name = "Custom value color",
                        disabled = function()
                            return not WidgetGet(id, "separateValueText")
                        end,
                        get = function() return WidgetGet(id, "useValueTextColor") end,
                        set = function(_, value)
                            WidgetSet(id, "useValueTextColor", value)
                        end,
                    },
                    valueTextColor = {
                        order = 7,
                        type = "color",
                        name = "Value color",
                        hasAlpha = true,
                        disabled = function()
                            return not WidgetGet(id, "separateValueText")
                                or not WidgetGet(id, "useValueTextColor")
                        end,
                        get = function() return WidgetColorGet(id, "valueTextColor") end,
                        set = function(_, r, g, b, a)
                            WidgetColorSet(id, "valueTextColor", r, g, b, a)
                        end,
                    },
                    valueTextPositionOverride = {
                        order = 10,
                        type = "toggle",
                        name = "Move value text separately",
                        disabled = function()
                            return not WidgetGet(id, "separateValueText")
                        end,
                        get = function()
                            return WidgetGet(id, "valueTextPositionOverride")
                        end,
                        set = function(_, value)
                            WidgetSet(id, "valueTextPositionOverride", value)
                        end,
                    },
                    valueTextAnchor = {
                        order = 11,
                        type = "select",
                        name = "Value anchor",
                        values = ANCHORS,
                        disabled = function()
                            return not WidgetGet(id, "separateValueText")
                                or not WidgetGet(id, "valueTextPositionOverride")
                        end,
                        get = function()
                            return WidgetGet(id, "valueTextAnchor") or "CENTER"
                        end,
                        set = function(_, value)
                            WidgetSet(id, "valueTextAnchor", value)
                        end,
                    },
                    valueTextRelativeAnchor = {
                        order = 12,
                        type = "select",
                        name = "Bar anchor for value",
                        values = ANCHORS,
                        disabled = function()
                            return not WidgetGet(id, "separateValueText")
                                or not WidgetGet(id, "valueTextPositionOverride")
                        end,
                        get = function()
                            return WidgetGet(id, "valueTextRelativeAnchor") or "CENTER"
                        end,
                        set = function(_, value)
                            WidgetSet(id, "valueTextRelativeAnchor", value)
                        end,
                    },
                    valueTextXOffset = {
                        order = 13,
                        type = "range",
                        name = "Value X offset",
                        min = -1000, max = 1000, step = 1,
                        disabled = function()
                            return not WidgetGet(id, "separateValueText")
                                or not WidgetGet(id, "valueTextPositionOverride")
                        end,
                        get = function() return WidgetGet(id, "valueTextXOffset") or 0 end,
                        set = function(_, value)
                            WidgetSet(id, "valueTextXOffset", value)
                        end,
                    },
                    valueTextYOffset = {
                        order = 14,
                        type = "range",
                        name = "Value Y offset",
                        min = -1000, max = 1000, step = 1,
                        disabled = function()
                            return not WidgetGet(id, "separateValueText")
                                or not WidgetGet(id, "valueTextPositionOverride")
                        end,
                        get = function() return WidgetGet(id, "valueTextYOffset") or 0 end,
                        set = function(_, value)
                            WidgetSet(id, "valueTextYOffset", value)
                        end,
                    },
                },
            },
            position = {
                order = 30,
                type = "group",
                name = "Position (experimental)",
                inline = true,
                disabled = function() return not WidgetGet(id, "enabled") end,
                args = {
                    warning = {
                        order = 1,
                        type = "description",
                        name = "|cffffcc00This places the widget relative to its Blizzard container "
                            .. "without reading protected frame measurements. Changes wait until combat ends.|r",
                    },
                    positionOverride = {
                        order = 2,
                        type = "toggle",
                        name = "Use custom position",
                        get = function() return WidgetGet(id, "positionOverride") end,
                        set = function(_, value)
                            WidgetSet(id, "positionOverride", value)
                        end,
                    },
                    anchor = {
                        order = 3,
                        type = "select",
                        name = "Anchor",
                        values = ANCHORS,
                        disabled = function()
                            return not WidgetGet(id, "positionOverride")
                        end,
                        get = function() return WidgetGet(id, "anchor") or "CENTER" end,
                        set = function(_, value) WidgetSet(id, "anchor", value) end,
                    },
                    xOffset = {
                        order = 4,
                        type = "range",
                        name = "X offset",
                        min = -1000,
                        max = 1000,
                        step = 1,
                        disabled = function()
                            return not WidgetGet(id, "positionOverride")
                        end,
                        get = function() return WidgetGet(id, "xOffset") or 0 end,
                        set = function(_, value) WidgetSet(id, "xOffset", value) end,
                    },
                    yOffset = {
                        order = 5,
                        type = "range",
                        name = "Y offset",
                        min = -1000,
                        max = 1000,
                        step = 1,
                        disabled = function()
                            return not WidgetGet(id, "positionOverride")
                        end,
                        get = function() return WidgetGet(id, "yOffset") or 0 end,
                        set = function(_, value) WidgetSet(id, "yOffset", value) end,
                    },
                },
            },
            internalPosition = {
                order = 40,
                type = "group",
                name = "Bar and text position",
                inline = true,
                disabled = function()
                    return not WidgetGet(id, "enabled")
                        or not WidgetGet(id, "overrideGlobal")
                end,
                args = {
                    barHeader = {
                        order = 1,
                        type = "header",
                        name = "Bar position inside widget",
                    },
                    barPositionOverride = {
                        order = 2,
                        type = "toggle",
                        name = "Move bar separately",
                        get = function() return WidgetGet(id, "barPositionOverride") end,
                        set = function(_, value)
                            WidgetSet(id, "barPositionOverride", value)
                        end,
                    },
                    barAnchor = {
                        order = 3,
                        type = "select",
                        name = "Bar anchor",
                        values = ANCHORS,
                        disabled = function()
                            return not WidgetGet(id, "barPositionOverride")
                        end,
                        get = function() return WidgetGet(id, "barAnchor") or "CENTER" end,
                        set = function(_, value) WidgetSet(id, "barAnchor", value) end,
                    },
                    barRelativeAnchor = {
                        order = 4,
                        type = "select",
                        name = "Widget anchor",
                        values = ANCHORS,
                        disabled = function()
                            return not WidgetGet(id, "barPositionOverride")
                        end,
                        get = function()
                            return WidgetGet(id, "barRelativeAnchor") or "CENTER"
                        end,
                        set = function(_, value)
                            WidgetSet(id, "barRelativeAnchor", value)
                        end,
                    },
                    barXOffset = {
                        order = 5,
                        type = "range",
                        name = "Bar X offset",
                        min = -1000, max = 1000, step = 1,
                        disabled = function()
                            return not WidgetGet(id, "barPositionOverride")
                        end,
                        get = function() return WidgetGet(id, "barXOffset") or 0 end,
                        set = function(_, value) WidgetSet(id, "barXOffset", value) end,
                    },
                    barYOffset = {
                        order = 6,
                        type = "range",
                        name = "Bar Y offset",
                        min = -1000, max = 1000, step = 1,
                        disabled = function()
                            return not WidgetGet(id, "barPositionOverride")
                        end,
                        get = function() return WidgetGet(id, "barYOffset") or 0 end,
                        set = function(_, value) WidgetSet(id, "barYOffset", value) end,
                    },
                    textHeader = {
                        order = 10,
                        type = "header",
                        name = "Text position relative to bar",
                    },
                    textPositionOverride = {
                        order = 11,
                        type = "toggle",
                        name = "Move text separately",
                        get = function() return WidgetGet(id, "textPositionOverride") end,
                        set = function(_, value)
                            WidgetSet(id, "textPositionOverride", value)
                        end,
                    },
                    textAnchor = {
                        order = 12,
                        type = "select",
                        name = "Text anchor",
                        desc = "The point on the text attached to the bar.",
                        values = ANCHORS,
                        disabled = function()
                            return not WidgetGet(id, "textPositionOverride")
                        end,
                        get = function() return WidgetGet(id, "textAnchor") or "CENTER" end,
                        set = function(_, value) WidgetSet(id, "textAnchor", value) end,
                    },
                    textRelativeAnchor = {
                        order = 13,
                        type = "select",
                        name = "Bar anchor",
                        desc = "The point on the bar used by the text.",
                        values = ANCHORS,
                        disabled = function()
                            return not WidgetGet(id, "textPositionOverride")
                        end,
                        get = function()
                            return WidgetGet(id, "textRelativeAnchor") or "CENTER"
                        end,
                        set = function(_, value)
                            WidgetSet(id, "textRelativeAnchor", value)
                        end,
                    },
                    textXOffset = {
                        order = 14,
                        type = "range",
                        name = "Text X offset",
                        min = -1000, max = 1000, step = 1,
                        disabled = function()
                            return not WidgetGet(id, "textPositionOverride")
                        end,
                        get = function() return WidgetGet(id, "textXOffset") or 0 end,
                        set = function(_, value) WidgetSet(id, "textXOffset", value) end,
                    },
                    textYOffset = {
                        order = 15,
                        type = "range",
                        name = "Text Y offset",
                        min = -1000, max = 1000, step = 1,
                        disabled = function()
                            return not WidgetGet(id, "textPositionOverride")
                        end,
                        get = function() return WidgetGet(id, "textYOffset") or 0 end,
                        set = function(_, value) WidgetSet(id, "textYOffset", value) end,
                    },
                },
            },
            copy = {
                order = 90,
                type = "group",
                name = "Copy settings",
                inline = true,
                args = {
                    source = {
                        order = 1,
                        type = "select",
                        name = "Copy from",
                        values = function() return CopyValues(id) end,
                        get = function()
                            EWC.copySources = EWC.copySources or {}
                            return EWC.copySources[id]
                        end,
                        set = function(_, value)
                            EWC.copySources = EWC.copySources or {}
                            EWC.copySources[id] = tonumber(value)
                        end,
                    },
                    copyButton = {
                        order = 2,
                        type = "execute",
                        name = "Copy to this widget",
                        disabled = function()
                            return not (EWC.copySources and EWC.copySources[id])
                        end,
                        func = function()
                            local sourceID = EWC.copySources and EWC.copySources[id]
                            if sourceID and EWC:CopyWidgetSettings(sourceID, id) then
                                E:Print("Enhanced Widget Control: settings copied.")
                            end
                        end,
                    },
                },
            },
            export = {
                order = 95,
                type = "execute",
                name = "Export this widget",
                desc = "Place this widget's settings in Import / Export > Widgets.",
                func = function()
                    EWC.transferWidgetID = id
                    EWC.widgetTransferText = EWC:CreateExport("widget", id) or ""
                    E.Libs.AceConfigRegistry:NotifyChange("ElvUI")
                    E:Print("Enhanced Widget Control: widget export created.")
                end,
            },
            reset = {
                order = 100,
                type = "execute",
                name = "Reset this widget",
                confirm = true,
                confirmText = "Reset this widget and stop customizing it?",
                func = function()
                    EWC.selectedWidgetID = id
                    EWC:ResetSelected()
                end,
            },
            ignore = {
                order = 101,
                type = "execute",
                name = "Ignore and remove this widget",
                desc = "Remove it from the list and prevent automatic detection until ignored widgets are restored.",
                confirm = true,
                confirmText = "Remove and ignore this widget?",
                func = function() EWC:IgnoreWidget(id) end,
            },
        },
    }
end

function EWC:RefreshWidgetOptions()
    if not self.widgetOptionsArgs then
        return
    end

    for key in pairs(self.widgetOptionsArgs) do
        self.widgetOptionsArgs[key] = nil
    end

    local found = false
    local ids = {}
    local categories = {}

    self.widgetOptionsArgs.controls = {
        order = 0,
        type = "group",
        name = "List Controls",
        args = {
            search = {
                order = 1,
                type = "input",
                name = "Search",
                get = function() return self.widgetSearch or "" end,
                set = function(_, value)
                    self.widgetSearch = value
                    self:RefreshWidgetOptions()
                end,
            },
            favorites = {
                order = 2,
                type = "toggle",
                name = "Show only favorites",
                get = function() return self.showOnlyFavorites end,
                set = function(_, value)
                    self.showOnlyFavorites = value
                    self:RefreshWidgetOptions()
                end,
            },
            customized = {
                order = 3,
                type = "toggle",
                name = "Show only customized",
                get = function() return self.showOnlyEnabled end,
                set = function(_, value)
                    self.showOnlyEnabled = value
                    self:RefreshWidgetOptions()
                end,
            },
        },
    }

    for id in pairs(self.detected) do
        ids[id] = true
    end

    for id in pairs(self:GetDatabase().widgets or {}) do
        ids[id] = true
    end

    for id in pairs(ids) do
        local settings = self:GetWidgetSettings(id, true)
        local name = settings.customName or self.detected[id] or ("Saved widget " .. id)
        local search = (self.widgetSearch or ""):lower()
        local matches = search == ""
            or tostring(id):find(search, 1, true)
            or tostring(name):lower():find(search, 1, true)

        if matches
            and (not self.showOnlyFavorites or settings.favorite)
            and (not self.showOnlyEnabled or settings.overrideGlobal) then
            found = true
            local category = self.metadata[id] and self.metadata[id].category
                or "Saved / Unknown"
            categories[category] = categories[category] or {}
            categories[category]["widget_" .. tostring(id)] = CreateWidgetOptions(id)
        end
    end

    local categoryOrder = 10
    for category, args in pairs(categories) do
        self.widgetOptionsArgs["category_" .. category:gsub("%W", "_")] = {
            order = categoryOrder,
            type = "group",
            name = category,
            childGroups = "tree",
            args = args,
        }
        categoryOrder = categoryOrder + 1
    end

    if not found then
        self.widgetOptionsArgs.none = {
            order = 1,
            type = "description",
            name = "No widgets have been detected yet. Make the widget visible in game, "
                .. "then return to General and press Scan now.",
        }
    end

    if E.Libs.AceConfigRegistry then
        E.Libs.AceConfigRegistry:NotifyChange("ElvUI")
    end
end

function EWC:AddOptions()
    local widgetArgs = {}
    self.widgetOptionsArgs = widgetArgs

    E.Options.args.enhancedWidgetControl = {
        order = 55,
        type = "group",
        name = "Enhanced Widget Control",
        childGroups = "tab",
        args = {
            general = {
                order = 1,
                type = "group",
                name = "General",
                args = {
                    information = {
                        order = 1,
                        type = "description",
                        name = "Enhanced Widget Control changes Blizzard widget bars used on "
                            .. "nameplates and other widget containers.\n\n"
                            .. "Open |cff00c0faSelected Widgets|r to choose directly from every "
                            .. "widget that has been detected.",
                    },
                    status = {
                        order = 1.5,
                        type = "description",
                        name = function()
                            local detected, saved, ignored = 0, 0, 0
                            for _ in pairs(self.detected) do detected = detected + 1 end
                            for _ in pairs(self:GetDatabase().widgets or {}) do saved = saved + 1 end
                            for _ in pairs(self:GetDatabase().ignored or {}) do ignored = ignored + 1 end
                            return ("|cff00c0faStatus:|r %d detected, %d saved, %d ignored.")
                                :format(detected, saved, ignored)
                        end,
                    },
                    enabled = {
                        order = 2,
                        type = "toggle",
                        name = "Enable module",
                        get = function() return self:GetDatabase().enabled end,
                        set = function(_, value)
                            self:GetDatabase().enabled = value
                            self:ApplyAll()
                        end,
                    },
                    scan = {
                        order = 3,
                        type = "execute",
                        name = "Scan now",
                        func = function()
                            self:ScanWidgets()
                            self:RefreshWidgetOptions()
                            E:Print("Enhanced Widget Control: scan complete.")
                        end,
                    },
                    resetAll = {
                        order = 4,
                        type = "execute",
                        name = "Reset all widgets",
                        confirm = true,
                        confirmText = "Reset and disable customization for every widget?",
                        func = function() self:ResetAll() end,
                    },
                    resetEverything = {
                        order = 5,
                        type = "execute",
                        name = "Reset Everything",
                        desc = "Reset global settings, all widget settings, ignored widgets and anchors, then reload the UI.",
                        confirm = true,
                        confirmText = "Completely reset Enhanced Widget Control and reload the UI?",
                        func = function() self:ResetEverything() end,
                    },
                    cleanup = {
                        order = 6,
                        type = "execute",
                        name = "Remove unused saved widgets",
                        desc = "Remove saved widgets that have not been detected during this login session.",
                        confirm = true,
                        confirmText = "Remove saved widgets not detected during this session?",
                        func = function()
                            local removed = self:CleanupUnused()
                            E:Print("Enhanced Widget Control: removed "
                                .. tostring(removed) .. " unused widget(s).")
                        end,
                    },
                    clearIgnored = {
                        order = 7,
                        type = "execute",
                        name = "Restore ignored widgets",
                        desc = "Allow ignored widgets to be automatically detected again.",
                        func = function()
                            self:ClearIgnored()
                            E:Print("Enhanced Widget Control: ignored widgets restored.")
                        end,
                    },
                    testMode = {
                        order = 8,
                        type = "group",
                        name = "Test mode",
                        inline = true,
                        args = {
                            enabled = {
                                order = 1,
                                type = "execute",
                                name = function()
                                    return self.testMode
                                        and "Bring Widget Gallery to Front"
                                        or "Open Widget Gallery"
                                end,
                                desc = "Show four live examples of common Blizzard widget bars using your current global settings.",
                                func = function()
                                    self:SetTestMode(true)
                                    E.Libs.AceConfigRegistry:NotifyChange("ElvUI")
                                end,
                            },
                            refresh = {
                                order = 2,
                                type = "execute",
                                name = "Refresh preview",
                                disabled = function() return not self.testMode end,
                                func = function() self:UpdatePreview() end,
                            },
                        },
                    },
                    presets = {
                        order = 9,
                        type = "group",
                        name = "Presets",
                        inline = true,
                        args = {
                            profileInfo = {
                                order = 0,
                                type = "description",
                                name = function()
                                    local profile = E.data and E.data.GetCurrentProfile
                                        and E.data:GetCurrentProfile() or "Unknown"
                                    return "Current ElvUI profile: |cff00c0fa"
                                        .. tostring(profile)
                                        .. "|r\nGlobal changes are saved automatically to this profile."
                                end,
                            },
                            preset = {
                                order = 1,
                                type = "select",
                                name = "Preset",
                                values = function() return self:GetPresetValues() end,
                                get = function() return self.selectedPreset end,
                                set = function(_, value) self.selectedPreset = value end,
                            },
                            apply = {
                                order = 2,
                                type = "execute",
                                name = "Apply preset globally",
                                disabled = function() return not self.selectedPreset end,
                                func = function()
                                    self:ApplyPreset(self.selectedPreset)
                                    E:Print("Enhanced Widget Control: preset applied.")
                                end,
                            },
                            presetName = {
                                order = 3,
                                type = "input",
                                name = "New preset name",
                                get = function() return self.newPresetName or "" end,
                                set = function(_, value) self.newPresetName = value end,
                            },
                            save = {
                                order = 4,
                                type = "execute",
                                name = "Save current globals",
                                disabled = function()
                                    return not self.newPresetName or self.newPresetName == ""
                                end,
                                func = function()
                                    if self:SavePreset(self.newPresetName) then
                                        self.selectedPreset = "custom:" .. self.newPresetName
                                        self.newPresetName = ""
                                        E.Libs.AceConfigRegistry:NotifyChange("ElvUI")
                                        E:Print("Enhanced Widget Control: preset saved.")
                                    end
                                end,
                            },
                            update = {
                                order = 4.5,
                                type = "execute",
                                name = "Update selected custom preset",
                                desc = "Replace the selected personal preset with the current global settings.",
                                confirm = true,
                                disabled = function()
                                    return not self.selectedPreset
                                        or not self.selectedPreset:match("^custom:")
                                end,
                                func = function()
                                    if self:UpdatePreset(self.selectedPreset) then
                                        E:Print("Enhanced Widget Control: preset updated.")
                                    end
                                end,
                            },
                            delete = {
                                order = 5,
                                type = "execute",
                                name = "Delete selected custom preset",
                                confirm = true,
                                disabled = function()
                                    return not self.selectedPreset
                                        or not self.selectedPreset:match("^custom:")
                                end,
                                func = function()
                                    if self:DeletePreset(self.selectedPreset) then
                                        self.selectedPreset = nil
                                        E.Libs.AceConfigRegistry:NotifyChange("ElvUI")
                                        E:Print("Enhanced Widget Control: preset deleted.")
                                    end
                                end,
                            },
                        },
                    },
                    globalAppearance = {
                        order = 10,
                        type = "group",
                        name = "Global appearance",
                        inline = true,
                        args = {
                            barWidth = {
                                order = 1,
                                type = "range",
                                name = "Bar width",
                                min = 20, max = 1000, step = 1,
                                get = function() return GlobalGet("barWidth") end,
                                set = function(_, value) GlobalSet("barWidth", value) end,
                            },
                            barHeight = {
                                order = 2,
                                type = "range",
                                name = "Bar height",
                                min = 2, max = 200, step = 1,
                                get = function() return GlobalGet("barHeight") end,
                                set = function(_, value) GlobalSet("barHeight", value) end,
                            },
                            barScale = {
                                order = 3,
                                type = "range",
                                name = "Bar scale",
                                min = 0.1, max = 5, step = 0.01,
                                isPercent = true,
                                get = function() return GlobalGet("barScale") end,
                                set = function(_, value) GlobalSet("barScale", value) end,
                            },
                            widgetScale = {
                                order = 4,
                                type = "range",
                                name = "Whole widget scale",
                                min = 0.1, max = 5, step = 0.01,
                                isPercent = true,
                                get = function() return GlobalGet("widgetScale") end,
                                set = function(_, value) GlobalSet("widgetScale", value) end,
                            },
                            font = {
                                order = 5,
                                type = "select",
                                dialogControl = "LSM30_Font",
                                name = "Font",
                                values = AceGUIWidgetLSMlists.font,
                                get = function() return GlobalGet("font") end,
                                set = function(_, value) GlobalSet("font", value) end,
                            },
                            fontSize = {
                                order = 6,
                                type = "range",
                                name = "Font size",
                                min = 6, max = 72, step = 1,
                                get = function() return GlobalGet("fontSize") end,
                                set = function(_, value) GlobalSet("fontSize", value) end,
                            },
                            fontOutline = {
                                order = 7,
                                type = "select",
                                name = "Font outline",
                                values = OUTLINES,
                                get = function() return GlobalGet("fontOutline") or "DEFAULT" end,
                                set = function(_, value) GlobalSet("fontOutline", value) end,
                            },
                            useTextColor = {
                                order = 8,
                                type = "toggle",
                                name = "Use custom text color",
                                get = function() return GlobalGet("useTextColor") end,
                                set = function(_, value) GlobalSet("useTextColor", value) end,
                            },
                            textColor = {
                                order = 9,
                                type = "color",
                                name = "Text color",
                                hasAlpha = true,
                                disabled = function() return not GlobalGet("useTextColor") end,
                                get = function() return GlobalColorGet("textColor") end,
                                set = function(_, r, g, b, a)
                                    GlobalColorSet("textColor", r, g, b, a)
                                end,
                            },
                            barTexture = {
                                order = 10,
                                type = "select",
                                dialogControl = "LSM30_Statusbar",
                                name = "Bar texture",
                                values = BarTextureValues,
                                get = function()
                                    return GlobalGet("barTexture") or "__BLIZZARD"
                                end,
                                set = function(_, value) GlobalSet("barTexture", value) end,
                            },
                            useBarColor = {
                                order = 11,
                                type = "toggle",
                                name = "Use custom bar color",
                                get = function() return GlobalGet("useBarColor") end,
                                set = function(_, value) GlobalSet("useBarColor", value) end,
                            },
                            barColor = {
                                order = 12,
                                type = "color",
                                name = "Bar color",
                                hasAlpha = true,
                                disabled = function() return not GlobalGet("useBarColor") end,
                                get = function() return GlobalColorGet("barColor") end,
                                set = function(_, r, g, b, a)
                                    GlobalColorSet("barColor", r, g, b, a)
                                end,
                            },
                            useBarBackground = {
                                order = 14,
                                type = "toggle",
                                name = "Use custom bar background",
                                get = function() return GlobalGet("useBarBackground") end,
                                set = function(_, value)
                                    GlobalSet("useBarBackground", value)
                                end,
                            },
                            barBackgroundColor = {
                                order = 15,
                                type = "color",
                                name = "Bar background color",
                                hasAlpha = true,
                                disabled = function()
                                    return not GlobalGet("useBarBackground")
                                end,
                                get = function()
                                    return GlobalColorGet("barBackgroundColor")
                                end,
                                set = function(_, r, g, b, a)
                                    GlobalColorSet("barBackgroundColor", r, g, b, a)
                                end,
                            },
                            useBorder = {
                                order = 16,
                                type = "toggle",
                                name = "Use custom border",
                                get = function() return GlobalGet("useBorder") end,
                                set = function(_, value) GlobalSet("useBorder", value) end,
                            },
                            borderColor = {
                                order = 17,
                                type = "color",
                                name = "Border color",
                                hasAlpha = true,
                                disabled = function() return not GlobalGet("useBorder") end,
                                get = function() return GlobalColorGet("borderColor") end,
                                set = function(_, r, g, b, a)
                                    GlobalColorSet("borderColor", r, g, b, a)
                                end,
                            },
                            borderSize = {
                                order = 18,
                                type = "range",
                                name = "Border size",
                                min = 1, max = 8, step = 1,
                                disabled = function() return not GlobalGet("useBorder") end,
                                get = function() return GlobalGet("borderSize") or 1 end,
                                set = function(_, value) GlobalSet("borderSize", value) end,
                            },
                            alpha = {
                                order = 13,
                                type = "range",
                                name = "Widget opacity",
                                min = 0.05, max = 1, step = 0.01,
                                isPercent = true,
                                get = function() return GlobalGet("alpha") or 1 end,
                                set = function(_, value) GlobalSet("alpha", value) end,
                            },
                        },
                    },
                    globalValueText = {
                        order = 15,
                        type = "group",
                        name = "Global value text",
                        inline = true,
                        args = {
                            explanation = {
                                order = 1,
                                type = "description",
                                name = "Applies to a separate counter/value such as |cffffffff28/28|r when a widget exposes one.",
                            },
                            separateValueText = {
                                order = 2,
                                type = "toggle",
                                name = "Style value text separately",
                                desc = "Turning this off restores normal value styling but keeps the configured values.",
                                get = function() return GlobalGet("separateValueText") end,
                                set = function(_, value)
                                    GlobalSet("separateValueText", value)
                                end,
                            },
                            valueFont = {
                                order = 3,
                                type = "select",
                                dialogControl = "LSM30_Font",
                                name = "Value font",
                                values = AceGUIWidgetLSMlists.font,
                                disabled = function() return not GlobalGet("separateValueText") end,
                                get = function() return GlobalGet("valueFont") end,
                                set = function(_, value) GlobalSet("valueFont", value) end,
                            },
                            valueFontSize = {
                                order = 4,
                                type = "range",
                                name = "Value font size",
                                min = 6, max = 72, step = 1,
                                disabled = function() return not GlobalGet("separateValueText") end,
                                get = function() return GlobalGet("valueFontSize") or 12 end,
                                set = function(_, value) GlobalSet("valueFontSize", value) end,
                            },
                            valueFontOutline = {
                                order = 5,
                                type = "select",
                                name = "Value outline",
                                values = OUTLINES,
                                disabled = function() return not GlobalGet("separateValueText") end,
                                get = function()
                                    return GlobalGet("valueFontOutline") or "DEFAULT"
                                end,
                                set = function(_, value)
                                    GlobalSet("valueFontOutline", value)
                                end,
                            },
                            useValueTextColor = {
                                order = 6,
                                type = "toggle",
                                name = "Use custom value color",
                                disabled = function() return not GlobalGet("separateValueText") end,
                                get = function() return GlobalGet("useValueTextColor") end,
                                set = function(_, value)
                                    GlobalSet("useValueTextColor", value)
                                end,
                            },
                            valueTextColor = {
                                order = 7,
                                type = "color",
                                name = "Value color",
                                hasAlpha = true,
                                disabled = function()
                                    return not GlobalGet("separateValueText")
                                        or not GlobalGet("useValueTextColor")
                                end,
                                get = function() return GlobalColorGet("valueTextColor") end,
                                set = function(_, r, g, b, a)
                                    GlobalColorSet("valueTextColor", r, g, b, a)
                                end,
                            },
                            valueTextPositionOverride = {
                                order = 10,
                                type = "toggle",
                                name = "Move value text separately",
                                disabled = function() return not GlobalGet("separateValueText") end,
                                get = function()
                                    return GlobalGet("valueTextPositionOverride")
                                end,
                                set = function(_, value)
                                    GlobalSet("valueTextPositionOverride", value)
                                end,
                            },
                            valueTextAnchor = {
                                order = 11,
                                type = "select",
                                name = "Value anchor",
                                values = ANCHORS,
                                disabled = function()
                                    return not GlobalGet("separateValueText")
                                        or not GlobalGet("valueTextPositionOverride")
                                end,
                                get = function()
                                    return GlobalGet("valueTextAnchor") or "CENTER"
                                end,
                                set = function(_, value)
                                    GlobalSet("valueTextAnchor", value)
                                end,
                            },
                            valueTextRelativeAnchor = {
                                order = 12,
                                type = "select",
                                name = "Bar anchor for value",
                                values = ANCHORS,
                                disabled = function()
                                    return not GlobalGet("separateValueText")
                                        or not GlobalGet("valueTextPositionOverride")
                                end,
                                get = function()
                                    return GlobalGet("valueTextRelativeAnchor") or "CENTER"
                                end,
                                set = function(_, value)
                                    GlobalSet("valueTextRelativeAnchor", value)
                                end,
                            },
                            valueTextXOffset = {
                                order = 13,
                                type = "range",
                                name = "Value X offset",
                                min = -1000, max = 1000, step = 1,
                                disabled = function()
                                    return not GlobalGet("separateValueText")
                                        or not GlobalGet("valueTextPositionOverride")
                                end,
                                get = function() return GlobalGet("valueTextXOffset") or 0 end,
                                set = function(_, value)
                                    GlobalSet("valueTextXOffset", value)
                                end,
                            },
                            valueTextYOffset = {
                                order = 14,
                                type = "range",
                                name = "Value Y offset",
                                min = -1000, max = 1000, step = 1,
                                disabled = function()
                                    return not GlobalGet("separateValueText")
                                        or not GlobalGet("valueTextPositionOverride")
                                end,
                                get = function() return GlobalGet("valueTextYOffset") or 0 end,
                                set = function(_, value)
                                    GlobalSet("valueTextYOffset", value)
                                end,
                            },
                        },
                    },
                    globalPosition = {
                        order = 20,
                        type = "group",
                        name = "Global position and anchors",
                        inline = true,
                        args = {
                            positionOverride = {
                                order = 1,
                                type = "toggle",
                                name = "Move whole widgets",
                                get = function() return GlobalGet("positionOverride") end,
                                set = function(_, value) GlobalSet("positionOverride", value) end,
                            },
                            anchor = {
                                order = 2,
                                type = "select",
                                name = "Widget anchor",
                                values = ANCHORS,
                                disabled = function() return not GlobalGet("positionOverride") end,
                                get = function() return GlobalGet("anchor") or "CENTER" end,
                                set = function(_, value) GlobalSet("anchor", value) end,
                            },
                            xOffset = {
                                order = 3,
                                type = "range",
                                name = "Widget X offset",
                                min = -1000, max = 1000, step = 1,
                                disabled = function() return not GlobalGet("positionOverride") end,
                                get = function() return GlobalGet("xOffset") or 0 end,
                                set = function(_, value) GlobalSet("xOffset", value) end,
                            },
                            yOffset = {
                                order = 4,
                                type = "range",
                                name = "Widget Y offset",
                                min = -1000, max = 1000, step = 1,
                                disabled = function() return not GlobalGet("positionOverride") end,
                                get = function() return GlobalGet("yOffset") or 0 end,
                                set = function(_, value) GlobalSet("yOffset", value) end,
                            },
                            barPositionOverride = {
                                order = 10,
                                type = "toggle",
                                name = "Move bars separately",
                                get = function() return GlobalGet("barPositionOverride") end,
                                set = function(_, value) GlobalSet("barPositionOverride", value) end,
                            },
                            barAnchor = {
                                order = 11,
                                type = "select",
                                name = "Bar anchor",
                                values = ANCHORS,
                                disabled = function() return not GlobalGet("barPositionOverride") end,
                                get = function() return GlobalGet("barAnchor") or "CENTER" end,
                                set = function(_, value) GlobalSet("barAnchor", value) end,
                            },
                            barRelativeAnchor = {
                                order = 12,
                                type = "select",
                                name = "Widget anchor for bar",
                                values = ANCHORS,
                                disabled = function() return not GlobalGet("barPositionOverride") end,
                                get = function() return GlobalGet("barRelativeAnchor") or "CENTER" end,
                                set = function(_, value) GlobalSet("barRelativeAnchor", value) end,
                            },
                            barXOffset = {
                                order = 13,
                                type = "range",
                                name = "Bar X offset",
                                min = -1000, max = 1000, step = 1,
                                disabled = function() return not GlobalGet("barPositionOverride") end,
                                get = function() return GlobalGet("barXOffset") or 0 end,
                                set = function(_, value) GlobalSet("barXOffset", value) end,
                            },
                            barYOffset = {
                                order = 14,
                                type = "range",
                                name = "Bar Y offset",
                                min = -1000, max = 1000, step = 1,
                                disabled = function() return not GlobalGet("barPositionOverride") end,
                                get = function() return GlobalGet("barYOffset") or 0 end,
                                set = function(_, value) GlobalSet("barYOffset", value) end,
                            },
                            textPositionOverride = {
                                order = 20,
                                type = "toggle",
                                name = "Move text separately",
                                get = function() return GlobalGet("textPositionOverride") end,
                                set = function(_, value) GlobalSet("textPositionOverride", value) end,
                            },
                            textAnchor = {
                                order = 21,
                                type = "select",
                                name = "Text anchor",
                                values = ANCHORS,
                                disabled = function() return not GlobalGet("textPositionOverride") end,
                                get = function() return GlobalGet("textAnchor") or "CENTER" end,
                                set = function(_, value) GlobalSet("textAnchor", value) end,
                            },
                            textRelativeAnchor = {
                                order = 22,
                                type = "select",
                                name = "Bar anchor for text",
                                values = ANCHORS,
                                disabled = function() return not GlobalGet("textPositionOverride") end,
                                get = function() return GlobalGet("textRelativeAnchor") or "CENTER" end,
                                set = function(_, value) GlobalSet("textRelativeAnchor", value) end,
                            },
                            textXOffset = {
                                order = 23,
                                type = "range",
                                name = "Text X offset",
                                min = -1000, max = 1000, step = 1,
                                disabled = function() return not GlobalGet("textPositionOverride") end,
                                get = function() return GlobalGet("textXOffset") or 0 end,
                                set = function(_, value) GlobalSet("textXOffset", value) end,
                            },
                            textYOffset = {
                                order = 24,
                                type = "range",
                                name = "Text Y offset",
                                min = -1000, max = 1000, step = 1,
                                disabled = function() return not GlobalGet("textPositionOverride") end,
                                get = function() return GlobalGet("textYOffset") or 0 end,
                                set = function(_, value) GlobalSet("textYOffset", value) end,
                            },
                        },
                    },
                },
            },
            selectedWidgets = {
                order = 2,
                type = "group",
                name = "Selected Widgets",
                childGroups = "tree",
                args = widgetArgs,
            },
        },
    }

    local rootArgs = E.Options.args.enhancedWidgetControl.args
    local general = rootArgs.general
    local generalArgs = general.args

    local function TransferStatus(payload, errorMessage)
        if errorMessage then
            return "|cffff3333" .. errorMessage .. "|r"
        elseif payload then
            return "|cff33ff99Valid import:|r "
                .. tostring(payload.kind)
                .. " - " .. tostring(payload.name or "Unnamed")
        end
        return "Paste an EWC string and validate it before importing."
    end

    rootArgs.transfer = {
        order = 3,
        type = "group",
        name = "Import / Export",
        childGroups = "tree",
        args = {
            global = {
                order = 1,
                type = "group",
                name = "Global Settings",
                args = {
                    info = {
                        order = 1,
                        type = "description",
                        name = "Share or replace the complete global style. A backup is created automatically before importing.",
                    },
                    export = {
                        order = 2,
                        type = "execute",
                        name = "Export Global Settings",
                        func = function()
                            self.globalTransferText = self:CreateExport("global") or ""
                        end,
                    },
                    text = {
                        order = 3,
                        type = "input",
                        name = "Global export / import string",
                        width = "full",
                        multiline = 10,
                        get = function() return self.globalTransferText or "" end,
                        set = function(_, value)
                            self.globalTransferText = value
                            self.pendingGlobalImport = nil
                            self.globalImportError = nil
                        end,
                    },
                    validate = {
                        order = 4,
                        type = "execute",
                        name = "Validate Global Import",
                        func = function()
                            self.pendingGlobalImport, self.globalImportError =
                                self:ReadImport(self.globalTransferText)
                            E.Libs.AceConfigRegistry:NotifyChange("ElvUI")
                        end,
                    },
                    status = {
                        order = 5,
                        type = "description",
                        name = function()
                            return TransferStatus(
                                self.pendingGlobalImport, self.globalImportError
                            )
                        end,
                    },
                    apply = {
                        order = 6,
                        type = "execute",
                        name = "Import to Global Settings",
                        confirm = true,
                        disabled = function() return not self.pendingGlobalImport end,
                        func = function()
                            if self:ApplyImport(self.pendingGlobalImport, "global") then
                                self.pendingGlobalImport = nil
                                E:Print("Enhanced Widget Control: global settings imported.")
                            end
                        end,
                    },
                },
            },
            presets = {
                order = 2,
                type = "group",
                name = "Presets",
                args = {
                    preset = {
                        order = 1,
                        type = "select",
                        name = "Preset to export",
                        values = function() return self:GetPresetValues() end,
                        get = function() return self.selectedPreset end,
                        set = function(_, value) self.selectedPreset = value end,
                    },
                    export = {
                        order = 2,
                        type = "execute",
                        name = "Export Selected Preset",
                        disabled = function() return not self.selectedPreset end,
                        func = function()
                            self.presetTransferText = self:CreateExport(
                                "preset", self.selectedPreset
                            ) or ""
                        end,
                    },
                    text = {
                        order = 3,
                        type = "input",
                        name = "Preset export / import string",
                        width = "full",
                        multiline = 10,
                        get = function() return self.presetTransferText or "" end,
                        set = function(_, value)
                            self.presetTransferText = value
                            self.pendingPresetImport = nil
                            self.presetImportError = nil
                        end,
                    },
                    validate = {
                        order = 4,
                        type = "execute",
                        name = "Validate Preset Import",
                        func = function()
                            self.pendingPresetImport, self.presetImportError =
                                self:ReadImport(self.presetTransferText)
                            E.Libs.AceConfigRegistry:NotifyChange("ElvUI")
                        end,
                    },
                    status = {
                        order = 5,
                        type = "description",
                        name = function()
                            return TransferStatus(
                                self.pendingPresetImport, self.presetImportError
                            )
                        end,
                    },
                    target = {
                        order = 6,
                        type = "input",
                        name = "New personal preset name",
                        get = function() return self.presetImportName or "" end,
                        set = function(_, value) self.presetImportName = value end,
                    },
                    apply = {
                        order = 7,
                        type = "execute",
                        name = "Import as Personal Preset",
                        confirm = true,
                        disabled = function()
                            return not self.pendingPresetImport
                                or not self.presetImportName
                                or self.presetImportName == ""
                        end,
                        func = function()
                            if self:ApplyImport(
                                self.pendingPresetImport,
                                "preset",
                                self.presetImportName
                            ) then
                                self.selectedPreset = "custom:" .. self.presetImportName
                                self.pendingPresetImport = nil
                                E:Print("Enhanced Widget Control: preset imported.")
                            end
                        end,
                    },
                },
            },
            widgets = {
                order = 3,
                type = "group",
                name = "Widgets",
                args = {
                    widgetID = {
                        order = 1,
                        type = "input",
                        name = "Widget ID",
                        get = function()
                            return self.transferWidgetID
                                and tostring(self.transferWidgetID) or ""
                        end,
                        set = function(_, value)
                            self.transferWidgetID = tonumber(value)
                        end,
                    },
                    export = {
                        order = 2,
                        type = "execute",
                        name = "Export Widget Settings",
                        disabled = function()
                            return not self.transferWidgetID
                                or not self:GetWidgetSettings(
                                    self.transferWidgetID, false
                                )
                        end,
                        func = function()
                            self.widgetTransferText = self:CreateExport(
                                "widget", self.transferWidgetID
                            ) or ""
                        end,
                    },
                    text = {
                        order = 3,
                        type = "input",
                        name = "Widget export / import string",
                        width = "full",
                        multiline = 10,
                        get = function() return self.widgetTransferText or "" end,
                        set = function(_, value)
                            self.widgetTransferText = value
                            self.pendingWidgetImport = nil
                            self.widgetImportError = nil
                        end,
                    },
                    validate = {
                        order = 4,
                        type = "execute",
                        name = "Validate Widget Import",
                        func = function()
                            self.pendingWidgetImport, self.widgetImportError =
                                self:ReadImport(self.widgetTransferText)
                            E.Libs.AceConfigRegistry:NotifyChange("ElvUI")
                        end,
                    },
                    status = {
                        order = 5,
                        type = "description",
                        name = function()
                            return TransferStatus(
                                self.pendingWidgetImport, self.widgetImportError
                            )
                        end,
                    },
                    apply = {
                        order = 6,
                        type = "execute",
                        name = "Import to Widget ID",
                        confirm = true,
                        disabled = function()
                            return not self.pendingWidgetImport
                                or not self.transferWidgetID
                        end,
                        func = function()
                            if self:ApplyImport(
                                self.pendingWidgetImport,
                                "widget",
                                self.transferWidgetID
                            ) then
                                self.pendingWidgetImport = nil
                                E:Print("Enhanced Widget Control: widget imported.")
                            end
                        end,
                    },
                },
            },
            backups = {
                order = 4,
                type = "group",
                name = "Backups",
                args = {
                    info = {
                        order = 1,
                        type = "description",
                        name = "EWC keeps the five latest automatic pre-import backups.",
                    },
                    restore = {
                        order = 2,
                        type = "execute",
                        name = "Restore Latest Import Backup",
                        confirm = true,
                        disabled = function()
                            return not (self:GetDatabase().importBackups
                                and self:GetDatabase().importBackups[1])
                        end,
                        func = function()
                            if self:RestoreLatestImportBackup() then
                                E:Print(
                                    "Enhanced Widget Control: latest backup restored."
                                )
                            end
                        end,
                    },
                },
            },
        },
    }
    general.childGroups = "tree"
    generalArgs.overview = {
        order = 1,
        type = "group",
        name = "Overview",
        args = {
            information = generalArgs.information,
            status = generalArgs.status,
            enabled = generalArgs.enabled,
        },
    }
    generalArgs.information = nil
    generalArgs.status = nil
    generalArgs.enabled = nil

    generalArgs.testMode.order = 2
    generalArgs.testMode.name = "Preview"
    generalArgs.testMode.inline = false

    generalArgs.presets.order = 3
    generalArgs.presets.inline = false

    generalArgs.globalAppearance.order = 4
    generalArgs.globalAppearance.name = "Global Style"
    generalArgs.globalAppearance.inline = false

    generalArgs.globalValueText.order = 5
    generalArgs.globalValueText.name = "Value Text"
    generalArgs.globalValueText.inline = false

    generalArgs.globalPosition.order = 6
    generalArgs.globalPosition.name = "Position"
    generalArgs.globalPosition.inline = false

    generalArgs.maintenance = {
        order = 7,
        type = "group",
        name = "Maintenance",
        args = {
            scan = generalArgs.scan,
            cleanup = generalArgs.cleanup,
            clearIgnored = generalArgs.clearIgnored,
            resetAll = generalArgs.resetAll,
            resetEverything = generalArgs.resetEverything,
        },
    }
    generalArgs.scan = nil
    generalArgs.cleanup = nil
    generalArgs.clearIgnored = nil
    generalArgs.resetAll = nil
    generalArgs.resetEverything = nil

    self:RefreshWidgetOptions()
end
