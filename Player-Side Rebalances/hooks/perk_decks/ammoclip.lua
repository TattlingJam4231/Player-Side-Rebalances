local _pickup_original = AmmoClip._pickup
function AmmoClip:_pickup(unit)
	local player_manager = managers.player
	
	local medical_supplies_cooldown = player_manager:has_activate_temporary_upgrade("temporary", "loose_ammo_restore_health")

	local picked_up = _pickup_original(self, unit)

	if picked_up and not self._projectile_id and not self._weapon_category and not unit:character_damage():is_downed()then
		if not medical_supplies_cooldown then
			if player_manager:has_category_upgrade("temporary", "loose_ammo_crit_bonus") then
				player_manager:add_gambler_crit_stack_oryo()
			end
			
			local damage_ext = unit:character_damage()

			if player_manager:has_category_upgrade("player", "loose_ammo_restore_armor") then
				if not damage_ext:need_revive() and not damage_ext:dead() and not damage_ext:is_berserker() then
					damage_ext:restore_armor(player_manager:upgrade_value("player", "loose_ammo_restore_armor", 0) * 0.1)
				end
			end
		elseif player_manager:has_category_upgrade("player", "loose_ammo_restore_health_alt") then
			local restore_value = player_manager:upgrade_value("player", "loose_ammo_restore_health_alt", 0)
			
			local sync_value = restore_value
			restore_value = restore_value * 0.1
			
			local damage_ext = unit:character_damage()

			if not damage_ext:need_revive() and not damage_ext:dead() and not damage_ext:is_berserker() then
				damage_ext:restore_health(restore_value, true)
				damage_ext:restore_armor(player_manager:upgrade_value("player", "loose_ammo_restore_armor", 0) * 0.1)
				unit:sound():play("pickup_ammo_health_boost", nil, true)
			end
			managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "pickup", 2 + sync_value)
		end
	end
	return picked_up
end

local sync_net_event_original = AmmoClip.sync_net_event
function AmmoClip:sync_net_event(event, peer)
	local player = managers.player:local_player()

	if not alive(player) or not player:character_damage() or player:character_damage():is_downed() or player:character_damage():dead() then
		return
	end

	local bonnie_share_ammo = 1
	if event == bonnie_share_ammo then
		local inventory = player:inventory()

		if inventory then
			local picked_up = false

			for id, weapon in pairs(inventory:available_selections()) do
				local give_ammo = math.random()
				if give_ammo < tweak_data.upgrades.loose_ammo_give_team_ratio then
					picked_up = weapon.unit:base():add_ammo(1) or picked_up
				end
			end

			if picked_up then
				player:sound():play(self._pickup_event or "pickup_ammo", nil, true)

				for id, weapon in pairs(inventory:available_selections()) do
					managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
				end
			end
		end
	else
		sync_net_event_original(self, event, peer)
	end
end

