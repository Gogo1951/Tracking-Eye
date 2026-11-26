# Tracking Eye // Test Plan

Tracking Eye keeps your tracking up for you: one menu for every tracking ability, Farm Mode switching between herbs and ore while you ride, and tracking whatever kind of creature you target. This time we most want you to try the redrawn mini-map menu, its new Cycle Speed and More Features flyouts, and the new Pause While a Window Is Open switch.

**Play on Classic Era, Season of Discovery, TBC Anniversary, WoW Forever, and MoP Classic.** If something looks wrong, tell us the check number and what you saw on [Discord](https://discord.gg/eh8hKq992Q).

## What's New

1. With Farm Mode on, open Farm Mode's flyout in the mini-map menu and pick a speed from the Cycle Speed flyout: the row should show the new speed.
2. Hover More Features in the mini-map menu: it should count what's On and Off, and its flyout should switch Come & Get It and open Free Placement Mode's options.
3. With Farm Mode on, stand in a town: Farm Mode should show Paused, with the reason under its description.
4. Open the world map with Farm Mode on, then turn off Pause While a Window Is Open and open it again: Farm Mode should keep cycling the second time.
5. Right-click the mini-map button while Clear Tracking shows to clear your tracking, then Shift-click it: Shift-clicks should do nothing.
6. On a character with no tracking ability, open the main options page: a line should say why the mini-map button is hidden.
7. Open the main, Farm Mode and Free Placement Mode options pages: every control should line up in one column.

## Everything Else

8. Hover the mini-map button, pick a tracking ability under Persistent Tracking, then die and resurrect: your tracking should come back.
9. On a character with Herbalism and Mining, mount up and ride with Farm Mode on: tracking should switch between Find Herbs and Find Minerals, and stop in combat.
10. On a Hunter with Automatic Target Tracking on, target a hostile beast, then an undead, and on WoW Forever do it in combat too, watching for Lua errors.
11. Bind **Toggle Farm Mode** and **Toggle Automatic Target Tracking** with Set Key on the main options page, then press each: the menu's On and Off should follow.
12. On a character without Herbalism or Mining, right-click an herb or ore vein: a callout should open in your chat box, and nothing goes out until you press Enter.
13. Open the options with `/te`, then with Tracking Eye Options in the mini-map menu: both should open inside the game's Options window, and TBC Anniversary is the one most likely to break.
14. In combat, try `/te` and Tracking Eye Options: the options should refuse to open, with a line in chat.
