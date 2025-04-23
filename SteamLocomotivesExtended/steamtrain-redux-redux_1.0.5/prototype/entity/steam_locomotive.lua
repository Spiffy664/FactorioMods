require("constants")

local steam_locomotive = table.deepcopy(data.raw["locomotive"]["locomotive"])

local custom_smoke = table.deepcopy(data.raw["trivial-smoke"]["train-smoke"])
custom_smoke.name = "rtc-train-smoke"
custom_smoke.start_scale = 0.2
custom_smoke.end_scale = 3

local custom_properties = {
	name = "rtc-steam-locomotive",
	type = "locomotive",
	placeable_by = {
		item = "rtc-steam-locomotive-item",
		count = 1
	},
	weight = 2000,
	connection_distance = 3,
	
	-- SpiffyGPT added properties to the base steam locomotive mod 
    -- Add water and steam properties
    water_capacity = 5000,            -- Water capacity in units
    steam_capacity = 10000,           -- Steam capacity in units
    water_consumption_per_tick = 0.5, -- Water used per tick when running
    steam_consumption_per_tick = 1.0, -- Steam used per tick when running
    steam_power_multiplier = 1.5,     -- Power multiplier when using steam
    
    -- Add boiler properties
    boiler = {
        water_to_steam_ratio = 1.0,   -- How much water converts to how much steam
        heating_energy_required = 100, -- Energy required to convert water to steam
        max_temperature = 165,        -- Maximum temperature of boiler
        min_working_temperature = 100, -- Minimum temperature to produce steam
        temperature_increase_per_energy_unit = 0.1 -- Temperature increase per energy unit
    },
    
    -- Add pump properties
    pump = {
        max_flow_rate = 10,           -- Maximum water units pumped per second
        energy_required_per_unit = 0.2 -- Energy required to pump one unit of water
    },


	energy_source = {
		type = "burner",
		emissions_per_minute = { pollution = 10 },
		fuel_inventory_size = 3,
		render_no_network_icon = false,
		smoke = {
			{
				deviation = { 0.1, 0.1 },
				frequency = 100,
				name = "rtc-train-smoke",
				position = { 0, -2.1 },
				height = 1.7,
				starting_vertical_speed = 0.15,
				starting_vertical_speed_deviation = 0.1,
			}
		}
	},
	working_sound = {
		sound = {
			filename = SOUND_PATH .. "steam-engine-1.ogg",
			volume = 0.2,
			speed = 0.1,
			min_speed = 1 / 64
		},
		match_speed_to_activity = true,
		match_volume_to_activity = true,
		use_doppler_shift = true,
		activity_to_volume_modifiers = {
			multiplier = 15,
			offset = 0.975
		},
		activity_to_speed_modifiers = {
			multiplier = 11,
			offset = 0.667,
			maximum = 15
		}
		--[[idle_sound = {
			filename = SOUND_PATH.."idle.ogg",
			volume = 0.4
		},]]

	},
	flags = {
		"placeable-neutral",
		"player-creation",
		"placeable-off-grid"
	},
	icon = SPRITE_PATH .. "icon/steam-locomotive.png",
	icon_size = 64,
	icon_mipmaps = 4,
	pictures = {
		rotated = {
			layers = {
				--base image
				{
					direction_count = 256,
					line_length = 16,
					lines_per_file = 16,
					width = 512,
					height = 512,
					filename = SPRITE_PATH .. "entity/steam-locomotive/body/body.png",
					scale = 0.525,
					shift = util.by_pixel(0, -19)
				},
				--color mask
				{
					apply_runtime_tint = true,
					direction_count = 256,
					line_length = 16,
					lines_per_file = 16,
					width = 512,
					height = 512,
					blend_mode = "additive",
					filename = SPRITE_PATH .. "entity/steam-locomotive/body/mask.png",
					scale = 0.525,
					shift = util.by_pixel(0, -19)
				},
				--shadow
				{
					draw_as_shadow = true,
					direction_count = 256,
					line_length = 16,
					lines_per_file = 16,
					width = 512,
					height = 512,
					filename = SPRITE_PATH .. "entity/steam-locomotive/body/shadow.png",
					scale = 0.525,
					shift = util.by_pixel(-7, -19)
				}
			}
		},
	},
	minable = {
		mining_time = 1,
		result = "rtc-steam-locomotive-item"
	},
	front_light = {
		type = "oriented",
		minimum_darkness = 0.3,
		picture =
		{
			filename = "__core__/graphics/light-cone.png",
			priority = "extra-high",
			flags = { "light" },
			scale = 1.5,
			width = 200,
			height = 200
		},
		shift = { 0, -13.5 },
		size = 2,
		intensity = 0.6,
		color = { r = 1, g = 1, b = 1 }
	},
	front_light_pictures = {
		rotated = {
			draw_as_light = true,
			direction_count = 256,
			line_length = 16,
			lines_per_file = 16,
			width = 512,
			height = 512,
			blend_mode = "normal",
			filename = SPRITE_PATH .. "entity/steam-locomotive/body/lights.png",
			scale = 0.525,
			shift = util.by_pixel(0, -19)
		},
	}
}

