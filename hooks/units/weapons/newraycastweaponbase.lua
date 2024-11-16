local update_reloading_original = NewRaycastWeaponBase.update_reloading
function NewRaycastWeaponBase:update_reloading(t, dt, time_left)

	-- <oryo
	if self._use_shotgun_reload and self._next_shell_reloded_t and self._next_shell_reloded_t < t and self._use_shotgun_reload == "dual" then
		local speed_multiplier = self:reload_speed_multiplier()
		self._next_shell_reloded_t = self._next_shell_reloded_t + self:reload_shell_expire_t(not self._started_reload_empty) / speed_multiplier
		self:set_ammo_remaining_in_clip(math.min(self:get_ammo_max_per_clip(), self:get_ammo_remaining_in_clip() + math.min(2, self:get_ammo_total() - self:get_ammo_remaining_in_clip())))
		self:update_ammo_objects()
	
		return true
	end
	-- oryo>

	return update_reloading_original(self, t, dt, time_left)
end

local reload_expire_t_original = NewRaycastWeaponBase.reload_expire_t
function NewRaycastWeaponBase:reload_expire_t(is_not_empty)

	-- <oryo
	if self._use_shotgun_reload and self._use_shotgun_reload == "dual" then
		local ammo_total = self:get_ammo_total()
		local ammo_max_per_clip = self:get_ammo_max_per_clip()
		local ammo_remaining_in_clip = self:get_ammo_remaining_in_clip()
		local reload_shell_expire_t = self:reload_shell_expire_t(is_not_empty)
		return math.ceil(math.min(ammo_total - ammo_remaining_in_clip, ammo_max_per_clip - ammo_remaining_in_clip) / 2) * reload_shell_expire_t
	end
	-- oryo>

	return reload_expire_t_original(self, is_not_empty)
end

Hooks:PostHook(NewRaycastWeaponBase, "start_reload", "Oryo NewRaycastWeaponBase start_reload", function(self)
	if self._use_shotgun_reload then
		local t = managers.player:player_timer():time()
		self._reload_interupt_grace =  t + (self._next_shell_reloded_t - t) / self._current_reload_speed_multiplier * 0
	end
end)

local reload_interuptable_original = NewRaycastWeaponBase.reload_interuptable
function NewRaycastWeaponBase:reload_interuptable()
	if self._use_shotgun_reload and not self._skip_reload_shotgun_shell then
		if self._reload_interupt_grace and self._reload_interupt_grace < managers.player:player_timer():time() then
			return true
		else
			return false
		end
	end

	return reload_interuptable_original
end

Hooks:PostHook(NewRaycastWeaponBase, "on_reload_stop", "Oryo NewRaycastWeaponBase on_reload_stop", function(self)
	self._reload_interupt_grace = nil
	
	if managers.player:get_current_state() then
		managers.player:get_current_state():empty_reload_interupt_queue_oryo()
	end
end)

function NewRaycastWeaponBase:recoil_wait() -- oryo: rewritten
	local recoil_wait = self:weapon_tweak_data().recoil_wait or {pause = 1, accel = 1}
	local multiplier_pause = recoil_wait.pause or 0
	local multiplier_accel = recoil_wait.accel or 0
	local fire_rate = self:weapon_tweak_data().fire_mode_data.fire_rate
	local wait = {
		pause = fire_rate * multiplier_pause,
		accel = fire_rate * multiplier_accel
	}
	return wait
end

