Hooks:PostHook(CharacterTweakData, "_init_fbi_heavy_swat", "Oryo CharacterTweakData _init_fbi_heavy_swat", function(self, presets)

	self.fbi_heavy_swat.damage.explosion_damage_mul = 1 -- oryo: removed explosion resist
		
end)

Hooks:PostHook(CharacterTweakData, "_init_medic", "Oryo CharacterTweakData _init_medic", function(self, presets)

	self.medic.damage.hurt_severity = presets.hurt_severities.only_poison_and_light_hurt -- oryo: allow poison hurt on medic
		
end)

Hooks:PostHook(CharacterTweakData, "_init_tank", "Oryo CharacterTweakData _init_tank", function(self, presets)

	self.tank.damage.hurt_severity = presets.hurt_severities.only_poison_and_light_hurt -- oryo: allow poison hurt on dozer
	self.tank_medic.damage.hurt_severity = presets.hurt_severities.only_poison_and_light_hurt
		
end)