function WeaponDescription._get_mods_stats(name, base_stats, equipped_mods, bonus_stats)
	local mods_stats = {}
	local weapon_tweak = tweak_data.weapon[name]
	local modifier_stats = weapon_tweak.stats_modifiers

	for _, stat in pairs(WeaponDescription._stats_shown) do
		mods_stats[stat.name] = {
			index = 0,
			value = 0
		}
	end

	if equipped_mods then
		local tweak_stats = tweak_data.weapon.stats
		local tweak_factory = tweak_data.weapon.factory.parts
		local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(name)
		local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)

		if bonus_stats then
			for _, stat in pairs(WeaponDescription._stats_shown) do
				if stat.name == "magazine" then
					local ammo = mods_stats[stat.name].index
					ammo = ammo and ammo + (tweak_data.weapon[name].stats.extra_ammo or 0)
					mods_stats[stat.name].value = mods_stats[stat.name].value + (ammo and tweak_stats.extra_ammo[ammo] or 0)
				elseif stat.name == "totalammo" then
					local ammo = bonus_stats.total_ammo_mod
					mods_stats[stat.name].index = mods_stats[stat.name].index + (ammo or 0)
				else
					mods_stats[stat.name].index = mods_stats[stat.name].index + (bonus_stats[stat.name] or 0)
				end
			end
		end

		local part_data = nil

		for _, mod in ipairs(equipped_mods) do
			part_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(mod, factory_id, default_blueprint, equipped_mods) -- oryo: added equipped_mods

			if part_data then
				for _, stat in pairs(WeaponDescription._stats_shown) do
					if part_data.stats then
						if stat.name == "magazine" then
							local ammo = part_data.stats.extra_ammo
							ammo = ammo and ammo + (tweak_data.weapon[name].stats.extra_ammo or 0)
							mods_stats[stat.name].value = mods_stats[stat.name].value + (ammo and tweak_stats.extra_ammo[ammo] or 0)

							if part_data.custom_stats and part_data.custom_stats.ammo_offset then
								mods_stats[stat.name].value = mods_stats[stat.name].value + part_data.custom_stats.ammo_offset
							end
						elseif stat.name == "totalammo" then
							local ammo = part_data.stats.total_ammo_mod
							mods_stats[stat.name].index = mods_stats[stat.name].index + (ammo or 0)
						elseif stat.name == "reload" then
							if not base_stats[stat.name].index then
								debug_pause("weapon is missing reload stat", name)
							end

							mods_stats[stat.name].index = mods_stats[stat.name].index + (part_data.stats[stat.name] or 0)
						elseif stat.name == "fire_rate" then
							if part_data.custom_stats and part_data.custom_stats.fire_rate_multiplier then
								mods_stats[stat.name].value = mods_stats[stat.name].value + part_data.custom_stats.fire_rate_multiplier - 1
							end
						elseif stat.name == "damage" and part_data.custom_stats and part_data.custom_stats.launcher_grenade then
							local projectile_type = weapon_tweak.projectile_types and weapon_tweak.projectile_types[part_data.custom_stats.launcher_grenade] or
									                        part_data.custom_stats.launcher_grenade
							mods_stats[stat.name].projectile_type = projectile_type
						else
							mods_stats[stat.name].index = mods_stats[stat.name].index + (part_data.stats[stat.name] or 0)
						end
					end
				end

				-- <oryo
				if part_data.stats then
					if part_data.stats.magazine_add then
						mods_stats.magazine.value = mods_stats.magazine.value + math.floor(part_data.stats.magazine_add)
					end

					if part_data.stats.total_ammo_add then
						mods_stats.totalammo.value = mods_stats.totalammo.value + math.floor(part_data.stats.total_ammo_add)
					end
				end
				-- oryo>

			end
		end

		local index, stat_name = nil

		for _, stat in pairs(WeaponDescription._stats_shown) do
			stat_name = stat.name

			if mods_stats[stat.name].index and tweak_stats[stat_name] then
				if stat_name == "reload" then
					local chosen_index = math.clamp(base_stats[stat_name].index + mods_stats[stat_name].index, 1, #tweak_stats[stat_name])
					local reload_time = managers.blackmarket:get_reload_time(name)
					local mult = 1 / tweak_stats[stat_name][chosen_index]
					local mod_value = reload_time * mult
					mods_stats[stat.name].value = mod_value - base_stats[stat.name].value
				elseif stat.name == "damage" and mods_stats[stat.name].projectile_type then
					local mod = modifier_stats and modifier_stats[stat.name] or 1
					local projectile_tweak = tweak_data.projectiles[mods_stats[stat.name].projectile_type]
					mods_stats[stat.name].value = projectile_tweak.damage * mod - base_stats[stat.name].value
				else
					if stat_name == "concealment" then
						index = base_stats[stat.name].index + mods_stats[stat.name].index
					else
						index = math.clamp(base_stats[stat.name].index + mods_stats[stat.name].index, 1, #tweak_stats[stat_name])
					end

					mods_stats[stat.name].value = stat.index and index or tweak_stats[stat_name][index] * tweak_data.gui.stats_present_multiplier
					local offset = math.min(tweak_stats[stat_name][1], tweak_stats[stat_name][#tweak_stats[stat_name]]) *
							               tweak_data.gui.stats_present_multiplier

					if stat.offset then
						mods_stats[stat.name].value = mods_stats[stat.name].value - offset
					end

					if stat.revert then
						local max_stat = math.max(tweak_stats[stat_name][1], tweak_stats[stat_name][#tweak_stats[stat_name]]) *
								                 tweak_data.gui.stats_present_multiplier

						if stat.offset then
							max_stat = max_stat - offset
						end

						mods_stats[stat.name].value = max_stat - mods_stats[stat.name].value
					end

					if modifier_stats and modifier_stats[stat.name] then
						local mod = modifier_stats[stat.name]

						if stat.revert and not stat.index then
							local real_base_value = tweak_stats[stat_name][index]
							local modded_value = real_base_value * mod
							local offset = math.min(tweak_stats[stat_name][1], tweak_stats[stat_name][#tweak_stats[stat_name]])

							if stat.offset then
								modded_value = modded_value - offset
							end

							local max_stat = math.max(tweak_stats[stat_name][1], tweak_stats[stat_name][#tweak_stats[stat_name]])

							if stat.offset then
								max_stat = max_stat - offset
							end

							local new_value = (max_stat - modded_value) * tweak_data.gui.stats_present_multiplier

							if mod ~= 0 and (tweak_stats[stat_name][1] < modded_value or modded_value < tweak_stats[stat_name][#tweak_stats[stat_name]]) then
								new_value = (new_value + mods_stats[stat.name].value / mod) / 2
							end

							mods_stats[stat.name].value = new_value
						else
							mods_stats[stat.name].value = mods_stats[stat.name].value * mod
						end
					end

					if stat.percent then
						local max_stat = stat.index and #tweak_stats[stat.name] or
								                 math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) *
								                 tweak_data.gui.stats_present_multiplier

						if stat.offset then
							max_stat = max_stat - offset
						end

						local ratio = mods_stats[stat.name].value / max_stat
						mods_stats[stat.name].value = ratio * 100
					end

					mods_stats[stat.name].value = mods_stats[stat.name].value - base_stats[stat.name].value
				end
			elseif stat.name == "fire_rate" then
				mods_stats[stat.name].value = base_stats[stat.name].value * mods_stats[stat.name].value
			end
		end
	end

	return mods_stats
end


function WeaponDescription._get_weapon_mod_stats(mod_name, weapon_name, base_stats, mods_stats, equipped_mods)
	local tweak_stats = tweak_data.weapon.stats
	local tweak_factory = tweak_data.weapon.factory.parts
	local weapon_tweak = tweak_data.weapon[weapon_name]
	local modifier_stats = weapon_tweak.stats_modifiers
	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_name)
	local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)
	local part_data = nil
	local mod_stats = {
		chosen = {},
		equip = {}
	}

	for _, stat in pairs(WeaponDescription._stats_shown) do
		mod_stats.chosen[stat.name] = 0
		mod_stats.equip[stat.name] = 0
	end

	mod_stats.chosen.name = mod_name

	if equipped_mods then
		for _, mod in ipairs(equipped_mods) do
			if tweak_factory[mod] and tweak_factory[mod_name].type == tweak_factory[mod].type then
				mod_stats.equip.name = mod

				break
			end
		end
	end

	local curr_stats = base_stats
	local index, wanted_index = nil

	for _, mod in pairs(mod_stats) do
		part_data = nil

		if mod.name then
			if tweak_data.blackmarket.weapon_skins[mod.name] and tweak_data.blackmarket.weapon_skins[mod.name].bonus and
					tweak_data.economy.bonuses[tweak_data.blackmarket.weapon_skins[mod.name].bonus] then
				part_data = {
					stats = tweak_data.economy.bonuses[tweak_data.blackmarket.weapon_skins[mod.name].bonus].stats
				}
			else
				part_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(mod.name, factory_id, default_blueprint, equipped_mods) -- oryo: added equipped_mods
			end
		end

		for _, stat in pairs(WeaponDescription._stats_shown) do
			if part_data and part_data.stats then
				if stat.name == "magazine" then
					local ammo = part_data.stats.extra_ammo

					local addend = part_data.stats.magazine_add or 0 -- oryo

					ammo = ammo and ammo + (tweak_data.weapon[weapon_name].stats.extra_ammo or 0)
					mod[stat.name] = ammo and tweak_data.weapon.stats.extra_ammo[ammo] + addend or 0

					if part_data.custom_stats and part_data.custom_stats.ammo_offset then
						mod[stat.name] = mod[stat.name] + part_data.custom_stats.ammo_offset
					end
				elseif stat.name == "totalammo" then
					local chosen_index = part_data.stats.total_ammo_mod or 0

					local addend = part_data.stats.total_ammo_add or 0 -- oryo

					chosen_index = math.clamp(base_stats[stat.name].index + chosen_index, 1, #tweak_stats.total_ammo_mod)
					mod[stat.name] = base_stats[stat.name].value * tweak_stats.total_ammo_mod[chosen_index] + addend
				elseif stat.name == "reload" then
					local chosen_index = part_data.stats.reload or 0
					chosen_index = math.clamp(base_stats[stat.name].index + chosen_index, 1, #tweak_stats[stat.name])
					local reload_time = managers.blackmarket:get_reload_time(weapon_name)
					local mult = 1 / tweak_data.weapon.stats[stat.name][chosen_index]
					local mod_value = reload_time * mult
					mod[stat.name] = mod_value - base_stats[stat.name].value
				elseif stat.name == "fire_rate" then
					if part_data.custom_stats and part_data.custom_stats.fire_rate_multiplier then
						mod[stat.name] = base_stats[stat.name].value * (part_data.custom_stats.fire_rate_multiplier - 1)
					end
				elseif stat.name == "damage" and part_data.custom_stats and part_data.custom_stats.launcher_grenade then
					local projectile_type = weapon_tweak.projectile_types and weapon_tweak.projectile_types[part_data.custom_stats.launcher_grenade] or
							                        part_data.custom_stats.launcher_grenade
					local modifier = modifier_stats and modifier_stats[stat.name] or 1
					local projectile_tweak = tweak_data.projectiles[projectile_type]
					mod[stat.name] = projectile_tweak.damage * modifier - base_stats[stat.name].value
				else
					local chosen_index = part_data.stats[stat.name] or 0

					if tweak_stats[stat.name] then
						wanted_index = curr_stats[stat.name].index + chosen_index
						index = math.clamp(wanted_index, 1, #tweak_stats[stat.name])
						mod[stat.name] = stat.index and index or tweak_stats[stat.name][index] * tweak_data.gui.stats_present_multiplier

						if wanted_index ~= index then
							print(
									"[WeaponDescription._get_weapon_mod_stats] index went out of bound, estimating value", "mod_name", mod_name, "stat.name",
											stat.name, "wanted_index", wanted_index, "index", index
							)

							if stat.index then
								index = wanted_index
								mod[stat.name] = index
							elseif index ~= curr_stats[stat.name].index then
								local diff_value = tweak_stats[stat.name][index] - tweak_stats[stat.name][curr_stats[stat.name].index]
								local diff_index = index - curr_stats[stat.name].index
								local diff_ratio = diff_value / diff_index
								diff_index = wanted_index - index
								diff_value = diff_index * diff_ratio
								mod[stat.name] = mod[stat.name] + diff_value * tweak_data.gui.stats_present_multiplier
							end
						end

						local offset = math.min(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) *
								               tweak_data.gui.stats_present_multiplier

						if stat.offset then
							mod[stat.name] = mod[stat.name] - offset
						end

						if stat.revert then
							local max_stat = math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) *
									                 tweak_data.gui.stats_present_multiplier

							if stat.revert then
								max_stat = max_stat - offset
							end

							mod[stat.name] = max_stat - mod[stat.name]
						end

						if modifier_stats and modifier_stats[stat.name] then
							local mod_stat = modifier_stats[stat.name]

							if stat.revert and not stat.index then
								local real_base_value = tweak_stats[stat.name][index]
								local modded_value = real_base_value * mod_stat
								local offset = math.min(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]])

								if stat.offset then
									modded_value = modded_value - offset
								end

								local max_stat = math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]])

								if stat.offset then
									max_stat = max_stat - offset
								end

								local new_value = (max_stat - modded_value) * tweak_data.gui.stats_present_multiplier

								if mod_stat ~= 0 and (tweak_stats[stat.name][1] < modded_value or modded_value < tweak_stats[stat.name][#tweak_stats[stat.name]]) then
									new_value = (new_value + mod[stat.name] / mod_stat) / 2
								end

								mod[stat.name] = new_value
							else
								mod[stat.name] = mod[stat.name] * mod_stat
							end
						end

						if stat.percent then
							local max_stat = stat.index and #tweak_stats[stat.name] or
									                 math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) *
									                 tweak_data.gui.stats_present_multiplier

							if stat.offset then
								max_stat = max_stat - offset
							end

							local ratio = mod[stat.name] / max_stat
							mod[stat.name] = ratio * 100
						end

						mod[stat.name] = mod[stat.name] - curr_stats[stat.name].value
					end
				end
			end
		end
	end

	return mod_stats
end


function WeaponDescription.get_weapon_ammo_info(weapon_id, extra_ammo, total_ammo_mod, total_ammo_add) -- oryo: added total_ammo_add
	local weapon_tweak_data = tweak_data.weapon[weapon_id]
	local ammo_max_multiplier = managers.player:upgrade_value("player", "extra_ammo_multiplier", 1)
	local primary_category = weapon_tweak_data.categories[1]
	local category_skill_in_effect = false
	local category_multiplier = 1

	for _, category in ipairs(weapon_tweak_data.categories) do
		if managers.player:has_category_upgrade(category, "extra_ammo_multiplier") then
			category_multiplier = category_multiplier + managers.player:upgrade_value(category, "extra_ammo_multiplier", 1) - 1
			category_skill_in_effect = true
		end
	end

	ammo_max_multiplier = ammo_max_multiplier * category_multiplier

	if managers.player:has_category_upgrade("player", "add_armor_stat_skill_ammo_mul") then
		ammo_max_multiplier = ammo_max_multiplier * managers.player:body_armor_value("skill_ammo_mul", nil, 1)
	end

	local function get_ammo_max_per_clip(weapon_id)
		local function upgrade_blocked(category, upgrade)
			if not weapon_tweak_data.upgrade_blocks then
				return false
			end

			if not weapon_tweak_data.upgrade_blocks[category] then
				return false
			end

			return table.contains(weapon_tweak_data.upgrade_blocks[category], upgrade)
		end


		local clip_base = weapon_tweak_data.CLIP_AMMO_MAX
		local clip_mod = extra_ammo and tweak_data.weapon.stats.extra_ammo[extra_ammo] or 0
		local clip_skill = managers.player:upgrade_value(weapon_id, "clip_ammo_increase")

		if not upgrade_blocked("weapon", "clip_ammo_increase") then
			clip_skill = clip_skill + managers.player:upgrade_value("weapon", "clip_ammo_increase", 0)
		end

		for _, category in ipairs(weapon_tweak_data.categories) do
			if not upgrade_blocked(category, "clip_ammo_increase") then
				clip_skill = clip_skill + managers.player:upgrade_value(category, "clip_ammo_increase", 0)
			end
		end

		return clip_base + clip_mod + clip_skill
	end


	local ammo_max_per_clip = get_ammo_max_per_clip(weapon_id)
	local ammo_max = tweak_data.weapon[weapon_id].AMMO_MAX
	local ammo_from_mods = ammo_max * (total_ammo_mod and tweak_data.weapon.stats.total_ammo_mod[total_ammo_mod] or 0) + total_ammo_add -- oryo: added total_ammo_add
	ammo_max = (ammo_max + ammo_from_mods + managers.player:upgrade_value(weapon_id, "clip_amount_increase") * ammo_max_per_clip) *
			           ammo_max_multiplier
	ammo_max_per_clip = math.min(ammo_max_per_clip, ammo_max)
	local ammo_data = {
		base = tweak_data.weapon[weapon_id].AMMO_MAX,
		mod = ammo_from_mods + managers.player:upgrade_value(weapon_id, "clip_amount_increase") * ammo_max_per_clip
	}
	ammo_data.skill = (ammo_data.base + ammo_data.mod) * ammo_max_multiplier - ammo_data.base - ammo_data.mod
	ammo_data.skill_in_effect = managers.player:has_category_upgrade("player", "extra_ammo_multiplier") or category_skill_in_effect or
			                            managers.player:has_category_upgrade("player", "add_armor_stat_skill_ammo_mul")

	return ammo_max_per_clip, ammo_max, ammo_data
end


function WeaponDescription._get_stats(name, category, slot, blueprint)
	local equipped_mods = nil
	local silencer = false
	local single_mod = false
	local auto_mod = false
	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(name)
	local blueprint = blueprint or slot and managers.blackmarket:get_weapon_blueprint(category, slot) or
			                  managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)
	local cosmetics = managers.blackmarket:get_weapon_cosmetics(category, slot)
	local bonus_stats = {}

	if cosmetics and cosmetics.id and cosmetics.bonus and not managers.job:is_current_job_competitive() and
			not managers.weapon_factory:has_perk("bonus", factory_id, blueprint) then
		bonus_stats = tweak_data:get_raw_value("economy", "bonuses", tweak_data.blackmarket.weapon_skins[cosmetics.id].bonus, "stats") or {}
	end

	if blueprint then
		equipped_mods = deep_clone(blueprint)
		local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(name)
		local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)

		if equipped_mods then
			silencer = managers.weapon_factory:has_perk("silencer", factory_id, equipped_mods)
			single_mod = managers.weapon_factory:has_perk("fire_mode_single", factory_id, equipped_mods)
			auto_mod = managers.weapon_factory:has_perk("fire_mode_auto", factory_id, equipped_mods)
		end
	end

	local base_stats = WeaponDescription._get_base_stats(name)
	local mods_stats = WeaponDescription._get_mods_stats(name, base_stats, equipped_mods, bonus_stats)
	local skill_stats = WeaponDescription._get_skill_stats(
			name, category, slot, base_stats, mods_stats, silencer, single_mod, auto_mod, blueprint
	)
	local clip_ammo, max_ammo, ammo_data = WeaponDescription.get_weapon_ammo_info(
			name, tweak_data.weapon[name].stats.extra_ammo, base_stats.totalammo.index + mods_stats.totalammo.index, mods_stats.totalammo.value
	) -- oryo: added mods_stats.totalammo.value
	base_stats.totalammo.value = ammo_data.base
	mods_stats.totalammo.value = ammo_data.mod
	skill_stats.totalammo.value = ammo_data.skill
	skill_stats.totalammo.skill_in_effect = ammo_data.skill_in_effect
	local my_clip = base_stats.magazine.value + mods_stats.magazine.value + skill_stats.magazine.value

	if max_ammo < my_clip then
		mods_stats.magazine.value = mods_stats.magazine.value + max_ammo - my_clip
	end

	return base_stats, mods_stats, skill_stats
end

