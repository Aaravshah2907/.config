#!/bin/bash

# ====================================================================
# COSMERE COLOR PALETTE
# Stormlight (Roshar) · Scadrial (Ruin & Preservation) · All Spren
# ====================================================================

# ──────────────────────────────────────────────
# NEUTRALS
# ──────────────────────────────────────────────
export WHITE=0xffffffff
export WHITE_TRANSLUCENT=0xaaffffff
export BLACK=0xff000000
export BLACK_TRANSLUCENT=0xaa000000

# ──────────────────────────────────────────────
# WINDRUNNER / STORMLIGHT  (Honor's Radiance, Roshar)
# ──────────────────────────────────────────────
export SAPPHIRE=0xff00BFFF                    # Pure Windrunner Sapphire
export SAPPHIRE_TRANSLUCENT=0xbb00BFFF        # Translucent — floating pills
export HONOR_GOLD=0xffFFD700                  # Radiance of the Oaths
export HONOR_GOLD_TRANSLUCENT=0x99FFD700
export SLATE=0xff708090                       # Rosharan Stone Surface
export DEEP_NIGHT=0xcc001a33                  # Dark Sapphire Depths (Bar BG)
export DEEP_SAPPHIRE=0xff003366               # Solid contrast for active items
export EMERALD=0xff50fa7b                     # Lifebound (Edgedancer)
export EMERALD_TRANSLUCENT=0x8850fa7b
export AMBER=0xffffb86c                       # Lightweaver's Warmth
export AMBER_TRANSLUCENT=0x99ffb86c
export CRIMSON=0xffed8796                     # Odium's Touch / Warning
export CRIMSON_TRANSLUCENT=0x99ed8796
export VIOLET=0xff8989ff                      # Shardblade Violet (Elsecaller)
export VIOLET_TRANSLUCENT=0x998989ff

# ──────────────────────────────────────────────
# SCADRIAL — RUIN  (Ati / Destruction)
# Palette: sulfurous ash, corroded bronze, volcanic obsidian,
#          deep maroon, poison green mist
# ──────────────────────────────────────────────
export RUIN_ASH=0xff3D2B1F                    # Ashmount Shadow (dark scorched brown)
export RUIN_ASH_TRANSLUCENT=0xbb3D2B1F
export RUIN_BRONZE=0xff7A4F35                 # Corroded Bronze — Inquisitor metal
export RUIN_BRONZE_TRANSLUCENT=0x997A4F35
export RUIN_OBSIDIAN=0xff1A0A0A               # Volcanic obsidian black
export RUIN_OBSIDIAN_TRANSLUCENT=0xbb1A0A0A
export RUIN_MAROON=0xff6B1A1A                 # Ruin's bloodline, deep maroon
export RUIN_MAROON_TRANSLUCENT=0x996B1A1A
export RUIN_MIST=0xff4A5C3A                   # Poison-green mist tinge
export RUIN_MIST_TRANSLUCENT=0x994A5C3A
export RUIN_SPIKE=0xff8B6914                  # Hemalurgic spike amber-gold
export RUIN_SPIKE_TRANSLUCENT=0x998B6914

# ──────────────────────────────────────────────
# SCADRIAL — PRESERVATION  (Leras / Survival & Stasis)
# Palette: icy blue-white mist, frosted silver, glacial teal,
#          pale lavender, faint gold of atium
# ──────────────────────────────────────────────
export PRES_MIST=0xffC8E8F5                   # Preservation Mist — pale icy blue
export PRES_MIST_TRANSLUCENT=0xaaC8E8F5
export PRES_SILVER=0xffB0C4DE                 # Frosted silver of the Well
export PRES_SILVER_TRANSLUCENT=0x99B0C4DE
export PRES_GLACIAL=0xff5DA8CC                # Glacial teal — deep Well of Ascension
export PRES_GLACIAL_TRANSLUCENT=0xbb5DA8CC
export PRES_LAVENDER=0xffC3AEE8               # Pale lavender — Preservation's calm
export PRES_LAVENDER_TRANSLUCENT=0x99C3AEE8
export PRES_ATIUM=0xffE8D5A0                  # Atium pale gold — stored power
export PRES_ATIUM_TRANSLUCENT=0x99E8D5A0
export PRES_DEEP=0xff1A2A3A                   # Deep Well darkness — near-black blue
export PRES_DEEP_TRANSLUCENT=0xcc1A2A3A

# ──────────────────────────────────────────────
# SPREN — All Orders of Knights Radiant
# Each spren has a normal (solid) and translucent variant
# ──────────────────────────────────────────────

# Honorspren  (Windrunners — Kaladin, Order of Wind)
export SPREN_HONOR=0xff00A8E8                 # Pure sky blue of Honorspren form
export SPREN_HONOR_T=0xbb00A8E8

# Cryptic / Pattern  (Lightweavers — Shallan, living lie)
export SPREN_CRYPTIC=0xffDA70D6               # Orchid-violet fractal shimmer
export SPREN_CRYPTIC_T=0xbbDA70D6

# Cultivationspren  (Edgedancers — Lift, growth & memory)
export SPREN_CULTIVATION=0xff3CB371           # Deep viridian-green
export SPREN_CULTIVATION_T=0xbb3CB371

# Mistspren  (Truthwatchers — rare, perception & truth)
export SPREN_MIST=0xff90EE90                  # Pale mist-green, soft glow
export SPREN_MIST_T=0xaa90EE90

# Inkspren  (Elsecallers — Jasnah, logic & transition)
export SPREN_INK=0xff4B0082                   # Deep indigo-ink, near black-violet
export SPREN_INK_T=0xbb4B0082

