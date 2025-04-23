data:extend({{
	type = "recipe",
	category = "crafting",
	name = "rtc-steam-locomotive-recipe",
	enabled = false,
	--added storage tank and boiler to the recipe
	ingredients = {{type="item",name="iron-gear-wheel",amount=20},{type="item",name="steam-engine",amount=1},{type="item", name="steel-plate",amount=50},{type="item",name="boiler",amount=1}},{type="item",name="storage-tank",amount=1}}
	results = {{type = "item", name = "rtc-steam-locomotive-item", amount = 1}},
	energy_required =  16.5,
	show_amount_in_title = false,
	icon = SPRITE_PATH.."icon/steam-locomotive.png",
	icon_size = 64,
}})