local zoom_original = NewRaycastWeaponBase.zoom
function NewRaycastWeaponBase:zoom(...)

	-- <oryo
	if self._magnification then
		local magnification = self._magnification

		local width = 960
		local base_fov = 63
		local focal_length = width / math.tan(base_fov / 2)

		local second_sight = self:get_active_second_sight()
		if second_sight then
			local gadget_magnification = tweak_data.weapon.factory.parts[second_sight.part_id].stats.gadget_magnification
			local gadget_magnification_mul = tweak_data.weapon.factory.parts[second_sight.part_id].stats.gadget_magnification_mul

			if gadget_magnification_mul then
				magnification = 2 * math.atan(width / (focal_length * magnification * gadget_magnification_mul))
			elseif gadget_magnification then
				magnification = 2 * math.atan(width / (focal_length * gadget_magnification))
			end
		else
			magnification = 2 * math.atan(width / (focal_length * magnification))
		end
		return magnification
	end
	-- oryo>

	return zoom_original(self, ...)
end

-- <oryo: burst counts as single shot
function NewRaycastWeaponBase:is_single_shot()
	if self:gadget_overrides_weapon_functions() then
		local gadget_shot = self:gadget_function_override("is_single_shot")

		if gadget_shot ~= nil then
			return gadget_shot
		end
	end

	return self:fire_mode() == "single" or self:fire_mode() == "burst"
end
-- oryo>

function NewRaycastWeaponBase:conditional_accuracy_multiplier(current_state)
	local mul = 1

	if not current_state then
		return mul
	end

	local pm = managers.player

	if current_state:in_steelsight() and self:is_single_shot()  and self:is_category("assault_rifle", "smg", "snp") then -- oryo: fixed vanilla bug where marksman aced affected all weapon categories
		mul = mul + 1 - pm:upgrade_value("player", "single_shot_accuracy_inc", 1)
	end

	if current_state:in_steelsight() then
		for _, category in ipairs(self:categories()) do
			mul = mul + 1 - managers.player:upgrade_value(category, "steelsight_accuracy_inc", 1)
		end
	end

	if current_state._moving then
		mul = mul + 1 - pm:upgrade_value("player", "weapon_movement_stability", 1)
	end

	mul = mul + 1 - pm:get_property("desperado", 1)

	return self:_convert_add_to_mul(mul)
end

local get_add_head_shot_mul_original = NewRaycastWeaponBase.get_add_head_shot_mul
function NewRaycastWeaponBase:get_add_head_shot_mul(...)

	-- <oryo: ammo can provide body expertise effect
	if self._ammo_data and self._ammo_data.add_head_shot_mul then
		return self._ammo_data.add_head_shot_mul
	end
	-- oryo>

	return get_add_head_shot_mul_original(self, ...)
end

-- <oryo: fixed vanilla bug where weapon attachments modified unused "_near_multiplier" and "_far_multiplier" values instead of "_near_mul" and "_far_mul", no longer needed?
-- Hooks:PostHook(NewRaycastWeaponBase, "_default_damage_falloff", "Oryo NewRaycastWeaponBase _default_damage_falloff", function(self)
-- 	self._near_multiplier = self._near_mul
-- 	self._far_multiplier = self._far_mul
-- end)

-- function NewRaycastWeaponBase:_fix_damage_falloff_modify_oryo()
-- 	self._near_mul = self._near_multiplier
-- 	self._far_mul = self._far_multiplier
-- end
-- oryo>

Hooks:PostHook(NewRaycastWeaponBase, "_update_stats_values", "Oryo NewRaycastWeaponBase _update_stats_values", function(self, disallow_replenish, ammo_data)

	--[[ self:_fix_damage_falloff_modify_oryo() ]] -- oryo: bug fix, see above

	self:_get_penetration_stats_oryo()
	self:_update_penetration_stats_oryo()
	self:_update_fire_mode_data_oryo() -- oryo: attachments can restrict to multiple fire modes instead of just one

	local parts_stats = managers.weapon_factory:get_stats(self._factory_id, self._blueprint)

	local spread_multiplier = tweak_data.weapon[self._name_id].spread_multiplier
	if parts_stats then
		if parts_stats.spread_multi then
			self._spread_multiplier = spread_multiplier and {spread_multiplier[1] * parts_stats.spread_multi[1], spread_multiplier[2] * parts_stats.spread_multi[2]} or parts_stats.spread_multi
		end

		if parts_stats.magazine_add then
			self.extra_ammo = self.extra_ammo + math.floor(parts_stats.magazine_add)
		end

		if parts_stats.total_ammo_add then
			self._total_ammo_add = parts_stats.total_ammo_add
		end
	end
	
	if parts_stats and parts_stats.magnification then
		self._magnification = parts_stats.magnification
	end

	if not disallow_replenish  and managers.weapon_factory:get_factory_id_by_weapon_id(self._name_id) then
		self:replenish()
	end
	self._spread_multiplier = spread_multiplier or	self._spread_multiplier
	
end)

