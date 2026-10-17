const fs = require('fs');

const orig = JSON.parse(fs.readFileSync('/Users/aaravshah2975/.config/karabiner/karabiner.json', 'utf8'));

// Identify rules to preserve
const preservedRuleDescs = [
  "Toggle AeroSpace (Option + ')",
  "Keybee device-specific mappings",
  "Application key shortcuts for toggle apps",
  "NumLock -> Keybee Cockpit",
  "Insert -> Cheat Sheet",
  "Middle button: Escape / Mission Control",
  "Button4: Back / Previous Space",
  "Button5: Forward / Next Space"
];

const seenDescs = new Set();
const preservedRules = orig.profiles[0].complex_modifications.rules.filter(r => {
  if (preservedRuleDescs.includes(r.description) && !seenDescs.has(r.description)) {
    seenDescs.add(r.description);
    return true;
  }
  return false;
});

const ALL_SUBLAYERS = ["o", "b", "s", "t", "c"];

// Helper for sublayer actions
function createSublayer(leaderKey, sublayerName, description, mappings, persistent = false) {
  const manipulators = [];

  // Target key actions (active whenever this sublayer variable == 1, whether Hyper is still held or released)
  for (const [key, action] of Object.entries(mappings)) {
    const manip = {
      type: "basic",
      conditions: [
        {
          type: "variable_if",
          name: "hyper_sublayer_" + sublayerName,
          value: 1
        }
      ],
      from: {
        key_code: key,
        modifiers: { optional: ["any"] }
      }
    };

    const toList = [];
    if (action.shell_command) {
      let cmd = action.shell_command;
      if (!persistent) {
        cmd += " ; /opt/homebrew/bin/sketchybar --trigger hyper_sublayer_change SUBLAYER=OFF";
      }
      toList.push({ shell_command: cmd });
    } else if (action.key_code) {
      const toObj = { key_code: action.key_code };
      if (action.modifiers) toObj.modifiers = action.modifiers;
      toList.push(toObj);
      if (!persistent) {
        toList.push({
          shell_command: "/opt/homebrew/bin/sketchybar --trigger hyper_sublayer_change SUBLAYER=OFF"
        });
      }
    }

    // For one-shot sublayers (apps, browse, system, tools), reset sublayer variable on execution
    if (!persistent) {
      toList.push({
        set_variable: {
          name: "hyper_sublayer_" + sublayerName,
          value: 0
        }
      });
    }

    manip.to = toList;
    manipulators.push(manip);
  }

  // Leader key manipulator (arms sublayer variable when Hyper is held; modal, does not reset on leader key release)
  const leaderTo = [
    {
      set_variable: {
        name: "hyper_sublayer_" + sublayerName,
        value: 1
      }
    }
  ];
  // Reset other sublayers when switching
  for (const other of ALL_SUBLAYERS) {
    if (other !== sublayerName) {
      leaderTo.push({
        set_variable: {
          name: "hyper_sublayer_" + other,
          value: 0
        }
      });
    }
  }
  leaderTo.push({
    shell_command: "/opt/homebrew/bin/sketchybar --trigger hyper_sublayer_change SUBLAYER=" + leaderKey.toUpperCase()
  });

  manipulators.push({
    type: "basic",
    conditions: [
      {
        type: "variable_if",
        name: "hyper_mode",
        value: 1
      }
    ],
    from: {
      key_code: leaderKey,
      modifiers: { optional: ["any"] }
    },
    to: leaderTo
  });

  return {
    description: description,
    manipulators: manipulators
  };
}

// Actions to execute when Hyper key is released (only resets hyper_mode, leaves armed modal sublayers active)
const hyperReleaseActions = [
  { set_variable: { name: "hyper_mode", value: 0 } },
  { set_variable: { name: "hyper_sublayer_t", value: 0 } }
];

// 1. Dual-Role Hyper Sources
const hyperSources = [
  {
    description: "Hyper Key: Caps Lock (Hold: Hyper, Tap: Escape)",
    manipulators: [
      {
        type: "basic",
        from: {
          key_code: "caps_lock",
          modifiers: { optional: ["any"] }
        },
        to: [
          { set_variable: { name: "hyper_mode", value: 1 } }
        ],
        to_after_key_up: hyperReleaseActions,
        to_if_alone: [
          { key_code: "escape" }
        ]
      }
    ]
  },
  {
    description: "Hyper Key: Right Command (Hold: Hyper, Tap: Spotlight)",
    manipulators: [
      {
        type: "basic",
        from: {
          key_code: "right_command",
          modifiers: { optional: ["any"] }
        },
        to: [
          { set_variable: { name: "hyper_mode", value: 1 } }
        ],
        to_after_key_up: hyperReleaseActions,
        to_if_alone: [
          {
            key_code: "spacebar",
            modifiers: ["left_command"]
          }
        ]
      }
    ]
  },
  {
    description: "Hyper Key: Right Ctrl (Hold: Hyper, Tap: Escape)",
    manipulators: [
      {
        type: "basic",
        from: {
          key_code: "right_control",
          modifiers: { optional: ["any"] }
        },
        to: [
          { set_variable: { name: "hyper_mode", value: 1 } }
        ],
        to_after_key_up: hyperReleaseActions,
        to_if_alone: [
          { key_code: "escape" }
        ]
      }
    ]
  }
];

