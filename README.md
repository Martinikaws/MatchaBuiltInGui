# MatchaBuiltInGui

The Rivals Skin Changer as a tab in Matcha's own menu. It edits `rivals_config.lua` and runs the changer, with the same options as the site and the drawn GUI: skins, skin swaps, wraps, finishers, charms, sky and lighting, tracers, no hands, sounds and spoof.

## Run it

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Martinikaws/MatchaBuiltInGui/main/gui.lua"))()
```

Then open the **Rivals Changer** tab in Matcha's menu. To load it on every join, put [`autoexec.lua`](autoexec.lua) in Matcha's autoexec folder. The tab only appears in RIVALS.

## How it's laid out

- **Changer**: Save & Apply, the status, and "Apply by itself on join".
- **Items** (left): pick Skins, Swaps, Wraps, Finishers or Charms under *Show*. Each list goes one step at a time: first the weapon or item you own, then what it should look like. `*` marks one you've set; `>` marks the current pick. The "you own" lists show only what you own (switchable in Changer).
- **Extras** (right): Sky and lighting, Sounds (with a preview), and Misc, which holds Tracers (colour per gun with a colour picker, rainbow, a speed slider, optional Energy Pistols tracers), Hands (hide your first-person arms per weapon) and Spoof (name, stats, badges, name effect).

Matcha's dropdowns can't scroll, so the long lists are buttons in scrollable sections, with a search box on each list.

## Notes

- It uses the same config file and auto-apply setting as the drawn GUI, and never stops it. Use one or the other.
- If the config was changed somewhere else (the site, the other GUI), Save refuses and asks you to press **Reload config**. Your file is never overwritten.

Credits: Martini (skin changer), dantekarati (contributor), choperr0333 aka @Giounis (main tester/supporter).
