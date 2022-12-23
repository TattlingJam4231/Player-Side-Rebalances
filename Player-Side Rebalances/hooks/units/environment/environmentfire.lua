function EnvironmentFire:on_spawn(data, normal, user_unit, added_time, range_multiplier) -- Player-Side Rebalances: ground fires are now always oriented vertically, fire aoe on trip mines is offset so as to maximise area covered
	local custom_params = {
		camera_shake_max_mul = 4,
		sound_muffle_effect = true,
		effect = data.effect_name,
		feedback_range = data.range * 2,
		sound_event = data.sound_event,
		sound_event_impact_duration = data.sound_event_impact_duration,
		sound_event_burning = data.sound_event_burning,
		sound_event_duration = data.burn_duration + added_time,
		sound_event_burning_stop = data.sound_event_burning_stop
	}
	self._data = data
	self._normal = normal
	self._added_time = added_time
	self._range_multiplier = range_multiplier
	self._user_unit = user_unit
	self._burn_duration = data.burn_duration + added_time
	self._burn_duration_destroy = (data.fire_dot_data and data.fire_dot_data.dot_length or 0) + 1
	self._burn_tick_counter = 0
	self._burn_tick_period = data.burn_tick_period
	self._range = data.range * range_multiplier
	self._curve_pow = data.curve_pow
	self._damage = data.damage
	self._player_damage = data.player_damage
	self._fire_dot_data = data.fire_dot_data and deep_clone(data.fire_dot_data)
	self._fire_alert_radius = data.fire_alert_radius
	self._no_fire_alert = data.no_fire_alert
	self._is_molotov = data.is_molotov
	self._hexes = data.hexes or 6
	self._damage_slotmask = data.slotmask or managers.slot:get_mask("explosion_targets")
	local range = self._range
    self._hexes = range > 100 and self._hexes * 3 or self._hexes
	local raycast = nil
	local slotmask = managers.slot:get_mask("molotov_raycasts")
	local vector = nil

	if normal == nil or mvector3.length(normal) < 0.1 then
		normal = Vector3(0, 0, 1)
	end

	local offset = Vector3(normal.z, normal.z, -normal.x - normal.y)
	if offset.x == 0 and offset.y == 0 and offset.z == 0 then
		offset = Vector3(-normal.y - normal.z, normal.x, normal.x)
	end
	mvector3.normalize(offset)

    if data.is_trip_mine then
        local rotation = Rotation()
        local position = self._unit:position()

        -- offset position along normal
        local offset_normal = normal
            -- check for obstructions
            mvector3.set_length(offset_normal, range * 4)
            raycast = World:raycast("ray", position, position + offset_normal, "slot_mask", slotmask)
            if raycast then
                mvector3.set_length(offset_normal, raycast.distance / 2) -- center aoe between obstuction and trip mine position
            else
                mvector3.set_length(offset_normal, range * 2) -- default aoe offset
            end
        position = position + offset_normal

        -- set normal as vertical
        normal = Vector3(0, 0, 1)

        -- calibrate offset to new normal
        offset = Vector3(normal.z, normal.z, -normal.x - normal.y)
        if offset.x == 0 and offset.y == 0 and offset.z == 0 then
            offset = Vector3(-normal.y - normal.z, normal.x, normal.x)
        end
        mvector3.normalize(offset)
        mvector3.multiply(offset, range * 2)
        

        mrotation.set_axis_angle(rotation, normal, 60)

        vector = position + Vector3(0, 0, 0)
        raycast = World:raycast("ray", position, vector, "slot_mask", slotmask)
        local ray_cast2, fake_ball_main = nil

        if raycast == nil then
            local vector21 = vector + Vector3(0, 0, -150)
            raycast = World:raycast("ray", vector + Vector3(0, 0, 20), vector21, "slot_mask", slotmask)

            if raycast == nil then
                local vector31 = vector + Vector3(0, 0, -1500)
                raycast = World:raycast("ray", vector + Vector3(0, 0, 20), vector31, "slot_mask", slotmask)

                if raycast ~= nil then
                    managers.fire:play_sound_and_effects(raycast.position, raycast.normal, range, custom_params, self._molotov_damage_effect_table)

                    ray_cast2 = raycast
                end
            else
                managers.fire:play_sound_and_effects(raycast.position, raycast.normal, range, custom_params, self._molotov_damage_effect_table)

                ray_cast2 = raycast
            end

            if ray_cast2 ~= nil then
                self._molotov_damage_effect_table[1].body = ray_cast2.body
                self._molotov_damage_effect_table[1].body_initial_position = ray_cast2.body:position()
                self._molotov_damage_effect_table[1].body_initial_rotation = ray_cast2.body:rotation()
                self._molotov_damage_effect_table[1].effect_initial_position = ray_cast2.position
                self._molotov_damage_effect_table[1].effect_initial_normal = ray_cast2.normal
            end
        end
        
        if self._hexes > 6 then
            mvector3.multiply(offset, 0.5)
        end

        for i = 1, self._hexes do
            if i == 7 then
                mvector3.multiply(offset, 2)
                mrotation.set_axis_angle(rotation, normal, 30)
                mvector3.rotate_with(offset, rotation)
                -- mrotation.set_axis_angle(rotation, normal, 60)
            end
            vector = position + offset
            raycast = World:raycast("ray", position, vector, "slot_mask", slotmask)
            local ray_cast, fake_ball_outline = nil

            if raycast == nil then
                local vector2 = vector + Vector3(0, 0, -150)
                raycast = World:raycast("ray", vector + Vector3(0, 0, 20), vector2, "slot_mask", slotmask)

                if raycast == nil then
                    local vector3 = vector + Vector3(0, 0, -1500)
                    raycast = World:raycast("ray", vector + Vector3(0, 0, 20), vector3, "slot_mask", slotmask)

                    if raycast ~= nil then
                        managers.fire:play_sound_and_effects(raycast.position, raycast.normal, range, custom_params, self._molotov_damage_effect_table)

                        ray_cast = raycast
                    end
                else
                    managers.fire:play_sound_and_effects(raycast.position, raycast.normal, range, custom_params, self._molotov_damage_effect_table)

                    ray_cast = raycast
                end

                if ray_cast ~= nil then
                    local tableSize = #self._molotov_damage_effect_table
                    self._molotov_damage_effect_table[tableSize].body = ray_cast.body
                    self._molotov_damage_effect_table[tableSize].body_initial_position = ray_cast.body:position()
                    self._molotov_damage_effect_table[tableSize].body_initial_rotation = ray_cast.body:rotation()
                    self._molotov_damage_effect_table[tableSize].effect_initial_position = ray_cast.position
                    self._molotov_damage_effect_table[tableSize].effect_initial_normal = ray_cast.normal
                end
            else
                table.insert(self._molotov_damage_effect_table, nil)
            end

            mvector3.rotate_with(offset, rotation)
        end
    else
        mvector3.multiply(offset, range * 2)

        local rotation = Rotation()
        local position = self._unit:position()

        

        -- find collision direction and set normal as opposite
        local raycast_direction = Vector3(mvector3.x(normal), mvector3.y(normal), mvector3.z(normal))
        mvector3.set_length(raycast_direction, 1000)
        local raycast_vector_1 = position + raycast_direction
        local raycast_vector_2 = position - raycast_direction
        local raycast = World:raycast("ray", position, raycast_vector_1, "slot_mask", slotmask)
        local distance1 = raycast and raycast.distance or 1000
        raycast = World:raycast("ray", position, raycast_vector_2, "slot_mask", slotmask)
        local distance2 = raycast and raycast.distance or 1000
        if distance2 < distance1 then
            normal = raycast_vector_1
            mvector3.normalize(normal)
        else
            normal = raycast_vector_2
            mvector3.normalize(normal)
        end

        -- offset position along normal
        local offset_normal = normal

            -- check for obstructions
            mvector3.set_length(offset_normal, range * 2)
            raycast = World:raycast("ray", position, position + offset_normal, "slot_mask", slotmask)
            if raycast then
                mvector3.set_length(offset_normal, raycast.distance / 2) -- center aoe between obstuction and grenade position
            else
                mvector3.set_length(offset_normal, range) -- default aoe offset
            end
        position = position + offset_normal


        -- set normal as vertical
        normal = Vector3(0, 0, 1)

        -- calibrate offset to new normal
        offset = Vector3(normal.z, normal.z, -normal.x - normal.y)
        if offset.x == 0 and offset.y == 0 and offset.z == 0 then
            offset = Vector3(-normal.y - normal.z, normal.x, normal.x)
        end
        mvector3.normalize(offset)
        mvector3.multiply(offset, range * 2)


        mrotation.set_axis_angle(rotation, normal, 60)

        vector = position + Vector3(0, 0, 0)
        raycast = World:raycast("ray", position, vector, "slot_mask", slotmask)
        local ray_cast2, fake_ball_main = nil
    
        if raycast == nil then
            local vector21 = vector + Vector3(0, 0, -150)
            raycast = World:raycast("ray", vector + Vector3(0, 0, 20), vector21, "slot_mask", slotmask)
    
            if raycast == nil then
                local vector31 = vector + Vector3(0, 0, -1500)
                raycast = World:raycast("ray", vector + Vector3(0, 0, 20), vector31, "slot_mask", slotmask)

                if raycast ~= nil then
                    managers.fire:play_sound_and_effects(raycast.position, raycast.normal, range, custom_params, self._molotov_damage_effect_table)

                    ray_cast2 = raycast
                end
            else
                managers.fire:play_sound_and_effects(raycast.position, raycast.normal, range, custom_params, self._molotov_damage_effect_table)
    
                ray_cast2 = raycast
            end
    
            if ray_cast2 ~= nil then
                self._molotov_damage_effect_table[1].body = ray_cast2.body
                self._molotov_damage_effect_table[1].body_initial_position = ray_cast2.body:position()
                self._molotov_damage_effect_table[1].body_initial_rotation = ray_cast2.body:rotation()
                self._molotov_damage_effect_table[1].effect_initial_position = ray_cast2.position
                self._molotov_damage_effect_table[1].effect_initial_normal = ray_cast2.normal
            end
        end
        
        for i = 1, self._hexes do
            vector = position + offset
            raycast = World:raycast("ray", position, vector, "slot_mask", slotmask)
            local ray_cast, fake_ball_outline = nil
    
            if raycast == nil then
                local vector2 = vector + Vector3(0, 0, -150)
                raycast = World:raycast("ray", vector + Vector3(0, 0, 20), vector2, "slot_mask", slotmask)
    
                if raycast == nil then
                    local vector3 = vector + Vector3(0, 0, -1500)
                    raycast = World:raycast("ray", vector + Vector3(0, 0, 20), vector3, "slot_mask", slotmask)

                    if raycast ~= nil then
                        managers.fire:play_sound_and_effects(raycast.position, raycast.normal, range, custom_params, self._molotov_damage_effect_table)

                        ray_cast = raycast
                    end
                else
                    managers.fire:play_sound_and_effects(raycast.position, raycast.normal, range, custom_params, self._molotov_damage_effect_table)
    
                    ray_cast = raycast
                end
    
                if ray_cast ~= nil then
                    local tableSize = #self._molotov_damage_effect_table
                    self._molotov_damage_effect_table[tableSize].body = ray_cast.body
                    self._molotov_damage_effect_table[tableSize].body_initial_position = ray_cast.body:position()
                    self._molotov_damage_effect_table[tableSize].body_initial_rotation = ray_cast.body:rotation()
                    self._molotov_damage_effect_table[tableSize].effect_initial_position = ray_cast.position
                    self._molotov_damage_effect_table[tableSize].effect_initial_normal = ray_cast.normal
                end
            else
                table.insert(self._molotov_damage_effect_table, nil)
            end
    
            mvector3.rotate_with(offset, rotation)
        end
    end

	self._unit:set_visible(false)
end