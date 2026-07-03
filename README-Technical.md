# Tracking Eye — Technical Reference

This document combines architecture notes and contribution guidance for developers working on Tracking Eye. For end-user documentation, see [README.md](https://github.com/Gogo1951/Tracking-Eye/blob/main/README.md).

## File Map

```text
TrackingEye/
  TrackingEye.toc              TOC manifest — interface versions, metadata, SavedVariables, load order
  README.md                    End-user documentation
  README-Technical.md          This file

  Data/
    Data.lua                   AceLocale handle, constants, spell table, farm-state IDs, restricted maps, raw color palette
    Default-Settings.lua       CHAR_DEFAULTS, GLOBAL_DEFAULTS, FARM_CYCLE_DEFAULTS

  Features/
    Core.lua                   State, SetLastCast, UpdateIcon, ClearTracking, CastTracking, TryRecastPersistent, event dispatcher
    Utilities.lua              GetColor, GetPlayerStates, GetActiveTrackingSpell, CanCast, HasTrackingAbility, IsPlayerClass, IsRestrictedZone
    Announcements.lua          ns:PrintMessage — the only chat output; prints to the player, never sends
    Farm-Mode.lua              Farm cycle cache, ticker management, RunFarmLogic decision chain
    Tracking-Menu.lua          LibUIDropDownMenu spell picker
    Diagnostics.lua            Read-only diagnostic reports and event log (developer troubleshooting)
    Minimap-Button.lua         LibDataBroker launcher, LibDBIcon, anonymous free-placement frame, tooltip, OnClick

  Options/
    Options-Utilities.lua      OptionsHeader / OptionsDesc / OptionsSpacer / OptionsSubHeader widget helpers
    Options-General.lua        BuildGeneralOptions — the main AceConfig panel; BuildFarmAbilityArgs
    Options-Diagnostics.lua    BuildDiagnosticsOptions — the gated Diagnostic Tools panel
    Options.lua                InitOptions, OpenOptions, slash commands, optionsOpen hooks

  Locales/
    enUS.lua                   Source-of-truth locale (sets the AceLocale `true` default flag)
    deDE.lua … zhTW.lua        Translations (fall back to enUS via AceLocale)

  Includes/
    Images/Tracking-Eye.tga    Addon icon (referenced from the TOC IconTexture)
    Libraries/                 Vendored libs: LibStub, CallbackHandler-1.0, Ace3 (AceLocale/AceGUI/AceConfig),
                               LibDataBroker-1.1, LibDBIcon-1.0, LibUIDropDownMenu
```

Files load in TOC order: `Includes/` → `Locales/` → `Data/` → `Features/` → `Options/`. Order matters. `Data/Data.lua` populates the shared namespace (spell tables, constants, palette) and `Data/Default-Settings.lua` adds the default tables before any feature reads them; `Features/Core.lua` defines the event dispatcher and `Features/Utilities.lua` the game-state predicates that the later files call at runtime.

## Architecture

### Shared Namespace

Every Lua file receives `(addonName, ns)` via the `...` vararg. The `ns` table is the addon's shared namespace — all public functions, constants, and state live on it. There are no global functions; everything hangs off `ns`. The only globals are the two SavedVariables tables (`TrackingEyeDB`, `TrackingEyeCharDB`), which exist because the WoW client owns their lifecycle, and the WoW-mandated `SLASH_*` / `SlashCmdList` entries.

Because features are split across files that load in a fixed order, a file may *define* a function the earlier-loaded files *call* — that is safe as long as the call happens at runtime, not at file scope. `Core.lua` loads before `Utilities.lua` yet calls `ns.GetPlayerStates` and `ns.GetColor`; this works because those calls only ever fire from event handlers and timers, long after every file has loaded.

### Event Loop

`Core.lua` registers a single hidden frame (`eventFrame`) and routes every event through one `OnEvent` handler. The registered event list lives in `ns.EVENT_NAMES` — a single source of truth that the Diagnostics *Event Registration* check reads back, so the two can never drift. `UNIT_SPELLCAST_SUCCEEDED` is registered with `RegisterUnitEvent(..., "player")` so the dispatcher is never woken for other units' casts.

Every event first passes through `ns:LogEvent` when the diagnostics event log is active (see *Diagnostics*). Initialization then happens in two passes:

- `ADDON_LOADED` (when `arg1 == addonName`) creates the SavedVariables tables if absent, runs the cross-character reset check, applies the field migrations, backfills missing defaults, seeds `farmCycleSpells`, calls `ns.CreateFreeFrame()`, and runs the first `ns.UpdateIcon()`.
- `PLAYER_LOGIN` calls `ns.InitMinimap()`, `ns.InitFarmMode()`, `ns.InitOptions()`, refreshes the icon, starts `PollUntilTrackingReady()`, and prints the welcome message (gated by `TrackingEyeDB.showWelcome`).

Steady-state events:

- `UNIT_SPELLCAST_SUCCEEDED` (player) — if the cast spell ID is in `ns.TRACKING_SET`, call `ns.SetLastCast(spellId)` and refresh the icon. This is the **only** writer of `ns.state.lastCastSpell`.
- `MINIMAP_UPDATE_TRACKING` — refresh the icon, run `FlushIconAfterTrackingChange()`, then `C_Timer.After(2, TryRecastPersistent)`. Tracking changed or was cancelled outside the addon; this is the trigger that re-applies a cancelled persistent spell. Safe to fire from our own casts — the function's grace window and debounce absorb the echo.
- `ZONE_CHANGED_NEW_AREA` — refresh the icon.
- `PLAYER_ENTERING_WORLD`, `SPELLS_CHANGED` — refresh the icon, then `ns.UpdatePlacement()` and `ns.InvalidateFarmCache()`. `PLAYER_ENTERING_WORLD` also records `ns.state.enteredWorldAt` (anchors the recast grace window) and schedules the **login catch-up**: one `TryRecastPersistent()` call at grace-expiry (+11s). Without it, a player who logs in with tracking down stays that way — on Era no tracking event may ever fire to provide a trigger. If tracking survived logout, the positive-mirror check inside `TryRecastPersistent` skips the cast.
- `UPDATE_SHAPESHIFT_FORM` — refresh the icon, then `C_Timer.After(1.5, TryRecastPersistent)`.
- `PLAYER_UNGHOST` — `C_Timer.After(1.5, …)` to recast the saved tracking spell directly (bypasses `TryRecastPersistent`; the server always clears tracking on resurrection).
- `PLAYER_UPDATE_RESTING` — call `ns.RunFarmLogic()` immediately so Farm Mode stops the instant the resting flag is set (entering a city/inn) and resumes the instant it clears, instead of waiting up to a full ticker interval. The resting flag itself can lag zone entry by several seconds — that latency is the client's, not the ticker's.
- `PLAYER_LOGOUT` — call `ns.SaveFreeFramePosition()` so the free-placement frame's live position is captured before WoW serializes SavedVariables (a backstop in addition to the `OnDragStop` save).

### Combat Lockdown

Tracking Eye does not defer any work for combat. None of its writes touch protected frames or secure templates: the LibDataBroker launcher, the LibDBIcon minimap button, the free-placement `Button`, and the AceConfig options panels are all unsecure. Spell casts go through `pcall(CastSpellByID, …)` and fail harmlessly if the cast is blocked, and `ns.CanCast()` already refuses to fire while `UnitAffectingCombat("player")` is true. If a future feature needs to drive secure UI, introduce an `InCombatLockdown()`-gated dirty flag and replay deferred work on `PLAYER_REGEN_ENABLED`.

### Icon Resolution

`ns.UpdateIcon()` ([Features/Core.lua](Features/Core.lua)) is the single place that decides which texture the launcher and free frame display. It resolves through one authoritative reader — `ns.GetActiveTrackingSpell()` — and never reads `MiniMapTrackingIcon` or `GetTrackingTexture()` directly. Every past icon bug on Era came from a second reader of the tracking mirror with slightly different rules.

1. `ns.GetPlayerStates()` — if the player has left Cat Form and `lastCastSpell` still holds `DRUID_HUMANOIDS`, clear it.
2. `activeSpell = ns.GetActiveTrackingSpell()` — the live tracking spell (Blizzard minimap icon while visible, `GetTrackingTexture()` as fallback; see [Features/Utilities.lua](Features/Utilities.lua)).
3. **Adopt** pre-session tracking: if `activeSpell` is set and `ns.state.lastCastSpell` is nil, adopt it via `ns.SetLastCast(activeSpell)` — but only while the session has no confirmed cast, since in-session casts already own `lastCastSpell` and the Era mirror lags them.
4. **Latch** `mirrorConfirmedCast`: once the mirror positively reports our own `lastCastSpell`, it has caught up, so a later nil reading is a genuine external cancel rather than lag.
5. Choose the icon spell: `activeSpell` if present; otherwise, for a few seconds after our own confirmed cast (`ICON_IN_FLIGHT_SECONDS`, and only until `mirrorConfirmedCast` latches), show `lastCastSpell` while the laggy Blizzard icon catches up. **There is no fallback to the selected or persisted spell** — every such fallback produced a stale icon (e.g. showing last session's spell at login with nothing actually up). Nothing tracked means `ns.ICON_DEFAULT` (`Interface\Icons\inv_misc_map_01`).

The resolved texture is written to `ns.state.currentIcon`, `ns.ldb.icon`, and the free frame's icon texture; `ns.RefreshTooltip()` then updates any tooltip already on-screen.

`ns.GetActiveTrackingSpell()` reads the global `MiniMapTrackingIcon` **only while it is visible** and matches its texture back to a known tracking ID; a hidden frame retains a stale texture, and on the Vanilla client the frame is hidden entirely when nothing is tracked. It falls back to `GetTrackingTexture()` for clients (TBC+) that show a generic "None" texture instead. The read degrades safely if the frame is ever absent — a nil frame yields no match and resolution falls through.

Two supporting pollers in `Core.lua` shave latency without ever making the mirror fresher:

- `PollUntilTrackingReady()` runs once at `PLAYER_LOGIN`, retrying every second (up to 15×) until `MiniMapTrackingIcon` has a texture, then refreshes the icon once. During the login event storm the icon may not have its texture set yet and `MINIMAP_UPDATE_TRACKING` may never fire, so without this the icon can stay stuck on default until the user toggles something.
- `FlushIconAfterTrackingChange()` re-runs `UpdateIcon` a few times over ~2s after a tracking change, catching the Era mirror the moment it flushes. Both pollers are coalesced so bursts of events cannot stack overlapping timers.

## Persistent Tracking Deep Dive

`TryRecastPersistent()` ([Features/Core.lua](Features/Core.lua)) handles mid-play recasts. It runs 1.5 seconds after `UPDATE_SHAPESHIFT_FORM`, 2 seconds after `MINIMAP_UPDATE_TRACKING`, and once at login-grace expiry after `PLAYER_ENTERING_WORLD` (the catch-up). The bail chain, in order:

- `TrackingEyeCharDB` missing, `persistentTracking` off, or `selectedSpellId` not set → stop.
- The player is in a farm state → stop; Farm Mode owns the cast.
- `IsPlayerSpell(spellId)` is false (the saved spell was unlearned) → stop.
- Less than `LOGIN_GRACE_SECONDS` (10) since `PLAYER_ENTERING_WORLD` → stop; the login/reload window. The `PLAYER_ENTERING_WORLD` catch-up re-fires after the window, so nothing is lost.
- `ns.GetActiveTrackingSpell()` returns the selected spell (provably active) → sync `lastCastSpell` and stop. This is what terminates the retry chain after a successful recast.
- Our own cast of this spell is still in flight (`lastCastSpell == spellId` and less than `ns.CAST_IN_FLIGHT_SECONDS` (10) since the attempt) → **reschedule** and re-check. Without this, the constant `UPDATE_SHAPESHIFT_FORM` stream from a hunter's aspects drives a redundant recast every ~5s until the mirror flushes — the "casting it three times" symptom.
- `ns.CanCast()` is false (dead/ghost, stealthed, mid-cast, or in combat) → **reschedule** via `ScheduleRecast(RECAST_DEBOUNCE_SECONDS)`.
- On cooldown or GCD → **reschedule**.
- Less than `RECAST_DEBOUNCE_SECONDS` (5) since the last cast attempt (the `MINIMAP_UPDATE_TRACKING` echo of our own cast) → **reschedule**.
- Otherwise recast.

Temporary bails **retry**, never swallow: on Era the client may fire no further tracking event ever, so a swallowed trigger (the user cancels tracking twice within the debounce) used to kill persistent tracking until the next login. `ScheduleRecast` coalesces retries behind a `recastRetryPending` flag so bursts cannot stack timers.

Two client facts shape this design:

1. **The login blackout.** During the Classic login/reload event storm the tracking API is unresponsive for ten or more seconds and `GetTrackingTexture()` returns `nil`; we cannot tell whether the saved spell is already active. Casting blindly in that window caused the historical login-recast bug. Solved by the **time-based grace window**, not by interpreting `nil`.
2. **The Era stale mirror.** On the Vanilla-based client (Classic Era 1.15.x, since ~1.15.1) the tracking mirror — `GetTrackingTexture()` and `MINIMAP_UPDATE_TRACKING` — lags the real state, sometimes by minutes; it only flushes when an unrelated buff update fires. `nil` is also that client's normal steady-state value for "no tracking active." An earlier version that bailed whenever `GetTrackingTexture()` was `nil` permanently blocked recasts on Era — the guard matched the exact state that needed fixing. **Do not reintroduce a nil bail.** Treat the mirror as a **positive signal only** ("provably active → skip") and let everything else fall through to a recast; recasting an already-active tracking spell is a harmless refresh.

`PLAYER_UNGHOST` does **not** route through `TryRecastPersistent`. After resurrection the server has genuinely cleared the player's tracking buff, so a recast is always needed. The handler skips the comparison logic and casts directly after a 1.5-second delay (letting the GCD and post-resurrection scripts settle).

`ns.CastTracking(spellId)` is the shared cast primitive. It validates `IsPlayerSpell`, gates Druid Track Humanoids on Cat Form, treats an active GCD/cooldown as "skip," records `ns.state.lastTrackingCastAt`, and `pcall`s `CastSpellByID`. It deliberately does **not** write `ns.state.lastCastSpell` — only `UNIT_SPELLCAST_SUCCEEDED` does, so a silent failure (LOS, range, server reject) never poisons the bookkeeping that the farm cycle and recast logic compare against.

## Farm Mode Deep Dive

`ns.RunFarmLogic()` ([Features/Farm-Mode.lua](Features/Farm-Mode.lua)) runs on a `C_Timer.NewTicker` (default 3.5s, configurable 2–10s via `TrackingEyeCharDB.farmInterval`) and also on demand from the `PLAYER_UPDATE_RESTING` handler. The decision chain:

1. Bail if the options panel is visible (`ns.optionsOpen`).
2. Bail if `TrackingEyeCharDB.farmMode` is off.
3. Read `ns.GetPlayerStates()`. If the player just left farm state (`not inForm and ns.state.wasFarming`), clear `wasFarming` and recast the persistent tracking spell unless it is already the last spell we successfully cast. This runs **before** the restricted-zone gate, so a player who unmounts inside an instance or a city still gets their persistent spell back.
4. Bail in restricted zones (`ns.IsRestrictedZone()`).
5. Bail if not in farm state or `ns.CanCast()` is false.
6. Lazily rebuild `cachedCycle` if nil. Bail when empty.
7. Single-entry shortcut: when `#cachedCycle == 1`, idle only while the spell is provably active (`ns.GetActiveTrackingSpell()`) or our own cast is still in flight (`ns.CAST_IN_FLIGHT_SECONDS` since the last attempt, covering icon lag); anything else — including tracking cancelled outside the addon — recasts. Mark `wasFarming = true` and bail.
8. Advance `farmIndex = (farmIndex % #cachedCycle) + 1` and cast `cachedCycle[farmIndex]` unless it is already the last spell we successfully cast. Mark `wasFarming = true`.

Farm logic never reads `GetTrackingTexture()` directly. The multi-spell cycle compares against `ns.state.lastCastSpell` — written only from `UNIT_SPELLCAST_SUCCEEDED`, reliable on every supported client — and the single-spell shortcut additionally consults `ns.GetActiveTrackingSpell()` (Blizzard icon first) so an external cancel is noticed and re-cast. These comparisons exist only to avoid burning a GCD on a no-op recast.

### Farm-State Detection

`ns.GetPlayerStates()` ([Features/Utilities.lua](Features/Utilities.lua)) returns `(isCat, isFarming)`. It scans up to 40 player buffs once and classifies the current movement state, then maps that state to the matching per-state toggle:

| Movement state | Detected by | Per-state toggle | Class gate (options) |
| --- | --- | --- | --- |
| On a taxi | `UnitOnTaxi` | *(always `false, false`)* | — |
| Mounted (out of combat) | `IsMounted` | `farmMounted` | all |
| Travel / Aquatic / Flight / Swift Flight form | buff IDs in `ns.FARM_FORMS` | `farmTravelForms` | Druid |
| Aspect of the Cheetah / Pack | buff IDs in `ns.CHEETAH_BUFFS` | `farmCheetah` | Hunter |
| Ghost Wolf | buff ID `ns.GHOST_WOLF` | `farmGhostWolf` | Hunter/Shaman movement |
| On foot (none of the above) | fallthrough | `farmNotMounted` (off by default) | all |

`isFarming` is true only when the master `farmMode` toggle is on **and** the current state's toggle is enabled. States are mutually exclusive in practice (mounting cancels forms and aspects), so the checks are ordered mounted → travel form → cheetah → ghost wolf → on-foot. The class gates live only in the options UI (`ns.IsPlayerClass`, [Options/Options-General.lua](Options/Options-General.lua)) so a low-level character can pre-configure a toggle before learning the ability; detection itself is class-agnostic.

`isCat` is reported separately because Cat Form is not a farm state — it gates Druid Track Humanoids, which is mutually exclusive with the travel forms that put the player into farm state (see below).

### Farm Cycle Cache

`BuildCycleCache()` builds a sorted, IDs-only array `cachedCycle` from every enabled entry in `TrackingEyeCharDB.farmCycleSpells`. It drops `ns.SPELLS.DRUID_HUMANOIDS`, requires `IsPlayerSpell`, and sorts to keep cycle order stable across reloads. `ns.InvalidateFarmCache()` nils the cache; it is invalidated on `SPELLS_CHANGED`, `PLAYER_ENTERING_WORLD`, and from each Farm Mode Abilities toggle's `set` handler, then rebuilt lazily on the next `RunFarmLogic()`.

### Why Druid Track Humanoids Is Excluded

`ns.SPELLS.DRUID_HUMANOIDS` (5225) requires Cat Form, which is mutually exclusive with the travel forms that put the player into farm state. Including it in the cycle would mean casting a Cat-Form-gated spell from a non-Cat-Form context, which always fails. The exclusion lives in three places: `BuildCycleCache()` ([Features/Farm-Mode.lua](Features/Farm-Mode.lua)) skips the ID, `BuildFarmAbilityArgs()` ([Options/Options-General.lua](Options/Options-General.lua)) hides the toggle, and `ns.CastTracking()` ([Features/Core.lua](Features/Core.lua)) guards on `isCat`. The tracking menu ([Features/Tracking-Menu.lua](Features/Tracking-Menu.lua)) likewise hides the entry unless the player is currently in Cat Form.

### Restricted Zones

`ns.IsRestrictedZone()` ([Features/Utilities.lua](Features/Utilities.lua)) returns true when `IsInInstance()` is true (any instance — dungeon, raid, battleground, arena), when the current instance map ID is in `ns.RESTRICTED_MAP_IDS` (currently only Deeprun Tram, 369), or when `IsResting()` is true (capital cities and inn rest areas). It stays intentionally simple: no capital-city or battleground tables and only a single map-ID special case. The trade-off is breadth — Farm Mode pauses anywhere the resting flag is set, which covers more than just the named cities.

## Minimap Button & Free-Placement Frame

`ns.InitMinimap()` ([Features/Minimap-Button.lua](Features/Minimap-Button.lua)) registers a `LibDataBroker-1.1` launcher and hands it to `LibDBIcon-1.0` with the saved `TrackingEyeDB.minimap` payload. `ns.CreateFreeFrame()` builds the standalone `Button` used when Free Placement Mode is on. `ns.UpdatePlacement()` toggles visibility between the two based on `TrackingEyeDB.freePlacement`, honors the Enable Mini-map Button preference (`TrackingEyeDB.minimap.hide`), and hides both when the player has no tracking abilities at all (`ns.HasTrackingAbility()`).

### Anonymous Free Frame

The free-placement frame is created with `nil` as its name on purpose. WoW's per-character `layout-local.txt` cache keys frames on their name; any named frame is looked up there at creation time and a cached position from a previous session is applied silently — overriding the account-wide `TrackingEyeDB.freePos`. `SetUserPlaced(false)` from Lua does *not* prevent this lookup. Making the frame anonymous removes it from the layout-local system entirely, so positioning is owned 100% by `TrackingEyeDB.freePos`.

### Position Pipeline

The free-placement frame uses two file-local helpers — `SaveFreePosition(frame)` and `ApplyFreePosition(frame)` — and a single stable anchor: `frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)`.

- **Storage format.** `TrackingEyeDB.freePos = {x = number, y = number}` where `x` and `y` are the frame's center in *absolute screen pixels* (live `GetCenter()` multiplied by the frame's effective scale at save time). Storing absolute pixels means a later UI-scale or icon-scale change doesn't drift the saved position — both ends of the round trip convert through the frame's current effective scale.
- **Save points.** `OnDragStop` (after every drag), `ns.SaveFreeFramePosition()` from the `PLAYER_LOGOUT` handler in [Features/Core.lua](Features/Core.lua) (final capture before serialization), and implicitly during legacy-format migration.
- **Apply points.** The end of `CreateFreeFrame` (initial restore), the end of `UpdateFreeFrameScale` (so `SetScale` doesn't shift the offsets), `UpdatePlacement` before `Show()` (defense against any code path that re-anchored the frame while hidden), and immediately after a drag (normalizing the live anchor back to the canonical `CENTER → BOTTOMLEFT` form).
- **`SetUserPlaced(false)`.** Called in both `OnDragStop` and `ApplyFreePosition`. `StartMoving` / `StopMovingOrSizing` silently flag any frame as user-placed for the rest of the session, and a stale flag can cause the client to write a layout-local entry on logout that out-races our SavedVariables on next login. Clearing it on every apply keeps the flag from sticking.
- **Legacy migration.** If `freePos` is found in the old array shape (`{point, relativePoint, xOffset, yOffset}`), `ApplyFreePosition` applies it once with the legacy anchor, calls `SaveFreePosition` to capture the resulting center in the new `{x, y}` format, and overwrites the stored value. After one login on the new code, the legacy shape is gone.

### Click Map

`OnClick` drives every interaction on both the LibDBIcon button and the free-placement frame:

| Modifier + Button   | Action                                              |
| ------------------- | --------------------------------------------------- |
| Left-Click          | Open the tracking menu.                              |
| Right-Click         | `ns.ClearTracking()` — cancel and forget selection. |
| Shift + Left-Click  | Toggle Persistent Tracking.                          |
| Shift + Right-Click | Toggle Farm Mode.                                    |
| Shift + Middle-Click| Toggle Free Placement Mode.                          |

`ns.ClearTracking()` nils `selectedSpellId`, calls `CancelTrackingBuff()`, and forces the icon to default immediately — `CancelTrackingBuff` is asynchronous and `GetTrackingTexture()` would still return the old texture for a frame otherwise.

## Diagnostics

The Diagnostic Tools system ([Features/Diagnostics.lua](Features/Diagnostics.lua) + [Options/Options-Diagnostics.lua](Options/Options-Diagnostics.lua)) exists to make bug reports actionable. It is **not** a unit-test runner — WoW's sandboxed Lua has no assertion framework. Every report builds only on an explicit button press, and every check is read-only and side-effect free. The single exception is the Taint Log button, which sets the `taintLog` CVar.

- **Runtime-only state.** `ns.diagnostics = {enabled, logging, log}` is a plain namespace table, **not** a SavedVariable, so file-scope initialization is correct here. Nothing about diagnostics persists across sessions; it always starts off.
- **English-only strings.** Diagnostics text lives in `ns.DiagnosticsStrings`, intentionally **not** localized — it is developer-facing troubleshooting output. The only localized value it uses is the addon's own display name (`ns.L["ADDON_TITLE"]`).
- **Enable gate.** A single runtime toggle (`ns:SetDiagnosticsEnabled`) shows the panel body; turning it off also stops any running event log. Each report section is a button that fills a read-only multiline editbox.
- **Reports.** Event Log (a 500-entry ring buffer fed by `ns:LogEvent` from the Core dispatcher, argument- and length-capped with pipes escaped), Event Registration (`ns.EVENT_NAMES` validated via `C_EventUtils.IsEventValid` and a probe frame), API Endpoints (`ns.DIAGNOSTIC_API_CHECKS` existence/shape checks), Player & Spell Context, Display Context, Farm Mode Context, Other Add-ons, Saved Variables dump, and Library Versions. Every report is prefixed with a client header (version, build, TOC, locale, `WOW_PROJECT_ID`).
- **Taint Log.** `ns:SetTaintLog` writes the `taintLog` CVar (0 = off, 2 = verbose). This is the only state the panel ever writes.
- **External tools.** Rather than reimplement them, the panel points at `/console scriptErrors 1`, BugSack/!BugGrabber, and `/etrace`.

## Saved Variables

### TrackingEyeCharDB (per-character)

| Field                | Type                | Default | Purpose                                                          |
| -------------------- | ------------------- | ------- | ---------------------------------------------------------------- |
| `persistentTracking` | boolean             | `true`  | Persistent Tracking master toggle.                               |
| `farmMode`           | boolean             | `true`  | Farm Mode master toggle.                                         |
| `farmInterval`       | number              | `3.5`   | Farm Mode cycle interval in seconds (2–10).                      |
| `farmMounted`        | boolean             | `true`  | Activate Farm Mode while mounted.                                |
| `farmTravelForms`    | boolean             | `true`  | Activate Farm Mode in Druid travel/flight forms.                 |
| `farmCheetah`        | boolean             | `true`  | Activate Farm Mode under Aspect of the Cheetah/Pack.             |
| `farmGhostWolf`      | boolean             | `true`  | Activate Farm Mode under Ghost Wolf.                             |
| `farmNotMounted`     | boolean             | `false` | Activate Farm Mode with no mount or movement form.               |
| `farmCycleSpells`    | `[spellId] = bool`  | Herbs + Minerals | Which tracking abilities Farm Mode rotates through.     |
| `selectedSpellId`    | number \| nil       | *(unset)* | The Persistent Tracking ability the user picked.               |
| `resetGeneration`    | number              | *(unset)* | Cross-character reset propagation marker (internal — see below).|

`selectedSpellId` and `farmCycleSpells` are intentionally absent from `ns.CHAR_DEFAULTS` ([Data/Default-Settings.lua](Data/Default-Settings.lua)): `nil` cannot be stored in a Lua table, and `farmCycleSpells` is a nested table deep-copied from `ns.FARM_CYCLE_DEFAULTS` on each init and reset.

### TrackingEyeDB (account-wide)

| Field              | Type     | Default | Purpose                                                            |
| ------------------ | -------- | ------- | ------------------------------------------------------------------ |
| `minimap`          | table    | `{}`    | LibDBIcon position payload (`hide`, `minimapPos`, …).             |
| `freePlacement`    | boolean  | `false` | Free Placement Mode toggle.                                        |
| `freeIconScale`    | number   | `1.1`   | Free-placement icon scale (0.25–3.0).                              |
| `freeIconShape`    | string   | `"circle"` | `"circle"` or `"square"`.                                       |
| `showWelcome`      | boolean  | `true`  | Print the one-line login chat message.                            |
| `freePos`          | table \| nil | *(unset)* | `{x, y}` free-frame center in absolute screen pixels. Written only once the user drags; legacy array shape migrated on load. |
| `resetGeneration`  | number   | *(unset)* | Bumped by the Reset action so all alts wipe on next login.       |

### Migration Chain

All migrations run inside `ADDON_LOADED` (per-character) or `ApplyFreePosition` (position), before the default backfill:

1. **Cross-character reset propagation** — if this character's `resetGeneration` is behind the account-wide value, `wipe(TrackingEyeCharDB)` and sync the marker.
2. **Legacy per-character field rename** — `autoTracking → persistentTracking`, `farmingMode → farmMode`. Copies the old value when the new key is nil (so a disabled feature stays disabled), then clears the old key. *Scheduled for removal after 2026-09-17.*
3. **Deprecated key cleanup** — `TrackingEyeCharDB.lastCastSpell = nil`. This field is now runtime-only and must never be persisted (see the pitfall below). *Scheduled for removal after 2026-09-17.*
4. **`freePos` array → `{x, y}`** — the legacy `{point, relativePoint, xOffset, yOffset}` shape is applied once, re-read as screen-pixel center, and overwritten in the new format ([Features/Minimap-Button.lua](Features/Minimap-Button.lua)).

The default backfill loops run *after* migrations; they only fill `nil` fields and never override explicit user values. `farmCycleSpells` is seeded (deep-copied from `ns.FARM_CYCLE_DEFAULTS`) only when the whole table is absent.

### Cross-Character Reset Propagation

The Reset action ([Options/Options-General.lua](Options/Options-General.lua)) bumps `TrackingEyeDB.resetGeneration` and syncs the current character's `resetGeneration` to match. On every other character's next `ADDON_LOADED`, the per-character DB is wiped because its `resetGeneration` is behind the account-wide value. This lets one Reset clear every alt without visiting each manually. Both fields are internal — do not surface them in options or treat them as user-facing. The reset deliberately preserves `TrackingEyeDB.minimap` (LibDBIcon's payload, holding the button position and the hide preference) and clears `freePos` so the free icon snaps back to center.

## Adding a New Tracking Spell

1. Add a row to `SPELL_DATA` in [Data/Data.lua](Data/Data.lua) under the appropriate source (`{spellId, key, source}`). The constructor populates `ns.SPELLS`, `ns.TRACKING_IDS`, and `ns.TRACKING_SET` automatically; form spells (listed in `FORM_KEYS`) are excluded from the tracking sets.
2. If the spell should be on by default in Farm Mode, add it to `ns.FARM_CYCLE_DEFAULTS` in [Data/Default-Settings.lua](Data/Default-Settings.lua).
3. If the spell has special form gating (like Druid Track Humanoids), add a guard in `ns.CastTracking` ([Features/Core.lua](Features/Core.lua)), exclude it from `cachedCycle` in `BuildCycleCache` ([Features/Farm-Mode.lua](Features/Farm-Mode.lua)), and exclude it from the Farm Mode Abilities list in `BuildFarmAbilityArgs` ([Options/Options-General.lua](Options/Options-General.lua)).
4. No new locale strings are needed — the spell name and icon come from `GetSpellInfo` / `GetSpellTexture` at runtime, so they localize automatically. Only add a locale key if you also need a custom label or description.
5. Verify the menu and options correctly hide the spell on characters that don't know it. The `IsPlayerSpell(id)` checks inside `BuildFarmAbilityArgs`'s `hidden` and inside `Tracking-Menu.lua`'s row loop are what gate visibility.

## Adding a New Locale

Copy `Locales/enUS.lua` to `Locales/<locale>.lua`. Drop the `true` argument from the `NewLocale("TrackingEye", "<locale>", true)` call — that flag marks the file as the default fallback, and only `enUS.lua` should set it. Translate every string. Add the file to [TrackingEye.toc](TrackingEye.toc) immediately after `Locales/enUS.lua`.

Do **not** translate the Diagnostics strings — they live in `ns.DiagnosticsStrings` ([Features/Diagnostics.lua](Features/Diagnostics.lua)), are developer-facing, and are intentionally English-only.

The existing Spanish locales (`esES.lua` and `esMX.lua`) are independent files; each registers its own `NewLocale` and translates every string in isolation. If you ever consolidate them, follow the shared-`strings`-table pattern from sibling addons: build one local table at the top, register both locales from it, and guard each `if L` block independently so the `if not L then return end` early-out from the first locale doesn't prevent the second from registering.

## Common Pitfalls

- **Trusting `GetTrackingTexture` / `MINIMAP_UPDATE_TRACKING` as live state** — On Classic Era 1.15.x the tracking mirror lags reality, sometimes by minutes, and `nil` doubles as the normal "no tracking active" value. Comparing against it (or bailing on `nil`) silently disabled Farm Mode and Persistent Tracking on Era. Compare against `ns.state.lastCastSpell` instead, and treat the mirror as a positive signal only. The login-recast bug is prevented by the time-based grace window (`LOGIN_GRACE_SECONDS`) in `TryRecastPersistent` — never by a `nil` bail.
- **Adding a second reader of the tracking mirror** — `ns.UpdateIcon` and all cast logic funnel through the single `ns.GetActiveTrackingSpell()`. Reading `MiniMapTrackingIcon` or `GetTrackingTexture()` directly anywhere else resurrects cleared tracking icons and re-poisons `lastCastSpell` through the adoption branch. Every past icon bug on Era came from a second reader with slightly different rules.
- **Persisting `ns.state.lastCastSpell`** — It is runtime-only, written solely by `UNIT_SPELLCAST_SUCCEEDED` via `ns.SetLastCast`. A value carried over from last session makes the farm cycle and persistent recast believe tracking is already up at login and skip every real cast. `ADDON_LOADED` actively clears any stored `lastCastSpell`.
- **Casting tracking during the GCD after shapeshift** — Mitigated by `C_Timer.After(1.5, TryRecastPersistent)` on `UPDATE_SHAPESHIFT_FORM`. Removing the delay causes silent cast failures because the shapeshift GCD hasn't elapsed.
- **Swallowing a temporary bail in `TryRecastPersistent`** — In-combat, on-cooldown, and debounce bails must `ScheduleRecast`, not `return` outright. On Era no further tracking event may fire, so a dropped trigger stops persistent tracking until the next login.
- **Adding Druid Track Humanoids to the farm cycle** — Excluded on purpose (requires Cat Form, mutually exclusive with travel forms). Re-adding it queues casts that always fail. Guarded in three places plus the menu.
- **Naming the free-placement frame** — Re-introduces the `layout-local.txt` lookup the anonymous-frame fix avoids; a cached per-character position silently overrides `TrackingEyeDB.freePos`. Keep the constructor's first arg `nil`.
- **Reading `GetPoint()` to serialize the free-frame position** — `StartMoving` / `StopMovingOrSizing` leave the frame on a non-canonical anchor; saving it causes drift on the next Show or scale change. Always round-trip through `SaveFreePosition` / `ApplyFreePosition`.
- **Skipping `SetUserPlaced(false)` after a position apply** — A leftover user-placed flag lets WoW write a layout-local entry on logout that out-races our SavedVariables on next login.
- **Using `IsShown()` instead of `IsVisible()` for the options-open flag** — The Settings canvas keeps its own shown flag set when the parent window closes, so `IsShown()` latches `ns.optionsOpen` true forever and pauses Farm Mode permanently. `InitOptions` uses `IsVisible()` on purpose.
- **Localizing Diagnostics strings** — They belong only in `ns.DiagnosticsStrings`, never in `Locales/`. Translating developer-facing troubleshooting text is wasted effort.
- **Touching `TrackingEyeCharDB` or `TrackingEyeDB` at file scope** — SavedVariables aren't populated until `ADDON_LOADED`; reading earlier returns `nil` and writing wipes user data.
- **Renaming an existing SavedVariables field without a migration** — Default backfill only fills `nil` fields. A rename leaves both keys present; add a tagged migration in `ADDON_LOADED` (with a removal date) that moves the value.
- **Forgetting to bump `resetGeneration` on a reset that should propagate** — Without the bump, alts keep their old settings forever. Don't add a "soft reset" path that skips it.

## Contributing

- **Issues:** open them at [github.com/Gogo1951/Tracking-Eye/issues](https://github.com/Gogo1951/Tracking-Eye/issues). For bug reports include: game version (Classic Era / Anniversary / etc.), client locale, character class and level, exact reproduction steps, and any chat output or error text. The Diagnostic Tools panel (`/te` → Diagnostic Tools) produces copy-paste reports that carry most of this automatically.
- **Discord:** [discord.gg/eh8hKq992Q](https://discord.gg/eh8hKq992Q) for discussion, screenshots, and quick questions.
- **Pull requests:**
  - Keep scope tight — one feature or fix per PR.
  - Follow the style guide. No alignment padding around `=`, no `##` for in-file section headers, no hardcoded user-facing strings (every player-visible string belongs in `Locales/enUS.lua`; Diagnostics strings are the deliberate English-only exception).
  - Respect the Persistent Tracking and icon-resolution guards — read the *Persistent Tracking Deep Dive* and *Icon Resolution* sections before touching those code paths.
  - When the architecture or file map changes, update this document in the same PR.

### Commit and PR descriptions require a User Story

Don't just say "I changed X" or "I fixed Y." Frame the change in terms of who it helps and why.

**Format:** *As a [role], I [needed / wanted] [behavior] so that [outcome]. This change [does X].*

**Example:** *As a druid who shapeshifts between Travel Form and caster form during a farming run, I wanted Tracking Eye to recast my saved tracking spell after the shapeshift instead of leaving me with no tracking buff. This change schedules a `TryRecastPersistent()` 1.5 seconds after `UPDATE_SHAPESHIFT_FORM` so the post-shift GCD has elapsed before the cast fires.*

The User Story makes review faster and gives future maintainers context the diff alone won't carry.
