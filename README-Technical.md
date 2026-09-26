# Tracking Eye // Technical Reference

This document combines architecture notes and contribution guidance for developers working on Tracking Eye. For end-user documentation, see [README.md](https://github.com/Gogo1951/Tracking-Eye/blob/main/README.md).

## File Map

```text
TrackingEye/
├── .github/
│   └── workflows/
│       └── package.yml              CurseForge and Wago release plus library vendoring, no GitHub token by design
├── .gitattributes                   Line-ending normalization
├── .gitignore                       Dev-clutter ignore list
├── .luacheckrc                      Lint config, skips Includes/ and .claude/
├── .pkgmeta                         Externals and the packager ignore list
├── TrackingEye_Vanilla.toc          Classic Era
├── TrackingEye_TBC.toc              TBC Anniversary
├── TrackingEye_Camelot.toc          WoW Forever
├── TrackingEye_Mists.toc            MoP Classic
├── TrackingEye_Mainline.toc         Retail
├── Bindings.xml                     The one key binding, found at the root by the client and never listed in a TOC
├── Data/
│   ├── Flavor.lua                   Flavor identity and the data folder to load, the canonical copy
│   ├── Data.lua                     Locale handle, palette, movement-state tables, timings, Come & Get It's channels
│   ├── {Game}/                      One complete data set per flavor: Vanilla, Discovery, TBC, Camelot, Wrath, Mists, Mainline
│   │   ├── Spells-{Game}.lua        Tracking spells, creature types, movement buffs, Farm Mode's default abilities
│   │   └── Zones-{Game}.lua         Maps outside an instance that count as restricted
│   └── Default-Settings.lua         The AceDB defaults, profile and global scopes
├── Features/
│   ├── Core.lua                     Version, welcome message, AceDB init, profile apply, the event dispatcher
│   ├── Utilities.lua                Spell lookups, colors, secret-value accessors, tracking reads, game-state predicates
│   ├── Announcements.lua            Branded print and the Come & Get It draft builder
│   ├── Tracking-State.lua           Runtime state, icon resolution, Clear Tracking, the cast primitive, icon pollers
│   ├── Persistent-Tracking.lua      The resolver, mid-play recasts, login catch-up, post-resurrection recast
│   ├── Farm-Mode.lua                Cycle cache, the farm tick, form-leave restore, manual advance, the ticker
│   ├── Farm-Pause-Reporting.lua     Why Farm Mode is idle, and the window and tooltip checks behind it
│   ├── Cycle-Sound-Mute.lua         The cycle's cast seam and its momentary sound-effects mute
│   ├── Target-Tracking.lua          The hunt: the targeted creature's kind stands in for the player's pick
│   ├── Come-and-Get-It.lua          A chat draft for a node the player can't gather or a chest they can't open
│   ├── Key-Bindings.lua             The two globals the binding system requires
│   ├── Tracking-Menu.lua            The LibUIDropDownMenu picker and the Blizzard tracking-button takeover
│   ├── Free-Placement.lua           The free-placement frame, its position pipeline, scale and shape
│   ├── Diagnostics.lua              Reports, event log and its noise filter, API probes, Validate Data, taint log
│   └── Minimap-Button.lua           LDB launcher, placement, tooltip, click map
├── Includes/
│   ├── Images/
│   │   └── Tracking-Eye.tga         Add-on icon, the TOCs' IconTexture
│   └── Libraries/                   Vendored libraries, never edited by hand
├── Locales/                         AceLocale strings
├── Options/
│   ├── Options-Utilities.lua        Widget helpers and the sub-option row builder
│   ├── Options-Target-Tracking.lua  Automatic Target Tracking section, merged into General
│   ├── Options-Free-Placement.lua   Free Placement Mode section, merged into General
│   ├── Options-General.lua          Root panel, composing the two sections above
│   ├── Options-Farm-Mode.lua        Farm Mode child panel
│   ├── Options-Come-and-Get-It.lua  Come & Get It child panel, directly beneath Farm Mode
│   ├── Options-Profiles.lua         Stock AceDBOptions-3.0 table, returned unmodified
│   ├── Options-Diagnostics.lua      Diagnostic Tools panel, registered last
│   └── Options.lua                  Registration, the options opener, the /te command
├── tools/                           Dev-only: no TOC lists it and .pkgmeta strips it
│   └── Test-Event-Log-Noise.lua     Offline tests for the event log's noise filter
├── LICENSE                          MIT
├── README.md                        End-user documentation
├── README-Notes.md                  The maintainer's settled exceptions and decisions
├── README-Technical.md              This document
└── README-Testing.md                Manual test plan
```

Within each folder, files are listed in TOC load order, which is dependency-first. Locales load before `Data/Data.lua` calls `GetLocale`. `Data/Flavor.lua` opens the data block because every later file may read the flavor, the TOC's own flavor folder follows `Data/Data.lua`, and `Data/Default-Settings.lua` closes the block because Farm Mode's default abilities come from that folder. `Features/Utilities.lua` builds the spell lookups once at load from the flavor data: `ns.SPELLS`, `ns.TRACKING_IDS`, `ns.TRACKING_SET`, `ns.TRACKING_SOURCE`, `ns.FARM_FORMS`, `ns.CAT_FORM_ONLY`, the movement-buff sets, and `ns.CREATURE_TYPE_SPELLS`. The two merged option sections load before `Options-General.lua`, which composes them.

There are five TOCs, one per flavor, identical line for line except `## Interface`, `## X-Flavor`, and the data-folder lines. There is deliberately no unsuffixed `TrackingEye.toc`, and one must never come back (see *Common Pitfalls*).

**Static game data lives in seven flavor folders, one complete copy per flavor** (Style Guide → DATA → Flavor Folders). Every folder declares the same five tables, in `Spells-{Game}.lua` (`ns.TRACKING_SPELLS`, `ns.CREATURE_TYPE_DATA`, `ns.MOVEMENT_BUFF_SPELLS`, `ns.FARM_CYCLE_DEFAULTS`) and `Zones-{Game}.lua` (`ns.RESTRICTED_MAP_IDS`), so feature code never checks which flavor built a table. Each TOC lists only its own folder, except that the Vanilla TOC lists `Data/Vanilla/` and then `Data/Discovery/`, whose files open with opposite `ns.IS_DISCOVERY` guards, so a Season of Discovery realm builds only Discovery's tables. No TOC lists `Data/Wrath/`, which is forward-prep for a flavor with no live client. A file copied from another folder says so at the top until Validate Data passes on its client. Game IDs live only in these folders; `Data/Data.lua` holds none.

The folders differ where the clients do. Classic Era has no Find Fish, and neither it nor WoW Forever has Flight Form or Swift Flight Form. MoP Classic has no Sense Demons, Sense Undead, or Find Treasure, and adds Track Pets. Retail adds Track Mechanicals, the druid's Cat Form Track Beasts, and Track Pets, keeps Sense Undead but not Sense Demons or Find Treasure, and has no buff row for Aspect of the Cheetah or Aspect of the Pack.

`.pkgmeta`'s ignore list strips the repo scaffolding, `LICENSE`, `tools`, and `Data/Wrath`, so a copy installed from CurseForge or Wago carries none of them. The release workflow re-exports `Includes/Libraries/` from `.pkgmeta`'s externals on every tag, so a hand edit there is lost at the next release. `Bindings.xml` has no TOC line on purpose; see *Key Bindings*.

## Architecture

### Shared Namespace

Every file receives `(ADDON_NAME, ns)` through the `...` vararg, and everything the add-on shares hangs off `ns`. The only globals are the ones something outside the add-on's own Lua must reach:

| Global | Why it exists |
| --- | --- |
| `TrackingEyeDB` | The SavedVariables table, owned by AceDB-3.0 and read through `ns.db` everywhere but the Diagnostics dump, which prints the raw table |
| `SLASH_TRACKINGEYE1`, `SlashCmdList["TRACKINGEYE"]` | The `/te` registration in `Options/Options.lua` |
| `TrackingEye_CycleFarmAbility` | `Bindings.xml` can only call a global function |
| `BINDING_NAME_TRACKINGEYE_CYCLE_FARM_ABILITY` | The binding's display name, matching the element's `name` attribute |
| `TrackingEyeTrackingMenu`, `TrackingEyeTrackingMenuFont` | The Tracking Menu's LibUIDropDownMenu frame and the larger font object (`CreateFont`) its rows use |
| `TrackingEyeScanTooltip` | Validate Data's hidden tooltip, created only on a client without `C_TooltipInfo.GetSpellByID`, because `GameTooltipTemplate` names its text lines after the frame |

An earlier file may call a function a later file defines, as long as the call happens at runtime. `Core.lua` loads first yet calls into nearly every feature, and that is safe because every call comes from an event handler and `ADDON_LOADED` fires only after all of the add-on's files have run. Most of those calls are guarded (`if ns.RunFarmLogic then`), so a feature left out of a flavor's TOC (Style Guide → COMPATIBILITY) would degrade instead of erroring. The icon, recast, and restricted-zone calls are not guarded, since every feature depends on those files.

### Event Loop

`Core.lua` owns one hidden frame and routes every event through its `OnEvent` handler; no feature file listens for events on a frame of its own. `ns.EVENT_NAMES` is the single list: the dispatcher registers from it, and the Diagnostic Tools Event Registration check reads it back, so the two can never drift. `UNIT_FILTERED_EVENTS` registers `UNIT_SPELLCAST_SUCCEEDED` through `RegisterUnitEvent` for `"player"` only, so other units' casts never wake the dispatcher. While the diagnostics event log is running, every event passes through `ns:LogEvent` before its handler, behind one boolean check, so logging costs nothing when it is off.

| Event | Handling |
| --- | --- |
| `ADDON_LOADED` (own name only) | Creates `ns.db`, wires the three profile callbacks to `ns:ApplyProfile`, registers the options panels, creates the free-placement frame, refreshes the icon |
| `PLAYER_LOGIN` | `ns.InitMinimap()`, `ns.InitFarmMode()` (starts the farm ticker), icon refresh, `ns.PollUntilTrackingReady()`, the welcome message |
| `UNIT_SPELLCAST_SUCCEEDED` (player) | For a spell in `ns.TRACKING_SET`: `ns.SetLastCast`, `ns.NotifyTrackingCastSucceeded()` for the cycle mute, icon refresh |
| `MINIMAP_UPDATE_TRACKING` | Icon refresh, `ns.FlushIconAfterTrackingChange()`, `ns.ScheduleEventRecast(2)` |
| `PLAYER_ENTERING_WORLD` | Icon refresh, `ns.StartLoginGrace()`, ends a hunt in a restricted zone, placement, farm and texture cache invalidation |
| `ZONE_CHANGED_NEW_AREA` | Icon refresh, ends a hunt in a restricted zone |
| `UPDATE_SHAPESHIFT_FORM` | Icon refresh, `ns.ScheduleEventRecast(1.5)` |
| `SPELLS_CHANGED` | Icon refresh, placement, farm and texture cache invalidation |
| `PLAYER_UNGHOST`, `PLAYER_ALIVE` | `ns.RecastAfterResurrection()` |
| `PLAYER_STARTED_MOVING` | `ns.OnPlayerStartedMoving()`, which wakes parked recasts |
| `PLAYER_EQUIPMENT_CHANGED` (main hand only) | Farm cache invalidation, icon refresh, `ns.ScheduleEventRecast(1.5)` |
| `PLAYER_UPDATE_RESTING` | Ends a hunt when resting starts, then runs `ns.RunFarmLogic()` at once |
| `PLAYER_LOGOUT` | `ns.SaveFreeFramePosition()`, then `ns.RestoreCycleSoundNow()` |
| `LOOT_OPENED`, `LOOT_CLOSED` | Set and clear `ns.state.lootWindowOpen` |
| `PLAYER_TARGET_CHANGED` | `ns.OnPlayerTargetChanged()` |
| `UI_ERROR_MESSAGE` | `ns.OnUIErrorMessage(messageID, message)`, Come & Get It's entry point |

Four timing decisions carry most of the weight:

- **Bursts coalesce into one recast.** `ns.ScheduleEventRecast(delay)` holds one pending `TryRecastPersistent` behind its own flag, so a hunter's aspects, which fire `UPDATE_SHAPESHIFT_FORM` constantly, share one recast. The 1.5 seconds after a shapeshift let the form's global cooldown expire first, and a main-hand change uses the same delay. The 2 seconds after `MINIMAP_UPDATE_TRACKING` let the burst settle; the add-on's own casts fire that event too, and the recast's grace window and debounce absorb the echo.
- **The farm ticker is the event for what has none.** `C_Timer.NewTicker` runs `ns.RunFarmLogic()` every `farmInterval` seconds whether or not Farm Mode is on. It is the only thing that sees a flight start or land, and the only refresh for pause reasons that fire no registered event.
- **Resting reacts at once.** `PLAYER_UPDATE_RESTING` runs the farm logic immediately instead of waiting up to a full tick. The resting flag itself can lag zone entry by several seconds; that latency is the client's.
- **The loot events are the truth about looting.** `LOOT_OPENED` and `LOOT_CLOSED` drive `ns.state.lootWindowOpen` rather than `LootFrame:IsShown()`, because speedy-loot add-ons hide that frame while looting is still open.

### Combat Lockdown

Nothing in the add-on drives a secure frame or edits a macro, so no work waits behind a dirty flag and no `PLAYER_REGEN_ENABLED` handler exists. Combat still shapes five behaviors, each deliberately different:

- **The options opener refuses outright.** `ns:OpenOptionsPanel` (`Options/Options.lua`) makes `InCombatLockdown()` its first statement, prints `CHAT_OPTIONS_IN_COMBAT`, and returns. Blizzard's Settings panel is protected in combat, and without the gate `/te` or Shift + Middle-Click hands the player an `ADDON_ACTION_BLOCKED` error naming Tracking Eye. It never queues the open.
- **Automatic casts refuse and retry.** `ns.CanCast()` is false while `UnitAffectingCombat("player")` is true, so the farm cycle, the form-leave restore, the persistent recast, the post-resurrection recast, the hunt cast, and the Cycle Farm Mode Ability binding all decline. Each automatic caller retries on its own: the ticker and the form-leave restore on the next tick, `TryRecastPersistent` through `ScheduleRecast`, the post-resurrection recast after `RECAST_DEBOUNCE_SECONDS`, the hunt cast after `HUNT_RETRY_SECONDS`. The binding does nothing until it is pressed again.
- **Automatic Target Tracking ignores targets picked in combat.** A target picked mid-fight never starts or switches a hunt, and nothing is queued for after the fight; otherwise whatever attacks the player would become what they track.
- **Come & Get It drops its draft.** Opening the chat box steals keyboard focus and breaks movement, so its gate refuses under `InCombatLockdown()` and the draft is dropped, never replayed: a callout after the fight is stale, and the node raises its error again on the next right-click.
- **WoW Forever hides combat state.** In combat, aura, cooldown, casting, identity, and unit-stat reads can come back secret there; see *Secret Values*.

A fight that starts while mounted is still a fight: the player stays in the `mounted` farm state, `ns.CanCast()` holds the cycle, and the tooltip reports combat (README-Notes → Decisions).

### Reading and Clearing Tracking

`ns.GetActiveTrackingSpell()` (`Features/Utilities.lua`) is the one answer to "which tracking spell is up right now?", and every caller goes through it. It tries three sources, by availability:

1. Blizzard's `MiniMapTrackingIcon`, only while it is visible, with its texture matched back to a spell ID. On Classic Era this is the authority: `GetTrackingTexture()` returns nil there for some active tracking (racials such as Find Treasure), and the Vanilla client hides the icon entirely when nothing is tracked. A hidden frame keeps its last texture, which is why it is read only while visible.
2. `GetTrackingTexture()`, wherever the client ships it, such as TBC Anniversary, whose icon shows a generic texture when nothing is tracked. When the client ships it, its answer, nil included, is final.
3. The `C_Minimap` tracking list, on a client without `GetTrackingTexture` (WoW Forever, which has no `MiniMapTrackingIcon` either): the first active entry backed by one of this add-on's spells, matched by its `spellID`, or by texture for a spell entry without one. A town service switched on in the same list never counts as tracking.

Reading `C_Minimap` only as the last resort is README-Notes → Exceptions → Legacy tracking reads: Classic Era ships `C_Minimap`'s tracking calls but reports an empty list, so the legacy reads stay wherever a client ships them.

`ns.CancelActiveTracking()` is the one clear: `CancelTrackingBuff()` where the client ships it, otherwise `C_Minimap.SetTracking(index, false)` for each active entry backed by one of the add-on's spells. It never calls `ClearAllTracking`, which also clears Blizzard's own quest and target filters.

**The mirror is a positive signal only.** On Classic Era 1.15.x the tracking mirror (`GetTrackingTexture()` and `MINIMAP_UPDATE_TRACKING`) lags the real state, sometimes by minutes, flushing only when an unrelated buff update fires, and nil is also its normal value for "nothing tracked". So a read that names the spell means "provably up, skip the cast", and anything else, nil included, falls through to a cast; recasting an active tracking spell is a harmless refresh. Never bail on nil: nil is both "nothing tracked" and "the mirror hasn't caught up", which is exactly the state a recast exists to fix.

### Decide → Cast → Confirm

Every tracking cast runs the same three steps, and the bookkeeping between them keeps the add-on from double-casting or giving up.

1. **Decide.** Something picks the spell: the player's Tracking Menu click, `ns.GetPersistentSpell()` for every Persistent Tracking recast (`Features/Persistent-Tracking.lua`), the farm cycle (`Features/Farm-Mode.lua`), or a hunt (`Features/Target-Tracking.lua`). Every automatic caller gates itself with `ns.CanCast()` first.
2. **Cast.** `ns.CastTracking(spellId)` (`Features/Tracking-State.lua`) checks `IsPlayerSpell`, refuses the druid's Cat Form tracking (`ns.CAT_FORM_ONLY`) outside Cat Form, skips a spell on cooldown or the global cooldown, stamps `ns.state.lastTrackingCastAt`, and calls `CastSpellByID` inside `pcall`. It returns `true` only when it reached `CastSpellByID`. It does not test `ns.CanCast()`: the Tracking Menu calls it directly, because a deliberate click must always cast.
3. **Confirm.** `UNIT_SPELLCAST_SUCCEEDED` records the spell through `ns.SetLastCast`. `ns.CastTracking` never writes `ns.state.lastCastSpell`, because a cast can still fail silently (line of sight, range, a server reject), and recording the attempt would suppress the retry that fixes it.

`ns.SetLastCast` is the one write site for `lastCastSpell`, and it records a spell only on evidence that the spell is up: the cast-success event, `ns.UpdateIcon` adopting tracking that predates the session, or `TryRecastPersistent` finding the spell provably active. It clears on Clear Tracking, and when the player leaves Cat Form with the druid's tracking recorded. `lastCastSpell` is runtime-only and never saved: carried over from last session, it would make every caller believe tracking is already up at login and skip every real cast.

Two windows cover the gap while the mirror catches up. For `ns.CAST_IN_FLIGHT_SECONDS` (10) after an attempt, casters treat their own cast of the same spell as in flight rather than recast it; `ns.ICON_IN_FLIGHT_SECONDS` (4) is the icon's shorter window (see *Icon Resolution*). `ns.state.mirrorConfirmedCast` latches once the mirror positively reports `lastCastSpell`, and from then on a nil read is a genuine external cancel, not lag.

`ns.CastTracking` treats an active global cooldown as a cooldown rather than separating the two, and says so at the call site. That is acceptable here: tracking casts are cheap refreshes and every caller retries, so a GCD-blocked attempt is never lost.

### Icon Resolution

`ns.UpdateIcon()` (`Features/Tracking-State.lua`) decides which texture the mini-map button and the free-placement frame show, and it reads tracking only through `ns.GetActiveTrackingSpell()`. The one other writer is `ns.ClearTracking()`, which forces the default icon at once (see *Click Map*). A second reader of the mirror with slightly different rules is what produced every stale icon on Era.

1. If the player has left Cat Form and `lastCastSpell` holds the druid's Cat Form tracking, clear it.
2. Read `activeSpell` from `ns.GetActiveTrackingSpell()`.
3. **Adopt** tracking that predates the session: `activeSpell` is set and `lastCastSpell` is nil. Only then, because in-session casts own `lastCastSpell`, and adopting over them while the Era mirror lags would corrupt the cycle's comparisons.
4. **Latch** `mirrorConfirmedCast` once `activeSpell` equals `lastCastSpell`.
5. Show `activeSpell`, or `lastCastSpell` for `ns.ICON_IN_FLIGHT_SECONDS` after the add-on's own cast and only until the latch, while the mirror catches up. **There is no fallback to the saved pick**: every such fallback showed a stale icon, such as last session's spell at login with nothing up. Nothing tracked shows `ns.ICON_DEFAULT`.

The texture goes to `ns.state.currentIcon`, the LDB object, and the free frame, and `ns.RefreshTooltip()` redraws a tooltip already on screen. `UpdateIcon` is also the only writer of `ns.state.farmPauseReason`, cached so the farm tick can tell when the reason changed (see *Pause Reporting*). The icon never dims for a pause (README-Notes → Decisions).

Two pollers in `Features/Tracking-State.lua` shave latency without making the mirror any fresher:

- `ns.PollUntilTrackingReady()` runs once at `PLAYER_LOGIN` and retries every second, up to 15 times, until `MiniMapTrackingIcon` has a texture, then refreshes the icon. During the login storm the icon may have no texture yet and `MINIMAP_UPDATE_TRACKING` may never fire. On a client without that frame it simply runs out its attempts.
- `ns.FlushIconAfterTrackingChange()` re-runs `UpdateIcon` eight times over two seconds after a tracking change, catching the Era mirror the moment it flushes. A flag coalesces it, so a burst of tracking events can't stack overlapping polls.

### Spell and Item Data

Spell names and icons are never stored. The flavor data holds only IDs, and everything the player sees comes from `C_Spell.GetSpellName` and `C_Spell.GetSpellTexture` at runtime, so it localizes for free. That makes cold-call nils the thing to handle:

- **The texture reverse cache.** Matching a texture back to a spell uses a lazy texture-to-spell map built from `ns.TRACKING_IDS` (`Features/Utilities.lua`). During the login storm `C_Spell.GetSpellTexture` returns nil for spells whose data hasn't loaded, so a map built then is missing entries. Rebuilds are driven by a dirty flag that `SPELLS_CHANGED` and `PLAYER_ENTERING_WORLD` set through `ns.InvalidateTextureCache()`, never by testing whether every ID resolved: an ID the client lacks never resolves, so a completeness test would rebuild the whole map on every miss, and a miss is what happens whenever nothing is tracked.
- **Nil names are a filter.** The Tracking Menu and the Farm Mode Abilities list both skip an ID whose name comes back nil, which is how an ID the client lacks disappears. Diagnostics reports the same condition as *not on this client*, so a bug report separates "this client has never heard of the spell" from "the player hasn't learned it".
- **The fishing pole needs no cache.** `ns.IsFishingPoleEquipped()` reads the main-hand item's class and subclass through `C_Item.GetItemInfoInstant`, which reads the client's own item table and never comes back empty on a cold call the way `C_Item.GetItemInfo` can, so there is no static list of fishing poles.

### Secret Values

WoW Forever runs the Retail engine and carries its secret values. While a restriction is in force, which in practice means combat, an aura read from add-on code throws, the player's own buffs included, and cooldown, casting, identity, and unit-stat reads return values add-on code may not test or compare. `C_Secrets` reports each restriction ahead of the read, so every read that can go secret sits behind an accessor in `Features/Utilities.lua` that asks first and answers with a safe default:

| Accessor | While secret, it answers | So the caller |
| --- | --- | --- |
| `ns.GetSpellCooldown` | nil | Treats the spell as not cooling down and lets the cast attempt decide |
| `ns.IsPlayerCasting` | `true` | Holds the automatic cast and retries |
| The buff scan behind `ns.GetPlayerStates` | The last readable scan | Keeps the last known form; Farm Mode is paused for combat anyway |
| `ns.GetUnitCreatureType` | nil | Starts no hunt |
| `ns.IsPlayerMoving` | `false` | Waits for movement |

`ns.HasAttackableTarget`'s reads and `UnitIsPlayer` never go secret, so they are called directly. Diagnostics follows the same rule: the Farm Mode Context report prints `secret` for its buff columns while auras are locked, and prints movement as a boolean, never the raw speed. `C_Secrets` ships on all three current targets, so it is called directly, and nothing reads a secret value and works around it (Style Guide → COMPATIBILITY).

### Client Differences

The TOC decides the flavor. `Data/Flavor.lua` sets `ns.FLAVOR` from the chosen TOC's `## X-Flavor` and `ns.IS_DISCOVERY` from the active season on the Vanilla TOC, and derives `ns.EXPANSION` and `ns.DATA_FOLDER` from them. No feature code reads any of them; Diagnostics prints the flavor and the data folder. Each difference lives in the first place that can hold it (Style Guide → COMPATIBILITY):

- **Data.** Each flavor folder carries only what its client has (see *File Map*), and the options hide what the data lacks. The Find Fish when you Equip a Fishing Pole row hides where `ns.SPELLS.FISH` is nil (Classic Era). A Farm Mode Condition whose movement state has no buff rows hides through `ns.IsMovementStateDetectable`, and the pause reason skips it too, which is how Retail drops Aspect of the Cheetah and Aspect of the Pack (README-Notes → Decisions).
- **Availability.** The tracking reads and clears (see *Reading and Clearing Tracking*), the mini-map zoom buttons, and Validate Data's tooltip text (`C_TooltipInfo` where the client ships it, a hidden `GameTooltipTemplate` tooltip where it doesn't) each pick an API by whether it exists, never by a truthy result.
- **Frame presence.** The Blizzard tracking-button takeover exists only where `MiniMapTracking` exists and `MiniMapTrackingButton` doesn't, which is Classic Era (see *Tracking Menu*).
- **Secret values**, on WoW Forever (see *Secret Values*).

