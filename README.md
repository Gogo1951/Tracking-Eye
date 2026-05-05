# Tracking Eye

A smart tracking menu that auto-cycles herb and ore tracking while mounted (or in travel forms), and automatically restores your tracking ability after death.

<img width="375" src="https://github.com/user-attachments/assets/f8627a30-8188-4691-bab8-75b5d82eaee1" />

<img width="175" src="https://github.com/user-attachments/assets/de98982b-d787-4fa3-ac6f-00aca4d637e8" />

## What It Does

Tracking in Classic is a chore. You forget to recast Find Herbs after a corpse run, you can only watch one node type at a time on a long mounted route, and the default tracking menu is a tiny minimap dropdown that never quite does what you want.

Tracking Eye fixes those frustrations in one place. It gives you a clean menu of every tracking spell you know, remembers which one you want active, and quietly recasts it after you die. While you're mounted or in travel form, it cycles between the tracking abilities you care about so you never miss a node along the way.

It works for Hunters, Druids, Warlocks, Paladins, and any class that uses Find Herbs, Find Minerals, Find Treasure, or Find Fish.

## Quick Start

1. Install from [CurseForge](https://www.curseforge.com/wow/addons/tracking-eye-classic), or grab the latest release from [GitHub](https://github.com/Gogo1951/Tracking-Eye) and drop it into your `Interface/AddOns` folder.
2. Log in. A new tracking-eye icon appears on your minimap.
3. Left-click the icon to pick a tracking spell — the addon will keep recasting it after death until you change your mind.
4. Mount up. Farm Mode automatically rotates between Find Herbs and Find Minerals so both nodes show up while you ride.
5. Type `/te` to open the options panel and tweak which abilities cycle, how fast, and where the icon lives.
6. Want the icon off the minimap? Enable Free Placement Mode and drag the icon anywhere on your screen.

## Tracking Menu

Left-click the minimap button to see every tracking spell your character knows in one alphabetical list. Click any spell to set it as your Persistent Tracking Ability and cast it immediately. The menu automatically hides spells you don't have.

- **Hunters** can pick from every Find/Track ability — Beasts, Demons, Dragonkin, Elementals, Giants, Hidden, Humanoids, and Undead.
- **Druids** see Track Humanoids in the menu when they're in Cat Form.
- **Warlocks** can choose Sense Demons.
- **Paladins** can choose Sense Undead.
- **Every class** sees Find Herbs, Find Minerals, Find Treasure, and Find Fish if those spells are known.

## Persistent Tracking

Set your tracking spell once and Tracking Eye remembers it. After you resurrect or change forms, the addon waits for the global cooldown and quietly recasts the spell so your minimap arrows come back without a thought. Toggle it on or off with Shift + Left-Click on the minimap button.

## Farm Mode

While you're mounted or in a Druid travel form, Farm Mode rotates between the tracking abilities you've selected — by default Find Herbs and Find Minerals — so both node types show on your minimap as you ride. The cycle pauses automatically inside instances and while resting, where it would just be noise. Toggle it with Shift + Right-Click on the minimap button.

## Free Placement Mode

Detach the tracking icon from the minimap and place it anywhere on your screen. Pick a circular or square border, scale it up or down, and drag it where you want. Toggle it with Shift + Middle-Click on the minimap button.

## Settings

Open the options panel via `/te` or `/trackingeye`.

- **Enable Welcome Message** — Show or hide the login chat message.
- **Enable Persistent Tracking** — Recast your tracking spell after death and shapeshift changes.
- **Enable Farm Mode** — Cycle through your selected tracking abilities while mounted or in travel form.
- **Farm Mode Abilities** — Pick which tracking spells Farm Mode rotates through. Only spells you actually know appear here.
- **Cycle Speed** — How often Farm Mode switches abilities, from 2 to 10 seconds (default 3.5).
- **Enable Free Placement Mode** — Replace the minimap button with a draggable standalone icon.
- **Icon Size** — Scale the standalone icon when Free Placement Mode is on.
- **Icon Shape** — Choose a circular or square border for the standalone icon.
- **Reset All Options** — Wipe every Tracking Eye setting back to defaults.

## Slash Commands

| Command | Effect |
| --- | --- |
| `/te` | Opens the options panel. |
| `/trackingeye` | Opens the options panel. |

## Minimap Button

| Action | Effect |
| --- | --- |
| Left-Click | Open the tracking menu. |
| Right-Click | Clear current tracking. |
| Shift + Left-Click | Toggle Persistent Tracking. |
| Shift + Right-Click | Toggle Farm Mode. |
| Shift + Middle-Click | Toggle Free Placement Mode. |

## Saved Variables

Tracking Eye stores per-character preferences in `TrackingEyeCharDB` (selected tracking spell, Persistent Tracking and Farm Mode toggles, cycle speed, farm-cycle ability list, last icon, welcome message toggle) and account-wide preferences in `TrackingEyeGlobalDB` (minimap button position, Free Placement Mode toggle, free-icon position, scale, and shape).

## Testing Status

🟢 World of Warcraft Classic Era

🟢 Burning Crusade Classic Anniversary

🔴 Mists of Pandaria Classic

🔴 Retail

Please reach out if you would like to be involved with testing!

## Links

- [CurseForge](https://www.curseforge.com/wow/addons/tracking-eye-classic)
- [GitHub](https://github.com/Gogo1951/Tracking-Eye)
- [Discord](https://discord.gg/eh8hKq992Q)

## History

This is a continuation of LindenRyuujin's [Tracking Eye](https://www.curseforge.com/wow/addons/tracking-eye).
