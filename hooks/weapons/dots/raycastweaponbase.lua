function DOTBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank)
	local result = DOTBulletBase.super.on_collision(self, col_ray, weapon_unit, user_unit, damage, blank, self.NO_BULLET_INPACT_SOUND)
	local hit_unit = col_ray.unit

	if hit_unit:character_damage() and hit_unit:character_damage().damage_dot and not hit_unit:character_damage():dead() then
		result = self:start_dot_damage(col_ray, weapon_unit, user_unit, self:_dot_data_by_weapon(weapon_unit))
	end

	return result
end

function DOTBulletBase:_dot_data_by_weapon(weapon_unit)
	if not alive(weapon_unit) then
		return nil
	end

	if weapon_unit:base()._ammo_data and weapon_unit:base()._ammo_data.dot_data then
		return managers.dot:create_dot_data(weapon_unit:base()._ammo_data.dot_data)
	elseif weapon_unit.base and weapon_unit:base()._name_id then
		local weapon_name_id = weapon_unit:base()._name_id

		if tweak_data.weapon[weapon_name_id] and tweak_data.weapon[weapon_name_id].dot_data then
			return managers.dot:create_dot_data(tweak_data.weapon[weapon_name_id].dot_data)
		end
	end

	return nil
end

function DOTBulletBase:start_dot_damage(col_ray, weapon_unit, user_unit, dot_data, weapon_id)
	dot_data = dot_data or self.DOT_DATA
	dot_data.hurt_animation = not dot_data.hurt_animation_chance or math.rand(1) < dot_data.hurt_animation_chance
	
	local flammable = nil
	local char_tweak = tweak_data.character[col_ray.unit:base()._tweak_table]
	flammable = char_tweak.flammable == nil and true or char_tweak.flammable
	local distance = 1000
	local hit_loc = col_ray.hit_position

	if hit_loc and user_unit and user_unit.position then
		distance = mvector3.distance(hit_loc, user_unit:position())
	end
	
	local dot_max_distance = dot_data.dot_trigger_max_distance
	local dot_trigger_chance = dot_data.dot_trigger_chance or 100

	local start_dot_damage_roll = math.random(1, 100)
	
	if dot_data.variant == "fire" then
		if not flammable then
			return
		end
	end

	if	start_dot_damage_roll <= dot_trigger_chance then
		if dot_max_distance then
			if dot_max_distance < distance then
				return
			end
		end
		managers.dot:add_doted_enemy(col_ray, col_ray.unit, TimerManager:game():time(), weapon_unit, dot_data, weapon_id)
	end
end

function DOTBulletBase:give_damage_dot(action_data)
	local col_ray = action_data.col_ray
	local defense_data = {}

	if col_ray and col_ray.unit and alive(col_ray.unit) and col_ray.unit:character_damage() then
		defense_data = col_ray.unit:character_damage():damage_dot(action_data)
	end

	return defense_data
end

FireBulletBase = FireBulletBase or class(DOTBulletBase)
FireBulletBase.VARIANT = "fire"

function FireBulletBase:play_impact_sound_and_effects(weapon_unit, col_ray, no_sound)
end

function FlameBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank)
	local hit_unit = col_ray.unit
	local play_impact_flesh = false

	if hit_unit:damage() and col_ray.body:extension() and col_ray.body:extension().damage then
		local sync_damage = not blank and hit_unit:id() ~= -1
		local network_damage = math.ceil(damage * 163.84)
		damage = network_damage / 163.84

		if sync_damage then
			local normal_vec_yaw, normal_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.normal, 128, 64)
			local dir_vec_yaw, dir_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.ray, 128, 64)

			managers.network:session():send_to_peers_synched("sync_body_damage_bullet", col_ray.unit:id() ~= -1 and col_ray.body or nil, user_unit:id() ~= -1 and user_unit or nil, normal_vec_yaw, normal_vec_pitch, col_ray.position, dir_vec_yaw, dir_vec_pitch, math.min(16384, network_damage))
		end

		local local_damage = not blank or hit_unit:id() == -1

		if local_damage then
			col_ray.body:extension().damage:damage_bullet(user_unit, col_ray.normal, col_ray.position, col_ray.ray, 1)
			col_ray.body:extension().damage:damage_damage(user_unit, col_ray.normal, col_ray.position, col_ray.ray, damage)

			if alive(weapon_unit) and weapon_unit:base().categories and weapon_unit:base():categories() then
				for _, category in ipairs(weapon_unit:base():categories()) do
					col_ray.body:extension().damage:damage_bullet_type(category, user_unit, col_ray.normal, col_ray.position, col_ray.ray, 1)
				end
			end
		end
	end

	local result = nil

	if hit_unit:character_damage() and hit_unit:character_damage().damage_fire then
		local is_alive = not hit_unit:character_damage():dead()
		result = self:give_fire_damage(col_ray, weapon_unit, user_unit, damage)
		
		local dot_data = self:_dot_data_by_weapon(weapon_unit)
		if hit_unit:character_damage() and hit_unit:character_damage().damage_dot and not hit_unit:character_damage():dead() and dot_data then
			result = self:start_dot_damage(col_ray, weapon_unit, user_unit, dot_data)
		end

		if result ~= "friendly_fire" then
			local is_dead = hit_unit:character_damage():dead()

			if weapon_unit:base()._ammo_data and weapon_unit:base()._ammo_data.push_units then
				local push_multiplier = self:_get_character_push_multiplier(weapon_unit, is_alive and is_dead)

				managers.game_play_central:physics_push(col_ray, push_multiplier)
			end
		else
			play_impact_flesh = false
		end
	elseif weapon_unit:base()._ammo_data and weapon_unit:base()._ammo_data.push_units then
		managers.game_play_central:physics_push(col_ray)
	end

	if play_impact_flesh then
		managers.game_play_central:play_impact_flesh({
			no_sound = true,
			col_ray = col_ray
		})
	end

	self:play_impact_sound_and_effects(weapon_unit, col_ray)

	return result
