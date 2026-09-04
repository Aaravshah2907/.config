return {
  "p00f/clangd_extensions.nvim",
  ft = { "c", "cpp" },
  opts = {
    inlay_hints = {
      inline = true,
      only_current_line = false,
      show_parameter_hints = true,
      parameter_hints_prefix = "← ",
      other_hints_prefix = "⇒ ",
    },
    ast = {
      role_icons = {
        type = "🄣",
        declaration = "🄓",
        expression = "🄔",
        statement = ";",
        specifier = "🄢",
        ["template argument"] = "🆃",
      },
    },
  },
}
