PlayerAction.UnseenStrike = {
	Priority = 1,
	Function = function (player_manager, min_time, max_duration, crit_chance)
		local co = coroutine.running()
		local current_time = Application:time()
		local target_time = Application:time() + min_time
		local end_time = nil
		local can_activate = true

		local function on_damage_taken()
			target_time = end_time and end_time + min_time or Application:time() + min_time
		end

		player_manager:register_message(Message.OnPlayerDamage, co, on_damage_taken)

		while true do
			current_time = Application:time()

			if target_time <= current_time then
				managers.player:activate_temporary_upgrade("temporary", "unseen_strike")
				end_time = current_time + max_duration
			end

			coroutine.yield(co)
		end

		player_manager:unregister_message(Message.OnPlayerDamage, co)
	end
}