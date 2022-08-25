-- basically entirely rewritten
function ShotgunBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data)
	local result = nil
	local col_rays = nil
	local db = self._bullet_class == FlameBulletBase

	if self._alert_events then
		col_rays = {}
	end

	local damage = self:_get_current_damage(dmg_mul)
	local autoaim, dodge_enemies = self:check_autoaim(from_pos, direction, self._range)

	local ray_hits = {}
	local hit_enemy = false
	local enemy_mask = managers.slot:get_mask("enemies")
	local wall_mask = managers.slot:get_mask("world_geometry", "vehicles")
	local shield_mask = managers.slot:get_mask("enemy_shield_check")
	local ai_vision_ids = Idstring("ai_vision")
	local bulletproof_ids = Idstring("bulletproof")

	local function collect_hits(from, to)
		local hits = nil
		hit_enemy = false
		local weapon_unit = self._unit
		local armor_piercing = weapon_unit:base()._use_armor_piercing or nil
		local pierce_armor = armor_piercing
		
		local units_hit = {}
		local unique_hits = {}

		local penetrations = 0
		local enemy_penetrations = 0
		local wall_penetrations = 0
		local prev_hit_wall = {}
		local shield_penetrations = 0
		local energy_loss = 0
		
		if self._can_shoot_through_armor_plating then
	
			if self._can_shoot_through_wall then
				hits = World:raycast_wall("ray", from, to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "thickness", 40, "thickness_mask", wall_mask)
			else
				hits = World:raycast_all("ray", from, to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
			end
			
			
			for i, hit in ipairs(hits) do
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
		elseif self._can_shoot_through_wall then
			hits = World:raycast_wall("ray", from, to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "thickness", 40, "thickness_mask", wall_mask)
		else
			hits = World:raycast_all("ray", from, to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
		end
		
		for i, hit in ipairs(hits) do
			if not units_hit[hit.unit:key()] then
				units_hit[hit.unit:key()] = true
				hit.distance = hit.distance + energy_loss
				if hit.body:name() == Idstring("body_plate") then
					if not armor_piercing then
						local armor_pierce_roll = math.rand(1)
						local armor_pierce_value = 0
	
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
	
						if armor_pierce_value > armor_pierce_roll then
							pierce_armor = true
						end
					end
					hit.armor_piercing = pierce_armor
				end
				unique_hits[#unique_hits + 1] = hit
				hit.hit_position = hit.position
				hit_enemy = hit_enemy or hit.unit:in_slot(enemy_mask)
				local weak_body = hit.body:has_ray_type(ai_vision_ids)
				weak_body = weak_body or hit.body:has_ray_type(bulletproof_ids)

				if self._can_shoot_through_armor_plating then
					--nothing
				elseif hit_enemy then
					if hit.body:name() == Idstring("body_plate") and not pierce_armor then
						break
					elseif not self._can_shoot_through_enemy then
						break
					elseif self._max_enemy_penetration_distance and self._max_enemy_penetration_distance < hit.distance then
						break
					elseif (type(self._can_shoot_through_enemy) == "number") and (self._can_shoot_through_enemy < math.random()) then
						break
					elseif  self._max_enemy_penetrations then
						if self._max_enemy_penetrations == enemy_penetrations then
							break
						else
							enemy_penetrations = enemy_penetrations + 1
						end
					elseif  self._max_penetrations then
						if self._max_penetrations == penetrations then
							break
						else
							penetrations = penetrations + 1
						end
					end
					if self._enemy_pen_energy_loss then
						energy_loss = energy_loss + self._enemy_pen_energy_loss
					end
				elseif hit.unit:in_slot(wall_mask) and weak_body then
					if not self._can_shoot_through_wall then
						break
					elseif self._max_wall_penetration_distance and self._max_wall_penetration_distance < hit.distance then
						break
					elseif (type(self._can_shoot_through_wall) == "number") and (self._can_shoot_through_wall < math.random()) then
						break
					elseif  self._max_wall_penetrations then
						if self._max_wall_penetrations == wall_penetrations then
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
								prev_hit_wall.distance = hit.distance
							end
						end
					elseif  self._max_penetrations then
						if self._max_penetrations == penetrations then
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
									penetrations = penetrations + 1
									prev_hit_wall.distance = hit.distance
								else
									--nothing
								end
							else
								penetrations = penetrations + 1
								prev_hit_wall.distance = hit.distance
							end
						end
					end
					if self._wall_pen_energy_loss then
						energy_loss = energy_loss + self._wall_pen_energy_loss
					end
				elseif hit.unit:in_slot(shield_mask) then
					if not self._can_shoot_through_shield then
						break
					elseif self._max_shield_penetration_distance and self._max_shield_penetration_distance < hit.distance then
						break
					elseif (type(self._can_shoot_through_shield) == "number") and (self._can_shoot_through_shield < math.random()) then
						break
					elseif  self._max_shield_penetrations then
						if self._max_shield_penetrations == shield_penetrations then
							break
						else
							shield_penetrations = shield_penetrations + 1
						end
					elseif  self._max_penetrations then
						if self._max_penetrations == penetrations then
							break
						else
							penetrations = penetrations + 1
						end
					end
					if self._shield_pen_energy_loss then
						energy_loss = energy_loss + self._shield_pen_energy_loss
					end
				end
			end
		end

		for i, hit in ipairs(unique_hits) do
			if hit.unit:in_slot(enemy_mask) then
				if hit.unit:character_damage().is_head and hit.unit:character_damage():is_head(hit.body) then
					ray_hits[hit.unit:key()] = hit
				elseif hit.body:name() == Idstring("body_helmet_plate") or hit.body:name() == Idstring("body_helmet_glass") then
					ray_hits[hit.unit:key()] = hit
				elseif hit.body:name() == Idstring("body_shields") or (hit.unit:character_damage()._bag_body_name_ids and hit.body:name() == hit.unit:character_damage()._bag_body_name_ids) then
					ray_hits[hit.unit:key()] = hit
				elseif not ray_hits[hit.unit:key()] then
					ray_hits[hit.unit:key()] = hit
				end
			else
				table.insert(ray_hits, hit)
			end
		end
	end

	local spread_x, spread_y = self:_get_spread(user_unit)
	local right = direction:cross(Vector3(0, 0, 1)):normalized()
	local up = direction:cross(right):normalized()

	local mvec_to = Vector3()
	local mvec_direction = Vector3()
	local mvec_spread_direction = Vector3()
	mvector3.set(mvec_direction, direction)
	
	for i = 1, self._rays do 
		local theta = math.random() * 360
		local ax = math.sin(theta) * math.random() * spread_x * (spread_mul or 1)
		local ay = math.cos(theta) * math.random() * spread_y * (spread_mul or 1)

		mvector3.set(mvec_spread_direction, mvec_direction)
		mvector3.add(mvec_spread_direction, right * math.rad(ax))
		mvector3.add(mvec_spread_direction, up * math.rad(ay))
		mvector3.set(mvec_to, mvec_spread_direction)
		mvector3.multiply(mvec_to, 20000)
		mvector3.add(mvec_to, from_pos)

		collect_hits(from_pos, mvec_to)

		local ray_from_unit = shoot_through_data and alive(shoot_through_data.ray_from_unit) and shoot_through_data.ray_from_unit or nil
		local col_ray = (ray_from_unit or World):raycast("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)

		if col_rays then
			if col_ray then
				table.insert(col_rays, col_ray)
			else
				local ray_to = mvector3.copy(mvec_to)
				local spread_direction = mvector3.copy(mvec_spread_direction)

				table.insert(col_rays, {
					position = ray_to,
					ray = spread_direction
				})
			end
		end

		if self._autoaim then
			local weight = 0.1
	
			if autoaim and not hit_enemy then
				local autohit_chance = 1 - math.clamp((self._autohit_current - self._autohit_data.MIN_RATIO) / (self._autohit_data.MAX_RATIO - self._autohit_data.MIN_RATIO), 0, 1)
	
				if autohit_mul then
					autohit_chance = autohit_chance * autohit_mul
				end
	
				if math.random() < autohit_chance then
					self._autohit_current = (self._autohit_current + weight) / (1 + weight)
	
					mvector3.set(mvec_to, from_pos)
					mvector3.add_scaled(mvec_to, autoaim.ray, ray_distance)
	
					collect_hits(from_pos, mvec_to)
				end
			end
	
			if hit_enemy then
				self._autohit_current = (self._autohit_current + weight) / (1 + weight)
			elseif autoaim then
				self._autohit_current = self._autohit_current / (1 + weight)
			end
		end
	end

	local kill_data = {
		kills = 0,
		headshots = 0,
		civilian_kills = 0
	}
	local hit_result = nil

	for _, col_ray in pairs(ray_hits) do
		local damage = self:get_damage_falloff(damage, col_ray, user_unit)
		hit_result = nil

		if col_ray.unit:character_damage() and not col_ray.unit:character_damage().is_head then
			self._bullet_class:on_collision_effects(col_ray, self._unit, user_unit, damage)
		end

		if damage > 0 then
			hit_result = self._bullet_class:on_collision(col_ray, self._unit, user_unit, damage)


			hit_result = managers.mutators:modify_value("ShotgunBase:_fire_raycast", hit_result)

			if hit_result and hit_result.type == "death" then
				managers.game_play_central:do_shotgun_push(col_ray.unit, col_ray.position, col_ray.ray, col_ray.distance, user_unit)

				kill_data.kills = kill_data.kills + 1

				if col_ray.body and col_ray.body:name() == Idstring("head") then
					kill_data.headshots = kill_data.headshots + 1
				end

				if col_ray.unit and col_ray.unit:base() and (col_ray.unit:base()._tweak_table == "civilian" or col_ray.unit:base()._tweak_table == "civilian_female") then
					kill_data.civilian_kills = kill_data.civilian_kills + 1
				end
			end
		end
	end

	if dodge_enemies and self._suppression then
		for enemy_data, dis_error in pairs(dodge_enemies) do
			enemy_data.unit:character_damage():build_suppression(suppr_mul * dis_error * self._suppression, self._panic_suppression_chance)
		end
	end

	if not result then
		result = {
			hit_enemy = next(ray_hits) and true or false
		}

		if self._alert_events then
			result.rays = ray_hits
		end
	end

	managers.statistics:shot_fired({
		hit = false,
		weapon_unit = self._unit
	})

	for _, hit in pairs(ray_hits) do
		if hit.unit:in_slot(managers.slot:get_mask("enemies")) then
			managers.statistics:shot_fired({
				skip_bullet_count = true,
				hit = true,
				weapon_unit = self._unit
			})
		end
	end

	for key, data in pairs(tweak_data.achievement.shotgun_single_shot_kills) do
		if data.headshot and data.count <= kill_data.headshots - kill_data.civilian_kills or data.count <= kill_data.kills - kill_data.civilian_kills then
			local should_award = true

			if data.blueprint then
				local missing_parts = false

				for _, part_or_parts in ipairs(data.blueprint) do
					if type(part_or_parts) == "string" then
						if not table.contains(self._blueprint or {}, part_or_parts) then
							missing_parts = true

							break
						end
					else
						local found_part = false

						for _, part in ipairs(part_or_parts) do
							if table.contains(self._blueprint or {}, part) then
								found_part = true

								break
							end
						end

						if not found_part then
							missing_parts = true

							break
						end
					end
				end

				if missing_parts then
					should_award = false
				end
			end

			if should_award then
				managers.achievment:_award_achievement(data, key)
			end
		end
	end

	return result
end

-- <Player-Side Rebalances: allow Close By Aced rate of fire buff to work on shotguns with magazines when fired in single or burst fire
function ShotgunBase:fire_rate_multiplier()
	local fire_rate_mul = self._fire_rate_multiplier

	local hip_fire_rate_inc = self:is_single_shot() and managers.player:upgrade_value("shotgun", "hip_rate_of_fire", 0) or 0

	if hip_fire_rate_inc ~= 0 then
		local user_unit = self._setup and self._setup.user_unit
		local current_state = alive(user_unit) and user_unit:movement() and user_unit:movement()._current_state

		if current_state and not current_state:in_steelsight() then
			fire_rate_mul = fire_rate_mul + 1 - hip_fire_rate_inc
			fire_rate_mul = self:_convert_add_to_mul(fire_rate_mul)
		end
	end

	return fire_rate_mul
end
-- Player-Side Rebalances>