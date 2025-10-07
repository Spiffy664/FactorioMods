data:extend({
    {
      type = "selection-tool",
      name = "ghosts-only-decon-planner",
      icon = "__base__/graphics/icons/deconstruction-planner.png",
      icon_size = 64,
      stack_size = 1,
      subgroup = "tool",
      order = "c[automated-construction]-c[ghosts-only-decon]",
  
      selection_color = { r = 0.5, g = 0.8, b = 1 },
      alt_selection_color = { r = 0.5, g = 0.8, b = 1 },
  
      selection_mode = { "any-entity" },
      alt_selection_mode = { "any-entity" },
  
      selection_cursor_box_type = "entity",
      alt_selection_cursor_box_type = "entity",
    }
  })
  