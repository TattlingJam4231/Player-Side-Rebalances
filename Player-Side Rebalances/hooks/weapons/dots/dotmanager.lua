function DOTManager:update_dot_info_oryo(dot_info, dot_damage_received_time, dot_data)
	if dot_info.damage_table and dot_data.damage_ticks then
		self:update_damage_table_oryo(dot_info, dot_data)

	elseif dot_info.scale_length and dot_data.scale_length then
		self:update_dot_length_oryo(dot_info, dot_damage_received_time, dot_data)

	elseif dot_info.reset_dot_length and dot_info.dot_damage_received_time + dot_info.dot_length < dot_damage_received_time + dot_data.dot_length then
		dot_info.dot_damage_received_time = dot_damage_received_time
		dot_info.dot_length = dot_data.dot_length

	end

	--update dot_tick_period
	if dot_info.scale_tick_period and dot_data.scale_tick_period then
		dot_info.dot_tick_period = math.max(dot_info.dot_tick_period - dot_data.scale_tick_period, dot_info.min_tick_period)
	elseif dot_info.dot_tick_period > dot_data.dot_tick_period then
		dot_info.dot_tick_period = dot_data.dot_tick_period
	end
	
	dot_info.hurt_animation = dot_info.hurt_animation or dot_data.hurt_animation
end

function DOTManager:update_damage_table_oryo(dot_info, dot_data)
	if dot_info.dot_can_stack == "extend" then
		table.insert(dot_info.damage_table, {dot_data.add_ticks or dot_data.damage_ticks, dot_data.dot_damage})

	else
		if dot_info.damage_table[1][1] > dot_data.damage_ticks then
			dot_info.damage_table[1][1] = dot_info.damage_table[1][1] - dot_data.damage_ticks
			table.insert(dot_info.damage_table, 1, {dot_data.damage_ticks, dot_info.damage_table[1][2] + dot_data.dot_damage})
		else
			local ticks = dot_data.damage_ticks
			local stack = 1
			while ticks > 0 do
				dot_info.damage_table[stack] = dot_info.damage_table[stack] or {}
				dot_info.damage_table[stack][1] = dot_info.damage_table[stack][1] or ticks
				dot_info.damage_table[stack][2] = dot_info.damage_table[stack][2] and dot_info.damage_table[stack][2] + dot_data.dot_damage or dot_data.dot_damage
				ticks =	ticks - dot_info.damage_table[stack][1] 
				stack = stack + 1
			end
		end
	end
end

function DOTManager:update_dot_length_oryo(dot_info, dot_damage_received_time, dot_data)
	local elapsed_time = (TimerManager:game():time() - dot_info.dot_damage_received_time)
	dot_info.dot_length = dot_info.dot_length - elapsed_time
	dot_info.dot_damage_received_time = dot_damage_received_time
	
	if dot_info.diminish_scale_length then
		if dot_info.diminish_scale_length and dot_info.diminish_scale_length <= dot_info.dot_length then
			dot_info.dot_length = dot_info.dot_length + (dot_data.scale_length * (dot_info.diminish_scale_length / (dot_info.dot_length + dot_data.scale_length)))
		else
			dot_info.dot_length = dot_info.dot_length + dot_data.scale_length
		end
		
	elseif dot_info.length_cap then
		dot_info.dot_length = math.min(dot_info.dot_length + dot_data.scale_length, dot_info.length_cap)
	else
		dot_info.dot_length = dot_info.dot_length + dot_data.scale_length
	end
end

function DOTManager:create_enemy_dot_info_oryo(col_ray, enemy_unit, dot_damage_received_time, weapon_unit, dot_data, weapon_id)
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
end

