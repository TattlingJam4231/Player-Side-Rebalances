function RaycastWeaponBase:_collect_hits(from, to, user_unit)
	local ray_hits = nil
	local hit_enemy = false
	local enemy_mask = managers.slot:get_mask("enemies")
	local wall_mask = managers.slot:get_mask("world_geometry", "vehicles")
	local shield_mask = managers.slot:get_mask("enemy_shield_check")
	local ai_vision_ids = Idstring("ai_vision")
	local bulletproof_ids = Idstring("bulletproof")
	
	local units_hit = {}
	local unique_hits = {}


	-- <Player-Side Rebalances
	local weapon_unit = self._unit
	local armor_piercing = weapon_unit:base()._use_armor_piercing or nil
	local pierce_armor = armor_piercing
	
	local penetrations = 0
	local enemy_penetrations = 0
	local wall_penetrations = 0
	local prev_hit_wall = {}
	local shield_penetrations = 0
	local energy_loss = 0

	if self._can_shoot_through_armor_plating then

		ray_hits = World:raycast_wall("ray", from, to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "thickness", 40, "thickness_mask", wall_mask)
		
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

		ray_hits = World:raycast_wall("ray", from, to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "thickness", 40, "thickness_mask", wall_mask)
	-- Player-Side Rebalances>


	elseif self._can_shoot_through_wall then
		ray_hits = World:raycast_wall("ray", from, to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "thickness", 40, "thickness_mask", wall_mask)
	else
		ray_hits = World:raycast_all("ray", from, to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
	end
	
	for i, hit in ipairs(ray_hits) do
		if not units_hit[hit.unit:key()] then
			units_hit[hit.unit:key()] = true


			-- <Player-Side Rebalances
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
			-- Player-Side Rebalances>


			unique_hits[#unique_hits + 1] = hit
			hit.hit_position = hit.position
			hit_enemy = hit_enemy or hit.unit:in_slot(enemy_mask)
			local weak_body = hit.body:has_ray_type(ai_vision_ids)
			weak_body = weak_body or hit.body:has_ray_type(bulletproof_ids)
			

			-- <Player-Side Rebalances
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
			-- Player-Side Rebalances>


		end
	end

	return unique_hits, hit_enemy
end

function RaycastWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul)
	if self:gadget_overrides_weapon_functions() then
		return self:gadget_function_override("_fire_raycast", self, user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul)
	end
	local result = {}
	local spread_x, spread_y = self:_get_spread(user_unit)
	local ray_distance = self:weapon_range()
	local right = direction:cross(Vector3(0, 0, 1)):normalized()
	local up = direction:cross(right):normalized()
	local theta = math.random() * 360
	local ax = math.sin(theta) * math.random() * spread_x * (spread_mul or 1)
	local ay = math.cos(theta) * math.random() * spread_y * (spread_mul or 1)

	local mvec_to = Vector3()
	local mvec_spread_direction = Vector3()
	mvector3.set(mvec_spread_direction, direction)
	mvector3.add(mvec_spread_direction, right * math.rad(ax))
	mvector3.add(mvec_spread_direction, up * math.rad(ay))
	mvector3.set(mvec_to, mvec_spread_direction)
	mvector3.multiply(mvec_to, ray_distance)
	mvector3.add(mvec_to, from_pos)

	local base_damage = self:_get_current_damage(dmg_mul)
	local damage = 0
	local ray_hits, hit_enemy = self:_collect_hits(from_pos, mvec_to, user_unit) -- Player-Side Rebalances: added user_unit
	local hit_anyone = false
	local auto_hit_candidate, suppression_enemies = self:check_autoaim(from_pos, direction)

	if suppression_enemies and self._suppression then
		result.enemies_in_cone = suppression_enemies
	end

	if self._autoaim then
		local weight = 0.1

		if auto_hit_candidate and not hit_enemy then
			local autohit_chance = 1 - math.clamp((self._autohit_current - self._autohit_data.MIN_RATIO) / (self._autohit_data.MAX_RATIO - self._autohit_data.MIN_RATIO), 0, 1)

			if autohit_mul then
				autohit_chance = autohit_chance * autohit_mul
			end

			if math.random() < autohit_chance then
				self._autohit_current = (self._autohit_current + weight) / (1 + weight)

				mvector3.set(mvec_to, from_pos)
				mvector3.add_scaled(mvec_to, auto_hit_candidate.ray, ray_distance)

				ray_hits, hit_enemy = self:_collect_hits(from_pos, mvec_to, user_unit) -- Player-Side Rebalances: added user_unit
			end
		end

		if hit_enemy then
			self._autohit_current = (self._autohit_current + weight) / (1 + weight)
		elseif auto_hit_candidate then
			self._autohit_current = self._autohit_current / (1 + weight)
		end
	end

	local hit_count = 0
	local cop_kill_count = 0
	local hit_through_wall = false
	local hit_through_shield = false
	local hit_result = nil

	for _, hit in ipairs(ray_hits) do
		damage = self:get_damage_falloff(base_damage, hit, user_unit)
		hit_result = nil

		if damage > 0 then
			hit_result = self._bullet_class:on_collision(hit, self._unit, user_unit, damage)
		end

		if hit_result and hit_result.type == "death" then
			local unit_type = hit.unit:base() and hit.unit:base()._tweak_table
			local is_civilian = unit_type and CopDamage.is_civilian(unit_type)

			if not is_civilian then
				cop_kill_count = cop_kill_count + 1
			end

			if self:is_category(tweak_data.achievement.easy_as_breathing.weapon_type) and not is_civilian then
				self._kills_without_releasing_trigger = (self._kills_without_releasing_trigger or 0) + 1

				if tweak_data.achievement.easy_as_breathing.count <= self._kills_without_releasing_trigger then
					managers.achievment:award(tweak_data.achievement.easy_as_breathing.award)
				end
			end
		end

		if hit_result then
			hit.damage_result = hit_result
			hit_anyone = true
			hit_count = hit_count + 1
		end

		if hit.unit:in_slot(managers.slot:get_mask("world_geometry")) then
			hit_through_wall = true
		elseif hit.unit:in_slot(managers.slot:get_mask("enemy_shield_check")) then
			hit_through_shield = hit_through_shield or alive(hit.unit:parent())
		end

		if hit_result and hit_result.type == "death" and cop_kill_count > 0 then
			local unit_type = hit.unit:base() and hit.unit:base()._tweak_table
			local multi_kill, enemy_pass, obstacle_pass, weapon_pass, weapons_pass, weapon_type_pass = nil

			for achievement, achievement_data in pairs(tweak_data.achievement.sniper_kill_achievements) do
				multi_kill = not achievement_data.multi_kill or cop_kill_count == achievement_data.multi_kill
				enemy_pass = not achievement_data.enemy or unit_type == achievement_data.enemy
				obstacle_pass = not achievement_data.obstacle or achievement_data.obstacle == "wall" and hit_through_wall or achievement_data.obstacle == "shield" and hit_through_shield
				weapon_pass = not achievement_data.weapon or self._name_id == achievement_data.weapon
				weapons_pass = not achievement_data.weapons or table.contains(achievement_data.weapons, self._name_id)
				weapon_type_pass = not achievement_data.weapon_type or self:is_category(achievement_data.weapon_type)

				if multi_kill and enemy_pass and obstacle_pass and weapon_pass and weapons_pass and weapon_type_pass then
					if achievement_data.stat then
						managers.achievment:award_progress(achievement_data.stat)
					elseif achievement_data.award then
						managers.achievment:award(achievement_data.award)
					elseif achievement_data.challenge_stat then
						managers.challenge:award_progress(achievement_data.challenge_stat)
					elseif achievement_data.trophy_stat then
						managers.custom_safehouse:award(achievement_data.trophy_stat)
					elseif achievement_data.challenge_award then
						managers.challenge:award(achievement_data.challenge_award)
					end
				end
			end
		end
	end

	if not tweak_data.achievement.tango_4.difficulty or table.contains(tweak_data.achievement.tango_4.difficulty, Global.game_settings.difficulty) then
		if self._gadgets and table.contains(self._gadgets, "wpn_fps_upg_o_45rds") and cop_kill_count > 0 and managers.player:player_unit():movement():current_state():in_steelsight() then
			if self._tango_4_data then
				if self._gadget_on == self._tango_4_data.last_gadget_state then
					self._tango_4_data = nil
				else
					self._tango_4_data.last_gadget_state = self._gadget_on
					self._tango_4_data.count = self._tango_4_data.count + 1
				end

				if self._tango_4_data and tweak_data.achievement.tango_4.count <= self._tango_4_data.count then
					managers.achievment:_award_achievement(tweak_data.achievement.tango_4, "tango_4")
				end
			else
				self._tango_4_data = {
					count = 1,
					last_gadget_state = self._gadget_on
				}
			end
		elseif self._tango_4_data then
			self._tango_4_data = nil
		end
	end

	result.hit_enemy = hit_anyone

	if self._autoaim then
		self._shot_fired_stats_table.hit = hit_anyone
		self._shot_fired_stats_table.hit_count = hit_count

		if (not self._ammo_data or not self._ammo_data.ignore_statistic) and not self._rays then
			managers.statistics:shot_fired(self._shot_fired_stats_table)
		end
	end

	local furthest_hit = ray_hits[#ray_hits]

	if (furthest_hit and furthest_hit.distance > 600 or not furthest_hit) and alive(self._obj_fire) then
		self._obj_fire:m_position(self._trail_effect_table.position)
		mvector3.set(self._trail_effect_table.normal, mvec_spread_direction)

		local trail = World:effect_manager():spawn(self._trail_effect_table)

		if furthest_hit then
			World:effect_manager():set_remaining_lifetime(trail, math.clamp((furthest_hit.distance - 600) / 10000, 0, furthest_hit.distance))
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

	local function _add_ammo(ammo_base, ratio, add_amount_override)
		if ammo_base:get_ammo_max() == ammo_base:get_ammo_total() then
			return false, 0
		end

		local multiplier = 1
		local multiplier_min = 1
		local multiplier_max = 1


		-- <Player-Side Rebalances
		multiplier = managers.player:upgrade_value("player", "pick_up_ammo_multiplier", 1)
		multiplier = multiplier * managers.player:upgrade_value("player", "pick_up_ammo_multiplier_2", 1) -- Player-Side Rebalances: fully loaded aced stacks multiplicatively with walk-in closet
		multiplier = multiplier * managers.player:crew_ability_upgrade_value("crew_scavenge", 1) -- Player-Side Rebalances: sharpeyed stacks multiplicatively

		if ammo_base._ammo_data and ammo_base._ammo_data.ammo_pickup_min_mul then
			multiplier_min = multiplier * ammo_base._ammo_data.ammo_pickup_min_mul -- Player-Side Rebalances: pick up modifiers from attachments don't negate pick up modifiers from skills and perks, stacks multiplicatively
		else
			multiplier_min = multiplier
		end

		if ammo_base._ammo_data and ammo_base._ammo_data.ammo_pickup_max_mul then
			multiplier_max = multiplier * ammo_base._ammo_data.ammo_pickup_max_mul
		else
			multiplier_max = multiplier
		end
		-- Player-Side Rebalances>


		local add_amount = add_amount_override
		local picked_up = true

		if not add_amount then


			-- <Player-Side Rebalances
			local min_ammo_pickup = ammo_base._ammo_pickup[1]
			local max_ammo_pickup = ammo_base._ammo_pickup[2]
			local rng_ammo = 0

			if max_ammo_pickup < 1 and (min_ammo_pickup + 0.5) == max_ammo_pickup then -- Player-Side Rebalances: exception for very low pickup values
				rng_ammo = math.lerp(min_ammo_pickup * multiplier_min, (max_ammo_pickup - 0.5) * multiplier_max + 0.5 * (multiplier_max == 0 and 0 or 1), math.random())
			else
			-- Player-Side Rebalances>


				rng_ammo = math.lerp(min_ammo_pickup * multiplier_min, max_ammo_pickup * multiplier_max, math.random())
			end
			picked_up = rng_ammo > 0
			add_amount = math.max(0, math.round(rng_ammo))
		end

		add_amount = math.floor(add_amount * (ratio or 1))

		ammo_base:set_ammo_total(math.clamp(ammo_base:get_ammo_total() + add_amount, 0, ammo_base:get_ammo_max()))

		return picked_up, add_amount
	end



	-- <Player-Side Rebalances
	local gadget_ammo = nil
	for _, gadget in ipairs(self:get_all_override_weapon_gadgets()) do
		if gadget and gadget.ammo_base then
			gadget_ammo = gadget:ammo_base()
		end
	end

	local main_ammo_ratio = self:get_ammo_total() / self:get_ammo_max()
	local gadget_ammo_ratio = gadget_ammo and gadget_ammo:get_ammo_total() / gadget_ammo:get_ammo_max() or 1

	local picked_up, add_amount = nil

	if math.random() > main_ammo_ratio or gadget_ammo_ratio >= 1 then -- Player-Side Rebalances: underbarrels no longer roll for ammo pickup simultaneously with main gun
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
	-- Player-Side Rebalances>

	return picked_up, add_amount
end

function InstantBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank, no_sound)

	local MIN_KNOCK_BACK = 200
	local KNOCK_BACK_CHANCE = 0.8

	local hit_unit = col_ray.unit
	local shield_knock = false
	local is_shield = hit_unit:in_slot(8) and alive(hit_unit:parent())

	if is_shield and not hit_unit:parent():character_damage():is_immune_to_shield_knockback() and weapon_unit then
		shield_knock = weapon_unit:base()._shield_knock
		local dmg_ratio = math.min(damage, MIN_KNOCK_BACK)
		dmg_ratio = dmg_ratio / MIN_KNOCK_BACK + 1
		local rand = math.random() * dmg_ratio

		if KNOCK_BACK_CHANCE < rand then
			local enemy_unit = hit_unit:parent()

			if shield_knock and enemy_unit:character_damage() then
				local damage_info = {
					damage = 0,
					type = "shield_knock",
					variant = "melee",
					col_ray = col_ray,
					result = {
						variant = "melee",
						type = "shield_knock"
					}
				}

				enemy_unit:character_damage():_call_listeners(damage_info)
			end
		end
	end

	local play_impact_flesh = not hit_unit:character_damage() or not hit_unit:character_damage()._no_blood

	if hit_unit:damage() and managers.network:session() and col_ray.body:extension() and col_ray.body:extension().damage then
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

	if alive(weapon_unit) and hit_unit:character_damage() and hit_unit:character_damage().damage_bullet then
		local is_alive = not hit_unit:character_damage():dead()
		local knock_down = weapon_unit:base()._knock_down and weapon_unit:base()._knock_down > 0 and math.random() < weapon_unit:base()._knock_down
		result = self:give_impact_damage(col_ray, weapon_unit, user_unit, damage, col_ray.armor_piercing --[[ Player-Side Rebalances: changed from weapon_unit:base()._use_armor_piercing ]], false, knock_down, weapon_unit:base()._stagger, weapon_unit:base()._variant)

		if result ~= "friendly_fire" then
			local is_dead = hit_unit:character_damage():dead()
			local push_multiplier = self:_get_character_push_multiplier(weapon_unit, is_alive and is_dead)

			managers.game_play_central:physics_push(col_ray, push_multiplier)
		else
			play_impact_flesh = false
		end
	else
		managers.game_play_central:physics_push(col_ray)
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
	InstantExplosiveBulletBase.CURVE_POW = 1 -- Player-Side Rebalances: Changed from 0.5
	-- InstantExplosiveBulletBase.PLAYER_DMG_MUL = 0.1
	InstantExplosiveBulletBase.RANGE = {max = 200, falloff_start = 100} -- Player-Side Rebalances: added falloff_start

	he_stats = true
end