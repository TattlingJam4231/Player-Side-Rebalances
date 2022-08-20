function WeaponLionGadget1:_is_deployable()
	if self._is_npc or not self:_get_bipod_obj() then
		return false
	end

	if self:_is_in_blocked_deployable_state() then
		return false
	end

	local bipod_rays = self:_shoot_bipod_rays()

	if not bipod_rays then
		return false
	end
	
	if (bipod_rays.left or bipod_rays.right) and bipod_rays.center or bipod_rays.center then
		return true
	end

	return false
end