// Cancel sublayers via Escape
const cancelSublayers = {
  description: "Cancel Sublayer Mode via Escape",
  manipulators: [
    ...ALL_SUBLAYERS.map(s => ({
      type: "basic",
      conditions: [{ type: "variable_if", name: "hyper_sublayer_" + s, value: 1 }],
      from: { key_code: "escape", modifiers: { optional: ["any"] } },
      to: [
        ...ALL_SUBLAYERS.map(sub => ({ set_variable: { name: "hyper_sublayer_" + sub, value: 0 } })),
        { shell_command: "/opt/homebrew/bin/sketchybar --trigger hyper_sublayer_change SUBLAYER=OFF" }
      ]
    }))
  ]
};

// 2. Sublayers
const sublayerO = createSublayer("o", "o", "Hyper Sublayer O (Open Applications)", {
  h: { shell_command: 'open -a "/Applications/Helium.app" && /opt/homebrew/bin/aerospace workspace B' },
  t: { shell_command: '/opt/homebrew/bin/aerospace workspace T && open -na Ghostty' },
  v: { shell_command: 'open -a "VLC" && /opt/homebrew/bin/aerospace workspace V' },
  c: { shell_command: 'open -a "Visual Studio Code" && /opt/homebrew/bin/aerospace workspace C' },
  o: { shell_command: 'open -a "Obsidian" && /opt/homebrew/bin/aerospace workspace O' },
  s: { shell_command: 'open -a "Spotify" && /opt/homebrew/bin/aerospace workspace S' },
  f: { shell_command: 'open ~ && /opt/homebrew/bin/aerospace workspace F' },
  a: { shell_command: 'open -a "Activity Monitor"' }
});

const sublayerB = createSublayer("b", "b", "Hyper Sublayer B (Browse Web Jumps)", {
  g: { shell_command: 'open -na "/Applications/Helium.app" --args --profile-directory="Default" "https://github.com" && /opt/homebrew/bin/aerospace workspace B' },
  c: { shell_command: 'open -na "/Applications/Helium.app" --args --profile-directory="Default" "https://codeforces.com" && /opt/homebrew/bin/aerospace workspace B' },
  m: { shell_command: 'open -na "/Applications/Helium.app" --args --profile-directory="Default" "https://mail.google.com" && /opt/homebrew/bin/aerospace workspace B' },
  y: { shell_command: 'open -na "/Applications/Helium.app" --args --profile-directory="Default" "https://youtube.com" && /opt/homebrew/bin/aerospace workspace B' }
});

const sublayerS = createSublayer("s", "s", "Hyper Sublayer S (System & Workspace Control)", {
  d: { shell_command: '~/.local/bin/toggle_dnd.sh' },
  x: { shell_command: '~/.local/bin/lock-screen.sh' },
  s: { shell_command: '~/.local/bin/study-mode' },
  p: { shell_command: '~/.local/bin/panic-mode' },
  o: { shell_command: 'screencapture -i -c' }
});

const sublayerT = createSublayer("t", "t", "Hyper Sublayer T (Tabs Navigation)", {
  h: { key_code: "left_arrow", modifiers: ["left_command", "left_option"] },
  l: { key_code: "right_arrow", modifiers: ["left_command", "left_option"] },
  w: { key_code: "w", modifiers: ["left_command"] },
  t: { key_code: "t", modifiers: ["left_command"] },
  r: { key_code: "r", modifiers: ["left_command", "left_shift"] },
  u: { key_code: "t", modifiers: ["left_command", "left_shift"] },
  d: { key_code: "i", modifiers: ["left_command", "left_option"] }
}, true);

const sublayerC = createSublayer("c", "c", "Hyper Sublayer C (Scratchpads & Tools)", {
  t: { shell_command: '/opt/homebrew/bin/aerospace workspace T && open -na Ghostty --args --title="Quick Terminal" -e "zsh -l -c todo"' },
  c: { shell_command: 'open -a Calculator' },
  f: { shell_command: '~/.local/bin/fv.sh' },
  semicolon: { shell_command: 'bash ~/.config/skhd/control_center.sh' }
});

