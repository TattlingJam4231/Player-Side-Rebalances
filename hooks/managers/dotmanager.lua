function DOTManager:update_dot_info_oryo(existing_dot_info, existing_var_info, data, t, should_sync)
    local dot_data = data.dot_data

	if existing_var_info.damage_table and dot_data.damage_ticks then
		self:update_damage_table_oryo(existing_var_info, dot_data)
	elseif existing_var_info.scale_length and dot_data.scale_length then
		self:update_dot_length_oryo(existing_var_info, dot_data, t)

	elseif existing_var_info.reset_dot_length and existing_var_info.dot_damage_received_time + existing_var_info.dot_length <
			t + dot_data.dot_length then
		existing_var_info.dot_damage_received_time = t
		existing_var_info.dot_length = dot_data.dot_length

	end

	-- update dot_tick_period
	if existing_var_info.scale_tick_period and dot_data.scale_tick_period then
		existing_var_info.dot_tick_period = math.max(existing_var_info.dot_tick_period - dot_data.scale_tick_period, existing_var_info.min_tick_period)
        existing_var_info.dot_ticks_remaining = dot_data.damage_ticks or math.max(1, math.floor(var_info.dot_length / var_info.dot_tick_period))
	elseif existing_var_info.dot_tick_period > dot_data.dot_tick_period then
		existing_var_info.dot_tick_period = dot_data.dot_tick_period
	end

	existing_var_info.hurt_animation = existing_var_info.hurt_animation or dot_data.hurt_animation

	--[[ _add_doted_enemy
    if existing_dot_info then ]]
	local is_stronger, should_update = self:_is_new_dot_stronger(existing_var_info, data, t)

	if is_stronger then
		self:_update_variant_override(existing_dot_info, existing_var_info, data, t)
	elseif should_update then
		self:_update_variant(existing_dot_info, existing_var_info, data, t)
	else
		should_sync = false

		self:_update_variant_attacker(existing_dot_info, existing_var_info, data)
	end

	return should_sync
	--[[ _add_doted_enemy
    if existing_dot_info then ]]
end

function DOTManager:update_damage_table_oryo(existing_var_info, dot_data)
	if existing_var_info.dot_can_stack == "extend" then
        local damage = dot_data.dot_damage
		table.insert(existing_var_info.damage_table, {dot_data.add_ticks or dot_data.damage_ticks, damage})

	else
		if existing_var_info.damage_table[1][1] > dot_data.damage_ticks then
			existing_var_info.damage_table[1][1] = existing_var_info.damage_table[1][1] - dot_data.damage_ticks
			table.insert(existing_var_info.damage_table, 1, {dot_data.damage_ticks, existing_var_info.damage_table[1][2] + dot_data.dot_damage})
		else
			local ticks = dot_data.damage_ticks
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
	end
end

function DOTManager:update_dot_length_oryo(existing_var_info, dot_data, t)
	local elapsed_time = (TimerManager:game():time() - existing_var_info.dot_damage_received_time)
	existing_var_info.dot_length = existing_var_info.dot_length - elapsed_time
	existing_var_info.dot_damage_received_time = t

	if existing_var_info.diminish_scale_length then
		if existing_var_info.diminish_scale_length and existing_var_info.diminish_scale_length <= existing_var_info.dot_length then
			existing_var_info.dot_length = existing_var_info.dot_length + (dot_data.scale_length *
					                               (existing_var_info.diminish_scale_length /
							                               (existing_var_info.dot_length + dot_data.scale_length)))
		else
			existing_var_info.dot_length = existing_var_info.dot_length + dot_data.scale_length
		end

	elseif existing_var_info.length_cap then
		existing_var_info.dot_length = math.min(existing_var_info.dot_length + dot_data.scale_length,
				existing_var_info.length_cap)
	else
		existing_var_info.dot_length = existing_var_info.dot_length + dot_data.scale_length
	end
end

function DOTManager:play_effects_oryo(weapon_unit, col_ray)
	local bullet_tweak = self.id and (tweak_data.blackmarket.bullets[self.id] or {}) or {}
	local params = {
		col_ray = col_ray,
		no_sound = true,
		effect = bullet_tweak.effect,
		sound_switch_name = bullet_tweak.sound_switch_name,
		immediate = alive(weapon_unit) and weapon_unit:base().weapon_tweak_data and weapon_unit:base():weapon_tweak_data() and
				weapon_unit:base():weapon_tweak_data().rays ~= nil
	}

	managers.game_play_central:play_impact_sound_and_effects(params)
end

function DOTManager:get_unit_oryo(_unit)
	local data_type = type(_unit)
	local unit = nil

	if data_type == 'number' then
		local peer = managers.network:session():peer(_unit)
		unit = peer:unit()
	else
		unit = _unit
	end

	return unit
end

function DOTManager:get_position_for_dot_effect_oryo(unit)
	local position = Vector3()
	mvector3.set(position, unit:position())
	mvector3.set_z(position, math.lerp(position.z, unit:movement():m_head_pos().z, 0.8))

	return position
