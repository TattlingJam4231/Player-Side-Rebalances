function HUDManager:activate_teammate_ability_radial_oryo(i, icon, time_left, time_total)
	self._teammate_panels[i]:activate_ability_radial(time_left, time_total)
    self._teammate_panels[i]:set_ability_icon_oryo(icon[1], icon[2])
end