# Tracking Eye // Notes

> Where Tracking Eye departs from the Gogo1951 add-on Style Guide, kept so no review raises it again.

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

- **Departs from:** `09 - Optional Create README.md` → Appreciation & History, "Pick the one lead line that is true."
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

### Typed herb and ore match words

- **Departs from:** GAME NAMES → a value that is itself the name of a skill doesn't belong in `Locales/`.
- **Instead:** Come & Get It tells an herb from an ore node by finding the skill word the game's "Requires" error shows, typed into every locale file.
- **Why:** No client API returns the words that error shows, so they can't be looked up by ID.
