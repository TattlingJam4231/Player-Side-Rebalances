function WeaponFactoryManager:_get_forbidden_parts(factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local forbidden = {}
	local override = self:_get_override_parts(factory_id, blueprint)

	for _, part_id in ipairs(blueprint) do
		if self:is_part_valid(part_id) then
			local part = self:get_part_data_oryo(part_id, factory_id, blueprint, override)

			if part.depends_on then
				local part_forbidden = true

				for _, other_part_id in ipairs(blueprint) do
					local other_part = self:get_part_data_oryo(other_part_id, factory_id, blueprint, override) -- Player-Side Rebalances: replaced _part_data function with own

					if part.depends_on == other_part.type then
						part_forbidden = false

						break
					end


					-- <Player-Side Rebalances
					if part.depends_on == other_part.name_id then
						part_forbidden = false

						break
					end
					-- Player-Side Rebalances>


				end

				if part_forbidden then
					forbidden[part_id] = part.depends_on
				end
			end

			if part.forbids then
				for _, forbidden_id in ipairs(part.forbids) do
					forbidden[forbidden_id] = part_id
				end
			end

			if part.adds then
				local add_forbidden = self:_get_forbidden_parts(factory_id, part.adds)

				for forbidden_id, part_id in pairs(add_forbidden) do
					forbidden[forbidden_id] = part_id
				end
			end
		else
			Application:error("[WeaponFactoryManager:_get_forbidden_parts] Part do not exist!", part_id, "factory_id", factory_id)

			forbidden[part_id] = part_id
		end
	end

	return forbidden
end

function WeaponFactoryManager:get_stats(factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)
	local override = self:_get_override_parts(factory_id, blueprint)
	local stats = {}
	for _, part_id in ipairs(blueprint) do
		if not forbidden[part_id] and factory.parts[part_id].stats then
			local part = self:get_part_data_oryo(part_id, factory_id, blueprint) -- Player-Side Rebalances: replaced _part_data function with own

			for stat_type, value in pairs(part.stats) do
				if type(value) == "number" then
					stats[stat_type] = stats[stat_type] or 0
					stats[stat_type] = stats[stat_type] + value
				elseif type(value) == "table" then
					stats[stat_type] = stats[stat_type] or {}

					for i = 1, #value do
						stats[stat_type][i] = stats[stat_type][i] or 0
						stats[stat_type][i] = stats[stat_type][i] + value[i]
					end
				end
			end
		end
	end

	return stats
end

function WeaponFactoryManager:get_part_data_by_part_id_from_weapon(part_id, factory_id, blueprint, equipped_mods)
	local override = self:_get_override_parts(factory_id, blueprint)

	return self:get_part_data_oryo(part_id, factory_id, equipped_mods, override) -- Player-Side Rebalances: replaced _part_data function with own
end

function WeaponFactoryManager:get_custom_stats_from_weapon(factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local t = {}

	for _, id in ipairs(self:get_assembled_blueprint(factory_id, blueprint)) do
		local part = self:get_part_data_oryo(id, factory_id, blueprint) -- Player-Side Rebalances: replaced _part_data function with own

		if part.custom_stats then
			t[id] = part.custom_stats
		end
	end

	return t
end

function WeaponFactoryManager:get_ammo_data_from_weapon(factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local t = {}
	local override = self:_get_override_parts(factory_id, blueprint)

	for _, id in ipairs(self:get_assembled_blueprint(factory_id, blueprint)) do
		if factory.parts[id].type == "ammo" then
			local part = self:get_part_data_oryo(id, factory_id, blueprint, override) -- Player-Side Rebalances: replaced _part_data function with own
			t = part.custom_stats
		end
	end

	return t
end

function WeaponFactoryManager:get_part_data_oryo(part_id, factory_id, equipped_mods, override)
	local part = deep_clone(self:_part_data(part_id, factory_id, override))
	if equipped_mods and part.overrides then
		for _, override in ipairs(part.overrides) do
			if override.depends_on and table.contains(equipped_mods, override.depends_on) then
				if override.stats then part.stats = override.stats end
				if override.custom_stats then part.custom_stats = override.custom_stats end
			end
		end
	end
	return part
end