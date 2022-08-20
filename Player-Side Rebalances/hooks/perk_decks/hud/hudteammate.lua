function HUDTeammate:set_ability_icon_oryo(texture, texture_rect)
	local ability_icon = self._radial_health_panel:child("radial_ability"):child("ability_icon")
	ability_icon:set_image(texture, unpack(texture_rect))
end