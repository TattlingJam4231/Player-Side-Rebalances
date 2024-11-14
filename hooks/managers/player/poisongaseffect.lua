function PoisonGasEffect:update(t, dt)
	if self._timer then
		self._timer = self._timer - dt

		if not self._started_fading and self._timer <= self._fade_time then
			World:effect_manager():fade_kill(self._effect)

			self._started_fading = true
		end

		if self._timer <= 0 then
			self._timer = nil

			if alive(self._grenade_unit) and (Network:is_server() or self._grenade_unit:id() == -1) then
				managers.enemy:add_delayed_clbk(
						"PoisonGasEffect" .. tostring(self._grenade_unit:key()), callback(PoisonGasEffect, PoisonGasEffect, "remove_grenade_unit"),
								TimerManager:game():time() + self._dot_data.dot_length + 1
				)
			end
		end

		if self._is_local_player then
			self._damage_tick_timer = self._damage_tick_timer - dt

			if self._damage_tick_timer <= 0 then
				self._damage_tick_timer = self._tweak_data.poison_gas_tick_time or 0.1
				local nearby_units = World:find_units_quick("sphere", self._position, self._range, managers.slot:get_mask("enemies"))

				for _, unit in ipairs(nearby_units) do
					if not self._unit_list[unit:key()] then
						self._unit_list[unit:key()] = true

						-- <oryo: not needed?
						self._dot_data.hurt_animation = not self._dot_data.hurt_animation_chance or math.rand(1) < self._dot_data.hurt_animation_chance
						self._dot_data.apply_hurt_once = true
						self._dot_data.variant = "poison"
						-- oryo>

						local data = {
							unit = unit,
							dot_data = self._dot_data,
							hurt_animation = not self._dot_data.hurt_animation_chance or math.rand(1) < self._dot_data.hurt_animation_chance,
							weapon_id = self._grenade_id,
							weapon_unit = alive(self._grenade_unit) and self._grenade_unit or nil,
							attacker_unit = alive(self._user_unit) and self._user_unit or nil
						}

						managers.dot:add_doted_enemy(data)
					end
				end
			end
		end
	end
end