function DOTManager:play_effects_oryo(weapon_unit, col_ray)
	local bullet_tweak = self.id and (tweak_data.blackmarket.bullets[self.id] or {}) or {}
	local params = {
		col_ray = col_ray,
		no_sound = true,
		effect = bullet_tweak.effect,
		sound_switch_name = bullet_tweak.sound_switch_name,
		immediate = alive(weapon_unit) and weapon_unit:base().weapon_tweak_data and weapon_unit:base():weapon_tweak_data() and weapon_unit:base():weapon_tweak_data().rays ~= nil
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
	mvector3.set(position,unit:position())
	mvector3.set_z(position,math.lerp(position.z, unit:movement():m_head_pos().z, 0.8))

	return position
end

function DOTManager:update(t, dt)
	
	for index = #self._doted_enemies, 1, -1 do
		local dot_info = self._doted_enemies[index]
		local tick_period = math.floor(dot_info.dot_tick_period * 10 + 0.5) / 10

		local function clear_dot()
			if dot_info.variant == "fire" then
				self:_remove_flame_effects_from_doted_unit(dot_info.enemy_unit)
				self:_stop_burn_body_sound(dot_info.sound_source)
			end
			table.remove(self._doted_enemies, index)
		end

		if dot_info.damage_table then

			if dot_info.dot_counter >= tick_period then
				dot_info.dot_damage = dot_info.damage_table[1][2]
				
				if dot_info.variant == "bleed" then
					dot_info.col_ray.position = self:get_position_for_dot_effect_oryo(self:get_unit_oryo(dot_info.enemy_unit))
					self:play_effects_oryo(dot_info.weapon_unit, dot_info.col_ray)
				end

				self:_damage_dot(dot_info)

				dot_info.damage_table[1][1] = dot_info.damage_table[1][1] - 1
				if dot_info.damage_table[1][1] <= 0 then table.remove(dot_info.damage_table, 1) end

				dot_info.dot_counter = 0
			end

			if not dot_info.damage_table[1] or dot_info.enemy_unit:character_damage():dead() then
				clear_dot()
			else
				dot_info.dot_counter = dot_info.dot_counter + dt
			end

		else
			if dot_info.dot_counter >= tick_period then
				self:_damage_dot(dot_info)
				dot_info.dot_counter = 0
			end	
			
			if t > dot_info.dot_damage_received_time + dot_info.dot_length or dot_info.enemy_unit:character_damage():dead() then
				clear_dot()
			else
				dot_info.dot_counter = dot_info.dot_counter + dt
			end

		end
	end
end

function DOTManager:add_doted_enemy(col_ray, enemy_unit, dot_damage_received_time, weapon_unit, dot_data, weapon_id)
	local dot_info = self:_add_doted_enemy(col_ray, enemy_unit, dot_damage_received_time, weapon_unit, dot_data, weapon_id)
end

function DOTManager:sync_add_dot_damage(col_ray, enemy_unit, dot_damage_received_time, weapon_unit, dot_data)
	if enemy_unit then
		local t = TimerManager:game():time()

		self:_add_doted_enemy(col_ray, enemy_unit, t, weapon_unit, dot_data)
	end
end

function DOTManager:_add_doted_enemy(col_ray, enemy_unit, dot_damage_received_time, weapon_unit, dot_data, weapon_id)
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
end

function DOTManager:_damage_dot(dot_info)
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
end

function DOTManager:create_dot_data(dot_info)
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
end

-- Player-Side Rebalances: from firemanager

function DOTManager:_remove_flame_effects_from_doted_unit(enemy_unit)
	if self._doted_enemies then
		for _, dot_info in ipairs(self._doted_enemies) do
			if dot_info.fire_effects and dot_info.enemy_unit == enemy_unit then
				for __, fire_effect_id in ipairs(dot_info.fire_effects) do
					World:effect_manager():fade_kill(fire_effect_id)
				end
			end
		end
	end
end

function DOTManager:start_burn_body_sound(dot_info, delay)
	local sound_loop_burn_body = SoundDevice:create_source("FireBurnBody")

	sound_loop_burn_body:set_position(dot_info.enemy_unit:position())
	sound_loop_burn_body:post_event("burn_loop_body")

	dot_info.sound_source = sound_loop_burn_body

	if delay then
		managers.enemy:add_delayed_clbk("FireBurnBody", callback(self, self, "_stop_burn_body_sound", sound_loop_burn_body), TimerManager:game():time() + delay - 0.5)
	end
end

function DOTManager:_stop_burn_body_sound(sound_source)
	sound_source:post_event("burn_loop_body_stop")
	managers.enemy:add_delayed_clbk("FireBurnBodyFade", callback(self, self, "_release_sound_source", {
		sound_source = sound_source
	}), TimerManager:game():time() + 0.5)
end

function DOTManager:_release_sound_source(...)
end

local tmp_used_flame_objects = nil
function DOTManager:_start_enemy_fire_effect(dot_info)
	local num_objects = #tweak_data.fire.fire_bones
	local num_effects = math.random(3, num_objects)

	if not tmp_used_flame_objects then
		tmp_used_flame_objects = {}

		for _, effect in ipairs(tweak_data.fire.fire_bones) do
			table.insert(tmp_used_flame_objects, false)
		end
	end

	local idx = 1
	local effect_id = nil
	local effects_table = {}

	for i = 1, num_effects do
		while tmp_used_flame_objects[idx] do
			idx = math.random(1, num_objects)
		end

		local fire_variant = alive(dot_info.weapon_unit) and (tweak_data.weapon[dot_info.weapon_unit:base():get_name_id()] or tweak_data.weapon.amcar).fire_variant
		local effect_prefix = fire_variant and fire_variant .. "_" or ""
		local effect = tweak_data.fire.effects[effect_prefix .. "endless"][tweak_data.fire.effects_cost[i]]
		local bone = dot_info.enemy_unit:get_object(Idstring(tweak_data.fire.fire_bones[idx]))

		if bone then
			effect_id = World:effect_manager():spawn({
				effect = Idstring(effect),
				parent = bone
			})

			table.insert(effects_table, effect_id)
		end

		tmp_used_flame_objects[idx] = true
	end

	dot_info.fire_effects = effects_table

	for idx, _ in ipairs(tmp_used_flame_objects) do
		tmp_used_flame_objects[idx] = false
	end
end