local verify_heal_requesting_unit = MedicDamage.verify_heal_requesting_unit
function MedicDamage:verify_heal_requesting_unit(requesting_unit)
	if not verify_heal_requesting_unit(self, requesting_unit) then
		return false
	end

	local vision_mask = managers.slot:get_mask("AI_visibility")
	local medic_head_pos = self._unit:movement():m_head_pos()
	local requesting_unit_head_pos = requesting_unit:movement():m_head_pos()
	local requesting_unit_pos = requesting_unit:movement():m_pos()

	if World:raycast("ray", medic_pos, requesting_unit_head_pos, "slot_mask", vision_mask, "ray_type", "ai_vision", "report") and
			World:raycast("ray", medic_pos, requesting_unit_pos, "slot_mask", vision_mask, "ray_type", "ai_vision", "report") then
		return false
	end

	return true
end