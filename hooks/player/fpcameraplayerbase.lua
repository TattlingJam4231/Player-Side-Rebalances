-- <Developer
local function save_recoil(recoil,filename)
	local file,err = io.open(filename, "w")
	if err then return err end

	file:write( "{\n")
	local previous = false
	for _,v in ipairs(recoil) do
		if previous then file:write(",\n") end
		file:write("	{"..tostring(v[1])..","..tostring(v[2]).."}")
		previous = true
	end
	file:write("\n}")
	file:close()
end

local function record_recoil_table()
	if record_recoil > 0 then
		previous_rot = current_rot
		current_rot = {self._camera_properties.pitch, self._camera_properties.spin}
		if previous_rot then
			local vertical_recoil = current_rot[1] - previous_rot[1]
			local horizontal_recoil = current_rot[2] - previous_rot[2]
			
			vertical_recoil = math.round_with_precision(vertical_recoil > 180 and vertical_recoil%-360 or vertical_recoil < -180 and vertical_recoil%360 or vertical_recoil, 2)
			horizontal_recoil = - math.round_with_precision(horizontal_recoil > 180 and horizontal_recoil%-360 or horizontal_recoil < -180 and horizontal_recoil%360 or horizontal_recoil, 2)

			table.insert(recoil,{vertical_recoil,horizontal_recoil})
			record_recoil = record_recoil - 1
		end
		if record_recoil == 0 then
			local file_path = nil
			if file_path then
				save_recoil(recoil, file_path)
			end
		end
	end
end

local record_recoil = 0
local recoil = {}
local current_rot = nil
local previous_rot = nil
-- Developer>

local kick_indices_timer = 0.5

function FPCameraPlayerBase:_update_movement(t, dt)
	local mrot1 = Rotation()
	local mrot2 = Rotation()
	local mrot3 = Rotation()
	local mvec1 = Vector3()
	local mvec2 = Vector3()
	local mvec3 = Vector3()

	local data = self._camera_properties
	local new_head_pos = mvec2
	local new_shoulder_pos = mvec1
	local new_shoulder_rot = mrot1
	local new_head_rot = mrot2

	self._parent_unit:m_position(new_head_pos)

	if _G.IS_VR then
		local hmd_position = mvec1
		local mover_position = mvec3

		mvector3.set(mover_position, new_head_pos)
		mvector3.set(hmd_position, self._parent_movement_ext:hmd_position())
		mvector3.set(new_head_pos, self._parent_movement_ext:ghost_position())
		mvector3.set_x(hmd_position, 0)
		mvector3.set_y(hmd_position, 0)
		mvector3.add(new_head_pos, hmd_position)

		local mover_top = math.max(self._parent_unit:get_active_mover_offset() * 2, 45)

		mvector3.set_z(mover_position, mover_position.z + mover_top)

		self._output_data.mover_position = mvector3.copy(mover_position)

		self:update_recoil_kick_oryo(t, dt)
	else
		mvector3.add(new_head_pos, self._head_stance.translation)

		local stick_input_x = 0
		local stick_input_y = 0
		local aim_assist_x, aim_assist_y = self:_get_aim_assist(t, dt, self._tweak_data.aim_assist_snap_speed, self._aim_assist)
		local x, y = self:update_recoil_kick_oryo(t, dt)
		stick_input_x = stick_input_x + x + aim_assist_x
		stick_input_y = stick_input_y + y + aim_assist_y
		local look_polar_spin = data.spin - stick_input_x
		local look_polar_pitch = math.clamp(data.pitch + stick_input_y, -85, 85)

		if not self._limits or not self._limits.spin then
			look_polar_spin = look_polar_spin % 360
		end

		local look_polar = Polar(1, look_polar_pitch, look_polar_spin)
		local look_vec = look_polar:to_vector()
		local cam_offset_rot = mrot3

		mrotation.set_look_at(cam_offset_rot, look_vec, math.UP)
		mrotation.set_zero(new_head_rot)
		mrotation.multiply(new_head_rot, self._head_stance.rotation)
		mrotation.multiply(new_head_rot, cam_offset_rot)

		data.pitch = look_polar_pitch
		data.spin = look_polar_spin
		self._output_data.rotation = new_head_rot or self._output_data.rotation

		if self._camera_properties.current_tilt ~= self._camera_properties.target_tilt then
			self._camera_properties.current_tilt = math.step(self._camera_properties.current_tilt, self._camera_properties.target_tilt, 150 * dt)
		end

		if self._camera_properties.current_tilt ~= 0 then
			self._output_data.rotation = Rotation(self._output_data.rotation:yaw(), self._output_data.rotation:pitch(), self._output_data.rotation:roll() + self._camera_properties.current_tilt)
		end
	end

	self._output_data.position = new_head_pos

	mvector3.set(new_shoulder_pos, self._shoulder_stance.translation)
	mvector3.add(new_shoulder_pos, self._vel_overshot.translation)
	mvector3.rotate_with(new_shoulder_pos, self._output_data.rotation)
	mvector3.add(new_shoulder_pos, new_head_pos)
	mrotation.set_zero(new_shoulder_rot)
	mrotation.multiply(new_shoulder_rot, self._output_data.rotation)
	mrotation.multiply(new_shoulder_rot, self._shoulder_stance.rotation)
	mrotation.multiply(new_shoulder_rot, self._vel_overshot.rotation)
	self:set_position(new_shoulder_pos)
	self:set_rotation(new_shoulder_rot)
