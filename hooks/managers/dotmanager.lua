function DOTManager:update(t, dt)
	local doted_units = self._doted_units
	local dot_info = nil

	for i = #doted_units, 1, -1 do
		dot_info = doted_units[i]

		if dot_info then
			for var_name, var_info in pairs(dot_info.variants) do

				if var_info.damage_table then
					local tick_period_modifier = 1
					if var_info.accelerate then
						local damage_remaining = self:damage_remaining_oryo(var_info)
						local unit_health = var_info.unit:character_damage():health()
						tick_period_modifier = (unit_health + damage_remaining) / unit_health
						-- log('tick_period_modifier: ' .. tick_period_modifier)
					end

					if var_info.dot_counter >= (var_info.dot_tick_period * var_info.tick_period_salt) / tick_period_modifier then
						var_info.dot_damage = var_info.damage_table[1][2]

						if var_info.lethal_hurt and ((not var_info.last_hurt_t) or (var_info.last_hurt_t and var_info.last_hurt_t + (var_info.hurt_period / (var_info.accelerate_hurt and tick_period_modifier or 1)) < t)) then
							var_info.hurt_animation = self:is_lethal_oryo(var_info)
							if var_info.hurt_animation then
								var_info.last_hurt_t = t 
							end
						else
							var_info.hurt_animation = false
						end

						local killed = self:_damage_dot(dot_info, var_info)

						if killed then
							break
						end

						var_info.damage_table[1][1] = var_info.damage_table[1][1] - 1
						if var_info.damage_table[1][1] <= 0 then
							table.remove(var_info.damage_table, 1)
						end

						var_info.dot_counter = var_info.dot_counter - (var_info.dot_tick_period * var_info.tick_period_salt)/tick_period_modifier
						var_info.tick_period_salt = math.lerp(0.9, 1.1, math.random())
					end

					if not var_info.damage_table[1] then
						self:_remove_variant(dot_info, var_name)

						if not next(dot_info.variants) then
							self:_remove_dot(dot_info, false)

							break
						end
					else
						var_info.dot_counter = var_info.dot_counter + dt
					end

				else
					var_info.dot_counter = var_info.dot_counter + dt

					if (var_info.dot_tick_period * var_info.tick_period_salt) <= var_info.dot_counter then
						var_info.dot_ticks_remaining = var_info.dot_ticks_remaining - 1
						var_info.dot_counter = var_info.dot_counter - (var_info.dot_tick_period * var_info.tick_period_salt)
						var_info.tick_period_salt = math.lerp(0.9, 1.1, math.random())
						local killed = self:_damage_dot(dot_info, var_info)

						if killed then
							break
						end
					end

					if var_info.dot_ticks_remaining <= 0 then
						self:_remove_variant(dot_info, var_name)

						if not next(dot_info.variants) then
							self:_remove_dot(dot_info, false)

							break
						end
					end
				end
			end
		end
	end
end


function DOTManager:damage_remaining_oryo(var_info)
	local damage_remaining = 0
	local damage_ext = var_info.unit:character_damage()
	if var_info.damage_table then
		for _, stack in pairs(var_info.damage_table) do
			damage_remaining = damage_remaining + stack[1] * damage_ext:get_real_damage_oryo(stack[2])
		end
	else
		damage_remaining = var_info.dot_ticks_remaining * damage_ext:get_real_damage_oryo(var_info.dot_damage)
	end
	return damage_remaining
end


function DOTManager:is_lethal_oryo(var_info)
	local damage_remaining = self:damage_remaining_oryo(var_info)

	if damage_remaining <= 0 then
		return false
	end

	local unit_health = var_info.unit:character_damage():health()
	if damage_remaining < unit_health then
		return false
	end

	return true
end


