script.on_event(defines.events.on_player_selected_area, function(event)
    if event.item == "ghosts-only-decon-planner" then
        local player = game.get_player(event.player_index)
        for _, entity in pairs(event.entities) do
            if entity and entity.valid and entity.ghost_prototype then
                entity.destroy()
            end
        end
    end
end)

script.on_event(defines.events.on_player_alt_selected_area, function(event)
    if event.item == "ghosts-only-decon-planner" then
        local player = game.get_player(event.player_index)
        for _, entity in pairs(event.entities) do
            if entity and entity.valid and entity.ghost_prototype then
                entity.destroy()
            end
        end
    end
end)
