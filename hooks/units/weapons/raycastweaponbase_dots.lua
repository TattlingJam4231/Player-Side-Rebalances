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