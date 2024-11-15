local damage_bullet_original = PlayerDamage.damage_bullet
function PlayerDamage:damage_bullet(attack_data)

	managers.player:set_current_incoming_damage_oryo(attack_data.damage) -- oryo: grab damage for Armorer reduction

	damage_bullet_original(self, attack_data)

	managers.player:cocaine_stack_damage_oryo()

	-- oryo: Running From Death and Up You Go trigger on damaged, can't refresh while active
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
	if type(attack_data.range) == "table" then
		attack_data.range = attack_data.range.max
	end
	managers.player:set_current_incoming_damage_oryo(attack_data.damage) -- oryo: grab damage for Armorer reduction

	damage_explosion_original(self, attack_data)
end


local damage_fire_original = PlayerDamage.damage_fire
function PlayerDamage:damage_fire(attack_data)

	managers.player:set_current_incoming_damage_oryo(attack_data.damage) -- oryo: grab damage for Armorer reduction

	damage_fire_original(self, attack_data)
end


local _calc_armor_damage_original = PlayerDamage._calc_armor_damage
function PlayerDamage:_calc_armor_damage(attack_data)
	local had_armor = true
	if self:get_real_armor() <= 0 then
		had_armor = false
	end
	local health_subtracted = _calc_armor_damage_original(self, attack_data)

	-- <oryo: min damage interval not overrided by higher damage on armor break
	if had_armor and self:get_real_armor() <= 0 then
		self._can_take_dmg_timer = self._dmg_interval > self._can_take_dmg_timer and self._dmg_interval or self._can_take_dmg_timer
	end
	-- oryo>

	return health_subtracted
end


Hooks:PostHook(
		PlayerDamage, "_regenerate_armor", "Oryo PlayerDamage _regenerate_armor", function(self)
			-- <oryo: Yakuza
			managers.player:activate_shallow_grave_revive_oryo()
			-- oryo>
		end
)

Hooks:PostHook(
		PlayerDamage, "_on_enter_swansong_event", "Oryo PlayerDamage _on_enter_swansong_event", function(self)
			-- <oryo: Yakuza
			self._block_shallow_grave = true
			-- oryo>
		end
)

Hooks:PostHook(
		PlayerDamage, "_on_revive_event", "Oryo PlayerDamage _on_revive_event", function(self)
			-- <oryo: Yakuza
			self._block_shallow_grave = false
			-- oryo>
		end
)

local _calc_health_damage_original = PlayerDamage._calc_health_damage
function PlayerDamage:_calc_health_damage(attack_data)
	local current_health = self:get_real_health()

	self:change_health(-attack_data.damage)

	local health_subtracted = current_health - self:get_real_health()
	self:set_health(current_health)

	-- <oryo: grab attack_data and health_subtracted for Shallow Grave
	self:save_last_attack_oryo(attack_data)
	self:save_last_health_loss_oryo(health_subtracted)
	-- oryo>

	return _calc_health_damage_original(self, attack_data)
end


function PlayerDamage:save_last_attack_oryo(attack_data)
	self._last_attack = attack_data
end


function PlayerDamage:get_last_attack_oryo()
	return self._last_attack
end


function PlayerDamage:save_last_health_loss_oryo(health_subtracted)
	self._health_subtracted = health_subtracted
end


function PlayerDamage:get_last_health_loss_oryo()
	return self._health_subtracted
end


local _check_bleed_out_original = PlayerDamage._check_bleed_out
function PlayerDamage:_check_bleed_out(can_activate_berserker, ignore_movement_state, ignore_reduce_revive)
	if self:get_real_health() == 0 and not self._check_berserker_done then
		if self._unit:movement():zipline_unit() then
			self._bleed_out_blocked_by_zipline = true

			return
		end

		if not ignore_movement_state and self._unit:movement():current_state():bleed_out_blocked() then
			self._bleed_out_blocked_by_movement_state = true

			return
		end

		-- <oryo: Yakuza
		if not self._block_shallow_grave and managers.player:has_category_upgrade("temporary", "shallow_grave") and
				not managers.player:active_shallow_grave_oryo() then

			local attack_data = self:get_last_attack_oryo()
			local health_subtracted = self:get_last_health_loss_oryo()

			self._can_take_dmg_timer = managers.player:activate_shallow_grave_oryo(attack_data, health_subtracted) or self._can_take_dmg_timer
			if managers.player:active_shallow_grave_oryo() then
				return
			end
		end
		-- oryo>
	end
	_check_bleed_out_original(self, can_activate_berserker, ignore_movement_state, ignore_reduce_revive)
end


-- <oryo: Ex-President - doesn't overdraw from stored health
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

-- oryo>

local revive_original = PlayerDamage.revive
function PlayerDamage:revive(silent)
	if Application:digest_value(self._revives, false) == 0 then
		self._revive_health_multiplier = nil
		return
	end

	revive_original(self, silent)

	if not self:arrested() then
		-- oryo: Combat Medic and Up You Go work off of max health instead of revive health
		local extra_revive_health = self:_max_health() *
				                            ((self._revive_health_multiplier or 0) + managers.player:upgrade_value("player", "revived_health_regain", 0))
		self:set_health((self:_max_health() * tweak_data.player.damage.REVIVE_HEALTH_STEPS[self._revive_health_i]) + extra_revive_health)
	end
end