end

function FlameBulletBase:give_fire_damage(col_ray, weapon_unit, user_unit, damage, armor_piercing)
	local fire_dot_data = nil

	if weapon_unit.base and weapon_unit:base()._ammo_data and weapon_unit:base()._ammo_data.bullet_class == "FlameBulletBase" then
		if weapon_unit:base()._ammo_data.dot_data then else fire_dot_data = weapon_unit:base()._ammo_data.fire_dot_data end
	elseif weapon_unit.base and weapon_unit:base()._name_id then
		local weapon_name_id = weapon_unit:base()._name_id

		if tweak_data.weapon[weapon_name_id] and tweak_data.weapon[weapon_name_id].fire_dot_data then
			if weapon_unit:base().dot_data then else fire_dot_data = weapon_unit:base().fire_dot_data end
		end
	end

	local action_data = {
		variant = "fire",
		damage = damage,
		weapon_unit = weapon_unit,
		attacker_unit = user_unit,
		col_ray = col_ray,
		armor_piercing = armor_piercing,
		fire_dot_data = fire_dot_data
	}
	local defense_data = col_ray.unit:character_damage():damage_fire(action_data)

	return defense_data
end

function FlameBulletBase:start_dot_damage(col_ray, weapon_unit, user_unit, dot_data, weapon_id)
	dot_data = dot_data or self.DOT_DATA
	local hurt_animation = not dot_data.hurt_animation_chance or math.rand(1) < dot_data.hurt_animation_chance
	
	local flammable = nil
	local char_tweak = tweak_data.character[col_ray.unit:base()._tweak_table]
	flammable = char_tweak.flammable == nil and true or char_tweak.flammable
	local distance = 1000
	local hit_loc = col_ray.hit_position

	if hit_loc and user_unit and user_unit.position then
		distance = mvector3.distance(hit_loc, user_unit:position())
	end
	
	local dot_max_distance = dot_data.dot_trigger_max_distance
	local dot_trigger_chance = dot_data.dot_trigger_chance or 100

	local start_dot_damage_roll = math.random(1, 100)
	
	if dot_data.variant == "fire" then
		if not flammable then
			return
		end
	end

	if	start_dot_damage_roll <= dot_trigger_chance then
		if dot_max_distance then
			if dot_max_distance < distance then
				return
			end
		end
		managers.dot:add_doted_enemy(col_ray, col_ray.unit, TimerManager:game():time(), weapon_unit, dot_data, weapon_id)
	end
end

function FlameBulletBase:_dot_data_by_weapon(weapon_unit)
	if not alive(weapon_unit) then
		return nil
	end

	if weapon_unit:base()._ammo_data and weapon_unit:base()._ammo_data.dot_data then
		return managers.dot:create_dot_data(weapon_unit:base()._ammo_data.dot_data)
	elseif weapon_unit.base and weapon_unit:base()._name_id then
		local weapon_name_id = weapon_unit:base()._name_id

		if tweak_data.weapon[weapon_name_id] and tweak_data.weapon[weapon_name_id].dot_data then
			return managers.dot:create_dot_data(tweak_data.weapon[weapon_name_id].dot_data)
		end
	end

	return nil
end