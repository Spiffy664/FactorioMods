-- Track GUI state for each player
local gui_data = {}

-- Initialize GUI data for a player
local function init_player_data(player_index)
  if not gui_data[player_index] then
    gui_data[player_index] = {
      ghosts_filter_active = false,
      window_position = { x = 100, y = 100 } -- Default position
    }
  end
end

-- control.lua

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
    local player = game.get_player(event.player_index)
    if not player then return end

    -- Check if player is holding a deconstruction planner
    local stack = player.cursor_stack
    if stack and stack.valid_for_read and stack.name == "deconstruction-planner" then
        create_custom_gui(player)
    else
        destroy_custom_gui(player)
    end
end)

function create_custom_gui(player)
    local gui = player.gui.screen
    if gui.decon_custom then return end -- already exists

    init_player_data(player.index)
    local data = gui_data[player.index]

    local frame = gui.add{
        type = "frame",
        name = "decon_custom",
        direction = "vertical"
    }

    -- Make the frame draggable
    frame.drag_target = frame

    -- Create title bar with close button
    local title_bar = frame.add{
        type = "flow",
        name = "title_bar",
        direction = "horizontal"
    }
    title_bar.drag_target = frame -- Make title bar draggable
    
    -- Add title label
    local title_label = title_bar.add{
        type = "label",
        name = "title_label",
        caption = "Ghost Filter",
        style = "frame_title"
    }
    title_label.style.horizontally_stretchable = true
    title_label.drag_target = frame -- Make title label draggable
    
    -- Add spacer to push close button to the right
    local spacer = title_bar.add{
        type = "empty-widget",
        name = "spacer"
    }
    spacer.style.horizontally_stretchable = true
    spacer.drag_target = frame -- Make spacer draggable
        
    -- Add close button
    local close_button = title_bar.add{
        type = "sprite-button",
        name = "close_button",
        sprite = "utility/close_black",
        style = "frame_action_button",
        tooltip = "Close"
    }
    -- Close button should NOT be draggable
    
    -- Create content area
    local content = frame.add{
        type = "flow",
        name = "content",
        direction = "vertical"
    }
    content.style.padding = 8

    -- Add the checkbox to content area
    content.add{
        type = "checkbox",
        name = "ghosts_only_checkbox",
        caption = "Ghosts only",
        state = data.ghosts_filter_active
    }
    
    -- Set the saved position
    frame.location = data.window_position
end

function destroy_custom_gui(player)
    if player.gui.screen.decon_custom then
        -- Save the current position before destroying
        init_player_data(player.index)
        local data = gui_data[player.index]
        data.window_position = player.gui.screen.decon_custom.location
        
        player.gui.screen.decon_custom.destroy()
    end
end

-- Handle GUI clicks (including close button)
script.on_event(defines.events.on_gui_click, function(event)
    local element = event.element
    if not element.valid then return end
    
    if element.name == "close_button" then
        local player = game.get_player(event.player_index)
        if player then
            destroy_custom_gui(player)
        end
    end
end)

-- Handle checkbox toggle
script.on_event(defines.events.on_gui_checked_state_changed, function(event)
    local element = event.element
    if not element.valid then return end

    if element.name == "ghosts_only_checkbox" then
        local player = game.get_player(event.player_index)
        if player then
            init_player_data(event.player_index)
            local data = gui_data[event.player_index]
            data.ghosts_filter_active = element.state
            
            player.print("Ghosts only is now: " .. tostring(element.state))
            -- store state in global if you need it for filtering
            global.ghosts_only = element.state
        end
    end
end)

-- Save window position when it's moved
script.on_event(defines.events.on_gui_location_changed, function(event)
    local element = event.element
    if not element.valid then return end
    
    if element.name == "decon_custom" then
        local player = game.get_player(event.player_index)
        if player then
            init_player_data(event.player_index)
            local data = gui_data[event.player_index]
            data.window_position = element.location
        end
    end
end)

-- Get all entity prototypes that can become ghosts
local function get_all_entity_names()
  local entity_names = {}
  for name, prototype in pairs(game.entity_prototypes) do
    if prototype.type ~= "tile-ghost" then
      table.insert(entity_names, name)
    end
  end
  return entity_names
end