if mods["elevated-rails"] then
	custom_properties.pictures.sloped = {
		layers = {
			--base image
			{
				direction_count = 128,
				line_length = 16,
				lines_per_file = 8,
				width = 512,
				height = 512,
				filename = SPRITE_PATH .. "entity/steam-locomotive/sloped/sloped.png",
				scale = 0.525,
				shift = util.by_pixel(0, -19)
			},
			--color mask
			{
				apply_runtime_tint = true,
				direction_count = 128,
				line_length = 16,
				lines_per_file = 8,
				width = 512,
				height = 512,
				blend_mode = "additive",
				filename = SPRITE_PATH .. "entity/steam-locomotive/sloped/mask_sloped.png",
				scale = 0.525,
				shift = util.by_pixel(0, -19)
			}
		}
	}

	custom_properties.front_light_pictures.sloped = {
		draw_as_light = true,
		direction_count = 128,
		line_length = 16,
		lines_per_file = 8,
		width = 512,
		height = 512,
		blend_mode = "normal",
		filename = SPRITE_PATH .. "entity/steam-locomotive/sloped/lights_sloped.png",
		scale = 0.525,
		shift = util.by_pixel(0, -19)
	}
end


for k, v in pairs(custom_properties) do
	steam_locomotive[k] = v
end

steam_locomotive.wheels.rotated.filenames = {
	SPRITE_PATH .. "entity/train-wheel/rotated/train-wheel-1.png",
	SPRITE_PATH .. "entity/train-wheel/rotated/train-wheel-2.png",
	SPRITE_PATH .. "entity/train-wheel/rotated/train-wheel-3.png",
	SPRITE_PATH .. "entity/train-wheel/rotated/train-wheel-4.png",
	SPRITE_PATH .. "entity/train-wheel/rotated/train-wheel-5.png",
	SPRITE_PATH .. "entity/train-wheel/rotated/train-wheel-6.png",
	SPRITE_PATH .. "entity/train-wheel/rotated/train-wheel-7.png",
	SPRITE_PATH .. "entity/train-wheel/rotated/train-wheel-8.png"
}

if mods["elevated-rails"] and steam_locomotive.wheels.sloped then
	steam_locomotive.wheels.sloped.filenames = {
		SPRITE_PATH .. "entity/train-wheel/sloped/train-wheel-sloped-1.png",
		SPRITE_PATH .. "entity/train-wheel/sloped/train-wheel-sloped-2.png",
		SPRITE_PATH .. "entity/train-wheel/sloped/train-wheel-sloped-3.png",
		SPRITE_PATH .. "entity/train-wheel/sloped/train-wheel-sloped-4.png",
		SPRITE_PATH .. "entity/train-wheel/sloped/train-wheel-sloped-5.png",
		SPRITE_PATH .. "entity/train-wheel/sloped/train-wheel-sloped-6.png",
		SPRITE_PATH .. "entity/train-wheel/sloped/train-wheel-sloped-7.png",
		SPRITE_PATH .. "entity/train-wheel/sloped/train-wheel-sloped-8.png"
	}
end
local placement_entity = table.deepcopy(steam_locomotive)

placement_entity.name = "rtc-steam-locomotive-placement-entity"
placement_entity.pictures.rotated = {
	direction_count = 256,
	line_length = 16,
	lines_per_file = 16,
	width = 512,
	height = 512,
	filename = SPRITE_PATH .. "entity/steam-locomotive/body/placement_entity.png",
	scale = 0.525,
	shift = util.by_pixel(0, -19)
}

---@diagnostic disable-next-line: assign-type-mismatch
data:extend({ custom_smoke, steam_locomotive, placement_entity })