function DOTManager:_add_doted_enemy(data)
	local target_unit = data.unit
	local char_dmg_ext = target_unit:character_damage()

	if not char_dmg_ext or char_dmg_ext.dead and char_dmg_ext:dead() then
		if not char_dmg_ext then
			Application:error("[DOTManager:_add_doted_enemy] Unit has no 'character_damage' extension, can't add.", target_unit)
		else
			Application:error("[DOTManager:_add_doted_enemy] Unit is dead, can't add or update dot.", target_unit)
		end

		return nil, nil, false
	end

	local t = data.time_override or TimerManager:game():time()
	local unit_key = target_unit:key()
	local existing_dot_info = self._doted_units_lookup[unit_key]

	if existing_dot_info then
		local should_sync = true
		local existing_var_info = existing_dot_info.variants[data.dot_data.variant]

		if existing_var_info then
			should_sync = self:update_dot_info_oryo(existing_dot_info, existing_var_info, data, t, should_sync)
		else
			existing_var_info = self:_add_variant_data(existing_dot_info, data, t)

			self:check_achievemnts()
		end

		return existing_dot_info, existing_var_info, should_sync
	end

	if not char_dmg_ext.add_listener then
		Application:error(
				"[DOTManager:_add_doted_enemy] No listener functionality in 'character_damage' extension to listen for death event, can't add.",
				target_unit)

		return nil, nil, false
	end

	local destroy_listener_class = target_unit:base()
	destroy_listener_class = destroy_listener_class and destroy_listener_class.add_destroy_listener and
									 destroy_listener_class or target_unit:unit_data() or nil
	destroy_listener_class = destroy_listener_class and destroy_listener_class.add_destroy_listener and
									 destroy_listener_class or nil

	if not destroy_listener_class then
		Application:error(
				"[DOTManager:_add_doted_enemy] No 'base' or 'unit_data' extension, or no destroy listener functionality in either, can't add.",
				target_unit)

		return nil, nil, false
	end

	local new_dot_info = {
		unit = target_unit,
		unit_key = unit_key,
		death_listener_key = "doted_unit_died" .. tostring(unit_key),
		destroy_listener_key = "doted_unit_destroyed" .. tostring(unit_key),
		variants = {}
	}

	char_dmg_ext:add_listener(new_dot_info.death_listener_key, {"death"},
			callback(self, self, "_clbk_doted_unit_died", new_dot_info))
	destroy_listener_class:add_destroy_listener(new_dot_info.destroy_listener_key,
			callback(self, self, "_clbk_doted_unit_destroyed", new_dot_info))

	local var_info = self:_add_variant_data(new_dot_info, data, t)

	table.insert(self._doted_units, 1, new_dot_info)

	self._doted_units_lookup[unit_key] = new_dot_info

	self:check_achievemnts()

	return new_dot_info, var_info, true
end


function DOTManager:update_dot_info_oryo(existing_dot_info, existing_var_info, data, t, should_sync)
	local dot_data = data.dot_data

	if dot_data.dot_application_period then
		local weapon_key = data.weapon_unit:key()
		if not existing_var_info.weapons[weapon_key] then 
			existing_var_info.weapons[weapon_key] = {}
			existing_var_info.weapons[weapon_key].dot_applied_time = t
		end
		if existing_var_info.weapons[weapon_key].dot_applied_time + 
				dot_data.dot_application_period > t then
			return
		end
		existing_var_info.weapons[weapon_key].dot_applied_time = existing_var_info.weapons[weapon_key].dot_applied_time + dot_data.dot_application_period
	end

	self:update_damage_table_oryo(existing_var_info, data)

	existing_var_info.hurt_animation = existing_var_info.hurt_animation or dot_data.hurt_animation

	return should_sync
end