-- Apply ghosts-only filter to deconstruction planner
local function apply_ghosts_filter(item)
  if not item or item.name ~= "deconstruction-planner" then return end
  
  -- Clear filters by setting to empty tables
  item.entity_filters = {}
  item.tile_filters = {}
  item.entity_filter_mode = defines.deconstruction_item.entity_filter_mode.blacklist
  item.tile_filter_mode = defines.deconstruction_item.tile_filter_mode.blacklist
end

-- Remove ghosts filter from deconstruction planner
local function remove_ghosts_filter(item)
  if not item or item.name ~= "deconstruction-planner" then return end
  
  -- Reset to default behavior with empty tables
  item.entity_filters = {}
  item.tile_filters = {}
  item.entity_filter_mode = defines.deconstruction_item.entity_filter_mode.blacklist
  item.tile_filter_mode = defines.deconstruction_item.tile_filter_mode.blacklist
  item.trees_and_rocks_only = false
  
  game.print("DEBUG: Filters cleared, back to default mode")
end

-- Recursively search for trees-and-rocks checkbox in GUI
local function find_trees_rocks_checkbox(element)
  if not element then return nil end
  
  if element.name == "trees-and-rocks-only" then
    return element
  end
  
  if element.children then
    for _, child in pairs(element.children) do
      local result = find_trees_rocks_checkbox(child)
      if result then return result end
    end
  end
  
  return nil
end

-- Add ghosts only checkbox to the deconstruction planner GUI
local function add_ghosts_checkbox(player)
  -- Search through all screen GUI elements
  for _, gui_element in pairs(player.gui.screen.children) do
    local trees_rocks_checkbox = find_trees_rocks_checkbox(gui_element)
    
    if trees_rocks_checkbox then
      local parent = trees_rocks_checkbox.parent
      if parent and not parent["ghosts-only-checkbox"] then
        -- Add our ghosts only checkbox
        local ghosts_checkbox = parent.add{
          type = "checkbox",
          name = "ghosts-only-checkbox",
          caption = "Ghosts only",
          state = false,
          tooltip = "Only deconstruct ghost entities"
        }
        
        -- Store reference for later updates
        init_player_data(player.index)
        game.print("DEBUG: Added ghosts checkbox to player " .. player.name) -- Debug message
        return true
      end
    end
  end
  
  game.print("DEBUG: Could not find trees-and-rocks checkbox for player " .. player.name) -- Debug message
  return false
end

-- Update checkbox state based on internal state
local function update_ghosts_checkbox(player)
  init_player_data(player.index)
  local data = gui_data[player.index]
  
  -- Find the checkbox in any open deconstruction planner GUI
  for _, gui_element in pairs(player.gui.screen.children) do
    local checkbox = find_gui_element_recursive(gui_element, "ghosts-only-checkbox")
    if checkbox then
      checkbox.state = data.ghosts_filter_active
    end
  end
end

-- Recursive function to find GUI element by name
local function find_gui_element_recursive(element, target_name)
  if not element then return nil end
  
  if element.name == target_name then
    return element
  end
  
  if element.children then
    for _, child in pairs(element.children) do
      local result = find_gui_element_recursive(child, target_name)
      if result then return result end
    end
  end
  
  return nil
end

