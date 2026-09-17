<div align="center">
  <img src="https://github.com/sxyazi/yazi/blob/main/assets/logo.png?raw=true" alt="Yazi logo" width="20%">
</div>

<h3 align="center">
	Cosmere Flavor for <a href="https://github.com/sxyazi/yazi">Yazi</a>
</h3>

A Yazi color flavor inspired by Brandon Sanderson's **Cosmere** universe — drawing colors from the worlds of Roshar (Stormlight Archive), Scadrial (Mistborn), and the luminous hues of Spren.

## 🎨 Color Palette

| Source | Color | Hex | Usage |
|--------|-------|-----|-------|
| Stormlight — Honor Gold | 🟡 | `#FFD700` | Find keywords, bold markup, diff changed |
| Stormlight — Sapphire | 🔵 | `#00BFFF` | Storage types, type declarations |
| Stormlight — Emerald | 🟢 | `#50fa7b` | Raw inline, exec success markers |
| Stormlight — Amber | 🟠 | `#ffb86c` | Function args, italic markup, warnings |
| Stormlight — Crimson | 🌸 | `#ed8796` | Cut marker, deleted diff, punctuation |
| Stormlight — Violet | 🔮 | `#8989ff` | Numbers, constants |
| Scadrial — Preservation Mist | ☁️ | `#C8E8F5` | Foreground text |
| Scadrial — Preservation Glacial | 🧊 | `#5DA8CC` | Borders, library functions |
| Scadrial — Preservation Lavender | 💜 | `#C3AEE8` | Directories, underline markup |
| Scadrial — Preservation Deep | 🌌 | `#1A2A3A` | Selection, panel backgrounds |
| Scadrial — Deep Night | 🌑 | `#0D1B2A` | Main background |
| Spren — Honorspren Sky Blue | 🩵 | `#00A8E8` | CWD, class names, headings, active mode |
| Spren — Cryptic Orchid | 🌸 | `#DA70D6` | Strings, tag names, find position |
| Spren — Cultivationspren Green | 🌿 | `#3CB371` | Functions, tag attrs, diff inserted |
| Spren — Inkspren Indigo | 🪬 | `#8A2BE2` | Archives, variable.language |
| Spren — Willshaper Amethyst | ✨ | `#E040FB` | Keywords, active tabs/mode, borders |
| Spren — Ashspren Volcanic | 🌋 | `#FF4500` | Hard errors, progress error |

## ⚙️ Usage

Set the content of your `theme.toml` to enable it as your _dark_ flavor:

```toml
[flavor]
dark = "cosmere"
```

Make sure your `theme.toml` doesn't contain anything other than `[flavor]`, unless you want to override certain styles of this flavor.

See the [Yazi flavor documentation](https://yazi-rs.github.io/docs/flavors/overview) for more details.

## 📜 License

MIT — inspired by the Dracula flavor structure.
