local revive_original = PlayerDamage.revive
function PlayerDamage:revive(silent)
	if Application:digest_value(self._revives, false) == 0 then
		self._revive_health_multiplier = nil
		return
	end

	revive_original(self, silent)

	if not self:arrested() then
		-- Player-Side Rebalances: Combat Medic and Up You Go work off of max health instead of revive health
		local extra_revive_health = self:_max_health() * ((self._revive_health_multiplier or 0) + managers.player:upgrade_value("player", "revived_health_regain", 0))
		self:set_health((self:_max_health() * tweak_data.player.damage.REVIVE_HEALTH_STEPS[self._revive_health_i]) + extra_revive_health)
	end
end