end

Hooks:PostHook(FPCameraPlayerBase, "start_shooting", "Oryo FPCameraPlayerBase start_shooting", function(self)
	self._reduce_kick_indices = nil -- Player-Side Rebalances
end)

Hooks:PostHook(FPCameraPlayerBase, "stop_shooting", "Oryo FPCameraPlayerBase stop_shooting", function(self)
	self._recoil_wait = type(self._recoil_wait) == "number" and {flat = 0, curve = 0} or self._recoil_wait
	self._reduce_kick_indices = true -- Player-Side Rebalances
	self._kick_indices_timer = kick_indices_timer -- Player-Side Rebalances
end)

Hooks:PreHook(FPCameraPlayerBase, "break_recoil", "Oryo FPCameraPlayerBase break_recoil", function(self)
	self._kick_indices = {} -- Player-Side Rebalances
end)

function FPCameraPlayerBase:recoil_kick(up, down, left, right, recoil_table) --added recoil_table

	if recoil_table then
		local kick_table = recoil_table.kick_table
		self._kick_indices = self._kick_indices or {}
		self._kick_indices[recoil_table.weapon_name_id] = self._kick_indices[recoil_table.weapon_name_id] and self._kick_indices[recoil_table.weapon_name_id] + 1 or 1
		local kick_index = math.clamp(math.ceil(self._kick_indices[recoil_table.weapon_name_id]), 1, #kick_table.kicks)
		self._kick_indices[recoil_table.weapon_name_id] = kick_index == #kick_table.kicks and self._kick_indices[recoil_table.weapon_name_id] - kick_table.loop_last or self._kick_indices[recoil_table.weapon_name_id]

		local variance_index = math.clamp(math.inverse_lerp(kick_table.start_variance, kick_table.end_variance, kick_index),0,1)
		local recoil_multiplier = recoil_table.recoil_multiplier * kick_table.state_mul[recoil_table.state] * (kick_table.scale_factor or 1)
		local v_mul = kick_table.v_scale_factor or 1
		local h_mul = kick_table.h_scale_factor or 1

		if math.abs(self._recoil_kick.accumulated) < 100 then 
			local v_variance_low = math.lerp(kick_table.v_variance.starting[1], kick_table.v_variance.ending[1], variance_index)
			local v_variance_high = math.lerp(kick_table.v_variance.starting[2], kick_table.v_variance.ending[2], variance_index)
			local v_variance = math.lerp(v_variance_low, v_variance_high, math.random())

			v = kick_table.kicks[kick_index][1] + v_variance
			v = v * recoil_multiplier * v_mul

			self._recoil_kick.accumulated = (self._recoil_kick.accumulated or 0) + (v * 5 / (5 + self._recoil_kick.accumulated))

		end

		local h_variance_low = math.lerp(kick_table.h_variance.starting[1], kick_table.h_variance.ending[1], variance_index)
		local h_variance_high = math.lerp(kick_table.h_variance.starting[2], kick_table.h_variance.ending[2], variance_index)
		local h_variance = math.lerp(h_variance_low, h_variance_high, math.random())

		local h = kick_table.kicks[kick_index][2] + h_variance
		h = h * recoil_multiplier * h_mul

		local recoil_max = math.abs((self._recoil_kick.h.accumulated or 0) + (h * 5 / (5 + self._recoil_kick.h.accumulated)))
		local recoil_min = math.abs((self._recoil_kick.h.accumulated or 0) + h)
		self._recoil_kick.h.accumulated = recoil_min < recoil_max and (self._recoil_kick.h.accumulated or 0) + h or (self._recoil_kick.h.accumulated or 0) + (h * 5 / (5 + self._recoil_kick.h.accumulated))

	else--original
		if math.abs(self._recoil_kick.accumulated) < 100 --[[ Player-Side Rebalances: changed to 100 from 20 ]] then 
			local v = math.lerp(up, down, math.random())

			self._recoil_kick.accumulated = (self._recoil_kick.accumulated or 0) + (v * 5 / (5 + self._recoil_kick.accumulated)) -- Player-Side Rebalances: added multiplier to v of (5 / (5 + self._recoil_kick.accumulated))

		end

		local h = math.lerp(left, right, math.random())


		-- <Player-Side Rebalances
		local recoil_max = math.abs((self._recoil_kick.h.accumulated or 0) + (h * 5 / (5 + self._recoil_kick.h.accumulated)))
		local recoil_min = math.abs((self._recoil_kick.h.accumulated or 0) + h)
		self._recoil_kick.h.accumulated = recoil_min < recoil_max and (self._recoil_kick.h.accumulated or 0) + h or (self._recoil_kick.h.accumulated or 0) + (h * 5 / (5 + self._recoil_kick.h.accumulated)) -- Player-Side Rebalances: added multiplier to h of (5 / (5 + self._recoil_kick.accumulated)) if horizontal recoil would move camera away from center
		-- Player-Side Rebalances>
	end

end

function FPCameraPlayerBase:update_recoil_kick_oryo(t, dt)
	local player_state = managers.player:current_state()

	if player_state == "bipod" then
		self:break_recoil()

		return 0, 0
	end

	if self._kick_indices and self._reduce_kick_indices then
		if self._recoil_wait and self._recoil_wait.flat > 0 then
			--nothing
		else
			for weapon, index in pairs(self._kick_indices) do
				self._kick_indices[weapon] = math.lerp(0,index,(self._kick_indices_timer-dt)/kick_indices_timer)
			end
		end
	end

	local r_value_v = 0
	local r_value_h = 0

	if (self._recoil_kick.current and self._episilon < math.abs(self._recoil_kick.accumulated - self._recoil_kick.current) --[[ Player-Side Rebalances: checks against absolute value of the difference ]] and 0 < self._recoil_kick.accumulated --[[ Player-Side Rebalances: added check for recoil above 0 ]])
	or (self._recoil_kick.h.current and self._episilon < math.abs(self._recoil_kick.h.accumulated - self._recoil_kick.h.current))
	then
		if self._recoil_kick.current and self._episilon < math.abs(self._recoil_kick.accumulated - self._recoil_kick.current) and 0 < self._recoil_kick.accumulated then
			local n = math.step(self._recoil_kick.current, self._recoil_kick.accumulated, 40 * dt)
			r_value_v = n - self._recoil_kick.current
			self._recoil_kick.current = n
		end
		if self._recoil_kick.h.current and self._episilon < math.abs(self._recoil_kick.h.accumulated - self._recoil_kick.h.current) then
			local n = math.step(self._recoil_kick.h.current, self._recoil_kick.h.accumulated, 40 * dt)
			r_value_h = n - self._recoil_kick.h.current
			self._recoil_kick.h.current = n
		end

	elseif self._recoil_wait and (self._recoil_kick.to_reduce or self._recoil_kick.h.to_reduce) then
		self._recoil_wait.flat = self._recoil_wait.flat - dt

		if self._recoil_wait.flat < 0 then
			self._recoil_wait.curve = self._recoil_wait.curve - dt

			if self._recoil_kick.to_reduce then
				self._recoil_kick.current = nil
				local n = math.lerp(math.max(self._recoil_kick.to_reduce, 0), 0, (9 / (1 + 10 * self._recoil_wait.curve)) * dt)
				r_value_v = -(math.max(self._recoil_kick.to_reduce, 0) - n)
				self._recoil_kick.to_reduce = n

				if self._recoil_kick.to_reduce == 0 then
					self._recoil_kick.to_reduce = nil
				end
			end
			if self._recoil_kick.h.to_reduce then
				self._recoil_kick.h.current = nil
				local n = math.lerp(self._recoil_kick.h.to_reduce, 0, (5 / (1 + self._recoil_wait.curve)) * dt)
				r_value_h = -(self._recoil_kick.h.to_reduce - n)
				self._recoil_kick.h.to_reduce = n

				if self._recoil_kick.h.to_reduce == 0 then
					self._recoil_kick.h.to_reduce = nil
				end
			end

			if self._recoil_wait.curve < 0 then
				self._recoil_wait = nil
			end
		end
	else
		if self._recoil_kick.to_reduce then
			self._recoil_kick.current = nil
			local n = math.lerp(math.max(self._recoil_kick.to_reduce, 0), 0, 9 * dt)
			r_value_v = -(math.max(self._recoil_kick.to_reduce, 0) - n)
			self._recoil_kick.to_reduce = n

			if self._recoil_kick.to_reduce == 0 then
				self._recoil_kick.to_reduce = nil
			end
		end
		if self._recoil_kick.h.to_reduce then
			self._recoil_kick.h.current = nil
			local n = math.lerp(self._recoil_kick.h.to_reduce, 0, 5 * dt)
			r_value_h = -(self._recoil_kick.h.to_reduce - n)
			self._recoil_kick.h.to_reduce = n
	
			if self._recoil_kick.h.to_reduce == 0 then
				self._recoil_kick.h.to_reduce = nil
			end
		end
	end

	return r_value_h, r_value_v
end