local mvec3_set = mvector3.set
local mvec3_add = mvector3.add
local mvec3_dot = mvector3.dot
local mvec3_sub = mvector3.subtract
local mvec3_mul = mvector3.multiply
local mvec3_norm = mvector3.normalize
local mvec3_dir = mvector3.direction
local mvec3_set_l = mvector3.set_length
local mvec3_len = mvector3.length
local mvec3_len_sq = mvector3.length_sq
local math_clamp = math.clamp
local math_lerp = math.lerp
local math_acos = math.acos
local math_pow = math.pow
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_rot1 = Rotation()

function RaycastWeaponBase.collect_hits(from, to, setup_data)
	setup_data = setup_data or {}
	local ray_hits = nil
	local hit_enemy = false
	local ignore_unit = setup_data.ignore_units or {}
	local enemy_mask = setup_data.enemy_mask --[[ managers.slot:get_mask("enemies") ]]
	local bullet_slotmask = setup_data.bullet_slotmask or managers.slot:get_mask("bullet_impact_targets")

    if setup_data.stop_on_impact then
		ray_hits = {}
		local hit = World:raycast("ray", from, to, "slot_mask", bullet_slotmask, "ignore_unit", ignore_unit)

		if hit then
			table.insert(ray_hits, hit)

			hit_enemy = hit.unit:in_slot(enemy_mask)
		end

		return ray_hits, hit_enemy, hit_enemy and {
			[hit.unit:key()] = hit.unit
		} or nil
	end
    
	local can_shoot_through_wall = setup_data.can_shoot_through_wall
	local can_shoot_through_shield = setup_data.can_shoot_through_shield
	local can_shoot_through_enemy = setup_data.can_shoot_through_enemy
	local wall_mask = setup_data.wall_mask --[[ managers.slot:get_mask("world_geometry", "vehicles") ]]
	local shield_mask = setup_data.shield_mask --[[ managers.slot:get_mask("enemy_shield_check") ]]
	local ai_vision_ids = Idstring("ai_vision")
	local bulletproof_ids = Idstring("bulletproof")


	-- <oryo
	local weapon_unit = setup_data.weapon_unit
	local armor_piercing =  setup_data.armor_piercing
	local pierce_armor = armor_piercing
	local armor_pierce_value = setup_data.armor_pierce_value

	local can_shoot_through_armor_plating = setup_data.can_shoot_through_armor_plating

	local max_enemy_penetration_distance = setup_data.max_enemy_penetration_distance
	local enemy_pen_energy_loss = setup_data._enemy_pen_energy_loss
	
	local max_wall_penetration_distance = setup_data.max_wall_penetration_distance
	local wall_pen_energy_loss = setup_data._enemy_pen_energy_loss
	
	local max_shield_penetration_distance = setup_data._max_shield_penetration_distance
	local shield_pen_energy_loss = setup_data._shield_pen_energy_loss
	
	local max_penetrations = setup_data._max_penetrations
	
	local penetrations = 0
	local enemy_penetrations = 0
	local wall_penetrations = 0
	local prev_hit_wall = {}
	local shield_penetrations = 0
	local energy_loss = 0

	if can_shoot_through_armor_plating then
		ray_hits = World:raycast_wall("ray", from, to, "slot_mask", bullet_slotmask, "ignore_unit", ignore_unit, "thickness", 40, "thickness_mask", wall_mask)
		
		for i, hit in ipairs(ray_hits) do
			if not units_hit[hit.unit:key()] then
				if hit.body:name() == Idstring("body_shields") then
					hit.unit:damage():run_sequence_simple("int_seq_shield_detach")
					hit.unit:character_damage():set_shield_health(0)
				elseif hit.body:name() == Idstring("head") then
					units_hit[hit.unit:key()] = true
					unique_hits[#unique_hits + 1] = hit
					hit.hit_position = hit.position
				end
			end
		end

		ray_hits = World:raycast_wall("ray", from, to, "slot_mask", bullet_slotmask, "ignore_unit", ignore_unit, "thickness", 40, "thickness_mask", wall_mask)
	-- oryo>


	elseif can_shoot_through_wall then
		ray_hits = World:raycast_wall("ray", from, to, "slot_mask", bullet_slotmask, "ignore_unit", ignore_unit, "thickness", 40, "thickness_mask", wall_mask)
	else
		ray_hits = World:raycast_all("ray", from, to, "slot_mask", bullet_slotmask, "ignore_unit", ignore_unit)
	end
	
	
	local unique_hits = {}
	local enemies_hit = {}
	local unit, u_key, is_enemy = nil
	local units_hit = {}
	local in_slot_func = Unit.in_slot
	local has_ray_type_func = Body.has_ray_type

	for i, hit in ipairs(ray_hits) do
        unit = hit.unit
		u_key = unit:key()

		if not units_hit[u_key] then
			units_hit[u_key] = true


			-- <oryo
			hit.distance = hit.distance + energy_loss

			if hit.body:name() == Idstring("body_plate") then
				if not armor_piercing then
					local armor_pierce_roll = math.rand(1)

					if armor_pierce_value > armor_pierce_roll then
						pierce_armor = true
					end
				end
				hit.armor_piercing = pierce_armor
			end
			-- oryo>


			unique_hits[#unique_hits + 1] = hit
			hit.hit_position = hit.position
			hit_enemy = hit_enemy or hit.unit:in_slot(enemy_mask)
            is_enemy = in_slot_func(unit, enemy_mask)

			if is_enemy then
				enemies_hit[u_key] = unit
				hit_enemy = true
			end
			local weak_body = has_ray_type_func(hit.body, ai_vision_ids)
			weak_body = weak_body or has_ray_type_func(hit.body, bulletproof_ids)
			

			-- <oryo
			if can_shoot_through_armor_plating then
				--nothing
			elseif hit_enemy then
				if hit.body:name() == Idstring("body_plate") and not pierce_armor then
					break
				elseif not can_shoot_through_enemy then
					break
				elseif max_enemy_penetration_distance and max_enemy_penetration_distance < hit.distance then
					break
				elseif type(can_shoot_through_enemy) == "number" then
					if can_shoot_through_enemy <= enemy_penetrations or max_penetrations and max_penetrations <= penetrations then
						break
					else
						enemy_penetrations = enemy_penetrations + 1
						penetrations = penetrations + 1
					end
				end
				if enemy_pen_energy_loss then
					energy_loss = energy_loss + enemy_pen_energy_loss
				end
			elseif in_slot_func(unit, wall_mask) and weak_body then
				if not can_shoot_through_wall then
					break
				elseif max_wall_penetration_distance and max_wall_penetration_distance < hit.distance then
					break
				elseif type(can_shoot_through_wall) == "number" then
					if can_shoot_through_wall <= wall_penetrations or max_penetrations and max_penetrations <= penetrations then
						if prev_hit_wall.distance then
							if hit.distance - prev_hit_wall.distance > 40 then
								break
							end
						else
							break
						end
					else
						if prev_hit_wall.distance then
							if hit.distance - prev_hit_wall.distance > 40 then
								wall_penetrations = wall_penetrations + 1
								prev_hit_wall.distance = hit.distance
							else
								--nothing
							end
						else
							wall_penetrations = wall_penetrations + 1
							penetrations = penetrations + 1
							prev_hit_wall.distance = hit.distance
						end
					end
				end
				if wall_pen_energy_loss then
					energy_loss = energy_loss + wall_pen_energy_loss
				end
			elseif in_slot_func(unit, shield_mask) then
				if not can_shoot_through_shield then
					break
				elseif max_shield_penetration_distance and max_shield_penetration_distance < hit.distance then
					break
				elseif type(can_shoot_through_shield) == "number" then
					if can_shoot_through_shield <= shield_penetrations or max_penetrations and max_penetrations <= penetrations then
						break
					else
						shield_penetrations = shield_penetrations + 1
						penetrations = penetrations + 1
					end
				end
				if shield_pen_energy_loss then
					energy_loss = energy_loss + shield_pen_energy_loss
				end
			end
			-- oryo>


		end
	end

	return unique_hits, hit_enemy, hit_enemy and enemies_hit or nil
end

function RaycastWeaponBase:_collect_hits(from, to, user_unit)
	local setup_data = {
        stop_on_impact = self:bullet_class().stop_on_impact,
		can_shoot_through_wall = self:can_shoot_through_wall(),
		can_shoot_through_shield = self:can_shoot_through_shield(),
		can_shoot_through_enemy = self:can_shoot_through_enemy(),
		bullet_slotmask = self._bullet_slotmask,
        enemy_mask = self.enemy_mask,
		wall_mask = self.wall_vehicle_mask,
		shield_mask = self.shield_mask,
		ignore_units = self._setup.ignore_units,
		
		
		-- <oryo
		weapon_unit = self._unit,
		armor_piercing = self._unit:base()._use_armor_piercing or nil,

		can_shoot_through_armor_plating = self._can_shoot_through_armor_plating,

		max_enemy_penetration_distance = self._max_enemy_penetration_distance or self._max_penetration_distance,
		enemy_pen_energy_loss = self._enemy_pen_energy_loss or self._pen_energy_loss,
	
		max_wall_penetration_distance = self._max_wall_penetration_distance or self._max_penetration_distance,
		wall_pen_energy_loss = self._enemy_pen_energy_loss or self._pen_energy_loss,
	
		max_shield_penetration_distance = self._max_shield_penetration_distance or self._max_penetration_distance,
		shield_pen_energy_loss = self._shield_pen_energy_loss or self._pen_energy_loss,
	
		max_penetrations = self._max_penetrations
		-- oryo>
	}

	-- <oryo
	local armor_pierce_value = 0
	if not setup_data.armor_piercing then
		local weapon_unit = setup_data.weapon_unit
		if user_unit == managers.player:player_unit() and not weapon_unit:base().thrower_unit then
			armor_pierce_value = armor_pierce_value + weapon_unit:base():armor_piercing_chance()
			armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("player", "armor_piercing_chance", 0)
			armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("weapon", "armor_piercing_chance", 0)
			armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("weapon", "armor_piercing_chance_2", 0)

			if weapon_unit:base():got_silencer() then
				armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("weapon", "armor_piercing_chance_silencer", 0)
			end

			if weapon_unit:base():is_category("saw") then
				armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("saw", "armor_piercing_chance", 0)
			end
		elseif user_unit:base() and user_unit:base().sentry_gun then
			local owner = user_unit:base():get_owner()

			if alive(owner) then
				if owner == managers.player:player_unit() then
					armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("sentry_gun", "armor_piercing_chance", 0)
					armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("sentry_gun", "armor_piercing_chance_2", 0)
				else
					armor_pierce_value = armor_pierce_value + (owner:base():upgrade_value("sentry_gun", "armor_piercing_chance") or 0)
					armor_pierce_value = armor_pierce_value + (owner:base():upgrade_value("sentry_gun", "armor_piercing_chance_2") or 0)
				end
			end
		end
	end

	setup_data.armor_pierce_value = armor_pierce_value
	-- oryo>
	

	return RaycastWeaponBase.collect_hits(from, to, setup_data)
end

local mvec_to = Vector3()
local mvec_right_ax = Vector3()
local mvec_up_ay = Vector3()
local mvec_ax = Vector3()
local mvec_ay = Vector3()
local mvec_spread_direction = Vector3()

function RaycastWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul)
	if self:gadget_overrides_weapon_functions() then
		return self:gadget_function_override("_fire_raycast", self, user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul)
	end
	local result = {}
    local ray_distance = self:weapon_range()
	local spread_x, spread_y = self:_get_spread(user_unit)
    spread_y = spread_y or spread_x
    spread_mul = spread_mul or 1

    mvector3.cross(mvec_right_ax, direction, math.UP)
    mvec3_norm(mvec_right_ax)
    mvector3.cross(mvec_up_ay, direction, mvec_right_ax)
    mvec3_norm(mvec_up_ay)
    mvec3_set(mvec_spread_direction, direction)

    local theta = math.random() * 360

    mvec3_mul(mvec_right_ax, math.rad(math.sin(theta) * math.random() * spread_x * spread_mul))
    mvec3_mul(mvec_up_ay, math.rad(math.cos(theta) * math.random() * spread_y * spread_mul))
    mvec3_add(mvec_spread_direction, mvec_right_ax)
    mvec3_add(mvec_spread_direction, mvec_up_ay)
    mvec3_set(mvec_to, mvec_spread_direction)
    mvec3_mul(mvec_to, ray_distance)
    mvec3_add(mvec_to, from_pos)

	local ray_hits, hit_enemy, enemies_hit = self:_collect_hits(from_pos, mvec_to, user_unit) -- oryo: added user_unit

	if self._autoaim and self._autohit_data then
		local weight = 0.1

		if hit_enemy then
			self._autohit_current = (self._autohit_current + weight) / (1 + weight)
		else
			local auto_hit_candidate, enemies_to_suppress = self:check_autoaim(from_pos, direction, nil, nil, nil, true)
			result.enemies_in_cone = enemies_to_suppress or false

			if auto_hit_candidate then
				local autohit_chance = self:get_current_autohit_chance_for_roll()

				if autohit_mul then
					autohit_chance = autohit_chance * autohit_mul
				end

				if math.random() < autohit_chance then
					self._autohit_current = (self._autohit_current + weight) / (1 + weight)

					mvec3_set(mvec_spread_direction, auto_hit_candidate.ray)
					mvec3_set(mvec_to, mvec_spread_direction)
					mvec3_mul(mvec_to, ray_distance)
					mvec3_add(mvec_to, from_pos)

				    ray_hits, hit_enemy, enemies_hit = self:_collect_hits(from_pos, mvec_to, user_unit) -- oryo: added user_unit
                end
			end

            if hit_enemy then
                self._autohit_current = (self._autohit_current + weight) / (1 + weight)
            elseif auto_hit_candidate then
                self._autohit_current = self._autohit_current / (1 + weight)
            end
        end
	end

	local hit_count = 0
    local hit_anyone = false
	local cop_kill_count = 0
	local hit_through_wall = false
	local hit_through_shield = false
    local is_civ_f = CopDamage.is_civilian
	local damage = self:_get_current_damage(dmg_mul)

	for _, hit in ipairs(ray_hits) do
		local dmg = self:get_damage_falloff(damage, hit, user_unit)

		if dmg > 0 then
			local hit_result = self:bullet_class():on_collision(hit, self._unit, user_unit, dmg)
			hit_through_wall = hit_through_wall or hit.unit:in_slot(self.wall_mask)
			hit_through_shield = hit_through_shield or hit.unit:in_slot(self.shield_mask) and alive(hit.unit:parent())

			if hit_result then
				hit.damage_result = hit_result
				hit_anyone = true
				hit_count = hit_count + 1

				if hit_result.type == "death" then
					local unit_base = hit.unit:base()
					local unit_type = unit_base and unit_base._tweak_table
					local is_civilian = unit_type and is_civ_f(unit_type)

					if not is_civilian then
						cop_kill_count = cop_kill_count + 1
					end

					self:_check_kill_achievements(cop_kill_count, unit_base, unit_type, is_civilian, hit_through_wall, hit_through_shield)
				end
			end
		end
	end

	self:_check_tango_achievements(cop_kill_count)

	result.hit_enemy = hit_anyone

	if self._autoaim then
		self._shot_fired_stats_table.hit = hit_anyone
		self._shot_fired_stats_table.hit_count = hit_count

		if not self._ammo_data or not self._ammo_data.ignore_statistic then
			managers.statistics:shot_fired(self._shot_fired_stats_table)
		end
	end

	local furthest_hit = ray_hits[#ray_hits]

	if (not furthest_hit or furthest_hit.distance > 600) and alive(self._obj_fire) then
		self._obj_fire:m_position(self._trail_effect_table.position)
		mvec3_set(self._trail_effect_table.normal, mvec_spread_direction)

		local trail = World:effect_manager():spawn(self._trail_effect_table)

		if furthest_hit then
			World:effect_manager():set_remaining_lifetime(trail, math_clamp((furthest_hit.distance - 600) / 10000, 0, furthest_hit.distance))
		end
	end

	if result.enemies_in_cone == nil then
		result.enemies_in_cone = self._suppression and self:check_suppression(from_pos, direction, enemies_hit) or nil
	elseif enemies_hit and self._suppression then
		result.enemies_in_cone = result.enemies_in_cone or {}
		local all_enemies = managers.enemy:all_enemies()

		for u_key, enemy in pairs(enemies_hit) do
			if all_enemies[u_key] then
				result.enemies_in_cone[u_key] = {
					error_mul = 1,
					unit = enemy
				}
			end
		end
	end

	if self._alert_events then
		result.rays = ray_hits
	end

	return result
end

function RaycastWeaponBase:update_next_shooting_time()
	if self:gadget_overrides_weapon_functions() then
		local gadget_func = self:gadget_function_override("update_next_shooting_time")

		if gadget_func then
			return gadget_func
		end
	end
	
	local fire_mode_data = tweak_data.weapon[self._name_id].fire_mode_data or {}

	if self._fire_mode == Idstring("single") then
		fire_mode_data = fire_mode_data and fire_mode_data.single or fire_mode_data
		local fire_rate = fire_mode_data.fire_rate or 0
		local next_fire = fire_rate / self:fire_rate_multiplier()
		self._next_fire_allowed = self._next_fire_allowed + next_fire

	elseif self._fire_mode == Idstring("auto") then
		fire_mode_data = fire_mode_data and fire_mode_data.auto or fire_mode_data
		local fire_rate = fire_mode_data.fire_rate or 0
		local next_fire = fire_rate / self:fire_rate_multiplier()
		self._next_fire_allowed = self._next_fire_allowed + next_fire

	elseif self._fire_mode == Idstring("burst") then
		fire_mode_data = fire_mode_data and fire_mode_data.burst or fire_mode_data
		local fire_rate = fire_mode_data.fire_rate or 0
		local next_fire = fire_rate / self:fire_rate_multiplier()
		self._next_fire_allowed = self._next_fire_allowed + next_fire
	else
		local next_fire = (tweak_data.weapon[self._name_id].fire_mode_data.fire_rate or 0) / self:fire_rate_multiplier()
		self._next_fire_allowed = self._next_fire_allowed + next_fire
	end
end

function RaycastWeaponBase:add_ammo(ratio, add_amount_override)
    local pickup_mul = managers.player:upgrade_value("player", "pick_up_ammo_multiplier", 1)
    pickup_mul = pickup_mul * managers.player:upgrade_value("player", "pick_up_ammo_multiplier_2", 1) -- oryo: fully loaded aced stacks multiplicatively with walk-in closet
    pickup_mul = pickup_mul * managers.player:crew_ability_upgrade_value("crew_scavenge", 1) -- oryo: sharpeyed stacks multiplicatively

	local function _add_ammo(ammo_base, ratio, add_amount_override)
		if ammo_base:get_ammo_max() == ammo_base:get_ammo_total() then
			return false, 0
		end
		local picked_up = true
        local stored_pickup_ammo = nil
		local add_amount = add_amount_override

		if not add_amount then


            -- <oryo
            local multiplier_min = 1
            local multiplier_max = 1

            if ammo_base._ammo_data then 
                multiplier_min = pickup_mul * (ammo_base._ammo_data.ammo_pickup_min_mul or multiplier_min)
                multiplier_max = pickup_mul * (ammo_base._ammo_data.ammo_pickup_max_mul or multiplier_max)
            end

			local min_ammo_pickup = ammo_base._ammo_pickup[1]
			local max_ammo_pickup = ammo_base._ammo_pickup[2]
			local rng_ammo = 0

			if max_ammo_pickup < 1 and (min_ammo_pickup + 0.5) == max_ammo_pickup then -- oryo: exception for very low pickup values
				add_amount = math.lerp(min_ammo_pickup * multiplier_min, (max_ammo_pickup - 0.5) * multiplier_max + 0.5 * (multiplier_max == 0 and 0 or 1), math.random())
			else
                add_amount = math.lerp(min_ammo_pickup * multiplier_min, max_ammo_pickup * multiplier_max, math.random())
			end
			-- oryo>

            
			picked_up = add_amount > 0
			add_amount = add_amount * (ratio or 1)
			stored_pickup_ammo = ammo_base:get_stored_pickup_ammo()

			if stored_pickup_ammo then
				add_amount = add_amount + stored_pickup_ammo

				ammo_base:remove_pickup_ammo()
			end
		end

		local rounded_amount = math.floor(add_amount)
		local new_ammo = ammo_base:get_ammo_total() + rounded_amount
		local max_allowed_ammo = ammo_base:get_ammo_max()

        if not add_amount_override and new_ammo < max_allowed_ammo then
			local leftover_ammo = add_amount - rounded_amount

			if leftover_ammo > 0 then
				ammo_base:store_pickup_ammo(leftover_ammo)
			end
		end

        ammo_base:set_ammo_total(math.clamp(new_ammo, 0, max_allowed_ammo))

        if stored_pickup_ammo then
			add_amount = math.floor(add_amount - stored_pickup_ammo)
		else
			add_amount = rounded_amount
		end

		return picked_up, add_amount
	end


	-- <oryo
	local gadget_ammo = nil
	for _, gadget in ipairs(self:get_all_override_weapon_gadgets()) do
		if gadget and gadget.ammo_base then
			gadget_ammo = gadget:ammo_base()
		end
	end

	local main_ammo_ratio = self:get_ammo_total() / self:get_ammo_max()
	local gadget_ammo_ratio = gadget_ammo and gadget_ammo:get_ammo_total() / gadget_ammo:get_ammo_max() or 1

	local picked_up, add_amount = nil

	if math.random() > main_ammo_ratio or gadget_ammo_ratio >= 1 then -- oryo: underbarrels no longer roll for ammo pickup simultaneously with main gun
		picked_up, add_amount = _add_ammo(self, ratio, add_amount_override)

		if self.AKIMBO then
			local akimbo_rounding = self:get_ammo_total() % 2 + #self._fire_callbacks

			if akimbo_rounding > 0 then
				_add_ammo(self, nil, akimbo_rounding)
			end
		end
	else
		picked_up, add_amount = _add_ammo(gadget_ammo, ratio, add_amount_override)
	end
	-- oryo>

    
	return picked_up, add_amount
end

function InstantBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank, no_sound)
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

		if hit_dmg_ext and hit_dmg_ext.damage_bullet then
			local was_alive = not hit_dmg_ext:dead()
			local armor_piercing, knock_down, stagger, variant = nil

			if weap_base then
				armor_piercing = col_ray.armor_piercing --[[ oryo: changed from {weap_base.has_armor_piercing and weap_base:has_armor_piercing()} ]]
				knock_down = weap_base.is_knock_down and weap_base:is_knock_down()
				stagger = weap_base.is_stagger and weap_base:is_stagger()
				variant = weap_base.variant and weap_base:variant()
			end

			result = self:give_impact_damage(col_ray, weapon_unit, user_unit, damage, armor_piercing, false, knock_down, stagger, variant)

			if result ~= "friendly_fire" then
				local has_died = hit_dmg_ext:dead()
				do_push = true
				push_mul = self:_get_character_push_multiplier(weapon_unit, was_alive and has_died)

				if weap_base and result and result.type == "death" and weap_base.should_shotgun_push and weap_base:should_shotgun_push() then
					do_shotgun_push = true
				end
			else
				play_impact_flesh = false
			end
		else
			do_push = true
		end
	else
		do_push = true
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
			no_sound = no_sound
		})
		self:play_impact_sound_and_effects(weapon_unit, col_ray, no_sound)
	end

	return result
end

if not he_stats then
	InstantExplosiveBulletBase.CURVE_POW = 1 -- oryo: Changed from 0.5
	-- InstantExplosiveBulletBase.PLAYER_DMG_MUL = 0.1
	InstantExplosiveBulletBase.RANGE = {max = 200, falloff_start = 100} -- oryo: added falloff_start

	he_stats = true
end