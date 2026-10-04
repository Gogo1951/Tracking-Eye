# Tracking Eye // Notes

> The maintainer's settled rulings for Tracking Eye, kept so no review raises them again: exceptions to the Gogo1951 add-on Style Guide, and decisions it leaves open.

## Exceptions

### Legacy tracking reads

- **Departs from:** COMPATIBILITY → call a namespaced API directly, with no legacy fallback.
- **Instead:** Reads and clears tracking through the legacy tracking calls and Blizzard's mini-map tracking icon on any client that still ships them, and through C_Minimap's tracking list only on a client that doesn't.
- **Why:** Classic Era ships C_Minimap's tracking calls but reports an empty tracking list, so C_Minimap alone can neither see nor clear tracking there.

### Every option for every class

- **Departs from:** OPTIONS PANEL → Widget Conventions → only show spells the player knows.
- **Instead:** The options offer every setting a profile holds on every character, tracking spells it hasn't learned and other classes' settings included.
- **Why:** A profile can be shared by characters of different classes, so every setting it holds has to be reachable from any of them.

### Default Output note

- **Departs from:** OPTIONS PANEL → Helper Text Lives in the Tooltip → never add a second description line under a control.
- **Instead:** Come & Get It's Default Output carries a one-line note beneath the dropdown: Local (/1) only reaches players on your layer. Its tooltip carries a different tip, so the two never repeat each other.
- **Why:** The layer limit decides whether a callout reaches anyone at all, so players have to see it before they pick a channel, not find it by hovering.

### Two History lead lines

- **Departs from:** Optional - ReadMe File Prompt → Appreciation & History → pick the one lead line that is true.
- **Instead:** The README's History carries both lead lines: the takeover line over LindenRyuujin's Tracking Eye, and the shoulders line over Come & Get It.
- **Why:** Both are true of this add-on: Gogo1951 took it over from its original author and later rolled another Gogo1951 add-on into it.

### Feature switches with their features

- **Departs from:** OPTIONS PANEL → Main Page Layout → Features, every feature's on/off switch two to a line.
- **Instead:** Each feature's Enable toggle heads that feature's own section or options page, and the feature's other settings hide while it is off.
- **Why:** A feature's settings mean nothing while it is off, so its switch sits with them and its section collapses to that one toggle.

### Game names in prose copy

- **Departs from:** GAME NAMES → a string that names a spell, item, skill, zone, class or Blizzard UI label doesn't belong in `Locales/`.
- **Instead:** The tagline's Find Herbs and Find Minerals and Come & Get It's mentions of Rogues are translated as copy in every locale.
- **Why:** The tagline must read the same as the TOC Notes and the listings, and a greeting addressed to a group of players isn't a lookup of a game record.

## Decisions