end

function DOTManager:update(t, dt)
	local doted_units = self._doted_units
	local dot_info = nil

	for i = #doted_units, 1, -1 do
		dot_info = doted_units[i]

		local function clear_dot()
			if dot_info.variant == "fire" then
				self:_remove_flame_effects_from_doted_unit(dot_info.enemy_unit)
				self:_stop_burn_body_sound(dot_info.sound_source)
			end
			table.remove(self._doted_units, i)
			log("clear")
		end

		if dot_info then
			for var_name, var_info in pairs(dot_info.variants) do

				if var_info.damage_table then

					if var_info.dot_counter >= (var_info.dot_tick_period * var_info.tick_period_salt) then
						var_info.dot_damage = var_info.damage_table[1][2]

						if var_info.variant == "bleed" then
							var_info.col_ray.position = self:get_position_for_dot_effect_oryo(self:get_unit_oryo(var_info.enemy_unit))
							self:play_effects_oryo(var_info.weapon_unit, var_info.col_ray)
						end

						local killed = self:_damage_dot(dot_info, var_info)

						if killed then
							break
						end

						var_info.damage_table[1][1] = var_info.damage_table[1][1] - 1
						if var_info.damage_table[1][1] <= 0 then
							table.remove(var_info.damage_table, 1)
						end

						var_info.dot_counter = var_info.dot_counter - (var_info.dot_tick_period * var_info.tick_period_salt)
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

--[[ function DOTManager:create_enemy_dot_info_oryo(col_ray, enemy_unit, dot_damage_received_time, weapon_unit, dot_data, weapon_id)
	local dot_info = deep_clone(dot_data)
	
	dot_info.col_ray = col_ray or {unit = enemy_unit}
	dot_info.dot_counter = 0
	dot_info.enemy_unit = enemy_unit
	dot_info.dot_damage_received_time = dot_damage_received_time
	dot_info.weapon_unit = weapon_unit
	dot_info.weapon_id = weapon_id
	
	if dot_info.damage_decay and dot_info.decay_period then
		dot_info.dot_length = ((dot_info.dot_damage / dot_info.damage_decay) * dot_info.decay_period) + 0.1
		dot_info.decay_counter = 0
	end
	if dot_info.damage_ticks and dot_info.dot_can_stack then
		dot_info.damage_table = {
			{
				dot_info.damage_ticks,
				dot_info.dot_damage
			}
		}
	end
	
	table.insert(self._doted_enemies, dot_info)
	
	if dot_data.variant == "fire" then
		self:_start_enemy_fire_effect(dot_info)
		self:start_burn_body_sound(dot_info)
	end
	
	self:check_achievemnts(enemy_unit, dot_damage_received_time)
end ]]

--[[ function DOTManager:create_dot_data(dot_info)
	local dot_types = {
		poison = {
			damage_class = "PoisonBulletBase",
			dot_damage = 25,
			dot_length = 6,
			hurt_animation_chance = 1
		},
		fire = {
			damage_class = "FlameBulletBase",
			dot_damage = 10,
			dot_length = 3.1
		},
		bleed = {
			damage_class = "PoisonBulletBase",
			dot_damage = 40,
			damage_ticks = 10
		}
	}
	
	local dot_data = dot_types[dot_info.type]

	if dot_info.custom_data then
		local custom_data = dot_info.custom_data

		dot_data.use_weapon_damage_falloff = custom_data.use_weapon_damage_falloff or dot_data.use_weapon_damage_falloff or false
		
		dot_data.variant = dot_info.type
		dot_data.dot_trigger_chance = custom_data.dot_trigger_chance or 100
		dot_data.hurt_animation_chance = custom_data.hurt_animation_chance or 0
		dot_data.dot_trigger_max_distance = custom_data.dot_trigger_max_distance
		dot_data.dot_can_stack = custom_data.dot_can_stack
		dot_data.dot_can_crit = custom_data.dot_can_crit

		--Damage Variables
		dot_data.dot_damage = custom_data.damage and custom_data.damage/10 or custom_data.dot_damage or dot_data.dot_damage
		
		if custom_data.scale_damage then
			dot_data.scale_damage = custom_data.scale_damage/10
		end
		if custom_data.damage_cap then
			dot_data.damage_cap = custom_data.damage_cap/10
		end
		
		--Length variables
		dot_data.dot_length = custom_data.dot_length or dot_data.dot_length
		dot_data.damage_ticks = custom_data.damage_ticks
		dot_data.add_ticks = custom_data.add_ticks

		if custom_data.reset_dot_length == nil then
			dot_data.reset_dot_length = true
		end

		dot_data.scale_length = custom_data.scale_length
		dot_data.length_cap = custom_data.length_cap
		dot_data.diminish_scale_length = custom_data.diminish_scale_length
		
		--Tick Period variables
		dot_data.dot_tick_period = custom_data.dot_tick_period or 0.5
		dot_data.scale_tick_period = custom_data.scale_tick_period
		dot_data.min_tick_period = custom_data.min_tick_period or 0.1
	end
	
	return dot_data
end ]]

