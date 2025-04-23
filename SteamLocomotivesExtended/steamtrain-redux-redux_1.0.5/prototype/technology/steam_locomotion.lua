require("constants")
data:extend({
	{
		type = "technology",
		name = "rtc-steam-locomotion-technology",
		icon = SPRITE_PATH.."technology/steam-locomotion.png",
		icon_size = 512,
		icon_mipmaps = 4,
		effects = {
			{
				type = "unlock-recipe",
				recipe = "rtc-steam-locomotive-recipe"
			}
		},
		prerequisites = {"railway"},
		unit = {
			count = 10,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1}
			},
			time = 30
		},
		order = "e-g"
	}
})
