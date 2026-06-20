# Tracking Eye — Technical Reference

This document combines architecture notes and contribution guidance for developers working on Tracking Eye. For end-user documentation, see [README.md](https://github.com/Gogo1951/Tracking-Eye/blob/main/README.md).

## File Map

```text
TrackingEye/
  TrackingEye.toc          TOC manifest — interface versions, metadata, load order
  Data.lua                 AceLocale init, constants, spell table, defaults, color palette
  Core.lua                 State, utility functions, event router, icon management, welcome message
  Farm-Mode.lua            Farm cycle cache, ticker management, decision chain
  Tracking-Menu.lua        LibUIDropDownMenu-based spell picker
  Minimap-Button.lua       LibDataBroker launcher, LibDBIcon, free-placement frame, tooltip
  Options.lua              AceConfig-3.0 options panel, slash commands, reset action
  Tracking-Eye.tga         Addon icon (referenced from the TOC's IconTexture)
  Locales/
    enUS.lua               Source-of-truth locale (sets the AceLocale `true` default flag)
    deDE.lua … zhTW.lua    Translations (fall back to enUS via AceLocale)
  Includes/                Bundled libraries (managed by .pkgmeta externals)
```

Files load in TOC order. Order matters: `Data.lua` populates the shared namespace before any other file touches it; `Core.lua` defines the event router and utility helpers that the later files call into.

## Shared Namespace

Every Lua file receives `(addonName, ns)` via the `...` vararg. The `ns` table is the addon's shared namespace — all public functions, constants, and state live on it. There are no global functions; everything hangs off `ns`. Saved variables are the only globals, and they exist because the WoW client owns their lifecycle.

## Architecture

### Event Loop

`Core.lua` registers a single hidden frame (`eventFrame`) and routes every event through one `OnEvent` handler. Initialization happens in two passes:

- `ADDON_LOADED` (when `arg1 == addonName`) applies the cross-character reset propagation check, backfills missing keys in `TrackingEyeCharDB` and `TrackingEyeDB`, calls `ns.CreateFreeFrame()`, and runs the first `ns.UpdateIcon()`.
- `PLAYER_LOGIN` calls `ns.InitMinimap()`, `ns.InitFarmMode()`, `ns.InitOptions()`, refreshes the icon, and prints the welcome message (gated by `TrackingEyeDB.showWelcome`).

Steady-state events:

- `UNIT_SPELLCAST_SUCCEEDED` — if the cast spell ID is in `ns.TRACKING_SET`, set it as `ns.state.lastCastSpell` and refresh the icon.
- `MINIMAP_UPDATE_TRACKING`, `ZONE_CHANGED_NEW_AREA` — refresh the icon.
- `PLAYER_ENTERING_WORLD`, `SPELLS_CHANGED` — refresh the icon, then call `ns.UpdatePlacement()` and `ns.InvalidateFarmCache()`.
- `UPDATE_SHAPESHIFT_FORM` — refresh the icon, then `C_Timer.After(1.5, TryRecastPersistent)`.
- `PLAYER_UNGHOST` — `C_Timer.After(1.5, …)` to recast the saved tracking spell directly (bypasses `TryRecastPersistent`).
- `PLAYER_LOGOUT` — call `ns.SaveFreeFramePosition()` so the free-placement frame's live position is captured before WoW serializes SavedVariables (defensive backstop in addition to the OnDragStop save).

### Combat Lockdown

Tracking Eye does not currently defer any work for combat. None of its writes touch protected frames or secure templates: the LibDataBroker launcher, the LibDBIcon minimap button, the free-placement `Button`, and the AceConfig options panel are all unsecure. Spell casts go through `pcall(CastSpellByID, …)` and fail harmlessly if the cast is blocked. If a future feature needs to drive secure UI, introduce an `InCombatLockdown()`-gated dirty flag and replay deferred work on `PLAYER_REGEN_ENABLED`.

### Persistent Tracking Pipeline

Selection happens in `Tracking-Menu.lua` (`InitMenu` → `info.func`): the menu writes `TrackingEyeCharDB.selectedSpellId`, clears `ns.state.wasFarming`, and calls `ns.CastTracking(button.value)`. Recasts come from two paths:

- `UPDATE_SHAPESHIFT_FORM` → `TryRecastPersistent()` — uses `GetTrackingTexture()` to check whether a recast is needed.
- `PLAYER_UNGHOST` → inline closure in the event handler — recasts unconditionally because the server clears tracking on resurrection.

`ns.CastTracking(spellId)` validates `IsPlayerSpell`, gates Druid Track Humanoids on Cat Form, checks the spell cooldown, then sets `ns.state.lastCastSpell` and `pcall`s `CastSpellByID`.

### Farm Cycle Cache

`Farm-Mode.lua` keeps a sorted, IDs-only array `cachedCycle` rebuilt by `BuildCycleCache()`. It pulls every enabled entry from `TrackingEyeCharDB.farmCycleSpells`, drops `ns.SPELLS.DRUID_HUMANOIDS`, requires `IsPlayerSpell`, and sorts the result to keep cycle order stable across reloads.

`ns.InvalidateFarmCache()` nils the cache. The Core event router invalidates on `SPELLS_CHANGED` and `PLAYER_ENTERING_WORLD`. The Options panel calls it from each Farm Mode Abilities toggle's `set` handler. The cache is lazily rebuilt the next time `ns.RunFarmLogic()` runs.

### Icon Resolution

`ns.UpdateIcon()` resolves the displayed texture through this priority chain:

1. `ReadActiveTracking()` — reads the live Blizzard minimap tracking texture from the global `MiniMapTrackingIcon` and matches it back to a known tracking spell. `GetTrackingTexture()` is unreliable on the Anniversary client (returns `nil` for some active trackers, such as the Dwarf racial Find Treasure), so the minimap icon is consulted first; this branch also self-heals the persisted `lastCastSpell` when the player toggled tracking through the default UI.
2. `GetTrackingTexture()` — the active in-game tracking buff.
3. `ns.state.lastCastSpell` → `GetSpellTexture(lastCastSpell)`. (Cleared first if the saved spell is `DRUID_HUMANOIDS` and the player is no longer in Cat Form.)
4. `TrackingEyeCharDB.selectedSpellId` → `GetSpellTexture(selected)`, skipped if the selected spell is `DRUID_HUMANOIDS` and the player is not in Cat Form.
5. `ns.ICON_DEFAULT` — `Interface\Icons\inv_misc_map_01`.

The resolved texture is written to `ns.state.currentIcon`, the LDB launcher's `icon` field, and the free-placement frame's icon texture. `ns.RefreshTooltip()` is then called so a tooltip already on-screen reflects the new icon.

**Client coverage.** The global `MiniMapTrackingIcon` read by `ReadActiveTracking` and `PollUntilTrackingReady` is present on both supported clients, verified against Blizzard's own minimap source: Classic Era 1.15.8 (`Blizzard_Minimap/Vanilla/Minimap.xml`, where the `MiniMapTracking` frame's `MiniMapTrackingIcon` texture is set from `GetTrackingTexture()` on `MINIMAP_UPDATE_TRACKING`) and TBC 2.5.5 (the `MiniMapTracking` frame is present in the TBC minimap source and confirmed by in-game testing). The read still degrades safely if the frame is ever absent on a future build — a nil frame yields no match and resolution falls through to `GetTrackingTexture()`.

