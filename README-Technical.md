# Tracking Eye — Technical Reference

This document combines architecture notes and contribution guidance for developers working on Tracking Eye. For end-user documentation, see [README.md](https://github.com/Gogo1951/Tracking-Eye/blob/main/README.md).

## File Map

```text
TrackingEye/
  TrackingEye.toc              TOC manifest — interface versions, metadata, SavedVariables, load order
  README.md                    End-user documentation
  README-Technical.md          This file
  Bindings.xml                 Key binding definition (auto-discovered from the root; never listed in the TOC)

  Data/
    Data.lua                   AceLocale handle, constants, spell table, farm-state IDs, restricted maps, raw color palette
    Default-Settings.lua       DATABASE_DEFAULTS (AceDB profile + global), FARM_CYCLE_DEFAULTS

  Features/
    Core.lua                   State, SetLastCast, UpdateIcon, ClearTracking, CastTracking, TryRecastPersistent, ApplyProfile, event dispatcher
    Utilities.lua              GetColor, GetPlayerStates, GetActiveTrackingSpell, CanCast, GetFarmPauseReason, cycle-sound mute, HasTrackingAbility, IsPlayerClass, IsRestrictedZone
    Announcements.lua          ns:PrintMessage — the only chat output; prints to the player, never sends
    Farm-Mode.lua              Farm cycle cache, ticker management, RunFarmLogic decision chain, AdvanceFarmCycle + key binding
    Target-Tracking.lua        Creature-type tracking switch, combat deferral, revert to the persistent ability
    Tracking-Menu.lua          LibUIDropDownMenu spell picker
    Diagnostics.lua            Read-only diagnostic reports and event log (developer troubleshooting)
    Minimap-Button.lua         LibDataBroker launcher, LibDBIcon, anonymous free-placement frame, tooltip, OnClick

  Options/
    Options-Utilities.lua       OptionsHeader / OptionsDesc / OptionsSpacer / OptionsRowLabel widget helpers, OptionsSubRow / OptionsSubLabel sub-option builders
    Options-General.lua         BuildGeneralOptions — root panel; composes the two fragments below into its args
    Options-Target-Tracking.lua BuildTargetTrackingOptions — Target Tracking settings fragment
    Options-Farm-Mode.lua       BuildFarmModeOptions + BuildFarmAbilityArgs — the Farm Mode child panel
    Options-Free-Placement.lua  BuildFreePlacementOptions — Free Placement settings fragment
    Options-Profiles.lua        BuildProfilesOptions — the stock AceDBOptions-3.0 profiles table
    Options-Diagnostics.lua     BuildDiagnosticsOptions — the gated Diagnostic Tools panel
    Options.lua                 RegisterOptionsPanels, OpenOptionsPanel, IsOptionsPanelOpen, /te slash command

  Locales/
    enUS.lua                   Source-of-truth locale (sets the AceLocale `true` default flag)
    deDE.lua … zhTW.lua        Translations (fall back to enUS via AceLocale)

  Includes/
    Images/Tracking-Eye.tga    Addon icon (referenced from the TOC IconTexture)
    Libraries/                 Vendored libs: LibStub, CallbackHandler-1.0, Ace3 (AceLocale/AceDB/AceDBOptions/AceGUI/AceConfig),
                               LibDataBroker-1.1, LibDBIcon-1.0, LibUIDropDownMenu
```

Files load in TOC order: `Includes/` → `Locales/` → `Data/` → `Features/` → `Options/`. Order matters. `Data/Data.lua` populates the shared namespace (spell tables, constants, palette) and `Data/Default-Settings.lua` adds the default tables before any feature reads them; `Features/Core.lua` defines the event dispatcher and `Features/Utilities.lua` the game-state predicates that the later files call at runtime.

## Architecture

### Shared Namespace

Every Lua file receives `(addonName, ns)` via the `...` vararg. The `ns` table is the addon's shared namespace — all public functions, constants, and state live on it. There are no global functions; everything hangs off `ns`. The only globals are the `TrackingEyeDB` SavedVariables table, the WoW-mandated `SLASH_*` / `SlashCmdList` entries, and the two the key binding requires (see *Key Bindings*). `TrackingEyeDB` is owned by **AceDB-3.0** — the addon reads it through `ns.db`, never directly.

Because features are split across files that load in a fixed order, a file may *define* a function the earlier-loaded files *call* — that is safe as long as the call happens at runtime, not at file scope. `Core.lua` loads before `Utilities.lua` yet calls `ns.GetPlayerStates` and `ns.GetColor`; this works because those calls only ever fire from event handlers and timers, long after every file has loaded.

### Event Loop

`Core.lua` registers a single hidden frame (`eventFrame`) and routes every event through one `OnEvent` handler. The registered event list lives in `ns.EVENT_NAMES` — a single source of truth that the Diagnostics *Event Registration* check reads back, so the two can never drift. `UNIT_SPELLCAST_SUCCEEDED` is registered with `RegisterUnitEvent(..., "player")` so the dispatcher is never woken for other units' casts.

Every event first passes through `ns:LogEvent` when the diagnostics event log is active (see *Diagnostics*). Initialization then happens in two passes:

- `ADDON_LOADED` (when `arg1 == addonName`) creates the AceDB database (`ns.db = LibStub("AceDB-3.0"):New("TrackingEyeDB", ns.DATABASE_DEFAULTS)` — no third argument, so each character gets its own profile), registers `ns:ApplyProfile` against the `OnProfileChanged` / `OnProfileCopied` / `OnProfileReset` callbacks, calls `ns.RegisterOptionsPanels()` (it must follow `AceDB:New`, since the Profiles builder reads `ns.db`), calls `ns.CreateFreeFrame()`, and runs the first `ns.UpdateIcon()`.
- `PLAYER_LOGIN` calls `ns.InitMinimap()`, `ns.InitFarmMode()`, refreshes the icon, starts `PollUntilTrackingReady()`, and prints the welcome message (gated by `ns.db.profile.showWelcome`).

Steady-state events:

- `UNIT_SPELLCAST_SUCCEEDED` (player) — if the cast spell ID is in `ns.TRACKING_SET`, call `ns.SetLastCast(spellId)` and refresh the icon. This is the **only** writer of `ns.state.lastCastSpell`.
- `MINIMAP_UPDATE_TRACKING` — refresh the icon, run `FlushIconAfterTrackingChange()`, then `C_Timer.After(2, TryRecastPersistent)`. Tracking changed or was cancelled outside the addon; this is the trigger that re-applies a cancelled persistent spell. Safe to fire from our own casts — the function's grace window and debounce absorb the echo.
- `ZONE_CHANGED_NEW_AREA` — refresh the icon.
- `PLAYER_ENTERING_WORLD`, `SPELLS_CHANGED` — refresh the icon, then `ns.UpdatePlacement()` and `ns.InvalidateFarmCache()`. `PLAYER_ENTERING_WORLD` also records `ns.state.enteredWorldAt` (anchors the recast grace window) and schedules the **login catch-up**: one `TryRecastPersistent()` call at grace-expiry (+11s). Without it, a player who logs in with tracking down stays that way — on Era no tracking event may ever fire to provide a trigger. If tracking survived logout, the positive-mirror check inside `TryRecastPersistent` skips the cast.
- `UPDATE_SHAPESHIFT_FORM` — refresh the icon, then `C_Timer.After(1.5, TryRecastPersistent)`.
- `PLAYER_UNGHOST` and `PLAYER_ALIVE` — both call `RecastAfterResurrection()`, which recasts the saved tracking spell directly after 1.5s (bypasses `TryRecastPersistent`; the server always clears tracking on resurrection). `PLAYER_UNGHOST` covers a corpse run; `PLAYER_ALIVE` covers an in-place rez (healer, soulstone). A corpse-run return fires both, so a `resurrectRecastPending` flag coalesces them into one recast, and the delayed callback bails while still dead/ghost (`PLAYER_ALIVE` also fires when releasing spirit).
- `PLAYER_UPDATE_RESTING` — call `ns.RunFarmLogic()` immediately so Farm Mode stops the instant the resting flag is set (entering a city/inn) and resumes the instant it clears, instead of waiting up to a full ticker interval. The resting flag itself can lag zone entry by several seconds — that latency is the client's, not the ticker's.
- `PLAYER_LOGOUT` — call `ns.SaveFreeFramePosition()` so the free-placement frame's live position is captured before WoW serializes SavedVariables (a backstop in addition to the `OnDragStop` save).
- `PLAYER_TARGET_CHANGED` — call `ns.HandleTargetChanged()` (see *Target Tracking Deep Dive*).
- `PLAYER_REGEN_ENABLED` — call `ns.HandleRegenEnabled()`, which applies a switch that was requested while the player was in combat.
- `LOOT_OPENED` and `LOOT_CLOSED` — set and clear `ns.state.lootWindowOpen`, the flag `ns.CanCast()` reads. The events are the source of truth rather than `LootFrame:IsShown()`: Speedy-Loot-style add-ons hide that frame while looting is still open, so a frame read would report "no loot window" during exactly the window that needs guarding.

### Combat Lockdown

One path is combat-gated: `ns:OpenOptionsPanel` ([Options/Options.lua](Options/Options.lua)) checks `InCombatLockdown()` before anything else and refuses with a printed `CHAT_OPTIONS_IN_COMBAT` notice. Blizzard's Settings panel is protected in combat, and without that gate `/te` or Shift + Middle-Click hands the player an `ADDON_ACTION_BLOCKED` error naming Tracking Eye. The gate returns — it never queues the open for later — and it is the single call site of that locale key.

Nothing else defers for combat. None of the add-on's other writes touch protected frames or secure templates: the LibDataBroker launcher, the LibDBIcon minimap button, the free-placement `Button`, and the AceConfig options panels are all unsecure. Spell casts go through `pcall(CastSpellByID, …)` and fail harmlessly if blocked, and `ns.CanCast()` already refuses to fire while `UnitAffectingCombat("player")` is true. If a future feature needs to drive secure UI, introduce an `InCombatLockdown()`-gated dirty flag and replay deferred work on `PLAYER_REGEN_ENABLED`.

### Icon Resolution

`ns.UpdateIcon()` ([Features/Core.lua](Features/Core.lua)) is the single place that decides which texture the launcher and free frame display. It resolves through one authoritative reader — `ns.GetActiveTrackingSpell()` — and never reads `MiniMapTrackingIcon` or `GetTrackingTexture()` directly. Every past icon bug on Era came from a second reader of the tracking mirror with slightly different rules.

1. `ns.GetPlayerStates()` — if the player has left Cat Form and `lastCastSpell` still holds `DRUID_HUMANOIDS`, clear it.
2. `activeSpell = ns.GetActiveTrackingSpell()` — the live tracking spell (Blizzard minimap icon while visible, `GetTrackingTexture()` as fallback; see [Features/Utilities.lua](Features/Utilities.lua)).
3. **Adopt** pre-session tracking: if `activeSpell` is set and `ns.state.lastCastSpell` is nil, adopt it via `ns.SetLastCast(activeSpell)` — but only while the session has no confirmed cast, since in-session casts already own `lastCastSpell` and the Era mirror lags them.
4. **Latch** `mirrorConfirmedCast`: once the mirror positively reports our own `lastCastSpell`, it has caught up, so a later nil reading is a genuine external cancel rather than lag.
5. Choose the icon spell: `activeSpell` if present; otherwise, for a few seconds after our own confirmed cast (`ICON_IN_FLIGHT_SECONDS`, and only until `mirrorConfirmedCast` latches), show `lastCastSpell` while the laggy Blizzard icon catches up. **There is no fallback to the selected or persisted spell** — every such fallback produced a stale icon (e.g. showing last session's spell at login with nothing actually up). Nothing tracked means `ns.ICON_DEFAULT` (`Interface\Icons\inv_misc_map_01`).

The resolved texture is written to `ns.state.currentIcon`, `ns.ldb.icon`, and the free frame's icon texture; `ns.RefreshTooltip()` then updates any tooltip already on-screen.

`UpdateIcon` also resolves `ns.GetFarmPauseReason()` into `ns.state.farmPauseReason` and dims the icon whenever it is non-nil — `ns.ICON_PAUSED_TINT` (0.45) into `ns.ldb.iconR/G/B` for the launcher, and `SetDesaturated` plus the same tint on the free frame. The tint is always written as a **number, never nil**: LibDBIcon passes `iconR/G/B` straight into `SetVertexColor`, which errors on a nil component, so the un-dimmed state is an explicit `1`.

`ns.GetActiveTrackingSpell()` reads the global `MiniMapTrackingIcon` **only while it is visible** and matches its texture back to a known tracking ID; a hidden frame retains a stale texture, and on the Vanilla client the frame is hidden entirely when nothing is tracked. It falls back to `GetTrackingTexture()` for clients (TBC+) that show a generic "None" texture instead. The read degrades safely if the frame is ever absent — a nil frame yields no match and resolution falls through.

The texture → spellId lookup is a lazily built reverse cache (`BuildTextureCache` in [Features/Utilities.lua](Features/Utilities.lua)), avoiding a linear `GetSpellTexture` scan on every call. During the login event storm `GetSpellTexture` returns nil for spells whose data hasn't loaded, so a cache built then is missing entries and has to be rebuilt once more data arrives.

**Rebuilds are driven by a dirty flag, never by testing whether every ID resolved.** Find Fish (43308) does not exist in the Era client at all, so "every ID resolved" is unreachable there: a completeness test stays false forever and rebuilds the whole table on every lookup miss — which is most of them, since a miss is what happens whenever nothing is tracked. `SPELLS_CHANGED` and `PLAYER_ENTERING_WORLD` are the only points where new spell data can appear, so they call `ns.InvalidateTextureCache()` and the next lookup rebuilds exactly once.

Two supporting pollers in `Core.lua` shave latency without ever making the mirror fresher:

- `PollUntilTrackingReady()` runs once at `PLAYER_LOGIN`, retrying every second (up to 15×) until `MiniMapTrackingIcon` has a texture, then refreshes the icon once. During the login event storm the icon may not have its texture set yet and `MINIMAP_UPDATE_TRACKING` may never fire, so without this the icon can stay stuck on default until the user toggles something.
- `FlushIconAfterTrackingChange()` re-runs `UpdateIcon` up to 8 times over ~2s after a tracking change, catching the Era mirror the moment it flushes. Both pollers are coalesced so bursts of events cannot stack overlapping timers.

## Persistent Tracking Deep Dive

`TryRecastPersistent()` ([Features/Core.lua](Features/Core.lua)) handles mid-play recasts. It runs 1.5 seconds after `UPDATE_SHAPESHIFT_FORM`, 2 seconds after `MINIMAP_UPDATE_TRACKING`, and once at login-grace expiry after `PLAYER_ENTERING_WORLD` (the catch-up). The bail chain, in order:

- `ns.db` not yet created, `persistentTracking` off, or `selectedSpellId` not set → stop.
- The player is in a farm state → stop; Farm Mode owns the cast.
- `IsPlayerSpell(spellId)` is false (the saved spell was unlearned) → stop.
- Less than `LOGIN_GRACE_SECONDS` (10) since `PLAYER_ENTERING_WORLD` → stop; the login/reload window. The `PLAYER_ENTERING_WORLD` catch-up re-fires after the window, so nothing is lost.
- `ns.GetActiveTrackingSpell()` returns the selected spell (provably active) → sync `lastCastSpell`, re-latch `mirrorConfirmedCast`, and stop. This is what terminates the retry chain after a successful recast.
- Our own cast of this spell is still in flight (`lastCastSpell == spellId` and less than `ns.CAST_IN_FLIGHT_SECONDS` (10) since the attempt) → **reschedule** and re-check. Without this, the constant `UPDATE_SHAPESHIFT_FORM` stream from a hunter's aspects drives a redundant recast every ~5s until the mirror flushes — the "casting it three times" symptom.
- `ns.CanCast()` is false (dead/ghost, stealthed, mid-cast, in combat, a loot window open, or something on the cursor) → **reschedule** via `ScheduleRecast(RECAST_DEBOUNCE_SECONDS)`.
- On cooldown or GCD → **reschedule**.
- Less than `RECAST_DEBOUNCE_SECONDS` (5) since the last cast attempt (the `MINIMAP_UPDATE_TRACKING` echo of our own cast) → **reschedule**.
- Otherwise recast.

Temporary bails **retry**, never swallow: on Era the client may fire no further tracking event ever, so a swallowed trigger (the user cancels tracking twice within the debounce) used to kill persistent tracking until the next login. `ScheduleRecast` coalesces retries behind a `recastRetryPending` flag so bursts cannot stack timers.

Two client facts shape this design:

1. **The login blackout.** During the Classic login/reload event storm the tracking API is unresponsive for ten or more seconds and `GetTrackingTexture()` returns `nil`; we cannot tell whether the saved spell is already active. Casting blindly in that window caused the historical login-recast bug. Solved by the **time-based grace window**, not by interpreting `nil`.
2. **The Era stale mirror.** On the Vanilla-based client (Classic Era 1.15.x, since ~1.15.1) the tracking mirror — `GetTrackingTexture()` and `MINIMAP_UPDATE_TRACKING` — lags the real state, sometimes by minutes; it only flushes when an unrelated buff update fires. `nil` is also that client's normal steady-state value for "no tracking active." An earlier version that bailed whenever `GetTrackingTexture()` was `nil` permanently blocked recasts on Era — the guard matched the exact state that needed fixing. **Do not reintroduce a nil bail.** Treat the mirror as a **positive signal only** ("provably active → skip") and let everything else fall through to a recast; recasting an already-active tracking spell is a harmless refresh.

Resurrection does **not** route through `TryRecastPersistent`. After a rez the server has genuinely cleared the player's tracking buff, so a recast is always needed. Both `PLAYER_UNGHOST` (returning to a corpse after a spirit run) and `PLAYER_ALIVE` (an in-place resurrection — healer rez, soulstone, or a graveyard port) call the shared `RecastAfterResurrection()`, which skips the comparison logic and casts directly after a 1.5-second delay (letting the GCD and post-resurrection scripts settle). It still honors the `persistentTracking` / `selectedSpellId` / `isFarming` guards. Two details make it robust: a corpse-run return fires **both** events, so a `resurrectRecastPending` flag coalesces them into a single recast; and because `PLAYER_ALIVE` also fires the instant the player releases spirit and becomes a ghost, the delayed callback bails when `UnitIsDeadOrGhost("player")` is still true so it never casts into a corpse (the real resurrection fires the event again).

`ns.CastTracking(spellId)` is the shared cast primitive. It validates `IsPlayerSpell`, gates Druid Track Humanoids on Cat Form, treats an active GCD/cooldown as "skip," records `ns.state.lastTrackingCastAt`, and `pcall`s `CastSpellByID`. It deliberately does **not** write `ns.state.lastCastSpell` — only `UNIT_SPELLCAST_SUCCEEDED` does, so a silent failure (LOS, range, server reject) never poisons the bookkeeping that the farm cycle and recast logic compare against.

## Farm Mode Deep Dive

`ns.RunFarmLogic()` ([Features/Farm-Mode.lua](Features/Farm-Mode.lua)) runs on a `C_Timer.NewTicker` (default 3.5s, configurable 2–10s via `ns.db.profile.farmInterval`) and also on demand from the `PLAYER_UPDATE_RESTING` handler. The decision chain:

1. Refresh the paused icon when `ns.GetFarmPauseReason()` differs from `ns.state.farmPauseReason` (see *Pause Reporting*). This sits **above every bail** so the dim state stays honest even on ticks that do nothing else.
2. Bail if the options panel is visible (`ns.IsOptionsPanelOpen()`).
3. Bail if `ns.db.profile.farmMode` is off.
4. Read `ns.GetPlayerStates()`. If the player just left farm state (`not inForm and ns.state.wasFarming`), clear `wasFarming` and recast the persistent tracking spell unless it is provably active or our own cast is still in flight. This runs **before** the restricted-zone gate, so a player who unmounts inside an instance or a city still gets their persistent spell back.
5. Bail in restricted zones (`ns.IsRestrictedZone()`).
6. Bail if not in farm state or `ns.CanCast()` is false.
7. Lazily rebuild `cachedCycle` if nil. Bail when empty.
8. Single-entry shortcut: when `#cachedCycle == 1`, idle only while the spell is provably active (`ns.GetActiveTrackingSpell()`) or our own cast is still in flight (`ns.CAST_IN_FLIGHT_SECONDS` since the last attempt, covering icon lag); anything else — including tracking cancelled outside the addon — recasts. Mark `wasFarming = true` and bail.
9. Advance the cycle via `ns.AdvanceFarmCycle()`. Mark `wasFarming = true`.

`ns.CanCast()` ([Features/Utilities.lua](Features/Utilities.lua)) is the shared gate for every **automatic** cast — the farm cycle, the persistent recast, and the manual cycle-advance binding. It refuses while the player is dead or a ghost, stealthed, mid-cast, in combat, while a loot window is open (`ns.state.lootWindowOpen`), or while `GetCursorInfo()` reports something on the cursor. The last two are not about wasting a GCD: in Classic a spell cast closes an open loot window, so a cycle tick landing mid-loot can cost the player the node they just gathered, and a cast fired while an item or spell is held on the cursor discards it. `ns.CastTracking` itself is deliberately **not** gated — the tracking menu is a deliberate player click and must always cast. Every condition is momentary and every caller retries, so nothing is ever swallowed.

Farm logic never reads `GetTrackingTexture()` directly. The multi-spell cycle compares against `ns.state.lastCastSpell` — written only from `UNIT_SPELLCAST_SUCCEEDED`, reliable on every supported client — and the single-spell shortcut additionally consults `ns.GetActiveTrackingSpell()` (Blizzard icon first) so an external cancel is noticed and re-cast. These comparisons exist only to avoid burning a GCD on a no-op recast.

### Farm-State Detection

`ns.GetPlayerStates()` ([Features/Utilities.lua](Features/Utilities.lua)) returns `(isCat, isFarming, movementState)`. It scans up to 40 player buffs once and classifies the current movement state, then maps that state to the matching per-state toggle:

| Movement state | Detected by | Per-state toggle | Class gate (options) |
| --- | --- | --- | --- |
| On a taxi | `UnitOnTaxi` | *(always `false, false`)* | — |
| Mounted (out of combat) | `IsMounted` | `farmMounted` | all |
| Travel / Aquatic / Flight / Swift Flight form | buff IDs in `ns.FARM_FORMS` | `farmTravelForms` | `DRUID` |
| Aspect of the Cheetah / Pack | buff IDs in `ns.CHEETAH_BUFFS` | `farmCheetah` | `HUNTER` |
| Ghost Wolf | buff ID `ns.GHOST_WOLF` | `farmGhostWolf` | `SHAMAN` |
| On foot (none of the above) | fallthrough | `farmNotMounted` (off by default) | all |

`isFarming` is true only when the master `farmMode` toggle is on **and** the current state's toggle is enabled. States are mutually exclusive in practice (mounting cancels forms and aspects), so the checks are ordered mounted → travel form → cheetah → ghost wolf → on-foot. The class gates live only in the options UI (`ns.IsPlayerClass`, [Options/Options-Farm-Mode.lua](Options/Options-Farm-Mode.lua)) so a low-level character can pre-configure a toggle before learning the ability; detection itself is class-agnostic.

`isCat` is reported separately because Cat Form is not a farm state — it gates Druid Track Humanoids, which is mutually exclusive with the travel forms that put the player into farm state (see below).

The scan sits behind a **frame-scoped memo** keyed on `GetTime()`, which is constant for the whole frame, so a cached answer can never come from a previous frame. `ns.UpdateIcon` and `ns.RunFarmLogic` each derive these states twice in one pass — directly, and again through `ns.GetFarmPauseReason` — and `FlushIconAfterTrackingChange` runs `UpdateIcon` eight times in about two seconds. Two bypasses are deliberate: while `ns.db` is nil the result is recomputed and never stamped, since `isFarming` reads the profile and the database appears mid-frame during `ADDON_LOADED`; and `ns:ApplyProfile` calls `ns.InvalidatePlayerStates()` first, since a profile switch rewrites the per-state toggles `isFarming` is derived from.

### Cycle Sound Mute

`ns.db.profile.muteCycleSound` (default `true`) silences the sound of Farm Mode's **own** automatic casts. Every automatic cast in [Features/Farm-Mode.lua](Features/Farm-Mode.lua) routes through one file-local seam, `CastCycleSpell(spellId)`; the tracking menu, `TryRecastPersistent`, and `RecastAfterResurrection` all call `ns.CastTracking` directly and keep their sound.

**Why a CVar and not `MuteSoundFile`.** The tracking spells' cast audio is played by the engine from the spell's own SoundKit and never passes through `PlaySound` or `PlaySoundFile`, so no FileDataID is reachable from Lua and `MuteSoundFile` has nothing to take. Switching `Sound_EnableSFX` off is the only lever available.

**The window is the whole trick.** The audio does *not* fire inside `CastSpellByID` — it fires when the server confirms the cast, a round trip later — so muting and restoring around the call silences nothing. The mute is held until `UNIT_SPELLCAST_SUCCEEDED` reports our spell (`ns.NotifyTrackingCastSucceeded`, the usual path, typically well under 200ms) and lifted a short tail after that, with `ns.CYCLE_MUTE_SECONDS` as the ceiling for a cast the server never confirms. Restores are generation-stamped so overlapping casts cannot restore each other early.

This is a **write to a game-wide user CVar for a convenience**, which WRITING USER CVARS otherwise forbids, and it carries no `PrintMessage` because a notice on every cycle tick would be unusable. That departure needs a matching entry in `References/Exceptions.md`. Four safeguards make it safe to ship:

- **The mute is armed only after a cast was actually attempted.** `ns.CastTracking` returns `true` when it reached `CastSpellByID` and `false` on each early bail (spell unknown, Cat Form gate, cooldown or GCD), and `CastCycleSpell` casts first and arms second. Arming afterwards is safe precisely because the audio plays on server confirmation, not inside the call.
- **`ns.RestoreCycleSoundNow()` restores unconditionally on teardown**, called from the `PLAYER_LOGOUT` handler in `Features/Core.lua` (which covers `/reload` as well as logout) and from the `muteCycleSound` toggle's `set` handler when the player switches the option off. `Sound_EnableSFX` persists across sessions, so a mute whose timer died with the UI would otherwise leave the player with sound effects off and nothing to connect it to.
- **The cast is wrapped in `pcall`**, so an error inside `ns.CastTracking` can never skip the restore and strand the player with sound switched off.
- **The CVar is only written when it is not already `"0"`.** A player who plays with sound effects off is never written to, and the restore puts back the exact string that was read.

The trade-off worth knowing: the toggle silences *all* sound effects for that instant, not just the tracking cast, so a sound already playing can be clipped. At a 3.5-second cycle this is rarely audible, which is why the option ships on: the repeated cast sound is noise the add-on itself creates, and the player never asked for those casts.

### Pause Reporting

Farm Mode goes quiet for several reasons the player cannot see, which is the most common "is it broken?" report. `ns.GetFarmPauseReason()` ([Features/Utilities.lua](Features/Utilities.lua)) answers that in one place, returning a locale key or nil: `FARM_PAUSED_TAXI` (`UnitOnTaxi`), `FARM_PAUSED_INSTANCE` (an instance or a `ns.RESTRICTED_MAP_IDS` map), `FARM_PAUSED_RESTING` (`IsResting`), or `FARM_PAUSED_NO_ABILITIES` (`ns.GetFarmCycleCount()` is zero). It returns nil when Farm Mode is switched off — that is not a pause, and the tooltip already reports Disabled — and combat is deliberately **not** a reason, since it is brief enough that reporting it would only flicker the icon.

`ns.IsRestrictedZone()` and `ns.GetFarmPauseReason()` share one file-local `GetRestrictedKind()` helper, so the yes/no gate and the reason string can never disagree about what counts as restricted.

Two of the transient reasons are Farm Mode's own gates rather than `ns.CanCast()` conditions, so they stop the cycle without touching the manual key binding or the persistent recast: `ns.IsOptionsPanelOpen()` and `ns.IsTooltipShowing()`. The tooltip check deliberately excludes the add-on's own tooltip — the mini-map button and the free frame both draw into `GameTooltip`, and counting them would make the status block report "paused" every time the player hovered the icon to read it. `ns.minimapButton` is stored in `ns.InitMinimap` purely so that owner comparison can be made.

The reason drives two surfaces: the dimmed icon (see *Icon Resolution*) and a `Paused // <reason>` line in the mini-map tooltip. Because several of these conditions fire no registered event — a taxi flight above all — `ns.RunFarmLogic()` re-resolves the reason on every tick **before its own bails** and calls `ns.UpdateIcon()` only when the value changed.

### Farm Cycle Cache

`BuildCycleCache()` also appends `ns.db.profile.selectedSpellId` when `farmIncludePersistent` is on, guarded by a membership set so an ability that is both the persistent pick *and* ticked in the list appears **once** — queued twice it would take double the airtime of everything else. Because the cycle now depends on `selectedSpellId`, every writer of that key invalidates the cache: the tracking menu's `info.func` and `ns.ClearTracking()`.

`ns.GetFarmCycleCount()` is the only reader of the cache's size outside this file — it builds the cache when nil and returns `#cachedCycle`, so nothing else needs to know the cache exists. `BuildCycleCache()` builds a sorted, IDs-only array `cachedCycle` from every enabled entry in `ns.db.profile.farmCycleSpells`. It drops `ns.SPELLS.DRUID_HUMANOIDS`, requires `IsPlayerSpell`, and sorts to keep cycle order stable across reloads. `ns.InvalidateFarmCache()` nils the cache; it is invalidated on `SPELLS_CHANGED`, `PLAYER_ENTERING_WORLD`, on any profile change, and from each Farm Mode Abilities toggle's `set` handler, then rebuilt lazily on the next `RunFarmLogic()`.

### Why Druid Track Humanoids Is Excluded

`ns.SPELLS.DRUID_HUMANOIDS` (5225) requires Cat Form, which is mutually exclusive with the travel forms that put the player into farm state. Including it in the cycle would mean casting a Cat-Form-gated spell from a non-Cat-Form context, which always fails. The exclusion lives in three places: `BuildCycleCache()` ([Features/Farm-Mode.lua](Features/Farm-Mode.lua)) skips the ID, `BuildFarmAbilityArgs()` ([Options/Options-Farm-Mode.lua](Options/Options-Farm-Mode.lua)) hides the toggle, and `ns.CastTracking()` ([Features/Core.lua](Features/Core.lua)) guards on `isCat`. The tracking menu ([Features/Tracking-Menu.lua](Features/Tracking-Menu.lua)) likewise hides the entry unless the player is currently in Cat Form.

### Restricted Zones

`ns.IsRestrictedZone()` ([Features/Utilities.lua](Features/Utilities.lua)) returns true when `IsInInstance()` is true (any instance — dungeon, raid, battleground, arena), when the current instance map ID is in `ns.RESTRICTED_MAP_IDS` (currently only Deeprun Tram, 369), or when `IsResting()` is true (capital cities and inn rest areas). It stays intentionally simple: no capital-city or battleground tables and only a single map-ID special case. The trade-off is breadth — Farm Mode pauses anywhere the resting flag is set, which covers more than just the named cities.

## Target Tracking Deep Dive

`Features/Target-Tracking.lua` sets the Persistent Tracking Ability from the creature the player targets. It is opt-in (`ns.db.profile.targetTracking`, default `false`) and open to every class: whatever creature types a character can track, it can have set automatically. It is richest on a Hunter, who covers seven types, but a Paladin covers Undead and a Warlock Demons. The option hides only for a character that covers none at all, and for one with Persistent Tracking switched off. It is drawn as a **sub-option of Enable Persistent Tracking** on the General panel and hides with it, because that is exactly what it modifies.

`ns.CREATURE_TYPE_SPELLS` ([Data/Data.lua](Data/Data.lua)) is keyed by the client's **localized** creature-type globals (`BEAST`, `DEMON`, `DRAGONKIN`, `ELEMENTAL`, `GIANT`, `HUMANOID`, `UNDEAD`) because `UnitCreatureType` returns a localized string. That is what makes the feature locale-proof without a single locale key of its own. A global the client doesn't define is skipped at build time, and the spell IDs come from `ns.SPELLS` rather than being written down a second time.

Each type maps to a **list** of candidate spells, not one: Undead is covered by the Hunter's Track Undead *or* the Paladin's Sense Undead, Demons by Track Demons *or* Sense Demons. `ns.GetCreatureTypeSpell(creatureType)` ([Features/Utilities.lua](Features/Utilities.lua)) walks them in order and returns the first the character has learned. Druid Track Humanoids is deliberately absent — it requires Cat Form, so setting it as the persistent ability would leave a spell that mostly cannot be cast.

Every type is registered under **two** keys: the client's localized global and the English literal. The globals are what make this work in other locales, but they cannot be relied on to exist — a missing one previously dropped its whole creature type at load, and the feature then failed silently for that type with no error to show for it.

**It writes `selectedSpellId` rather than borrowing the tracking slot**, and that single decision is what keeps the module small. Everything downstream already reads that one key — the post-resurrection recast, the form-leave restore, `TryRecastPersistent`, and the farm cycle's optional persistent entry — so all of them follow for free. There is no hold flag, no revert path, and no need to suppress Persistent Tracking, which means the two features cannot fight each other.

`ns.HandleTargetChanged()` runs on `PLAYER_TARGET_CHANGED`. The bail chain:

- `ns.db` missing, `targetTracking` off, **or `persistentTracking` off** → clear any pending switch and stop. The parent gate is load-bearing: the options panel hides this control while Persistent Tracking is off, so a feature that kept acting would rewrite the saved ability and burn a GCD for something the player believes is switched off. Its own `targetTracking` key is never written by that gate — the setting survives and resumes when the parent comes back on.
- No target, or `UnitCanAttack("player", "target")` is false → stop. Friendly units never drive a switch; targeting a city guard is not a hunt.
- `UnitCreatureType("target")` has no entry in `ns.CREATURE_TYPE_SPELLS`, or the spell isn't known → stop.
- It is already the selected ability → clear any pending switch and stop.
- `UnitAffectingCombat("player")` → store the ID in `pendingSpellId` and stop. **Nothing is ever cast in combat**: a tracking cast costs a global cooldown, which is least affordable mid-fight.
- Otherwise write `selectedSpellId`, invalidate the farm cache (the cycle can include the persistent ability), and cast immediately unless `ns.CanCast()` refuses. **It casts whether or not Farm Mode is running.** An earlier version deferred to the cycle whenever `isFarming` was true, which made the feature look broken in the state it is most used in: mounted, the pick becomes one entry in a rotation of three or four and is overwritten within seconds, so targeting a beast produced nothing visible. Casting now shows the pack at once and the cycle reclaims the slot on its next tick, which keeps the no-hold-flag design intact.

`ns.HandleRegenEnabled()` (`PLAYER_REGEN_ENABLED`) re-runs the whole decision rather than casting `pendingSpellId` directly — by the time the fight ends the target may be dead, swapped, or gone, and re-validating is cheaper than setting tracking from a corpse.

## Minimap Button & Free-Placement Frame

`ns.InitMinimap()` ([Features/Minimap-Button.lua](Features/Minimap-Button.lua)) registers a `LibDataBroker-1.1` launcher and hands it to `LibDBIcon-1.0` with the saved `ns.db.global.minimap` payload. `ns.CreateFreeFrame()` builds the standalone `Button` used when Free Placement Mode is on. `ns.UpdatePlacement()` toggles visibility between the two based on `ns.db.profile.freePlacement`, honors the Enable Mini-map Button preference (`ns.db.global.minimap.hide`), and hides both when the player has no tracking abilities at all (`ns.HasTrackingAbility()`).

### Anonymous Free Frame

The free-placement frame is created with `nil` as its name on purpose. WoW's per-character `layout-local.txt` cache keys frames on their name; any named frame is looked up there at creation time and a cached position from a previous session is applied silently — overriding the account-wide `ns.db.global.freePos`. `SetUserPlaced(false)` from Lua does *not* prevent this lookup. Making the frame anonymous removes it from the layout-local system entirely, so positioning is owned 100% by `ns.db.global.freePos`.

### Position Pipeline

The free-placement frame uses two file-local helpers — `SaveFreePosition(frame)` and `ApplyFreePosition(frame)` — and a single stable anchor: `frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)`.

- **Storage format.** `ns.db.global.freePos = {x = number, y = number}` where `x` and `y` are the frame's center in *absolute screen pixels* (live `GetCenter()` multiplied by the frame's effective scale at save time). Storing absolute pixels means a later UI-scale or icon-scale change doesn't drift the saved position — both ends of the round trip convert through the frame's current effective scale.
- **Save points.** `OnDragStop` (after every drag), `ns.SaveFreeFramePosition()` from the `PLAYER_LOGOUT` handler in [Features/Core.lua](Features/Core.lua) (a backstop, **guarded on the frame being shown**).
- **Why the logout save is guarded.** The absolute-pixel round trip is only exact when the frame's effective scale is the same at anchor time and at save time. `UpdatePlacement` returns early for a character with no tracking ability, skipping the `ApplyFreePosition` in `UpdateFreeFrameScale` — so on that character the frame is anchored once during `ADDON_LOADED`, before `UIParent`'s effective scale settles to the `uiScale` CVar, and never re-anchored. An unguarded logout save then read stale offsets, multiplied by the *settled* scale, and wrote a drifted `freePos`. Because `freePos` is account-wide, that moved the icon for every character, compounding on each visit to the alt. `ns.SaveFreeFramePosition` now bails unless `ns.freeFrame:IsShown()`, which also stops a never-dragged frame from materializing a `freePos` at screen center.
- **Apply points.** The end of `CreateFreeFrame` (initial restore), the end of `UpdateFreeFrameScale` (so `SetScale` doesn't shift the offsets), `UpdatePlacement` before `Show()` (defense against any code path that re-anchored the frame while hidden), and immediately after a drag (normalizing the live anchor back to the canonical `CENTER → BOTTOMLEFT` form).
- **`SetUserPlaced(false)`.** Called in both `OnDragStop` and `ApplyFreePosition`. `StartMoving` / `StopMovingOrSizing` silently flag any frame as user-placed for the rest of the session, and a stale flag can cause the client to write a layout-local entry on logout that out-races our SavedVariables on next login. Clearing it on every apply keeps the flag from sticking.

### Click Map

`OnClick` drives every interaction on both the LibDBIcon button and the free-placement frame:

| Modifier + Button | Action |
| --- | --- |
| Left-Click | Open the tracking menu. |
| Right-Click | `ns.ClearTracking()` — cancel and forget selection. |
| Shift + Left-Click | Toggle Persistent Tracking. |
| Shift + Right-Click | Toggle Farm Mode. |
| Shift + Middle-Click | Open the options panel (`ns:OpenOptionsPanel()`). |

Shift + Middle-Click is handled **before** the `ns.db` guard, so the options panel opens regardless of saved-variable state. `ns.ClearTracking()` nils `selectedSpellId`, calls `CancelTrackingBuff()`, and forces the icon to default immediately — `CancelTrackingBuff` is asynchronous and `GetTrackingTexture()` would still return the old texture for a frame otherwise.

### Blizzard Tracking Button Hook

`ns.ApplyBlizzardTrackingHook()` optionally makes Blizzard's own mini-map tracking icon — inert on these clients — open the Tracking Menu. It is gated on `ns.db.global.hookBlizzardTracking` (account-wide presentation, default `false`), called at the end of `ns.InitMinimap()` and from the option's `set` handler. The frame is resolved as `MiniMapTrackingButton`, falling back to `MiniMapTracking`, and the whole function no-ops when neither exists.

Three details are deliberate:

- **Take-over, not `HookScript`.** A hook would leave Blizzard's own handler running and open two menus at once, so the existing handler is saved and replaced.
- **Exactly one script is replaced** — `OnClick` where `HasScript` reports it, `OnMouseUp` otherwise. Replacing both fires the handler twice for a single click, which opens the menu and immediately closes it. `MiniMapTracking` is a `Frame` and has no `OnClick`, which is why the choice is probed rather than assumed.
- **Restore puts the frame back exactly as found.** Turning the option off re-installs the saved handler (including a nil one) and clears the saved state.

Neither frame is secure or protected on Classic Era or TBC Anniversary, so replacing their scripts raises no taint. A UI that swaps the button out *after* the hook is applied (ElvUI reskins, for instance) will receive the saved handler back on restore, which is the documented limit of the contract.

### Key Bindings

One binding ships, defined in `Bindings.xml` at the add-on root: `TRACKINGEYE_CYCLE_FARM_ABILITY`, which advances the Farm Mode cycle by a single step on demand. It is a **manual** control and is deliberately not gated on `ns.db.profile.farmMode` — pressing the key works with Farm Mode switched off, standing still, or anywhere the automatic cycle would be paused. It still routes through `ns.AdvanceFarmCycle()`, so it obeys `ns.CanCast()` exactly as the ticker does.

Two globals in [Features/Key-Bindings.lua](Features/Key-Bindings.lua) exist only because WoW's binding system demands them, and are the one documented exception to the namespace rule in *Shared Namespace*:

| Global | Why |
| --- | --- |
| `TrackingEye_CycleFarmAbility` | `Bindings.xml` can only call a global function. Prints `BINDING_NOTHING_TO_CYCLE` when the cycle is empty, then delegates to `ns.AdvanceFarmCycle()`. |
| `BINDING_NAME_TRACKINGEYE_CYCLE_FARM_ABILITY` | The binding's display name, matching the `name` attribute. |

`Bindings.xml` is **auto-discovered from the add-on root and must never be listed in the TOC**. Listing it routes the file through the generic UI XML parser, which does not know the `<Bindings>` node and rejects the whole file with `Unrecognized XML: Bindings` warnings, so the binding never appears. Its root element is `<Bindings>` — not a `<Ui>` wrapper, which fails the same way. The `Binding` element carries `name` and **`category`**: the category string is what draws the collapsible **Tracking Eye** section in the Key Bindings list, and without it the binding loads but has nowhere to appear. `header` is a separate, older mechanism for sub-headings inside a category and is not used here.

## Client Assumptions

Both supported flavors — Classic Era 1.15.x and TBC Anniversary 2.5.x — run the modern client, so the modern API is what actually executes in practice. Every modern call is still **reached through an availability guard** with its legacy global behind it, per COMPATIBILITY ("Check the API exists, then call exactly one"). The guards cost nothing on a healthy client and turn a hard Lua error into a graceful degrade on one that is missing something.

- `C_AddOns.GetAddOnMetadata`, `C_AddOns.GetAddOnInfo`, and `C_AddOns.GetNumAddOns` resolve once through `(C_AddOns and C_AddOns.X) or X`, falling back to the pre-`C_AddOns` globals. `GetVersion` returns `Dev` when neither resolves; `ns:BuildAddOnReport` emits a single "unavailable" line.
- `ns:OpenOptionsPanel` runs the full chain: combat gate, then `Settings.OpenToCategory(<captured categoryID>)` behind a `Settings and Settings.OpenToCategory` guard, then `InterfaceOptionsFrame_OpenToCategory(<captured frame>)` called twice, then `AceConfigDialog:Open` as a genuine last resort. Every route uses handles captured at registration, never a name or title lookup.
- Rows in `ns.DIAGNOSTIC_API_CHECKS` carry an optional third element. A row flagged optional is the legacy half of a guard, absent on a modern client by design: it renders `[n/a]` and never counts as a failure. Any other miss is a real problem.

**Find Fish (43308) is the one deliberate cross-flavor entry.** It exists on TBC Anniversary and not in the Era client's spell database at all, so on Era `GetSpellInfo` returns nil, the menu and the Farm Mode list skip it, and Diagnostics reports it as *not on this client*. See *Icon Resolution* for the texture-cache rule that depends on this.

## Diagnostics

The Diagnostic Tools system ([Features/Diagnostics.lua](Features/Diagnostics.lua) + [Options/Options-Diagnostics.lua](Options/Options-Diagnostics.lua)) exists to make bug reports actionable. It is **not** a unit-test runner — WoW's sandboxed Lua has no assertion framework. Every report builds only on an explicit button press, and every check is read-only and side-effect free. The single exception is the Taint Log button, which sets the `taintLog` CVar.

- **Runtime-only state.** `ns.diagnostics = {enabled, logging, log}` is a plain namespace table, **not** a SavedVariable, so file-scope initialization is correct here. Nothing about diagnostics persists across sessions; it always starts off.
- **English-only strings.** Diagnostics text lives in `ns.DiagnosticsStrings`, intentionally **not** localized — it is developer-facing troubleshooting output. The only localized value it uses is the addon's own display name (`ns.L["ADDON_TITLE"]`).
- **Enable gate.** A single runtime toggle (`ns:SetDiagnosticsEnabled`) shows the panel body; turning it off also stops any running event log. Each report section is a button that fills a read-only multiline editbox.
- **Reports.** Event Log (a 500-entry ring buffer fed by `ns:LogEvent` from the Core dispatcher, capped at 8 arguments of 255 characters each with pipes escaped), Event Registration (`ns.EVENT_NAMES` validated via `C_EventUtils.IsEventValid` and a probe frame), API Endpoints (`ns.DIAGNOSTIC_API_CHECKS` existence/shape checks), Player & Spell Context, Display Context, Farm Mode Context, Other Add-ons, Saved Variables dump, and Library Versions. Every report is prefixed with a client header (version, build, TOC, locale, `WOW_PROJECT_ID`).
- **Taint Log.** `ns:SetTaintLog` writes the `taintLog` CVar (0 = off, 2 = verbose). This is the only state the panel ever writes.
- **External tools.** Rather than reimplement them, the panel points at `/console scriptErrors 1`, BugSack/!BugGrabber, and `/etrace`.

## Saved Variables

Tracking Eye declares exactly one SavedVariables table, `TrackingEyeDB`, managed by **AceDB-3.0**, and no `SavedVariablesPerCharacter` line. `ns.db` is the AceDB object. The add-on uses the **Per-Character** model: the third `AceDB:New` argument is omitted, so each character lands on its own `"Name - Realm"` profile. Per-character tracking state lives in `ns.db.profile`; account-wide layout and presentation live in `ns.db.global`. Profiles are switched from the Profiles panel ([Options/Options-Profiles.lua](Options/Options-Profiles.lua), the stock AceDBOptions-3.0 table).

### ns.db.profile (per-profile settings)

| Field | Type | Default | Purpose |
| --- | --- | --- | --- |
| `persistentTracking` | boolean | `true` | Persistent Tracking master toggle. |
| `farmMode` | boolean | `true` | Farm Mode master toggle. |
| `farmInterval` | number | `3.5` | Farm Mode cycle interval in seconds (2–10, step 0.5). |
| `farmMounted` | boolean | `true` | Activate Farm Mode while mounted. |
| `farmTravelForms` | boolean | `true` | Activate Farm Mode in Druid travel/flight forms. |
| `farmCheetah` | boolean | `false` | Activate Farm Mode under Aspect of the Cheetah/Pack. |
| `farmGhostWolf` | boolean | `true` | Activate Farm Mode under Ghost Wolf. |
| `farmNotMounted` | boolean | `false` | Activate Farm Mode with no mount or movement form. |
| `farmCycleSpells` | `[spellId] = bool` | Herbs + Minerals + Treasure | Which tracking abilities Farm Mode rotates through. |
| `farmIncludePersistent` | boolean | `true` | Add the Persistent Tracking ability to the rotation. |
| `selectedSpellId` | number \| nil | *(unset)* | The Persistent Tracking ability the user picked. |
| `targetTracking` | boolean | `false` | Target Tracking master toggle. |
| `muteCycleSound` | boolean | `true` | Silence Farm Mode's automatic casts. |

### ns.db.global (account-wide layout and presentation)

| Field | Type | Default | Purpose |
| --- | --- | --- | --- |
| `minimap` | table | `{}` | LibDBIcon position payload (`hide`, `minimapPos`, …). |
| `freePos` | table \| nil | *(unset)* | `{x, y}` free-frame center in absolute screen pixels. Written only once the user drags. |
| `freePlacement` | boolean | `false` | Free Placement Mode toggle. |
| `freeIconScale` | number | `1.1` | Free-placement icon scale (0.25–3.0, step 0.05). |
| `freeIconShape` | string | `"circle"` | `"circle"` or `"square"`. |
| `showWelcome` | boolean | `true` | Print the one-line login chat message. |
| `hookBlizzardTracking` | boolean | `false` | Take over Blizzard's mini-map tracking button. |

Global holds how the add-on presents itself, so switching, resetting, or deleting a profile never moves the icon, changes its shape, or brings the welcome message back.

### Profile Apply

`ns:ApplyProfile` ([Features/Core.lua](Features/Core.lua)) is registered by name against all three AceDB profile callbacks and is the single settings-apply path. Only values read live from the database update themselves on a profile switch; everything applied imperatively has to be repeated here — the farm cache and ticker interval, the icon placement, the free-frame scale and shape, the Blizzard tracking-button hook, and the Target Tracking hold. It ends by calling `AceConfigRegistry:NotifyChange` for every name in `ns.OPTIONS_REGISTRY`, iterating the table rather than listing panels, so an options panel already on screen redraws instead of showing the profile the player just left.

Defaults come from `ns.DATABASE_DEFAULTS` and are applied lazily by AceDB-3.0 via metatables — nothing is copied into the saved table, and explicit user values (including `false`) are never overridden.

There is deliberately **no refill-on-empty logic**. `farmCycleSpells` is a settings map, not a re-seedable list: AceDB copies its concrete defaults with `rawset`, so the map iterates correctly for new users, and the options toggle stores an explicit `false` for a disabled spell. A user who turns every entry off keeps that state across logins. Storing `nil` instead would let AceDB re-add the default `true` on the next login and resurrect a spell the user turned off. `selectedSpellId` is likewise absent from the defaults — `nil` is its "unset" value and cannot be stored as a default.

### Reset

Reset is entirely stock: the AceDBOptions **Reset Profile** on the Profiles panel resets the active profile only. The General panel carries no reset control, and there is no account-wide wipe.

## Adding a New Tracking Spell

1. Add a row to `SPELL_DATA` in [Data/Data.lua](Data/Data.lua) under the appropriate source (`{spellId, key, source}`). The constructor populates `ns.SPELLS`, `ns.TRACKING_IDS`, and `ns.TRACKING_SET` automatically; form spells (listed in `FORM_KEYS`) are excluded from the tracking sets.
2. If the spell should be on by default in Farm Mode, add it to `ns.FARM_CYCLE_DEFAULTS` in [Data/Default-Settings.lua](Data/Default-Settings.lua).
3. If the spell has special form gating (like Druid Track Humanoids), add a guard in `ns.CastTracking` ([Features/Core.lua](Features/Core.lua)), exclude it from `cachedCycle` in `BuildCycleCache` ([Features/Farm-Mode.lua](Features/Farm-Mode.lua)), and exclude it from the Farm Mode Abilities list in `BuildFarmAbilityArgs` ([Options/Options-Farm-Mode.lua](Options/Options-Farm-Mode.lua)).
4. No new locale strings are needed — the spell name and icon come from `GetSpellInfo` / `GetSpellTexture` at runtime, so they localize automatically. Only add a locale key if you also need a custom label or description.
5. Verify the menu and options correctly hide the spell on characters that don't know it. The `IsPlayerSpell(id)` checks inside `BuildFarmAbilityArgs`'s `hidden` and inside `Tracking-Menu.lua`'s row loop are what gate visibility.

## Adding a New Registered Event

1. Add the event name to `ns.EVENT_NAMES` in [Features/Core.lua](Features/Core.lua). This is the single source of truth — the dispatcher registers from it and the Diagnostics *Event Registration* check validates against it, so both pick the event up together.
2. If the event is unit-filtered, add it to the `UNIT_FILTERED_EVENTS` map in the same file so it registers via `RegisterUnitEvent` rather than waking the dispatcher for every unit.
3. Add a branch to the `OnEvent` handler. Keep the branch ordering intact — `ADDON_LOADED` and `PLAYER_LOGIN` must stay ahead of the steady-state events.
4. Do not register the event on a second frame. One dispatcher, one registration list.

## Localization

Player-visible strings live in `Locales/<locale>.lua`, each registered through AceLocale-3.0's `NewLocale("TrackingEye", "<locale>")`. `enUS.lua` is the source of truth and the only file that passes the `true` default-fallback flag; every string originates there and the other locales translate from it. `Data/Data.lua` acquires the handle once (`ns.L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)`) and every file reads `local L = ns.L`.

This is **maintenance, not expansion** — WoW ships a fixed locale set and all eleven files already exist (`enUS, deDE, esES, esMX, frFR, itIT, koKR, ptBR, ruRU, zhCN, zhTW`). There is no "add a new locale" step.

- **Keeping locales in sync.** Every locale carries a translation of the same key set, and AceLocale falls back to English via `__index` for anything missing at runtime. Translating each `enUS.lua` key into every locale and keeping the files aligned is the job of the Localization pass (`3 - Copy Cleanup & Localization Prompt.md`); don't hand-edit the other locales during ordinary work.
- **Placeholders.** `%s` / `%d` count, type, and order must match `enUS` per key in every locale, or the string crashes at runtime. Only one key currently carries a placeholder: `CHAT_LOADED` takes a single `%s` (the version), formatted in `PrintWelcome` ([Features/Core.lua](Features/Core.lua)).
- **Spanish.** `esES.lua` and `esMX.lua` are two separate, self-contained files. Identical strings in both is correct and expected.
- **Locale overflow.** German is the usual canary for strings that outgrow their widget. Tracking Eye builds no macros, so the 255-character macro limit does not apply here; the risk is confined to option labels and tooltip lines that wrap awkwardly.
- **Diagnostics strings are not localized.** They live in `ns.DiagnosticsStrings` ([Features/Diagnostics.lua](Features/Diagnostics.lua)), are developer-facing, and are intentionally English-only. Never add them to `Locales/`.

## Common Pitfalls

- **Trusting `GetTrackingTexture` / `MINIMAP_UPDATE_TRACKING` as live state** — On Classic Era 1.15.x the tracking mirror lags reality, sometimes by minutes, and `nil` doubles as the normal "no tracking active" value. Comparing against it (or bailing on `nil`) silently disabled Farm Mode and Persistent Tracking on Era. Compare against `ns.state.lastCastSpell` instead, and treat the mirror as a positive signal only. The login-recast bug is prevented by the time-based grace window (`LOGIN_GRACE_SECONDS`) in `TryRecastPersistent` — never by a `nil` bail.
- **Adding a second reader of the tracking mirror** — `ns.UpdateIcon` and all cast logic funnel through the single `ns.GetActiveTrackingSpell()`. Reading `MiniMapTrackingIcon` or `GetTrackingTexture()` directly anywhere else resurrects cleared tracking icons and re-poisons `lastCastSpell` through the adoption branch. Every past icon bug on Era came from a second reader with slightly different rules.
- **Persisting `ns.state.lastCastSpell`** — It is runtime-only, written solely by `UNIT_SPELLCAST_SUCCEEDED` via `ns.SetLastCast`. A value carried over from last session makes the farm cycle and persistent recast believe tracking is already up at login and skip every real cast. It is never written to `ns.db`.
- **Casting tracking during the GCD after shapeshift** — Mitigated by `C_Timer.After(1.5, TryRecastPersistent)` on `UPDATE_SHAPESHIFT_FORM`. Removing the delay causes silent cast failures because the shapeshift GCD hasn't elapsed.
- **Swallowing a temporary bail in `TryRecastPersistent`** — In-combat, on-cooldown, and debounce bails must `ScheduleRecast`, not `return` outright. On Era no further tracking event may fire, so a dropped trigger stops persistent tracking until the next login.
- **Adding Druid Track Humanoids to the farm cycle** — Excluded on purpose (requires Cat Form, mutually exclusive with travel forms). Re-adding it queues casts that always fail. Guarded in three places plus the menu.
- **Naming the free-placement frame** — Re-introduces the `layout-local.txt` lookup the anonymous-frame fix avoids; a cached per-character position silently overrides `ns.db.global.freePos`. Keep the constructor's first arg `nil`.
- **Reading `GetPoint()` to serialize the free-frame position** — `StartMoving` / `StopMovingOrSizing` leave the frame on a non-canonical anchor; saving it causes drift on the next Show or scale change. Always round-trip through `SaveFreePosition` / `ApplyFreePosition`.
- **Skipping `SetUserPlaced(false)` after a position apply** — A leftover user-placed flag lets WoW write a layout-local entry on logout that out-races our SavedVariables on next login.
- **Saving the free-frame position from a frame that was never re-anchored** — `GetCenter()` returns frame-space coords, so `SaveFreePosition` is only correct when the frame's effective scale matches the one `ApplyFreePosition` last used. A character with no tracking ability never re-anchors (`UpdatePlacement` early-returns), so an unguarded save at `PLAYER_LOGOUT` re-encoded stale offsets against a different scale and corrupted the account-wide `freePos` for every character. Keep the `IsShown()` guard on `ns.SaveFreeFramePosition`, and never add a new unconditional caller of `SaveFreePosition`.
- **Caching the options-open state, or reading it with `IsShown()`** — Closing the Settings window hides the *window*, not our canvas, so the canvas keeps its own shown flag and its `OnHide` never fires. A flag cached behind Show/Hide hooks therefore keeps the last value it saw (true) and pauses Farm Mode until the next reload, and `IsShown()` fails the same way because it reports only the frame's own flag. `ns.IsOptionsPanelOpen()` evaluates `IsVisible()` live on every call, which also requires every ancestor to be shown.
- **Deferring Target Tracking's cast to the farm cycle** — `ns.HandleTargetChanged` must cast immediately, not bail on `isFarming`. Handing the cast to the cycle looks correct on paper but is the same as not implementing the feature while mounted: the pick is one entry in a rotation and is overwritten within seconds. The cycle reclaiming the slot a tick later is the intended, harmless outcome.
- **Reusing a retired locale key name** — When a key is dropped from `enUS.lua` its translations stay behind in the other ten files, and AceLocale only falls back to enUS for keys a locale does *not* define. Reusing the name silently serves every non-English player the old string. Grep `Locales/` for any new key name before adding it; if it hits, pick a different name rather than editing the other locales, which the Localization pass owns.
- **Localizing Diagnostics strings** — They belong only in `ns.DiagnosticsStrings`, never in `Locales/`. Translating developer-facing troubleshooting text is wasted effort.
- **Reading `ns.db` before `ADDON_LOADED`** — AceDB creates `ns.db` inside the `ADDON_LOADED` handler in `Core.lua`. Any file-scope read of `ns.db` (or a bare `TrackingEyeDB`) runs before that and sees `nil`; every access is guarded (`ns.db and …`) and happens from runtime handlers, never at load.
- **Renaming a profile field without a migration** — AceDB's metatable defaults only supply `nil` fields, so a rename leaves the old value stranded under the old key. Add a dated `MIGRATION` block in `ADDON_LOADED` that moves the value into `ns.db.profile`, and remove it when the window closes.
- **Storing `nil` to disable a `farmCycleSpells` entry** — AceDB re-adds the default `true` for any absent default key on the next login, so a disabled Herbs/Minerals would resurrect. The options toggle writes explicit `false`; keep it that way.
- **Building the texture cache during the login storm and trusting it** — `GetSpellTexture` returns nil for spells whose data hasn't loaded yet, so a cache built then is permanently incomplete. `BuildTextureCache` tracks `textureCacheComplete` and rebuilds once on a miss; don't remove that retry.

## Contributing

- **Issues:** open them at [github.com/Gogo1951/Tracking-Eye/issues](https://github.com/Gogo1951/Tracking-Eye/issues). For bug reports include: game version (Classic Era / Anniversary / etc.), client locale, character class and level, exact reproduction steps, and any chat output or error text. The Diagnostic Tools panel (`/te` → Diagnostic Tools) produces copy-paste reports that carry most of this automatically.
- **Discord:** [discord.gg/eh8hKq992Q](https://discord.gg/eh8hKq992Q) for discussion, screenshots, and quick questions.
- **Pull requests:**
  - Keep scope tight — one feature or fix per PR.
  - Follow the style guide. No alignment padding around `=`, no `##` for in-file section headers, no hardcoded user-facing strings (every player-visible string belongs in `Locales/enUS.lua`; Diagnostics strings are the deliberate English-only exception).
  - Respect the Persistent Tracking and icon-resolution guards — read the *Persistent Tracking Deep Dive* and *Icon Resolution* sections before touching those code paths.
  - Migration discipline: every field rename or storage-shape change ships with a dated `MIGRATION` block and a removal date.
  - When the architecture or file map changes, update this document in the same PR.

### Commit and PR descriptions require a User Story

Don't just say "I changed X" or "I fixed Y." Frame the change in terms of who it helps and why.

**Format:** *As a [role], I [needed / wanted] [behavior] so that [outcome]. This change [does X].*

**Example:** *As a druid who shapeshifts between Travel Form and caster form during a farming run, I wanted Tracking Eye to recast my saved tracking spell after the shapeshift instead of leaving me with no tracking buff. This change schedules a `TryRecastPersistent()` 1.5 seconds after `UPDATE_SHAPESHIFT_FORM` so the post-shift GCD has elapsed before the cast fires.*

The User Story makes review faster and gives future maintainers context the diff alone won't carry.
