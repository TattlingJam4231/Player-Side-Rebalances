function BlackMarketManager:modify_damage_falloff(damage_falloff, custom_stats) -- Player-Side Rebalances: bug fix, all instances of ".near_mul" and ".far_mul" have been changed to ".near_multiplier" and ".far_multiplier" respectively
	if damage_falloff and custom_stats then
		for part_id, stats in pairs(custom_stats) do
			if stats.falloff_override then
				damage_falloff.optimal_distance = stats.falloff_override.optimal_distance or damage_falloff.optimal_distance
				damage_falloff.optimal_range = stats.falloff_override.optimal_range or damage_falloff.optimal_range
				damage_falloff.near_falloff = stats.falloff_override.near_falloff or damage_falloff.near_falloff
				damage_falloff.far_falloff = stats.falloff_override.far_falloff or damage_falloff.far_falloff
				damage_falloff.near_multiplier = stats.falloff_override.near_multiplier or damage_falloff.near_multiplier
				damage_falloff.far_multiplier = stats.falloff_override.far_multiplier or damage_falloff.far_multiplier
			end

			if stats.optimal_distance_mul ~= nil then
				damage_falloff.optimal_distance = damage_falloff.optimal_distance * stats.optimal_distance_mul
			end

			if stats.optimal_range_mul ~= nil then
				damage_falloff.optimal_range = damage_falloff.optimal_range * stats.optimal_range_mul
			end

			if stats.near_falloff_mul ~= nil then
				damage_falloff.near_falloff = damage_falloff.near_falloff * stats.near_falloff_mul
			end

			if stats.far_falloff_mul ~= nil then
				damage_falloff.far_falloff = damage_falloff.far_falloff * stats.far_falloff_mul
			end

			if stats.falloff_mul ~= nil then
				damage_falloff.optimal_distance = damage_falloff.optimal_distance * stats.falloff_mul
				damage_falloff.optimal_range = damage_falloff.optimal_range * stats.falloff_mul
				damage_falloff.near_falloff = damage_falloff.near_falloff * stats.falloff_mul
				damage_falloff.far_falloff = damage_falloff.far_falloff * stats.falloff_mul
			end

			if stats.near_damage_mul ~= nil then
				damage_falloff.near_multiplier = damage_falloff.near_multiplier * stats.near_damage_mul
			end

			if stats.far_damage_mul ~= nil then
				damage_falloff.far_multiplier = damage_falloff.far_multiplier * stats.far_damage_mul
			end

			if stats.falloff_damage_mul ~= nil then
				damage_falloff.near_multiplier = damage_falloff.near_multiplier * stats.falloff_damage_mul
				damage_falloff.far_multiplier = damage_falloff.far_multiplier * stats.falloff_damage_mul
			end

			if stats.damage_near_mul ~= nil then
				damage_falloff.optimal_range = damage_falloff.optimal_range * stats.damage_near_mul
			end

			if stats.damage_far_mul ~= nil then
				damage_falloff.far_falloff = damage_falloff.far_falloff * stats.damage_far_mul
			end
		end
	end
end