function PlayerManager:_on_enter_trigger_happy_event(unit, attack_data)
	local attacker_unit = attack_data.attacker_unit
	local variant = attack_data.variant

	if attacker_unit == self:player_unit() and not self._coroutine_mgr:is_running("trigger_happy") and self:is_current_weapon_of_category("pistol") then
		local data = self:upgrade_value("pistol", "stacking_hit_damage_multiplier", 0)

		if data ~= 0 then
			self._coroutine_mgr:add_coroutine("trigger_happy", PlayerAction.TriggerHappy, self, data.damage_bonus, data.max_stacks, Application:time() + data.max_time)
		end
	end
end

function PlayerManager:_on_enter_ammo_efficiency_event()
	if not self._coroutine_mgr:is_running("ammo_efficiency") then
		local weapon_unit = self:equipped_weapon_unit()

		if weapon_unit and weapon_unit:base():fire_mode() ~= "auto" and weapon_unit:base():is_category("smg", "assault_rifle", "snp") then -- Player-Side Rebalances: burst marker
			self._coroutine_mgr:add_coroutine("ammo_efficiency", PlayerAction.AmmoEfficiency, self, self._ammo_efficiency.headshots, self._ammo_efficiency.ammo, Application:time() + self._ammo_efficiency.time)
		end
	end
end

function PlayerManager:_on_activate_aggressive_reload_event(attack_data)
	if attack_data and attack_data.variant ~= "projectile" then
		local weapon_unit = self:equipped_weapon_unit()

		if weapon_unit then
			local weapon = weapon_unit:base()

			if weapon and weapon:fire_mode() ~= "auto" and weapon:is_category("smg", "assault_rifle", "snp") then -- Player-Side Rebalances: burst marker
				self:activate_temporary_upgrade("temporary", "single_shot_fast_reload")
			end
		end
	end
end