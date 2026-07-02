return {
  "HiPhish/rainbow-delimiters.nvim",
  event = "VeryLazy",
  config = function()
    -- This plugin provides a custom module that we just need to load.
    -- It will automatically colorize parentheses, brackets, and braces
    -- according to their depth.
    
    local rainbow_delimiters = require("rainbow-delimiters")

    vim.g.rainbow_delimiters = {
      strategy = {
        [""] = rainbow_delimiters.strategy["global"],
        vim = rainbow_delimiters.strategy["local"],
      },
      query = {
        [""] = "rainbow-delimiters",
        lua = "rainbow-blocks",
      },
      -- Let's use nice Cosmere-fitting colors from our palette
      highlight = {
        "RainbowDelimiterRed",    -- Crimson (Odium)
        "RainbowDelimiterYellow", -- Gold (Honor)
        "RainbowDelimiterBlue",   -- Sapphire (Windrunner)
        "RainbowDelimiterOrange", -- Peach / Amber (Sibling)
        "RainbowDelimiterGreen",  -- Emerald (Lifebound)
        "RainbowDelimiterViolet", -- Amethyst (Willshaper)
        "RainbowDelimiterCyan",   -- Teal (Nightwatcher)
      },
    }
  end,
}