local replenish_original = NewRaycastWeaponBase.replenish
function NewRaycastWeaponBase:replenish(...)
	replenish_original(self, ...)

	local total_ammo_add = self._total_ammo_add or 0 -- oryo
	local ammo_max = self:get_ammo_max() + total_ammo_add

	self:set_ammo_max(ammo_max)
	self:set_ammo_total(ammo_max)
end

function NewRaycastWeaponBase:_get_penetration_stats_oryo()

	self._can_shoot_through_armor_plating = tweak_data.weapon[self._name_id].can_shoot_through_armor_plating

	self._max_enemy_penetration_distance = tweak_data.weapon[self._name_id].max_enemy_penetration_distance
	self._enemy_pen_energy_loss = tweak_data.weapon[self._name_id].enemy_pen_energy_loss

	self._max_wall_penetration_distance = tweak_data.weapon[self._name_id].max_wall_penetration_distance
	self._wall_pen_energy_loss = tweak_data.weapon[self._name_id].wall_pen_energy_loss

	self._max_shield_penetration_distance = tweak_data.weapon[self._name_id].max_shield_penetration_distance
	self._shield_pen_energy_loss = tweak_data.weapon[self._name_id].shield_pen_energy_loss

	self._max_penetration_distance = tweak_data.weapon[self._name_id].max_penetration_distance
	self._pen_energy_loss = tweak_data.weapon[self._name_id].pen_energy_loss

end

function NewRaycastWeaponBase:_update_penetration_stats_oryo()
	if self._ammo_data then

		if self._ammo_data.can_shoot_through_armor_plating ~= nil then
			self._can_shoot_through_armor_plating = self._ammo_data.can_shoot_through_armor_plating
		end


		if self._ammo_data.max_enemy_penetration_distance ~= nil then
			self._max_enemy_penetration_distance = self._ammo_data.max_enemy_penetration_distance
		end
		if self._ammo_data.enemy_pen_energy_loss ~= nil then
			self._enemy_pen_energy_loss = self._ammo_data.enemy_pen_energy_loss
		end


		if self._ammo_data.max_wall_penetration_distance ~= nil then
			self._max_wall_penetration_distance = self._ammo_data.max_wall_penetration_distance
		end
		if self._ammo_data.wall_pen_energy_loss ~= nil then
			self._wall_pen_energy_loss = self._ammo_data.wall_pen_energy_loss
		end


		if self._ammo_data.max_shield_penetration_distance ~= nil then
			self._max_shield_penetration_distance = self._ammo_data.max_shield_penetration_distance
		end
		if self._ammo_data.shield_pen_energy_loss ~= nil then
			self._shield_pen_energy_loss = self._ammo_data.shield_pen_energy_loss
		end


		if self._ammo_data.max_penetration_distance ~= nil then
			self._max_penetration_distance = self._ammo_data.max_penetration_distance
		end
		if self._ammo_data.max_penetrations ~= nil then
			self._max_penetrations = self._ammo_data.max_penetrations
		end
		if self._ammo_data.pen_energy_loss ~= nil then
			self._pen_energy_loss = self._ammo_data.pen_energy_loss
		end

	end
end

