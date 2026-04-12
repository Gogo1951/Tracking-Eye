# Tracking Eye — Architecture

Developer reference for the internal design of Tracking Eye. Start here if you're adding a feature, fixing a bug, or trying to understand how the pieces fit together.

## File Structure & Load Order

Files load in the order listed in `TrackingEye.toc`. Order matters because later files depend on the shared namespace (`te`) being populated by earlier ones.

```
TrackingEye/
  TrackingEye.toc          # TOC manifest — interface versions, metadata, load order
  Data.lua                 # Constants, spell IDs, zone tables, color palette
  Locales/
    enUS.lua               # Source-of-truth locale (all keys defined here)
    deDE.lua … zhTW.lua    # Translations (fall back to enUS)
  Core.lua                 # State, utility functions, event router, icon management
  Farm-Mode.lua            # Farm cycle logic, spell casting, ticker management
  Tracking-Menu.lua        # LibUIDropDownMenu-based spell picker
  Minimap-Button.lua       # LibDBIcon minimap button, free-placement frame, tooltip
  Options.lua              # AceConfig-3.0 options panel, slash commands
  Includes/                # Bundled libraries (managed by pkgmeta externals)
```

## Shared Namespace

Every file receives `(addonName, te)` via the `...` vararg. The `te` table is the shared namespace — all public functions, constants, and state live on it. There are no global functions; everything hangs off `te`.

## Saved Variables

Two saved variable scopes, declared in the TOC:

**`TrackingEyeDB`** (per-character) holds user preferences that should differ between characters: `autoTracking`, `farmingMode`, `farmInterval`, `farmCycleSpells`, `selectedSpellId`, `lastIcon`.

**`TrackingEyeGlobalDB`** (account-wide) holds preferences shared across characters: `minimap` (LibDBIcon position data), `freePlacement`, `freeIconScale`, `freeIconShape`, `freePos`.

Both are initialized with defaults in the `ADDON_LOADED` handler in Core.lua. Missing keys are back-filled with defaults so new options don't require migration logic.

## Event Flow

Core.lua registers a single event frame that routes all events. The flow from login to steady-state:

```
ADDON_LOADED
  → Initialize saved variables with defaults
  → Create free-placement frame
  → Update icon

PLAYER_LOGIN
  → InitMinimap()        — register LDB object, LibDBIcon
  → InitFarmMode()       — start the farm ticker (C_Timer.NewTicker)
  → InitOptions()        — register AceConfig, hook options panel show/hide
  → Update icon

Steady-state events:
  UNIT_SPELLCAST_SUCCEEDED  → Track when player casts a tracking spell
  MINIMAP_UPDATE_TRACKING   → Sync icon with minimap tracking state
  ZONE_CHANGED_NEW_AREA     → Update icon
  UPDATE_SHAPESHIFT_FORM    → Delayed recast of persistent tracking (1.5s for GCD)
  SPELLS_CHANGED            → Invalidate farm cache, update placement visibility
  PLAYER_ENTERING_WORLD     → Invalidate farm cache, update placement
  PLAYER_UNGHOST            → Delayed recast of persistent tracking (1.5s post-rez)
```

## Core Systems

### Persistent Tracking

When the player selects a spell from the tracking menu, it's saved to `TrackingEyeDB.selectedSpellId`. After death (`PLAYER_UNGHOST`) or shapeshift changes (`UPDATE_SHAPESHIFT_FORM`), the addon waits 1.5 seconds (for GCD) then recasts if the current tracking texture doesn't match the saved spell.

Key safety guard: `TryRecastPersistent()` bails out if `GetTrackingTexture()` returns nil. During the Classic login event storm, the tracking API is unresponsive for 10+ seconds. Removing this nil check causes the login-recast bug. The comment in Core.lua explains this in detail — read it before touching this code path.

### Farm Mode

Farm Mode runs on a `C_Timer.NewTicker` (default 3.5 second interval). Each tick calls `te.RunFarmLogic()`, which follows this decision chain:

1. Bail if options panel is open (`te.optionsOpen`)
2. Bail if Farm Mode is disabled
3. Bail if in a restricted zone (capital city or battleground)
4. Check player state — mounted or in travel/flight/aquatic form?
5. If player just left farm form, restore persistent tracking
6. If not in farm form or can't cast, bail
7. Build/use cached spell cycle list, advance index, cast next spell

The cycle cache (`cachedCycle`) is a sorted array of enabled spell IDs. It's invalidated on `SPELLS_CHANGED`, `PLAYER_ENTERING_WORLD`, or when the user changes farm ability toggles in options. Druid Track Humanoids is excluded from the farm cycle (it requires Cat Form, which conflicts with travel forms).

### Zone Restrictions

`te.IsRestrictedZone()` in Core.lua uses `C_Map.GetBestMapForUnit("player")` to get the current uiMapId, then checks it against two hash tables in Data.lua:

- `te.CAPITAL_CITIES` — 10 cities through Wrath (Stormwind, Ironforge, Darnassus, Undercity, Orgrimmar, Thunder Bluff, Silvermoon, Exodar, Shattrath, Dalaran)
- `te.BATTLEGROUNDS` — 6 BGs through Wrath (AV, WSG, AB, EotS, SotA, IoC)

If `C_Map` returns nil (e.g., during loading screens), the function returns `false` as a safe default.

### Icon Management

`te.UpdateIcon()` resolves the current display icon through a priority chain: last cast spell texture > active tracking texture > saved last icon > default map icon. It updates both the LDB object (minimap button) and the free-placement frame, then refreshes the tooltip if visible.

### Tracking Menu

The tracking menu uses LibUIDropDownMenu to build a list of known tracking spells, sorted alphabetically. Druid Track Humanoids only appears when the player is in Cat Form. Selecting a spell sets the persistent tracking ability and casts it immediately.

## Libraries

All libraries are bundled in `Includes/` and fetched via pkgmeta externals during the release build:

| Library | Purpose |
|---|---|
| LibStub | Library versioning |
| CallbackHandler-1.0 | Event callback system (dependency of LDB/LDBIcon) |
| LibDataBroker-1.1 | Data object for minimap button |
| LibDBIcon-1.0 | Minimap button rendering and positioning |
| LibUIDropDownMenu | Drop-down menu framework (replaces Blizzard's tainted version) |
| AceLocale-3.0 | Localization framework |
| AceGUI-3.0 | Widget toolkit (dependency of AceConfigDialog) |
| AceConfigRegistry-3.0 | Options table registration |
| AceConfigDialog-3.0 | Renders options as Blizzard Interface Options panel |

## Adding a New Feature

1. Create a new `.lua` file following the existing pattern: `local _, te = ...` at the top, section headers with dashed comment blocks.
2. Add it to the TOC in the correct position (after Core.lua, before Options.lua if it needs to be initialized before the options panel loads).
3. If it needs initialization at login, add a `te.InitFeatureName()` function and call it from the `PLAYER_LOGIN` handler in Core.lua.
4. If it needs new saved variable keys, add defaults in the `ADDON_LOADED` handler in Core.lua.
5. If it needs localized strings, add keys to `Locales/enUS.lua` first (source of truth), then other locale files.

## Adding a New Zone Restriction

Add the uiMapId to `te.CAPITAL_CITIES` or `te.BATTLEGROUNDS` in Data.lua. Use the Questie zone database or `C_Map.GetBestMapForUnit("player")` in-game with `/dump` to find the correct ID. No other code changes needed — `te.IsRestrictedZone()` checks both tables automatically.
