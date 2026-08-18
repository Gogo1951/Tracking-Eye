# Tracking Eye — Manual Test Plan

This is the manual test plan for Tracking Eye — the steps to confirm it works before a release is tagged. For what it does, see [README.md](https://github.com/Gogo1951/Tracking-Eye/blob/main/README.md); for how it works, see [README-Technical.md](https://github.com/Gogo1951/Tracking-Eye/blob/main/README-Technical.md).

## How to run this plan

Run the whole list on each flavor the add-on ships, in TOC order: Classic Era first, then TBC Anniversary. Do a `/reload` before starting each flavor.

Work top to bottom. Every step tells you exactly what to do, what you should see, and what failure looks like — if a step doesn't match its expected result, it failed. Steps are numbered continuously from 1 to 108 across the whole document, so a bug report only needs "failed on step N."

Some steps behave differently on the two clients and say so in the step itself. Those are not optional on either flavor — the client a step warns about is precisely the one where that step earns its keep. **A run on only one flavor is not a completed run.**

A few steps need a particular class or profession. Where one does, the step names it. Run every class path you can reach and record the ones you couldn't in the sign-off grid.

## Before you start

Gather these once so you aren't caught short mid-run:

- **Both flavors installed** — Classic Era and TBC Anniversary. The add-on ships for both, and both must be tested.
- **A character with Herbalism and Mining.** This is the main test character for most of the plan — Find Herbs and Find Minerals are the two abilities the cycle exists to rotate. A mount, or any movement form, on that character.
- **A Hunter** — for Track Beasts, the Aspect of the Cheetah condition, and Automatic Target Tracking. This is the easiest character for the target-tracking steps.
- **A Druid** — for Cat Form (Track Humanoids appears in the menu only in Cat Form) and the Travel & Flight Forms condition.
- **A Shaman** — for the Ghost Wolf condition. Optional if you have none; note it in the sign-off.
- **A Dwarf of any class** — for Find Treasure, which is now ticked by default. Optional; note it if you skip it.
- **A Warlock or a Paladin** — optional, for the one step that checks Sense Demons and Sense Undead are chosen ahead of the Hunter versions.
- **A character who knows no tracking ability at all** — a Mage, Priest, Rogue, or Warrior with neither gathering profession. Several steps check that the add-on gets out of the way entirely for that character.
- **A second character on the same account and realm**, for the per-character profile steps.
- **An open-world zone with herb nodes and ore veins**, plus a town or inn you can stand in, a dungeon entrance you can zone into, and a flight path you can take. All four are used as Farm Mode pause conditions.
- **Something to fight** — any open-world mob, for the combat steps.
- **Fishing at a level that grants Find Fish** — optional, and only meaningful on TBC Anniversary. That spell does not exist on the Classic Era client at all.
- **A non-English client** — only for the optional localization spot-check in steps 104–108.

Unless a step says otherwise, be **out of combat, out of instances, and outside towns and inns**, standing in the open world.

One note before you start: running from an unpackaged working copy, the version shown in the options panel and the mini-map tooltip reads **Dev**. That is correct and is not a bug to report.

## Verify this release's changes

This release restructures the settings, adds four features, and changes two defaults. These twenty-four steps are the highest-value part of the plan: each one watches a specific change actually work. Run them first, on both flavors.

### Load and upgrade

**1.** Log in with Tracking Eye enabled. No Lua error window may appear, and no red error text may print in chat. Failure is any error popup naming Tracking Eye, or the add-on missing from the AddOns list entirely.

**2.** Log in on a character that already used the previous release. Its Persistent Tracking Ability, its Farm Mode toggles, and its mini-map button position must all be exactly as you left them. Failure is any of those back at install defaults, which means the upgrade lost that character's settings.

**3.** Type `/reload`. The UI must come back with no error window and no red text, the welcome line must print again, and `/te` must still open the settings. Failure is an error on reload or a panel that no longer opens.

### Farm Mode moves to its own page

**4.** Type `/te`, then look at the category list on the left. Four entries must sit under **Tracking Eye**, in this order: the main **Tracking Eye** page, **Farm Mode**, **Profiles**, and **Diagnostic Tools**. Each must open without error. Failure is a missing entry, an entry that opens blank, or Farm Mode still living as a section on the main page.

**5.** Open the **Farm Mode** page and untick **Enable Farm Mode**. Everything below the toggle must vanish, leaving the page as the description, the toggle, and nothing else. Re-tick it and the conditions, the ability list, and the cycle dropdown must all come straight back. Failure is controls staying on screen while Farm Mode is off, or the page needing a reopen to redraw.

### Options Interface refuses to open in combat

**6.** Pull a mob and, while still in combat, type `/te`. The panel must **not** open, and a line must print reading *"Tracking Eye // As a safety precaution, the Options Interface cannot be opened during combat."* Failure is the panel opening, silence with no printed line, or a red `ADDON_ACTION_BLOCKED` error naming Tracking Eye.

**7.** Still in combat, Shift + Middle-Click the mini-map button. The same refusal line must print and the panel must stay shut. Now kill the mob and stand still — the panel must **not** open by itself once combat ends. Failure is the panel appearing on its own seconds later, which means the refusal queued instead of returning.

### Automatic Target Tracking

**8.** On the Hunter, open `/te` and look under **Persistent Tracking**. An indented **Automatic Target Tracking** checkbox must be there, **unticked**, with a silver note beneath it. Now untick **Enable Persistent Tracking** — the checkbox and its note must both disappear. Failure is the box ticked on a fresh profile, or the sub-option staying visible with its parent switched off.

**9.** Re-tick Persistent Tracking, tick **Automatic Target Tracking**, close the panel, and target a hostile beast in the open world. Your tracking must switch to Track Beasts within a second or so, and the mini-map tooltip must show **Track Beasts** as the Persistent Tracking Ability. Failure is nothing happening, or the tooltip still naming your old ability.

**10.** Now target a friendly NPC — a guard, a vendor, any non-attackable unit. Your tracking must **not** change. Then pull a hostile beast and, while still in combat, target something of a different tracked type. Nothing may change mid-fight; the switch must land once the fight ends. Failure is tracking switching off a friendly target, or a tracking cast going off while you're in combat.

### Cycle Farm Mode Ability key binding

**11.** Open the game menu, choose **Key Bindings**, and scroll to the **Tracking Eye** section. One binding must be listed, named **Cycle Farm Mode Ability**. Bind it to a spare key. Failure is no Tracking Eye section at all, or a binding row with a blank or raw-key name.

**12.** With Find Herbs and Find Minerals both ticked in the Farm Mode ability list, stand in the open world out of combat and press that key twice. Your tracking must advance to the next ability in the list on each press, whether or not Farm Mode is switched on. Now untick every ability **and** the **Persistent Tracking Ability** toggle at the top of that list, and press the key again — a line must print reading *"Tracking Eye // No tracking abilities are selected for Farm Mode. Pick some under Options > AddOns > Tracking Eye."* Failure is the key doing nothing with a full list, or staying silent with an empty one.

### Use the Default Tracking Button

**13.** On the main `/te` page, find **Use the Default Tracking Button** beneath the mini-map toggle. It must be **unticked** on a fresh profile. Tick it, then click Blizzard's own tracking icon on the mini-map: the Tracking Eye menu must open, and only that menu — not Blizzard's, and not both. Untick it and click that icon again: Blizzard's own behavior must be back exactly as it was. Failure is two menus opening, a menu that flickers open and shut, or Blizzard's button staying hijacked after you switch the option off. If the toggle is absent, that client has no default tracking button of its own — note it in your results rather than calling it a failure.

### Silence Tracking Sounds

**14.** On the **Farm Mode** page, confirm **Silence Tracking Sounds** is **ticked** on a fresh profile. With your sound on, mount up in the open world and let the cycle run for half a minute: the repeated tracking-cast sound must not play. Now open the tracking menu and pick an ability by hand — that cast **must** be audible. Failure is hearing the cycle, or losing the sound on your own manual cast.

**15.** While the cycle is running and silenced, type `/reload`. When the UI comes back, open the game's Sound options: **Sound Effects must still be enabled**. Failure is sound effects switched off after the reload, which would leave you silent with nothing to connect it to. Then untick **Silence Tracking Sounds** mid-cycle — sound must return immediately, not after a delay.

### Farm Mode status and the dimmed icon

**16.** Hover the mini-map button in the open world while mounted with Farm Mode on. The tooltip must lead with a **Farm Mode Status** row reading **Active** in green. Now ride into a town or inn and hover again: it must read **Paused** in grey with a plain-language reason beneath it — *"In a town or inn."* — and the tracking icon itself must visibly dim. Failure is a status that never changes, a missing reason line, or an icon that stays bright in town.

**17.** Ride back out, tick **Not Mounted** on the Farm Mode page so the cycle runs on foot, then pull a mob. While in combat, hover the button: the status must read **Paused** with *"In combat."* underneath, but the icon must **not** dim. Failure is the icon dimming and undimming through the fight, which reads as a flickering bug.

### Persistent Tracking Ability in the rotation

**18.** On the **Farm Mode** page, the ability list must lead with a **Persistent Tracking Ability** toggle, ticked by default and carrying no spell icon. With Find Herbs set as your Persistent Tracking Ability and Find Herbs **also** ticked in the list below, mount up and watch a few cycles: Find Herbs must come up once per lap, not twice. Untick the toggle and it must drop out of the rotation entirely unless it is ticked in the list. Failure is Find Herbs getting double the airtime of everything else.

### Cycle Every N Seconds

**19.** On the **Farm Mode** page, open the dropdown beside **Enable Farm Mode**. It must list every half-second from **Cycle Every 2.0 Seconds** to **Cycle Every 10 Seconds**, in ascending numeric order. Failure is the list starting with 10, jumping around, or showing bare numbers with no sentence around them.

**20.** Set it to **Cycle Every 2.0 Seconds**, mount up, and count: tracking must change roughly twice as often as it did at the default 3.5. `/reload` and reopen the page — the dropdown must still read 2.0. Failure is the cadence not changing, or the setting reverting across the reload.

### New Farm Mode defaults

**21.** On a Dwarf, on a fresh profile, open the **Farm Mode** ability list: **Find Treasure** must be **ticked**. On a Hunter, on a fresh profile, open the conditions: **Aspect of the Cheetah** must be **unticked** while **Mounted** stays ticked. Failure is either default the other way round. (Use Profiles → Reset Profile to get a fresh profile; see step 88.)

### Farm Mode holds off while you're busy

**22.** Mount up in the open world with the cycle running, then, one at a time: open a merchant or your bank, hover an item in your bags long enough to read its tooltip, open a loot window on a corpse, and pick up an item onto your cursor. In each case the cycle must stop while that is true and resume within a tick of you closing or clearing it. Hover the Tracking Eye icon itself and the cycle must **keep running** — reading our own tooltip is not a pause. Failure is a tracking cast going off underneath an open window, closing your loot window, or dropping what was on your cursor.

### Profile switches apply live

**23.** With the options panel open, go to **Profiles** and switch to a different profile. The main page and the Farm Mode page must immediately show the new profile's values, the mini-map icon must re-place itself if the two profiles differ, and the cycle must pick up the new interval — all **without** a `/reload`. Failure is any page still showing the old profile's values until you click away and back.

### Feedback & Support rows

**24.** Scroll to the bottom of the main `/te` page. **Discord**, **GitHub**, **CurseForge**, and **Wago** must each show their label on the left with a readable URL in a box **beside** it on the same line, all four boxes ending at the same right edge. Click into one, select all, and copy — the copied address must be the full link. Failure is a label stacked above its box, boxes of different widths, an empty box, or a URL cut off at the edge of the field.

When steps 1–24 pass on both flavors, this release's changes are verified — proceed to `4 - Pre-Launch Review Prompt.md` once the rest of the plan passes too.

## Options Interface

**25.** Type `/te`. The settings must appear **docked inside the Blizzard Options window**, with Tracking Eye selected in the category list on the left. Failure looks like either nothing happening at all, or a standalone window floating free of the Options frame. **This step is flavor-sensitive — TBC Anniversary is the client where the panel has historically floated free, so run it there and not just on Era.**

**26.** Close the Options window and Shift + Middle-Click the mini-map button. The same docked panel must open on the Tracking Eye page. Failure is nothing happening, a floating window, or the wrong page being selected.

**27.** Press `Esc`, choose **Options**, then **AddOns**, and select **Tracking Eye** from the list. The panel must open docked, exactly as it did from `/te`. Failure is a missing entry in the AddOns list, or a page that opens blank.

**28.** Read the main page top to bottom. You must see, in order: an intro paragraph, **Enable Welcome Message**, **Enable Mini-map Button**, **Use the Default Tracking Button** with a silver note, a **/Commands** header with `/te` and its description, a **Key Bindings** header naming **Cycle Farm Mode Ability**, a **Persistent Tracking** header with its toggle and the indented Automatic Target Tracking row, a **Free Placement Mode** header with its toggle, **Feedback & Support** with four links, and the version line. Every one must read as a sentence or a label in your language. Failure is a raw key showing through — text like `OPTIONS_ENABLE_WELCOME` or `PLACEMENT_DESC` on screen instead of words — or a blank where a label belongs.

**29.** Untick **Enable Welcome Message**, then type `/reload`. Reopen the panel: the box must still be unticked, and no welcome line may have printed. Failure is the setting reverting, or the message printing anyway.

**30.** Log out fully and log back in on the **same** character. The welcome message must still be suppressed. Re-tick the box, `/reload`, and it must print again. Failure is the setting surviving a reload but not a relog, or the toggle working in only one direction.

**31.** Log in on a **different character on the same account**. **Enable Welcome Message**, **Enable Mini-map Button**, **Use the Default Tracking Button**, and everything under **Free Placement Mode** must match what you set on the first character — these are account-wide by design. Failure is any of them back at defaults on the second character.

**32.** Type junk into one of the Feedback & Support boxes and press Enter, then click to another page and back. The box must show its original URL again. These are display fields you copy from, never fields you edit. Failure is your typed text sticking.

**33.** Open each of the four pages in turn — Tracking Eye, Farm Mode, Profiles, Diagnostic Tools — then `/reload` and open them again. All four must still be present, in the same order, and each must draw its contents. Failure is a page vanishing after a reload, which means it lost its registration.

## Mini-map button

**34.** Look at your mini-map on a character that knows at least one tracking ability. A Tracking Eye button must be there, drawn with the icon of whatever you are currently tracking, or a map icon when you're tracking nothing. Failure is no button at all, or a blank or question-mark texture.

**35.** Hover the button and read the tooltip top to bottom. It must show, in order: **Tracking Eye** with the version on the right; a **Farm Mode Status** block if Farm Mode is on; **Tracking Menu** with a description and *Left-Click / Open*; **Persistent Tracking Ability** with your current ability and icon on the right, and *Right-Click / Clear Tracking*; **Persistent Tracking** with Enabled or Disabled and *Shift + Left-Click / Toggle*; **Farm Mode** with Enabled or Disabled and *Shift + Right-Click / Toggle*; **Silence Tracking Sounds** with its state; and finally **Tracking Eye Options** with *Shift + Middle-Click*. Failure is a missing block, a state that reads the opposite of the panel, or a raw key in place of a name. On a character that can track a creature type, an **Automatic Target Tracking** state row also appears after Persistent Tracking.

**36.** Left-Click the button. The tracking menu must open, anchored beside the button. Failure is nothing happening, or a menu that opens somewhere unrelated.

**37.** With a tracking ability active, Right-Click the button. Tracking must stop, the button's icon must return to the default map icon within a second or two, and the tooltip must now read **None Set** for the Persistent Tracking Ability. Failure is tracking continuing, or the old spell icon staying on the button.

**38.** Shift + Left-Click the button. The tooltip's **Persistent Tracking** row must flip between Enabled and Disabled with each click, updating in place while you hover. Open `/te` and confirm the panel's **Enable Persistent Tracking** box matches. Failure is the tooltip not updating until you move the mouse away, or the panel disagreeing with the tooltip.

**39.** Shift + Right-Click the button. The **Farm Mode** row must flip between Enabled and Disabled the same way, and the Farm Mode page's **Enable Farm Mode** box must match. Failure is the same as above.

**40.** Shift + Middle-Click the button. The options panel must open docked. Failure is nothing happening or a floating window.

**41.** Untick **Enable Mini-map Button** on the main page. The button must disappear immediately. Mount up and confirm from the tracking icon on your mini-map that **Farm Mode keeps cycling** with the button hidden. `/reload` — the button must stay hidden. Re-tick it and it must come straight back. Failure is the button reappearing after a reload, or Farm Mode stopping when the button is hidden.

**42.** Drag the button around the mini-map to a new spot, then `/reload`. It must return to where you left it. Log out and back in — still there. Failure is the button snapping back to its old position.

## Free Placement Mode

**43.** On the main page, tick **Enable Free Placement Mode**. The mini-map button must disappear and a standalone tracking icon must appear in the middle of your screen. **Enable Mini-map Button** must go greyed out while this is on. Failure is both icons showing at once, no icon at all, or the mini-map toggle staying clickable.

**44.** Drag the standalone icon to a corner of your screen, then `/reload`. It must come back in the same place. Log out and back in — still there. Change your interface scale in the game's options and it must hold its screen position rather than drifting. Failure is the icon jumping to the middle of the screen, or sliding after a scale change.

**45.** Two indented sub-options must have appeared under the toggle: **Icon Shape** with a dropdown and **Icon Size** with a slider. Switch the shape between **Circle** and **Square** — the icon's border must change to match immediately. Failure is nothing changing, or both borders drawing at once.

**46.** Drag the **Icon Size** slider from end to end. The standalone icon must grow and shrink live, and must stay where you put it rather than sliding across the screen as it resizes. Failure is the icon drifting as it scales.

**47.** Hover the standalone icon. It must show the same tooltip as the mini-map button. Left-Click it, Right-Click it, and Shift + Left/Right/Middle-Click it: each must do exactly what the same click does on the mini-map button. Failure is any click doing nothing or the wrong thing.

**48.** Untick **Enable Free Placement Mode**. The standalone icon must vanish and the mini-map button must come back — and it must respect whatever **Enable Mini-map Button** was set to before you turned free placement on. Failure is losing both icons, or the mini-map button reappearing when you had it switched off.

**49.** Log in on a different character on the same account. Free Placement Mode, its shape, its size, and the icon's position must all match — this layout is account-wide. Failure is the second character showing its own placement.

## Tracking Menu

**50.** Left-Click the mini-map button. The menu must open with a **Tracking Menu** title at the top, then one row per tracking ability **you actually know**, each with its spell icon and its name, sorted alphabetically. Failure is abilities you don't know appearing in the list, an ability you do know missing, a row with no icon, or an order that isn't alphabetical.

**51.** Click an ability. The menu must close, that ability must be cast, and the mini-map button's icon must change to it. Reopen the menu — that row must now carry a check mark. Failure is nothing being cast, the icon not changing, or no check mark on the ability you picked.

**52.** Hover the mini-map button after picking. The **Persistent Tracking Ability** row must name the ability you just chose. Failure is it still naming the previous one.

**53.** On a Druid **not** in Cat Form, open the menu. **Track Humanoids** must not be listed. Shift into Cat Form and open it again — it must now appear and be castable. Failure is the row showing out of form, where it could not be cast anyway.

**54.** On a character who knows exactly one tracking ability, open the menu: it must show the title and that single row, with no blank rows or stray spacers. Failure is an empty or malformed menu.

**55.** On TBC Anniversary, on a character with Fishing high enough for Find Fish, open the menu: **Find Fish** must be listed. On Classic Era it must **never** appear, on any character — that spell does not exist on that client. Failure is Find Fish missing on Anniversary, or showing up on Era.

## Persistent Tracking

**56.** Confirm **Enable Persistent Tracking** is ticked on a fresh profile. Pick Find Herbs from the tracking menu, then die and run back to your corpse. Within a couple of seconds of resurrecting, Find Herbs must be recast — the herb dots must be back on your mini-map before you've moved. Failure is tracking staying down after the corpse run.

**57.** Die again and take a resurrection in place instead — a healer's rez, a soulstone, or releasing to the graveyard and resurrecting at the spirit healer. Tracking must come back the same way. Failure is the recast only working for corpse runs.

**58.** On a Druid, with tracking up, shift into Bear or Cat Form and back out. Tracking must be recast a second or two after you leave form. Failure is tracking staying down after shapeshifting.

**59.** Untick **Enable Persistent Tracking**, then die and resurrect. Tracking must **not** come back on its own. Failure is a recast happening with the feature switched off.

**60.** With Persistent Tracking on, Right-Click the mini-map button to clear tracking. Tracking must stop and stay stopped — the tooltip must read **None Set**, and nothing may recast it. Failure is the add-on immediately putting tracking back after you asked it to stop.

**61.** With Persistent Tracking on and Farm Mode running while mounted, watch the cycle for a minute. The persistent recast must not fight the cycle — tracking must rotate cleanly rather than snapping back to one ability every few seconds. Dismount, and your Persistent Tracking Ability must be restored within a tick or two. Failure is the cycle stuttering, or your chosen ability not coming back when you get off the mount.

## Automatic Target Tracking

**62.** On the character who knows no tracking ability at all, and again on a pure gatherer who knows only Find Herbs and Find Minerals, open `/te`. **Automatic Target Tracking** must not appear at all — neither character can track a creature type, so the setting would do nothing. Failure is the row showing up where it can never act.

**63.** On the Hunter with the feature on, target a hostile humanoid, then a hostile beast, then a hostile undead if you can find one. Each time, tracking must switch to the matching ability and the mini-map tooltip must name it. Failure is tracking switching to the wrong type, or not switching at all for a type you can track.

**64.** Target a critter or a hostile mob of a type you have no tracker for. Nothing must change — your current tracking must stay exactly as it was. Failure is tracking being cleared or set to something unrelated.

**65.** On a Paladin, target a hostile undead: tracking must switch to **Sense Undead**, not Track Undead. On a Warlock, target a demon: it must switch to **Sense Demons**. Failure is the add-on choosing an ability that class doesn't have.

**66.** With the feature on and Farm Mode also running while mounted, target a hostile beast. Track Beasts must go up immediately, and the cycle must then carry on rotating on its next tick. Failure is the target-driven switch never showing at all because the cycle overwrote it before you saw it.

## Farm Mode

**67.** On a fresh profile, open the **Farm Mode** page. **Enable Farm Mode** must be ticked, the conditions must read **Mounted** ticked and **Not Mounted** unticked, and the ability list must have **Find Herbs**, **Find Minerals**, and **Find Treasure** ticked with everything else unticked. Find Treasure is listed only on a Dwarf, so on any other race it is simply absent rather than unticked. Failure is any of these the other way round.

**68.** Look at the conditions list by class. **Travel & Flight Forms** must appear only for a Druid, **Aspect of the Cheetah** only for a Hunter, and **Ghost Wolf** only for a Shaman. **Mounted** and **Not Mounted** must appear for everyone. Failure is a condition offered to a class that can never reach it.

**69.** Look at the ability list. It must show only tracking abilities **this character knows**, each with its spell icon, sorted alphabetically, and **Track Humanoids** must never be listed there for a Druid. Failure is unknown abilities appearing, or Track Humanoids being offered as a cycle entry.

**70.** With Find Herbs and Find Minerals both ticked, mount up in the open world. Your mini-map tracking icon must change every few seconds, alternating between the two, and herb dots and ore dots must alternate on the mini-map. Failure is tracking sitting on one ability and never moving.

**71.** Dismount. The cycle must stop and your Persistent Tracking Ability must be restored within a tick or two. Failure is the cycle continuing on foot, or your chosen ability not coming back.

**72.** Tick **Not Mounted** and stand still on foot in the open world. The cycle must now run without a mount. Untick it again and it must stop. Failure is the toggle having no effect.

**73.** On the Druid, shift into Travel Form with **Travel & Flight Forms** ticked. The cycle must run. Untick that condition and it must stop while you stay in form. Failure is the toggle having no effect. On TBC Anniversary, repeat it in Flight Form — Flight Form does not exist on Classic Era, so this half is Anniversary only.

**74.** On the Hunter, tick **Aspect of the Cheetah** and use that aspect. The cycle must run. On the Shaman, tick **Ghost Wolf** and use it — the cycle must run. Failure is the class condition not activating the cycle.

**75.** Ride into a town or inn. The cycle must stop, the tooltip must read **Paused** with *"In a town or inn."*, and the icon must dim. Ride out and it must resume. Failure is the cycle firing tracking casts in a city.

**76.** Zone into a dungeon while mounted or on foot. The cycle must stop and the tooltip must read *"Inside an instance."* Failure is casts firing inside an instance.

**77.** Take a flight path. The cycle must stop for the whole flight, with the tooltip reading *"On a flight path."* and the icon dimmed. Failure is tracking cycling while you're on a gryphon.

**78.** Tick **Not Mounted** so the cycle runs on foot, then pull a mob. The cycle must stop for the fight — the tooltip reads *"In combat."* — and resume once combat ends. Failure is a tracking cast going off mid-fight and eating a global cooldown.

**79.** Untick every ability in the list **and** the **Persistent Tracking Ability** toggle above it, leaving Farm Mode on. Hover the button: the status must read **Paused** with *"No tracking abilities selected."*, and the icon must dim. Failure is the status claiming Active with an empty rotation.

**80.** Tick exactly one ability, leave the **Persistent Tracking Ability** toggle unticked so nothing else joins the rotation, and mount up. That single ability must be kept up rather than the cycle sitting idle — if you cancel tracking by hand it must be recast within a tick or two. Failure is a one-ability cycle doing nothing at all.

**81.** Untick **Enable Farm Mode** entirely and mount up. Nothing may cycle, and the tooltip's **Farm Mode** row must read **Disabled** with no status block above it. Failure is the cycle running with the feature off.

**82.** Tick your abilities back on, then untick every Farm Mode condition while leaving the feature itself on, and hover the button on foot. The status must read **Paused** with *"No Farm Mode conditions are switched on."* Tick only **Mounted** and, still on foot, the reason must change to *"Not mounted."* Failure is a reason that doesn't match what you actually switched off.

## Cycle Farm Mode Ability key binding

**83.** With the binding set and two or more abilities ticked, press it repeatedly out of combat with **Farm Mode switched off**. Tracking must still advance one ability per press — this is a manual control and doesn't need Farm Mode on. Failure is the key doing nothing while Farm Mode is off.

**84.** Press the key while in combat, and again while a loot window is open. Nothing must happen and nothing may print — the binding holds off in exactly the situations the cycle does. Failure is a tracking cast going off mid-fight, or a loot window closing under you.

## Profiles

**85.** Open `/te` → **Profiles**. The panel must load showing your current profile named for this character, in the shape *Name - Realm*. Failure is a blank panel, a Lua error, or a shared **Default** profile — tracking settings are per-character by design.

**86.** Set a Persistent Tracking Ability and a distinctive cycle interval on one character, then log in on a second character on the same account. That character must have its **own** tracking settings, untouched by the first. Failure is the second character inheriting the first's ability or interval.

**87.** On the second character, confirm the account-wide settings still match: the welcome message toggle, the mini-map button toggle and position, Free Placement Mode and its layout, and **Use the Default Tracking Button**. Failure is any of those differing per character.

**88.** Change several Farm Mode settings, then click **Reset Profile**. The tracking and Farm Mode settings must return to install defaults, and the pages must show the reset values as soon as you click back to them, **without** a `/reload`. Failure is settings surviving the reset, or panels showing stale values until you reload.

**89.** Confirm what Reset Profile did **not** touch: the welcome message toggle, the mini-map button's position and visibility, and Free Placement Mode must all be exactly as they were. Failure is a reset wiping account-wide layout along with the character's own settings.

**90.** Create a new profile called `Test`. Change the cycle interval while on `Test`, then switch back to your character's own profile. Each must hold its own value, and the panel must show each profile's values the moment you switch. Failure is one profile's change leaking into the other.

**91.** With `Test` active, use **Copy From** and copy from the other profile. `Test` must take on those settings, visible immediately. Then `/reload` — `Test` must still be the active profile with its settings intact. Failure is nothing changing, an error, or the profile snapping back across the reload.

**92.** Switch back to your own profile and delete `Test`. The deletion must succeed with no error, and `Test` must be gone from the list and stay gone after a `/reload`. Failure is an error, or the profile reappearing.

## Diagnostic Tools

**93.** Log in fresh and open `/te` → **Diagnostic Tools**. Only two things may be visible: the warning paragraph and the **Enable Diagnostic Tools** toggle, which must be **off**. Failure is the toggle being on by default, or any report button visible before you enable anything.

**94.** Tick **Enable Diagnostic Tools**. Eleven sections must appear below it without reopening the panel: Event Log, Event Registration, API Endpoints, Player & Spell Context, Display Context, Farm Mode Context, Other Add-ons, Saved Variables, Library Versions, Taint Log, and External Tools — the last being two hint lines mentioning `/console scriptErrors 1` and `/etrace`. Failure is nothing appearing, a missing section, or the panel needing a reopen.

**95.** Click **Show Captured Events** before starting a log. The output box must read **(no events captured)** under a header line naming the add-on, its version, and your client. Failure is an error or an empty box with no explanation.

**96.** Click **Start Event Log**, then go mount up, change your tracking from the menu, and dismount. Come back and click **Show Captured Events**. The box must fill with timestamped lines naming the events as they fired, including your tracking cast. Click **Stop Event Log**, then **Show Captured Events** again — it must return to **(no events captured)**. Failure is an empty log after you demonstrably changed tracking, or old entries persisting after a stop.

**97.** Click **Test Event Registration**. Every event listed must show `[PASS]`, and the summary line must read that all events register on this client. Failure is any `[FAIL]`. An `IsEventValid: n/a` is **not** a failure — that check simply doesn't exist on every client.

**98.** Click **Test WoW API Endpoints**. Rows marked `[n/a]` are the legacy half of a compatibility pair and are expected on a client that has the modern half — they are not failures. Failure is any `[FAIL]` row, or a summary line reporting missing APIs.

**99.** Click **Check Player & Tracking Spells**. It must print your class and level, then one line per tracking spell marked *known* or *not known*. On Classic Era, spell **43308** must read **(not on this client)** — Find Fish does not exist there, and that line is correct, not a failure. On TBC Anniversary it must show a real name instead. Failure is a wrong class or level, or every spell reading "not on this client".

**100.** Click **Check Display & Icon Placement**. It must print your screen size, your UI scale, and the live state of the mini-map button and the free-placement frame — and those values must agree with what you can see on screen. Turn Free Placement Mode on, run it again, and `freePlacement` must now read true with a position beside it. Failure is `nil` where a number belongs, or a report that disagrees with the screen.

**101.** Mount up in the open world, then click **Check Farm Mode State**. It must print the master toggle, every condition toggle, your live movement state, whether the cycle can currently cast, and the list of abilities actually in your rotation — and all of it must match what the Farm Mode page shows. Ride into town and run it again: the pause reason must change. That reason prints as a short code rather than a sentence, which is deliberate so a report pasted from any language stays readable. Failure is the report contradicting the panel or the tooltip.

**102.** Click **List Installed Add-ons**, **Dump Saved Variables**, and **List Library Versions** in turn. Each must fill its box with readable text rather than an empty box or an error. In the Saved Variables dump, your Persistent Tracking Ability and Farm Mode toggles must appear under your character's profile and match what the panel shows. Failure is any button producing nothing, or stored values that disagree with the panel.

**103.** Read the Taint Log state line, click **Turn On Taint Log** — the state must change to level 2 — then **Turn Off Taint Log**, and it must return to level 0. **Leave taint logging off when you're done.** Then untick **Enable Diagnostic Tools**: everything below the toggle must disappear immediately and any running log must stop. `/reload` and reopen the panel — the toggle must be **off** again, because diagnostics is deliberately a session-only setting. Failure is the number not moving, sections staying on screen, or diagnostics surviving a reload.

## Characters with no tracking abilities

**104.** Log in on the character who knows no tracking ability at all. There must be **no Tracking Eye mini-map button** and no standalone icon — with nothing to track, the add-on stays out of the way. Type `/te`: the options panel must still open normally. Failure is a button appearing, or `/te` failing on a character with no abilities.

**105.** On that character, open the **Farm Mode** page. It must be empty of controls — no conditions, no ability list, no cycle dropdown. Turn Free Placement Mode on from the main page: still no icon may appear. Failure is an empty ability list rendered as a broken or half-drawn section, or a free-placement icon appearing with nothing to show.

## Flavor differences to watch

Do not skim these. Each behaves differently on the two clients, and a plan run on only the forgiving flavor will pass while the add-on is broken for half its users.

- **Options panel docking (steps 25–27)** — correct on Classic Era; TBC Anniversary is the client where the panel has historically floated free instead of docking inside the Blizzard Options window. Run all three entry points on Anniversary, not just Era.
- **Tracking icon settle time (steps 37, 51, 70)** — on Classic Era the mini-map's tracking display can take a few seconds to catch up after tracking changes; on TBC Anniversary it updates promptly. Give a change five seconds on Era before calling a step failed. A change that never lands at all, on either client, is a real failure.
- **Find Fish (steps 55, 99)** — exists on TBC Anniversary only. On Classic Era it must never appear in the tracking menu or the Farm Mode ability list, and the Player & Spell Context report must say *(not on this client)* for spell 43308. That is correct behavior, not a gap.
- **Druid Flight Form and Swift Flight Form (step 73)** — TBC Anniversary only. On Classic Era the Travel & Flight Forms condition covers Travel Form and Aquatic Form alone, and there is nothing else to test there.
- **Use the Default Tracking Button (step 13)** — this reaches into a frame the game owns and the two clients don't build it identically. Confirm the take-over **and** the restore on both flavors; a clean round trip on Era proves nothing about Anniversary.
- **API Endpoints report (step 98)** — which rows read `[n/a]` differs between the clients. That is the report doing its job. Only a `[FAIL]` counts.

## Localization spot-check

Optional, and only worth running on a non-English client. The add-on ships eleven locales, and its tooltip and options text are almost entirely translated, so this is where breakage shows up.

**106.** Log in on a non-English client and read the main page, the Farm Mode page, and the mini-map tooltip. Every label, description, note, and status must render in that language. Failure is a raw key showing through — text like `OPTIONS_FARM_NOTE` or `FARM_PAUSED_RESTING` on screen instead of a sentence.

**107.** Read the welcome line at login and the cycle dropdown. The welcome line must carry a version where the number belongs and must read as one sentence; every dropdown entry must carry its number in a sensible place. Failure is `nil` anywhere, a stray `%s`, a doubled value, or a number landing in the wrong half of the sentence. Do this on **ruRU** in particular — Cyrillic is the widest-encoding locale the add-on ships, so anything that overruns shows there first. Nothing here is sent to chat, so there is no length limit to breach; you are checking that the sentences render and read correctly.

**108.** Ride into a town, then into an instance, then take a flight path, hovering the button each time, and read the Farm Mode pause reasons. Each must be a complete, grammatical sentence in that language naming the right condition. Then check the same reasons on a Hunter and a Shaman, where the wording changes with the class. Some languages reorder these sentences — that is **intentional and correct**, and a translator should not "fix" it. Failure is only a genuinely ungrammatical sentence, or a reason describing a condition you aren't in.

## Sign-off

Manual testing is complete when **every step passes on both Classic Era and TBC Anniversary**. A single flavor is half a run. Once both rows below are filled in and passing, the add-on is ready for `4 - Pre-Launch Review Prompt.md`.

| Flavor | Tester | Date | Result | Failed steps |
| --- | --- | --- | --- | --- |
| Classic Era | | | ☐ Pass ☐ Fail | |
| TBC Anniversary | | | ☐ Pass ☐ Fail | |

Several steps need a particular class or profession. Record which paths you actually covered, so a returning maintainer can see what is still untested.

| Class path | Steps | Covered |
| --- | --- | --- |
| Herbalism + Mining | most of the plan | ☐ |
| Hunter | 8–10, 21, 63–64, 66, 68, 74, 108 | ☐ |
| Druid | 53, 58, 68, 73 | ☐ |
| Shaman | 68, 74, 108 | ☐ |
| Dwarf (Find Treasure) | 21, 67 | ☐ |
| Paladin or Warlock | 65 | ☐ |
| No tracking ability at all | 62, 104–105 | ☐ |
| Fishing (Anniversary only) | 55 | ☐ |
