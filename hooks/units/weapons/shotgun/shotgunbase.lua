local mvec3_add = mvector3.add
local mvec3_cpy = mvector3.copy
local mvec3_cross = mvector3.cross
local mvec3_mul = mvector3.multiply
local mvec3_norm = mvector3.normalize
local mvec3_set = mvector3.set
local math_cos = math.cos
local math_rad = math.rad
local math_random = math.random
local math_sin = math.sin

local mvec_to = Vector3()
local mvec_right = Vector3()
local mvec_up = Vector3()
local mvec_ax = Vector3()
local mvec_ay = Vector3()
local mvec_spread_direction = Vector3()

function ShotgunBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul)
	if self:gadget_overrides_weapon_functions() then
		return self:gadget_function_override("_fire_raycast", self, user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul)
	end

	local result = {}
	local all_hits = {}
	local hit_effects = {}
	local all_enemies_hit = {}
	local alert_rays = self._alert_events and {}
	local all_hits_lookup = {}
	local alert_rays_lookup = alert_rays and {}

	local function on_hit(ray_hits)
		for _, hit in ipairs(ray_hits) do
			local unit_key = hit.unit:key()
			local char_dmg_ext = hit.unit:character_damage()

			if not char_dmg_ext then
				if not hit.unit:in_slot(self.shield_mask) then
					all_hits[#all_hits + 1] = hit

					if alert_rays then
						alert_rays[#alert_rays + 1] = hit
					end
				elseif not all_hits_lookup[unit_key] then
					all_hits_lookup[unit_key] = #all_hits + 1
					all_hits[#all_hits + 1] = hit

					if alert_rays then
						alert_rays_lookup[unit_key] = #alert_rays + 1
						alert_rays[#alert_rays + 1] = hit
					end
				else
					local base_ext = hit.unit:base()

					if base_ext and base_ext.chk_body_hit_priority and base_ext:chk_body_hit_priority(all_hits[all_hits_lookup[unit_key]].body, hit.body) then
						hit_effects[#hit_effects + 1] = all_hits[all_hits_lookup[unit_key]]
						all_hits[all_hits_lookup[unit_key]] = hit

						if alert_rays then
							alert_rays[alert_rays_lookup[unit_key]] = hit
						end
					else
						hit_effects[#hit_effects + 1] = hit
					end
				end
			elseif not all_hits_lookup[unit_key] then
				all_hits_lookup[unit_key] = #all_hits + 1
				all_hits[#all_hits + 1] = hit

				if alert_rays then
					alert_rays_lookup[unit_key] = #alert_rays + 1
					alert_rays[#alert_rays + 1] = hit
				end
			elseif char_dmg_ext.chk_body_hit_priority and char_dmg_ext:chk_body_hit_priority(all_hits[all_hits_lookup[unit_key]].body, hit.body) then
				if not char_dmg_ext.is_head then
					hit_effects[#hit_effects + 1] = all_hits[all_hits_lookup[unit_key]]
				end

				all_hits[all_hits_lookup[unit_key]] = hit

				if alert_rays then
					alert_rays[alert_rays_lookup[unit_key]] = hit
				end
			elseif not char_dmg_ext.is_head then
				hit_effects[#hit_effects + 1] = hit
			end
		end
	end

	local ray_distance = self:weapon_range(user_unit)
	local can_autoaim = self._autoaim and self._autohit_data and true or false
	local spread_x, spread_y = self:_get_spread(user_unit)
	spread_y = spread_y or spread_x
	spread_mul = spread_mul or 1

	mvec3_cross(mvec_right, direction, math.UP)
	mvec3_norm(mvec_right)
	mvec3_cross(mvec_up, direction, mvec_right)
	mvec3_norm(mvec_up)

	for i = 1, self._rays do
		mvec3_set(mvec_ax, mvec_right)
		mvec3_set(mvec_ay, mvec_up)
		mvec3_set(mvec_spread_direction, direction)

		local theta = math_random() * 360

		mvec3_mul(mvec_ax, math_rad(math_sin(theta) * math_random() * spread_x * spread_mul))
		mvec3_mul(mvec_ay, math_rad(math_cos(theta) * math_random() * spread_y * spread_mul))
		mvec3_add(mvec_spread_direction, mvec_ax)
		mvec3_add(mvec_spread_direction, mvec_ay)
		mvec3_set(mvec_to, mvec_spread_direction)
		mvec3_mul(mvec_to, ray_distance)
		mvec3_add(mvec_to, from_pos)

		local ray_hits, hit_enemy, enemies_hit = self:_collect_hits(from_pos, mvec_to, user_unit) -- oryo: added user_unit

		if can_autoaim then
			can_autoaim = false
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

					if math_random() < autohit_chance then
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

		if hit_enemy then
			for u_key, enemy in pairs(enemies_hit) do
				all_enemies_hit[u_key] = enemy
			end
		end

		if ray_hits and next(ray_hits) then
			on_hit(ray_hits)

			result.hit_enemy = result.hit_enemy or ray_hits[#ray_hits].unit:character_damage() and true or false
		end
	end

	local function sort_f(a, b)
		return a.distance < b.distance
	end

	table.sort(all_hits, sort_f)
	table.sort(hit_effects, sort_f)

	if alert_rays then
		table.sort(alert_rays, sort_f)
	end

	local hit_count = 0
	local hit_anyone = false
	local cop_kill_count = 0
	local kill_data = {
		kills = 0,
		headshots = 0,
		civilian_kills = 0
	}
	local bullet_class = self:bullet_class()
	local damage = self:_get_current_damage(dmg_mul)
	local check_additional_achievements = self._ammo_data and self._ammo_data.check_additional_achievements

	for _, hit in ipairs(hit_effects) do
		bullet_class:on_collision_effects(hit, self._unit, user_unit, damage)
	end

	local hit_through_wall = false
	local hit_through_shield = false
	local is_civ_f = CopDamage.is_civilian

	for _, hit in ipairs(all_hits) do
		local dmg = self:get_damage_falloff(damage, hit, user_unit)

		if dmg > 0 then
			local hit_result = bullet_class:on_collision(hit, self._unit, user_unit, dmg)
			hit_result = managers.mutators:modify_value("ShotgunBase:_fire_raycast", hit_result)

			if check_additional_achievements then
				hit_through_wall = hit_through_wall or hit.unit:in_slot(self.wall_mask)
				hit_through_shield = hit_through_shield or hit.unit:in_slot(self.shield_mask) and alive(hit.unit:parent())
			end

			if hit_result then
				hit.damage_result = hit_result
				hit_anyone = true
				hit_count = hit_count + 1

				if hit_result.type == "death" then
					kill_data.kills = kill_data.kills + 1
					local unit_base = hit.unit:base()
					local unit_type = unit_base and unit_base._tweak_table
					local is_civilian = unit_type and is_civ_f(unit_type)

					if is_civilian then
						kill_data.civilian_kills = kill_data.civilian_kills + 1
					else
						cop_kill_count = cop_kill_count + 1
					end

					if check_additional_achievements then
						self:_check_kill_achievements(cop_kill_count, unit_base, unit_type, is_civilian, hit_through_wall, hit_through_shield)
					end
				end
			end
		end
	end

	if check_additional_achievements then
		self:_check_tango_achievements(cop_kill_count)
	end

	self:_check_one_shot_shotgun_achievements(kill_data)

	if result.enemies_in_cone == nil then
		result.enemies_in_cone = self._suppression and self:check_suppression(from_pos, direction, all_enemies_hit) or nil
	elseif all_enemies_hit and self._suppression then
		result.enemies_in_cone = result.enemies_in_cone or {}
		local all_enemies = managers.enemy:all_enemies()

		for u_key, enemy in pairs(all_enemies_hit) do
			if all_enemies[u_key] then
				result.enemies_in_cone[u_key] = {
					error_mul = 1,
					unit = enemy
				}
			end
		end
	end

	if alert_rays then
		result.rays = alert_rays
	end

	if self._autoaim then
		self._shot_fired_stats_table.hit = hit_anyone
		self._shot_fired_stats_table.hit_count = hit_count

		if not self._ammo_data or not self._ammo_data.ignore_statistic then
			managers.statistics:shot_fired(self._shot_fired_stats_table)
		end
	end

	return result
end


-- -- basically entirely rewritten
-- function ShotgunBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data)
-- 	if self:gadget_overrides_weapon_functions() then
-- 		return self:gadget_function_override("_fire_raycast", self, user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul)
-- 	end
--     local result = nil
-- 	local col_rays = nil
-- 	local db = self._bullet_class == FlameBulletBase

-- 	if self._alert_events then
-- 		col_rays = {}
-- 	end

-- 	local damage = self:_get_current_damage(dmg_mul)
-- 	local autoaim, dodge_enemies = self:check_autoaim(from_pos, direction, self._range)
-- 	local extra_collisions = self.extra_collisions and self:extra_collisions()

-- 	local ray_hits = {}
-- 	local hit_enemy = false
-- 	local enemy_mask = managers.slot:get_mask("enemies")
-- 	local wall_mask = managers.slot:get_mask("world_geometry", "vehicles")
-- 	local shield_mask = managers.slot:get_mask("enemy_shield_check")
-- 	local ai_vision_ids = Idstring("ai_vision")
-- 	local bulletproof_ids = Idstring("bulletproof")

-- 	local setup_data = {
-- 		can_shoot_through_wall = self:can_shoot_through_wall(),
-- 		can_shoot_through_shield = self:can_shoot_through_shield(),
-- 		can_shoot_through_enemy = self:can_shoot_through_enemy(),
-- 		bullet_slotmask = self._bullet_slotmask,
-- 		ignore_units = self._setup.ignore_units,
		
-- 		weapon_unit = self._unit,
-- 		armor_piercing = self._unit:base()._use_armor_piercing or nil,

-- 		can_shoot_through_armor_plating = self._can_shoot_through_armor_plating,

-- 		max_enemy_penetration_distance = self._max_enemy_penetration_distance or self._max_penetration_distance,
-- 		enemy_pen_energy_loss = self._enemy_pen_energy_loss or self._pen_energy_loss,
	
-- 		max_wall_penetration_distance = self.max_wall_penetration_distance or self._max_penetration_distance,
-- 		wall_pen_energy_loss = self._enemy_pen_energy_loss or self._pen_energy_loss,
	
-- 		max_shield_penetration_distance = self._max_shield_penetration_distance or self._max_penetration_distance,
-- 		shield_pen_energy_loss = self._shield_pen_energy_loss or self._pen_energy_loss,
	
-- 		max_penetrations = self._max_penetrations
-- 	}
	
-- 	local armor_pierce_value = 0
-- 	if not setup_data.armor_piercing then
-- 		local weapon_unit = setup_data.weapon_unit
-- 		if user_unit == managers.player:player_unit() and not weapon_unit:base().thrower_unit then
-- 			armor_pierce_value = armor_pierce_value + weapon_unit:base():armor_piercing_chance()
-- 			armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("player", "armor_piercing_chance", 0)
-- 			armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("weapon", "armor_piercing_chance", 0)
-- 			armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("weapon", "armor_piercing_chance_2", 0)

-- 			if weapon_unit:base():got_silencer() then
-- 				armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("weapon", "armor_piercing_chance_silencer", 0)
-- 			end

-- 			if weapon_unit:base():is_category("saw") then
-- 				armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("saw", "armor_piercing_chance", 0)
-- 			end
-- 		elseif user_unit:base() and user_unit:base().sentry_gun then
-- 			local owner = user_unit:base():get_owner()

-- 			if alive(owner) then
-- 				if owner == managers.player:player_unit() then
-- 					armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("sentry_gun", "armor_piercing_chance", 0)
-- 					armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("sentry_gun", "armor_piercing_chance_2", 0)
-- 				else
-- 					armor_pierce_value = armor_pierce_value + (owner:base():upgrade_value("sentry_gun", "armor_piercing_chance") or 0)
-- 					armor_pierce_value = armor_pierce_value + (owner:base():upgrade_value("sentry_gun", "armor_piercing_chance_2") or 0)
-- 				end
-- 			end
-- 		end
-- 	end

-- 	setup_data.armor_pierce_value = armor_pierce_value

-- 	local function collect_hits(from, to, setup_data)
-- 		setup_data = setup_data or {}
-- 		local hits = nil
-- 		hit_enemy = false
-- 		local can_shoot_through_wall = setup_data.can_shoot_through_wall
-- 		local can_shoot_through_shield = setup_data.can_shoot_through_shield
-- 		local can_shoot_through_enemy = setup_data.can_shoot_through_enemy
-- 		local bullet_slotmask = setup_data.bullet_slotmask or managers.slot:get_mask("bullet_impact_targets")
-- 		local enemy_mask = managers.slot:get_mask("enemies")
-- 		local wall_mask = managers.slot:get_mask("world_geometry", "vehicles")
-- 		local shield_mask = managers.slot:get_mask("enemy_shield_check")
-- 		local ai_vision_ids = Idstring("ai_vision")
-- 		local bulletproof_ids = Idstring("bulletproof")
-- 		local ignore_unit = setup_data.ignore_units or {}
		
-- 		local units_hit = {}
-- 		local unique_hits = {}
	
	
-- 		-- <oryo
-- 		local weapon_unit = setup_data.weapon_unit
-- 		local armor_piercing =  setup_data.armor_piercing
-- 		local pierce_armor = armor_piercing
-- 		local armor_pierce_value = setup_data.armor_pierce_value
	
-- 		local can_shoot_through_armor_plating = setup_data.can_shoot_through_armor_plating
	
-- 		local max_enemy_penetration_distance = setup_data.max_enemy_penetration_distance
-- 		local enemy_pen_energy_loss = setup_data._enemy_pen_energy_loss
		
-- 		local max_wall_penetration_distance = setup_data.max_wall_penetration_distance
-- 		local wall_pen_energy_loss = setup_data._enemy_pen_energy_loss
		
-- 		local max_shield_penetration_distance = setup_data._max_shield_penetration_distance
-- 		local shield_pen_energy_loss = setup_data._shield_pen_energy_loss
		
-- 		local max_penetrations = setup_data._max_penetrations
		
-- 		local penetrations = 0
-- 		local enemy_penetrations = 0
-- 		local wall_penetrations = 0
-- 		local prev_hit_wall = {}
-- 		local shield_penetrations = 0
-- 		local energy_loss = 0
		
-- 		if can_shoot_through_armor_plating then

-- 			hits = World:raycast_wall("ray", from, to, "slot_mask", bullet_slotmask, "ignore_unit", ignore_unit, "thickness", 40, "thickness_mask", wall_mask)
			
-- 			for i, hit in ipairs(hits) do
-- 				if not units_hit[hit.unit:key()] then
-- 					if hit.body:name() == Idstring("body_shields") then
-- 						hit.unit:damage():run_sequence_simple("int_seq_shield_detach")
-- 						hit.unit:character_damage():set_shield_health(0)
-- 					elseif hit.body:name() == Idstring("head") then
-- 						units_hit[hit.unit:key()] = true
-- 						unique_hits[#unique_hits + 1] = hit
-- 						hit.hit_position = hit.position
-- 					end
-- 				end
-- 			end
	
-- 			hits = World:raycast_wall("ray", from, to, "slot_mask", bullet_slotmask, "ignore_unit", ignore_unit, "thickness", 40, "thickness_mask", wall_mask)

-- 		elseif can_shoot_through_wall then
-- 			hits = World:raycast_wall("ray", from, to, "slot_mask", bullet_slotmask, "ignore_unit", ignore_unit, "thickness", 40, "thickness_mask", wall_mask)
-- 		else
-- 			hits = World:raycast_all("ray", from, to, "slot_mask", bullet_slotmask, "ignore_unit", ignore_unit)
-- 		end
		
-- 		for i, hit in ipairs(hits) do
-- 			if not units_hit[hit.unit:key()] then
-- 				units_hit[hit.unit:key()] = true
	
-- 				hit.distance = hit.distance + energy_loss
	
-- 				if hit.body:name() == Idstring("body_plate") then
-- 					if not armor_piercing then
-- 						local armor_pierce_roll = math.rand(1)
	
-- 						if armor_pierce_value > armor_pierce_roll then
-- 							pierce_armor = true
-- 						end
-- 					end
-- 					hit.armor_piercing = pierce_armor
-- 				end
	
-- 				unique_hits[#unique_hits + 1] = hit
-- 				hit.hit_position = hit.position
-- 				hit_enemy = hit_enemy or hit.unit:in_slot(enemy_mask)
-- 				local weak_body = hit.body:has_ray_type(ai_vision_ids)
-- 				weak_body = weak_body or hit.body:has_ray_type(bulletproof_ids)
				
-- 				if can_shoot_through_armor_plating then
-- 					--nothing
-- 				elseif hit_enemy then
-- 					if hit.body:name() == Idstring("body_plate") and not pierce_armor then
-- 						break
-- 					elseif not can_shoot_through_enemy then
-- 						break
-- 					elseif max_enemy_penetration_distance and max_enemy_penetration_distance < hit.distance then
-- 						break
-- 					elseif type(can_shoot_through_enemy) == "number" then
-- 						if can_shoot_through_enemy <= enemy_penetrations or max_penetrations and max_penetrations <= penetrations then
-- 							break
-- 						else
-- 							enemy_penetrations = enemy_penetrations + 1
-- 							penetrations = penetrations + 1
-- 						end
-- 					end
-- 					if enemy_pen_energy_loss then
-- 						energy_loss = energy_loss + enemy_pen_energy_loss
-- 					end
-- 				elseif hit.unit:in_slot(wall_mask) and weak_body then
-- 					if not can_shoot_through_wall then
-- 						break
-- 					elseif max_wall_penetration_distance and max_wall_penetration_distance < hit.distance then
-- 						break
-- 					elseif type(can_shoot_through_wall) == "number" then
-- 						if can_shoot_through_wall <= wall_penetrations or max_penetrations and max_penetrations <= penetrations then
-- 							if prev_hit_wall.distance then
-- 								if hit.distance - prev_hit_wall.distance > 40 then
-- 									break
-- 								end
-- 							else
-- 								break
-- 							end
-- 						else
-- 							if prev_hit_wall.distance then
-- 								if hit.distance - prev_hit_wall.distance > 40 then
-- 									wall_penetrations = wall_penetrations + 1
-- 									prev_hit_wall.distance = hit.distance
-- 								else
-- 									--nothing
-- 								end
-- 							else
-- 								wall_penetrations = wall_penetrations + 1
-- 								penetrations = penetrations + 1
-- 								prev_hit_wall.distance = hit.distance
-- 							end
-- 						end
-- 					end
-- 					if wall_pen_energy_loss then
-- 						energy_loss = energy_loss + wall_pen_energy_loss
-- 					end
-- 				elseif hit.unit:in_slot(shield_mask) then
-- 					if not can_shoot_through_shield then
-- 						break
-- 					elseif max_shield_penetration_distance and max_shield_penetration_distance < hit.distance then
-- 						break
-- 					elseif type(can_shoot_through_shield) == "number" then
-- 						if can_shoot_through_shield <= shield_penetrations or max_penetrations and max_penetrations <= penetrations then
-- 							break
-- 						else
-- 							shield_penetrations = shield_penetrations + 1
-- 							penetrations = penetrations + 1
-- 						end
-- 					end
-- 					if shield_pen_energy_loss then
-- 						energy_loss = energy_loss + shield_pen_energy_loss
-- 					end
-- 				end
				
-- 			end
-- 		end

-- 		for i, hit in ipairs(unique_hits) do
-- 			if hit.unit:in_slot(enemy_mask) then
-- 				if hit.unit:character_damage().is_head and hit.unit:character_damage():is_head(hit.body) then
-- 					ray_hits[hit.unit:key()] = hit
-- 				elseif hit.body:name() == Idstring("body_helmet_plate") or hit.body:name() == Idstring("body_helmet_glass") then
-- 					ray_hits[hit.unit:key()] = hit
-- 				elseif hit.body:name() == Idstring("body_shields") or (hit.unit:character_damage()._bag_body_name_ids and hit.body:name() == hit.unit:character_damage()._bag_body_name_ids) then
-- 					ray_hits[hit.unit:key()] = hit
-- 				elseif not ray_hits[hit.unit:key()] then
-- 					ray_hits[hit.unit:key()] = hit
-- 				end
-- 			else
-- 				table.insert(ray_hits, hit)
-- 			end
-- 		end
-- 	end

-- 	local spread_x, spread_y = self:_get_spread(user_unit)
-- 	local right = direction:cross(Vector3(0, 0, 1)):normalized()
-- 	local up = direction:cross(right):normalized()

-- 	local mvec_to = Vector3()
-- 	local mvec_direction = Vector3()
-- 	local mvec_spread_direction = Vector3()
-- 	mvector3.set(mvec_direction, direction)
	
-- 	for i = 1, self._rays do 
-- 		local theta = math.random() * 360
-- 		local ax = math.sin(theta) * math.random() * spread_x * (spread_mul or 1)
-- 		local ay = math.cos(theta) * math.random() * spread_y * (spread_mul or 1)

-- 		mvector3.set(mvec_spread_direction, mvec_direction)
-- 		mvector3.add(mvec_spread_direction, right * math.rad(ax))
-- 		mvector3.add(mvec_spread_direction, up * math.rad(ay))
-- 		mvector3.set(mvec_to, mvec_spread_direction)
-- 		mvector3.multiply(mvec_to, 20000)
-- 		mvector3.add(mvec_to, from_pos)

-- 		collect_hits(from_pos, mvec_to, setup_data)

-- 		local ray_from_unit = shoot_through_data and alive(shoot_through_data.ray_from_unit) and shoot_through_data.ray_from_unit or nil
-- 		local col_ray = (ray_from_unit or World):raycast("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)

-- 		if col_rays then
-- 			if col_ray then
-- 				table.insert(col_rays, col_ray)
-- 			else
-- 				local ray_to = mvector3.copy(mvec_to)
-- 				local spread_direction = mvector3.copy(mvec_spread_direction)

-- 				table.insert(col_rays, {
-- 					position = ray_to,
-- 					ray = spread_direction
-- 				})
-- 			end
-- 		end

-- 		if self._autoaim then
-- 			local weight = 0.1
	
-- 			if autoaim and not hit_enemy then
-- 				local autohit_chance = 1 - math.clamp((self._autohit_current - self._autohit_data.MIN_RATIO) / (self._autohit_data.MAX_RATIO - self._autohit_data.MIN_RATIO), 0, 1)
	
-- 				if autohit_mul then
-- 					autohit_chance = autohit_chance * autohit_mul
-- 				end
	
-- 				if math.random() < autohit_chance then
-- 					self._autohit_current = (self._autohit_current + weight) / (1 + weight)
	
-- 					mvector3.set(mvec_to, from_pos)
-- 					mvector3.add_scaled(mvec_to, autoaim.ray, ray_distance)
	
-- 					collect_hits(from_pos, mvec_to, setup_data)
-- 				end
-- 			end
	
-- 			if hit_enemy then
-- 				self._autohit_current = (self._autohit_current + weight) / (1 + weight)
-- 			elseif autoaim then
-- 				self._autohit_current = self._autohit_current / (1 + weight)
-- 			end
-- 		end
-- 	end

-- 	local kill_data = {
-- 		kills = 0,
-- 		headshots = 0,
-- 		civilian_kills = 0
-- 	}
-- 	local hit_result = nil

-- 	for _, col_ray in pairs(ray_hits) do
-- 		local damage = self:get_damage_falloff(damage, col_ray, user_unit)
-- 		hit_result = nil

-- 		if col_ray.unit:character_damage() and not col_ray.unit:character_damage().is_head then
-- 			self._bullet_class:on_collision_effects(col_ray, self._unit, user_unit, damage)
-- 		end

-- 		if damage > 0 then
-- 			hit_result = self._bullet_class:on_collision(col_ray, self._unit, user_unit, damage)
			
-- 			if extra_collisions then
-- 				for idx, extra_col_data in ipairs(extra_collisions) do
-- 					if alive(col_ray.unit) then
-- 						extra_col_data.bullet_class:on_collision(col_ray, self._unit, user_unit, damage * (extra_col_data.dmg_mul or 1))
-- 					end
-- 				end
-- 			end


-- 			hit_result = managers.mutators:modify_value("ShotgunBase:_fire_raycast", hit_result)

-- 			if hit_result and hit_result.type == "death" then
-- 				managers.game_play_central:do_shotgun_push(col_ray.unit, col_ray.position, col_ray.ray, col_ray.distance, user_unit)

-- 				kill_data.kills = kill_data.kills + 1

-- 				if col_ray.body and col_ray.body:name() == Idstring("head") then
-- 					kill_data.headshots = kill_data.headshots + 1
-- 				end

-- 				if col_ray.unit and col_ray.unit:base() and (col_ray.unit:base()._tweak_table == "civilian" or col_ray.unit:base()._tweak_table == "civilian_female") then
-- 					kill_data.civilian_kills = kill_data.civilian_kills + 1
-- 				end
-- 			end
-- 		end
-- 	end

-- 	if dodge_enemies and self._suppression then
-- 		for enemy_data, dis_error in pairs(dodge_enemies) do
-- 			enemy_data.unit:character_damage():build_suppression(suppr_mul * dis_error * self._suppression, self._panic_suppression_chance)
-- 		end
-- 	end

-- 	if not result then
-- 		result = {
-- 			hit_enemy = next(ray_hits) and true or false
-- 		}

-- 		if self._alert_events then
-- 			result.rays = ray_hits
-- 		end
-- 	end

-- 	managers.statistics:shot_fired({
-- 		hit = false,
-- 		weapon_unit = self._unit
-- 	})

-- 	for _, hit in pairs(ray_hits) do
-- 		if hit.unit:in_slot(managers.slot:get_mask("enemies")) then
-- 			managers.statistics:shot_fired({
-- 				skip_bullet_count = true,
-- 				hit = true,
-- 				weapon_unit = self._unit
-- 			})
-- 		end
-- 	end

-- 	for key, data in pairs(tweak_data.achievement.shotgun_single_shot_kills) do
-- 		if data.headshot and data.count <= kill_data.headshots - kill_data.civilian_kills or data.count <= kill_data.kills - kill_data.civilian_kills then
-- 			local should_award = true

-- 			if data.blueprint then
-- 				local missing_parts = false

-- 				for _, part_or_parts in ipairs(data.blueprint) do
-- 					if type(part_or_parts) == "string" then
-- 						if not table.contains(self._blueprint or {}, part_or_parts) then
-- 							missing_parts = true

-- 							break
-- 						end
-- 					else
-- 						local found_part = false

-- 						for _, part in ipairs(part_or_parts) do
-- 							if table.contains(self._blueprint or {}, part) then
-- 								found_part = true

-- 								break
-- 							end
-- 						end

-- 						if not found_part then
-- 							missing_parts = true

-- 							break
-- 						end
-- 					end
-- 				end

-- 				if missing_parts then
-- 					should_award = false
-- 				end
-- 			end

-- 			if should_award then
-- 				managers.achievment:_award_achievement(data, key)
-- 			end
-- 		end
-- 	end

-- 	return result
-- end

-- <oryo: allow Close By Aced rate of fire buff to work on shotguns with magazines when fired in single or burst fire, no longer needed?
-- function ShotgunBase:fire_rate_multiplier()
-- 	local fire_rate_mul = self._fire_rate_multiplier

-- 	local hip_fire_rate_inc = self:is_single_shot() and self._hip_fire_rate_inc
-- 	if hip_fire_rate_inc ~= 0 then
-- 		local user_unit = self._setup and self._setup.user_unit
-- 		local current_state = alive(user_unit) and user_unit:movement() and user_unit:movement()._current_state

-- 		if current_state and not current_state:in_steelsight() then
-- 			fire_rate_mul = fire_rate_mul + 1 - hip_fire_rate_inc
-- 			fire_rate_mul = self:_convert_add_to_mul(fire_rate_mul)
-- 		end
-- 	end

-- 	return fire_rate_mul
-- end
-- oryo>