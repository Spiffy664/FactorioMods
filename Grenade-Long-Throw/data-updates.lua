log(serpent.block(data.raw["capsule"]["grenade"]))
local grenade = data.raw["capsule"]["grenade"]
if grenade and grenade.capsule_action and grenade.capsule_action.attack_parameters then
  log("Old grenade range: " .. (grenade.capsule_action.attack_parameters.range or "nil"))
  grenade.capsule_action.attack_parameters.range = 3000  -- Increase throw distance
  log("New grenade range set to: " .. grenade.capsule_action.attack_parameters.range)
else
  log("Grenade or its attack_parameters not found.")
end