The namespaced APIs every current target ships (`C_AddOns`, `C_Item`, `C_Map`, `C_Minimap`, `C_Secrets`, `C_Spell`, `C_UnitAuras`) are called directly with no legacy fallback. The legacy tracking reads are the one sanctioned exception (README-Notes → Exceptions).

## Persistent Tracking

Persistent Tracking keeps one ability up and puts it back whenever something takes it away: death, a shapeshift, a loading screen, a cancel from outside the add-on, the end of a farm run.

### The Resolver

`ns.GetPersistentSpell()` (`Features/Persistent-Tracking.lua`) decides what that ability is right now. First match wins, and each override also requires the character to know the spell:

1. Track Humanoids inside a battleground or an arena, with **Hunter: Track Humanoids in Battlegrounds** on (`battlegroundHumanoids`).
2. Druid Track Humanoids in Cat Form, with **Druid: Track Humanoids when you Shift into Cat Form** on (`catFormHumanoids`).
3. Find Fish with a fishing pole in the main hand, with **Find Fish when you Equip a Fishing Pole** on (`fishingPoleFish`).
4. The running Automatic Target Tracking hunt, while the player is out in the world.
5. The player's own pick, `selectedSpellId`.

Everything that restores the ability reads the resolver: `TryRecastPersistent`, the post-resurrection recast, the form-leave restore, and the farm cycle's persistent entry. None of them knows about overrides or hunts, and "your own pick comes back" costs nothing: when an override's condition ends, the resolver answers with the pick again and the next recast trigger casts it. `UPDATE_SHAPESHIFT_FORM` covers Cat Form, `PLAYER_EQUIPMENT_CHANGED` on the main hand covers the pole, and the `PLAYER_ENTERING_WORLD` catch-up covers a battleground. Switching an override on or off invalidates the farm cache and calls `ns.TryRecastPersistent()`, so the change applies at once. A hunt never runs inside an instance, so it never meets the battleground override, and the resolver ignores a hunt outside the world as a backstop against a missed event that should already have ended it.

