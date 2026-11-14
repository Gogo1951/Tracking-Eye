# Tracking Eye // Notes

> Where Tracking Eye departs from the Gogo1951 add-on Style Guide, kept so no review raises it again.

## Exceptions

### Legacy tracking reads

- **Departs from:** COMPATIBILITY → call a namespaced API directly, with no legacy fallback.
- **Instead:** Reads and clears tracking through the legacy tracking calls and Blizzard's mini-map tracking icon on any client that still ships them, and through C_Minimap's tracking list only on a client that doesn't.
- **Why:** Classic Era ships C_Minimap's tracking calls but reports an empty tracking list, so C_Minimap alone can neither see nor clear tracking there.

### Default Output note

- **Departs from:** OPTIONS PANEL → Helper Text Lives in the Tooltip → never add a second description line under a control.
- **Instead:** Come & Get It's Default Output carries a one-line note beneath the dropdown: Local (/1) only reaches players on your layer. Its tooltip carries a different tip, so the two never repeat each other.
- **Why:** The layer limit decides whether a callout reaches anyone at all, so players have to see it before they pick a channel, not find it by hovering.

### Two History lead lines

- **Departs from:** `09 - Optional Create README.md` → Appreciation & History, "Pick the one lead line that is true."
- **Instead:** The README's History carries both lead lines: the takeover line over LindenRyuujin's Tracking Eye, and the shoulders line over Come & Get It.
- **Why:** Both are true of this add-on: Gogo1951 took it over from its original author and later rolled another Gogo1951 add-on into it.

### Menu screenshot under the TL;DR

- **Departs from:** `09 - Optional Create README.md` → Image Handling, "Images live in the feature blocks, one per block, and nowhere else."
- **Instead:** The README carries a screenshot of the mini-map menu directly under the TL;DR, ahead of the feature blocks.
- **Why:** The menu is where every feature is switched, so players see it before they read about any one feature.

### Free Placement Mode opens options

- **Departs from:** MINIMAP MENU → Features Mirror, every More Features row a compact `toggle` that switches its feature.
- **Instead:** Free Placement Mode's More Features row shows On or Off, but a click opens its options panel rather than switching it.
- **Why:** Turning it on is only the start: the player drags the icon into place and picks its shape and size, all of which they do in options.

### Typed herb and ore match words

- **Departs from:** GAME NAMES → a value that is itself the name of a skill doesn't belong in `Locales/`.
- **Instead:** Come & Get It tells an herb from an ore node by finding the skill word the game's "Requires" error shows, typed into every locale file.
- **Why:** No client API returns the words that error shows, so they can't be looked up by ID.