## Persistent Tracking Deep Dive

The `UPDATE_SHAPESHIFT_FORM` path runs `TryRecastPersistent()` after a 1.5-second delay. The function bails early under any of these conditions:

- `TrackingEyeCharDB` missing, `persistentTracking` off, or `selectedSpellId` not set.
- The player is currently in a farm form (mounted, travel, aquatic, flight, swift flight) — Farm Mode owns the cast in that case.
- `IsPlayerSpell(spellId)` is false (e.g., the saved spell was unlearned).
- `GetTrackingTexture()` returns `nil`.

The last bail is load-bearing. During the Classic login and reload event storm the tracking API is unresponsive for ten or more seconds. `GetTrackingTexture()` returns `nil` during that window and we cannot tell whether the saved spell is already active. Casting blindly during this window causes the long-standing login-recast bug — Tracking Eye would re-fire the spell on every login, sometimes interrupting whatever the player was doing. The nil bail is the fix. Do not remove it. The block comment above `TryRecastPersistent` in [Core.lua](Core.lua) records this in detail — read it before touching that path.

`PLAYER_UNGHOST` does **not** route through `TryRecastPersistent`. After resurrection the server has genuinely cleared the player's tracking buff, so a recast is always needed. The handler skips the texture-comparison logic and casts directly after a 1.5-second delay (giving GCD and any post-resurrection scripts time to settle).

