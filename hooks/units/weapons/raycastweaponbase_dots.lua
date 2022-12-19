function DOTBulletBase:_dot_data_by_weapon(weapon_unit)
	local weap_base = alive(weapon_unit) and weapon_unit:base()
	local ammo_data = weap_base.ammo_data and weap_base:ammo_data()
	local ammo_dot_data = ammo_data and ammo_data.dot_data

	if ammo_dot_data then
		return managers.dot:create_dot_data(ammo_dot_data)
	elseif weap_base._name_id then
		local weapon_name_id = weapon_unit:base()._name_id

		if tweak_data.weapon[weapon_name_id] and tweak_data.weapon[weapon_name_id].dot_data then
			return managers.dot:create_dot_data(tweak_data.weapon[weapon_name_id].dot_data)
		end
	end

	return nil
end

function DOTBulletBase:start_dot_damage(col_ray, weapon_unit, dot_data, weapon_id, user_unit)

	if not alive(col_ray.unit) then
		return
	end

	dot_data = dot_data or self.DOT_DATA
	weapon_unit = alive(weapon_unit) and weapon_unit or nil
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

		local dot_length = dot_data.dot_length
		if dot_data.use_weapon_damage_falloff then
			local weap_base = weapon_unit and weapon_unit:base()
	
			if weap_base and weap_base.get_damage_falloff then
				user_unit = alive(user_unit) and user_unit or nil
				dot_length = weap_base:get_damage_falloff(dot_length, col_ray, user_unit)
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

function FlameBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank, no_sound)
	local hit_unit = col_ray.unit
	user_unit = alive(user_unit) and user_unit or nil

	if user_unit and self:chk_friendly_fire(hit_unit, user_unit) then
		return "friendly_fire"
	end

	weapon_unit = alive(weapon_unit) and weapon_unit or nil
	local endurance_alive_chk = false

	if hit_unit:damage() then
		local body_dmg_ext = col_ray.body:extension() and col_ray.body:extension().damage

		if body_dmg_ext then
			local sync_damage = not blank and hit_unit:id() ~= -1
			local network_damage = math.ceil(damage * 163.84)
			local body_damage = network_damage / 163.84

			if sync_damage and managers.network:session() then
				local normal_vec_yaw, normal_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.normal, 128, 64)
				local dir_vec_yaw, dir_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.ray, 128, 64)

				managers.network:session():send_to_peers_synched("sync_body_damage_bullet", col_ray.unit:id() ~= -1 and col_ray.body or nil, user_unit and user_unit:id() ~= -1 and user_unit or nil, normal_vec_yaw, normal_vec_pitch, col_ray.position, dir_vec_yaw, dir_vec_pitch, math.min(16384, network_damage))
			end

			local local_damage = not blank or hit_unit:id() == -1

			if local_damage then
				endurance_alive_chk = true
				local weap_cats = weapon_unit and weapon_unit:base().categories and weapon_unit:base():categories()

				body_dmg_ext:damage_bullet(user_unit, col_ray.normal, col_ray.position, col_ray.ray, 1)

				if hit_unit:alive() then
					body_dmg_ext:damage_damage(user_unit, col_ray.normal, col_ray.position, col_ray.ray, body_damage)
				end

				if weap_cats and hit_unit:alive() then
					for _, category in ipairs(weap_cats) do
						body_dmg_ext:damage_bullet_type(category, user_unit, col_ray.normal, col_ray.position, col_ray.ray, 1)
					end
				end
			end
		end
	end

	if endurance_alive_chk and not hit_unit:alive() then
		return
	end

	local do_shotgun_push, result, do_push, push_mul = nil
	local hit_dmg_ext = hit_unit:character_damage()
	local play_impact_flesh = not hit_dmg_ext or not hit_dmg_ext._no_blood

	if not blank and weapon_unit then
		local weap_base = weapon_unit:base()

		if weap_base and weap_base.chk_shield_knock then
			weap_base:chk_shield_knock(hit_unit, col_ray, weapon_unit, user_unit, damage)
		end

		if hit_dmg_ext and hit_dmg_ext.damage_fire then
			local was_alive = not hit_dmg_ext:dead()
			local armor_piercing, knock_down, stagger, variant = nil

			if weap_base then
				armor_piercing = weap_base.has_armor_piercing and weap_base:has_armor_piercing()
				knock_down = weap_base.is_knock_down and weap_base:is_knock_down()
				stagger = weap_base.is_stagger and weap_base:is_stagger()
				variant = weap_base.variant and weap_base:variant()
			end

			result = self:give_fire_damage(col_ray, weapon_unit, user_unit, damage, armor_piercing, false, knock_down, stagger, variant)

			if result ~= "friendly_fire" then
				local ammo_data = weap_base and weap_base.ammo_data and weap_base:ammo_data()

				
				-- <Player-Side Rebalances
				local dot_data = self:_dot_data_by_weapon(weapon_unit)
				if hit_unit:character_damage() and hit_unit:character_damage().damage_dot and not hit_unit:character_damage():dead() and dot_data then
					result = self:start_dot_damage(col_ray, weapon_unit, user_unit, dot_data)
				end
				-- <Player-Side Rebalances


				if ammo_data and ammo_data.push_units then
					local has_died = hit_dmg_ext:dead()
					do_push = true
					push_mul = self:_get_character_push_multiplier(weapon_unit, was_alive and has_died)
				end

				if result and result.type == "death" and weap_base.should_shotgun_push and weap_base:should_shotgun_push() then
					do_shotgun_push = true
				end
			else
				play_impact_flesh = false
			end
		else
			local ammo_data = weap_base and weap_base.ammo_data and weap_base:ammo_data()
			do_push = ammo_data and ammo_data.push_units
		end
	elseif weapon_unit then
		local weap_base = weapon_unit:base()
		local ammo_data = weap_base and weap_base.ammo_data and weap_base:ammo_data()
		do_push = ammo_data and ammo_data.push_units
	end

	if do_push then
		managers.game_play_central:physics_push(col_ray, push_mul)
	end

	if do_shotgun_push then
		managers.game_play_central:do_shotgun_push(col_ray.unit, col_ray.position, col_ray.ray, col_ray.distance, user_unit)
	end

	if play_impact_flesh then
		managers.game_play_central:play_impact_flesh({
			col_ray = col_ray,
			no_sound = no_sound ~= false
		})
		self:play_impact_sound_and_effects(weapon_unit, col_ray, no_sound)
	end

	return result
end

function FlameBulletBase:give_fire_damage(col_ray, weapon_unit, user_unit, damage, armor_piercing, shield_knock, knock_down, stagger, variant)
	local fire_dot_data = nil
	local weap_base = weapon_unit:base()
	local ammo_data = weap_base and weap_base.ammo_data and weap_base:ammo_data()

	if ammo_data and ammo_data.bullet_class == "FlameBulletBase" then
		fire_dot_data = ammo_data.fire_dot_data
	else
		local weapon_tweak_data = weap_base and weap_base.weapon_tweak_data and weap_base:weapon_tweak_data()
		if weap_base.dot_data then else fire_dot_data = weapon_tweak_data and weapon_tweak_data.fire_dot_data end -- Player-Side Rebalances
	end

	local action_data = {
		variant = variant or "fire",
		damage = damage,
		weapon_unit = weapon_unit,
		attacker_unit = user_unit,
		col_ray = col_ray,
		armor_piercing = armor_piercing,
		shield_knock = shield_knock,
		knock_down = knock_down,
		stagger = stagger,
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