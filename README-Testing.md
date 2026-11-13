# Tracking Eye // Test Plan

Tracking Eye keeps your tracking up for you: one menu for every tracking ability, Farm Mode switching between herbs and ore while you ride, and tracking whatever kind of creature you target. This time we most want you to try the reworked mini-map menu, and logging in and dying with Persistent Tracking on.

**Play on Classic Era, Season of Discovery, TBC Anniversary, WoW Forever, and MoP Classic.** If something looks wrong, tell us the check number and what you saw on [Discord](https://discord.gg/eh8hKq992Q).

## What's New

1. Hover the mini-map button and click the Toggle row under each feature: the state beside its name should change, and the menu should stay open.
2. On a Mage or Warrior, open the mini-map menu: Automatic Target Tracking should be missing, and Farm Mode's settings should list no travel forms or aspects.
3. Log in with Persistent Tracking on and your tracking up, then walk: it should not be cast again.
4. As a Hunter, turn on Automatic Target Tracking and target a beast, then mount up and ride with Farm Mode on, then dismount: your own Persistent Tracking pick should come back, not the beast tracking.
5. On the **Come & Get It** page, switch **Default Output** and watch the Example line under it follow, then log onto another character: your choice should carry over.

## Everything Else

6. Left-click the mini-map button, pick a tracking ability from the list under Persistent Tracking, then clear it with Clear Tracking.
7. On a character with Herbalism and Mining, mount up and ride: tracking should switch between Find Herbs and Find Minerals every few seconds, and stop when you stand still or fight.
8. With **Enable Persistent Tracking** ticked, die, resurrect, and walk: your tracking should come back, even if you logged out while dead.
9. On a Druid, tick **Druid: Track Humanoids When You Shift Into Cat Form**, then shift into Cat Form and back out: tracking should swap, then return.
10. On a Hunter with Automatic Target Tracking on, target a hostile beast, then an undead.
11. On a character without Herbalism or Mining, right-click an herb or ore vein: a callout should open in your chat box, and nothing goes out until you press Enter.
12. Open the options with `/te`, then with Tracking Eye Options in the mini-map menu; both should open inside the game's Options window, and TBC Anniversary is the one most likely to break.
13. In combat, try `/te` and Tracking Eye Options in the menu: the options should refuse to open, with a line in chat.
14. On WoW Forever, fight a few mobs with Farm Mode on, then as a Hunter with Automatic Target Tracking on and as a Druid shifting forms, and watch for Lua errors.