## Farm Mode Deep Dive

`ns.RunFarmLogic()` runs on a `C_Timer.NewTicker` (default interval 3.5s, configurable 2–10s via `TrackingEyeCharDB.farmInterval`). The decision chain:

1. Bail if the options panel is visible (`ns.optionsOpen`).
2. Bail if `TrackingEyeCharDB.farmMode` is off.
3. Bail in restricted zones (`ns.IsRestrictedZone()` — see *Restricted Zones* below).
4. Read `ns.GetPlayerStates()`. If the player just left farm form (`not inForm and ns.state.wasFarming`), recast the persistent tracking spell when its texture differs from the current tracking texture.
5. Bail if not in farm form or `ns.CanCast()` is false.
6. Lazily rebuild `cachedCycle` if nil. Bail when empty.
7. Single-entry shortcut: when `#cachedCycle == 1`, only cast if the spell isn't already active; otherwise mark `wasFarming = true` and bail.
8. Advance `farmIndex = (farmIndex % #cachedCycle) + 1` and cast `cachedCycle[farmIndex]` when its texture differs from the current tracking texture.

`ns.CanCast()` returns false while dead/ghost, stealthed, mid-cast, or in combat. Combined with the form check in step 5, this keeps Farm Mode from queuing casts that the server would reject.

### Why Druid Track Humanoids Is Excluded

`ns.SPELLS.DRUID_HUMANOIDS` (5225) requires Cat Form. Cat Form is mutually exclusive with the travel forms that put the player into farm state — Travel, Aquatic, Flight, Swift Flight. Including Druid Track Humanoids in `cachedCycle` would mean trying to cast a Cat-Form-gated spell from a non-Cat-Form context, which always fails. The exclusion lives in three places: `BuildCycleCache()` skips the ID, `BuildFarmAbilityArgs()` in [Options.lua](Options.lua) hides the toggle from the Farm Mode Abilities list, and `ns.CastTracking()` guards on `isCat` before letting the cast through.

### Restricted Zones

`ns.IsRestrictedZone()` returns true when `IsInInstance()` is true (any instance — dungeon, raid, battleground, arena) or when `IsResting()` is true (capital cities and inn rest areas). It is intentionally simple: there is no `ns.CAPITAL_CITIES` or `ns.BATTLEGROUNDS` table and no `C_Map` lookup. The trade-off is breadth — Farm Mode pauses anywhere the resting flag is set, which covers more than just the named cities, and it correctly pauses in non-BG instances too.

## Minimap Button & Free-Placement Frame

`ns.InitMinimap()` registers a `LibDataBroker-1.1` launcher and hands it to `LibDBIcon-1.0` with the saved `TrackingEyeDB.minimap` payload. `ns.CreateFreeFrame()` builds the standalone `Button` used when Free Placement Mode is on. `ns.UpdatePlacement()` toggles visibility between the two based on `TrackingEyeDB.freePlacement`, and also hides both when the player has no tracking abilities at all (`ns.HasTrackingAbility()`).

