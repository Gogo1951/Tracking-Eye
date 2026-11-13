# Tracking Eye // Test Plan

Tracking Eye keeps your tracking up for you: one menu for every tracking ability, Farm Mode switching between herbs and ore while you ride, and tracking whatever kind of creature you target. This time we most want you to try the new mini-map menu, above all with a controller, and the new Feedback & Support page.

**Play on Classic Era, Season of Discovery, TBC Anniversary, WoW Forever, MoP Classic, and Retail.** If something looks wrong, tell us the check number and what you saw on [Discord](https://discord.gg/eh8hKq992Q).

## What's New

1. Hover the mini-map button: a menu should open, with every feature and whether it's on, and close again a moment after you move away.
2. In the menu, hover Farm Mode and Automatic Target Tracking and click their On/Off switches, switch an ability in the Farm Mode list, then click Tracking Eye Options. With a controller, do the same with the gamepad cursor.
3. Type `/te` and open the new **Feedback & Support** page between **Profiles** and **Diagnostic Tools**, then copy a link from its box with Ctrl+A and Ctrl+C.
4. On WoW Forever and Retail, log in with your usual mini-map add-ons and check the button's icon sits centered and round, with no error.
5. In **Diagnostic Tools**, tick **Enable Diagnostic Tools**, open the new **Localization** tab, and click **Run All Localization Reports**; **Game Names** should read *all found*, above all on a non-English client.

## Everything Else

6. Left-Click the mini-map button, pick a tracking ability from the list that opens, then clear it with Clear Tracking under the list.
7. On a character with Herbalism and Mining, mount up and ride: tracking should switch between Find Herbs and Find Minerals every few seconds, and stop when you stand still or fight.
8. With **Enable Persistent Tracking** ticked, die, resurrect, and walk: your tracking should come back.
9. With **Find Fish When You Equip a Fishing Pole** ticked, equip a fishing pole and walk, then put it away (not on Classic Era).
10. On a Druid, tick **Druid: Track Humanoids When You Shift into Cat Form** and shift into Cat Form.
11. On a Hunter, click Automatic Target Tracking in the mini-map menu to turn it on, then target a hostile beast and an undead.
12. On a character without Herbalism or Mining, right-click an herb or ore vein: a callout should open in your chat box, and nothing goes out until you press Enter.
13. Bind **Cycle Farm Mode Ability** with its **Set Key** button on the main `/te` page, then press the key to switch tracking.
14. Open the options with `/te`, then with Tracking Eye Options in the mini-map menu; both should open inside the game's Options window, and TBC Anniversary is the one most likely to break.
15. In combat, try `/te` and Tracking Eye Options in the menu: the options should refuse to open, with a line in chat.
16. On WoW Forever and Retail, fight a few mobs while Farm Mode is on, then as a Hunter swapping aspects and a Druid shifting forms, and watch for Lua errors.