# Highspren  (Skybreakers — Szeth, law & justice)
export SPREN_HIGH=0xffF5F5DC                  # Pale bone/beige — cold law, no warmth
export SPREN_HIGH_T=0xaaF5F5DC

# Ashspren  (Dustbringers — Malata, entropy & fire)
export SPREN_ASH=0xffFF4500                   # Volcanic orange-red, embers
export SPREN_ASH_T=0xbbFF4500

# Peakspren  (Stonewards — Taln, endurance & stone)
export SPREN_PEAK=0xff8B7355                  # Warm stone-tan/brown
export SPREN_PEAK_T=0x998B7355

# Willshaper Spren  (Willshapers — Venli, freedom & flexibility)
export SPREN_WILL=0xffE040FB                  # Electric amethyst / magenta-violet
export SPREN_WILL_T=0xbbE040FB

# Bondsmiths' Spren  (Dalinar — three unique godspren)
#   Stormfather  →  Stormcloud blue-grey
export SPREN_STORM=0xff607D8B                 # Storm-cloud slate blue-grey
export SPREN_STORM_T=0xaa607D8B
#   Nightwatcher →  Deep twilight teal
export SPREN_NIGHT=0xff006064                 # Nightwatcher deep teal
export SPREN_NIGHT_T=0xbb006064
#   Sibling       →  Warm crystal amber (tower-light)
export SPREN_SIBLING=0xffFFAB40               # Urithiru Tower crystal amber
export SPREN_SIBLING_T=0xbbFFAB40

# Gloryspren  (ambient — gold orbs of pure joy)
export SPREN_GLORY=0xffFFD700                 # Gold glory orbs
export SPREN_GLORY_T=0x99FFD700

# Painspren  (ambient — orange claws of suffering)
export SPREN_PAIN=0xffFF6B35                  # Orange-red pain-claws
export SPREN_PAIN_T=0xbbFF6B35

# Fearspren  (ambient — purple-grey tendrils)
export SPREN_FEAR=0xff9E6B9E                  # Muted dusty purple
export SPREN_FEAR_T=0xaa9E6B9E

# Logicspren  (ambient — tiny storm clouds)
export SPREN_LOGIC=0xffA8C5DA                 # Cool steel-blue
export SPREN_LOGIC_T=0xaaA8C5DA

# ──────────────────────────────────────────────
# FUNCTIONAL THEME MAPPINGS
# These are what sketchybarrc references directly
# ──────────────────────────────────────────────

# Bar & backgrounds
export BAR_COLOR=$DEEP_NIGHT
export ITEM_BG_COLOR=$DEEP_SAPPHIRE
export POPUP_BG_COLOR=$PRES_DEEP               # Preservation deep as popup bg

# Primary accents
export ACCENT_COLOR=$SAPPHIRE
export RADIANT_GOLD=$HONOR_GOLD
export RADIANT_PURPLE=$VIOLET
export RADIANT_SAPPHIRE=$SAPPHIRE
export RADIANT_SAPPHIRE_T=$SAPPHIRE_TRANSLUCENT

# Pill border defaults (normal vs translucent)
export PILL_BORDER=$SAPPHIRE_TRANSLUCENT       # Default pill border (Windrunner)
export PILL_BORDER_RUIN=$RUIN_BRONZE_TRANSLUCENT   # Ruin-themed pills
export PILL_BORDER_PRES=$PRES_GLACIAL_TRANSLUCENT  # Preservation-themed pills

# Status/alert colors
export RELOAD_COLOR=$RUIN_MAROON               # Reload = Ruin's touch
export WARN_COLOR=$SPREN_ASH                   # Warnings = Ashspren / Dustbringer
export OK_COLOR=$SPREN_CULTIVATION             # OK / alive = Cultivationspren

# Labels / icons
export LABEL_COLOR=$WHITE
export ICON_COLOR=$WHITE

# Music pill — Willshaper freedom energy
export MUSIC_ACCENT=$SPREN_WILL
export MUSIC_ACCENT_T=$SPREN_WILL_T

# System popup — Preservation tones
export SYS_ACCENT=$PRES_GLACIAL
export SYS_CPU_COLOR=$RUIN_SPIKE              # CPU heat = Hemalurgic spike
export SYS_RAM_COLOR=$PRES_ATIUM             # RAM = Atium reserve
export SYS_DISK_COLOR=$PRES_SILVER           # Disk = Frosted silver

# Network / Bluetooth — Highspren (law, order, precision)
export NET_ACCENT=$SPREN_HIGH
export NET_ACCENT_T=$SPREN_HIGH_T

# Battery — Preservation reserve
export BATT_ACCENT=$PRES_MIST
export BATT_ACCENT_T=$PRES_MIST_TRANSLUCENT

# Clock / Calendar — Sibling (Urithiru crystal amber)
export CLOCK_ACCENT=$SPREN_SIBLING
export CLOCK_ACCENT_T=$SPREN_SIBLING_T

# Notifications — Gloryspren gold
export NOTIF_ACCENT=$SPREN_GLORY
export NOTIF_ACCENT_T=$SPREN_GLORY_T

# Spaces — Stormfather (space = storm)
export SPACE_ACCENT=$SPREN_STORM
export SPACE_ACCENT_T=$SPREN_STORM_T

# Front App — Cryptic shimmer (lies & truths of app state)
export FRONTAPP_ACCENT=$SPREN_CRYPTIC
export FRONTAPP_ACCENT_T=$SPREN_CRYPTIC_T
