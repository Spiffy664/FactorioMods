local WheelControl = require("script/handle_wheels.lua")

local WHEEL_UPDATE_TICK = 2
local CLEANUP_UPDATE_TICK = 600

local function is_locomotive_valid(i, v)
	if not v then
		table.remove(storage.locomotives, i)
		return false
	end
	if not v.locomotive or not v.locomotive.valid then
		table.remove(storage.locomotives, i)
		if v.wheels then
			v.wheels.base.destroy()
			v.wheels.elevated.destroy()
			v.wheels = nil
		end
		return false
	else
		return true
	end
end

local function on_tick(event)
	if event.tick % WHEEL_UPDATE_TICK > 0 then
		return
	end
	for i = 1, #storage.locomotives, 1 do
		local v = storage.locomotives[i]
		if not v then
			return
		end

		if is_locomotive_valid(i, v) then
			if not v.wheels or not v.wheels.base.valid or not v.wheels.elevated.valid then
				v.wheels = WheelControl:apply_wheels(v.locomotive)
			end
			WheelControl:update_wheel_position(v.locomotive, v.wheels)
		else
			if v.wheels and v.wheels.base and v.wheels.base.valid then
				v.wheels.base.destroy()
			end
			if v.wheels and v.wheels.elevated and v.wheels.elevated.valid then
				v.wheels.elevated.destroy()
			end
		end
	end
end

local function addToGlobal(locomotive)
	table.insert(storage.locomotives, {
		locomotive = locomotive,
		wheels = WheelControl:apply_wheels(locomotive)
	})
end

local function on_build(event)
	if (not event.entity or not event.entity.valid) then
		return
	end
	if (event.entity.name == 'rtc-steam-locomotive-placement-entity') then
		local force = game.forces.neutral
		if (event.player_index) then
			local player = game.get_player(event.player_index)
---@diagnostic disable-next-line: cast-local-type
			force = player and player.force or force
		end
		if (event.robot) then
			force = event.robot.force
		end
		local position = event.entity.position
		local orientation = event.entity.orientation
		local surface = event.entity.surface
		local quality = event.entity.quality
		event.entity.destroy()
		local locomotive = surface.create_entity({
			name = "rtc-steam-locomotive",
			position = position,
			orientation = orientation,
			force = force,
			quality = quality,
			raise_script_built = false
		})
		addToGlobal(locomotive)
	elseif (event.entity.name == 'rtc-steam-locomotive') then
		addToGlobal(event.entity)
	end
end


local function on_script_built(event)
	local entity = event.entity
	if entity and entity.name == 'rtc-steam-locomotive' then
		addToGlobal(entity)
	end
end


local function cleanup()
	local wheels = {}
	local elevated_wheels = {}
	local locomotives = {}

	for i,v in pairs(storage.locomotives) do
		wheels[v.wheels.base.unit_number] = true
		elevated_wheels[v.wheels.elevated.unit_number] = true
		locomotives[v.locomotive.unit_number] = true
	end

	for _, surface in pairs(game.surfaces) do
		for _, v in pairs(surface.find_entities_filtered({name={"rtc-steam-wheels","rtc-steam-wheels-elevated","rtc-steam-locomotive","rtc-steam-locomotive-placement-entity"}})) do
			if v and v.valid then
				if v.name == "rtc-steam-wheels" then
					if not wheels[v.unit_number] then
						v.destroy()
					end
				elseif v.name == "rtc-steam-wheels-elevated" then
					if not elevated_wheels[v.unit_number] then
						v.destroy()
					end
				elseif v.name == "rtc-steam-locomotive" then
					if not locomotives[v.unit_number] then
						addToGlobal(v)
					end
				elseif v.name == "rtc-steam-locomotive-placement-entity" then
					v.destroy()
				end
			end
		end
	end
end


local function on_init()
	if not storage then storage = {} end
	if not storage.locomotives then storage.locomotives = {} end
end

script.on_configuration_changed(on_init)
script.on_init(on_init)
--script.on_nth_tick(CLEANUP_UPDATE_TICK, cleanup)
script.on_event(defines.events.on_tick, on_tick)
script.on_event(defines.events.on_built_entity, on_build)
script.on_event(defines.events.on_robot_built_entity, on_build)
script.on_event(defines.events.script_raised_built, on_script_built)
