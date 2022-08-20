function TripMineBase:_spawn_environment_fire(user_unit, added_time, range_multiplier)
	local position = self._unit:position()
	local rotation = self._unit:rotation()
	local data = tweak_data.env_effect:trip_mine_fire()
	local normal = self._unit:rotation():y()
	local dir = Vector3()
    data.is_trip_mine = true -- Player-Side Rebalances

	mvector3.set(dir, normal)
	mvector3.multiply(dir, 20)
	mvector3.add(position, dir)
	EnvironmentFire.spawn(position, rotation, data, normal, user_unit, added_time, range_multiplier)
end