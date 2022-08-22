function PlayerDamage:revive(silent)
	if Application:digest_value(self._revives, false) == 0 then
		self._revive_health_multiplier = nil

		return
	end

	local arrested = self:arrested()

	managers.player:set_player_state("standard")
	managers.player:remove_copr_risen_cooldown()

	if not silent then
		PlayerStandard.say_line(self, "s05x_sin")
	end

	self._bleed_out = false
	self._incapacitated = nil
	self._downed_timer = nil
	self._downed_start_time = nil

	if not arrested then

        -- Player-Side Rebalances: Combat Medic and Up You Go work off of max health instead of revive health
		local extra_revive_health = self:_max_health() * ((self._revive_health_multiplier or 0) + managers.player:upgrade_value("player", "revived_health_regain", 0))
		self:set_health((self:_max_health() * tweak_data.player.damage.REVIVE_HEALTH_STEPS[self._revive_health_i]) + extra_revive_health)
		
        self:set_armor(self:_max_armor())

		self._revive_health_i = math.min(#tweak_data.player.damage.REVIVE_HEALTH_STEPS, self._revive_health_i + 1)
		self._revive_miss = 2
	end

	self:_regenerate_armor()
	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})
	self:_send_set_health()
	self:_set_health_effect()
	managers.hud:pd_stop_progress()

	self._revive_health_multiplier = nil

	self._listener_holder:call("on_revive")

	managers.player:activate_temporary_upgrade("temporary", "revived_damage_resist")
	managers.player:activate_temporary_upgrade("temporary", "increased_movement_speed")
	managers.player:activate_temporary_upgrade("temporary", "swap_weapon_faster")
	managers.player:activate_temporary_upgrade("temporary", "reload_weapon_faster")
end