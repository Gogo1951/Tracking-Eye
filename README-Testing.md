# Tracking Eye // Test Plan

Tracking Eye keeps your tracking up for you: one menu for every tracking ability, Farm Mode switching between herbs and ore while you ride, and tracking whatever kind of creature you target. This time we most want you to try the new Feedback & Support page and, on WoW Forever and Retail, the mini-map button.

**Play on Classic Era, Season of Discovery, TBC Anniversary, WoW Forever, MoP Classic, and Retail.** If something looks wrong, tell us the check number and what you saw on [Discord](https://discord.gg/eh8hKq992Q).

## What's New

1. Type `/te` and open the new **Feedback & Support** page between **Profiles** and **Diagnostic Tools**, then copy a link from its box with Ctrl+A and Ctrl+C.
2. On WoW Forever and Retail, log in with your usual mini-map add-ons and check the button's icon sits centered and round, with no error.
3. In **Diagnostic Tools**, tick **Enable Diagnostic Tools**, open the new **Localization** tab, and click **Run All Localization Reports**; **Game Names** should read *all found*, above all on a non-English client.

## Everything Else

4. Left-Click the mini-map button, pick a tracking ability from the Tracking Menu, then Right-Click the button to clear it.
5. On a character with Herbalism and Mining, mount up and ride: tracking should switch between Find Herbs and Find Minerals every few seconds, and stop when you stand still or fight.
6. With **Enable Persistent Tracking** ticked, die, resurrect, and walk: your tracking should come back.
7. With **Find Fish When You Equip a Fishing Pole** ticked, equip a fishing pole and walk, then put it away (not on Classic Era).
8. On a Druid, tick **Druid: Track Humanoids When You Shift into Cat Form** and shift into Cat Form.
9. On a Hunter, Shift + Right-Click the mini-map button to turn on Automatic Target Tracking, then target a hostile beast and an undead.
10. On a character without Herbalism or Mining, right-click an herb or ore vein: a callout should open in your chat box, and nothing goes out until you press Enter.
11. Bind **Cycle Farm Mode Ability** with its **Set Key** button on the main `/te` page, then press the key to switch tracking.
12. Open the options with `/te`, then with Shift + Middle-Click on the mini-map button; both should open inside the game's Options window, and TBC Anniversary is the one most likely to break.
13. In combat, try `/te` and Shift + Middle-Click: the options should refuse to open, with a line in chat.
14. On WoW Forever and Retail, fight a few mobs while Farm Mode is on, then as a Hunter swapping aspects and a Druid shifting forms, and watch for Lua errors.