- The post-resurrection tracking recast waits 1.5 seconds (`C_Timer.After`) before casting, by the maintainer's choice.
- Every automatic tracking cast, the form-leave restore and the post-resurrection recast included, waits for the same all-clear (alive, not stealthed, out of combat, and not casting, channeling, looting, or holding anything on the cursor) and retries until it gets it, so it never costs a global cooldown mid-fight or disturbs what the player is doing.
- A fight that starts while mounted pauses Farm Mode as combat, like any other fight, and the tooltip reports combat.
- The icon never dims while Farm Mode is paused: on foot is itself a pause by default, so a dimmed icon made the whole add-on look switched off. The tooltip's Farm Mode Status is the only place a pause shows.
- An Automatic Target Tracking hunt takes the Persistent Tracking Ability's entry in Farm Mode's rotation, under the existing Include Persistent Tracking Ability toggle; with that toggle off, the hunt stays out of the rotation and the form-leave restore brings it back.
- Only targets picked out of combat start or switch a hunt, and nothing picked mid-fight is queued for after the fight.
- Only creatures drive a hunt: enemy players and dead targets never switch it, so looting an add's corpse keeps the hunt.
- A hunt has no fade timer; it ends only at a context break (a town, an inn, an instance, a flight, a Tracking Menu pick, Clear Tracking, switching the feature off, or a profile change).
- A hunt switch casts immediately, costing one global cooldown per new creature kind rather than per pull.
- Come & Get It ships inside Tracking Eye as its own options page directly beneath Farm Mode, switched on by default, without the standalone add-on's `/cgi` command.
- The Farm Mode Abilities list is grouped in bordered blocks, as in Control Freak: Professions & Racial Abilities, then Druid, Hunter, Warlock, and Paladin. Druid Track Humanoids is listed under Druid beside the hunter's own and cycles only while the druid is in Cat Form.
- Aspect of the Pack is a Farm Mode condition of its own, off by default, separate from Aspect of the Cheetah.
- Farm Mode Conditions, and the pause reasons that name them, leave out any movement state the flavor's data has no buff for, as Retail has none for Aspect of the Cheetah or Aspect of the Pack.
- The mini-map tooltip runs Tracking Menu, Persistent Tracking Ability, Farm Mode, Farm Mode Status, Automatic Target Tracking, then options. Persistent Tracking is options-only (on by default). Shift + Left-Click toggles Farm Mode and Shift + Right-Click toggles Automatic Target Tracking. The Automatic Target Tracking block doesn't name a running hunt's ability; the icon already shows it.
- Use the Default Tracking Button is offered only on Classic Era, where Blizzard's tracking icon has no menu of its own. On TBC Anniversary and MoP Classic, Blizzard's button opens its own tracking menu, so it stays Blizzard's.
- Farm Mode cycles, and Persistent Tracking brings its ability back, only while the player is moving, with no option to turn that off: standing still is when a player eats, drinks, gathers, or reads. Target Tracking's switch isn't covered and casts at once.
- Farm Mode, the form-leave restore included, holds while a living target the player can attack is selected, and while any tooltip shows, Tracking Eye's own included. Targeting yourself, a party member, a friendly NPC, or a corpse doesn't hold it. The Farm Mode Status names its own tooltip only when nothing else is holding the cycle.
- Persistent Tracking's sub-options are labeled by the event that triggers them and run in this order: Find Fish when you Equip a Fishing Pole, Druid: Track Humanoids when you Shift into Cat Form, then Hunter: Track Humanoids in Battlegrounds.
- Find Fish when you Equip a Fishing Pole is on by default and shown only where the flavor's data has Find Fish: with a fishing pole in the main hand it makes Find Fish the Persistent Tracking Ability, and the player's own pick comes back when the pole comes off. Find Fish is off by default in the Farm Mode Abilities list, since this option brings it up while fishing.
- Druid: Track Humanoids when you Shift into Cat Form is off by default: in Cat Form it makes Druid Track Humanoids the Persistent Tracking Ability, and the player's own pick comes back when they shift out.
- Hunter: Track Humanoids in Battlegrounds is off by default: in a battleground or an arena it makes Track Humanoids the Persistent Tracking Ability, and the player's own pick comes back outside.
- Zoom Mini-map Out is a Farm Mode sub-option, on by default: it zooms the mini-map all the way out when a Farm Mode run starts and never puts the player's zoom back, by the maintainer's choice.
- The README's Features are the four main features: Tracking Menu & Persistent Tracking, Farm Mode, Automatic Target Tracking, and Come & Get It, then a fifth Highly Configurable bullet, which the maintainer wants kept. Free Placement Mode is covered under How It Works instead.
- Declined: treating a tracking spell cast outside the Tracking Menu (an action bar, the spellbook, a macro, or WoW Forever's own tracking menu) as a new pick. The Tracking Menu stays the only way to change the pick.
- Declined: ticking Farm Mode Abilities from the Tracking Menu. The menu only picks the Persistent Tracking Ability; Farm Mode Abilities are set on the Farm Mode page.
- Declined: key bindings for Toggle Farm Mode, Toggle Automatic Target Tracking, and Open Tracking Menu. The mini-map button's clicks already do all three.
- Declined: a starting pick for a character that has never used the Tracking Menu. Persistent Tracking keeps nothing up until the player picks, so Clear Tracking stays a plain clear.
- Declined: counting the herbs and ore gathered each session. That's farming stats, not tracking, and the mini-map tooltip stays bare-bones.
- Declined: holding automatic casts while the player eats or drinks. Target Tracking's switch casts the moment a new kind of creature is targeted, even mid-meal.
- Declined: an Eagle Eye Farm Mode condition. Casting a tracking spell ends the Eagle Eye channel, so the cycle can't run while a hunter scouts.