function DOTManager:update_damage_table_oryo(existing_var_info, data)
	local dot_data = data.dot_data
	local add_ticks = true
	local ticks = self:_calc_damage_ticks_oryo(data, add_ticks)

	if existing_var_info.dot_can_stack == "extend" then
		local damage = dot_data.dot_damage
		table.insert(existing_var_info.damage_table, {ticks, damage})
		-- log('damage_remaining: ' .. self:damage_remaining_oryo(existing_var_info))

	else
		if existing_var_info.damage_table[1][1] > ticks then
			existing_var_info.damage_table[1][1] = existing_var_info.damage_table[1][1] - ticks
			table.insert(existing_var_info.damage_table, 1, {ticks, existing_var_info.damage_table[1][2] + dot_data.dot_damage})
		else
			local damage = dot_data.dot_damage
			local stack = 1
			while ticks > 0 do
				existing_var_info.damage_table[stack] = existing_var_info.damage_table[stack] or {}
				existing_var_info.damage_table[stack][1] = existing_var_info.damage_table[stack][1] or ticks
				existing_var_info.damage_table[stack][2] = existing_var_info.damage_table[stack][2] and
				existing_var_info.damage_table[stack][2] + damage or damage
				ticks = ticks - existing_var_info.damage_table[stack][1]
				stack = stack + 1
			end
		end
		-- log('damage_remaining: ' .. self:damage_remaining_oryo(existing_var_info))
	end
end


function DOTManager:_add_variant_data(dot_info, data, t)
	t = t or data.time_override or TimerManager:game():time()
	local var_info = {}
	local dot_data = data.dot_data
	dot_info.variants[dot_data.variant] = var_info
	var_info.variant = dot_data.variant
	var_info.damage_class = dot_data.damage_class
	var_info.unit = data.unit
	var_info.last_weapon_id = data.weapon_id
	var_info.last_weapon_unit = data.weapon_unit
	var_info.last_attacker_unit = data.attacker_unit
	var_info.hurt_animation = data.hurt_animation
	var_info.apply_hurt_once = dot_data.apply_hurt_once
	var_info.lethal_hurt = dot_data.lethal_hurt
	var_info.hurt_period = 10
	var_info.dot_applied_time = t

	var_info.weapons = {}
	if dot_data.dot_application_period then
		local weapon_key = data.weapon_unit:key()
		var_info.weapons[weapon_key] = {}
		var_info.weapons[weapon_key].dot_applied_time = t
	end

	var_info.use_weapon_damage_falloff = dot_data.use_weapon_damage_falloff or var_info.use_weapon_damage_falloff or false

	var_info.dot_trigger_chance = dot_data.dot_trigger_chance or 1
	var_info.hurt_animation_chance = dot_data.hurt_animation_chance or 0
	var_info.dot_trigger_max_distance = dot_data.dot_trigger_max_distance
	var_info.dot_can_stack = dot_data.dot_can_stack
	var_info.dot_can_crit = dot_data.dot_can_crit

	-- Damage Variables
	var_info.dot_damage = dot_data.dot_damage

	-- Tick Period variables
	var_info.dot_tick_period = dot_data.dot_tick_period
	var_info.tick_period_salt = math.lerp(0.9, 1.1, math.random())
	var_info.accelerate = dot_data.accelerate

	if var_info.accelerate then
		var_info.accelerate_hurt = not var_info.unit:base():has_tag("tank")
	end

	-- Length variables
	var_info.dot_length = data.modified_length or dot_data.dot_length
	var_info.add_ticks = dot_data.add_ticks
	var_info.damage_ticks = self:_calc_damage_ticks_oryo(data)
	var_info.dot_damage_received_time = t
	var_info.dot_grace_period = dot_data.dot_grace_period
	var_info.dot_ticks_remaining = var_info.damage_ticks or math.max(1, math.floor(var_info.dot_length / var_info.dot_tick_period))
	var_info.dot_counter = var_info.dot_tick_period - math.max(var_info.dot_tick_period, var_info.dot_grace_period)

	-- Misc Variables
	if var_info.damage_ticks and dot_data.dot_can_stack then
		var_info.damage_table = {{var_info.damage_ticks, var_info.dot_damage}}
	end

	if data.on_added_clbk then
		data.on_added_clbk(dot_info, var_info, data)
	end

	var_info.on_removed_clbk = data.on_removed_clbk
	var_info.check_achivements_clbk = data.check_achivements_clbk

	self:_chk_local_updating(var_info)
