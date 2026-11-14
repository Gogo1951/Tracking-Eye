# Tracking Eye // Test Plan

Tracking Eye keeps your tracking up for you: one menu for every tracking ability, Farm Mode switching between herbs and ore while you ride, and tracking whatever kind of creature you target. This time we most want you to try the mini-map button's click shortcuts and the options, which now give every feature its own page.

**Play on Classic Era, Season of Discovery, TBC Anniversary, WoW Forever, and MoP Classic.** If something looks wrong, tell us the check number and what you saw on [Discord](https://discord.gg/eh8hKq992Q).

## What's New

1. On the mini-map button itself, try each click the menu names on the right of a row (Right-Click, Shift + Left-Click, Shift + Right-Click, Shift + Middle-Click): each should do what its row does.
2. Under **More Features** in the mini-map menu, click Come & Get It to switch it on and off, then click Free Placement Mode: it should open its options page instead.
3. Look through the options: every feature has its own page, Farm Mode has an **Abilities** page under it, and the **Features** switches on the main page should match each page's own switch.
4. With a tracking ability picked, turn Persistent Tracking off and back on with its Toggle row, then switch profiles on the **Profiles** page: the ability should cast right away both times.
5. With Free Placement Mode on, set **Icon Shape** to Square: the icon should fill its thin black border.
6. Ride with Farm Mode on and hover the mini-map button: Farm Mode should read Active, not Paused.

## Everything Else

7. Hover the mini-map button, pick a tracking ability from the list under Persistent Tracking, then clear it with Clear Tracking.
8. On a character with Herbalism and Mining, mount up and ride: tracking should switch between Find Herbs and Find Minerals every few seconds, and stop when you stand still or fight.
9. With Persistent Tracking on, die, resurrect, and walk: your tracking should come back, even if you logged out while dead.
10. On a Druid, tick **Druid: Track Humanoids When You Shift Into Cat Form**, then shift into Cat Form and back out: tracking should swap, then return.
11. On a Hunter with Automatic Target Tracking on, target a hostile beast, then an undead.
12. On a character without Herbalism or Mining, right-click an herb or ore vein: a callout should open in your chat box, and nothing goes out until you press Enter.
13. Open the options with `/te`, then with Tracking Eye Options in the mini-map menu: both should open inside the game's Options window, and TBC Anniversary is the one most likely to break.
14. In combat, try `/te` and Tracking Eye Options: the options should refuse to open, with a line in chat.
15. On WoW Forever, fight a few mobs with Farm Mode on, then as a Hunter with Automatic Target Tracking on and as a Druid shifting forms, and watch for Lua errors.
