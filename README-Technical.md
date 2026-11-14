# Tracking Eye // Technical Reference

> Code map for working on Tracking Eye: where things live, how they connect, and the traps. Where this and the code disagree, the code wins. For players, see [README.md](https://github.com/Gogo1951/Tracking-Eye/blob/main/README.md).

## File Map

```text
TrackingEye/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── config.yml                   The New issue page's links, kept per add-on
│   │   ├── defect.yml                   Common-Core's Defect form, copied unchanged
│   │   └── request.yml                  Common-Core's Request form, copied unchanged
│   └── workflows/
│       ├── ci.yml                       Calls Common-Core: Lua 5.1 syntax, luacheck, StyLua, offline tests
│       ├── issue-labels.yml             Calls Common-Core: fills a new issue's missing Area, Priority and Type labels
│       └── package.yml                  Calls Common-Core: CurseForge and Wago release, library refresh
├── .gitattributes                       Shared from Common-Core
├── .gitignore                           Shared from Common-Core
├── .luacheckrc                          Lint config; its globals list is exactly the add-on's sanctioned globals
├── .pkgmeta                             Externals and ignore list; strips Tests, Data/Wrath, Data/Mainline, dev READMEs
├── TrackingEye_Vanilla.toc              Classic Era; lists Data/Vanilla then Data/Discovery
├── TrackingEye_TBC.toc                  TBC Anniversary
├── TrackingEye_Camelot.toc              WoW Forever
├── TrackingEye_Mists.toc                MoP Classic
├── Bindings.xml                         The one key binding; found at the root, never listed in a TOC
├── Data/
│   ├── Flavor.lua                       Flavor identity and the data folder this client built, from the TOC
│   ├── Data.lua                         Locale handle, links, panel registry, option widths, movement-state maps, timings, channels, palette
│   ├── {Game}/                          Shipped: Vanilla, Discovery, TBC, Camelot, Mists. Dev-only, no TOC: Wrath, Mainline
│   │   ├── Spells-{Game}.lua            Tracking spells and forms, creature types, movement buffs, Farm Mode defaults
│   │   ├── Zones-{Game}.lua             Maps that count as restricted though not instances
│   │   └── Game-IDs-{Game}.lua          The sample herb the Come & Get It Example line names
│   └── Default-Settings.lua             The AceDB defaults, profile and global scopes
├── Diagnostics/                         Copied framework; Manifests.lua is Tracking Eye's own part
├── Features/
│   ├── Core.lua                         Version, welcome, AceDB init, prune, migration, profile apply, the dispatcher
│   ├── Utilities.lua                    Spell lookups, game names, colors, secret-value accessors, state predicates, settings refresh
│   ├── Announcements.lua                Branded print and the Come & Get It line builder
│   ├── Tracking-State.lua               Runtime state, tracking reads and clear, the icon, the cast primitive, pollers
│   ├── Persistent-Tracking.lua          Resolver, the on/off setter, mid-play recasts, movement parking, login grace, post-resurrection
│   ├── Farm-Mode.lua                    Cycle cache, the farm tick, form-leave restore, mini-map zoom, ticker
│   ├── Farm-Pause-Reporting.lua         Why Farm Mode is idle, plus the window, tooltip and own-menu checks
│   ├── Cycle-Sound-Mute.lua             The cycle's one cast seam and its momentary sound-effects mute
│   ├── Target-Tracking.lua              The hunt, and flight detection for the farm tick
│   ├── Come-and-Get-It.lua              Error match, gate, compose, chat draft
│   ├── Key-Bindings.lua                 The binding's two globals and the Set Key routes
│   ├── Menu-Kit.lua                     Generic menu plate and row kinds, no Tracking Eye knowledge
│   ├── Minimap-Menu.lua                 The menu's content, the button-click table, open and close rules, Blizzard button takeover
│   ├── Free-Placement.lua               The anonymous free frame, its position round trip, scale, shape and icon size
│   └── Minimap-Button.lua               LDB launcher, LibDBIcon, icon fit, placement, launcher handlers
├── Includes/
│   ├── Images/
│   │   ├── Menu-Plate.tga               The menu plate, from PWQL's Quest Arrow menu
│   │   └── Tracking-Eye.tga             Add-on icon
│   └── Libraries/                       Vendored, refreshed from .pkgmeta on every release; never hand-edited
├── Locales/                             AceLocale strings
├── Options/
│   ├── Options-Utilities.lua            The feature list ns.FEATURES, its switches and Features rows, row helpers
│   ├── Options-General.lua              Root panel: intro, Welcome Message, Mini-map Button, Features, Key Bindings, /Commands
│   ├── Options-Persistent-Tracking.lua  Persistent Tracking panel and its overrides
│   ├── Options-Farm-Mode.lua            Farm Mode panel and its Abilities sub-panel
│   ├── Options-Target-Tracking.lua      Automatic Target Tracking panel
│   ├── Options-Come-and-Get-It.lua      Come & Get It panel, its live Example line and the sample herb's load handler
│   ├── Options-Free-Placement.lua       Free Placement Mode panel
│   ├── Options-Profiles.lua             Stock AceDBOptions table, returned unmodified
│   ├── Options-Feedback-Support.lua     The mandated Feedback & Support panel
│   └── Options.lua                      Registration, /te, the options opener, panel-open check
├── Tests/                               Dev-only, stripped by .pkgmeta; runs on Lua 5.1
│   └── Run.lua                          Event-log noise filter and other-client character prune
├── LICENSE                              MIT
├── README.md
├── README-Notes.md
├── README-Technical.md
└── README-Testing.md
```

- Folders list files in TOC load order, dependency-first. Locales load before `Data/Data.lua` calls `GetLocale`; `Data/Flavor.lua` opens the data block; the flavor folder's files follow `Data/Data.lua`; `Data/Default-Settings.lua` closes it, because `ns.FARM_CYCLE_DEFAULTS` comes from the folder.
- `Data/Vanilla/` and `Data/Discovery/` files open with opposite `ns.IS_DISCOVERY` guards, so the one Vanilla TOC builds only one set.
- Every folder declares the same tables, empty where a flavor has no rows, so feature code never asks which flavor built one. Game IDs live only in the folders.
- `Data/Wrath/` and `Data/Mainline/` are forward prep: no TOC lists them and `.pkgmeta` strips them. Code still names `Mainline` (`ns.EXPANSION`, the icon fit) for when a TOC returns.
- `Options/Options-Utilities.lua` opens the Options block: every panel file aliases its helpers at file scope. The panel files follow in `ns.FEATURES` order; `Diagnostics/Options-Diagnostics.lua` loads inside the block, before `Options/Options.lua`.

## Architecture

### Namespace and Globals

- Every file takes `(ADDON_NAME, ns)`; everything shared hangs off `ns`.
- Globals, each because something outside the add-on's Lua must reach it:
    - `TrackingEyeDB`: the SavedVariables table. Only Diagnostics reads it raw; everything else goes through `ns.db`.
    - `SLASH_TRACKINGEYE1`, `SlashCmdList.TRACKINGEYE`: `/te`, in `Options/Options.lua`.
    - `TrackingEye_CycleFarmAbility`, `BINDING_NAME_TRACKINGEYE_CYCLE_FARM_ABILITY`: the binding system can only call a global, and names it by a matching global (`Features/Key-Bindings.lua`).
    - `TrackingEyeMenu`: the menu panel, named only so `UISpecialFrames` closes it on Escape. Its flyout is anonymous.
    - `TrackingEyeScanTooltip`: the hidden tooltip `ns.GetTooltipLines` reads where `C_TooltipInfo` lacks its getters; `GameTooltipTemplate` names its lines after the frame.
- `Core.lua` loads first yet calls most features: safe, since every call runs from an event and `ADDON_LOADED` fires after all files ran. Most calls are guarded (`if ns.RunFarmLogic then`); the icon, recast, restricted-zone and settings-refresh calls aren't, since everything depends on them.
- `ns.FEATURES` lives in `Options/Options-Utilities.lua`, which loads after `Features/`; `Features/Minimap-Menu.lua` reads it only while drawing, never at file scope.

### Event Loop

- One hidden frame in `Features/Core.lua` handles every event; Diagnostics' probe frame only tests registration. `ns.EVENT_NAMES` is the only list: the dispatcher registers from it, and Diagnostics' Event Registration reads it back.
- `UNIT_FILTERED_EVENTS` registers `UNIT_SPELLCAST_SUCCEEDED` for `"player"` only.
- While the diagnostics log runs, every event passes through `ns:LogEvent` first, behind a `ns.diagnostics.logging` check, so logging off costs nothing.
- Routing worth knowing:
    - `ADDON_LOADED` (own name): AceDB, prune, migration, profile callbacks, options registration, free frame, icon.
    - `PLAYER_LOGIN`: LDB and LibDBIcon (`ns.InitMinimap`), the farm ticker (`ns.InitFarmMode`), `ns.PollUntilTrackingReady`, welcome.
    - `UNIT_SPELLCAST_SUCCEEDED`: tracking spells only: `ns.SetLastCast`, the mute's early lift, icon.
    - `MINIMAP_UPDATE_TRACKING`: icon, `ns.FlushIconAfterTrackingChange`, `ns.ScheduleEventRecast`.
    - `UPDATE_SHAPESHIFT_FORM`, main-hand `PLAYER_EQUIPMENT_CHANGED`: `ns.ScheduleEventRecast`, delayed past the form's global cooldown.
    - `PLAYER_ENTERING_WORLD`: `ns.StartLoginGrace`, hunt end in a restricted zone (`ZONE_CHANGED_NEW_AREA` too), placement (`ns:ApplyMinimapButton`), farm and texture cache invalidation. `SPELLS_CHANGED` shares the last three.
    - `PLAYER_DEAD` → `ns.OnPlayerDead` arms the post-resurrection recast; `PLAYER_UNGHOST` and `PLAYER_ALIVE` → `ns.OnPlayerAlive` fire it.
    - `PLAYER_UPDATE_RESTING`: ends a hunt when resting starts, then runs `ns.RunFarmLogic` at once instead of waiting a tick.
    - `LOOT_OPENED`/`LOOT_CLOSED` drive `ns.state.lootWindowOpen`: speedy-loot add-ons hide `LootFrame` while looting is still open.
    - `PLAYER_LOGOUT`: `ns.SaveFreeFramePosition`, then `ns.RestoreCycleSoundNow`.
    - `UI_ERROR_MESSAGE`: `ns.OnUIErrorMessage`. `UPDATE_BINDINGS`: redraws the General panel.
    - `GET_ITEM_INFO_RECEIVED`: `ns.OnItemInfoReceived` (`Options/Options-Come-and-Get-It.lua`), which acts only while the Example line waits on the sample herb. Fires for every item the client loads.
- Bursts coalesce: `ns.ScheduleEventRecast` holds one pending recast behind its own flag, so a hunter's aspect spam (`UPDATE_SHAPESHIFT_FORM`) costs one recast.
- The farm ticker (`C_Timer.NewTicker`, `farmInterval`) runs whether or not Farm Mode is on: it is the only thing that sees a flight start or land, and the only refresh for pause reasons with no event.

### Combat Lockdown

No secure frames, no macros, no `PLAYER_REGEN_ENABLED`: nothing defers behind a dirty flag. Combat still decides:

- **Refuse:** `ns:OpenOptionsPanel` (Style Guide → Combat Guard), whichever way it is reached (`/te`, the menu's Options row or its button click, Free Placement Mode's More Features row), and the Set Key button's `ns:OpenKeyBindings`, which prints `CHAT_KEY_BINDINGS_IN_COMBAT` the same way.
- **Refuse and retry:** every automatic cast and the binding go through `ns.CanCast()`, false in combat. The ticker and form-leave restore retry next tick, `TryRecastPersistent` through `ScheduleRecast`, the post-resurrection recast after `RECAST_DEBOUNCE_SECONDS`, the hunt after `HUNT_RETRY_SECONDS`. The binding waits for the next press.
- **Drop, never replay:** a target picked in combat never starts a hunt; a Come & Get It draft in combat is discarded.
- **Secret values** on WoW Forever, below.

### Reading and Clearing Tracking

- `ns.GetActiveTrackingSpell()` (`Features/Tracking-State.lua`) is the only reader. Order: `MiniMapTrackingIcon` while visible (authoritative on Classic Era, where `GetTrackingTexture` misses racials), then `GetTrackingTexture` where shipped (its nil is final), then the `C_Minimap` list (WoW Forever, which has neither). README-Notes → Legacy tracking reads.
- `C_Minimap` entries count only when backed by one of the add-on's spells (`spellID`, or texture for a spell entry without one), so a town service never reads as tracking.
- `ns.CancelActiveTracking()` is the only clear: `CancelTrackingBuff` where shipped, else `C_Minimap.SetTracking(index, false)` per own entry. Never `ClearAllTracking`.
- **The mirror is a positive signal only.** On Classic Era it lags by up to minutes and nil also means "nothing tracked". A read naming the spell means "skip the cast"; anything else falls through to a cast, which is a harmless refresh.

### Decide → Cast → Confirm (Main Pipeline)

1. **Decide.** The menu pick, `ns.GetPersistentSpell()` for every Persistent Tracking recast, the farm cycle, or a hunt. Automatic callers check `ns.CanCast()`.
2. **Cast.** `ns.CastTracking(spellId)`: `IsPlayerSpell`, the Cat Form gate, cooldown or GCD (treated alike: every caller retries), stamps `ns.state.lastTrackingCastAt`, `pcall(CastSpellByID)`. Returns true only when it reached the cast. It doesn't check `ns.CanCast()`: a menu click must always cast.
3. **Confirm.** `UNIT_SPELLCAST_SUCCEEDED` → `ns.SetLastCast`. The cast never writes `lastCastSpell`: a silent failure recorded as success suppresses the retry.

- `ns.SetLastCast` is the only writer of `lastCastSpell`, on evidence: the success event, `ns.UpdateIcon` adopting pre-session tracking, `TryRecastPersistent` finding the spell up. Cleared by Clear Tracking and by leaving Cat Form with Cat Form tracking recorded. Runtime-only.
- In-flight windows while the mirror catches up: `ns.CAST_IN_FLIGHT_SECONDS` for casters, `ns.ICON_IN_FLIGHT_SECONDS` for the icon. `ns.state.mirrorConfirmedCast` latches once the mirror reports `lastCastSpell`; after that a nil read is a real cancel.

### Icon Resolution

- `ns.UpdateIcon()` reads only `ns.GetActiveTrackingSpell()`. Steps: drop Cat Form tracking from `lastCastSpell` outside Cat Form; adopt the active spell only while `lastCastSpell` is nil; latch `mirrorConfirmedCast`; show the active spell, or `lastCastSpell` inside the icon window until the latch, else `ns.ICON_DEFAULT`.
- No fallback to the saved pick: every such fallback showed a stale icon. The icon never dims for a pause; the menu's Farm Mode Status is the one surface.
- It also caches the pause reason (`ns.state.farmPauseReason`, `farmPauseState`; its only writer) and redraws an open menu.
- `ns.ClearTracking()` is the other writer: forces the default icon, since the cancel is asynchronous, then `ns.RefreshSettings()`, since the pick it clears is a saved setting.
- Pollers in `Features/Tracking-State.lua` only shave latency: `ns.PollUntilTrackingReady` at login until the Blizzard icon has a texture; `ns.FlushIconAfterTrackingChange` re-runs the icon a few times after a tracking change, coalesced by a flag.

### Caching

- **Texture reverse map** (`Features/Tracking-State.lua`): texture → spell, built lazily from `ns.TRACKING_IDS`. Cold `C_Spell.GetSpellTexture` nils during the login storm leave gaps, so `SPELLS_CHANGED` and `PLAYER_ENTERING_WORLD` mark it dirty (`ns.InvalidateTextureCache`). Never a completeness test: an ID the client lacks never resolves.
- **Names are never stored.** Spell names and icons come from `C_Spell` at runtime; a nil name filters the ID out of every list. The `ns.Get*Name*` helpers in `Features/Utilities.lua` return `""`, never typed text, while a record is cold.
- **Player states** (`ns.GetPlayerStates`): a frame-scoped memo keyed on `GetTime()`. Recomputed unstamped while `ns.db` is nil; `ns:ApplyProfile` and the menu's condition toggles call `ns.InvalidatePlayerStates()`.
- **Farm cycle** (`Features/Farm-Mode.lua`): below.
- **No item cache.** `ns.IsFishingPoleEquipped` uses `C_Item.GetItemInfoInstant`, which never comes back cold. The Come & Get It Example's herb name (`C_Item.GetItemNameByID`) shows `SAMPLE_LOADING_ITEM` with the ID, requests the item, sets a waiting flag, and redraws that panel when `ns.OnItemInfoReceived` sees `ns.SAMPLE_HERB_ITEM_ID` arrive.

### Secret Values

- WoW Forever carries Retail's secret values: in combat an aura read throws, and cooldown, casting, identity and unit-stat reads can't be compared. `C_Secrets` (called directly on every flavor) answers first; each read sits behind an accessor in `Features/Utilities.lua` with a safe default:
    - `ns.GetSpellCooldown`: nil (not cooling down; the cast decides).
    - `ns.IsPlayerCasting`: true (hold and retry).
    - The buff scan behind `ns.GetPlayerStates`: the last readable scan.
    - `ns.GetUnitCreatureType`: nil (no hunt).
    - `ns.IsPlayerMoving`: false (wait for movement).
- `ns.HasAttackableTarget`'s reads and `UnitIsPlayer` never go secret and are called directly. Diagnostics probes read through the same accessors.

### Client Differences

- The TOC decides the flavor: `Data/Flavor.lua` reads `## X-Flavor` and the active season, never `WOW_PROJECT_ID`.
- Each difference lives in the first place that can hold it: the data (a missing row hides its option: Find Fish's override where `ns.SPELLS.FISH` is nil, a condition where `ns.IsMovementStateDetectable` is false); API presence (tracking reads, zoom buttons, Set Key routes, tooltip read), never a truthy result; frame presence (the Blizzard button takeover); secret values.
- The one direct flavor test in feature code is the icon fit in `ns.InitMinimap`.

### Settings Refresh

- `ns.RefreshSettings()` (`Features/Utilities.lua`) is where every settings change ends: `NotifyChange` on every `ns.OPTIONS_REGISTRY` panel, then `ns.RefreshMenu()`. Every panel setter, every menu row and button click, `ns.ClearTracking` and `ns:ApplyProfile` call it.
- AceConfig re-evaluates a widget's dynamic `name`, `get` and `hidden` only on a redraw, and the menu redraws only when told: a writer that skips it leaves both showing the old value.
- `UPDATE_BINDINGS` and the sample herb's load notify only their own panel.

### Persistent Tracking

- **Resolver:** `ns.GetPersistentSpell()` (`Features/Persistent-Tracking.lua`), first match wins, each override requiring the spell known: Track Humanoids in a battleground or arena (`battlegroundHumanoids`), Druid Track Humanoids in Cat Form (`catFormHumanoids`), Find Fish with a pole in the main hand (`fishingPoleFish`), the running hunt while out in the world, then `selectedSpellId`. Every restore path reads it, so none knows about overrides or hunts.
- **On/off:** `ns.SetPersistentTracking(enabled)`, shared by the options switch (through `ns.FEATURES`) and the menu's Toggle row. Switching on calls `TryRecastPersistent` at once.
- **Mid-play recast:** `TryRecastPersistent` (exported as `ns.TryRecastPersistent`). Bail chain: off or nothing resolved; in a farm state; unknown spell; inside `LOGIN_GRACE_SECONDS`; provably up (sync `lastCastSpell`, re-latch, stop: this ends retry chains); own cast in flight (reschedule); standing still (park); `ns.CanCast()` refuses, cooldown, or inside `RECAST_DEBOUNCE_SECONDS` of the last attempt (reschedule); else cast.
- **Temporary bails retry, never swallow.** On Era no further tracking event may fire. `ScheduleRecast` coalesces behind `recastRetryPending`, separate from the event-burst flag.
- **Waiting for movement:** with `ns.IsPlayerMoving()` false, the recast and the post-resurrection recast park in a set with no timer. `PLAYER_STARTED_MOVING` → `ns.OnPlayerStartedMoving` runs them once after `MOVEMENT_SETTLE_SECONDS`; the set is swapped before the calls and each re-checks. The farm tick holds the same way. A hunt's cast doesn't wait.
- **Login blackout:** `ns.StartLoginGrace` anchors `ns.state.enteredWorldAt` on every `PLAYER_ENTERING_WORLD` and schedules a catch-up recast after the window. Solved by time, never by reading nil.
- **Post-resurrection:** `ns.OnPlayerAlive` never consults the mirror (resurrection really clears tracking). Armed only by `ns.OnPlayerDead` (`PLAYER_DEAD`, or entering the world dead): `PLAYER_ALIVE` also fires at login and on releasing spirit. `resurrectRecastPending` coalesces the corpse-run pair. Lasting bails end the chain; a `ns.CanCast()` or cast refusal retries after `RECAST_DEBOUNCE_SECONDS`.
- **Profile change:** `ns:ApplyProfile` ends any hunt, then calls `ns.TryRecastPersistent()` itself, since `ns.EndHunt` recasts only when a hunt was running.

### Farm Mode

- **Tick:** `ns.RunFarmLogic()` (`Features/Farm-Mode.lua`), in order: `ns.HandleFlightState`; re-resolve the pause reason and refresh only on change (above every hold, so the status stays honest); stop without `ns.db`, or with Farm Mode off and no run to wind down (`wasFarming` clear); hold for an options panel, a blocking window, an attackable target, any other tooltip, the own menu; hold while standing still; **form-leave restore**; Farm Mode off; restricted zone; not in a farm state or `ns.CanCast()` refuses; empty cycle; run start (zoom out, end any hunt); cast; set `wasFarming`.
- **Form-leave restore** runs ahead of the Farm Mode and restricted-zone gates, so switching Farm Mode off mid-run or dismounting in town still restores the ability. `wasFarming` stays set until the restore reports done; a temporary refusal retries next tick.
- **Cast step:** a one-entry cycle recasts only when not provably up and not in flight (how an outside cancel gets noticed). Longer cycles go through `ns.AdvanceFarmCycle()`, which skips an entry equal to `lastCastSpell` and is shared with the binding.
- **`ns.CanCast()`** (`Features/Utilities.lua`): dead or ghost, stealthed, casting or channeling, combat, loot window open, something on the cursor. A cast ends a channel, closes a Classic loot window, and drops a cursor item.
- **Farm states:** `ns.GetPlayerStates()` returns `(isCat, isFarming, movementState)`. States: `taxi` (never farming), `mounted`, `travelForms`, `cheetah`, `pack`, `ghostWolf`, `foot`, checked in that order. `ns.MOVEMENT_STATE_TOGGLES`, `ns.MOVEMENT_STATE_CLASS`, `ns.CLASS_STATE_ORDER` (`Data/Data.lua`) tie each to its toggle, class, and place in the on-foot reason. Cat Form counts as `foot`; `isCat` only gates Cat Form tracking. No Eagle Eye state: a cast ends that channel.
- **Cycle cache:** `BuildCycleCache` sorts every enabled, known `farmCycleSpells` entry, Cat Form tracking only in Cat Form, plus the resolved persistent spell once when `farmIncludePersistent` is on (a duplicate would double its airtime). It records the Cat Form state it was built for; `EnsureCycleCache` rebuilds on change. `ns.InvalidateFarmCache()` on `SPELLS_CHANGED`, entering the world, main-hand change, profile change, hunt change, pick or clear, and every relevant toggle. `ns.GetFarmCycleCount` and `ns.GetFarmCycle` (a copy, for Diagnostics) are the outside readers.
- **Pause reporting:** `ns.GetFarmPauseReason()` (`Features/Farm-Pause-Reporting.lua`) returns a locale key and, for movement reasons, the state whose buff the sentence names; `ns.FormatFarmPauseReason` fills names. Nil while Farm Mode is off. Settled reasons first (dead, taxi, instance, resting, empty cycle via `ns.GetEmptyCycleKind`, movement), transient ones only while farming. Each pairing is one precomposed key.
- **The own menu holds but is never a reason.** Opening the menu is how the player reads Farm Mode Status, so the status names what Farm Mode would be doing apart from the menu. `ns.IsTooltipShowing` ignores a `GameTooltip` owned by a menu row (`ns.IsMenuFrame`); `ns.IsOwnMenuShowing` is checked only by the tick.
- **Holds vs `ns.CanCast()`:** options panel, window, tooltip, own menu, target and standing still are tick holds; they stop the cycle but not the binding. A `ns.CanCast()` condition stops both.
- **Window and panel checks:** `ns.IsBlockingWindowOpen` sweeps `UIPanelWindows` plus `EXTRA_BLOCKING_FRAMES`. `ns.IsOptionsPanelOpen` (`Options/Options.lua`) reads `IsVisible()` live across every frame `Register` captured.
- **Mini-map zoom:** `ZoomMinimapOutForRun` on the run's first casting tick only; never puts the player's zoom back; re-enables zoom-in and disables zoom-out on whichever button pair the client has.
- **Cat Form tracking:** `ns.CAT_FORM_ONLY` (`Features/Utilities.lua`). Gated in `ns.CastTracking`, `BuildCycleCache`, `ns.GetEmptyCycleKind`, the form-leave restore, the post-resurrection recast and `ns.UpdateIcon`; never a Persistent Tracking pick in the menu (the Cat Form override covers it); absent from `ns.CREATURE_TYPE_DATA`.

### Cycle Sound Mute

- Every cycle cast (ticker and binding) goes through `ns.CastCycleSpell` (`Features/Cycle-Sound-Mute.lua`); every other cast calls `ns.CastTracking` and keeps its sound.
- `Sound_EnableSFX` is the only lever: the cast audio is the spell's SoundKit, never `PlaySound`, so `MuteSoundFile` has nothing to take.
- The audio fires on server confirmation, not inside `CastSpellByID`. The mute holds until `ns.NotifyTrackingCastSucceeded` plus `ns.CYCLE_MUTE_TAIL_SECONDS`, capped by `ns.CYCLE_MUTE_SECONDS`; restores are generation-stamped.
- Cast first, arm second; nothing written when SFX is already off; the exact read value is restored; `ns.RestoreCycleSoundNow` on logout and when the option is switched off (panel and menu alike).

### Restricted Zones

- `ns.GetRestrictedKind()` (`Features/Utilities.lua`): `"instance"` for `IsInInstance()` or an instance map ID (eighth return of `GetInstanceInfo`) in `ns.RESTRICTED_MAP_IDS`; `"resting"` for `IsResting()`. `ns.IsRestrictedZone` and the pause reason share it.
- Deliberately simple: no city or battleground tables. Farm Mode pauses wherever resting is set and reacts only as fast as the client sets it. `Features/Core.lua` cites this section.
- `ns.IsOutInTheWorld()` adds "not on a taxi", for Automatic Target Tracking.

### Automatic Target Tracking

- `Features/Target-Tracking.lua`. Out in the world, the targeted creature's kind stands in for the pick. Runtime only (`ns.state.huntSpellId`); nothing automatic writes `selectedSpellId`.
- Keyed by creature type ID (`UnitCreatureType`'s second return, locale-proof). `ns.CREATURE_TYPE_SPELLS` is built from `ns.CREATURE_TYPE_DATA`; `ns.GetCreatureTypeSpell` returns the first known candidate.
- `ns.OnPlayerTargetChanged` bails: feature off; not out in the world, or in combat; no living attackable target, or a player; no known candidate; same hunt. Otherwise set the hunt and cast at once.
- Each hunt change bumps `huntGeneration` (retiring old retries), invalidates the farm cache, refreshes the icon. The cast skips while farming without `farmIncludePersistent`.
- Ends only at a context break, via `ns.EndHunt(restorePersistent)`: a Farm Mode run starting, resting, a restricted zone, a flight (`ns.HandleFlightState`, restore after landing), a menu pick, Clear Tracking, the feature off (`ns.SetTargetTracking`, behind the switch, the menu row and its click), a profile change. Run start, pick and Clear pass false; they set tracking themselves.

### Come & Get It

- Gate → detect → compose → write, entered from Core's `UI_ERROR_MESSAGE` through `ns.OnUIErrorMessage`.
- **Gate** `CanAnnounce`, before any matching: toggle (`ns.db.global.comeAndGetIt`), not in an instance, not in combat, `ns.ANNOUNCE_COOLDOWN`.
- **Detect** `ns.MatchError(messageID, message)`: `ERROR_STRING_MAPPING` by GlobalStrings name via `GetGameMessageInfo` (locked chests, `ns.ERROR_STRING_LOCKED_CHEST`), then `SKILL_MAPPING` by lowercased substring of `L["MATCH_HERB"]`/`L["MATCH_MINE"]`, each may list several names split on `;`. Kept on `ns` for the Diagnostics noise filter.
- **Compose** `AnnounceNode`: map, position (exact `0, 0` bails), zone, node name from `GameTooltipTextLeft1` only while `GameTooltip:IsShown()`, bail when the tooltip shows an item (bag lockboxes raise the same error). Line from `ns:BuildAnnounceMessage` (`Features/Announcements.lua`), pipes stripped.
- **Write** `ChatFrameUtil.OpenChat(command .. " " .. line, ChatFrame1)`, skipped while the player is typing; cooldown stamped only after an open. Over `ns.CHAT_MESSAGE_MAX_LENGTH` bytes prints `CHAT_TOO_LONG` but opens whole, measured without the command.
- **Draft shape:** `/1 Hey Miners! Rich Thorium Vein at 25, 54 in Eastern Plaguelands.` Each `MSG_FORMAT_*` body has four `%s`: node, x, y, zone. No marker, no add-on name: it is the player's line.
- **Channels:** `ns.OUTPUT_CHANNELS` (`Data/Data.lua`) drives the command lookup, the dropdown and the Example line. Blizzard channels label with `labelGlobal`; Local uses `labelKey`. A stale saved key falls back to `ns.DEFAULT_OUTPUT_CHANNEL`.
- **Example line** (`Options/Options-Come-and-Get-It.lua`): the herb draft as it would land in the picked channel, built with the same `ns:BuildAnnounceMessage`, the channel's chat color and `prefixGlobal`, and `ns.SAMPLE_HERB_ITEM_ID`.
- The Default Output note under the dropdown is on the panel by exception (README-Notes → Default Output note).

### Mini-map Menu

`Features/Minimap-Menu.lua` cites this section. Every row is a plain click, so a controller cursor reaches everything; the launchers also keep modifier clicks, each a shortcut for one row.

- **Blocks:** header (name, version), then per feature a gold title with its state on the right, a white `MENU_*_DESCRIPTION` line, and a blue Toggle row (tooltip from its Enable option). Then More Features, a separator and the Options row.
    - **Persistent Tracking:** On/Off. Known abilities as choice rows inside the block (never Cat Form tracking; works with the feature off); Toggle goes through `ns.SetPersistentTracking`; Clear Tracking under Toggle while something is picked. Flyout: the overrides whose spell this character knows, while on.
    - **Farm Mode:** Active, Paused or Off. Flyout while on: Farm Mode Status and its reason note, Include Persistent Tracking Ability, known abilities (Cat Form tracking included), conditions (`ns.KnowsMovementState`), Silence Sounds, Zoom Mini-map Out.
    - **Automatic Target Tracking:** shown only when `ns.KnowsHuntAbility()`; no flyout; Toggle goes through `ns.SetTargetTracking`.
    - **More Features** (`MENU_MORE_FEATURES`): one On/Off row per `ns.FEATURES` entry without `block` (Come & Get It, Free Placement Mode). An entry with `opensOptions` opens that panel instead of switching (README-Notes → Free Placement Mode opens options).
- **Button clicks:** `CLICKS` is one table read both ways. `ns.HandleLauncherClick` (`Features/Minimap-Button.lua`) asks `ns.RunButtonClick(button)` first, which matches button and Shift state, runs the job and calls `ns.RefreshSettings()`. The row doing the same job is built with `ClickRow`, which shows the click's `MENU_CLICK_*` name on the right in gray and runs the same `run`. Jobs: Clear Tracking, Farm Mode's and Target Tracking's Toggle rows, the Options row. A plain Left-Click has no job, so it opens the menu and holds it longer. Before `ns.db` exists every click except Options is swallowed.
- **Rules:** a title opens a flyout only when it has rows (else it is a plain `status` heading). Class rows show only to a character who knows the spell, tested by character, never by form, mount, zone or gear; the options keep every row. Picks close the menu; switches keep it open. The display toggles, Cycle Speed, Come & Get It's channel and Free Placement's shape and size stay on the options pages.
- **Picks** (`PickPersistent`): end any hunt without restore, write `selectedSpellId`, invalidate the farm cache, clear `wasFarming`, `ns.CastTracking` directly. The menu is the only way to set the pick; a cast from anywhere else is never adopted as one.
- **Every change** ends in `ns.RefreshSettings()`, which redraws the menu and any open panel.
- **Open and close:** `ns.ShowMenu(anchor, flyoutKey, how)` from hover or left-click, placed away from the nearest screen edges. An `OnUpdate` closes it `HOVER_CLOSE_DELAY` (or `CLICK_CLOSE_DELAY` after a click) once the cursor leaves launcher, menu and flyout; also on launcher hide, Escape, a pick. Entering a title opens its flyout; entering any other row closes it.
- **Cursor test:** `ns.MenuKit.IsCursorOver` reads `GetCursorPosition`, which a controller's virtual cursor also reports.
- **Menu Kit** (`Features/Menu-Kit.lua`): add-on agnostic (no Tracking Eye names), meant to move to Common-Core. `CreatePanel`, `panel:Render(entries)`, row kinds listed in its header comment, palette keys for color. One font size; kinds differ by color. A spacer is inserted above every heading. Plate is nine-sliced at half size.
- **Blizzard button takeover:** `ns.ApplyBlizzardTrackingHook()`, gated on `ns.db.global.hookBlizzardTracking`. Only where `MiniMapTracking` exists without `MiniMapTrackingButton` (Classic Era, `ns.HasBlizzardTrackingButton`); elsewhere that button opens Blizzard's own menu on mouse-down, which no script swap stops, and the option hides. Replaces `OnMouseUp` (not `HookScript`) with a menu open on any button, no click jobs, and restores the saved handler, nil included.

### Mini-map Button and Free Placement

- `ns.InitMinimap()`: LDB launcher (`label` is the add-on title) with `OnEnter` (not `OnTooltipShow`) so every display opens the menu on hover; LibDBIcon with `ns.db.global.minimap`. On Camelot and Mainline the icon is sized, anchored and masked by hand.
- `ns:ApplyMinimapButton()`: no tracking ability → neither shows. Free Placement on → free frame shows, LibDBIcon hides without touching `minimap.hide`. Ends by re-applying the free frame's scale and shape.
- `ns.HandleLauncherEnter`/`ns.HandleLauncherClick` serve both launchers; both take every mouse button (the free frame registers `AnyUp`, and drags on the left button).
- **Free frame** (`Features/Free-Placement.lua`): created with a `nil` name. Position is `ns.db.global.freePos`, the center times effective scale, anchored `CENTER` to `UIParent` `BOTTOMLEFT`; `SaveFreePosition`/`ApplyFreePosition` round-trip it. Saved on drag stop and at logout only while shown. Re-applied after create, after `SetScale`, before every show, and after a drag. `SetUserPlaced(false)` on every apply.
- **Shape:** `ns.UpdateFreeFrameShape` swaps prebuilt textures and resizes the icon (`CIRCLE_ICON_SIZE` fits Blizzard's tracking border, `SQUARE_ICON_SIZE` lines up with action buttons); the square border is the square icon plus one point a side.

### Key Bindings

- `TRACKINGEYE_CYCLE_FARM_ABILITY` → `TrackingEye_CycleFarmAbility` → `ns.AdvanceFarmCycle()`. Manual: not gated on `farmMode`, but obeys `ns.CanCast()`. An empty cycle prints its reason from `EMPTY_CYCLE_MESSAGES`, keyed by `ns.GetEmptyCycleKind`.
- General's Key Bindings row shows the bound key and a Set Key button. `ns:OpenKeyBindings` tries `Settings.KEYBINDINGS_CATEGORY_ID`, then the Settings category list by title, then `KeyBindingFrame`, then prints `KEY_BINDINGS_LOCATION`.
- `Bindings.xml`: root element `<Bindings>`, `category` attribute draws the list section.

### Options Panels

- **Features:** `ns.FEATURES` (`Options/Options-Utilities.lua`) lists every feature once, in the order the root panel's Features section, the panel tree and the menu draw them. Each names its store (`profile` or `global`), setting, menu name, Enable caption and description, and `apply`; `block` makes it a menu block, `opensOptions` names the panel its More Features row opens.
- **Panels,** registered in `ns.RegisterOptionsPanels()` after `AceDB:New` (the Profiles builder reads `ns.db`): the root (intro, Welcome Message, Mini-map Button with Use the Default Tracking Button, Features, Key Bindings, /Commands), then one panel per feature in `ns.FEATURES` order (Farm Mode with its Abilities sub-panel), then Profiles, Feedback & Support, Diagnostic Tools. Names from `ns.OPTIONS_REGISTRY`.
- `Register` keeps each panel's frame (for `ns.IsOptionsPanelOpen`) and category ID (for the opener) by registry key, so a new panel needs no other list.
- Every feature panel opens with its description, then its switch, then its settings, which hide while it is off.
- **Feature switches:** General's Features section carries every switch, two to a line, each pair its own unnamed inline group (`ns.OptionsFeatureSwitchRows`). The same switch also heads the feature's own panel. Both copies come from `ns.OptionsFeatureSwitch`: one caption, one tooltip, one setter (the feature's `apply`, then `ns.RefreshSettings()`).
- A sub-panel nests under its feature's panel by the category ID that panel's registration returned, and its title names the parent (`ns.SubPanelTitle`: "Farm Mode > Abilities"); the tree label is the plain name. Nothing on it hides while the feature is off.
- The opener takes an `ns.OPTIONS_REGISTRY` key (`ns:OpenOptionsPanel("FreePlacement")`) and opens that panel by the category ID captured at registration; no key opens the root. `AceConfigDialog:Open` only when `AddToBlizOptions` returned no category ID.
- `ns.OptionsSubRow`: one unnamed inline group per sub-option, controls sized with slack, `hidden` on the group. Label-beside-control rows pair `ns.OptionsRowLabel` with an unnamed control totaling `ns.OPTIONS_ROW_WIDTH`. A helper line under a field sits in the control column behind a blank `ns.OptionsRowLabel` cell.
- Cycle Speed's dropdown needs `CYCLE_SORTING`, or "10" sorts before "2".
- Every class sees every option (profiles can be shared); only flavor-missing data hides a row.

### Localization

- `enUS.lua` is the source; `07 - Localization Review.md` owns the other ten files.
- Keys reached indirectly, which a search for `L["` reports as unused: `MSG_FORMAT_*` (`mapping.formatKey`), `OPTIONS_OUTPUT_CHANNEL1` (`labelKey`), every `FARM_PAUSED_*` (returned by `ns.GetFarmPauseReason`), `EMPTY_CYCLE_MESSAGES`, `MENU_CLICK_*` (`CLICKS` in `Features/Minimap-Menu.lua`), the `name`/`caption`/`desc` keys in `ns.FEATURES`, the `KEY_BINDINGS` table in `Options/Options-General.lua`, `PARAGRAPHS` and `LINKS` in `Options/Options-Feedback-Support.lua`.
- `MATCH_*` must equal what the client prints, or herb and ore detection silently stops in that locale (README-Notes → Typed herb and ore match words).
- Creature types are matched by ID and never named; Automatic Target Tracking has no keys.
- Not localized: `ns.DiagnosticsStrings`, `ns.OPTIONS_REGISTRY`, `Bindings.xml`'s `category`.

### Diagnostics

- `Diagnostics/Manifests.lua` holds the add-on's surface: `ns.DIAGNOSTIC_API_CHECKS` (both halves of every compatibility pair, so a `[FAIL]` names the branch taken), the four context reports (Player & Spell, Persistent Tracking, Farm Mode, Come & Get It), `ns.DIAGNOSTIC_NAME_LOOKUPS`, `ns.DIAGNOSTIC_DATA_SOURCES`, and `ns.GetItemStats`.
- Probes read through the features' own accessors, and print every `ns.CanCast()` condition (`AddCanCastLine`) and the secret restrictions in force.
- Data sources: one entry per data file label (`Spells`, `Zones`, `Game-IDs`). The Game-IDs file sets one constant, so `ns.DIAGNOSTIC_GAME_IDS` wraps it in a table for the validator.
- Event log: both firehoses, `UI_ERROR_MESSAGE` and `GET_ITEM_INFO_RECEIVED`, are in `ns.MESSAGE_ID_FILTERED_EVENTS`. `ns:SuppressUncorrelatedMessage` logs a firing in full when its event's `CORRELATED` check (`Diagnostics/Event-Log.lua`) accepts it (`ns.MatchError` for an error, `ns.SAMPLE_HERB_ITEM_ID` for an item load), and folds the rest into per-ID counters.

## Files That Change Together

- **New tracking spell:** a `ns.TRACKING_SPELLS` row in each `Data/{Game}/Spells-{Game}.lua` whose client has it; optionally `ns.FARM_CYCLE_DEFAULTS` (reaches existing characters), a `ns.CREATURE_TYPE_DATA` candidate, `ns.CAT_FORM_ONLY` in `Features/Utilities.lua`, a `ns.FARM_ABILITY_CLASSES` row for a new class source (and `ns.CLASS_COLORS` past Wrath); `SENTENCE_SPELL_KEYS` in `Diagnostics/Manifests.lua` only if one of our sentences names it (Game Names lists every other tracking spell on its own).
- **New feature:** an `ns.FEATURES` row (`block` or not, `opensOptions` if its settings need the panel); its `ns.DATABASE_DEFAULTS` key; its panel builder, an `ns.OPTIONS_REGISTRY` key and a `RegisterChild` call in feature order; a block in `BuildMainEntries` when `block`; a `CLICKS` entry if it gets a button click; `Locales/enUS.lua`; a context report.
- **New Farm Mode condition:** `ns.MOVEMENT_STATE_TOGGLES`, `ns.MOVEMENT_STATE_CLASS`, `ns.CLASS_STATE_ORDER` (`Data/Data.lua`); `ns.MOVEMENT_BUFF_SPELLS` rows per folder; buff set, `MOVEMENT_STATE_BUFFS`, `ScanMovementBuffs` (and its last-scan values), `ComputePlayerStates` (`Features/Utilities.lua`); the toggle default; `FOOT_REASONS`, `STATE_OFF_REASONS`, `STATE_NAMED_REASONS` (`Features/Farm-Pause-Reporting.lua`); the reason keys and option strings in `Locales/enUS.lua`; a `ConditionToggle` (`Options/Options-Farm-Mode.lua`); a `Condition` row in `FLYOUTS.farm` (`Features/Minimap-Menu.lua`); the Farm Mode Context report.
- **New pause reason:** the key in `Locales/enUS.lua`; its place in `ns.GetFarmPauseReason`; the matching tick hold or `ns.CanCast()` condition; a new `ns.CanCast()` condition also in `AddCanCastLine`.
- **New setting:** `ns.DATABASE_DEFAULTS` key in the right scope; the panel widget, its `set` ending in `ns.RefreshSettings()`; `ns:ApplyProfile` if applied imperatively; `ns.InvalidateFarmCache()`/`ns.TryRecastPersistent()` in its `set` if it changes the cycle or the resolver; the feature's menu flyout, with the same side effects; `Locales/enUS.lua`; the feature's context report; a migration if it reshapes an existing key.
- **New button click:** a `CLICKS` entry (`Features/Minimap-Menu.lua`) and its `MENU_CLICK_*` key; the row doing the same job built with `ClickRow`. Both launchers already take every button.
- **New registered event:** `ns.EVENT_NAMES` (and `UNIT_FILTERED_EVENTS` if unit-scoped) and an `OnEvent` branch in `Features/Core.lua`; a firehose goes in `ns.DIAGNOSTIC_EVENT_EXCLUDE`, or in `ns.MESSAGE_ID_FILTERED_EVENTS` with a `CORRELATED` check (`Diagnostics/Event-Log.lua`).
- **New Come & Get It node type:** an error-name constant in `Data/Data.lua` or a `MATCH_*` key; an entry in `ERROR_STRING_MAPPING` or `SKILL_MAPPING`; its `MSG_FORMAT_*` body; the Come & Get It Context report, `ns.DIAGNOSTIC_NAME_LOOKUPS` for a new error name, and Message Length's `CALLOUT_KEYS` (`Diagnostics/Localization-Reports.lua`).
- **New output channel:** one `ns.OUTPUT_CHANNELS` row (`key` never renamed; `labelGlobal` and `prefixGlobal` checked on every client, or a `labelKey` in `Locales/enUS.lua`); the dropdown, Example line and Game Names pick it up on their own.
- **New data table or file:** the same file in all seven `Data/{Game}/` folders, keeping the Vanilla and Discovery guards; a new file in every TOC's data block; an entry in `ns.DIAGNOSTIC_DATA_SOURCES`.
- **New options panel:** an `ns.OPTIONS_REGISTRY` key, a `Register`/`RegisterChild` call in `ns.RegisterOptionsPanels`, and its file in every TOC's Options block.

## Saved Variables

- `TrackingEyeDB`: the one SavedVariables table, owned by AceDB-3.0, read through `ns.db`.
- **Model: Per-Character.** `AceDB:New` omits the third argument; each character gets its own profile, because the pick and the cycled abilities differ per character. **Reset Profile clears that character's tracking pick and per-character feature settings only**; `global` survives.
    - `profile`: Persistent Tracking and its overrides, Farm Mode (toggle, interval, conditions, ability map, persistent entry, sound mute), Automatic Target Tracking.
    - `global`: presentation (LibDBIcon `minimap`, Free Placement and `freePos`, welcome, the Blizzard button takeover), Zoom Mini-map Out (it changes the shared mini-map), and Come & Get It (toggle, output channel).
- `ns.FEATURES` records each feature's scope in `store`; the feature switches and the More Features rows read it from there.
- **Seeding:** none in the Style Guide's list sense. `farmCycleSpells` is a settings map whose default is `ns.FARM_CYCLE_DEFAULTS`: AceDB fills any missing key at every load, so an added default reaches every character that never saved one, and only an explicit `false` survives.
- No defaults on purpose: `selectedSpellId` (nil means nothing picked) and `freePos`.
- Runtime only, never saved: `ns.state` and `ns.diagnostics`.
- `PruneOtherClientCharacters` runs right after `AceDB:New`, before the migration (Style Guide → Other-Client Characters).

### Migration Chain

1. `MigrateComeAndGetItScope` (`Features/Core.lua`, remove after 2026-12-13): copies the current profile's `comeAndGetIt` and `comeAndGetItOutput` to `global` if `global` has none, then nils both keys in every profile.

## Pitfalls & Why

- **Trusting the tracking mirror**: on Classic Era it lags by minutes and nil doubles as "nothing tracked". Compare against `lastCastSpell`, read the mirror only as "provably up", and leave login to the grace window.
- **A second tracking reader**: deciding from `MiniMapTrackingIcon`, `GetTrackingTexture` or `C_Minimap` outside `ns.GetActiveTrackingSpell()` resurrects cleared icons and poisons `lastCastSpell` through the adopt branch. The poller and the Player & Spell report read raw but decide nothing.
- **Recording a cast before confirmation**: `ns.CastTracking` must never write `lastCastSpell`; a silent failure would suppress its own retry.
- **Persisting `lastCastSpell`**: every caller would think tracking is up at login and skip every cast.
- **Swallowing a temporary bail in `TryRecastPersistent`**: on Era no further event may come, so Persistent Tracking stops until the next login. Reschedule or park.
- **Switching Persistent Tracking on by writing `persistentTracking`**: nothing casts until the next event. Go through `ns.SetPersistentTracking`.
- **Casting inside the shapeshift GCD**: fails silently; keep the `ns.ScheduleEventRecast` delay after `UPDATE_SHAPESHIFT_FORM`.
- **`ClearAllTracking`**: also clears Blizzard's quest and target filters. Use `ns.CancelActiveTracking()`.
- **Bare secret-capable reads**: an aura read in WoW Forever combat throws. Use the `Features/Utilities.lua` accessors, in Diagnostics too.
- **A completeness test on the texture map**: rebuilds the whole map on every miss. Only the dirty flag rebuilds it.
- **Wiring a movement state into only some tables**: detection works while the on-foot reason never names it. Follow *Files That Change Together*.
- **Cat Form tracking outside Cat Form or in the creature-type map**: every cycle step would be a failing cast, and a hunt could land on it.
- **Building a pause reason from fragments**: untranslatable. One precomposed key per combination.
- **Reporting the own menu as a pause reason**: opening the menu to read Farm Mode Status would always read "paused" and name the menu instead of the cause. It stays a tick hold only.
- **Moving the tick's hold checks above the Farm-Mode-off stop**: every tick sweeps `UIPanelWindows` and the tooltip for a feature that is off.
- **Caching the options-open state or using `IsShown()`**: closing Settings hides the window, not the canvas, so Farm Mode stays paused until a reload.
- **A settings write that skips `ns.RefreshSettings()`**: the menu and any open panel keep the old value until reopened.
- **A More Features row for a feature whose `apply` does more than write the key**: the row's `Toggle` writes the setting directly and never calls `apply`. Give it `opensOptions`, as Free Placement Mode has, or route the row through `apply`.
- **Naming a button click on a row by hand**: the label drifts from what the click does. Build the row with `ClickRow` from `CLICKS`.
- **Arming the cycle mute before the cast**: mutes sound for a cast that never happened. Cast first, arm second.
- **Relying on the mute's timer**: `Sound_EnableSFX` outlives the session; keep the logout and switch-off restores and the `pcall`.
- **`LibDBIcon:SetButtonIcon` for the icon fit**: its `ResetButtonIcon` errors when another add-on replaced the icon. Size `button.icon` directly.
- **Naming the free frame**: `layout-local.txt` overrides `freePos` with a cached per-character position.
- **Saving the free frame from `GetPoint()` or while hidden**: writes a drifted, account-wide `freePos`. Round-trip through the two helpers; keep the `IsShown()` guard on the logout save.
- **Letting a hunt write `selectedSpellId`**: a passing target would replace the pick and the login catch-up would bring it back in town.
- **Queueing a combat-dropped hunt or draft**: it would fire late, and the draft would steal focus as the fight ends.
- **Keying herb or mine on the error ID, or merging the two mapping tables**: both share one error whose number differs by client; a merged table tests `ERR_ITEM_LOCKED` against message text.
- **Making `ns.MatchError` file-local**: the event-log filter classifies with it; every node error would fold into the spam counters.
- **A filtered firehose without a `CORRELATED` check**: every firing folds into the counters, signal included.
- **Loosening the compose guards**: `0, 0` is a valid vector where the map can't place the player; `GameTooltipTextLeft1` keeps stale text; bag lockboxes raise the chest error.
- **Trimming an over-long draft**: a byte cut splits multi-byte characters. Warn, keep it whole, measure without the command.
- **Renaming an output channel key**: the key is saved; existing players fall back to Local.
- **Storing `nil` to untick a `farmCycleSpells` entry**: AceDB re-adds a default-true key at login. Write `false`, as both the panel and the menu do.
- **Expecting a new `ns.FARM_CYCLE_DEFAULTS` entry to reach only new characters**: it reaches every map without the key; say so in release notes.
- **An imperatively applied setting missing from `ns:ApplyProfile`**: stale after a profile switch until `/reload`.
- **Opening options by name**: AceConfigDialog aliases the name only on clients without `C_SettingsUtil.OpenSettingsPanel`; elsewhere the lookup is nil and the panel floats. Route by the captured category ID.
- **Nesting a sub-panel by its parent's name**: AceConfigDialog maps only root names to IDs. Pass the category ID the parent's `RegisterChild` returned.
- **Mutating `ns.BuildProfilesOptions()`'s table**: AceDBOptions shares `args` across every database, so the change leaks into every Ace3 add-on's Profiles panel.
- **Reusing a retired locale key**: its stale translations win over the English fallback.
- **An unsuffixed `TrackingEye.toc`, or `Bindings.xml` in a TOC**: the first loads under the wrong flavor; the second makes the UI parser reject the binding.
- **Adding a Wrath or Mainline TOC without touching `.pkgmeta`**: both data folders are in its ignore list, so the release would ship a TOC whose data files were stripped.
- **Editing a Common-Core shared file here**: CI fails the drift. Only `ISSUE_TEMPLATE/config.yml` is this add-on's own.
- **Renaming *Restricted Zones* or *Mini-map Menu* here**: `Features/Core.lua` and `Features/Minimap-Menu.lua` cite them by name.