// 3. Direct Hyper Navigation & Editing (when hyper_mode == 1)
const directHyperNav = {
  description: "Hyper Direct Navigation, Editing & Window Management",
  manipulators: [
    // Vim Navigation
    {
      type: "basic",
      conditions: [{ type: "variable_if", name: "hyper_mode", value: 1 }],
      from: { key_code: "h", modifiers: { optional: ["any"] } },
      to: [{ key_code: "left_arrow" }]
    },
    {
      type: "basic",
      conditions: [{ type: "variable_if", name: "hyper_mode", value: 1 }],
      from: { key_code: "j", modifiers: { optional: ["any"] } },
      to: [{ key_code: "down_arrow" }]
    },
    {
      type: "basic",
      conditions: [{ type: "variable_if", name: "hyper_mode", value: 1 }],
      from: { key_code: "k", modifiers: { optional: ["any"] } },
      to: [{ key_code: "up_arrow" }]
    },
    {
      type: "basic",
      conditions: [{ type: "variable_if", name: "hyper_mode", value: 1 }],
      from: { key_code: "l", modifiers: { optional: ["any"] } },
      to: [{ key_code: "right_arrow" }]
    },
    // Word navigation
    {
      type: "basic",
      conditions: [{ type: "variable_if", name: "hyper_mode", value: 1 }],
      from: { key_code: "y", modifiers: { optional: ["any"] } },
      to: [{ key_code: "left_arrow", modifiers: ["left_option"] }]
    },
    {
      type: "basic",
      conditions: [{ type: "variable_if", name: "hyper_mode", value: 1 }],
      from: { key_code: "p", modifiers: { optional: ["any"] } },
      to: [{ key_code: "right_arrow", modifiers: ["left_option"] }]
    },
    // Line start / end
    {
      type: "basic",
      conditions: [{ type: "variable_if", name: "hyper_mode", value: 1 }],
      from: { key_code: "0", modifiers: { optional: ["any"] } },
      to: [{ key_code: "left_arrow", modifiers: ["left_command"] }]
    },
    {
      type: "basic",
      conditions: [{ type: "variable_if", name: "hyper_mode", value: 1 }],
      from: { key_code: "4", modifiers: { mandatory: ["shift"], optional: ["any"] } },
      to: [{ key_code: "right_arrow", modifiers: ["left_command"] }]
    },
    // Editing
    {
      type: "basic",
      conditions: [{ type: "variable_if", name: "hyper_mode", value: 1 }],
      from: { key_code: "i", modifiers: { optional: ["any"] } },
      to: [{ key_code: "delete_or_backspace", modifiers: ["left_option"] }]
    },
    {
      type: "basic",
      conditions: [{ type: "variable_if", name: "hyper_mode", value: 1 }],
      from: { key_code: "period", modifiers: { optional: ["any"] } },
      to: [{ key_code: "delete_forward", modifiers: ["left_option"] }]
    },
    {
      type: "basic",
      conditions: [{ type: "variable_if", name: "hyper_mode", value: 1 }],
      from: { key_code: "m", modifiers: { mandatory: ["shift"], optional: ["caps_lock"] } },
      to: [{ key_code: "delete_or_backspace", modifiers: ["left_command"] }]
    },
    {
      type: "basic",
      conditions: [{ type: "variable_if", name: "hyper_mode", value: 1 }],
      from: { key_code: "m", modifiers: { optional: ["any"] } },
      to: [{ key_code: "k", modifiers: ["left_control"] }]
    },
    // AeroSpace Window Navigation
    {
      type: "basic",
      conditions: [{ type: "variable_if", name: "hyper_mode", value: 1 }],
      from: { key_code: "left_arrow", modifiers: { optional: ["any"] } },
      to: [{ shell_command: "/opt/homebrew/bin/aerospace workspace prev" }]
    },
    {
      type: "basic",
      conditions: [{ type: "variable_if", name: "hyper_mode", value: 1 }],
      from: { key_code: "right_arrow", modifiers: { optional: ["any"] } },
      to: [{ shell_command: "/opt/homebrew/bin/aerospace workspace next" }]
    },
    {
      type: "basic",
      conditions: [{ type: "variable_if", name: "hyper_mode", value: 1 }],
      from: { key_code: "q", modifiers: { optional: ["any"] } },
      to: [{ shell_command: "/opt/homebrew/bin/aerospace close" }]
    },
    // Shortcut Hub (Hyper + ? / Hyper + /)
    {
      type: "basic",
      conditions: [{ type: "variable_if", name: "hyper_mode", value: 1 }],
      from: { key_code: "slash", modifiers: { optional: ["any"] } },
      to: [{ shell_command: "/Users/aaravshah2975/.config/cheatsheet/show-cheatsheet.sh" }]
    }
  ]
};

// Combine all rules
const newRules = [
  ...preservedRules,
  ...hyperSources,
  cancelSublayers,
  sublayerO,
  sublayerB,
  sublayerS,
  sublayerT,
  sublayerC,
  directHyperNav
];

orig.profiles[0].complex_modifications.rules = newRules;

fs.writeFileSync('/Users/aaravshah2975/.config/karabiner/karabiner.json', JSON.stringify(orig, null, 4));
console.log('Successfully generated karabiner.json with ' + newRules.length + ' rules.');
