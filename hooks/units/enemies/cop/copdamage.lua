function CopDamage:add_crit_chance_oryo(attack_data)
	local add_crit = 0
	local weapon_unit = attack_data.weapon_unit

	if tostring(weapon_unit) == "[Unit NULL]"  then
		return add_crit
	end

	if attack_data.weapon_unit then
		if weapon_unit and weapon_unit:base() and weapon_unit:base()._ammo_data and weapon_unit:base()._ammo_data.crit_chance then
			add_crit = add_crit + weapon_unit:base()._ammo_data.crit_chance
		end
	end

	return add_crit
end


function CopDamage:get_real_damage_oryo(damage)
	local damage_percent = math.ceil(math.clamp(damage / self._HEALTH_INIT_PRECENT, 1, self._HEALTH_GRANULARITY))
	local real_damage = damage_percent * self._HEALTH_INIT_PRECENT

	return real_damage
end


function CopDamage:is_headshot_oryo(col_ray)
	local headshot = self._head_body_name and col_ray.body and col_ray.body:name() == self._ids_head_body_name

	return headshot
end


function CopDamage:damage_fire(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	if self:is_friendly_fire(attack_data.attacker_unit) then
		return "friendly_fire"
	end

	if self:chk_immune_to_attacker(attack_data.attacker_unit) then
		return
	end

	local result = nil
	local damage = attack_data.damage
	local is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)
	local head = self._head_body_name and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name
	local headshot_multiplier = 1


	-- <oryo
	if attack_data.attacker_unit == managers.player:player_unit() then
		local damage_scale = nil

		if alive(attack_data.weapon_unit) and attack_data.weapon_unit:base() and attack_data.weapon_unit:base().is_weak_hit then
			damage_scale = attack_data.weapon_unit:base():is_weak_hit(attack_data.col_ray and attack_data.col_ray.distance, attack_data.attacker_unit) or 1
		end

		local critical_hit, crit_damage = self:roll_critical_hit(attack_data, damage)

		if critical_hit then
			damage = crit_damage
			attack_data.critical_hit = true
		end

		if attack_data.weapon_unit and attack_data.variant ~= "stun" then
			if critical_hit then
				managers.hud:on_crit_confirmed(damage_scale)
			else
				managers.hud:on_hit_confirmed(damage_scale)
			end
		end

		headshot_multiplier = managers.player:upgrade_value("weapon", "passive_headshot_damage_multiplier", 1)

		if managers.groupai:state():is_enemy_special(self._unit) then
			damage = damage * managers.player:upgrade_value("weapon", "special_damage_taken_multiplier", 1)

			if attack_data.weapon_unit:base().weapon_tweak_data then
				damage = damage * (attack_data.weapon_unit:base():weapon_tweak_data().special_damage_multiplier or 1)
			end
		end

		if head then
			managers.player:on_headshot_dealt()
		end
	end

	local can_headshot = false
	if alive(attack_data.weapon_unit) and attack_data.weapon_unit:base() and attack_data.weapon_unit:base().can_headshot_oryo then
		can_headshot = attack_data.weapon_unit:base():can_headshot_oryo()
	end

	if can_headshot and not self._char_tweak.ignore_headshot and not self._damage_reduction_multiplier and head then
		if self._char_tweak.headshot_dmg_mul then
			damage = damage * self._char_tweak.headshot_dmg_mul * headshot_multiplier
		else
			damage = self._health * 10
		end
	end

	if not head and can_headshot and not self._char_tweak.no_headshot_add_mul and attack_data.weapon_unit:base().get_add_head_shot_mul then
		local add_head_shot_mul = attack_data.weapon_unit:base():get_add_head_shot_mul()

		if add_head_shot_mul then
			if self._char_tweak.headshot_dmg_mul then
				local tweak_headshot_mul = math.max(0, self._char_tweak.headshot_dmg_mul - 1)
				local mul = tweak_headshot_mul * add_head_shot_mul + 1
				damage = damage * mul
			else
				damage = self._health * 10
			end
		end
	end
	-- oryo>


	damage = self:_apply_damage_reduction(damage)
	damage = math.clamp(damage, 0, self._HEALTH_INIT)
	local damage_percent = math.ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then
		damage = math.min(damage, self._health - 1)
	end

	if self._health <= damage then
		if self:check_medic_heal() then
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			attack_data.damage = self._health
			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
			self:chk_killshot(attack_data.attacker_unit, "fire", head, attack_data.weapon_unit and attack_data.weapon_unit:base():get_name_id())
		end
	else
		attack_data.damage = damage
		local result_type = "dmg_rcv"
		result = {
			type = result_type,
			variant = attack_data.variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position
	local attacker = attack_data.attacker_unit

	if not alive(attacker) or attacker:id() == -1 then
		attacker = self._unit
	end

	local attacker_unit = attack_data.attacker_unit

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			owner = attack_data.owner,
			weapon_unit = attack_data.weapon_unit,
			variant = attack_data.variant,
			head_shot = head,
			is_molotov = attack_data.is_molotov
		}

		managers.statistics:killed_by_anyone(data)

		if not is_civilian and managers.player:has_category_upgrade("temporary", "overkill_damage_multiplier") and attacker_unit == managers.player:player_unit() and alive(attack_data.weapon_unit) and not attack_data.weapon_unit:base().thrower_unit and attack_data.weapon_unit:base().is_category and attack_data.weapon_unit:base():is_category("shotgun", "saw") then
			managers.player:activate_temporary_upgrade("temporary", "overkill_damage_multiplier")
		end

		if attacker_unit and alive(attacker_unit) and attacker_unit:base() and attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
			data.weapon_unit = attack_data.attacker_unit
		end

		if attacker_unit == managers.player:player_unit() then
			if alive(attacker_unit) then
				self:_comment_death(attacker_unit, self._unit)
			end

			self:_show_death_hint(self._unit:base()._tweak_table)
			managers.statistics:killed(data)

			if is_civilian then
				managers.money:civilian_killed()
			end

			self:_check_damage_achievements(attack_data, false)
		end
	end

	local weapon_unit = attack_data.weapon_unit or attacker

	if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().add_damage_result then
		weapon_unit:base():add_damage_result(self._unit, result.type == "death", damage_percent)
	end

	local i_result = self._result_type_to_idx.fire[result.type] or 0

	self:_send_fire_attack_result(attack_data, attacker, damage_percent, attack_data.col_ray.ray, i_result)
	self:_on_damage_received(attack_data)

	if not is_civilian and attack_data.attacker_unit and alive(attack_data.attacker_unit) then
		managers.player:send_message(Message.OnEnemyShot, nil, self._unit, attack_data)
	end

	result.attack_data = attack_data

	return result
