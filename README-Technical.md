# Tracking Eye — Technical Reference

This document combines architecture notes and contribution guidance for developers working on Tracking Eye. For end-user documentation, see [README.md](https://github.com/Gogo1951/Tracking-Eye/blob/main/README.md).

## File Map

```text
TrackingEye/
├── .github/
│   └── workflows/
│       └── package.yml              CurseForge release and library vendoring
├── .gitattributes                   Line-ending normalization
├── .pkgmeta                         Externals and ignore list
├── TrackingEye.toc                  Metadata, SavedVariables, load order
├── Bindings.xml                     Key binding, auto-discovered from the root and never listed in the TOC
├── Data/
│   ├── Data.lua                     Locale handle, spell tables, creature-type map, timing constants, palette
│   └── Default-Settings.lua         ns.DATABASE_DEFAULTS and ns.FARM_CYCLE_DEFAULTS
├── Features/
│   ├── Core.lua                     State, icon resolution, the cast primitive, persistent recast, dispatcher
│   ├── Utilities.lua                Colors and every shared game-state predicate
│   ├── Announcements.lua            ns:PrintMessage, the add-on's only chat output
│   ├── Farm-Mode.lua                Cycle cache, ticker, RunFarmLogic, the cycle sound mute
│   ├── Target-Tracking.lua          Sets the persistent ability from the targeted creature
│   ├── Key-Bindings.lua             The two globals WoW's binding system demands
│   ├── Tracking-Menu.lua            LibUIDropDownMenu spell picker
│   ├── Diagnostics.lua              Read-only reports and the event log buffer
│   └── Minimap-Button.lua           LDB launcher, free-placement frame, tooltip, click map
├── Includes/
│   ├── Images/
│   │   └── Tracking-Eye.tga         Add-on icon, referenced by the TOC IconTexture
│   └── Libraries/                   Vendored libraries, never hand-edited
├── Locales/
│   ├── enUS.lua                     Source of truth, the only file passing AceLocale's default flag
│   └── deDE.lua … zhTW.lua          Ten translations
├── Options/
│   ├── Options-Utilities.lua        Widget helpers and the sub-option row builder
│   ├── Options-Target-Tracking.lua  Fragment merged into the General panel
│   ├── Options-Free-Placement.lua   Fragment merged into the General panel
│   ├── Options-General.lua          Root panel, composing both fragments above
│   ├── Options-Farm-Mode.lua        The Farm Mode child panel
│   ├── Options-Profiles.lua         Stock AceDBOptions-3.0 table, unmodified
│   ├── Options-Diagnostics.lua      The gated Diagnostic Tools panel
│   └── Options.lua                  Registration, open routing, the /te command
├── LICENSE                          MIT
├── README.md                        End-user documentation
└── README-Technical.md              This file
```

Files load in TOC order: `Includes/` → `Locales/` → `Data/` → `Features/` → `Options/`. Order matters. `Data/Data.lua` populates the shared namespace (spell tables, constants, palette) and `Data/Default-Settings.lua` adds the defaults table before any feature reads them; `Features/Core.lua` defines the dispatcher and `Features/Utilities.lua` the game-state predicates the later files call at runtime. Inside `Options/`, the two merged fragments load **before** `Options-General.lua`, which reads their builders while composing its own args.

`Bindings.xml` carries no TOC line on purpose — see *Key Bindings*.

## Architecture

### Shared Namespace

Every Lua file receives `(addonName, ns)` via the `...` vararg. The `ns` table is the add-on's shared namespace — all public functions, constants, and state live on it. There are no global functions beyond the ones something outside the add-on's own Lua must reach:

| Global | Why it exists |
| --- | --- |
| `TrackingEyeDB` | The SavedVariables table, owned by AceDB-3.0. Read through `ns.db`, never directly. |
| `SLASH_TRACKINGEYE1` / `SlashCmdList["TRACKINGEYE"]` | WoW's slash registration ([Options/Options.lua](Options/Options.lua)). |
| `TrackingEye_CycleFarmAbility` | `Bindings.xml` can only call a global function. |
| `BINDING_NAME_TRACKINGEYE_CYCLE_FARM_ABILITY` | The binding's display name, matching the element's `name` attribute. |
| `TrackingEyeTrackingMenu` (+ its font object) | The named dropdown frame LibUIDropDownMenu creates. |

Because features are split across files that load in a fixed order, a file may *define* a function the earlier-loaded files *call* — safe as long as the call happens at runtime, not at file scope. `Core.lua` loads before `Utilities.lua` yet calls `ns.GetPlayerStates` and `ns.GetColor`; that works because those calls only ever fire from event handlers and timers, long after every file has loaded. Calls into optional-by-load-order modules are still guarded (`if ns.RunFarmLogic then …`), so a partially loaded add-on degrades instead of erroring.

### Event Loop

`Core.lua` registers a single hidden frame (`eventFrame`) and routes every event through one `OnEvent` handler. The registered list lives in `ns.EVENT_NAMES` — a single source of truth the Diagnostics *Event Registration* check reads back, so the two can never drift. `UNIT_FILTERED_EVENTS` maps the events that register through `RegisterUnitEvent` instead; `UNIT_SPELLCAST_SUCCEEDED` is the only entry, scoped to `"player"`, so the dispatcher is never woken for other units' casts.

Every event first passes through `ns:LogEvent` when the diagnostics event log is active (see *Diagnostics*), behind a plain boolean read so nothing is allocated when logging is off. Initialization then happens in two passes:

- `ADDON_LOADED` (when `arg1 == addonName`) creates the database (`ns.db = LibStub("AceDB-3.0"):New("TrackingEyeDB", ns.DATABASE_DEFAULTS)` — no third argument, so each character gets its own profile), registers `ns:ApplyProfile` against the `OnProfileChanged` / `OnProfileCopied` / `OnProfileReset` callbacks, calls `ns.RegisterOptionsPanels()` (it must follow `AceDB:New`, since the Profiles builder reads `ns.db`), calls `ns.CreateFreeFrame()`, and runs the first `ns.UpdateIcon()`.
- `PLAYER_LOGIN` calls `ns.InitMinimap()`, `ns.InitFarmMode()`, refreshes the icon, starts `PollUntilTrackingReady()`, and prints the welcome message (gated on `ns.db.global.showWelcome`).

Steady-state events:

- `UNIT_SPELLCAST_SUCCEEDED` (player) — if the cast spell ID is in `ns.TRACKING_SET`, call `ns.SetLastCast(spellId)`, notify the cycle sound mute, and refresh the icon. This is the **only** writer of `ns.state.lastCastSpell`.
- `MINIMAP_UPDATE_TRACKING` — refresh the icon, run `FlushIconAfterTrackingChange()`, then `C_Timer.After(2, TryRecastPersistent)`. Tracking changed or was cancelled outside the add-on; this is the trigger that re-applies a cancelled persistent spell. Safe to fire from our own casts — the recast function's grace window and debounce absorb the echo.
- `ZONE_CHANGED_NEW_AREA` — refresh the icon.
- `PLAYER_ENTERING_WORLD`, `SPELLS_CHANGED` — refresh the icon, then `ns.UpdatePlacement()`, `ns.InvalidateFarmCache()`, and `ns.InvalidateTextureCache()`. `PLAYER_ENTERING_WORLD` also records `ns.state.enteredWorldAt` (anchoring the recast grace window) and schedules the **login catch-up**: one `TryRecastPersistent()` call at grace-expiry (+11s). Without it, a player who logs in with tracking down stays that way — on Era no tracking event may ever fire to provide a trigger. If tracking survived logout, the positive-mirror check inside `TryRecastPersistent` skips the cast.
- `UPDATE_SHAPESHIFT_FORM` — refresh the icon, then `C_Timer.After(1.5, TryRecastPersistent)`.
- `PLAYER_UNGHOST` and `PLAYER_ALIVE` — both call `RecastAfterResurrection()` (see *Persistent Tracking*).
- `PLAYER_UPDATE_RESTING` — call `ns.RunFarmLogic()` immediately so Farm Mode stops the instant the resting flag is set (entering a city or inn) and resumes the instant it clears, instead of waiting up to a full ticker interval. The resting flag itself can lag zone entry by several seconds; that latency is the client's, not the ticker's.
- `PLAYER_LOGOUT` — call `ns.SaveFreeFramePosition()` so the free frame's live position is captured before WoW serializes SavedVariables, then `ns.RestoreCycleSoundNow()` so an in-flight sound mute can never outlive the session.
- `PLAYER_TARGET_CHANGED` — call `ns.HandleTargetChanged()` (see *Target Tracking*).
- `PLAYER_REGEN_ENABLED` — call `ns.HandleRegenEnabled()`, which replays a switch requested during combat.
- `LOOT_OPENED` and `LOOT_CLOSED` — set and clear `ns.state.lootWindowOpen`, the flag `ns.CanCast()` reads. The events are the source of truth rather than `LootFrame:IsShown()`: Speedy-Loot-style add-ons hide that frame while looting is still open, so a frame read would report "no loot window" during exactly the window that needs guarding.

### Combat Lockdown

Nothing here drives secure or protected UI, so there is no taint surface to defer around. Combat still shapes three behaviors, and they are deliberately different from one another:

- **The options opener refuses outright.** `ns:OpenOptionsPanel` ([Options/Options.lua](Options/Options.lua)) checks `InCombatLockdown()` before anything else and returns after printing `CHAT_OPTIONS_IN_COMBAT`. Blizzard's Settings panel is protected in combat, and without that gate `/te` or Shift + Middle-Click hands the player an `ADDON_ACTION_BLOCKED` error naming Tracking Eye. It **never queues** the open for later, and it is the single call site of that locale key.
- **Target Tracking defers.** A creature-type switch asked for during combat is stored in the `pendingSpellId` file-local in [Features/Target-Tracking.lua](Features/Target-Tracking.lua) rather than cast, because a tracking cast costs a global cooldown and mid-fight is when that is least affordable. `PLAYER_REGEN_ENABLED` replays it through `ns.HandleRegenEnabled`, which re-runs the whole decision instead of casting the stored ID (see *Target Tracking*).
- **Automatic casts refuse and retry.** `ns.CanCast()` is false while `UnitAffectingCombat("player")` is true, so the farm ticker, the persistent recast, and the cycle binding all decline. No queue is needed because every caller re-fires on its own: the ticker on its next tick, the recast through `ScheduleRecast`.

Two smaller combat facts follow from the same reasoning. `ComputePlayerStates` classifies the player as `mounted` only while `UnitAffectingCombat("player")` is false, so a fight that begins while mounted drops the state at once rather than leaving the cycle armed behind `ns.CanCast()`. And combat is reported as a Farm Mode pause reason but flagged **transient**, so the icon does not dim for it (see *Pause Reporting*).

If a future feature ever needs to drive secure UI, add an `InCombatLockdown()`-gated dirty flag and replay it from the existing `PLAYER_REGEN_ENABLED` branch.

### Icon Resolution

`ns.UpdateIcon()` ([Features/Core.lua](Features/Core.lua)) is the single place that decides which texture the launcher and the free frame display. It resolves through one authoritative reader — `ns.GetActiveTrackingSpell()` — and never reads `MiniMapTrackingIcon` or `GetTrackingTexture()` directly. Every past icon bug on Era came from a second reader of the tracking mirror with slightly different rules.

1. `ns.GetPlayerStates()` — if the player has left Cat Form and `lastCastSpell` still holds `DRUID_HUMANOIDS`, clear it.
2. `activeSpell = ns.GetActiveTrackingSpell()` — the live tracking spell (Blizzard minimap icon while visible, `GetTrackingTexture()` as fallback; see [Features/Utilities.lua](Features/Utilities.lua)).
3. **Adopt** pre-session tracking: if `activeSpell` is set and `ns.state.lastCastSpell` is nil, adopt it via `ns.SetLastCast(activeSpell)` — but only while the session has no confirmed cast, since in-session casts already own `lastCastSpell` and the Era mirror lags them.
4. **Latch** `mirrorConfirmedCast`: once the mirror positively reports our own `lastCastSpell`, it has caught up, so a later nil reading is a genuine external cancel rather than lag.
5. Choose the icon spell: `activeSpell` if present; otherwise, for `ns.ICON_IN_FLIGHT_SECONDS` (4) after our own cast attempt and only until `mirrorConfirmedCast` latches, show `lastCastSpell` while the laggy Blizzard icon catches up. **There is no fallback to the selected or persisted spell** — every such fallback produced a stale icon (last session's spell at login with nothing actually up). Nothing tracked means `ns.ICON_DEFAULT` (`Interface\Icons\inv_misc_map_01`).

The resolved texture is written to `ns.state.currentIcon`, `ns.ldb.icon`, and the free frame's icon texture; `ns.RefreshTooltip()` then updates any tooltip already on-screen.

`UpdateIcon` is also the only writer of `ns.state.farmPauseReason`. It resolves `ns.GetFarmPauseReason()` and dims the icon **only for settled reasons** — `ns.ICON_PAUSED_TINT` (0.45) into `ns.ldb.iconR/G/B` for the launcher, plus `SetDesaturated` and the same tint on the free frame. Transient reasons (combat, casting, looting, a tooltip) are reported in the tooltip but never dim, or the icon strobes through every fight and every gathered node. The tint is always written as a **number, never nil**: LibDBIcon passes `iconR/G/B` straight into `SetVertexColor`, which errors on a nil component, so the un-dimmed state is an explicit `1`.

`ns.GetActiveTrackingSpell()` reads the global `MiniMapTrackingIcon` **only while it is visible** and matches its texture back to a known tracking ID; a hidden frame retains a stale texture, and on the Vanilla client the frame is hidden entirely when nothing is tracked. It falls back to `GetTrackingTexture()` for clients (TBC+) that show a generic "None" texture instead. The read degrades safely if the frame is ever absent — a nil frame yields no match and resolution falls through.

Two supporting pollers in `Core.lua` shave latency without ever making the mirror fresher:

- `PollUntilTrackingReady()` runs once at `PLAYER_LOGIN`, retrying every second (up to 15×) until `MiniMapTrackingIcon` has a texture, then refreshes the icon once. During the login event storm the icon may not have its texture set yet and `MINIMAP_UPDATE_TRACKING` may never fire, so without this the icon can stay stuck on default until the user toggles something.
- `FlushIconAfterTrackingChange()` re-runs `UpdateIcon` up to 8 times over ~2s after a tracking change, catching the Era mirror the moment it flushes. Both pollers are coalesced behind a flag so bursts of events cannot stack overlapping timers.

### Spell Data Caching

Spell names and textures are never stored; `Data/Data.lua` holds only IDs, and everything player-visible comes from `GetSpellInfo` / `GetSpellTexture` at runtime so it localizes for free. That makes cold-call nils the thing to handle, in two places.

**The texture reverse cache.** `ns.GetActiveTrackingSpell()` has to turn a texture back into a spell ID, so `BuildTextureCache` in [Features/Utilities.lua](Features/Utilities.lua) builds a lazy `texture → spellId` map instead of scanning `ns.TRACKING_IDS` with `GetSpellTexture` on every call. During the login event storm `GetSpellTexture` returns nil for spells whose data has not loaded, so a cache built then is missing entries.

**Rebuilds are driven by a dirty flag, never by testing whether every ID resolved.** Find Fish (43308) does not exist in the Era client at all, so "every ID resolved" is unreachable there: a completeness test stays false forever and rebuilds the whole table on every lookup miss — which is most of them, since a miss is what happens whenever nothing is tracked. `SPELLS_CHANGED` and `PLAYER_ENTERING_WORLD` are the only points where new spell data can appear, so they call `ns.InvalidateTextureCache()` and the next lookup rebuilds exactly once.

**Nil names are a filter, not an error.** The tracking menu ([Features/Tracking-Menu.lua](Features/Tracking-Menu.lua)) and the Farm Mode ability list ([Options/Options-Farm-Mode.lua](Options/Options-Farm-Mode.lua)) both skip any ID whose `GetSpellInfo` comes back nil, which is how Find Fish silently disappears on Era. Diagnostics reports the same condition explicitly as *not on this client*, so a bug report can tell "the client has never heard of this spell" apart from "the player has not learned it."

## Persistent Tracking

`TryRecastPersistent()` ([Features/Core.lua](Features/Core.lua)) handles mid-play recasts. It runs 1.5 seconds after `UPDATE_SHAPESHIFT_FORM`, 2 seconds after `MINIMAP_UPDATE_TRACKING`, and once at grace-expiry after `PLAYER_ENTERING_WORLD` (the catch-up). The bail chain, in order:

- `ns.db` not yet created, `persistentTracking` off, or `selectedSpellId` not set → stop.
- The player is in a farm state → stop; Farm Mode owns the cast.
- `IsPlayerSpell(spellId)` is false (the saved spell was unlearned) → stop.
- Less than `LOGIN_GRACE_SECONDS` (10) since `PLAYER_ENTERING_WORLD` → stop; the login/reload window. The catch-up re-fires after the window, so nothing is lost.
- `ns.GetActiveTrackingSpell()` returns the selected spell (provably active) → sync `lastCastSpell`, re-latch `mirrorConfirmedCast`, and stop. This is what terminates the retry chain after a successful recast.
- Our own cast of this spell is still in flight (`lastCastSpell == spellId` and less than `ns.CAST_IN_FLIGHT_SECONDS` (10) since the attempt) → **reschedule** and re-check. Without this, the constant `UPDATE_SHAPESHIFT_FORM` stream from a hunter's aspects drives a redundant recast every ~5s until the mirror flushes — the "it casts it three times" symptom.
- `ns.CanCast()` is false (dead or ghost, stealthed, mid-cast, in combat, a loot window open, or something on the cursor) → **reschedule** via `ScheduleRecast(RECAST_DEBOUNCE_SECONDS)`.
- On cooldown or GCD → **reschedule**.
- Less than `RECAST_DEBOUNCE_SECONDS` (5) since the last cast attempt (the `MINIMAP_UPDATE_TRACKING` echo of our own cast) → **reschedule**.
- Otherwise recast.

Temporary bails **retry, never swallow**: on Era the client may fire no further tracking event ever, so a swallowed trigger (the user cancels tracking twice within the debounce) used to kill persistent tracking until the next login. `ScheduleRecast` coalesces retries behind a `recastRetryPending` flag so bursts cannot stack timers.

Two client facts shape this design:

1. **The login blackout.** During the Classic login/reload event storm the tracking API is unresponsive for ten or more seconds and `GetTrackingTexture()` returns `nil`; we cannot tell whether the saved spell is already active. Casting blindly in that window caused the historical login-recast bug. Solved by the **time-based grace window**, not by interpreting `nil`.
2. **The Era stale mirror.** On the Vanilla-based client (Classic Era 1.15.x, since ~1.15.1) the tracking mirror — `GetTrackingTexture()` and `MINIMAP_UPDATE_TRACKING` — lags the real state, sometimes by minutes; it only flushes when an unrelated buff update fires. `nil` is also that client's normal steady-state value for "no tracking active." An earlier version that bailed whenever `GetTrackingTexture()` was `nil` permanently blocked recasts on Era — the guard matched the exact state that needed fixing. **Do not reintroduce a nil bail.** Treat the mirror as a **positive signal only** ("provably active → skip") and let everything else fall through to a recast; recasting an already-active tracking spell is a harmless refresh.

Resurrection does **not** route through `TryRecastPersistent`. After a rez the server has genuinely cleared the player's tracking buff, so a recast is always needed and the mirror is never consulted. Both `PLAYER_UNGHOST` (returning to a corpse after a spirit run) and `PLAYER_ALIVE` (an in-place resurrection — healer rez, soulstone, or a graveyard port) call the shared `RecastAfterResurrection()`, which casts directly after a 1.5-second delay so the GCD and post-resurrection scripts settle. It still honors the `persistentTracking` / `selectedSpellId` / farm-state guards. Two details make it robust: a corpse-run return fires **both** events, so a `resurrectRecastPending` flag coalesces them into a single recast; and because `PLAYER_ALIVE` also fires the instant the player releases spirit and becomes a ghost, the delayed callback bails while `UnitIsDeadOrGhost("player")` is still true so it never casts into a corpse (the real resurrection fires the event again).

`ns.CastTracking(spellId)` is the shared cast primitive. It validates `IsPlayerSpell`, gates Druid Track Humanoids on Cat Form, treats an active GCD or cooldown as "skip," records `ns.state.lastTrackingCastAt`, and `pcall`s `CastSpellByID`. It **returns `true` only when it reached `CastSpellByID`**, which is what the cycle sound mute arms on. It deliberately does **not** write `ns.state.lastCastSpell` — only `UNIT_SPELLCAST_SUCCEEDED` does, so a silent failure (line of sight, range, server reject) never poisons the bookkeeping the farm cycle and recast logic compare against.

## Farm Mode

`ns.RunFarmLogic()` ([Features/Farm-Mode.lua](Features/Farm-Mode.lua)) runs on a `C_Timer.NewTicker` (default 3.5s, configurable 2–10s in half-second steps via `ns.db.profile.farmInterval`) and also on demand from the `PLAYER_UPDATE_RESTING` handler. The decision chain:

1. Refresh the dimmed icon when `ns.GetFarmPauseReason()` differs from `ns.state.farmPauseReason`. This sits **above every bail** so the dim state stays honest even on ticks that do nothing else.
2. Bail if one of our options panels is visible (`ns.IsOptionsPanelOpen()`).
3. Bail if any blocking window is open (`ns.IsBlockingWindowOpen()`) or the player is reading a tooltip (`ns.IsTooltipShowing()`).
4. Bail if `ns.db.profile.farmMode` is off.
5. Read `ns.GetPlayerStates()`. If the player just left farm state (`not inForm and ns.state.wasFarming`), clear `wasFarming` and recast the persistent tracking spell unless it is provably active or our own cast is still in flight, then return. This runs **before** the restricted-zone gate, so a player who unmounts inside an instance or a city still gets their persistent spell back.
6. Bail in restricted zones (`ns.IsRestrictedZone()`).
7. Bail if not in farm state or `ns.CanCast()` is false.
8. Lazily rebuild `cachedCycle` if nil. Bail when empty.
9. Single-entry shortcut: when `#cachedCycle == 1`, idle only while the spell is provably active (`ns.GetActiveTrackingSpell()`) or our own cast is still in flight (`ns.CAST_IN_FLIGHT_SECONDS` since the last attempt, covering icon lag); anything else — including tracking cancelled outside the add-on — recasts. Mark `wasFarming = true` and return.
10. Advance the cycle via `ns.AdvanceFarmCycle()`. Mark `wasFarming = true`.

`ns.CanCast()` ([Features/Utilities.lua](Features/Utilities.lua)) is the shared gate for every **automatic** cast — the farm cycle, the persistent recast, the post-target switch, and the manual cycle binding. It refuses while the player is dead or a ghost, stealthed, mid-cast, in combat, while a loot window is open (`ns.state.lootWindowOpen`), or while `GetCursorInfo()` reports something on the cursor. The last two are not about wasting a GCD: in Classic a spell cast closes an open loot window, so a cycle tick landing mid-loot can cost the player the node they just gathered, and a cast fired while an item or spell is held on the cursor discards it. `ns.CastTracking` itself is deliberately **not** gated — the tracking menu is a deliberate player click and must always cast. Every condition is momentary and every caller retries, so nothing is ever swallowed.

Farm logic never reads `GetTrackingTexture()` directly. The multi-spell cycle compares against `ns.state.lastCastSpell` — written only from `UNIT_SPELLCAST_SUCCEEDED`, reliable on every supported client — and the single-spell shortcut additionally consults `ns.GetActiveTrackingSpell()` (Blizzard icon first) so an external cancel is noticed and re-cast. These comparisons exist only to avoid burning a GCD on a no-op recast.

`ns.AdvanceFarmCycle()` is the one advance path, shared by the ticker and the key binding. It honors `ns.CanCast()` itself, skips an entry that already matches `lastCastSpell` rather than recasting it, and always recasts on a one-entry cycle — pressing the key has to do something visible.

### Farm-State Detection

`ns.GetPlayerStates()` ([Features/Utilities.lua](Features/Utilities.lua)) returns `(isCat, isFarming, movementState)`. It scans up to 40 player buffs once, classifies the current movement state, then maps that state to its per-state toggle through `ns.MOVEMENT_STATE_TOGGLES`:

| Movement state | Detected by | Per-state toggle | Class gate (options only) |
| --- | --- | --- | --- |
| `taxi` | `UnitOnTaxi` | *(returns `false, false` immediately)* | — |
| `mounted` | `IsMounted()` and not in combat | `farmMounted` | all |
| `travelForms` | buff IDs in `ns.FARM_FORMS` | `farmTravelForms` | `DRUID` |
| `cheetah` | buff IDs in `ns.CHEETAH_BUFFS` | `farmCheetah` | `HUNTER` |
| `ghostWolf` | buff ID `ns.GHOST_WOLF` | `farmGhostWolf` | `SHAMAN` |
| `foot` | fallthrough | `farmNotMounted` (off by default) | all |

`isFarming` is true only when the master `farmMode` toggle is on **and** the current state's toggle is enabled. States are mutually exclusive in practice (mounting cancels forms and aspects), so the checks are ordered mounted → travel form → cheetah → ghost wolf → on foot. `ns.MOVEMENT_STATE_TOGGLES` and `ns.MOVEMENT_STATE_CLASS` ([Data/Data.lua](Data/Data.lua)) are the one place the set of states is written down, so detection, the options toggles, and the paused-reason strings cannot disagree about which states exist.

The class gates live only in the options UI (`ns.IsPlayerClass`, [Options/Options-Farm-Mode.lua](Options/Options-Farm-Mode.lua)) so a low-level character can pre-configure a toggle before learning the ability; detection itself is class-agnostic.

`isCat` is reported separately because Cat Form is not a farm state — it gates Druid Track Humanoids, which is mutually exclusive with the travel forms that put the player into farm state.

The scan sits behind a **frame-scoped memo** keyed on `GetTime()`, which is constant for the whole frame, so a cached answer can never come from a previous frame. `ns.UpdateIcon` and `ns.RunFarmLogic` each derive these states twice in one pass — directly, and again through `ns.GetFarmPauseReason` — and `FlushIconAfterTrackingChange` runs `UpdateIcon` eight times in about two seconds. Two bypasses are deliberate: while `ns.db` is nil the result is recomputed and never stamped, since `isFarming` reads the profile and the database appears mid-frame during `ADDON_LOADED`; and `ns:ApplyProfile` calls `ns.InvalidatePlayerStates()` first, since a profile switch rewrites the per-state toggles `isFarming` is derived from.

### Pause Reporting

Farm Mode goes quiet for reasons the player cannot see, which is the most common "is it broken?" report. `ns.GetFarmPauseReason()` answers that in one place, returning `(localeKey, isTransient)` or nil:

| Kind | Reasons |
| --- | --- |
| **Settled** (dims the icon) | dead; on a taxi; inside an instance or a `ns.RESTRICTED_MAP_IDS` map; resting; the cycle is empty; the current movement state's toggle is off; on foot with the on-foot toggle off |
| **Transient** (tooltip only) | our options panel open; any blocking window open; a tooltip showing; in combat; casting; stealthed; a loot window open; something on the cursor |

It returns nil when Farm Mode is switched off — that is not a pause, and the tooltip already reports Disabled. **The transient flag is the whole point of the second return value:** these clear on their own within seconds, and an icon that flickers through every fight and every gathered node reads as a bug.

The on-foot case gets special treatment. `GetMovementReason` names the states that *would* start the cycle, considering only the ones this class can reach, so a mage is never told about Ghost Wolf. Each combination is **one precomposed locale key** (`FARM_PAUSED_NOT_MOUNTED_TRAVEL`, `FARM_PAUSED_NOT_MOUNTED_CHEETAH`, …) rather than fragments joined at runtime: a comma-spliced sentence assembled from pieces cannot be translated correctly.

`ns.IsRestrictedZone()` and `ns.GetFarmPauseReason()` share one file-local `GetRestrictedKind()` helper, so the yes/no gate and the reason string can never disagree about what counts as restricted.

Two of the transient reasons are Farm Mode's own gates rather than `ns.CanCast()` conditions, so they stop the cycle without touching the manual key binding or the persistent recast: `ns.IsOptionsPanelOpen()` and `ns.IsTooltipShowing()`. The tooltip check deliberately excludes the add-on's own tooltip — the mini-map button and the free frame both draw into `GameTooltip`, and counting them would make the status block report "paused" every time the player hovered the icon to read it. `ns.minimapButton` is stored in `ns.InitMinimap` purely so that owner comparison can be made. `ns.IsBlockingWindowOpen()` sweeps `UIPanelWindows` rather than a hand-written list, so every standard window (merchant, mail, auction, quest, gossip, bank, trade) is covered at once and stays covered when Blizzard adds one; a short `EXTRA_BLOCKING_FRAMES` list adds the few that are never registered there (the game menu, the Settings panel, `StaticPopup1`).

The reason drives two surfaces: the dimmed icon and a status block at the top of the mini-map tooltip. Because several of these conditions fire no registered event — a taxi flight above all — `ns.RunFarmLogic()` re-resolves the reason on every tick **before its own bails** and calls `ns.UpdateIcon()` only when the value changed.

### Farm Cycle Cache

`BuildCycleCache()` builds a sorted, IDs-only array `cachedCycle` from every enabled entry in `ns.db.profile.farmCycleSpells`. It drops `ns.SPELLS.DRUID_HUMANOIDS`, requires `IsPlayerSpell`, and sorts so cycle order is stable across reloads.

It also appends `ns.db.profile.selectedSpellId` when `farmIncludePersistent` is on, guarded by a membership set so an ability that is both the persistent pick *and* ticked in the list appears **once** — queued twice it would take double the airtime of everything else. Because the cycle depends on `selectedSpellId`, every writer of that key invalidates the cache: the tracking menu's `info.func`, `ns.ClearTracking()`, and `ns.HandleTargetChanged()`.

`ns.InvalidateFarmCache()` nils the cache; it is invalidated on `SPELLS_CHANGED`, `PLAYER_ENTERING_WORLD`, on any profile change, and from each Farm Mode Abilities toggle's `set` handler, then rebuilt lazily on the next read. `ns.GetFarmCycleCount()` is the only reader of the cache's size outside this file — it builds the cache when nil and returns `#cachedCycle`, so nothing else needs to know the cache exists.

### Cycle Sound Mute

`ns.db.profile.muteCycleSound` (default `true`) silences the sound of Farm Mode's **own** automatic casts. Every automatic cast in [Features/Farm-Mode.lua](Features/Farm-Mode.lua) routes through one file-local seam, `CastCycleSpell(spellId)`; the tracking menu, `TryRecastPersistent`, `RecastAfterResurrection`, and Target Tracking all call `ns.CastTracking` directly and keep their sound.

**Why a CVar and not `MuteSoundFile`.** The tracking spells' cast audio is played by the engine from the spell's own SoundKit and never passes through `PlaySound` or `PlaySoundFile`, so no FileDataID is reachable from Lua and `MuteSoundFile` has nothing to take. Switching `Sound_EnableSFX` off is the only lever available.

**The window is the whole trick.** The audio does *not* fire inside `CastSpellByID` — it fires when the server confirms the cast, a round trip later — so muting and restoring around the call silences nothing. The mute is held until `UNIT_SPELLCAST_SUCCEEDED` reports our spell (`ns.NotifyTrackingCastSucceeded`, the usual path, typically well under 200ms) and lifted `ns.CYCLE_MUTE_TAIL_SECONDS` (0.1) after that, with `ns.CYCLE_MUTE_SECONDS` (0.6) as the ceiling for a cast the server never confirms. Restores are generation-stamped so overlapping casts cannot restore each other early.

This is a **write to a game-wide user CVar for a convenience**, which WRITING USER CVARS otherwise forbids, and it carries no `PrintMessage` notice because one on every cycle tick would be unusable. Four safeguards make it safe to ship:

- **The mute is armed only after a cast was actually attempted.** `ns.CastTracking` returns `true` when it reached `CastSpellByID` and `false` on each early bail (spell unknown, Cat Form gate, cooldown or GCD), and `CastCycleSpell` casts first and arms second. Arming afterwards is safe precisely because the audio plays on server confirmation, not inside the call.
- **`ns.RestoreCycleSoundNow()` restores unconditionally on teardown**, called from the `PLAYER_LOGOUT` handler in `Features/Core.lua` (which covers `/reload` as well as logout) and from the `muteCycleSound` toggle's `set` handler when the player switches the option off. `Sound_EnableSFX` persists across sessions, so a mute whose timer died with the UI would otherwise leave the player with sound effects off and nothing to connect it to.
- **The cast is wrapped in `pcall`**, so an error inside `ns.CastTracking` can never skip the restore and strand the player with sound switched off.
- **The CVar is only written when it is not already `"0"`.** A player who plays with sound effects off is never written to, and the restore puts back the exact string that was read.

The trade-off worth knowing: the toggle silences *all* sound effects for that instant, not just the tracking cast, so a sound already playing can be clipped. At a 3.5-second cycle this is rarely audible, which is why the option ships on: the repeated cast sound is noise the add-on itself creates, and the player never asked for those casts.

### Why Druid Track Humanoids Is Excluded

`ns.SPELLS.DRUID_HUMANOIDS` (5225) requires Cat Form, which is mutually exclusive with the travel forms that put the player into farm state. Including it in the cycle would mean casting a Cat-Form-gated spell from a non-Cat-Form context, which always fails. The exclusion lives in four places: `BuildCycleCache()` ([Features/Farm-Mode.lua](Features/Farm-Mode.lua)) skips the ID for both the list and the persistent entry, `BuildFarmAbilityArgs()` ([Options/Options-Farm-Mode.lua](Options/Options-Farm-Mode.lua)) never builds the toggle, `ns.CastTracking()` ([Features/Core.lua](Features/Core.lua)) guards on `isCat`, and `ns.CREATURE_TYPE_SPELLS` ([Data/Data.lua](Data/Data.lua)) omits it so Target Tracking can never select it. The tracking menu hides the entry unless the player is currently in Cat Form.

### Restricted Zones

`ns.IsRestrictedZone()` ([Features/Utilities.lua](Features/Utilities.lua)) returns true when `IsInInstance()` is true (any instance — dungeon, raid, battleground, arena), when the current instance map ID is in `ns.RESTRICTED_MAP_IDS` (currently only Deeprun Tram, 369), or when `IsResting()` is true (capital cities and inn rest areas). It stays intentionally simple: no capital-city or battleground tables and only a single map-ID special case. The trade-off is breadth — Farm Mode pauses anywhere the resting flag is set, which covers more than just the named cities.

## Target Tracking

`Features/Target-Tracking.lua` sets the Persistent Tracking Ability from the creature the player targets. It is opt-in (`ns.db.profile.targetTracking`, default `false`) and open to every class: whatever creature types a character can track, it can have set automatically. It is richest on a Hunter, who covers seven types, but a Paladin covers Undead and a Warlock Demons. It is drawn as a **sub-option of Enable Persistent Tracking** on the General panel and hides with it, because that is exactly what it modifies; it also hides for a character that covers no creature type at all. `ns.HasCreatureTypeTracking()` is the single predicate behind both the options section's `hidden` and the mini-map tooltip's status row, so the two can never disagree about whether the feature applies here.

`ns.CREATURE_TYPE_SPELLS` ([Data/Data.lua](Data/Data.lua)) is keyed by the client's **localized** creature-type globals (`BEAST`, `DEMON`, `DRAGONKIN`, `ELEMENTAL`, `GIANT`, `HUMANOID`, `UNDEAD`) because `UnitCreatureType` returns a localized string. That is what makes the feature locale-proof without a single locale key of its own. Every type is registered under **two** keys, the localized global and the English literal: the globals are what make this work in other locales, but they cannot be relied on to exist — a missing one previously dropped its whole creature type at load, and the feature then failed silently for that type with no error to show for it.

Each type maps to a **list** of candidate spells, not one: Undead is covered by the Hunter's Track Undead *or* the Paladin's Sense Undead, Demons by Track Demons *or* Sense Demons. `ns.GetCreatureTypeSpell(creatureType)` ([Features/Utilities.lua](Features/Utilities.lua)) walks them in order and returns the first the character has learned.

**It writes `selectedSpellId` rather than borrowing the tracking slot**, and that single decision is what keeps the module small. Everything downstream already reads that one key — the post-resurrection recast, the form-leave restore, `TryRecastPersistent`, and the farm cycle's optional persistent entry — so all of them follow for free. There is no hold flag, no revert path, and no need to suppress Persistent Tracking, which means the two features cannot fight each other.

`ns.HandleTargetChanged()` runs on `PLAYER_TARGET_CHANGED`. The bail chain:

- `ns.db` missing, `targetTracking` off, **or `persistentTracking` off** → clear any pending switch and stop. The parent gate is load-bearing: the options panel hides this control while Persistent Tracking is off, so a feature that kept acting would rewrite the saved ability and burn a GCD for something the player believes is switched off. Its own `targetTracking` key is never written by that gate — the setting survives and resumes when the parent comes back on.
- No target, or `UnitCanAttack("player", "target")` is false → stop. Friendly units never drive a switch; targeting a city guard is not a hunt.
- `UnitCreatureType("target")` has no entry in `ns.CREATURE_TYPE_SPELLS`, or no candidate spell is known → stop.
- It is already the selected ability → clear any pending switch and stop.
- `UnitAffectingCombat("player")` → store the ID in `pendingSpellId` and stop (see *Combat Lockdown*).
- Otherwise write `selectedSpellId`, invalidate the farm cache (the cycle can include the persistent ability), and cast immediately unless `ns.CanCast()` refuses. **It casts whether or not Farm Mode is running.** An earlier version deferred to the cycle whenever `isFarming` was true, which made the feature look broken in the state it is most used in: mounted, the pick becomes one entry in a rotation of three or four and is overwritten within seconds, so targeting a beast produced nothing visible. Casting now shows the pack at once and the cycle reclaims the slot on its next tick, which keeps the no-hold-flag design intact.

`ns.HandleRegenEnabled()` re-runs the whole decision rather than casting `pendingSpellId` directly — by the time the fight ends the target may be dead, swapped, or gone, and re-validating is cheaper than setting tracking from a corpse.

## Tracking Menu

`Features/Tracking-Menu.lua` builds one LibUIDropDownMenu dropdown at file scope and exposes `ns.ToggleMenu(anchor)`. Rows are every ID in `ns.TRACKING_IDS` that resolves a name and passes `IsPlayerSpell`, sorted by the **localized** name so the list reads alphabetically in every client. Druid Track Humanoids is hidden unless the player is currently in Cat Form.

Two rendering details are deliberate. LibDD only honors `info.fontObject` on *enabled* buttons, so the title and every ability row are built as enabled entries — the title simply carries no `func` — which is the only way to get the larger font. Spacer rows are `notClickable` entries with empty text, used between abilities to keep the list readable.

Picking a row writes `ns.db.profile.selectedSpellId`, invalidates the farm cache, clears `ns.state.wasFarming` (so the next non-farm tick does not fire a redundant form-leave restore of the ability just cast), and calls `ns.CastTracking` directly — **not** through `ns.CanCast()`, because a deliberate player click must always cast.

## Minimap Button & Free-Placement Frame

`ns.InitMinimap()` ([Features/Minimap-Button.lua](Features/Minimap-Button.lua)) registers a `LibDataBroker-1.1` launcher and hands it to `LibDBIcon-1.0` with the saved `ns.db.global.minimap` payload. `ns.CreateFreeFrame()` builds the standalone `Button` used when Free Placement Mode is on. `ns.UpdatePlacement()` toggles visibility between the two based on `ns.db.global.freePlacement`, honors the Enable Mini-map Button preference (`ns.db.global.minimap.hide`), and hides both when the player has no tracking abilities at all (`ns.HasTrackingAbility()`). Free Placement hides the LibDBIcon button without touching `minimap.hide`, so the preference survives a round trip through Free Placement and back.

### Tooltip

`ns.BuildTooltip` draws both surfaces. The **Farm Mode Status** block leads, because it is the only block that answers "why is nothing happening?" — it renders only while Farm Mode is enabled, shows Active in green or Paused in gray, and prints the localized pause reason underneath. Below it come the interactive blocks (Tracking Menu, Persistent Tracking Ability, Persistent Tracking, Farm Mode), each with its click hint, and two **status-only teasers** (Automatic Target Tracking, Silence Tracking Sounds) that report a setting's state with no click hint because they are operated from the options panel. Each teaser draws only while its setting is actually reachable, matching the condition its options row hides on, so the tooltip never advertises something the player cannot act on. The tooltip always ends with the options block.

`ns.RefreshTooltip()` re-runs the owning frame's `OnEnter` when the tooltip is already on screen, so a state change made by a click updates the text in place.

### Anonymous Free Frame

The free-placement frame is created with `nil` as its name on purpose. WoW's per-character `layout-local.txt` cache keys frames on their name; any named frame is looked up there at creation time and a cached position from a previous session is applied silently — overriding the account-wide `ns.db.global.freePos`. `SetUserPlaced(false)` from Lua does *not* prevent this lookup. Making the frame anonymous removes it from the layout-local system entirely, so positioning is owned 100% by `ns.db.global.freePos`.

### Position Pipeline

The frame uses two file-local helpers — `SaveFreePosition(frame)` and `ApplyFreePosition(frame)` — and a single stable anchor: `frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)`.

- **Storage format.** `ns.db.global.freePos = { x = number, y = number }` where `x` and `y` are the frame's center in *absolute screen pixels* (live `GetCenter()` multiplied by the frame's effective scale at save time). Storing absolute pixels means a later UI-scale or icon-scale change does not drift the saved position — both ends of the round trip convert through the frame's current effective scale.
- **Save points.** `OnDragStop` (after every drag), and `ns.SaveFreeFramePosition()` from the `PLAYER_LOGOUT` handler in [Features/Core.lua](Features/Core.lua) as a backstop, **guarded on the frame being shown**.
- **Why the logout save is guarded.** The absolute-pixel round trip is only exact when the frame's effective scale is the same at anchor time and at save time. `UpdatePlacement` returns early for a character with no tracking ability, skipping the `ApplyFreePosition` inside `UpdateFreeFrameScale` — so on that character the frame is anchored once during `ADDON_LOADED`, before `UIParent`'s effective scale settles to the `uiScale` CVar, and never re-anchored. An unguarded logout save then read stale offsets, multiplied by the *settled* scale, and wrote a drifted `freePos`. Because `freePos` is account-wide, that moved the icon for every character, compounding on each visit to the alt. `ns.SaveFreeFramePosition` bails unless `ns.freeFrame:IsShown()`, which also stops a never-dragged frame from materializing a `freePos` at screen center.
- **Apply points.** The end of `CreateFreeFrame` (initial restore), the end of `UpdateFreeFrameScale` (so `SetScale` does not shift the offsets), `UpdatePlacement` before `Show()` (defense against any code path that re-anchored the frame while hidden), and immediately after a drag (normalizing the live anchor back to the canonical `CENTER → BOTTOMLEFT` form).
- **`SetUserPlaced(false)`.** Called in both `OnDragStop` and `ApplyFreePosition`. `StartMoving` / `StopMovingOrSizing` silently flag any frame as user-placed for the rest of the session, and a stale flag can cause the client to write a layout-local entry on logout that out-races our SavedVariables on next login. Clearing it on every apply keeps the flag from sticking.

Shape is a texture swap, not a rebuild: `UpdateFreeFrameShape` shows either the circle pair or the square pair of textures created up front in `CreateFreeFrame`.

### Click Map

`OnClick` drives every interaction on both the LibDBIcon button and the free-placement frame:

| Modifier + Button | Action |
| --- | --- |
| Left-Click | Open the tracking menu. |
| Right-Click | `ns.ClearTracking()` — cancel and forget selection. |
| Shift + Left-Click | Toggle Persistent Tracking. |
| Shift + Right-Click | Toggle Farm Mode. |
| Shift + Middle-Click | Open the options panel (`ns:OpenOptionsPanel()`). |

Shift + Middle-Click is handled **before** the `ns.db` guard, so the options panel opens regardless of saved-variable state. `ns.ClearTracking()` nils `selectedSpellId`, invalidates the farm cache, calls `CancelTrackingBuff()`, and forces the icon to default immediately — `CancelTrackingBuff` is asynchronous and the mirror would still report the old texture for a frame otherwise.

### Blizzard Tracking Button Hook

`ns.ApplyBlizzardTrackingHook()` optionally makes Blizzard's own mini-map tracking icon — inert on these clients — open the Tracking Menu. It is gated on `ns.db.global.hookBlizzardTracking` (account-wide presentation, default `false`), called at the end of `ns.InitMinimap()`, from `ns:ApplyProfile`, and from the option's `set` handler. The frame is resolved as `MiniMapTrackingButton`, falling back to `MiniMapTracking`; `ns.HasBlizzardTrackingButton()` reports whether either exists and hides the option outright when neither does.

Three details are deliberate:

- **Take-over, not `HookScript`.** A hook would leave Blizzard's own handler running and open two menus at once, so the existing handler is saved and replaced.
- **Exactly one script is replaced** — `OnClick` where `HasScript` reports it, `OnMouseUp` otherwise. Replacing both fires the handler twice for a single click, which opens the menu and immediately closes it. `MiniMapTracking` is a `Frame` and has no `OnClick`, which is why the choice is probed rather than assumed.
- **Restore puts the frame back exactly as found.** Turning the option off re-installs the saved handler (including a nil one) and clears the saved state.

Neither frame is secure or protected on Classic Era or TBC Anniversary, so replacing their scripts raises no taint. A UI that swaps the button out *after* the hook is applied (ElvUI reskins, for instance) will receive the saved handler back on restore, which is the documented limit of the contract.

## Key Bindings

One binding ships, defined in `Bindings.xml` at the add-on root: `TRACKINGEYE_CYCLE_FARM_ABILITY`, which advances the Farm Mode cycle by a single step on demand. It is a **manual** control and is deliberately not gated on `ns.db.profile.farmMode` — pressing the key works with Farm Mode switched off, standing still, or anywhere the automatic cycle would be paused. It still routes through `ns.AdvanceFarmCycle()`, so it obeys `ns.CanCast()` exactly as the ticker does, and it prints `BINDING_NOTHING_TO_CYCLE` when the cycle is empty rather than failing silently.

The binding cannot be *set* from an AceConfig panel, so the General panel carries a Key Bindings section that points at the game's own Key Bindings list, using the same display name.

`Bindings.xml` is **auto-discovered from the add-on root and must never be listed in the TOC**. Listing it routes the file through the generic UI XML parser, which does not know the `<Bindings>` node and rejects the whole file with `Unrecognized XML: Bindings` warnings, so the binding never appears. Its root element is `<Bindings>` — not a `<Ui>` wrapper, which fails the same way. The `Binding` element carries `name` and **`category`**: the category string is what draws the collapsible **Tracking Eye** section in the Key Bindings list, and without it the binding loads but has nowhere to appear. `header` is a separate, older mechanism for sub-headings inside a category and is not used here.

## Client Assumptions

Both supported flavors — Classic Era 1.15.x and TBC Anniversary 2.5.x — run the modern client, so the modern API is what actually executes in practice. Every modern call is still **reached through an availability guard** with its legacy global behind it, per COMPATIBILITY ("Check the API exists, then call exactly one"). The guards cost nothing on a healthy client and turn a hard Lua error into a graceful degrade on one that is missing something.

- `C_AddOns.GetAddOnMetadata`, `C_AddOns.GetAddOnInfo`, and `C_AddOns.GetNumAddOns` resolve through `(C_AddOns and C_AddOns.X) or X`, falling back to the pre-`C_AddOns` globals. `GetVersion` returns `Dev` when neither resolves or when the value still carries the `@project-version@` token; `ns:BuildAddOnReport` emits a single "unavailable" line.
- `ns:OpenOptionsPanel` runs the full chain: combat gate, then `Settings.OpenToCategory(<captured categoryID>)` behind a `Settings and Settings.OpenToCategory` guard, then `InterfaceOptionsFrame_OpenToCategory(<captured frame>)` called twice, then `AceConfigDialog:Open` as a genuine last resort. Every route uses handles captured at registration, never a name or title lookup.
- Rows in `ns.DIAGNOSTIC_API_CHECKS` carry an optional third element. A row flagged optional is the legacy half of a guard, absent on a modern client by design: it renders `[n/a]` and never counts as a failure. Any other miss is a real problem.
- `ns.CastTracking` treats an active GCD as "on cooldown" rather than splitting the two. That is acceptable here and says so at the call site: tracking casts are cheap refreshes and every caller retries, so a GCD-blocked attempt is never lost.

**Find Fish (43308) is the one deliberate cross-flavor entry.** It exists on TBC Anniversary and not in the Era client's spell database at all, so on Era `GetSpellInfo` returns nil, the menu and the Farm Mode list skip it, and Diagnostics reports it as *not on this client*. See *Spell Data Caching* for the texture-cache rule that depends on this.

## Diagnostics

The Diagnostic Tools system ([Features/Diagnostics.lua](Features/Diagnostics.lua) + [Options/Options-Diagnostics.lua](Options/Options-Diagnostics.lua)) exists to make bug reports actionable. It is **not** a unit-test runner — WoW's sandboxed Lua has no assertion framework. Every report builds only on an explicit button press, and every check is read-only and side-effect free. The single exception is the Taint Log button, which sets the `taintLog` CVar.

- **Runtime-only state.** `ns.diagnostics = { enabled, logging, log }` is a plain namespace table, **not** a SavedVariable, so file-scope initialization is correct here. Nothing about diagnostics persists across sessions; it always starts off.
- **English-only strings.** Diagnostics text lives in `ns.DiagnosticsStrings`, intentionally **not** localized — it is developer-facing troubleshooting output. The only localized value it uses is the add-on's own display name (`ns.L["ADDON_TITLE"]`).
- **Enable gate.** A single runtime toggle (`ns:SetDiagnosticsEnabled`) shows the panel body; turning it off also stops any running event log. Because every gated widget shares that one condition, the panel bakes it into local `SectionHeader` / `ReportOutput` builders rather than repeating the predicate.
- **Reports.** Event Log, Event Registration (`ns.EVENT_NAMES` validated via `C_EventUtils.IsEventValid` plus a register/unregister round trip on a probe frame), API Endpoints (`ns.DIAGNOSTIC_API_CHECKS` existence and shape checks), Player & Spell Context (`ns.DIAGNOSTIC_SPELLS`, which is `ns.TRACKING_IDS`), Display Context, Farm Mode Context, Other Add-ons, Saved Variables dump, and Library Versions. Every report is prefixed with a client header (version, build, TOC, locale, `WOW_PROJECT_ID`).
- **The Farm Mode Context report is the add-on's own context probe** and answers most "it stopped cycling" reports in one paste: every toggle, the live movement inputs, the resulting `ns.GetPlayerStates()` classification, `CanCast` / `IsRestrictedZone`, the raw mirror value next to `lastCastSpell`, and the pause reason. The reason is printed as its **raw locale key**, never the translated string, so a report pasted from a zhTW client is still readable.
- **Event Log.** A 500-entry ring buffer fed by `ns:LogEvent` from the Core dispatcher, capped at 8 arguments of 255 bytes each, with pipes escaped **after** the length cut so a truncated argument cannot leave a dangling pipe. `ns.DIAGNOSTIC_EVENT_EXCLUDE` is deliberately empty: the log only ever sees events the add-on registered, and none of those is a firehose.
- **Taint Log.** `ns:SetTaintLog` writes the `taintLog` CVar (0 = off, 2 = verbose). This is the only state the panel ever writes.
- **External tools.** Rather than reimplement them, the panel points at `/console scriptErrors 1`, BugSack/!BugGrabber, and `/etrace`.

## Saved Variables

Tracking Eye declares exactly one SavedVariables table, `TrackingEyeDB`, managed by **AceDB-3.0**, and no `SavedVariablesPerCharacter` line. `ns.db` is the AceDB object and is the only way the add-on reads it.

**The add-on uses the Per-Character model:** the third `AceDB:New` argument is omitted, so each character lands on its own `"Name - Realm"` profile. **Reset Profile therefore clears that character's tracking and Farm Mode configuration only** — everything in `global` survives, so resetting or switching a profile never moves the mini-map button, changes the free-placement icon's shape or size, or brings the welcome message back.

- `ns.db.profile` holds this character's tracking state and Farm Mode configuration: the selected persistent ability, the Persistent Tracking / Farm Mode / Target Tracking master toggles, the cycle interval, the five per-movement-state toggles, the `farmCycleSpells` map, `farmIncludePersistent`, and `muteCycleSound`.
- `ns.db.global` holds account-wide presentation: the LibDBIcon `minimap` payload, the free frame's `freePos` / `freePlacement` / `freeIconScale` / `freeIconShape`, `showWelcome`, and `hookBlizzardTracking`.

Profiles are switched from the Profiles panel ([Options/Options-Profiles.lua](Options/Options-Profiles.lua), the stock AceDBOptions-3.0 table returned unmodified).

Defaults come from `ns.DATABASE_DEFAULTS` and are applied by AceDB-3.0 when a scope is first accessed — explicit user values, including `false`, are never overridden. Note that scalar and table defaults are physically copied into the saved table (`copyDefaults` via `rawset`); only `*`/`**` wildcard defaults resolve through metatables.

There is deliberately **no refill-on-empty logic**. `farmCycleSpells` is a settings map, not a re-seedable list: AceDB copies its concrete defaults with `rawset`, so the map iterates correctly for new users, and the options toggle stores an explicit `false` for a disabled spell. A user who turns every entry off keeps that state across logins. Storing `nil` instead would let AceDB re-add the default `true` on the next login and resurrect a spell the user turned off. `selectedSpellId` is likewise absent from the defaults — `nil` is its "unset" value and cannot be stored as a default, and `freePos` is absent because it is written only once the player drags.

No migration code ships. All migrations are retired: a stale key left behind by a long-gone storage shape simply lingers in that install's SavedVariables, harmlessly, and a returning player whose data predates the current shape falls back to defaults.

### Profile Apply

`ns:ApplyProfile` ([Features/Core.lua](Features/Core.lua)) is registered by name against all three AceDB profile callbacks and is the single settings-apply path. Only values read live from the database update themselves on a profile switch; everything applied imperatively has to be repeated here — the memoized player states, the farm cache and ticker interval, the icon placement, the free-frame scale and shape, and the Blizzard tracking-button hook. It ends by calling `ns.RefreshOptionsPanels()`, which iterates `ns.OPTIONS_REGISTRY` and fires `AceConfigRegistry:NotifyChange` for every registered name, so an options panel already on screen redraws instead of showing the profile the player just left. That same function is the general remedy for a setting changed from outside the panel — AceConfig only re-evaluates dynamic `name`, `disabled`, and `get` callbacks when it redraws.

### Reset

Reset is entirely stock: the AceDBOptions **Reset Profile** control on the Profiles panel resets the active profile only. The General panel carries no reset control, and there is no account-wide wipe.

## Adding a New Tracking Spell

1. Add a row to `SPELL_DATA` in [Data/Data.lua](Data/Data.lua) under the appropriate source (`{ spellId, key, source }`), and extend the SQL comment above the table so it stays regenerable. The loops below it populate `ns.SPELLS`, `ns.TRACKING_IDS`, and `ns.TRACKING_SET` automatically; form spells (listed in `FORM_KEYS`) are excluded from the tracking sets.
2. If the spell should be on by default in Farm Mode, add it to `ns.FARM_CYCLE_DEFAULTS` in [Data/Default-Settings.lua](Data/Default-Settings.lua). Existing users keep their saved map, so note the addition in release notes.
3. If it tracks a creature type, add it to the matching `CREATURE_TYPE_DATA` row in [Data/Data.lua](Data/Data.lua), in preference order, so Target Tracking can select it.
4. If the spell has special form gating (like Druid Track Humanoids), add a guard in `ns.CastTracking` ([Features/Core.lua](Features/Core.lua)), exclude it from `BuildCycleCache` ([Features/Farm-Mode.lua](Features/Farm-Mode.lua)), and exclude it from `BuildFarmAbilityArgs` ([Options/Options-Farm-Mode.lua](Options/Options-Farm-Mode.lua)).
5. No new locale strings are needed — the name and icon come from `GetSpellInfo` / `GetSpellTexture` at runtime, so they localize automatically. Only add a locale key if you also need a custom label or description.
6. Verify the menu and options hide the spell on characters that do not know it. The `IsPlayerSpell(id)` checks inside `BuildFarmAbilityArgs`'s `hidden` and inside `Tracking-Menu.lua`'s row loop are what gate visibility.

## Adding a New Registered Event

1. Add the event name to `ns.EVENT_NAMES` in [Features/Core.lua](Features/Core.lua). This is the single source of truth — the dispatcher registers from it and the Diagnostics *Event Registration* check validates against it, so both pick the event up together.
2. If the event is unit-filtered, add it to the `UNIT_FILTERED_EVENTS` map in the same file so it registers via `RegisterUnitEvent` rather than waking the dispatcher for every unit.
3. Add a branch to the `OnEvent` handler. Keep the branch ordering intact — `ADDON_LOADED` and `PLAYER_LOGIN` must stay ahead of the steady-state events.
4. Do not register the event on a second frame. One dispatcher, one registration list.

## Adding a New Farm Mode Pause Reason

1. Add the locale key to [Locales/enUS.lua](Locales/enUS.lua) beside the other `FARM_PAUSED_*` strings, as one complete sentence. **Never assemble a reason from fragments at runtime** — a comma-spliced sentence cannot be translated correctly, which is why every on-foot combination has its own precomposed key.
2. Return it from `ns.GetFarmPauseReason()` in [Features/Utilities.lua](Features/Utilities.lua), placed in the chain by priority. Return a second value of `true` if the condition clears on its own within seconds; omit it only for a settled condition that should dim the icon.
3. If the condition should also stop the cycle, add the matching bail to `ns.RunFarmLogic()` or to `ns.CanCast()`. Reporting a reason and stopping the cycle are separate decisions: a `ns.CanCast()` condition stops every automatic cast, while a `RunFarmLogic` bail leaves the manual binding and the persistent recast alone.
4. Grep `Locales/` for the key name before you commit to it — a retired key's translations survive in the other ten files and would silently serve the old string (see *Common Pitfalls*).

## Localization

Player-visible strings live in `Locales/<locale>.lua`, each registered through AceLocale-3.0's `NewLocale("TrackingEye", "<locale>")`. `enUS.lua` is the source of truth and the only file that passes the `true` default-fallback flag; every string originates there and the other locales translate from it. `Data/Data.lua` acquires the handle once (`ns.L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)`) and every file reads `local L = ns.L`.

This is **maintenance, not expansion** — WoW ships a fixed locale set and all eleven files already exist (`enUS, deDE, esES, esMX, frFR, itIT, koKR, ptBR, ruRU, zhCN, zhTW`). There is no "add a new locale" step.

- **Keeping locales in sync.** Every locale carries a translation of the same key set, and AceLocale falls back to English via `__index` for anything missing at runtime. Translating each `enUS.lua` key and keeping the files aligned is the job of the Localization pass (`3 - Copy Cleanup & Localization Prompt.md`); do not hand-edit the other locales during ordinary work.
- **Placeholders.** `%s` / `%d` count, type, and order must match `enUS` per key in every locale, or the string crashes at runtime. Two keys carry one today: `CHAT_LOADED` takes the version (formatted in `PrintWelcome`, [Features/Core.lua](Features/Core.lua)) and `OPTIONS_CYCLE_EVERY` takes the interval (formatted while building the dropdown values, [Options/Options-Farm-Mode.lua](Options/Options-Farm-Mode.lua)).
- **Spanish.** `esES.lua` and `esMX.lua` are two separate, self-contained files. Identical strings in both is correct and expected.
- **Locale overflow.** Neither 255-byte ceiling applies here: Tracking Eye writes no macros and calls `SendChatMessage` never — `ns:PrintMessage` is a plain `print`. The real constraint is layout, so the strings to eyeball are the long ones — the pause reasons, the option notes, and the welcome line — in the locales that render widest, usually deDE and ruRU.
- **Diagnostics strings are not localized.** They live in `ns.DiagnosticsStrings` ([Features/Diagnostics.lua](Features/Diagnostics.lua)), are developer-facing, and are intentionally English-only. Never add them to `Locales/`.
- **Target Tracking needs no locale keys of its own.** It keys off the client's localized creature-type globals, which is what makes it work in every locale for free.

## Common Pitfalls

- **Trusting `GetTrackingTexture` / `MINIMAP_UPDATE_TRACKING` as live state** — on Classic Era 1.15.x the tracking mirror lags reality, sometimes by minutes, and `nil` doubles as the normal "no tracking active" value. Comparing against it (or bailing on `nil`) silently disabled Farm Mode and Persistent Tracking on Era. Compare against `ns.state.lastCastSpell`, and treat the mirror as a positive signal only. The login-recast bug is prevented by the time-based grace window (`LOGIN_GRACE_SECONDS`), never by a `nil` bail.
- **Adding a second reader of the tracking mirror** — `ns.UpdateIcon` and all cast logic funnel through the single `ns.GetActiveTrackingSpell()`. Reading `MiniMapTrackingIcon` or `GetTrackingTexture()` directly anywhere else resurrects cleared tracking icons and re-poisons `lastCastSpell` through the adoption branch.
- **Persisting `ns.state.lastCastSpell`** — it is runtime-only, written solely by `UNIT_SPELLCAST_SUCCEEDED` via `ns.SetLastCast`. A value carried over from last session makes the farm cycle and persistent recast believe tracking is already up at login and skip every real cast. It is never written to `ns.db`.
- **Writing `lastCastSpell` from `ns.CastTracking`** — the cast can still fail silently (line of sight, range, server reject), and bookkeeping that records the attempt as a success suppresses the retry that would have fixed it.
- **Casting tracking during the GCD after shapeshift** — mitigated by `C_Timer.After(1.5, TryRecastPersistent)` on `UPDATE_SHAPESHIFT_FORM`. Removing the delay causes silent cast failures because the shapeshift GCD has not elapsed.
- **Swallowing a temporary bail in `TryRecastPersistent`** — in-combat, on-cooldown, in-flight, and debounce bails must `ScheduleRecast`, not `return` outright. On Era no further tracking event may fire, so a dropped trigger stops persistent tracking until the next login.
- **Testing the texture cache for completeness instead of using the dirty flag** — Find Fish does not exist on Era, so "every ID resolved" is unreachable and a completeness test rebuilds the whole table on every lookup miss. Keep `ns.InvalidateTextureCache()` as the only trigger.
- **Adding Druid Track Humanoids to the farm cycle or the creature-type map** — excluded on purpose (requires Cat Form, mutually exclusive with travel forms). Re-adding it queues casts that always fail.
- **Forgetting the second return of `ns.GetFarmPauseReason()`** — a reason returned without the transient flag dims the icon. Give a condition that clears within seconds (combat, casting, looting) the `true`, or the icon strobes through every fight and every gathered node and players report it as a bug.
- **Assembling a pause reason from fragments** — the on-foot reasons look like they want to be joined at runtime ("not mounted" + "not in Travel Form"). They are precomposed keys per combination because a comma-spliced sentence cannot be translated correctly.
- **Counting our own tooltip in `ns.IsTooltipShowing()`** — the mini-map button and free frame both draw into `GameTooltip`, so dropping the owner check makes the status block report "paused" every time the player hovers the icon to read it, which is the one moment it has to be accurate.
- **Arming the cycle sound mute before the cast** — `ns.CastTracking` returns `false` on every early bail, and muting for a cast that never happened switches the player's sound off for nothing. Cast first, arm second; that is safe only because the audio plays on server confirmation, not inside `CastSpellByID`.
- **Relying on the mute's timer to restore `Sound_EnableSFX`** — the CVar survives the session but the timer does not. Keep the unconditional `ns.RestoreCycleSoundNow()` calls on `PLAYER_LOGOUT` and on switching the option off, and keep the `pcall` around the cast.
- **Naming the free-placement frame** — reintroduces the `layout-local.txt` lookup the anonymous-frame fix avoids; a cached per-character position silently overrides `ns.db.global.freePos`. Keep the constructor's first argument `nil`.
- **Reading `GetPoint()` to serialize the free-frame position** — `StartMoving` / `StopMovingOrSizing` leave the frame on a non-canonical anchor; saving it causes drift on the next Show or scale change. Always round-trip through `SaveFreePosition` / `ApplyFreePosition`.
- **Skipping `SetUserPlaced(false)` after a position apply** — a leftover user-placed flag lets WoW write a layout-local entry on logout that out-races our SavedVariables on next login.
- **Saving the free-frame position from a frame that was never re-anchored** — `GetCenter()` returns frame-space coordinates, so `SaveFreePosition` is only correct when the frame's effective scale matches the one `ApplyFreePosition` last used. A character with no tracking ability never re-anchors (`UpdatePlacement` early-returns), so an unguarded save at `PLAYER_LOGOUT` re-encoded stale offsets against a different scale and corrupted the account-wide `freePos` for every character. Keep the `IsShown()` guard, and never add a new unconditional caller of `SaveFreePosition`.
- **Caching the options-open state, or reading it with `IsShown()`** — closing the Settings window hides the *window*, not our canvas, so the canvas keeps its own shown flag and its `OnHide` never fires. A flag cached behind Show/Hide hooks keeps the last value it saw (true) and pauses Farm Mode until the next reload, and `IsShown()` fails the same way. `ns.IsOptionsPanelOpen()` evaluates `IsVisible()` live on every call, which also requires every ancestor to be shown.
- **Deferring Target Tracking's cast to the farm cycle** — `ns.HandleTargetChanged` must cast immediately, not bail on `isFarming`. Handing the cast to the cycle looks correct on paper but is the same as not implementing the feature while mounted: the pick is one entry in a rotation and is overwritten within seconds. The cycle reclaiming the slot a tick later is the intended, harmless outcome.
- **Reusing a retired locale key name** — when a key is dropped from `enUS.lua` its translations stay behind in the other ten files, and AceLocale only falls back to enUS for keys a locale does *not* define. Reusing the name silently serves every non-English player the old string. Grep `Locales/` for any new key name before adding it; if it hits, pick a different name rather than editing the other locales, which the Localization pass owns.
- **Localizing Diagnostics strings** — they belong only in `ns.DiagnosticsStrings`, never in `Locales/`.
- **Reading `ns.db` before `ADDON_LOADED`** — AceDB creates `ns.db` inside the `ADDON_LOADED` handler in `Core.lua`. Any file-scope read of `ns.db` (or a bare `TrackingEyeDB`) runs before that and sees `nil`; every access is guarded (`ns.db and …`) and happens from runtime handlers, never at load.
- **Renaming a profile field without a migration** — AceDB's defaults only supply absent fields, so a rename leaves the old value stranded under the old key. Add a dated `MIGRATION` block in `ADDON_LOADED` that moves the value, and delete it when the date passes.
- **Storing `nil` to disable a `farmCycleSpells` entry** — AceDB re-adds the default `true` for any absent default key on the next login, so a disabled Herbs or Minerals would resurrect. The options toggle writes an explicit `false`; keep it that way.
- **Adding a setting that only `ns:ApplyProfile` would apply, and forgetting to add it there** — anything applied imperatively rather than read live from the database stays stale after a profile switch until the next `/reload`.

## Contributing

- **Issues:** open them at [github.com/Gogo1951/Tracking-Eye/issues](https://github.com/Gogo1951/Tracking-Eye/issues). For bug reports include: game version (Classic Era / TBC Anniversary), client locale, character class and level, exact reproduction steps, and any chat output or error text. The Diagnostic Tools panel (`/te` → Diagnostic Tools) produces copy-paste reports that carry most of this automatically — Farm Mode Context and Player & Spell Context answer the majority of reports on their own.
- **Discord:** [discord.gg/eh8hKq992Q](https://discord.gg/eh8hKq992Q) for discussion, screenshots, and quick questions.
- **Pull requests:**
    - Keep scope tight — one feature or fix per PR.
    - Run StyLua with its default configuration over every Lua file you touched. There is no `.stylua.toml`; the formatter owns whitespace.
    - Follow the style guide: no hardcoded user-facing strings (every player-visible string belongs in `Locales/enUS.lua`; Diagnostics strings are the deliberate English-only exception), `#` rather than `##` for TOC file-group headers, and comments only where the code cannot speak for itself.
    - Respect the Persistent Tracking and icon-resolution guards — read *Persistent Tracking* and *Icon Resolution* before touching those code paths.
    - Migration discipline: every field rename or storage-shape change ships with a dated `MIGRATION` tag, and tags past their date are deleted on sight.
    - Check output length for any string change that reaches chat or a macro. Tracking Eye currently has neither, so the check is a formality — but the moment a `SendChatMessage` call appears, the 255-**byte** ceiling applies and the canary is whichever supported locale encodes widest, usually ruRU rather than deDE.
    - When the architecture or file map changes, update this document in the same PR.

### Commit and PR descriptions require a User Story

Do not just say "I changed X" or "I fixed Y." Frame the change in terms of who it helps and why.

**Format:** *As a [role], I [needed / wanted] [behavior] so that [outcome]. This change [does X].*

**Example:** *As a druid who shapeshifts between Travel Form and caster form during a farming run, I wanted Tracking Eye to recast my saved tracking spell after the shapeshift instead of leaving me with no tracking buff. This change schedules a `TryRecastPersistent()` 1.5 seconds after `UPDATE_SHAPESHIFT_FORM` so the post-shift GCD has elapsed before the cast fires.*

The User Story makes review faster and gives future maintainers context the diff alone will not carry.
