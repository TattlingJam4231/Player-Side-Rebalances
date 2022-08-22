local damage_bullet_original = PlayerDamage.damage_bullet
function PlayerDamage:damage_bullet(attack_data)

	managers.player:set_current_incoming_damage_oryo(attack_data.damage) -- Player-Side Rebalances: grab damage for Armorer reduction

	damage_bullet_original(self, attack_data)

	managers.player:cocaine_stack_damage_oryo()

	-- Player-Side Rebalances: Running From Death and Up You Go trigger on damaged, can't refresh while active
	if managers.player:has_inactivate_temporary_upgrade("temporary", "revived_damage_resist") then
		managers.player:activate_temporary_upgrade("temporary", "revived_damage_resist")
	end

	if managers.player:has_inactivate_temporary_upgrade("temporary", "increased_movement_speed") then
		managers.player:activate_temporary_upgrade("temporary", "increased_movement_speed")
	end

	if managers.player:has_inactivate_temporary_upgrade("temporary", "swap_weapon_faster") then
		managers.player:activate_temporary_upgrade("temporary", "swap_weapon_faster")
	end

	if managers.player:has_inactivate_temporary_upgrade("temporary", "reload_weapon_faster") then
		managers.player:activate_temporary_upgrade("temporary", "reload_weapon_faster")
	end
end

local damage_explosion_original = PlayerDamage.damage_explosion
function PlayerDamage:damage_explosion(attack_data)

	managers.player:set_current_incoming_damage_oryo(attack_data.damage) -- Player-Side Rebalances: grab damage for Armorer reduction

	damage_explosion_original(self, attack_data)
end

local damage_fire_original = PlayerDamage.damage_fire
function PlayerDamage:damage_fire(attack_data)

	managers.player:set_current_incoming_damage_oryo(attack_data.damage) -- Player-Side Rebalances: grab damage for Armorer reduction

	damage_fire_original(self, attack_data)
end


local _calc_armor_damage_original = PlayerDamage._calc_armor_damage
function PlayerDamage:_calc_armor_damage(attack_data)
	local had_armor = true
	if self:get_real_armor() <= 0 then
		had_armor = false
	end
	local health_subtracted = _calc_armor_damage_original(self, attack_data)

	-- <Player-Side Rebalances: min damage interval not overrided by higher damage on armor break
	if had_armor and self:get_real_armor() <= 0 then
		self._can_take_dmg_timer = self._dmg_interval > self._can_take_dmg_timer and self._dmg_interval or self._can_take_dmg_timer 
	end
	-- Player-Side Rebalances>

	return health_subtracted
end

Hooks:PostHook(PlayerDamage, "_regenerate_armor", "Oryo PlayerDamage _regenerate_armor", function(self)
	-- <Player-Side Rebalances: Yakuza
	managers.player:activate_shallow_grave_revive_oryo()
	-- Player-Side Rebalances>
end)

Hooks:PostHook(PlayerDamage, "_on_enter_swansong_event", "Oryo PlayerDamage _on_enter_swansong_event", function(self)
	-- <Player-Side Rebalances: Yakuza
	self._block_shallow_grave = true
	-- Player-Side Rebalances>
end)

Hooks:PostHook(PlayerDamage, "_on_revive_event", "Oryo PlayerDamage _on_revive_event", function(self)
	-- <Player-Side Rebalances: Yakuza
	self._block_shallow_grave = false
	-- Player-Side Rebalances>
end)

function PlayerDamage:_calc_health_damage(attack_data)
	local health_subtracted = 0
	health_subtracted = self:get_real_health()

	self:change_health(-attack_data.damage)

	health_subtracted = health_subtracted - self:get_real_health()

	if managers.player:has_activate_temporary_upgrade("temporary", "copr_ability") and health_subtracted > 0 then
		local teammate_heal_level = managers.player:upgrade_level_nil("player", "copr_teammate_heal")

		if teammate_heal_level and self:get_real_health() > 0 then
			self._unit:network():send("copr_teammate_heal", teammate_heal_level)
		end
	end

	local trigger_skills = table.contains({
		"bullet",
		"explosion",
		"melee",
		"delayed_tick"
	}, attack_data.variant)

	if self:get_real_health() == 0 and trigger_skills then
		self:_chk_cheat_death()
	end

	self:_damage_screen()
	self:_check_bleed_out(trigger_skills, nil, nil, attack_data, health_subtracted) -- Player-Side Rebalances: added attack_data and health_subtracted
	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})
	self:_send_set_health()
	self:_set_health_effect()
	managers.statistics:health_subtracted(health_subtracted)

	return health_subtracted
