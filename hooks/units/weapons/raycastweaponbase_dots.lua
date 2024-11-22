function DOTBulletBase:_dot_data_by_weapon(weapon_unit)
	local weap_base = alive(weapon_unit) and weapon_unit:base()
	local ammo_data = weap_base.ammo_data and weap_base:ammo_data()
	local dot_data_name = ammo_data and ammo_data.dot_data_name

	if not dot_data_name then
		local weapon_tweak_data = weap_base and weap_base.weapon_tweak_data and weap_base:weapon_tweak_data()
		dot_data_name = weapon_tweak_data and weapon_tweak_data.dot_data_name
	end

	if dot_data_name then
		return tweak_data.dot:get_dot_data(dot_data_name)
	end

	return nil
end

function DOTBulletBase:start_dot_damage(col_ray, weapon_unit, dot_data, weapon_id, user_unit)
	if not alive(col_ray.unit) then
		return
	end

	dot_data = dot_data or tweak_data.dot:get_dot_data(self.DOT_DATA_NAME)
	weapon_unit = alive(weapon_unit) and weapon_unit or nil
	user_unit = alive(user_unit) and user_unit or nil
	local hurt_animation = not dot_data.hurt_animation_chance or math.rand(1) < dot_data.hurt_animation_chance
	local modified_length = nil

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

        if dot_data.use_weapon_damage_falloff then
            local weap_base = weapon_unit and weapon_unit:base()

            if weap_base and weap_base.get_damage_falloff then
                modified_length = weap_base:get_damage_falloff(dot_data.dot_length, col_ray, user_unit)
            end
        end

        local data = {
            col_ray = col_ray,
            unit = col_ray.unit,
            dot_data = dot_data,
            hurt_animation = hurt_animation,
            modified_length = modified_length,
            weapon_id = weapon_id,
            weapon_unit = weapon_unit,
            attacker_unit = user_unit
        }

	    managers.dot:add_doted_enemy(data)
    end
end

function DOTBulletBase:give_damage_dot(action_data)
	local col_ray = action_data.col_ray

    action_data.variant = action_data.dot_info.variant or self.VARIANT

	local defense_data = nil
	local char_dmg_ext = col_ray and alive(col_ray.unit) and col_ray.unit:character_damage()

	if char_dmg_ext and char_dmg_ext.damage_dot then
		defense_data = char_dmg_ext:damage_dot(action_data)
	end

	return defense_data
end

function FlameBulletBase:start_dot_damage(col_ray, weapon_unit, dot_data, weapon_id, user_unit, defense_data)
	local target_unit = col_ray.unit

	if not alive(target_unit) then
		return
	end

	local target_base_ext = target_unit:base()
	local char_tweak = target_base_ext and target_base_ext.char_tweak and target_base_ext:char_tweak()
	local flammable = char_tweak and char_tweak.flammable ~= false
	local can_dot = flammable

	if not can_dot then
		return
	end

	can_dot = not dot_data.dot_trigger_chance or math.random() <= dot_data.dot_trigger_chance or false

	if not can_dot then
		return
	end

	local weapon = nil
	local attacker = alive(user_unit) and user_unit or nil

	if attacker then
		local base_ext = attacker:base()

		if base_ext and base_ext.thrower_unit then
			attacker = base_ext:thrower_unit()
			attacker = alive(attacker) and attacker or nil
			weapon = user_unit
		end
	end

	if dot_data.dot_trigger_max_distance then
		if not attacker then
			return
		end

		local distance = mvector3.distance(attacker:position(), target_unit:position())
		can_dot = distance <= dot_data.dot_trigger_max_distance
	end

	if not can_dot then
		return
	end

	weapon = weapon or alive(weapon_unit) and weapon_unit or nil

	if not weapon_id and weapon then
		local base_ext = weapon:base()
		weapon_id = base_ext and base_ext.get_name_id and base_ext:get_name_id()
	end

	local data = {
		col_ray = col_ray, -- oryo
		unit = col_ray.unit, -- oryo
		dot_data = dot_data,
		weapon_id = weapon_id,
		weapon_unit = weapon_unit,
		attacker_unit = user_unit
	}

	managers.fire:add_doted_enemy(data)

	if char_tweak and char_tweak.use_animation_on_fire_damage ~= false then
		local char_dmg_ext = target_unit:character_damage()

		if char_dmg_ext.get_last_time_unit_got_fire_damage and char_dmg_ext.force_hurt then
			local last_fire_t = char_dmg_ext:get_last_time_unit_got_fire_damage()
			local t = TimerManager:game():time()

			if not last_fire_t or t - last_fire_t > (char_tweak.fire_animation_cooldown or 1) then
				local damage_info = nil

				if type(defense_data) == "table" and defense_data.attack_data then
					damage_info = defense_data.attack_data
					damage_info.type = "fire_hurt"

					if damage_info.result then
						damage_info.result.type = "fire_hurt"
						damage_info.result.variant = dot_data.variant or self.VARIANT
					else
						damage_info.result = {
							type = "fire_hurt",
							variant = dot_data.variant or self.VARIANT
						}
					end
				else
					damage_info = {
						damage = 0,
						type = "fire_hurt",
						variant = dot_data.variant or self.VARIANT,
						col_ray = col_ray,
						result = {
							type = "fire_hurt",
							variant = dot_data.variant or self.VARIANT
						}
					}
				end

				char_dmg_ext:force_hurt(damage_info)
			end
		end
	end
end


function FlameBulletBase:give_damage_dot(action_data)
	local col_ray = action_data.col_ray

    action_data.variant = action_data.dot_info.variant or self.VARIANT

	local defense_data = nil
	local char_dmg_ext = col_ray and alive(col_ray.unit) and col_ray.unit:character_damage()

	if char_dmg_ext and char_dmg_ext.damage_dot then
		defense_data = char_dmg_ext:damage_dot(action_data)
	end

	return defense_data
end