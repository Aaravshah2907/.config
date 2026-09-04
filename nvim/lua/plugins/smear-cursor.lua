return {
  "sphamba/smear-cursor.nvim",
  event = "VeryLazy",
  opts = {
    cursor_color = "#ffffff",
    never_draw_over_target = true,
    smear_insert_mode = false,
    min_vertical_distance_smear = 2,
    stiffness = 0.8,
    trailing_stiffness = 0.5,
    distance_stop_animating = 0.5,
  },
}
