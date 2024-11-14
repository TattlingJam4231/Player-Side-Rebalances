PlayerAction.AmmoEfficiency = {
	Priority = 1,
	Function = function(player_manager, target_headshots, bullet_refund, target_time)
		local co = coroutine.running()
		local time = Application:time()
		local headshots = 1

		local function on_headshot()
			headshots = headshots + 1

			if headshots >= target_headshots then
				player_manager:on_ammo_increase(bullet_refund)

				target_time = time + player_manager._ammo_efficiency.time
			end
		end


		player_manager:register_message(Message.OnHeadShot, co, on_headshot)

		while time < target_time do
			time = Application:time()
			local weapon_unit = player_manager:equipped_weapon_unit()

			if weapon_unit and (weapon_unit:base():fire_mode() == "auto" or not weapon_unit:base():is_category("smg", "assault_rifle", "snp")) then -- oryo: burst marker
				break
			end

			coroutine.yield(co)
		end

		player_manager:unregister_message(Message.OnHeadShot, co)
	end

}