function NewRaycastWeaponBase:_update_fire_mode_data_oryo()
	local custom_stats = managers.weapon_factory:get_custom_stats_from_weapon(self._factory_id, self._blueprint)

	local can_toggle_firemode = nil
	for part_id, stats in pairs(custom_stats) do
		can_toggle_firemode = stats.can_toggle_firemode
	end

	local locked_fire_mode = nil
	if type(can_toggle_firemode) == "table" then
		if table.getn(can_toggle_firemode) > 1 then
			self._restricted_fire_modes = deep_clone(can_toggle_firemode)
		else
			locked_fire_mode = can_toggle_firemode[1]
		end
	elseif type(can_toggle_firemode) == "string" then
		locked_fire_mode = Idstring(can_toggle_firemode)
	end

	if locked_fire_mode then
		self._locked_fire_mode = locked_fire_mode
	end 

	self._fire_mode = type(self:can_toggle_firemode()) == "table" and Idstring(self:can_toggle_firemode()[1]) or self._locked_fire_mode or self._fire_mode
	self._fire_mode_index = self._fire_mode_index or 1
end

local can_toggle_firemode_original = NewRaycastWeaponBase.can_toggle_firemode
function NewRaycastWeaponBase:can_toggle_firemode(...)
	local can_toggle_firemode = self._restricted_fire_modes or can_toggle_firemode_original(self, ...)

	return can_toggle_firemode
end

local toggle_firemode_original = NewRaycastWeaponBase.toggle_firemode
function NewRaycastWeaponBase:toggle_firemode(skip_post_event)
	local can_toggle = not self._locked_fire_mode and self:can_toggle_firemode()

	if type(can_toggle) == "table" then
		local fire_modes = table.getn(can_toggle)
		self._fire_mode_index = (self._fire_mode_index % fire_modes) + 1
		local index = self._fire_mode_index

		if can_toggle[index] then
			self._fire_mode = Idstring(can_toggle[index])

			if not skip_post_event then
				self._sound_fire:post_event(index % 2 == 0 and "wp_auto_switch_on" or "wp_auto_switch_off")
			end

			local fire_mode_data = self._fire_mode_data[self._fire_mode:key()]
			local fire_effect = fire_mode_data and (self._silencer and fire_mode_data.muzzleflash_silenced or fire_mode_data.muzzleflash)

			self:change_fire_effect(fire_effect)

			local trail_effect = fire_mode_data and fire_mode_data.trail_effect

			self:change_trail_effect(trail_effect)
			self:call_on_digital_gui("set_firemode", self:fire_mode())
			self:update_firemode_gui_ammo()
		else

			return false
		end

		return true
	end

	return toggle_firemode_original(self, skip_post_event)
end

function NewRaycastWeaponBase:stop_shooting()
	NewRaycastWeaponBase.super.stop_shooting(self)
	
	local fire_mode_data = tweak_data.weapon[self._name_id].fire_mode_data or {}

	if self._fire_mode == Idstring("burst") then
		fire_mode_data = fire_mode_data and fire_mode_data.burst or fire_mode_data
		local fire_rate = fire_mode_data.fire_rate or 0
		local burst_cooldown = fire_mode_data.burst_cooldown or fire_rate * 2
		local next_fire = burst_cooldown / self:fire_rate_multiplier()
		self._next_fire_allowed = self._next_fire_allowed + next_fire
    elseif self._fire_mode == Idstring("volley") then
		self:stop_volley_charge()
	end
end

-- <oryo: guns always reset to default position when moving from ads to hip-fire while sight gadget is enabled
function NewRaycastWeaponBase:stance_mod() -- where else is this function being used? i hope emptying it doesn't break something else
end

function NewRaycastWeaponBase:stance_mod_oryo() -- contents of "stance_mod" transferred to here
	if not self._blueprint or not self._factory_id then
		return nil
	end

	local second_sight_data = self:get_active_second_sight()

	return managers.weapon_factory:get_stance_mod(self._factory_id, self._blueprint, second_sight_data and second_sight_data.part_id)
end
-- oryo>