end


-- <oryo
local damage_dot_original = CopDamage.damage_dot
function CopDamage:damage_dot(attack_data)

	if not alive(attack_data.weapon_unit) then -- oryo: avoid access violation
		attack_data.weapon_unit = nil
	end
	
	if attack_data.attacker_unit == managers.player:player_unit() and attack_data.dot_can_crit and not attack_data.critical_hit then
		local critical_hit, crit_damage = self:roll_critical_hit(attack_data, attack_data.damage)
		if critical_hit then
			attack_data.damage = crit_damage
			attack_data.critical_hit = true
		else
			attack_data.critical_hit = false
		end
	end

	local result = damage_dot_original(self, attack_data)

	attack_data.weapon_unit = attack_data.dot_info.last_weapon_unit

	local is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)
	if result and result.type == "death" and not is_civilian and managers.player:has_category_upgrade("temporary", "overkill_damage_multiplier") and attack_data.attacker_unit == managers.player:player_unit() and alive(attack_data.weapon_unit) and not attack_data.weapon_unit:base().thrower_unit and attack_data.weapon_unit:base().is_category and attack_data.weapon_unit:base():is_category("shotgun", "saw") then
		managers.player:activate_temporary_upgrade("temporary", "overkill_damage_multiplier")
	end

	if attack_data.variant == "fire" then
		local target_base_ext = attack_data.col_ray.unit:base()
		local char_tweak = target_base_ext and target_base_ext.char_tweak and target_base_ext:char_tweak()

		if char_tweak and char_tweak.use_animation_on_fire_damage ~= false then
			local last_fire_t = self:get_last_time_unit_got_fire_damage()
			local t = TimerManager:game():time()

			if not last_fire_t or t - last_fire_t > (--[[ char_tweak.fire_animation_cooldown or ]] 2.5) then
				local result_type = "fire_hurt"
				attack_data.type = result_type
				attack_data.pos = attack_data.col_ray.unit:position()
				result = {
					type = result_type,
					variant = attack_data.variant
				}
				local data = {
					result = result,
					weapon_unit = attack_data.dot_info.last_weapon_unit
				}
				self:force_hurt(data)
			end
		end
	end

	return result
end
-- oryo>


-- <oryo
local damage_bullet_original = CopDamage.damage_bullet
function CopDamage:damage_bullet(attack_data)
	attack_data.hit_unit_max_health = self._HEALTH_INIT -- used for graze damage

	return damage_bullet_original(self, attack_data)
end
-- oryo>


function CopDamage:roll_critical_hit(attack_data, damage)
	damage = damage or attack_data.damage

	if not self:can_be_critical(attack_data) then
		return false, damage
	end
	
	local critical_hits = self._char_tweak.critical_hits or {}
	local critical_hit = false
	local critical_value = CopDamage:add_crit_chance_oryo(attack_data) + (critical_hits.base_chance or 0) + managers.player:critical_hit_chance() * (critical_hits.player_chance_multiplier or 1)

	if critical_value > 0 then
		local critical_roll = math.rand(1)
		critical_hit = critical_roll < critical_value
	end

	if critical_hit then
		local critical_damage_mul = critical_hits.damage_mul or self._char_tweak.headshot_dmg_mul

		if critical_damage_mul then
			damage = damage * critical_damage_mul
		else
			damage = self._health * 10
		end
	end

	return critical_hit, damage
end


function CopDamage:check_medic_heal()
	local unit = self._unit

	if unit:base():has_tag("medic") then -- oryo
		return false
	end

	if unit:anim_data().act then
		return false
	end

	local medic = managers.enemy:get_nearby_medic(unit)

	return medic and medic:character_damage():heal_unit(unit)
end