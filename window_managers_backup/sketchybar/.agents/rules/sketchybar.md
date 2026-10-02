# Sketchybar Configuration Context

This rule provides context for Antigravity when working in this directory.

## Theme and Aesthetics
- This setup heavily uses a custom **Cosmere (Stormlight/Scadrial) theme**. 
- All colors are strictly centralized and defined in `~/.local/bin/cosmere_colors.sh`. 
- **Do not** hardcode new hex colors into individual scripts. Always source the `cosmere_colors.sh` file and use the exported variables (e.g., `$PRES_GLACIAL`, `$WARN_COLOR`, `$SPREN_HONOR`).
- Follow the aesthetic principle of using dark, translucent backgrounds with highly contrasting radiant colors.

## Architecture
- The main configuration is inside `sketchybarrc`.
- Plugin scripts are stored in the `plugins/` directory.
- The configuration relies heavily on hover-triggered popups. Most items use `hover.sh` to handle `mouse.entered` and `mouse.exited` events.

## Best Practices
- Before modifying a specific feature, read the corresponding script in the `plugins/` directory.
- Prioritize event-driven updates (e.g., using `sketchybar --add event ...`) over polling when possible to save resources.
- For UI feedback, utilize dynamic icons and colors (like changing a battery icon or color based on percentage) rather than static text when possible.
