return {
  "echasnovski/mini.ai",
  event = "VeryLazy",
  config = function()
    require("mini.ai").setup({
      n_lines = 500, -- Number of lines to search for object
      
      -- Custom textobjects
      custom_textobjects = nil,

      -- Define mappings. Use `''` (empty string) to disable one.
      mappings = {
        -- Main textobject prefixes
        around = "a",
        inside = "i",

        -- Next/last variants
        around_next = "an",
        inside_next = "in",
        around_last = "al",
        inside_last = "il",

        -- Move cursor to corresponding edge of `a` textobject
        goto_left = "g[",
        goto_right = "g]",
      },
    })
  end,
}