The mini-map tooltip's Persistent Tracking Ability row always shows the pick, never an override or a hunt.

### Mid-Play Recasts

`TryRecastPersistent()` runs 1.5 seconds after `UPDATE_SHAPESHIFT_FORM` or a main-hand change, 2 seconds after `MINIMAP_UPDATE_TRACKING`, once when the login grace window ends (the catch-up), when a hunt ends at a context break or a flight lands, and when a Persistent Tracking sub-option changes. It is exposed as `ns.TryRecastPersistent` for those last callers. The bail chain, in order:

1. `ns.db` missing, `persistentTracking` off, or nothing resolved: stop.
2. The player is in a farm state: stop, Farm Mode owns the casting.
3. The character doesn't know the spell: stop.
4. Less than `LOGIN_GRACE_SECONDS` (10) since `PLAYER_ENTERING_WORLD`: stop, the catch-up covers it.
5. The spell is provably up: sync `lastCastSpell`, re-latch `mirrorConfirmedCast`, stop. This is what ends a retry chain once a recast has landed.
6. The add-on's own cast of this spell is still in flight: reschedule for when the window ends. Without this, a hunter's stream of shapeshift events drives a redundant recast every few seconds until the mirror flushes.
7. The player is standing still: park until they move (below).
8. `ns.CanCast()` refuses: reschedule after `RECAST_DEBOUNCE_SECONDS` (5).
9. On cooldown or the GCD: reschedule.
10. Inside the debounce since the last attempt, which is the `MINIMAP_UPDATE_TRACKING` echo of the add-on's own cast: reschedule for when it ends.
11. Otherwise cast.

**Temporary bails retry, never swallow.** On Era the client may never fire another tracking event, so a dropped trigger, such as a player cancelling tracking twice inside the debounce, would stop Persistent Tracking until the next login. `ScheduleRecast` coalesces the retries behind `recastRetryPending`, a flag separate from the event-burst one.

### Waiting for Movement

Every recast here waits for the player to move (README-Notes → Decisions). Standing still is when a player eats, drinks, gathers, or reads, and a cast then stands them up or costs a global cooldown for nothing. So `TryRecastPersistent` and the post-resurrection recast check `ns.IsPlayerMoving()` just ahead of the all-clear and, while it is false, park themselves in a waiting set with no timer. `PLAYER_STARTED_MOVING` calls `ns.OnPlayerStartedMoving()`, which runs every parked recast once, `MOVEMENT_SETTLE_SECONDS` (0.2) later, coalesced behind a pending flag. The set is swapped out before the calls and each recast re-checks movement itself, so a tap that stops at once parks it again. The farm tick holds the same way, the form-leave restore included (see *The Farm Tick*). Automatic Target Tracking's switch is not covered and casts the moment a new kind of creature is targeted.

### The Login Blackout

During the login or reload event storm the tracking API is unresponsive for ten seconds or more and `GetTrackingTexture()` returns nil, so there is no telling whether the pick is already up. A time-based grace window handles it, never an interpretation of nil. `ns.StartLoginGrace()` anchors `ns.state.enteredWorldAt` on every `PLAYER_ENTERING_WORLD` and schedules the catch-up for one second after the window ends. Without the catch-up, a player who logs in with tracking down stays that way, since on Era no tracking event may ever fire; if tracking survived the logout, the positive check skips the cast.

### Post-Resurrection Recast

Resurrection doesn't route through `TryRecastPersistent`: a resurrection genuinely clears tracking on the server, so the mirror is never consulted. `PLAYER_UNGHOST` (back at the corpse after a spirit run) and `PLAYER_ALIVE` (an in-place resurrection: a healer's, a soulstone, or a graveyard port) both call `ns.RecastAfterResurrection()`, which tries 1.5 seconds later, by the maintainer's choice (README-Notes → Decisions).

- A corpse-run return fires both events, and `resurrectRecastPending` coalesces them into one attempt. The flag stays set while the attempt waits, so another `PLAYER_ALIVE` can't start a second chain.
- `PLAYER_ALIVE` also fires the instant the player releases spirit and becomes a ghost, so the attempt ends while `UnitIsDeadOrGhost("player")` is still true; the real resurrection fires the event again.
- `persistentTracking`, the resolver, the farm state, `IsPlayerSpell`, and the Cat Form gate are lasting bails that end the chain. Standing still parks it. When `ns.CanCast()` or the cast refuses, as it does when a battle resurrection or soulstone lands mid-fight, it tries again after `RECAST_DEBOUNCE_SECONDS` until it casts or a lasting bail ends it.

## Farm Mode

Farm Mode cycles the player's ticked tracking abilities while they travel in a farm state, so herbs and ore share one mini-map.

### The Farm Tick

`ns.RunFarmLogic()` (`Features/Farm-Mode.lua`) runs on the ticker, every 3.5 seconds by default and 2 to 10 in half-second steps through `ns.db.profile.farmInterval`, and on demand from `PLAYER_UPDATE_RESTING`:

