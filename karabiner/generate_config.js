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

const preservedRules = orig.profiles[0].complex_modifications.rules.filter(r => 
  preservedRuleDescs.includes(r.description)
);

// Helper for sublayer actions
function createSublayer(leaderKey, sublayerName, description, mappings) {
  const manipulators = [];

  // Target key actions (when sublayer variable is active)
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

    if (action.shell_command) {
      manip.to = [
        { shell_command: action.shell_command },
        { shell_command: "/opt/homebrew/bin/sketchybar --trigger hyper_sublayer_change SUBLAYER=OFF" }
      ];
    } else if (action.key_code) {
      const toObj = { key_code: action.key_code };
      if (action.modifiers) toObj.modifiers = action.modifiers;
      manip.to = [
        toObj,
        { shell_command: "/opt/homebrew/bin/sketchybar --trigger hyper_sublayer_change SUBLAYER=OFF" }
      ];
    }

    manipulators.push(manip);
  }

  // Leader key manipulator (activates sublayer variable when Hyper is held)
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
    to: [
      {
        set_variable: {
          name: "hyper_sublayer_" + sublayerName,
          value: 1
        }
      },
      {
        shell_command: "/opt/homebrew/bin/sketchybar --trigger hyper_sublayer_change SUBLAYER=" + leaderKey.toUpperCase()
      }
    ],
    to_after_key_up: [
      {
        set_variable: {
          name: "hyper_sublayer_" + sublayerName,
          value: 0
        }
      },
      {
        shell_command: "/opt/homebrew/bin/sketchybar --trigger hyper_sublayer_change SUBLAYER=OFF"
      }
    ]
  });

  return {
    description: description,
    manipulators: manipulators
  };
}

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
        to_after_key_up: [
          { set_variable: { name: "hyper_mode", value: 0 } }
        ],
        to_if_alone: [
          { key_code: "escape" }
        ]
      }
    ]
  },
  {
    description: "Hyper Key: Apple Internal Right Command (Hold: Hyper, Tap: Spotlight)",
    manipulators: [
      {
        type: "basic",
        conditions: [
          {
            type: "device_if",
            identifiers: [{ is_built_in_keyboard: true }]
          }
        ],
        from: {
          key_code: "right_command",
          modifiers: { optional: ["any"] }
        },
        to: [
          { set_variable: { name: "hyper_mode", value: 1 } }
        ],
        to_after_key_up: [
          { set_variable: { name: "hyper_mode", value: 0 } }
        ],
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
    description: "Hyper Key: Pebble Keyboard Right Ctrl (Hold: Hyper, Tap: Escape)",
    manipulators: [
      {
        type: "basic",
        conditions: [
          {
            type: "device_if",
            identifiers: [{ vendor_id: 1578, product_id: 16641 }]
          }
        ],
        from: {
          key_code: "right_control",
          modifiers: { optional: ["any"] }
        },
        to: [
          { set_variable: { name: "hyper_mode", value: 1 } }
        ],
        to_after_key_up: [
          { set_variable: { name: "hyper_mode", value: 0 } }
        ],
        to_if_alone: [
          { key_code: "escape" }
        ]
      }
    ]
  }
];

// 2. Sublayers
const sublayerO = createSublayer("o", "o", "Hyper Sublayer O (Open Applications)", {
  h: { shell_command: 'open -na "/Applications/Helium.app" --args --profile-directory="Default"' },
  t: { shell_command: 'open -na Ghostty' },
  v: { shell_command: 'open -a "VLC"' },
  c: { shell_command: 'open -a "Visual Studio Code"' },
  o: { shell_command: 'open -a "Obsidian"' },
  s: { shell_command: 'open -a "Spotify"' },
  f: { shell_command: 'open ~' },
  a: { shell_command: 'open -a "Activity Monitor"' }
});

const sublayerB = createSublayer("b", "b", "Hyper Sublayer B (Browse Web Jumps)", {
  g: { shell_command: 'open -na "/Applications/Helium.app" --args --profile-directory="Default" "https://github.com"' },
  c: { shell_command: 'open -na "/Applications/Helium.app" --args --profile-directory="Default" "https://codeforces.com"' },
  m: { shell_command: 'open -na "/Applications/Helium.app" --args --profile-directory="Default" "https://mail.google.com"' },
  y: { shell_command: 'open -na "/Applications/Helium.app" --args --profile-directory="Default" "https://youtube.com"' }
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
});

const sublayerC = createSublayer("c", "c", "Hyper Sublayer C (Scratchpads & Tools)", {
  t: { shell_command: 'open -na Ghostty --args --title="Quick Terminal" -e "zsh -l -c todo"' },
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
  sublayerO,
  sublayerB,
  sublayerS,
  sublayerT,
  sublayerC,
  directHyperNav
];

orig.profiles[0].complex_modifications.rules = newRules;

fs.writeFileSync('/Users/aaravshah2975/.config/karabiner/karabiner.json.new', JSON.stringify(orig, null, 4));
console.log('Successfully generated karabiner.json.new with ' + newRules.length + ' rules.');
