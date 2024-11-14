-- update 240: no longer needed?
-- oryo: fixed vanilla bug where "near_mul" and "far_mul" are expected but get "near_multiplier" and "far_multiplier" instead
local modify_damage_falloff_original = BlackMarketManager.modify_damage_falloff
function BlackMarketManager:modify_damage_falloff(damage_falloff, custom_stats)
	damage_falloff.near_mul = damage_falloff.near_multiplier
	damage_falloff.far_mul = damage_falloff.far_multiplier

	modify_damage_falloff_original(self, damage_falloff, custom_stats)

	damage_falloff.near_multiplier = damage_falloff.near_mul
	damage_falloff.far_multiplier = damage_falloff.far_mul
end
