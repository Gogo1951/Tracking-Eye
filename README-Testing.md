# Tracking Eye // Test Plan

Tracking Eye keeps your tracking up for you: one menu for every tracking ability, Farm Mode switching between herbs and ore while you ride, and tracking whatever kind of creature you target. This time we most want you to try the mouse wheel on the mini-map button, the two new key bindings, and the redrawn mini-map menu.

**Play on Classic Era, Season of Discovery, TBC Anniversary, WoW Forever, and MoP Classic.** If something looks wrong, tell us the check number and what you saw on [Discord](https://discord.gg/eh8hKq992Q).

## What's New

1. With Farm Mode on, roll the mouse wheel over the mini-map button: each notch changes Cycle Speed by half a second, and Farm Mode's flyout opens showing the new speed and what you're Tracking Now.
2. Bind **Toggle Farm Mode** and **Toggle Automatic Target Tracking** with Set Key on the main options page, then press each: the menu's On and Off should follow.
3. Let Farm Mode turn on a tracking ability without picking one yourself, then hover the mini-map button: Clear Tracking should show and clear it.
4. With Free Placement Mode on, drag the icon away, then click **Reset** under Icon Position: it should jump back to the middle of your screen.
5. With Farm Mode off, open its **Abilities** page: a silver line should say Farm Mode is off, and the ticks should still change.
6. Open each flyout in the mini-map menu, with the button on the left and then the right side of your screen: it should overlap the menu slightly, never leave a gap.

## Everything Else

7. Hover the mini-map button, pick a tracking ability under Persistent Tracking, then die and resurrect: your tracking should come back.
8. On a character with Herbalism and Mining, mount up and ride with Farm Mode on: tracking should switch between Find Herbs and Find Minerals, and stop in combat.
9. On a Hunter with Automatic Target Tracking on, target a hostile beast, then an undead.
10. On a character without Herbalism or Mining, right-click an herb or ore vein: a callout should open in your chat box, and nothing goes out until you press Enter.
11. Open the options with `/te`, then with Tracking Eye Options in the mini-map menu: both should open inside the game's Options window, and TBC Anniversary is the one most likely to break.
12. In combat, try `/te` and Tracking Eye Options: the options should refuse to open, with a line in chat.
13. On WoW Forever, fight a few mobs with Farm Mode on, then as a Hunter with Automatic Target Tracking on, and watch for Lua errors.
