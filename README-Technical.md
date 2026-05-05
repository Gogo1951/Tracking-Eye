# Tracking Eye — Technical Reference

This document combines architecture notes and contribution guidance for developers working on Tracking Eye. For end-user documentation, see [README.md](https://github.com/Gogo1951/Tracking-Eye/blob/main/README.md).

## File Map

```text
TrackingEye/
  TrackingEye.toc          TOC manifest — interface versions, metadata, load order
  Data.lua                 Locale init, constants, spell IDs, defaults, color palette
  Core.lua                 State, utility functions, event router, icon management, welcome message
  Farm-Mode.lua            Farm cycle logic, spell casting, ticker management
  Tracking-Menu.lua        LibUIDropDownMenu-based spell picker
  Minimap-Button.lua       LibDBIcon minimap button, free-placement frame, tooltip
  Options.lua              AceConfig-3.0 options panel, slash commands
  Tracking-Eye.tga         Addon icon
  Locales/
    enUS.lua               Source-of-truth locale (sets the AceLocale `true` default)
    deDE.lua … zhTW.lua    Translations (fall back to enUS via AceLocale)
    esES.lua               Shared-`strings` pattern; also registers esMX
  Includes/                Bundled libraries (managed by .pkgmeta externals)
```

## Architecture

### Event Loop

`Core.lua` registers a single hidden frame (`eventFrame`) and routes every event through one `OnEvent` handler. Initialization happens in two passes:

- `ADDON_LOADED` (when `arg1 == addonName`) backfills missing keys in `TrackingEyeCharDB` and `TrackingEyeGlobalDB`, calls `te.CreateFreeFrame()`, and runs the first `te.UpdateIcon()`.
- `PLAYER_LOGIN` calls `te.InitMinimap()`, `te.InitFarmMode()`, `te.InitOptions()`, then refreshes the icon and prints the welcome message.

Steady-state events:

- `UNIT_SPELLCAST_SUCCEEDED` — if the cast spell ID is in `te.TRACKING_SET`, set it as `te.state.lastCastSpell` and refresh the icon.
- `MINIMAP_UPDATE_TRACKING`, `ZONE_CHANGED_NEW_AREA` — refresh the icon.
- `PLAYER_ENTERING_WORLD`, `SPELLS_CHANGED` — refresh the icon, then call `te.UpdatePlacement()` and `te.InvalidateFarmCache()`.
- `UPDATE_SHAPESHIFT_FORM` — refresh the icon, then `C_Timer.After(1.5, TryRecastPersistent)`.
- `PLAYER_UNGHOST` — `C_Timer.After(1.5, ...)` to recast the saved tracking spell directly (bypasses `TryRecastPersistent`).

### Combat Lockdown

Tracking Eye does not currently defer any work for combat. None of its writes touch protected frames or secure templates: the LDB launcher, the LibDBIcon button, the free-placement Button, and the AceConfig options panel are all unsecure. Spell casts go through `pcall(CastSpellByID, ...)` which fails harmlessly if the cast is blocked. If a future feature needs to drive secure UI, introduce an `InCombatLockdown()`-gated dirty flag and replay deferred work on `PLAYER_REGEN_ENABLED`.

### Persistent Tracking Pipeline

Selection happens in `Tracking-Menu.lua` (`InitMenu` → `info.func`): the menu writes `TrackingEyeCharDB.selectedSpellId`, clears `te.state.wasFarming`, and calls `te.CastTracking(button.value)`. Recasts come from two paths:

- `UPDATE_SHAPESHIFT_FORM` → `TryRecastPersistent()` — uses `GetTrackingTexture()` to check whether a recast is needed.
- `PLAYER_UNGHOST` → inline closure in the event handler — recasts unconditionally because the server clears tracking on resurrection.

`te.CastTracking(spellId)` validates `IsPlayerSpell`, gates Druid Track Humanoids on Cat Form, checks the spell cooldown, then sets `te.state.lastCastSpell` and `pcall`s `CastSpellByID`.

### Farm Cycle Cache

`Farm-Mode.lua` keeps a sorted, IDs-only array `cachedCycle` rebuilt by `BuildCycleCache()`. It pulls every enabled entry from `TrackingEyeCharDB.farmCycleSpells`, drops `te.SPELLS.DRUID_HUMANOIDS`, requires `IsPlayerSpell`, and sorts the result to keep cycle order stable across reloads.

`te.InvalidateFarmCache()` nils the cache. The Core event router invalidates on `SPELLS_CHANGED` and `PLAYER_ENTERING_WORLD`. The Options panel calls it from each Farm Mode Abilities toggle's `set` handler. The cache is lazily rebuilt the next time `te.RunFarmLogic()` runs.

### Icon Resolution

`te.UpdateIcon()` resolves the displayed texture through this priority chain:

1. `te.state.lastCastSpell` → `GetSpellTexture(lastCastSpell)`.
2. `GetTrackingTexture()` — the active in-game tracking buff.
3. `TrackingEyeCharDB.lastIcon` — the most recently observed texture saved across sessions.
4. `te.ICON_DEFAULT` — `Interface\Icons\inv_misc_map_01`.

The resolved texture is written to `te.state.currentIcon`, the LDB object's `icon` field, and the free-placement frame's icon texture. If the resolved texture is anything other than the default, it's also persisted to `TrackingEyeCharDB.lastIcon` so the icon survives reloads.

## Persistent Tracking Deep Dive

The `UPDATE_SHAPESHIFT_FORM` path runs `TryRecastPersistent()` after a 1.5-second delay. The function bails early under any of these conditions:

- `TrackingEyeCharDB` missing, `autoTracking` off, or `selectedSpellId` not set.
- The player is currently in a farm form (mounted, travel, aquatic, flight, swift flight) — Farm Mode owns the cast in that case.
- `IsPlayerSpell(spellId)` is false (e.g., the saved spell was unlearned).
- `GetTrackingTexture()` returns `nil`.

The last bail is load-bearing. During the Classic login and reload event storm the tracking API is unresponsive for ten or more seconds. `GetTrackingTexture()` returns `nil` during that window and we cannot tell whether the saved spell is already active. Casting blindly during this window causes the long-standing login-recast bug — Tracking Eye would re-fire the spell on every login, sometimes interrupting whatever the player was doing. The nil bail is the fix. Do not remove it.

`PLAYER_UNGHOST` does **not** route through `TryRecastPersistent`. After resurrection the server has genuinely cleared the player's tracking buff, so a recast is always needed. The handler skips the texture-comparison logic and casts directly after a 1.5-second delay (giving GCD and any post-resurrection scripts time to settle).

## Farm Mode Deep Dive

`te.RunFarmLogic()` runs on a `C_Timer.NewTicker` (default interval 3.5s, configurable 2–10s via `TrackingEyeCharDB.farmInterval`). The decision chain:

1. Bail if the options panel is visible (`te.optionsOpen`).
2. Bail if `TrackingEyeCharDB.farmingMode` is off.
3. Bail in restricted zones (`te.IsRestrictedZone()` — see *Restricted Zones* below).
4. Read `te.GetPlayerStates()`. If the player just left farm form (`not inForm and te.state.wasFarming`), recast the persistent tracking spell when its texture differs from the current tracking texture.
5. Bail if not in farm form or `te.CanCast()` is false.
6. Lazily rebuild `cachedCycle` if nil. Bail when empty.
7. Single-entry shortcut: when `#cachedCycle == 1`, only cast if the spell isn't already active; otherwise mark `wasFarming = true` and bail.
8. Advance `farmIndex = (farmIndex % #cachedCycle) + 1` and cast `cachedCycle[farmIndex]` when its texture differs from the current tracking texture.

### Why Druid Track Humanoids Is Excluded

`te.SPELLS.DRUID_HUMANOIDS` (5225) requires Cat Form. Cat Form is mutually exclusive with the travel forms that put the player into farm state — Travel, Aquatic, Flight, Swift Flight. Including Druid Track Humanoids in `cachedCycle` would mean trying to cast a Cat-Form-gated spell from a non-Cat-Form context, which always fails. The exclusion lives in two places: `BuildCycleCache()` skips the ID, and `BuildFarmAbilityArgs()` in [Options.lua](Options.lua) hides the toggle from the Farm Mode Abilities list.

### Restricted Zones

`te.IsRestrictedZone()` returns true when `IsInInstance()` is true (any instance — dungeon, raid, battleground, arena) or when `IsResting()` is true (capital cities and inn rest areas). It is intentionally simple: there is no `te.CAPITAL_CITIES` or `te.BATTLEGROUNDS` table and no `C_Map` lookup. The trade-off is breadth — Farm Mode pauses anywhere the resting flag is set, which covers more than just the named cities, and it correctly pauses in non-BG instances too.

## Saved Variables

### TrackingEyeCharDB (per-character)

| Field | Type | Purpose |
| --- | --- | --- |
| `autoTracking` | boolean | Persistent Tracking master toggle. |
| `farmingMode` | boolean | Farm Mode master toggle. |
| `farmInterval` | number | Farm Mode cycle interval in seconds (2–10). |
| `farmCycleSpells` | `[spellId] = bool` | Which tracking abilities Farm Mode rotates through. |
| `selectedSpellId` | number | The Persistent Tracking ability the user picked. |
| `lastIcon` | string | Last non-default texture observed by `te.UpdateIcon()`. |
| `showWelcome` | boolean | Whether to print the login chat message. |

### TrackingEyeGlobalDB (account-wide)

| Field | Type | Purpose |
| --- | --- | --- |
| `minimap` | table | LibDBIcon position payload (`hide`, `minimapPos`, etc.). |
| `freePlacement` | boolean | Free Placement Mode toggle. |
| `freePos` | array | `{point, relativePoint, xOffset, yOffset}` for the free-placement frame. |
| `freeIconScale` | number | Free-placement icon scale (0.25–3.0). |
| `freeIconShape` | string | `"circle"` or `"square"`. |

### Migration Chain

1. **Per-character rename (current release):** legacy `TrackingEyeDB` (per-character) → `TrackingEyeCharDB`. The TOC declares both names under `## SavedVariablesPerCharacter:` so the client loads the legacy table; `ADDON_LOADED` copies any non-nil fields from `TrackingEyeDB` into `TrackingEyeCharDB`, then `wipe`s and nils `TrackingEyeDB`. The legacy declaration in the TOC will be dropped in a follow-up release.
2. **Account-wide rename (planned, target ≥ July 2026):** legacy `TrackingEyeGlobalDB` → `TrackingEyeDB` (canonical). Will follow the same pattern: TOC declares both names under `## SavedVariables:`, `ADDON_LOADED` copies fields, then wipes and nils the legacy table. The collision with the legacy per-character `TrackingEyeDB` is resolved once step 1 has rolled out — the per-character declaration drops in step 2. The full prompt for executing step 2 lives in the `TODO(2026-07)` block above the Stage 1 migration in [Core.lua](Core.lua).

**Defaults rule:** initialization only fills a field when it is `nil`. Existing user values are never overwritten. Add new defaults the same way; never reset existing fields without a tagged migration.

## Adding a New Tracking Spell

1. Add the spell ID to `te.SPELLS` in [Data.lua](Data.lua) under the appropriate class section.
2. Add a reference to `te.TRACKING_IDS` in [Data.lua](Data.lua) so it appears in the menu, the options Farm Abilities list, and the `te.TRACKING_SET` hash.
3. If the spell has special form gating (like Druid Track Humanoids), add a guard in `te.CastTracking` ([Farm-Mode.lua](Farm-Mode.lua)), exclude it from `cachedCycle` in `BuildCycleCache`, and exclude it from the Farm Mode Abilities options list in `BuildFarmAbilityArgs` ([Options.lua](Options.lua)).
4. If the new spell should be on by default in Farm Mode, add it to `te.FARM_CYCLE_DEFAULTS` in [Data.lua](Data.lua).
5. No new locale strings are needed — the spell name and icon come from `GetSpellInfo` / `GetSpellTexture` at runtime. Only add a locale key if you also need a custom label or description.
6. Verify the menu and options correctly hide the spell on characters that don't know it. The `IsPlayerSpell(id)` check inside `BuildFarmAbilityArgs`'s `hidden` and inside `Tracking-Menu.lua`'s row loop is what gates visibility.

## Adding a New Locale

Copy `Locales/enUS.lua` to `Locales/<locale>.lua`. Drop the `true` argument from the `NewLocale("TrackingEye", "<locale>", true)` call (the `true` flag marks the file as the default fallback — only `enUS.lua` should set it). Translate every string. Add the file to [TrackingEye.toc](TrackingEye.toc) immediately after `Locales/enUS.lua`.

For Spanish, follow the shared-`strings`-table pattern in [Locales/esES.lua](Locales/esES.lua): build a single `strings` table at the top, register both `esES` and `esMX` from it with `if L`/`if L2` guards. The shared table avoids the early-return bug where `if not L then return end` after the esES `NewLocale` call would prevent esMX-only clients from registering anything.

## Common Pitfalls

- **Removing the `GetTrackingTexture` nil guard in `TryRecastPersistent`** — Causes the login-recast bug. The tracking API is unresponsive during the Classic login/reload event storm; without the guard the addon casts on every login because it can't see whether the spell is already active.
- **Casting tracking during the GCD after shapeshift** — Mitigated by `C_Timer.After(1.5, TryRecastPersistent)` on `UPDATE_SHAPESHIFT_FORM`. Removing the delay causes silent cast failures because the GCD from the shapeshift hasn't elapsed.
- **Adding Druid Track Humanoids to the farm cycle** — Excluded on purpose. It requires Cat Form, which is mutually exclusive with the travel forms that put the player into farm state. Re-adding it would queue casts that always fail.
- **Options panel auto-cycle interference** — Farm Mode pauses while the options panel is visible (`te.optionsOpen` is hooked to the panel's `OnShow`/`OnHide` in `te.InitOptions`). Without this, toggling abilities in the panel would race the ticker and produce inconsistent state.
- **Touching `TrackingEyeCharDB` at file scope** — Always defer reads/writes until after `ADDON_LOADED`. SavedVariables aren't populated until the client fires that event; reading them earlier returns `nil` and overwriting them at file scope wipes user data.
- **Renaming an existing SavedVariables field without a migration** — `EnsureDefaults`-style backfill only fills `nil` fields. A rename leaves both the old and new key present; the user's intent stays in the old key until a tagged migration moves it.

## Contributing

- **Issues:** open them at [github.com/Gogo1951/Tracking-Eye/issues](https://github.com/Gogo1951/Tracking-Eye/issues). For bug reports include: game version (Classic Era / Anniversary / etc.), client locale, character class and level, exact reproduction steps, and any chat output or error text.
- **Discord:** [discord.gg/eh8hKq992Q](https://discord.gg/eh8hKq992Q) for discussion, screenshots, and quick questions.
- **Pull requests:**
  - Keep scope tight — one feature or fix per PR.
  - Follow the style guide. No alignment padding around `=`, no `##` for in-file section headers, no hardcoded user-facing strings.
  - Respect the Persistent Tracking guards — read the *Persistent Tracking Deep Dive* section before touching that code path.
  - When the architecture or file map changes, update this document in the same PR.