function DOTManager:_add_variant_data(dot_info, data, t)
	t = t or data.time_override or TimerManager:game():time()
	local var_info = {}
	local dot_data = data.dot_data
	dot_info.variants[dot_data.variant] = var_info
	var_info.variant = dot_data.variant
	var_info.damage_class = dot_data.damage_class
	var_info.last_weapon_id = data.weapon_id
	var_info.last_weapon_unit = data.weapon_unit
	var_info.last_attacker_unit = data.attacker_unit
	var_info.hurt_animation = data.hurt_animation
	var_info.apply_hurt_once = dot_data.apply_hurt_once
	var_info.dot_applied_time = t

	var_info.use_weapon_damage_falloff = dot_data.use_weapon_damage_falloff or var_info.use_weapon_damage_falloff or false

	var_info.dot_trigger_chance = dot_data.dot_trigger_chance or 100
	var_info.hurt_animation_chance = dot_data.hurt_animation_chance or 0
	var_info.dot_trigger_max_distance = dot_data.dot_trigger_max_distance
	var_info.dot_can_stack = dot_data.dot_can_stack
	var_info.dot_can_crit = dot_data.dot_can_crit

	-- Damage Variables
	var_info.dot_damage = dot_data.dot_damage

	if dot_data.scale_damage then
		var_info.scale_damage = dot_data.scale_damage
	end
	if dot_data.damage_cap then
		var_info.damage_cap = dot_data.damage_cap
	end

	-- Tick Period variables
	var_info.dot_tick_period = dot_data.dot_tick_period
	var_info.tick_period_salt = math.lerp(0.9, 1.1, math.random())
	dot_data.scale_tick_period = dot_data.scale_tick_period
	dot_data.min_tick_period = dot_data.min_tick_period or 0.1

	-- Length variables
	var_info.dot_length = data.modified_length or dot_data.dot_length
	var_info.damage_ticks = dot_data.damage_ticks
	var_info.add_ticks = dot_data.add_ticks
	var_info.dot_damage_received_time = t

	if dot_data.reset_dot_length == nil then
		var_info.reset_dot_length = true
	end

	var_info.scale_length = dot_data.scale_length
	var_info.length_cap = dot_data.length_cap
	var_info.diminish_scale_length = dot_data.diminish_scale_length

	var_info.dot_grace_period = dot_data.dot_grace_period
	var_info.dot_ticks_remaining = var_info.damage_ticks or math.max(1, math.floor(var_info.dot_length / var_info.dot_tick_period))
	var_info.dot_counter = var_info.dot_tick_period - math.max(var_info.dot_tick_period, var_info.dot_grace_period)
	--

	-- Misc Variables
	if dot_data.damage_decay and dot_data.decay_period then
		var_info.dot_length = ((dot_data.dot_damage / dot_data.damage_decay) * dot_data.decay_period) + 0.1
		var_info.decay_counter = 0
	end
	if dot_data.damage_ticks and dot_data.dot_can_stack then
		var_info.damage_table = {{dot_data.damage_ticks, var_info.dot_damage}}
	end

	if data.on_added_clbk then
		data.on_added_clbk(dot_info, var_info, data)
	end

	var_info.on_removed_clbk = data.on_removed_clbk
	var_info.check_achivements_clbk = data.check_achivements_clbk

	self:_chk_local_updating(var_info)
end

--[[ function DOTManager:_add_doted_enemy(col_ray, enemy_unit, dot_damage_received_time, weapon_unit, dot_data, weapon_id)
	local contains = false

	if self._doted_enemies then
		for _, dot_info in ipairs(self._doted_enemies) do
			if dot_info.enemy_unit == enemy_unit and dot_info.weapon_id == weapon_id and dot_info.variant == dot_data.variant then
				self:update_dot_info_oryo(dot_info, dot_damage_received_time, dot_data)
				contains = true
			end
		end

		if not contains then
			self:create_enemy_dot_info_oryo(col_ray, enemy_unit, dot_damage_received_time, weapon_unit, dot_data, weapon_id)
		end
	end
end ]]

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

--[[ function DOTManager:_damage_dot(dot_info)
	local action_data = deep_clone(dot_info)
	action_data.attacker_unit = managers.player:player_unit()
	action_data.damage = dot_info.dot_damage

	if dot_info.variant then
		if dot_info.variant == "poison" then
			local result = PoisonBulletBase:give_damage_dot(action_data)

			if result and alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().thrower_unit then
				local is_dead = result.type == "death"

				weapon_unit:base():_check_achievements(dot_info.enemy_unit, is_dead, result.damage_percent or 0, 1, is_dead and 1 or 0, dot_info.variant)
			end

			if dot_info.hurt_animation and dot_info.apply_hurt_once then
				dot_info.hurt_animation = false
			end
		else
			DOTBulletBase:give_damage_dot(action_data)
		end
	end
end ]]

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
			weapon_unit = var_info.last_weapon_unit,
			attacker_unit = attacker,
			col_ray = col_ray,
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
