# Windrunner's Guide: Yabai & Skhd Cheat Sheet

A comprehensive guide to keyboard-driven desktop management on macOS using **yabai** and **skhd**.

---

## 🌀 1. Window Focus (Vim-Style Navigation)
Focus windows or display targets seamlessly.

*   `⌥ H` : Focus window / display **West (Left)**
*   `⌥ J` : Focus window / display **South (Down)**
*   `⌥ K` : Focus window / display **North (Up)**
*   `⌥ L` : Focus window / display **East (Right)**
*   `⌥ S` : Focus display **West (Left)**
*   `⌥ G` : Focus display **East (Right)**

---

## 📐 2. Space Layout & Surgebinding
Modify space configurations and window layouts.

*   `⇧ ⌥ R` : Rotate space layout **270°**
*   `⇧ ⌥ Y` : Mirror space on **Y-Axis (Vertical)**
*   `⇧ ⌥ X` : Mirror space on **X-Axis (Horizontal)**
*   `⇧ ⌥ T` : **Toggle Float State** (resets to centered grid `4:4:1:1:2:2`)
*   `⇧ ⌥ M` : **Toggle Zoom-Fullscreen** (maximize focused window)
*   `⇧ ⌥ E` : **Balance Space** (distribute window sizes evenly)

---

## ⚡ 3. Moving & Swapping Windows (Warping)
Swap position or warp windows within the grid.

*   `⇧ ⌥ H` : **Swap** window with **West (Left)**
*   `⇧ ⌥ J` : **Swap** window with **South (Down)**
*   `⇧ ⌥ K` : **Swap** window with **North (Up)**
*   `⇧ ⌥ L` : **Swap** window with **East (Right)**
*   `⌃ ⌥ H` : **Warp** window to **West (Left)** (moves window and follows focus)
*   `⌃ ⌥ J` : **Warp** window to **South (Down)**
*   `⌃ ⌥ K` : **Warp** window to **North (Up)**
*   `⌃ ⌥ L` : **Warp** window to **East (Right)**

---

## 🖥️ 4. Multi-Display Navigation
Send windows across physical screens.

*   `⇧ ⌥ S` : Move window to **West display** (and follow focus)
*   `⇧ ⌥ G` : Move window to **East display** (and follow focus)

---

## 🌌 5. Inter-Space Navigation
Send windows across workspace spaces.

*   `⇧ ⌥ P` : Move window to **Previous Space** (and focus it)
*   `⇧ ⌥ N` : Move window to **Next Space** (and focus it)
*   `⇧ ⌥ [0-9]` : Move window to **Space 0 to 9** (and focus it)

---

## 🛠️ 6. Yabai Service Management
Start, stop, or reload your layout configuration.

*   `⌃ ⌥ Q` : Stop Yabai service (`brew services stop yabai`)
*   `⌃ ⌥ S` : Start Yabai service (`brew services start yabai`)
*   `⌃ ⌥ R` : Restart Yabai service (`brew services restart yabai`)