1. `ns.HandleFlightState()` (`Features/Target-Tracking.lua`): taking off ends a running hunt, and landing afterwards brings the Persistent Tracking Ability back.
2. Re-resolve the pause reason and refresh the icon and any open tooltip when it changed. This sits above every hold, so the Farm Mode Status stays honest on ticks that do nothing else.
3. Hold while one of the add-on's options panels is visible (`ns.IsOptionsPanelOpen()`).
4. Hold while a window is open, while a living target the player can attack is selected, or while any tooltip shows, the add-on's own included (the last two per README-Notes → Decisions).
5. Hold until `ns.db` exists.
6. Hold while the player stands still.
7. **Form-leave restore.** If the player just left the farm state (`ns.state.wasFarming` is set and the state isn't), cast the resolved ability back unless it is provably up or the add-on's own cast is in flight, then return. A refusal by the all-clear, a cooldown, or the GCD keeps `wasFarming` set so the next tick retries; it clears only once the restore has cast or has nothing left to do. The restore runs ahead of the Farm Mode and restricted-zone gates, so switching Farm Mode off mid-run, or dismounting in an instance or a town, still brings the ability back. Holds 3, 4, and 6 hold it too.
8. Stop if Farm Mode is off.
9. Stop in a restricted zone (see *Restricted Zones*).
10. Stop outside a farm state, or while `ns.CanCast()` refuses.
11. Build the cycle if needed, and stop if it is empty.
12. As a run starts (`wasFarming` still false), zoom the mini-map out (see *Mini-map Zoom*).
13. Cast. A one-entry cycle recasts only when its spell isn't provably up and the add-on's own cast isn't in flight, which is how a cancel from outside the add-on gets noticed. A longer cycle steps through `ns.AdvanceFarmCycle()`, which skips an entry that already matches `lastCastSpell`.
14. Set `wasFarming`.

Farm logic never uses the mirror as a gate. The multi-entry cycle compares against `lastCastSpell`, and the one-entry shortcut consults `ns.GetActiveTrackingSpell()` only as a positive signal. Those comparisons exist only to avoid spending a GCD on a no-op recast.

`ns.CanCast()` (`Features/Utilities.lua`) is the all-clear for every automatic cast and for the binding. It refuses while the player is dead or a ghost, stealthed, casting or channeling, in combat, looting, or holding something on the cursor (README-Notes → Decisions). Three of those cost more than a wasted GCD: any cast ends a channel, so a tracking cast would cut short Fishing, a bandage, or Eagle Eye; in Classic a spell cast closes an open loot window, so a tick mid-loot can cost the node just gathered; and a cast fired with an item or spell on the cursor drops it. Every condition is momentary and every caller retries.

`ns.AdvanceFarmCycle()` is the one advance path, shared by the ticker and the Cycle Farm Mode Ability binding. It honors `ns.CanCast()` itself, and it always recasts a one-entry cycle, since pressing the key has to do something visible.

### Farm-State Detection

`ns.GetPlayerStates()` (`Features/Utilities.lua`) returns `(isCat, isFarming, movementState)`. It scans up to 40 player buffs, classifies the movement state, and maps the state to its toggle through `ns.MOVEMENT_STATE_TOGGLES`:

| Movement state | Detected by | Toggle | Owning class |
| --- | --- | --- | --- |
| `taxi` | `UnitOnTaxi` | None: never a farm state | |
| `mounted` | `IsMounted()` | `farmMounted` | Every class |
| `travelForms` | A buff in `ns.FARM_FORMS` | `farmTravelForms` | `DRUID` |
| `cheetah` | A buff in `ns.CHEETAH_BUFFS` | `farmCheetah` | `HUNTER` |
| `pack` | A buff in `ns.PACK_BUFFS` | `farmPack` | `HUNTER` |
| `ghostWolf` | A buff in `ns.GHOST_WOLF_BUFFS` | `farmGhostWolf` | `SHAMAN` |
| `foot` | Everything else | `farmNotMounted` | Every class |

`isFarming` is true only when the master `farmMode` toggle and the current state's toggle are both on. The checks run in the table's order; in practice the states exclude each other, since mounting cancels forms and aspects. `ns.MOVEMENT_STATE_TOGGLES`, `ns.MOVEMENT_STATE_CLASS`, and `ns.CLASS_STATE_ORDER` (`Data/Data.lua`) tie each state to its toggle, its owning class, and its place in the on-foot pause reason. The buff scan, the pause-reason keys, and the option toggles still name each state themselves, so a new state has to be wired everywhere at once (see *Adding a New Farm Mode Condition*). Aspect of the Pack is a state of its own, off by default, and there is no Eagle Eye state, since a tracking cast ends that channel (README-Notes → Decisions).

Detection is class-agnostic, and so are the options: every class is offered every condition, because the toggles save to the profile, which characters of any class can share (README-Notes → Exceptions). The owning class matters only to the on-foot pause reason, which names just the states this character's class owns (`ns.IsPlayerClass`).

`isCat` is reported separately because Cat Form is not a farm state of its own: it counts as `foot`. It gates the druid's Cat Form tracking (see *Druid Tracking and Cat Form*).

The scan sits behind a **frame-scoped memo** keyed on `GetTime()`, which is constant for the whole frame, so a cached answer never comes from an earlier frame. `ns.UpdateIcon` and `ns.RunFarmLogic` each derive the states twice in one pass, directly and again through `ns.GetFarmPauseReason`, and `FlushIconAfterTrackingChange` runs `UpdateIcon` eight times in two seconds. Two bypasses are deliberate: while `ns.db` is nil the result is recomputed and never stamped, since `isFarming` reads the profile and the database appears mid-frame during `ADDON_LOADED`; and `ns:ApplyProfile` calls `ns.InvalidatePlayerStates()` first, since a profile switch rewrites the toggles `isFarming` comes from.

### Pause Reporting

Farm Mode goes quiet for reasons the player can't see, and "is it broken?" is the most common report. `ns.GetFarmPauseReason()` (`Features/Farm-Pause-Reporting.lua`) answers it in one place, returning a locale key or nil. It returns nil when Farm Mode is off: that isn't a pause, and the tooltip already reports Disabled. Settled reasons come first; the transient ones, which clear on their own within seconds, are checked only while the player is in a farm state:

| Kind | Reasons, in order |
| --- | --- |
| **Settled** | Dead; on a taxi; inside an instance or on a restricted map; resting; an empty cycle; the current state's toggle off; on foot with the on-foot toggle off |
| **Transient** | An options panel open; a window open; someone else's tooltip showing; in combat; casting; stealthed; looting; something on the cursor; an attackable target; standing still; the add-on's own tooltip, ranked last |

An empty cycle has three causes, told apart by `ns.GetEmptyCycleKind()` (`Features/Farm-Mode.lua`): nothing ticked (`FARM_PAUSED_NO_ABILITIES`), nothing ticked that this character knows, like Find Herbs ticked with no Herbalism (`FARM_PAUSED_NOT_LEARNED`), or only the druid's Cat Form tracking known, outside Cat Form (`FARM_PAUSED_CAT_FORM`). Reporting the first for the second tells a player to tick abilities that are already ticked, and the second for the third tells a druid they don't know a spell they do. The binding's chat line splits the same three ways.

On foot, `GetMovementReason` names the states that *would* start the cycle, considering only those this class owns and this flavor can detect, so a mage is never told about Ghost Wolf. A class that owns several, such as a hunter's Cheetah and Pack, is told about the first one switched on in `ns.CLASS_STATE_ORDER`. Each pairing is **one precomposed locale key** (`FARM_PAUSED_NOT_MOUNTED_TRAVEL`, `FARM_PAUSED_NOT_MOUNTED_CHEETAH`, and so on) rather than fragments joined at runtime, because a comma-spliced sentence assembled from pieces can't be translated correctly.

Several transient reasons are Farm Mode's own holds rather than `ns.CanCast()` conditions, so they stop the cycle without touching the manual binding: an options panel, a window, a tooltip, an attackable target, and standing still. All but standing still leave the persistent recast alone too; standing still holds it through its own check (see *Waiting for Movement*).

Tooltips are checked in two halves. The mini-map button and the free frame both draw into `GameTooltip`, and hovering them is how the player reads the Farm Mode Status, so `ns.IsTooltipShowing()` covers everyone else's tooltips and `ns.IsOwnTooltipShowing()` the add-on's own, ranked last so the status names any other cause first. `ns.BuildTooltip` draws before its tooltip shows, when the live check can't see it yet, so it passes `true` as `ns.GetFarmPauseReason`'s `ownTooltipShowing` argument. `ns.minimapButton` is stored in `ns.InitMinimap` for that owner comparison. `ns.IsBlockingWindowOpen()` sweeps `UIPanelWindows` rather than a hand-written list, so every standard window stays covered when Blizzard adds one, plus a short `EXTRA_BLOCKING_FRAMES` list for frames never registered there, such as the game menu, the Settings panel, and `StaticPopup1`. `ns.IsOptionsPanelOpen()` (`Options/Options.lua`) evaluates `IsVisible()` live on every call: closing the Settings window hides the window, not the add-on's canvas, so a cached flag or an `IsShown()` read would stay true and pause Farm Mode until the next reload.

The reason has one surface, the Farm Mode Status block in the mini-map tooltip. Because several conditions fire no registered event, a taxi flight above all, `ns.RunFarmLogic()` re-resolves the reason on every tick before its holds and calls `ns.UpdateIcon()` only when the value changed, which redraws an open tooltip.

### Farm Cycle Cache

`BuildCycleCache()` builds `cachedCycle`, a sorted array of spell IDs, from every enabled entry in `ns.db.profile.farmCycleSpells` that the character knows, admitting the druid's Cat Form tracking only in Cat Form. Sorting keeps the cycle order stable across reloads. The cache records the Cat Form state it was built for, and every read (`ns.GetFarmCycleCount()`, `ns.GetFarmCycle()`, the tick, the advance) goes through `EnsureCycleCache`, which rebuilds it when that state has changed, so shifting in or out of Cat Form needs no invalidation of its own.

With `farmIncludePersistent` on, the cache also appends the resolved ability (`ns.GetPersistentSpell()`, so a running hunt takes the pick's place), guarded by a membership set so an ability that is both the persistent entry and ticked in the list appears **once**; queued twice, it would take double the airtime of everything else.

`ns.InvalidateFarmCache()` nils the cache, and the next read rebuilds it. It runs on `SPELLS_CHANGED`, `PLAYER_ENTERING_WORLD`, and a main-hand change, on every profile change, on every hunt change, on every write of `selectedSpellId` (the Tracking Menu, Clear Tracking), and from the `set` handler of each Farm Mode Abilities toggle, the Include Persistent Tracking Ability toggle, and each Persistent Tracking sub-option. `ns.GetFarmCycleCount()` is the only reader of the cycle's size outside the file, and `ns.GetFarmCycle()` hands Diagnostics a copy, never the live cache.

### Cycle Sound Mute

`ns.db.profile.muteCycleSound`, on by default, silences the sound of Farm Mode's own casts. Every cycle cast, the ticker's and the binding's, goes through one seam, `ns.CastCycleSpell(spellId)` in `Features/Cycle-Sound-Mute.lua`. The form-leave restore, the Tracking Menu, the persistent and post-resurrection recasts, and the hunt call `ns.CastTracking` directly and keep their sound.

**Why a CVar.** A tracking spell's cast audio comes from the spell's own SoundKit, played by the engine; it never passes through `PlaySound` or `PlaySoundFile`, so no FileDataID reaches Lua and `MuteSoundFile` has nothing to take. Switching `Sound_EnableSFX` off is the only lever.

**The window is the whole trick.** The audio doesn't fire inside `CastSpellByID`. It fires when the server confirms the cast, a round trip later, so muting and restoring around the call silences nothing. The mute holds until `UNIT_SPELLCAST_SUCCEEDED` reports the spell (`ns.NotifyTrackingCastSucceeded`, usually well under 200 ms) and lifts `ns.CYCLE_MUTE_TAIL_SECONDS` (0.1) after that, with `ns.CYCLE_MUTE_SECONDS` (0.6) as the ceiling for a cast the server never confirms. Restores are generation-stamped, so overlapping casts can't restore each other early.

This is the momentary kind of write Style Guide → WRITING USER CVARS allows: made around the add-on's own automated action and restored within a second to the exact value read, so it prints nothing. It has its own toggle, and `README.md` discloses it. Four safeguards keep it that way:

- **Cast first, arm second.** `ns.CastTracking` returns `false` on every early bail (an unknown spell, the Cat Form gate, a cooldown, the GCD), and the mute arms only after a cast was attempted. Arming afterwards is safe precisely because the audio plays on confirmation.
- **Teardown restores unconditionally.** `ns.RestoreCycleSoundNow()` runs from the `PLAYER_LOGOUT` handler, which covers `/reload` as well, and from the toggle's `set` when the player switches the option off. `Sound_EnableSFX` persists across sessions, so a mute whose timer died with the UI would leave the player with sound effects off and nothing to connect it to.
- **The cast runs inside `pcall`**, so an error can never skip the restore.
- **Nothing is written when sound effects are already off**, and the restore puts back the exact string that was read.

The trade-off: the mute silences every sound effect for that instant, not only the cast, so a sound already playing can be clipped. At a 3.5-second cycle that is rarely audible.

### Mini-map Zoom

**Zoom Mini-map Out** (`ns.db.global.farmZoomOut`, a Farm Mode sub-option, on by default) zooms the mini-map all the way out as each Farm Mode run starts, on the tick where the cycle is about to cast and `wasFarming` is still false. Zoomed out, the mini-map shows tracked nodes from farther away. It acts only then, so a player who zooms back in mid-run keeps that until the next run, and it never restores the player's own zoom (README-Notes → Decisions). It skips the write when the mini-map is already fully out. The key lives in `global` although it sits on the Farm Mode panel: it changes the client's own mini-map, which every character shares, so per-character copies would only undo each other.

`Minimap:SetZoom` alone leaves Blizzard's zoom buttons showing the old state, so a player who was fully zoomed in would find zoom-in greyed out; Blizzard's own zoom clicks set the buttons themselves after the call. `ZoomMinimapOutForRun` does the same, enabling zoom-in and disabling zoom-out on `Minimap.ZoomIn` and `Minimap.ZoomOut` (WoW Forever) or `MinimapZoomIn` and `MinimapZoomOut` (Classic Era, TBC Anniversary), whichever exists.

### Druid Tracking and Cat Form

`ns.CAT_FORM_ONLY` (`Features/Utilities.lua`) holds the druid's tracking, which can be cast only in Cat Form: Track Humanoids (`ns.SPELLS.DRUID_HUMANOIDS`, 5225) on every flavor, and Track Beasts (`ns.SPELLS.DRUID_BEASTS`, 210065) on Retail. Each is listed in the Farm Mode Abilities list under Druid, beside the hunter's own, and the cycle admits it, from the list or as the persistent entry, only while the player is in Cat Form. Cat Form counts as on foot, so in practice it cycles for a druid farming with **Not Mounted** ticked; in Travel Form the rest of the cycle runs without it rather than spending a step on a cast that always fails. Every toggle in that list shows its ability's own tooltip on hover (`tooltipHyperlink`), so these carry their catch on the panel instead, muted beside the name (`OPTIONS_FARM_CAT_FORM_NOTE`).

Everywhere Cat Form can't be assumed, the add-on keeps them out of reach: `ns.CastTracking()` refuses them outside Cat Form, the form-leave restore and the post-resurrection recast skip them there, `ns.UpdateIcon` clears them from `lastCastSpell` when the player shifts out, the Tracking Menu hides them unless the player is in Cat Form, and `ns.CREATURE_TYPE_DATA` omits them so a hunt never lands on one.

**Druid: Track Humanoids when you Shift into Cat Form** (`catFormHumanoids`, off by default) makes Druid Track Humanoids the Persistent Tracking Ability while the druid is in Cat Form, through the resolver. Nothing else is needed: `UPDATE_SHAPESHIFT_FORM` schedules the recast both ways, and like every automatic cast it waits out Prowl, since `ns.CanCast()` refuses while stealthed.

### Restricted Zones

`ns.IsRestrictedZone()` (`Features/Utilities.lua`) is true inside any instance (`IsInInstance()`: a dungeon, raid, battleground, or arena), on a map listed in the flavor folder's `ns.RESTRICTED_MAP_IDS` (Deeprun Tram, 369, on every flavor), and while resting (`IsResting()`: capital cities and inns). It shares `ns.GetRestrictedKind()` with the pause reason, so the gate and the reason can never disagree about what counts. The design stays deliberately simple, with no capital-city or battleground tables and a single map-ID special case. The trade-off is breadth: Farm Mode pauses anywhere the resting flag is set, which covers more than the named cities, and it reacts only as fast as the client sets that flag. `ns.IsOutInTheWorld()` adds "not on a taxi" to the same test for Automatic Target Tracking.

## Automatic Target Tracking

`Features/Target-Tracking.lua` runs the **hunt**: out in the world, the kind of creature the player targets temporarily stands in for the Persistent Tracking Ability. It is opt-in (`ns.db.profile.targetTracking`, off by default) and open to every class; whatever creature types a character can track, it can hunt. A Hunter covers seven types (eight on Retail, with Mechanical), and a Paladin's Sense Undead or a Warlock's Sense Demons covers one where the flavor has it. The section on the General panel and the mini-map tooltip block show on every character, since the setting lives in the profile, which characters of any class can share (README-Notes → Exceptions); a character that covers no creature type simply never starts a hunt.

`ns.CREATURE_TYPE_SPELLS` (built in `Features/Utilities.lua` from each flavor folder's `ns.CREATURE_TYPE_DATA`) is keyed by the **creature type ID** that `UnitCreatureType` returns as its second value: 1 Beast, 2 Dragonkin, 3 Demon, 4 Elemental, 5 Giant, 6 Undead, 7 Humanoid, 9 Mechanical, the same on every client and in every locale. That is what makes the feature locale-proof without a single locale key of its own. Never match on the name `UnitCreatureType` returns first: it is localized. Each type maps to a list of candidates in preference order, such as Track Undead or Sense Undead, and `ns.GetCreatureTypeSpell()` returns the first one the character knows.

**An automatic signal must never overwrite a choice the player saved.** The hunt is runtime state only (`ns.state.huntSpellId`), never saved, and nothing automatic writes `selectedSpellId`: the Tracking Menu sets it on the player's own click, and Clear Tracking clears it. Login and `/reload` always start without a hunt, and walking into town gives the player's own pick back. The resolver folds the hunt in (see *The Resolver*), so the recasts, the form-leave restore, and the farm cycle's persistent entry follow it without knowing about it. With Persistent Tracking off, hunts still start and switch, but nothing is ever recast.

`ns.OnPlayerTargetChanged()` runs on `PLAYER_TARGET_CHANGED`. The bail chain:

1. `ns.db` missing or `targetTracking` off: stop. Persistent Tracking being off doesn't stop it.
2. Not out in the world (`ns.IsOutInTheWorld()`), or in combat: stop, and nothing is queued (see *Combat Lockdown*).
3. No living, attackable target (`ns.HasAttackableTarget()`, the same test that holds Farm Mode), or an enemy player: stop. Creatures only, so clicking an add's corpse to loot it keeps the hunt.
4. No known candidate for the creature type, read through `ns.GetUnitCreatureType` (see *Secret Values*): stop.
5. The hunt is already this spell: stop.
6. Otherwise start or switch the hunt and cast it at once: one global cooldown per new kind of creature, not per pull (README-Notes → Decisions).

Every hunt change invalidates the farm cycle cache and refreshes the icon and tooltip. The cast treats `ns.GetActiveTrackingSpell()` only as a positive "already up" signal, and when `ns.CanCast()` or a cooldown refuses, it retries every `HUNT_RETRY_SECONDS` (2) until it lands or the hunt changes or ends; a generation counter retires a retry that belongs to an older hunt. While Farm Mode is actively cycling with Include Persistent Tracking Ability off (`farmIncludePersistent`), the hunt doesn't cast: it stays out of the rotation, and the form-leave restore brings it back when the farm state ends (README-Notes → Decisions).

A hunt has no fade timer. It ends only at a context break: resting starting (`PLAYER_UPDATE_RESTING`), arriving in a restricted zone (`PLAYER_ENTERING_WORLD`, `ZONE_CHANGED_NEW_AREA`), a flight starting (seen by the farm tick through `ns.HandleFlightState`), a Tracking Menu pick, Clear Tracking, switching the feature off (the options toggle or Shift + Right-Click, both through `ns.SetTargetTracking`), and a profile change. Killing the target, looting, or clearing the target keeps it. `ns.EndHunt(restorePersistent)` brings the Persistent Tracking Ability back through `ns.TryRecastPersistent` for every break except the menu pick and Clear Tracking, which set tracking themselves; after a flight that ended a hunt, landing triggers that recast.

## Come & Get It

`Features/Come-and-Get-It.lua` is the standalone Come & Get It add-on folded in as a feature (README-Notes → Decisions). Right-click an herb the player can't pick, a vein they can't mine, or a locked chest, and the error the client raises becomes a chat draft naming the node, its coordinates, and the zone. **It never sends anything**: the draft opens in the chat box for the player to send, edit, or delete. It is on by default (`ns.db.profile.comeAndGetIt`) and has its own options page directly beneath Farm Mode. The standalone's `/cgi` command, welcome message, and link rows didn't come across. Running the standalone alongside is harmless: whichever handler runs second finds the chat box already open and stands down.

The pipeline is gate, detect, compose, write, entered from Core's `UI_ERROR_MESSAGE` branch through `ns.OnUIErrorMessage(messageID, message)`.

**Gate: `CanAnnounce()`.** The toggle, then `IsInInstance()`, then `InCombatLockdown()`, then the 5-second cooldown (`ns.ANNOUNCE_COOLDOWN`). It runs before any matching on purpose: every "Out of range" and "Not enough rage" fires this event, hardest in combat, which is exactly when the gate says no, so a discarded error costs no string work.

**Detect: `ns.MatchError(messageID, message)`.** Two tables, one per kind of key:

- **Fast path, by error name.** A numeric `UI_ERROR_MESSAGE` index shifts between patches and between clients, since WoW Forever's Retail engine numbers errors differently from Classic, so the matcher resolves it with `GetGameMessageInfo` and looks up the GlobalStrings name. Locked chests match here, through `ns.ERROR_STRING_LOCKED_CHEST` (`"ERR_ITEM_LOCKED"`).
- **Slow path, by skill name.** Herb and mine nodes raise the same `Requires <Skill>` error, so only the localized skill name tells them apart: the lowercased message is substring-scanned for `L["MATCH_HERB"]` and `L["MATCH_MINE"]`. One `MATCH_*` string can hold several names separated by semicolons, for a language whose clients don't all name the skill the same way. Substring matching is an accepted trade-off: word-boundary patterns break CJK locales, and a false match is bounded because nothing is ever sent.

The two mappings stay separate tables because both key kinds are strings; merged, the substring scan would also try `ERR_ITEM_LOCKED` against message text. `ns.MatchError` lives on the namespace because the Diagnostics noise filter classifies with it.

**Compose: `AnnounceNode(mapping)`.** Each step bails silently: the map from `C_Map.GetBestMapForUnit`; the position from `C_Map.GetPlayerMapPosition`, where an exact `0, 0` means the map can't resolve the player; the zone from `C_Map.GetMapInfo`; the node name from `GameTooltipTextLeft1`, read only while `GameTooltip:IsShown()` because the font string keeps its last text after the tooltip hides; and a bail when the tooltip shows an item, because a lockbox in the bags raises the same locked error as a world chest. `GameTooltip:GetItem` backs that check because `TooltipUtil` isn't on every client. The line comes from `ns:BuildAnnounceMessage` (`Features/Announcements.lua`).

**Write.** `ChatFrameUtil.OpenChat(command .. " " .. announcement, ChatFrame1)`, skipped while `ChatFrameUtil.GetActiveWindow()` reports the player is already typing. The code calls `ChatFrameUtil` directly; the older `ChatFrame_OpenChat` and `ChatEdit_GetActiveWindow` globals survive only as deprecated aliases. `lastAnnounceTime` is stamped only after a successful open, so a bailed attempt never starts the cooldown. A line over 255 bytes (`ns.CHAT_MESSAGE_MAX_LENGTH`) prints `CHAT_TOO_LONG` but still opens whole: a byte-wise cut would split a multi-byte character, and the player edits the draft anyway. The measurement covers the line alone, since the client consumes the command prefix as a channel selector.

### The Draft Line

What lands in the chat box, with Local chosen:

```text
/1 Hey Miners! Rich Thorium Vein at 25, 54 in Eastern Plaguelands.
```

Each `MSG_FORMAT_*` body is the whole line after the command, with four `%s` in a fixed order: node name, x, y, zone. It carries no target marker, no add-on name, and no ` // `: a line drafted into the player's own chat box is the player's words (Style Guide → MESSAGES → Target Marker), and WoW Forever blocks raid-marker tokens in chat anyway. The greeting closes on "!" so nothing attaches to the node name, and no article or adjective has to agree with a name whose gender and number are unknown until runtime. `ns:BuildAnnounceMessage` strips stray pipes from the result; the bodies never carry item links, so nothing is lost.

### Output Channels

`ns.OUTPUT_CHANNELS` (`Data/Data.lua`) pairs each stable saved key with a slash command and a locale label key. The feature derives its key-to-command lookup from it and the options page derives the dropdown, so the list, its order, and the mapping can't drift. The chosen key is saved as `ns.db.profile.comeAndGetItOutput`. A key that no longer exists falls back to `ns.DEFAULT_OUTPUT_CHANNEL` (`channel1`, Local) at write time, and the dropdown shows that default rather than a blank.

Beneath the dropdown sits a one-line note, `OPTIONS_OUTPUT_NOTE`: Local (/1) only reaches players on your layer. It is there by exception to the rule that helper text lives in the tooltip (README-Notes → Exceptions), and the dropdown's tooltip carries a different tip so the two never repeat each other.

## Tracking Menu

`Features/Tracking-Menu.lua` builds one LibUIDropDownMenu dropdown at file scope and exposes `ns.ToggleMenu(anchor)`. Rows are every ID in `ns.TRACKING_IDS` that resolves a name and passes `IsPlayerSpell`, sorted by the **localized** name so the list reads alphabetically in every client. The druid's Cat Form tracking is hidden unless the player is in Cat Form.

LibUIDropDownMenu honors `info.fontObject` only on enabled buttons, so the title and every ability row are built as enabled entries, the title simply without a `func`; that is the only way to get the larger font. Spacer rows between abilities are `notClickable` entries with empty text.

Picking a row ends any running hunt (without the restore, since the pick casts itself), writes `ns.db.profile.selectedSpellId`, invalidates the farm cache, clears `ns.state.wasFarming` so the next tick doesn't run a redundant form-leave restore of the ability just cast, and calls `ns.CastTracking` directly, never through `ns.CanCast()`, because a deliberate click must always cast. The Tracking Menu is the only way to choose the pick: a tracking spell cast from an action bar, the spellbook, a macro, or WoW Forever's own tracking menu is never treated as one (README-Notes → Decisions).

### Blizzard Tracking Button Takeover

`ns.ApplyBlizzardTrackingHook()` optionally makes Classic Era's own mini-map tracking icon open the Tracking Menu. It is gated on `ns.db.global.hookBlizzardTracking` (account-wide presentation, off by default) and called at the end of `ns.InitMinimap()`, from `ns:ApplyProfile`, and from the option's `set` handler.

It is offered on Classic Era only (README-Notes → Decisions). There the icon is the plain `MiniMapTracking` frame, which has no menu of its own: a right-click cancels tracking, and the takeover replaces that. On TBC Anniversary and MoP Classic, `MiniMapTrackingButton` is a Blizzard dropdown button whose built-in mouse-down opens Blizzard's own tracking menu, which no script swap can stop, so a takeover would open two menus on one click. `ns.HasBlizzardTrackingButton()` therefore reports a frame only when `MiniMapTracking` exists and `MiniMapTrackingButton` doesn't, and the option hides everywhere else.

- **A takeover, not `HookScript`.** A hook would leave Blizzard's own handler running, so the frame's `OnMouseUp` handler is saved and replaced.
- **Restore puts the frame back exactly as found.** Turning the option off re-installs the saved handler, a nil one included, and clears the saved state.

The frame is neither secure nor protected, so replacing its script raises no taint. A UI that swaps the frame out after the takeover, such as an ElvUI reskin, gets the saved handler back on restore, which is the documented limit of the contract.

## Mini-map Button and Free Placement

`ns.InitMinimap()` (`Features/Minimap-Button.lua`) registers a LibDataBroker-1.1 launcher and hands it to LibDBIcon-1.0 with the saved `ns.db.global.minimap` table. `ns.CreateFreeFrame()` (`Features/Free-Placement.lua`) builds the standalone button used in Free Placement Mode: the same launcher drawn somewhere else, sharing the tooltip (`ns.BuildTooltip`) and click handler (`ns.HandleLauncherClick`).

`ns.UpdatePlacement()` decides which one shows. A character with no tracking ability (`ns.HasTrackingAbility()`) gets neither. With `ns.db.global.freePlacement` on, the free frame shows and the LibDBIcon button hides without touching `minimap.hide`, so the Enable Mini-map Button preference survives a round trip through Free Placement; otherwise `LibDBIcon:Refresh` honors that preference. The Enable Mini-map Button toggle is disabled while Free Placement is on.

### Tooltip

`ns.BuildTooltip` draws both surfaces, in order: the Tracking Menu, the Persistent Tracking Ability, Farm Mode, the Farm Mode Status (only while Farm Mode is on: gray Paused with its reason, or green Active), Automatic Target Tracking, and the options block (README-Notes → Decisions). The Persistent Tracking Ability row always shows the saved pick, and the Automatic Target Tracking block doesn't name a running hunt: the icon already shows what is tracked. Persistent Tracking itself has no block, since it is set in the options panel.

`ns.RefreshTooltip()` re-runs the owning frame's `OnEnter` while its tooltip is on screen, so a change made by a click updates the text in place.

### Click Map

`ns.HandleLauncherClick` drives both the LibDBIcon button and the free frame:

| Click | Action |
| --- | --- |
| Left-Click | Open the Tracking Menu |
| Right-Click | `ns.ClearTracking()`: cancel tracking and forget the pick |
| Shift + Left-Click | Toggle Farm Mode |
| Shift + Right-Click | `ns.SetTargetTracking()`: toggle Automatic Target Tracking; switching it off ends any hunt |
| Shift + Middle-Click | `ns:OpenOptionsPanel()` |

Shift + Middle-Click is handled before the `ns.db` guard, so the options panel opens regardless of saved-variable state. `ns.ClearTracking()` ends any hunt, clears `lastCastSpell` and `selectedSpellId`, invalidates the farm cache, calls `ns.CancelActiveTracking()`, and forces the default icon at once: the cancel is asynchronous, and the mirror would still report the old texture for a frame.

### Anonymous Free Frame

The free-placement frame is created with `nil` as its name on purpose. WoW's per-character `layout-local.txt` cache keys frames on their name, and a named frame is looked up there at creation and silently given a cached position from a previous session, overriding the account-wide `ns.db.global.freePos`. `SetUserPlaced(false)` from Lua doesn't prevent the lookup. An anonymous frame is outside that system entirely, so `freePos` alone owns placement.

### Position Pipeline

The frame uses two helpers, `SaveFreePosition(frame)` and `ApplyFreePosition(frame)`, the second also exported as `ns.ApplyFreePosition` for `ns.UpdatePlacement`, and one stable anchor: `frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)`.

- **Storage.** `ns.db.global.freePos = { x = ..., y = ... }` holds the frame's center in UI units at scale 1.0, the live `GetCenter()` multiplied by the effective scale at save time. Both ends of the round trip convert through the frame's current effective scale, so a later UI-scale or icon-scale change doesn't drift the saved position. With no `freePos` the frame sits at screen center.
- **Save points.** `OnDragStop` after every drag, and `ns.SaveFreeFramePosition()` from the `PLAYER_LOGOUT` handler as a backstop, **guarded on the frame being shown**.
- **Why the logout save is guarded.** The round trip is exact only when the effective scale at save time matches the one the last apply used. `UpdatePlacement` returns early for a character with no tracking ability, skipping the re-anchor, so on that character the frame keeps its first anchor from `ADDON_LOADED`, before `UIParent`'s effective scale settled to the `uiScale` CVar. An unguarded logout save would read those stale offsets against the settled scale and write a drifted `freePos`, and since `freePos` is account-wide, that moves the icon for every character. The `IsShown()` guard also stops a never-shown frame from materializing a `freePos`.
- **Apply points.** The end of `CreateFreeFrame`, the end of `ns.UpdateFreeFrameScale` (so `SetScale` doesn't shift the offsets), `UpdatePlacement` before every `Show()` (against any code path that re-anchored the frame while hidden), and right after a drag, normalizing the live anchor back to the canonical one.
- **`SetUserPlaced(false)`** runs in both `OnDragStop` and `ApplyFreePosition`. `StartMoving` and `StopMovingOrSizing` silently flag a frame as user-placed for the rest of the session, and a stale flag can make the client write a layout-local entry on logout that out-races the SavedVariables at the next login.

Shape is a texture swap, not a rebuild: `ns.UpdateFreeFrameShape` shows either the circle pair or the square pair of textures created up front.

## Key Bindings

One binding ships, defined in `Bindings.xml` at the add-on root: `TRACKINGEYE_CYCLE_FARM_ABILITY`, which advances the Farm Mode cycle one step. It is a **manual** control, deliberately not gated on `farmMode`: it works with Farm Mode off, standing still, or anywhere the automatic cycle is paused. It still goes through `ns.AdvanceFarmCycle()`, so it obeys `ns.CanCast()` exactly as the ticker does, and on an empty cycle it prints why rather than failing silently: `BINDING_NOTHING_TO_CYCLE` when nothing is ticked, `BINDING_NOTHING_LEARNED` when this character knows none of the ticked abilities, and `BINDING_NEEDS_CAT_FORM` when the only ones it knows are the druid's Cat Form tracking, outside Cat Form. The binding's chat line splits the same way as the pause reason (see *Pause Reporting*).

An AceConfig panel can't set a binding, so the General panel carries a Key Bindings section that points at the game's own Key Bindings list, using the same display name.

`Bindings.xml` is **found at the add-on root by the client and must never be listed in a TOC**. Listed, it goes through the generic UI XML parser, which doesn't know the `<Bindings>` node and rejects the whole file, so the binding never appears. Its root element is `<Bindings>`, never a `<Ui>` wrapper, which fails the same way. The `Binding` element carries `name` and `category`: the category string draws the collapsible **Tracking Eye** section in the Key Bindings list, and without it the binding loads with nowhere to appear.

## Options Panels

`Options/Options.lua` registers five panels in a fixed order, which is the order of the `AddToBlizOptions` calls: General (the root), Farm Mode, Come & Get It, Profiles, and Diagnostic Tools. Registration is deferred to `ns.RegisterOptionsPanels()`, which `Core.lua` calls right after `AceDB:New`, because the Profiles builder reads `ns.db`. Every registry name comes from `ns.OPTIONS_REGISTRY` (`Data/Data.lua`), derived from `ADDON_NAME`.

- **The opener routes by captured handles.** `ns:OpenOptionsPanel` gates on combat first (see *Combat Lockdown*), then calls `Settings.OpenToCategory` with the category ID captured from the root panel's `AddToBlizOptions`, and falls back to `AceConfigDialog:Open` only when registration returned no ID. A lookup by the panel's name returns nil wherever AceConfigDialog keeps a generated category ID, which drops the panel into a floating window.
- **Open panels redraw on outside changes.** AceConfig re-evaluates dynamic `name`, `disabled`, and `get` callbacks only when it redraws, so `ns.RefreshOptionsPanels()` fires `NotifyChange` for every registered name. `ns:ApplyProfile` calls it; so should any new writer that changes a setting from outside the panel.
- **Master switches hide their pages.** With Enable Farm Mode or Enable Come & Get It off, everything below it on that page hides outright, so the page is the toggle and nothing else. Persistent Tracking's and Free Placement Mode's sub-options collapse with their toggles the same way.
- **Sub-option rows** come from `ns.OptionsSubRow` (`Options/Options-Utilities.lua`), and three details there are load-bearing: one unnamed inline group per sub-option, or the next control packs onto the leftover space and the indent stops indenting; controls sized with slack rather than to the full row width, or a control on the wrap boundary tips onto its own line and strands the indent; and `hidden` on the group, not its members, or the indent is left behind when the section collapses.
- **Label-beside-control rows** (Cycle Speed, Default Output, the Feedback & Support links) pair `ns.OptionsRowLabel` with a control whose `name` is empty, the two totaling `ns.OPTIONS_ROW_WIDTH`. A row that can hide, as Cycle Speed and Default Output do, sits in an unnamed inline group so the pair hides as one. The cycle-interval dropdown needs its `sorting` list: without it the numeric keys sort as strings and "10" lands ahead of "2".
- **Every class sees every option.** The Farm Mode Abilities list shows every tracking spell the client has, learned or not, and every Farm Mode Condition shows to every class, because a profile can be shared by characters of different classes (README-Notes → Exceptions).

## Diagnostics

The Diagnostic Tools system (`Features/Diagnostics.lua` and `Options/Options-Diagnostics.lua`) exists to make bug reports actionable. It isn't a unit-test runner, since WoW's sandboxed Lua has none: every report builds only on an explicit button press, and every check is read-only and side-effect free except the Taint Log buttons, which set the `taintLog` CVar.

- **Runtime-only state.** `ns.diagnostics` is a plain namespace table, never a SavedVariable, so file-scope initialization is correct and every session starts with the panel off. Turning it off stops the event log and releases its buffer, and retires any Validate Data run in progress.
- **English-only strings.** Diagnostics text lives in `ns.DiagnosticsStrings`, deliberately not localized. The add-on title is the only localized string it uses as its own text; the Come & Get It Context report also prints the two `MATCH_*` strings, as data. Every widget below the enable toggle shares one condition, so the panel bakes it into local `SectionHeader` and `ReportOutput` builders.
- **Fourteen sections, in panel order:** Event Log, Event Registration, API Endpoints, Player & Spell Context, Display Context, Farm Mode Context, Come & Get It Context, Other Add-ons, Saved Variables, Library Versions, one Validate Data section for each of the two flavor data files, Taint Log, and External Tools. Every report opens with a client header: add-on version, client version, build, TOC number, locale, `ns.FLAVOR`, and `ns.DATA_FOLDER`, never `WOW_PROJECT_ID`, which reads the same on WoW Forever and Retail.
- **Event Registration** checks every name in `ns.EVENT_NAMES` with `C_EventUtils.IsEventValid` and a register-and-unregister round trip on a probe frame.
- **API Endpoints** runs `ns.DIAGNOSTIC_API_CHECKS`, existence and shape checks for every API the add-on reaches directly as a namespaced call, through a guard, or through an accessor, plus the load-bearing calls the core loop depends on. A row with its optional third element set is one half of a compatibility guard or an optional read, absent on some clients by design: it renders `[n/a]` and never counts as a failure. Any other miss is a real problem.
- **Player & Spell Context** lists class, level, and every `ns.TRACKING_IDS` entry as known, not known, or not on this client (`ns.DIAGNOSTIC_SPELLS`).
- **Display Context** prints the screen size, UI scale, `uiScale` CVar, the free-placement state and `freePos`, the LibDBIcon position, and the mini-map zoom.
- **Farm Mode Context** is the add-on's own context probe and answers most "it stopped cycling" reports in one paste: Farm Mode's toggles and interval, the Persistent Tracking overrides and the other feature toggles beside `Sound_EnableSFX`, the live movement inputs, the resulting `ns.GetPlayerStates()` classification, `ns.CanCast()` and `ns.IsRestrictedZone()`, the raw mirror beside `lastCastSpell`, every `C_Minimap` tracking entry, the pause reason, the target's creature type and what it resolves to, the hunt and the resolver's answer, and the cycle as Farm Mode casts it. The pause reason prints as its **raw locale key**, so a report pasted from a zhTW client is still readable.
- **Come & Get It Context** prints live values: the toggle and channel, the locked-chest error name, the two match strings, the instance and combat gates, and the map, position, and zone `AnnounceNode` would use. An existence check can't prove the map chain returns something usable. If herbs and veins stay silent while chests work, the match strings don't equal what that client prints.
- **Validate Data.** `ns.DIAGNOSTIC_DATA_SOURCES` names each flavor data file by label (`Spells`, `Zones`) and each of its tables by its key on `ns`, with a kind (`spell`, or `other` for IDs no client API looks up) and how to reach each row's ID. The folders share their table names, so one manifest serves every flavor, and each section's title reads the folder from `ns.DATA_FOLDER`. A run requests 100 spell IDs at a time, polls until each settles, and prints a tab-separated report: `OK`, `NOT ON CLIENT` (`C_Spell.DoesSpellExist` is false, or the ID never loads), `INCOMPLETE` (loaded, but its description or tooltip never did), `ERROR` (a reader threw), and `TABLE MISSING` for a table the folder never built. A `NOT ON CLIENT` row is a row in the wrong folder. Tooltip text comes through `ns.GetSpellTooltipText`: `C_TooltipInfo` where the client ships it, a hidden `GameTooltipTemplate` tooltip where it doesn't.
- **Event Log.** A 500-entry buffer fed by `ns:LogEvent` from the Core dispatcher, capped at 8 arguments of 255 bytes each, with pipes escaped **after** the length cut so a truncated argument can't leave a dangling pipe. Stop keeps the capture for Show, and Start replaces it. `ns.DIAGNOSTIC_EVENT_EXCLUDE` is deliberately empty, since the log only ever sees events the add-on registered and each carries signal. `UI_ERROR_MESSAGE` is a firehose that is only sometimes signal, so `ns.MESSAGE_ID_FILTERED_EVENTS` names the argument position of its message ID and `ns:SuppressUncorrelatedMessage` classifies each firing at capture with the live `ns.MatchError`: a correlated firing logs in full, a firing with no ID logs verbatim, and everything else folds into a per-ID counter printed at the end of the report, biggest first. Filtering at capture rather than at render is the point: combat spam would otherwise evict the one line the report exists to carry. On a match, the feature also logs a synthetic `GetNodeName(...)` entry carrying the tooltip read, and a nil there means the read missed.
- **Taint Log.** `ns:SetTaintLog` writes the `taintLog` CVar, 0 for off and 2 for verbose, the only state the panel ever writes. **External Tools** points at `/console scriptErrors 1`, BugSack and !BugGrabber, and `/etrace` rather than reimplementing them.

### Offline Tests

`tools/Test-Event-Log-Noise.lua` pins the noise filter with the three cases Build Reference → DIAGNOSTIC TOOLS → Event Log Noise requires: spam collapses to one counted row, a correlated ID still logs a full line, and an event with no ID logs verbatim. It loads `Features/Come-and-Get-It.lua` and `Features/Diagnostics.lua` into a stubbed sandbox, so it runs outside the game: `lua tools/Test-Event-Log-Noise.lua` from the add-on root, with Lua 5.2 or later, since it passes an environment to `loadfile`. It prints one PASS or FAIL line per test and exits non-zero on any failure. No TOC lists `tools/`, and `.pkgmeta` keeps it out of the release.

## Saved Variables

Tracking Eye declares one SavedVariables table, `TrackingEyeDB`, managed by AceDB-3.0 and read through `ns.db`; only the Diagnostics dump reads the raw global. There is no `SavedVariablesPerCharacter` line.

**Model: Per-Character.** `AceDB:New("TrackingEyeDB", ns.DATABASE_DEFAULTS)` omits the third argument, so each character lands on its own `"Name - Realm"` profile, because the add-on stores what genuinely differs by character: the tracking ability that character picked and the abilities its Farm Mode cycles. **Reset Profile therefore clears that character's tracking picks and feature settings only**; everything in `global` survives, so a reset or a profile switch never moves the mini-map button, the free icon, or its shape and size, and never brings the welcome message back. That is the fact to check before adding a setting.

- **`profile`** holds the character's choices and the feature settings that ride with them: Persistent Tracking with its pick and its three overrides, Farm Mode's toggle, interval, conditions, ability map, persistent entry, and sound mute, Automatic Target Tracking's toggle, and Come & Get It's toggle and output channel.
- **`global`** holds presentation: the LibDBIcon `minimap` table, Free Placement Mode (on or off, `freePos`, icon size and shape), the welcome message, the Blizzard tracking-button takeover, and Farm Mode's mini-map zoom, which lives here because it changes the client's own mini-map.

`Data/Default-Settings.lua` is the source of truth for the keys. Runtime state is never saved: `ns.state` (the running hunt, `lastCastSpell`, the loot flag) and `ns.diagnostics` start fresh every session. The standalone Come & Get It kept its settings in its own `ComeAndGetItDB`, which Tracking Eye never reads.

Defaults come from `ns.DATABASE_DEFAULTS` and are applied by AceDB-3.0 when a scope is first accessed, and explicit user values, including `false`, are never overridden. Note that scalar and table defaults are physically copied into the saved table (`copyDefaults` via `rawset`); only `*`/`**` wildcard defaults resolve through metatables. This add-on defines no wildcard defaults.

There are no seeded lists and no refill-on-empty logic. `farmCycleSpells` is a settings map whose defaults are the flavor data's `ns.FARM_CYCLE_DEFAULTS`, handed to AceDB as they are: at every load AceDB fills in any default key missing from a character's map, so **a spell added to `ns.FARM_CYCLE_DEFAULTS` switches on for every existing character that never saved a choice for it**, and one removed from it switches off for them. Only an explicit `false`, which the option writes when the player unticks an ability, survives either change; say so in the release notes. The same explicit `false` is what lets a player who unticks everything keep that across logins. Two keys have no default on purpose: `selectedSpellId`, whose nil means nothing picked and can't be stored as a default, and `freePos`, which is written by a drag, or at logout while the free frame is shown.

There is no migration chain and no migration code. A change to the shape, name, or scope of saved data ships with its own migration for the data players already have, tagged `MIGRATION (remove after YYYY-MM-DD)` 30 days past the release that ships it (Style Guide → SAVED VARIABLES → Migration Windows).

### Profile Apply

`ns:ApplyProfile` (`Features/Core.lua`) is registered by name against all three AceDB profile callbacks (`OnProfileChanged`, `OnProfileCopied`, `OnProfileReset`) and is the single settings-apply path. Values read live from the database update themselves; everything applied imperatively is repeated here: the memoized player states, the farm cache and ticker interval, the placement, the free frame's scale and shape, and the Blizzard tracking-button takeover. It also ends a running hunt, bringing the new profile's Persistent Tracking Ability back, and finishes with `ns.RefreshOptionsPanels()`, so an options panel already on screen redraws instead of showing the profile the player just left.

Reset is entirely stock: the AceDBOptions Reset Profile control on the Profiles panel resets the active profile only. The General panel carries no reset control, and there is no account-wide wipe.

## Adding a New Tracking Spell

1. Add a `{ spellId, key, source }` row to `ns.TRACKING_SPELLS` in the `Spells-{Game}.lua` of every flavor folder whose client has the spell, and extend the SQL block above the table so it stays regenerable. Report which folders got the row and which didn't (Style Guide → DATA → Flavor Folders). The loops at the top of `Features/Utilities.lua` derive `ns.SPELLS`, `ns.TRACKING_IDS`, `ns.TRACKING_SET`, and `ns.TRACKING_SOURCE`; a form key in `FORM_KEYS` stays out of the tracking sets.
2. If the spell should be on by default in Farm Mode, add `[spellId] = true` to `ns.FARM_CYCLE_DEFAULTS` in the same files. It switches on for existing characters too, except those that unticked it (see *Saved Variables*), so the release notes say so.
3. If it tracks a creature type, add its key to that type's `ns.CREATURE_TYPE_DATA` row in the same files, in preference order, or add a row for a new creature type ID.
4. If it can be cast only in Cat Form, add its key to the `ns.CAT_FORM_ONLY` list in `Features/Utilities.lua`; every Cat Form gate reads that set, and it stays out of `ns.CREATURE_TYPE_DATA`. Any other form gate needs its own guard in `ns.CastTracking` and in `BuildCycleCache`'s `CanCycle`, and if the gate can change mid-farm, `EnsureCycleCache` has to notice, as it does for Cat Form.
5. The source field picks its group in the Farm Mode Abilities list: the class `ns.FARM_ABILITY_CLASSES` (`Data/Data.lua`) maps it to, or Professions & Racial Abilities for anything else. A new class needs a row there; `ns.CLASS_COLORS` already covers every class through Wrath.
6. No locale strings are needed: the name and icon come from `C_Spell` at runtime.
7. Run the Spells section of Validate Data on each client that got the row, and check the Tracking Menu hides the spell on a character that doesn't know it while the Farm Mode Abilities list shows it on every character.

## Adding a New Farm Mode Condition

A new movement state touches every layer, and a state missing from any one of them misbehaves quietly.

1. `Data/Data.lua`: add the state to `ns.MOVEMENT_STATE_TOGGLES` (state to profile key), `ns.MOVEMENT_STATE_CLASS` (its owning class), and `ns.CLASS_STATE_ORDER` (where the on-foot reason considers it).
2. Every flavor folder's `ns.MOVEMENT_BUFF_SPELLS`: a `{ spellId, movementState }` row for each buff that means the state, in the folders whose client has it. A folder without one leaves the state undetectable there, and its toggle and reasons hide.
3. `Features/Utilities.lua`: build the state's buff set from those rows, add it to `MOVEMENT_STATE_BUFFS`, check it in `ScanMovementBuffs` (including the last-scan values that stand in while auras are secret), and slot it into `ComputePlayerStates`' ordered checks.
4. `Data/Default-Settings.lua`: the toggle's default, in `profile`.
5. `Features/Farm-Pause-Reporting.lua`: its `FOOT_REASONS` entries, one for the state and one for mounted-or-the-state, and its `STATE_OFF_REASONS` entry.
6. `Locales/enUS.lua`: the three pause reasons (`FARM_PAUSED_NOT_*`, `FARM_PAUSED_NOT_MOUNTED_*`, `FARM_PAUSED_*_OFF`), each a whole sentence, and the option's label and tooltip.
7. `Options/Options-Farm-Mode.lua`: a `ConditionToggle` that passes the state, so it hides where the flavor can't detect it.
8. `Features/Diagnostics.lua`: the toggle and the live buff in the Farm Mode Context report.

## Adding a New Farm Mode Pause Reason

1. Add the locale key to `Locales/enUS.lua` beside the other `FARM_PAUSED_*` strings, as one complete sentence. **Never assemble a reason from fragments at runtime.**
2. Return it from `ns.GetFarmPauseReason()` in `Features/Farm-Pause-Reporting.lua`, placed in the chain by priority. A condition that clears on its own within seconds goes below the `isFarming` check with the other transient reasons, and above the own-tooltip reason, which stays last.
3. If the condition should also stop the cycle, add the matching hold to `ns.RunFarmLogic()` or the condition to `ns.CanCast()`. Reporting a reason and stopping the cycle are separate decisions: a `ns.CanCast()` condition stops every automatic cast and the binding, while a `RunFarmLogic` hold leaves the binding and the persistent recast alone.
4. Make sure the key name has never been used before (see *Localization*).

## Adding a New Setting

1. Add the key and its default to `ns.DATABASE_DEFAULTS` in `Data/Default-Settings.lua`: `profile` for anything that rides with a per-character feature, `global` for presentation and for anything whose effect lands in something every character shares (Style Guide → SAVED VARIABLES → The Two Models).
2. Add the widget to the builder of the panel that owns it, reading and writing `ns.db` directly. A control that only means something while a toggle is on goes in an `ns.OptionsSubRow` with `hidden` on the row. It carries a label and one tooltip `desc`, with no second description line under it (Style Guide → OPTIONS PANEL → Helper Text Lives in the Tooltip).
3. If the setting is applied imperatively (a frame, a timer, a hook), repeat it in `ns:ApplyProfile`, or a profile switch leaves it stale until a `/reload`.
4. If it changes what Farm Mode cycles, call `ns.InvalidateFarmCache()` in its `set`; if it changes what Persistent Tracking keeps up, call `ns.TryRecastPersistent()` as well, as the three Persistent Tracking sub-options do.
5. Add its strings to `Locales/enUS.lua` only.
6. A change to an existing key's shape, name, or scope ships with its own migration (see *Saved Variables*).

## Adding a New Registered Event

1. Add the event name to `ns.EVENT_NAMES` in `Features/Core.lua`. The dispatcher registers from it and the Diagnostics Event Registration check validates against it, so both pick the event up together.
2. If the event is unit-filtered, add it to `UNIT_FILTERED_EVENTS` in the same file, so it registers through `RegisterUnitEvent` instead of waking the dispatcher for every unit.
3. Add a branch to the `OnEvent` handler that calls into the owning feature through `ns`, guarded if the feature could be left out of a flavor's TOC. `ADDON_LOADED` and `PLAYER_LOGIN` stay first.
4. Never register an event on a second frame: it would escape the event-log tap.
5. Run Event Registration on every flavor. Registering an event a client lacks throws (Style Guide → COMPATIBILITY).
6. A firehose that is never signal goes in `ns.DIAGNOSTIC_EVENT_EXCLUDE`; one that is sometimes signal and carries a message ID goes in `ns.MESSAGE_ID_FILTERED_EVENTS` instead.

## Adding a Come & Get It Node Type

1. **Identify the trigger** with `/etrace`. If the client raises an error unique to that node type, add its GlobalStrings name as a constant in `Data/Data.lua` beside `ns.ERROR_STRING_LOCKED_CHEST`; never key on the numeric index. If it raises only the shared `Requires <Skill>` error, match the localized skill name instead.
2. **Add a mapping entry** in `Features/Come-and-Get-It.lua`: in `ERROR_STRING_MAPPING` keyed by the error name, or in `SKILL_MAPPING` keyed by `L["MATCH_*"]`. Either way the entry carries a `formatKey` naming its `MSG_FORMAT_*` body. Keep the two tables separate.
3. **Add the locale keys** to `Locales/enUS.lua`: the `MSG_FORMAT_*` body, with four `%s` in the fixed order and nothing attached before the node name, and the `MATCH_*` skill name if the match is by substring.
4. **Show it in Diagnostics.** Add the new constant or match string to the Come & Get It Context report.
5. **Check the length.** The composed line is a chat message the player sends: 255 bytes (`ns.CHAT_MESSAGE_MAX_LENGTH`), measured in bytes against the widest-encoding locale (Style Guide → MESSAGES → Message Length).

## Adding an Output Channel

1. Add one row to `ns.OUTPUT_CHANNELS` in `Data/Data.lua`. The `key` is saved to the database, so pick it once and never rename it.
2. Add its `OPTIONS_OUTPUT_*` label to `Locales/enUS.lua`.

The feature and the dropdown pick the row up on their own.

## Adding a Data Table

1. Declare the table whole in the same-named file of all seven `Data/{Game}/` folders, empty (`= {}`) where a flavor has no rows, with its column-header comment and a source block naming where the rows came from. The `Data/Vanilla/` and `Data/Discovery/` copies keep their opposite `ns.IS_DISCOVERY` guards.
2. A new file goes into every TOC's data block, between `Data/Data.lua` and `Data/Default-Settings.lua`; the Vanilla TOC lists the Vanilla file and then the Discovery file.
3. Add the table to `ns.DIAGNOSTIC_DATA_SOURCES` in `Features/Diagnostics.lua`, with its kind and how to reach each row's ID; a new file gets its own entry, and the panel builds its Validate Data section from that alone.
4. Run Validate Data on every client with a TOC.

## Localization

Player-visible strings live in `Locales/`, one AceLocale-3.0 file per supported locale, all eleven already present, so localization is **maintenance, not expansion**; there is no "add a new locale" step.

- **`enUS.lua` is the source of truth** and the only file that passes the `true` default-fallback flag to `NewLocale("TrackingEye", ...)`; `Data/Data.lua` acquires the handle once with `GetLocale(ADDON_NAME)`. Every other locale translates its key set, and the Localization pass (`3 - Copy Cleanup & Localization Prompt.md`) owns those files: never hand-edit them during ordinary work. A reworded `enUS` string reads as the old translation elsewhere until that pass runs, which is expected. A retired key name is never reused, because its stale translations stay behind and would silently win over the English fallback.
- **Placeholders.** `%s` and `%d` count, type, and order must match `enUS` per key in every locale, or the string crashes at runtime. The keys that carry them: `CHAT_LOADED` and `OPTIONS_VERSION` (the version), `OPTIONS_CYCLE_EVERY` (the formatted interval), the three `MSG_FORMAT_*` bodies (four `%s` in a fixed order: node name, x, y, zone, explained for translators in `enUS.lua`), and `CHAT_TOO_LONG`, whose two `%d` are the silent case: swapped, they don't crash, they report the draft's size and the limit backwards.
- **`MATCH_*` is not display copy.** The two skill names must equal what the client itself prints in that language, since they are substring-matched against its error text; where a language's clients disagree, the string lists every name, separated by semicolons. A stylized translation silently stops herb and ore detection in that locale while chests keep working.
- **Keys reached indirectly.** The `MSG_FORMAT_*` bodies resolve through `mapping.formatKey`, the `OPTIONS_OUTPUT_*` labels through `channel.labelKey`, every `FARM_PAUSED_*` reason through the key `ns.GetFarmPauseReason()` returns, and the three empty-cycle binding lines through `EMPTY_CYCLE_MESSAGES` (`Features/Key-Bindings.lua`). A search for `L["` reports them as unused; they aren't.
- **Not localized:** `ns.DiagnosticsStrings`, the `ns.OPTIONS_REGISTRY` names, and the `category` attribute in `Bindings.xml`. Automatic Target Tracking needs no keys of its own, since it matches creature type IDs.

Everything else, including the Spanish file pairing, the overflow canary, and the output ceilings, is per Style Guide → LOCALIZATION and MESSAGES → Message Length.

## Common Pitfalls

- **Trusting the tracking mirror as live state**: on Classic Era the mirror lags reality, sometimes by minutes, and nil doubles as "nothing tracked", so comparing against it, or bailing on nil, silently disables Farm Mode and Persistent Tracking there. Compare against `lastCastSpell`, treat the mirror as a positive signal only, and leave the login case to the time-based grace window.
- **Adding a second reader of tracking state**: everything funnels through `ns.GetActiveTrackingSpell()`. Reading `MiniMapTrackingIcon`, `GetTrackingTexture()`, or `C_Minimap` anywhere else resurrects cleared icons and re-poisons `lastCastSpell` through the adopt branch.
- **Recording a cast before the game confirms it**: `ns.CastTracking` must never write `lastCastSpell`. A silent failure (line of sight, range, a server reject) recorded as a success suppresses the retry that would have fixed it. Record only through `ns.SetLastCast`, on evidence the spell is up.
- **Persisting `lastCastSpell`**: last session's value makes every caller believe tracking is already up at login and skip every real cast. It lives in `ns.state` and never in `ns.db`.
- **Swallowing a temporary bail in `TryRecastPersistent`**: the in-flight, all-clear, cooldown, and debounce bails reschedule, and standing still parks. On Era no further tracking event may fire, so a dropped trigger stops Persistent Tracking until the next login.
- **Casting in the shapeshift GCD**: the 1.5-second `ns.ScheduleEventRecast` delay after `UPDATE_SHAPESHIFT_FORM` lets the form's global cooldown expire. Without it the cast fails silently.
- **Clearing tracking with `ClearAllTracking`**: it also clears Blizzard's own quest and target filters. Use `ns.CancelActiveTracking()`, which switches off only entries backed by the add-on's spells.
- **Reading a secret value on WoW Forever**: a bare aura read in combat throws there, and a secret cooldown, cast, identity, or speed can't be compared. Go through the accessors in `Features/Utilities.lua`, which ask `C_Secrets` first.
- **Testing the texture cache for completeness**: an ID the client lacks never resolves, so a completeness test rebuilds the whole map on every miss. `ns.InvalidateTextureCache()` is the only rebuild trigger.
- **Adding a movement state to only some of its tables**: detection and the toggle can work while the on-foot reason never names it, so a player whose only state it is reads "Not mounted." Follow *Adding a New Farm Mode Condition* end to end.
- **Letting the druid's Cat Form tracking run outside Cat Form, or into the creature-type map**: every cycle step it took would be a cast that always fails, and a hunt could land on it. Keep the `CanCycle` gate, the Cat Form check in `EnsureCycleCache`, and its absence from `ns.CREATURE_TYPE_DATA`.
- **Assembling a pause reason from fragments**: a comma-spliced sentence can't be translated. Every combination is its own precomposed key.
- **Ranking the own-tooltip pause reason anywhere but last**: hovering the button is how the player reads the Farm Mode Status, so an earlier rank makes it read "Reading a tooltip." in place of the real cause. Keep `ns.IsTooltipShowing()` to everyone else's tooltips.
- **Caching the options-open state, or reading it with `IsShown()`**: closing the Settings window hides the window, not the canvas, so either one sticks at true and pauses Farm Mode until a reload. `ns.IsOptionsPanelOpen()` reads `IsVisible()` live.
- **Arming the cycle mute before the cast**: `ns.CastTracking` returns `false` on every early bail, and muting for a cast that never happened switches the player's sound off for nothing. Cast first, arm second.
- **Relying on the mute's timer to restore `Sound_EnableSFX`**: the CVar survives the session and the timer doesn't. Keep the unconditional restores on `PLAYER_LOGOUT` and on switching the option off, and keep the `pcall` around the cast.
- **Naming the free-placement frame**: it brings back the `layout-local.txt` lookup, and a cached per-character position silently overrides `ns.db.global.freePos`. Keep the constructor's name argument `nil`.
- **Serializing the free frame with `GetPoint()`, or saving it from a frame never re-anchored**: after a drag the frame sits on a non-canonical anchor, and a frame that was never re-anchored carries offsets from a different scale; either writes a drifted, account-wide `freePos`. Round-trip through `SaveFreePosition` and `ApplyFreePosition`, keep `SetUserPlaced(false)` on every apply, keep the `IsShown()` guard on the logout save, and never add an unconditional caller of `SaveFreePosition`.
- **Letting Automatic Target Tracking write `selectedSpellId`**: a passing target would overwrite the pick, and the login catch-up would bring it back even in town. The hunt stays in `ns.state`, read through the resolver.
- **Queueing a hunt switch or a Come & Get It draft for later**: a target picked in combat or outside the world, and a draft refused in combat, are dropped. Replayed, they would arrive minutes late from a fight that is long over, and the draft would steal keyboard focus as the fight ends.
- **Keying herb or mine on the error ID, or merging Come & Get It's two mapping tables**: both node types share one error, whose number isn't stable across clients anyway, and a merged table would test `ERR_ITEM_LOCKED` against message text. The skill-name scan is the only thing that separates herb from mine.
- **Making `ns.MatchError` file-local**: the Diagnostics noise filter classifies with it. Without it every red error logs in full, and combat spam floods the 500-entry buffer.
- **Loosening Come & Get It's compose guards**: `C_Map.GetPlayerMapPosition` returns a valid vector reading exactly `0, 0` where the map can't place the player; `GameTooltipTextLeft1` keeps its last text after the tooltip hides; and a locked lockbox in the bags raises the same error as a world chest. Keep the zero check, the `IsShown()` read, and the bag-item gate, or drafts point at the map origin, name the wrong node, or call out inventory.
- **Trimming an over-long draft, or measuring it with the command attached**: a byte-wise cut splits multi-byte characters, and the client strips `/1 ` before sending. Warn, leave the text whole, and measure the line alone.
- **Renaming an output channel key**: the key is what is saved, so a rename silently sends existing players back to Local.
- **Storing `nil` to untick a `farmCycleSpells` entry**: AceDB re-adds a default-`true` key on the next login, so an unticked Find Herbs or Find Minerals would come back. The toggle writes an explicit `false`.
- **Expecting a new `ns.FARM_CYCLE_DEFAULTS` entry to reach only new characters**: AceDB fills it into every existing map that never saved that key, and removing one takes it away the same way. Say so in the release notes.
- **Reading `ns.db` before `ADDON_LOADED`**: AceDB creates it in Core's `ADDON_LOADED` handler, so a file-scope read sees nil. Every access is guarded and happens from runtime handlers.
- **Adding an imperatively applied setting without adding it to `ns:ApplyProfile`**: it stays stale after a profile switch until a `/reload`.
- **Opening the options panel by name**: AceConfigDialog aliases a category's ID to its display name only on a client without `C_SettingsUtil.OpenSettingsPanel`, so a name lookup works on Classic Era but returns nil on TBC Anniversary and drops the panel into a floating window. Route by the category ID captured from `AddToBlizOptions`.
- **Mutating the table `ns.BuildProfilesOptions()` returns**: AceDBOptions-3.0 hands every database the same table, so a change leaks into every other Ace3 add-on's Profiles panel. Return it unmodified.
- **Reusing a retired locale key name**: its old translations stay in the other ten files, and AceLocale falls back to English only for keys a locale doesn't define. Search every locale file for a new key name before using it.
- **Adding an unsuffixed `TrackingEye.toc`**: a client with no TOC of its own suffix falls back to it and would load the add-on under whatever `X-Flavor` it names. One suffixed TOC per flavor and nothing else.
- **Listing `Bindings.xml` in a TOC**: the UI parser rejects the file and the binding never appears. The client loads it from the root on its own.
- **Adding a GitHub token to `package.yml`**: given `GITHUB_OAUTH` or `GITHUB_API_TOKEN`, the packager rewrites the GitHub release's name and body from commit messages on every build, replacing the hand-written release notes. The workflow deliberately carries neither.
- **Renaming *Restricted Zones* in this document**: `Features/Core.lua` cites that section by name.

## Contributing

- **Issues:** open them at [github.com/Gogo1951/Tracking-Eye/issues](https://github.com/Gogo1951/Tracking-Eye/issues).
- **Bug reports:** include the game version (Classic Era 1.15.x, with or without Season of Discovery, TBC Anniversary 2.5.x, WoW Forever 1.60.x, MoP Classic 5.5.x, or Retail 12.x) and client locale, the character's class and level, exact reproduction steps, and any chat output: a Come & Get It draft, a key-binding message, or an error. The Diagnostic Tools panel (`/te`, then Diagnostic Tools) produces copy-paste reports that carry most of this; Farm Mode Context and Player & Spell Context answer most reports on their own.
- **Discord:** [discord.gg/eh8hKq992Q](https://discord.gg/eh8hKq992Q) for discussion, screenshots, and quick questions.
- **Pull requests:**
    - Keep scope tight: one feature or fix per PR.
    - Run StyLua with its default configuration and `--syntax lua51` over every Lua file you touched outside `Includes/`, and a clean `luacheck .` alongside `luac -p`. There is no `.stylua.toml`; the formatter owns whitespace.
    - Put every player-visible string in `Locales/enUS.lua` (Diagnostics strings are the English-only exception), and comment only what the code can't say for itself; the durable why belongs here.
    - Read *Reading and Clearing Tracking*, *Decide → Cast → Confirm*, and *Persistent Tracking* before touching those paths.
    - Migration discipline: a change to the shape, name, or scope of saved data ships with its own 30-day migration, tagged `MIGRATION (remove after YYYY-MM-DD)` (Style Guide → SAVED VARIABLES → Migration Windows). A new or removed `ns.FARM_CYCLE_DEFAULTS` entry reaches existing characters; the release notes say so.
    - Output length: Tracking Eye writes no macros and sends no chat itself. The Come & Get It `MSG_FORMAT_*` bodies are its one chat line, sent by the player, so a change to them is checked against 255 bytes in the widest-encoding locale (Style Guide → MESSAGES → Message Length), with the four `%s` kept in order.
    - Run `lua tools/Test-Event-Log-Noise.lua` after touching Come & Get It's matcher or the event log, and `README-Testing.md` on each flavor before a release.
    - When the architecture or file map changes, update this document in the same PR.
- **Commit and PR descriptions require a User Story.** Don't just say "I changed X" or "I fixed Y." Frame the change in terms of who it helps and why:

    **Format:** *As a [role], I [needed / wanted] [behavior] so that [outcome]. This change [does X].*

    **Example:** *As a druid who shifts between Travel Form and caster form on a farming run, I wanted Tracking Eye to recast my tracking after the shift instead of leaving me with none. This change schedules a Persistent Tracking recast 1.5 seconds after `UPDATE_SHAPESHIFT_FORM`, so the form's global cooldown has passed before the cast fires.*
