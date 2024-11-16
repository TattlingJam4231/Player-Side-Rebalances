function SentryGunWeapon:_set_fire_mode(use_armor_piercing)
	self._use_armor_piercing = use_armor_piercing
	self._fire_rate_reduction = self._use_armor_piercing and 4 or 1
	self._current_damage_mul = self._use_armor_piercing and 3.5 or 1

	self:flip_fire_sound()
    self._unit:base():set_use_armor_piercing(use_armor_piercing)
end

function SentryGunWeapon:fire(blanks, expend_ammo, shoot_player, target_unit)
	if expend_ammo then
		if self._ammo_total <= 0 then
			return
		end
		
		if self._use_armor_piercing then
			self:change_ammo(-4)
		else
			self:change_ammo(-1)
		end
	end

	local fire_obj = self._effect_align[self._interleaving_fire]
	local from_pos = fire_obj:position()
	local direction = fire_obj:rotation():y()

	mvector3.spread(direction, tweak_data.weapon[self._name_id].SPREAD * self._spread_mul)
	World:effect_manager():spawn(self._muzzle_effect_table[self._interleaving_fire])

	if self._use_shell_ejection_effect then
		World:effect_manager():spawn(self._shell_ejection_effect_table)
	end

	if self._unit:damage() and self._unit:damage():has_sequence("anim_fire_seq") then
		self._unit:damage():run_sequence_simple("anim_fire_seq")
	end

	local ray_res = self:_fire_raycast(from_pos, direction, shoot_player, target_unit)

	if self._alert_events and ray_res.rays then
		RaycastWeaponBase._check_alert(self, ray_res.rays, from_pos, direction, self._unit)
	end

	self._unit:movement():give_recoil()
	self._unit:event_listener():call("on_fire")

	return ray_res
end

function SentryGunWeapon:out_of_ammo()
	if self._ammo_total then
		return self._ammo_total <= 0
	else
		return self._ammo_ratio <= 0
	end
end