### Anonymous Free Frame

The free-placement frame is created with `nil` as its name on purpose. WoW's per-character `layout-local.txt` cache keys frames on their name; any named frame is looked up there at creation time, and a cached position from a previous session is applied silently — overriding the account-wide `TrackingEyeDB.freePos`. `SetUserPlaced(false)` from Lua does *not* prevent this lookup. Making the frame anonymous removes it from the layout-local system entirely, so positioning is owned 100% by `TrackingEyeDB.freePos`.

### Position Pipeline

The free-placement frame uses two file-local helpers in [Minimap-Button.lua](Minimap-Button.lua) — `SaveFreePosition(frame)` and `ApplyFreePosition(frame)` — and a single stable anchor: `frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)`.

- **Storage format.** `TrackingEyeDB.freePos = {x = number, y = number}` where `x` and `y` are the frame's center in *absolute screen pixels* (i.e., the live `GetCenter()` multiplied by the frame's effective scale at save time). Storing absolute pixels means a later UI-scale change or icon-scale change doesn't drift the saved position — both ends of the round trip convert through the frame's current effective scale.
- **Save points.** `SaveFreePosition` runs from three places: `OnDragStop` (after every user drag), `ns.SaveFreeFramePosition()` called from the `PLAYER_LOGOUT` handler in [Core.lua](Core.lua) (final capture before SavedVariables serialize), and implicitly during legacy-format migration inside `ApplyFreePosition`.
- **Apply points.** `ApplyFreePosition` runs from the end of `CreateFreeFrame` (initial restore), the end of `UpdateFreeFrameScale` (so `SetScale` doesn't shift the offsets), `UpdatePlacement` before `Show()` (defense against any other code path that re-anchored the frame while it was hidden), and again right after a drag (so the live anchor is normalized back to the canonical CENTER → BOTTOMLEFT form instead of whatever WoW chose mid-drag).
- **`SetUserPlaced(false)`.** Called in both `OnDragStop` and `ApplyFreePosition`. `StartMoving` / `StopMovingOrSizing` silently flag any frame as user-placed for the rest of the session, and a stale flag can cause the client to write a layout-local entry on logout that out-races our SavedVariables on next login. Clearing the flag on every position apply keeps the flag from sticking.
- **Legacy migration.** If `freePos` is found in the old array shape (`{point, relativePoint, xOffset, yOffset}`), `ApplyFreePosition` applies it once with the legacy anchor, calls `SaveFreePosition` to capture the resulting center in the new `{x, y}` format, and overwrites the stored value. After one login on the new code, the legacy shape is gone.

### Click Map

`OnClick` in [Minimap-Button.lua](Minimap-Button.lua) drives every interaction on both the LibDBIcon button and the free-placement frame:

| Modifier + Button   | Action                                              |
| ------------------- | --------------------------------------------------- |
| Left-Click          | Open the tracking menu.                              |
| Right-Click         | `ns.ClearTracking()` — cancel and forget selection. |
| Shift + Left-Click  | Toggle Persistent Tracking.                          |
| Shift + Right-Click | Toggle Farm Mode.                                    |
| Shift + Middle-Click| Toggle Free Placement Mode.                          |

`ns.ClearTracking()` nils `selectedSpellId`, calls `CancelTrackingBuff()`, and forces the icon to default immediately — `CancelTrackingBuff` is asynchronous and `GetTrackingTexture()` would still return the old texture for a frame otherwise.

## Saved Variables

### TrackingEyeCharDB (per-character)

| Field              | Type                | Purpose                                                          |
| ------------------ | ------------------- | ---------------------------------------------------------------- |
| `persistentTracking`     | boolean             | Persistent Tracking master toggle.                               |
| `farmMode`      | boolean             | Farm Mode master toggle.                                         |
| `farmInterval`     | number              | Farm Mode cycle interval in seconds (2–10).                      |
| `farmCycleSpells`  | `[spellId] = bool`  | Which tracking abilities Farm Mode rotates through.              |
| `selectedSpellId`  | number              | The Persistent Tracking ability the user picked.                 |
| `resetGeneration`  | number              | Cross-character reset propagation marker (internal — see below). |

### TrackingEyeDB (account-wide)

| Field              | Type     | Purpose                                                            |
| ------------------ | -------- | ------------------------------------------------------------------ |
| `minimap`          | table    | LibDBIcon position payload (`hide`, `minimapPos`, etc.).           |
| `freePlacement`    | boolean  | Free Placement Mode toggle.                                        |
| `freePos`          | table    | `{x = number, y = number}` — free-placement frame center in absolute screen pixels. Legacy `{point, relativePoint, xOffset, yOffset}` array is migrated on first load. |
| `freeIconScale`    | number   | Free-placement icon scale (0.25–3.0).                              |
| `freeIconShape`    | string   | `"circle"` or `"square"`.                                          |
| `showWelcome`      | boolean  | Print the one-line login chat message.                             |
| `resetGeneration`  | number   | Bumped by the Reset action so all alts wipe on next login.         |

### Cross-Character Reset Propagation

The Reset action in Options bumps `TrackingEyeDB.resetGeneration` and syncs the current character's per-character `resetGeneration` to match. On every other character's next `ADDON_LOADED`, the per-character DB is wiped because its `resetGeneration` is behind the account-wide value. This lets one Reset clear every alt without round-tripping through each character manually. Both fields are internal — do not surface them in options or treat them as user-facing.

## Adding a New Tracking Spell

1. Add a row to `SPELL_DATA` in [Data.lua](Data.lua) under the appropriate source. The constructor populates `ns.SPELLS`, `ns.TRACKING_IDS`, and `ns.TRACKING_SET` from this table automatically.
2. If the spell should be on by default in Farm Mode, add it to `ns.FARM_CYCLE_DEFAULTS` in [Data.lua](Data.lua).
3. If the spell has special form gating (like Druid Track Humanoids), add a guard in `ns.CastTracking` ([Core.lua](Core.lua)), exclude it from `cachedCycle` in `BuildCycleCache` ([Farm-Mode.lua](Farm-Mode.lua)), and exclude it from the Farm Mode Abilities options list in `BuildFarmAbilityArgs` ([Options.lua](Options.lua)).
4. No new locale strings are needed — the spell name and icon come from `GetSpellInfo` / `GetSpellTexture` at runtime. Only add a locale key if you also need a custom label or description.
5. Verify the menu and options correctly hide the spell on characters that don't know it. The `IsPlayerSpell(id)` check inside `BuildFarmAbilityArgs`'s `hidden` and inside `Tracking-Menu.lua`'s row loop is what gates visibility.

## Adding a New Locale

Copy `Locales/enUS.lua` to `Locales/<locale>.lua`. Drop the `true` argument from the `NewLocale("TrackingEye", "<locale>", true)` call — that flag marks the file as the default fallback, and only `enUS.lua` should set it. Translate every string. Add the file to [TrackingEye.toc](TrackingEye.toc) immediately after `Locales/enUS.lua`.

The existing Spanish locales (`esES.lua` and `esMX.lua`) are independent files; each registers its own `NewLocale` and translates every string in isolation. If you ever consolidate them, follow the shared-`strings`-table pattern from sibling addons: build one local table at the top, register both locales from it, and guard each `if L` block independently so the `if not L then return end` early-out from the first locale doesn't prevent the second from registering.

## Common Pitfalls

- **Removing the `GetTrackingTexture` nil guard in `TryRecastPersistent`** — Causes the login-recast bug. The tracking API is unresponsive during the Classic login/reload event storm; without the guard the addon casts on every login because it can't tell whether the spell is already active. The fix's purpose is documented in a block comment above the function in [Core.lua](Core.lua) — leave the comment in place too.
- **Casting tracking during the GCD after shapeshift** — Mitigated by `C_Timer.After(1.5, TryRecastPersistent)` on `UPDATE_SHAPESHIFT_FORM`. Removing the delay causes silent cast failures because the GCD from the shapeshift hasn't elapsed.
- **Adding Druid Track Humanoids to the farm cycle** — Excluded on purpose. It requires Cat Form, which is mutually exclusive with the travel forms that put the player into farm state. Re-adding it would queue casts that always fail.
- **Naming the free-placement frame** — Re-introduces the WoW `layout-local.txt` lookup that the anonymous-frame fix exists to avoid. A cached per-character position will silently override `TrackingEyeDB.freePos`. Keep the constructor's first arg `nil`.
- **Reading `GetPoint()` to serialize the free-frame position** — `StartMoving` / `StopMovingOrSizing` leave the frame on a non-canonical anchor; saving the result causes the icon to drift on the next Show or scale change. Always go through `SaveFreePosition` / `ApplyFreePosition`, which round-trip through screen-pixel coords on a stable `CENTER → UIParent BOTTOMLEFT` anchor.
- **Skipping `SetUserPlaced(false)` after a position apply** — `StartMoving` silently flags the frame as user-placed. A leftover flag lets WoW write a layout-local entry on logout that out-races our SavedVariables on next login, so the icon respawns at the layout-local position before we can re-anchor it.
- **Options panel auto-cycle interference** — Farm Mode pauses while the options panel is visible (`ns.optionsOpen` is hooked to the panel's `OnShow`/`OnHide` in `ns.InitOptions`). Without this, toggling abilities in the panel would race the ticker and produce inconsistent state.
- **Touching `TrackingEyeCharDB` or `TrackingEyeDB` at file scope** — Always defer reads/writes until after `ADDON_LOADED`. SavedVariables aren't populated until the client fires that event; reading them earlier returns `nil`, and overwriting them at file scope wipes user data.
- **Renaming an existing SavedVariables field without a migration** — Default backfill only fills `nil` fields. A rename leaves both the old and new key present; the user's intent stays in the old key until a tagged migration moves it.
- **Forgetting to bump `resetGeneration` on a reset that should propagate** — Without the bump, alts keep their old settings forever. With it, every alt wipes once on its next login. Don't add a "soft reset" path that skips the bump.

## Contributing

- **Issues:** open them at [github.com/Gogo1951/Tracking-Eye/issues](https://github.com/Gogo1951/Tracking-Eye/issues). For bug reports include: game version (Classic Era / Anniversary / etc.), client locale, character class and level, exact reproduction steps, and any chat output or error text.
- **Discord:** [discord.gg/eh8hKq992Q](https://discord.gg/eh8hKq992Q) for discussion, screenshots, and quick questions.
- **Pull requests:**
  - Keep scope tight — one feature or fix per PR.
  - Follow the style guide. No alignment padding around `=`, no `##` for in-file section headers, no hardcoded user-facing strings (every player-visible string belongs in `Locales/enUS.lua`).
  - Respect the Persistent Tracking guards — read the *Persistent Tracking Deep Dive* section before touching that code path.
  - When the architecture or file map changes, update this document in the same PR.

### Commit and PR descriptions require a User Story

Don't just say "I changed X" or "I fixed Y." Frame the change in terms of who it helps and why.

**Format:** *As a [role], I [needed / wanted] [behavior] so that [outcome]. This change [does X].*

**Example:** *As a druid who shapeshifts between Travel Form and caster form during a farming run, I wanted Tracking Eye to recast my saved tracking spell after the shapeshift instead of leaving me with no tracking buff. This change schedules a `TryRecastPersistent()` 1.5 seconds after `UPDATE_SHAPESHIFT_FORM` so the post-shift GCD has elapsed before the cast fires.*

The User Story makes review faster and gives future maintainers context the diff alone won't carry.
