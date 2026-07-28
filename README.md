# Enhanced Widget Control

Enhanced Widget Control (EWC) is an ElvUI module for styling Blizzard
status-bar widgets, including widgets attached to nameplates and other
Blizzard widget containers.

## Requirements

- World of Warcraft Retail
- ElvUI 15.18 or newer

EWC includes its own default font and status-bar texture. No additional
SharedMedia or ElvUI plugin is required.

## Features

- ElvUI-integrated configuration
- Automatic widget detection
- Global styling used by default
- Optional per-widget overrides
- Bar width, height, scale, texture, color and opacity
- Original Blizzard colors when custom bar color is disabled
- Font, size, outline and optional text color
- Separately styled value text
- Widget, bar and text anchors with X/Y offsets
- Background and border styling
- Widget gallery with a draggable 1:1 preview
- Built-in and personal presets
- Copy settings between detected widgets
- Global, preset and widget import/export
- Automatic pre-import backups
- Search, favorites, custom names and widget categories
- Cleanup and ignore tools for unused widgets

## Installation

1. Install and enable ElvUI.
2. Copy the `EnhancedWidgetControl` folder into:
   `World of Warcraft/_retail_/Interface/AddOns/`
3. Restart World of Warcraft or reload the UI.
4. Open ElvUI settings.
5. Select **Enhanced Widget Control**.

If ElvUI is missing or older than the supported version, EWC disables
itself and prints a clear message in chat.

## Basic setup

1. Open **General > Presets**.
2. Select **EWC Default** or another built-in preset.
3. Press **Apply preset globally**.
4. Open **General > Preview** to inspect the result.
5. Use **Selected Widgets** only when a specific widget should look
   different from the global style.

Global settings are stored in the active ElvUI profile.

## Selected widgets

Widgets are added to the list when Blizzard creates and displays them.
The list is organized by detected container and can be searched or
filtered.

Enable **Override Global Settings** on a widget before changing its
individual appearance. Disabling the override returns the widget to the
global style without deleting its saved override values.

## Import and export

The **Import / Export** tab has separate pages for:

- Global settings
- Presets
- Widgets
- Backups

Import strings are validated before use. EWC creates an automatic backup
before applying an import and keeps the five latest backups.

Only import strings from sources you trust and review the displayed import
type before applying it.

## Known limitations

- A widget must appear in the game before EWC can detect its ID.
- Only supported Blizzard status-bar widget layouts can be styled.
- Blizzard may recreate widget frames at any time; EWC reapplies settings
  when those widgets are detected again.
- Position changes requested during combat are delayed until combat ends
  to respect Blizzard's protected-frame restrictions.
- Blizzard controls the original color of a live widget when custom bar
  color is disabled. Neutral colors shown in the gallery are illustrative.

## Troubleshooting

If a widget does not appear:

1. Make the widget visible in game.
2. Open **General > Maintenance**.
3. Press **Scan now**.

If the configuration behaves unexpectedly:

1. Test with only ElvUI, ElvUI libraries/options and EWC enabled.
2. Create a temporary clean ElvUI profile.
3. Reload the UI.
4. Check the in-game error report for the first EWC-related error.

Use **Reset Everything** only after exporting important presets or making
a backup.

## Included media

EWC includes the Play Bold font from Google Fonts under the SIL Open Font
License 1.1. The license is included at `Media/OFL-Play.txt`.

`Media/EWCDark.tga` is an original texture created for Enhanced Widget
Control.

## License

Enhanced Widget Control source code and its original EWC Dark texture and
addon icon are released under the MIT License. See `LICENSE`.

The bundled Play Bold font is distributed separately under the SIL Open Font
License 1.1. See `Media/OFL-Play.txt`.

## Support development

Enhanced Widget Control is free and will remain free. If you enjoy the addon and would like to support its continued development, you can buy me a coffee.

[![Buy Me a Coffee](https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png)](https://buymeacoffee.com/th3m0us3)

Support is completely optional and never required to use any addon feature.
