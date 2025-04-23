require("constants")

local wheels = {
	name = "rtc-steam-wheels",
	type = "car",
	effectivity = 0,
	consumption = "0kW",
	rotation_speed = 100,
	weight = 1e-5,
	braking_force = 1e-5,
	friction_force = 1e-5,
	energy_per_hit_point = 0,
	allow_passengers = false,
	flags = {"placeable-off-grid", "not-on-map"},
	render_layer = "lower-object-above-shadow",
	energy_source = {
		type = "void",
		emissions_per_minute = {},
		render_no_power_icon = false,
		render_no_network_icon = false
	},
	inventory_size = 0,
	collision_box = {{0,0},{0,0}},
	collision_mask = {layers = {}},
	max_health = 2147483648,
	healing_per_tick = 2147483648,
	animation = {
		name = "rtc-wheel-animation",
		type = "animation",
		direction_count = 256,
		frame_count = 12,
		height = 512,
		width = 512,
		scale = 0.525,
		shift = util.by_pixel(0, -19),
		lines_per_file=16,
		slice=16,
		animation_speed = 1.25,
		filenames = {
			SPRITE_PATH.."entity/steam-wheels/wheel_0.png",
			SPRITE_PATH.."entity/steam-wheels/wheel_1.png",
			SPRITE_PATH.."entity/steam-wheels/wheel_2.png",
			SPRITE_PATH.."entity/steam-wheels/wheel_3.png",
			SPRITE_PATH.."entity/steam-wheels/wheel_4.png",
			SPRITE_PATH.."entity/steam-wheels/wheel_5.png",
			SPRITE_PATH.."entity/steam-wheels/wheel_6.png",
			SPRITE_PATH.."entity/steam-wheels/wheel_7.png",
			SPRITE_PATH.."entity/steam-wheels/wheel_8.png",
			SPRITE_PATH.."entity/steam-wheels/wheel_9.png",
			SPRITE_PATH.."entity/steam-wheels/wheel_10.png",
			SPRITE_PATH.."entity/steam-wheels/wheel_11.png"
		}
	}
}

--holy FUCK this is stupid
local elevated_wheels = table.deepcopy(wheels)
elevated_wheels.name = "rtc-steam-wheels-elevated"
elevated_wheels.render_layer = "elevated-lower-object"

data:extend({wheels, elevated_wheels})
