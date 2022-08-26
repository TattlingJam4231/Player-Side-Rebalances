function PlayerEquipment:_can_place(eq_id)
	if eq_id == "sentry_gun" then
		local equipment_data = managers.player:selected_equipment()

		if not equipment_data then
			return false
		end

		local min_ammo_cost = SentryGunBase.MIN_DEPLOYEMENT_COST
		local inventory = self._unit:inventory()

		for _, weapon in pairs(inventory:available_selections()) do
			if weapon == inventory._available_selections[inventory._equipped_selection] then
				if weapon.unit:base():get_ammo_ratio() < min_ammo_cost then
					managers.hint:show_hint("sentry_not_enough_ammo_to_place")

					return false
				end
			end
		end
	end

	return true
end

function PlayerEquipment:_sentry_gun_ammo_cost(sentry_uid)
	local equipment_data = managers.player:selected_equipment()

	if not equipment_data then
		return
	end

	local equipment_tweak_data = tweak_data.equipments[equipment_data.equipment]

	if not equipment_tweak_data.ammo_cost then
		return
	end

	local deployement_cost = SentryGunBase.DEPLOYEMENT_COST[managers.player:upgrade_value("sentry_gun", "cost_reduction", 1)]
	local inventory = self._unit:inventory()
	local hud = managers.hud
	self._sentry_ammo_cost = self._sentry_ammo_cost or {}
	self._sentry_ammo_cost[sentry_uid] = self._sentry_ammo_cost[sentry_uid] or {
		{},
		{}
	}

	for index, weapon in pairs(inventory:available_selections()) do
		if weapon == inventory._available_selections[inventory._equipped_selection] then
			local ammo_taken = weapon.unit:base():get_ammo_max() * (1 - deployement_cost)
			
			
			local max_ammo = weapon.unit:base():get_ammo_max()
			local total_ammo = weapon.unit:base():get_ammo_total()
			local ammo = total_ammo - math.floor(max_ammo * (1 - deployement_cost))

			weapon.unit:base():set_ammo_total(ammo)

			local ammo_in_clip = weapon.unit:base():get_ammo_remaining_in_clip()

			if weapon.unit:base():get_ammo_total() < ammo_in_clip then
				weapon.unit:base():set_ammo_remaining_in_clip(ammo)
			end
			
			
			self._sentry_ammo_cost[sentry_uid][index] = ammo_taken
		else
			local ammo_taken = 0
			self._sentry_ammo_cost[sentry_uid][index] = ammo_taken
		end
		hud:set_ammo_amount(index, weapon.unit:base():ammo_info())
	end
end