local _init_fbi_heavy_swat_original = CharacterTweakData._init_fbi_heavy_swat
function CharacterTweakData:_init_fbi_heavy_swat(presets)
	_init_fbi_heavy_swat_original(self, presets)
	self.fbi_heavy_swat.damage.explosion_damage_mul = 1 -- changed from 0.9
end