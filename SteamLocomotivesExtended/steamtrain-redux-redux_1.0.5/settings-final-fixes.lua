if mods["Honk"] then
	local honk_group = data.raw["string-setting"]["honk-sound-locos-steam"].default_value
	if not string.find(honk_group, "rtc%-steam%-locomotive") then
		honk_group = honk_group .. ",rtc-steam-locomotive"
	end
	data.raw["string-setting"]["honk-sound-locos-steam"].default_value = honk_group
end