end

function PlayerDamage:_check_bleed_out(can_activate_berserker, ignore_movement_state, ignore_reduce_revive, attack_data, health_subtracted) -- Player-Side Rebalances: added attack_data and health_subtracted
	if self:get_real_health() == 0 and not self._check_berserker_done then
		if self._unit:movement():zipline_unit() then
			self._bleed_out_blocked_by_zipline = true

			return
		end

		if not ignore_movement_state and self._unit:movement():current_state():bleed_out_blocked() then
			self._bleed_out_blocked_by_movement_state = true

			return
		end

		if managers.player:has_activate_temporary_upgrade("temporary", "copr_ability") and managers.player:has_category_upgrade("player", "copr_out_of_health_move_slow") then
			return
		end

		local time = Application:time()

		-- <Player-Side Rebalances: Yakuza
		if not self._block_shallow_grave and managers.player:has_category_upgrade("temporary", "shallow_grave") and not managers.player:active_shallow_grave_oryo() then
			self._can_take_dmg_timer = managers.player:activate_shallow_grave_oryo(attack_data, health_subtracted) or self._can_take_dmg_timer
			if managers.player:active_shallow_grave_oryo() then
				return
			end
		end
		-- Player-Side Rebalances>


		if not self._block_medkit_auto_revive and not ignore_reduce_revive and time > self._uppers_elapsed + self._UPPERS_COOLDOWN then
			local auto_recovery_kit = FirstAidKitBase.GetFirstAidKit(self._unit:position())

			if auto_recovery_kit then
				auto_recovery_kit:take(self._unit)
				self._unit:sound():play("pickup_fak_skill")

				self._uppers_elapsed = time

				return
			end
		end

		if can_activate_berserker and not self._check_berserker_done then
			local has_berserker_skill = managers.player:has_category_upgrade("temporary", "berserker_damage_multiplier")

			if has_berserker_skill and not self._disable_next_swansong then
				managers.hud:set_teammate_condition(HUDManager.PLAYER_PANEL, "mugshot_swansong", managers.localization:text("debug_mugshot_downed"))
				managers.player:activate_temporary_upgrade("temporary", "berserker_damage_multiplier")

				self._current_state = nil
				self._check_berserker_done = true

				if alive(self._interaction:active_unit()) and not self._interaction:active_unit():interaction():can_interact(self._unit) then
					self._unit:movement():interupt_interact()
				end

				self._listener_holder:call("on_enter_swansong")
			end

			self._disable_next_swansong = nil
		end

		self._hurt_value = 0.2
		self._damage_to_hot_stack = {}

		managers.environment_controller:set_downed_value(0)
		SoundDevice:set_rtpc("downed_state_progression", 0)

		if not self._check_berserker_done or not can_activate_berserker then
			if not ignore_reduce_revive then
				self._revives = Application:digest_value(Application:digest_value(self._revives, false) - 1, true)

				self:_send_set_revives()
			end
			
			self._check_berserker_done = nil

			managers.environment_controller:set_last_life(Application:digest_value(self._revives, false) <= 1)

			if Application:digest_value(self._revives, false) == 0 then
				self._down_time = 0
			end

			self._bleed_out = true
			self._current_state = nil

			managers.player:set_player_state("bleed_out")

			self._critical_state_heart_loop_instance = self._unit:sound():play("critical_state_heart_loop")
			self._slomo_sound_instance = self._unit:sound():play("downed_slomo_fx")
			self._bleed_out_health = Application:digest_value(tweak_data.player.damage.BLEED_OUT_HEALTH_INIT * managers.player:upgrade_value("player", "bleed_out_health_multiplier", 1), true)

			self:_drop_blood_sample()
			self:on_downed()
		end
	elseif not self._said_hurt and self:get_real_health() / self:_max_health() < 0.2 then
		self._said_hurt = true

		PlayerStandard.say_line(self, "g80x_plu")
	end
end

-- <Player-Side Rebalances: Ex-President
function PlayerDamage:consume_armor_stored_health(amount)
	
	if self._armor_stored_health and not self._dead and not self._bleed_out and not self._check_berserker_done then
		local health_before = self:get_real_health()
		local max_health = self:_max_health() * self._max_health_reduction
		
		self:change_health(self._armor_stored_health)

		self._armor_stored_health = math.max(health_before + self._armor_stored_health - max_health, 0)
	end

	if managers.hud then
		managers.hud:set_stored_health(self._armor_stored_health / self:_max_health())
	end
end
-- Player-Side Rebalances>