end


function DOTManager:_calc_damage_ticks_oryo(data, add_ticks)
	local dot_data = data.dot_data
	local ticks = add_ticks and dot_data.add_ticks or dot_data.damage_ticks
	if ticks and dot_data.use_weapon_damage_falloff or dot_data.headshot_length_scale then
		local damage_ext = data.unit:character_damage()
		local weap_base = data.weapon_unit and data.weapon_unit:base()
		local modified_ticks
		local headshot = damage_ext:is_headshot_oryo(data.col_ray)

		if dot_data.use_weapon_damage_falloff and weap_base and weap_base.get_damage_falloff then
			modified_ticks = weap_base:get_damage_falloff(ticks, data.col_ray, data.attacker_unit)
		end

		if dot_data.headshot_length_scale and headshot then
			local headshot_multiplier = managers.player:upgrade_value("weapon", "passive_headshot_damage_multiplier", 1)
			modified_ticks = (modified_ticks or 1) * damage_ext._char_tweak.headshot_dmg_mul * headshot_multiplier
		end

		modified_ticks = math.ceil(modified_ticks)
		ticks = modified_ticks or dot_data.damage_ticks
		-- log('damage_ticks: ' .. ticks)
	end
	return ticks
end


function DOTManager:_damage_dot(dot_info, var_info)
	if not var_info.damage_class then
		return false
	end

	if not var_info.can_deal_damage then
		if var_info.apply_hurt_once then
			var_info.hurt_animation = false
		end

		return false
	end

	local damage_class = CoreSerialize.string_to_classtable(var_info.damage_class)

	if damage_class and damage_class.give_damage_dot then
		local col_ray = {
			unit = dot_info.unit
		}
		local weapon_unit = var_info.last_weapon_unit
		weapon_unit = alive(weapon_unit) and weapon_unit or nil
		local attacker = var_info.last_attacker_unit
		attacker = alive(attacker) and attacker or nil

		if attacker then
			local base_ext = attacker:base()

			if base_ext and base_ext.thrower_unit then
				attacker = base_ext:thrower_unit()
				attacker = alive(attacker) and attacker or nil
			end
		end

		-- <oryo
		local action_data = {
			dot_info = deep_clone(var_info),
			damage = var_info.dot_damage,
			dot_can_crit = var_info.dot_can_crit,
			weapon_unit = var_info.last_weapon_unit,
			attacker_unit = attacker,
			col_ray = col_ray,
			hurt_animation = var_info.hurt_animation,
			weapon_id = var_info.last_weapon_id
		}
		local result = damage_class:give_damage_dot(action_data)
		-- oryo>

		if result and result ~= "friendly_fire" then
			local base_ext = weapon_unit and weapon_unit:base()

			if base_ext and base_ext.thrower_unit and base_ext._check_achievements then
				local is_dead = result.type == "death"

				base_ext:_check_achievements(dot_info.unit, is_dead, result.damage_percent or 0, 1, is_dead and 1 or 0,
						var_info.variant)
			end
		end
		
		if var_info.apply_hurt_once then
			var_info.hurt_animation = false
		end
	elseif damage_class then
		Application:error("[DOTManager:_damage_dot] Class '" .. tostring(var_info.damage_class) ..
								  "' lacks 'give_damage_dot' function.")
	else
		Application:error("[DOTManager:_damage_dot] No class found with '" .. tostring(var_info.damage_class) .. "'.")
	end

	return not alive(dot_info.unit) or dot_info.unit:character_damage().dead and dot_info.unit:character_damage():dead()
end