-- Toggle the ghosts filter
local function toggle_ghosts_filter(player, new_state)
  init_player_data(player.index)
  local data = gui_data[player.index]
  
  -- Update state
  data.ghosts_filter_active = new_state
  
  -- Find the deconstruction planner item
  local item = player.cursor_stack
  if not item or not item.valid_for_read or item.name ~= "deconstruction-planner" then
    -- Try to find it in opened GUI
    if player.opened and player.opened.object_name == "LuaItemStack" and player.opened.name == "deconstruction-planner" then
      item = player.opened
    end
  end
  
  if not item or not item.valid_for_read or item.name ~= "deconstruction-planner" then
    player.print("No deconstruction planner found.")
    return
  end
  
  if new_state then
    apply_ghosts_filter(item)
    player.print("Ghosts filter activated")
  else
    remove_ghosts_filter(item)
    player.print("Ghosts filter deactivated")
  end
  
  -- Also uncheck trees/rocks if ghosts is enabled (they're mutually exclusive)
  if new_state then
    for _, gui_element in pairs(player.gui.screen.children) do
      local trees_checkbox = find_gui_element_recursive(gui_element, "trees-and-rocks-only")
      if trees_checkbox then
        trees_checkbox.state = false
      end
    end
  end
end

-- Event handler for GUI opening
script.on_event(defines.events.on_gui_opened, function(event)
  local player = game.players[event.player_index]
  
  game.print("DEBUG: GUI opened by " .. player.name .. ", type: " .. tostring(event.gui_type)) -- Debug message
  
  -- Check if it's a deconstruction planner GUI
  if event.gui_type == defines.gui_type.item and 
     player.opened and 
     player.opened.object_name == "LuaItemStack" and 
     player.opened.name == "deconstruction-planner" then
    
    game.print("DEBUG: Deconstruction planner GUI opened") -- Debug message
    
    -- Debug: Print entire GUI structure after a delay
    script.on_nth_tick(3, function()
      game.print("DEBUG: Exploring GUI structure...")
      for _, gui_element in pairs(player.gui.screen.children) do
        game.print("DEBUG: Found screen GUI: " .. (gui_element.name or "unnamed"))
        debug_gui_structure(gui_element, 0)
      end
      script.on_nth_tick(3, nil) -- Remove handler
    end)
    
    -- Try multiple times with delays to catch the GUI
    for i = 1, 5 do
      script.on_nth_tick(i, function()
        local success = add_ghosts_checkbox(player)
        if success then
          update_ghosts_checkbox(player)
          -- Remove all the tick handlers once we succeed
          for j = i, 5 do
            script.on_nth_tick(j, nil)
          end
        end
      end)
    end
  end
end)

-- Event handler for checkbox clicks
script.on_event(defines.events.on_gui_checked_state_changed, function(event)
  if event.element.name == "ghosts-only-checkbox" then
    local player = game.players[event.player_index]
    toggle_ghosts_filter(player, event.element.state)
  elseif event.element.name == "trees-and-rocks-only" then
    -- If trees/rocks is checked, uncheck ghosts
    if event.element.state then
      local player = game.players[event.player_index]
      init_player_data(event.player_index)
      gui_data[event.player_index].ghosts_filter_active = false
      update_ghosts_checkbox(player)
    end
  end
end)

-- Keyboard shortcut handler
script.on_event("toggle-ghosts-filter", function(event)
  local player = game.players[event.player_index]
  init_player_data(event.player_index)
  local data = gui_data[event.player_index]
  
  -- Toggle state
  local new_state = not data.ghosts_filter_active
  
  -- Find the deconstruction planner item
  local item = player.cursor_stack
  if item and item.valid_for_read and item.name == "deconstruction-planner" then
    toggle_ghosts_filter(player, new_state)
    return
  end
  
  -- Try main inventory
  local main_inventory = player.get_main_inventory()
  if main_inventory then
    for i = 1, #main_inventory do
      local stack = main_inventory[i]
      if stack.valid_for_read and stack.name == "deconstruction-planner" then
        player.cursor_stack.swap_stack(stack) -- Move to cursor
        toggle_ghosts_filter(player, new_state)
        return
      end
    end
  end
  
  player.print("No deconstruction planner found in cursor or inventory.")
end)

-- Event handler for checkbox state changes
script.on_event(defines.events.on_gui_checked_state_changed, function(event)
  if event.element.name == "ghosts-only-checkbox" then
    local player = game.players[event.player_index]
    toggle_ghosts_filter(player, event.element.state)
  elseif event.element.name == "trees-and-rocks-only" then
    -- If trees/rocks is checked, uncheck ghosts
    if event.element.state then
      local player = game.players[event.player_index]
      init_player_data(event.player_index)
      gui_data[event.player_index].ghosts_filter_active = false
      update_ghosts_checkbox(player)
    end
  end
end)

script.on_event(defines.events.on_marked_for_deconstruction, function(event)
  if not event.entity then return end
  
  local player = game.players[event.player_index]
  init_player_data(event.player_index)
  local data = gui_data[event.player_index]
  
  if data.ghosts_filter_active then
    -- If ghosts filter is active and this isn't a ghost, cancel the deconstruction
    if event.entity.type ~= "entity-ghost" and event.entity.type ~= "tile-ghost" then
      event.entity.cancel_deconstruction(player.force, player)
    end
  end
end)

-- Initialize for existing players when mod is added to existing save
script.on_init(function()
  for _, player in pairs(game.players) do
    init_player_data(player.index)
  end
end)

script.on_configuration_changed(function()
  for _, player in pairs(game.players) do
    init_player_data(player.index)
  end
end)