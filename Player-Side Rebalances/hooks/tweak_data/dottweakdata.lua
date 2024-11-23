Hooks:PostHook(DOTTweakData, "_init_dot_entries_fire", "Oryo DOTTweakData _init_dot_entries_fire", function(self, entries, tweak_data)

	-- Flamethrower DoT
	self.dot_entries.fire.weapon_flamethrower_mk2 = {
		dot_trigger_chance = 1,
		dot_grace_period = 0,
		dot_damage = 1.0,
		dot_tick_period = 0.5,
		damage_ticks = 3,
		dot_can_stack = true,
		dot_can_crit = true
	}

	-- MA-17 Flamethrower DoT
	self.dot_entries.fire.weapon_system  = {
		dot_trigger_chance = 1,
		dot_grace_period = 0,
		dot_damage = 0.8,
		dot_tick_period = 0.5,
		damage_ticks = 3,
		dot_can_stack = true,
		dot_can_crit = true
	}

	-- Incendiary Grenade
	self.dot_entries.fire.proj_fire_com = {
		dot_trigger_chance = 1,
		dot_grace_period = 0,
		dot_damage = 8,
		damage_ticks = 12,
		dot_trigger_max_distance = false,
		dot_can_stack = true,
		dot_can_crit = true
	}

	-- Molotov
	self.dot_entries.fire.proj_molotov = {
		dot_trigger_chance = 1,
		dot_grace_period = 0,
		dot_application_period = 1.5,
		dot_damage = 8,
		dot_tick_period = 0.5,
		damage_ticks = 10,
		dot_trigger_max_distance = false,
		dot_can_stack = true,
		dot_can_crit = true,
		is_molotov = true
	}
	self.dot_entries.fire.proj_molotov_groundfire = {
		dot_trigger_chance = 1,
		dot_grace_period = 0,
		dot_application_period = 1.5,
		dot_damage = 8,
		dot_tick_period = 0.5,
		damage_ticks = 12,
		dot_trigger_max_distance = false,
		dot_can_stack = true,
		dot_can_crit = true,
		is_molotov = true
	}

	-- Launcher Incendiary Grenade
	self.dot_entries.fire.proj_launcher_incendiary = {
		dot_trigger_chance = 1,
		dot_grace_period = 0,
		dot_application_period = 1.5,
		dot_damage = 8,
		dot_tick_period = 0.5,
		damage_ticks = 6,
		dot_trigger_max_distance = false,
		dot_can_stack = true,
		dot_can_crit = true
	}
	self.dot_entries.fire.proj_launcher_incendiary_groundfire = deep_clone(self.dot_entries.fire.proj_molotov_groundfire)

	-- Arbiter Incendiary Grenade
	self.dot_entries.fire.proj_launcher_incendiary_arbiter = {
		dot_trigger_chance = 1,
		dot_grace_period = 0,
		dot_application_period = 1.5,
		dot_damage = 8,
		dot_tick_period = 0.5,
		damage_ticks = 3,
		dot_trigger_max_distance = false,
		dot_can_stack = true,
		dot_can_crit = true
	}
	self.dot_entries.fire.proj_launcher_incendiary_arbiter_groundfire = deep_clone(self.dot_entries.fire.proj_molotov_groundfire)

	-- Dragon's Breath
	local ammo_dragons_breath = {
		dot_trigger_chance = 1,
		dot_grace_period = 0,
		dot_damage = 2.2,
		dot_tick_period = 0.5,
		damage_ticks = 12,
		dot_trigger_max_distance = 2000,
		dot_can_stack = true,
		dot_can_crit = true
	}

	self.dot_entries.fire.ammo_dragons_breath_4 = deep_clone(ammo_dragons_breath)
	self.dot_entries.fire.ammo_dragons_breath_4.dot_damage = 7.9
	
	self.dot_entries.fire.ammo_dragons_breath_pump = deep_clone(ammo_dragons_breath)
	self.dot_entries.fire.ammo_dragons_breath_pump.dot_damage = 5.6
	self.dot_entries.fire.ammo_dragons_breath_pump.dot_trigger_max_distance = 2700
	
	self.dot_entries.fire.ammo_dragons_breath_3 = deep_clone(ammo_dragons_breath)
	self.dot_entries.fire.ammo_dragons_breath_3.dot_damage = 5.6
	
	self.dot_entries.fire.ammo_dragons_breath_2 = deep_clone(ammo_dragons_breath)
	self.dot_entries.fire.ammo_dragons_breath_2.dot_damage = 2.8

	self.dot_entries.fire.ammo_dragons_breath_1 = deep_clone(ammo_dragons_breath)
	self.dot_entries.fire.ammo_dragons_breath_1.dot_damage = 2.2

	-- The Motherforker DoT
	self.dot_entries.fire.melee_fork = {
		dot_trigger_chance = 0.5,
		dot_grace_period = 0,
		dot_damage = 1.0,
		dot_tick_period = 0.5,
		damage_ticks = 6,
		dot_can_stack = true,
		dot_can_crit = true,
		max_values = {
			dot_trigger_chance = 1,
			dot_damage = 4.0,
			damage_ticks = 3
		}
	}

	-- Spatula DoT
	self.dot_entries.fire.melee_spatula = {
		dot_trigger_chance = 1,
		dot_grace_period = 0,
		dot_damage = 1.5,
		dot_tick_period = 0.5,
		damage_ticks = 2,
		dot_can_stack = true,
		dot_can_crit = true,
		max_values = {
			dot_damage = 5.0
		}
	}

	-- You're Mine DoT
	self.dot_entries.fire.melee_branding_iron = {
		dot_trigger_chance = 1,
		dot_grace_period = 0,
		dot_damage = 1.0,
		dot_tick_period = 0.5,
		damage_ticks = 2,
		dot_can_stack = true,
		dot_can_crit = true,
		max_values = {
			dot_damage = 3.5,
			damage_ticks = 4
		}
	}

end)


Hooks:PostHook(DOTTweakData, "_init_dot_entries_poison", "Oryo DOTTweakData _init_dot_entries_poison", function(self, entries)

	-- Viper Grenade
	self.dot_entries.poison.proj_gas_grenade_cloud = {
		dot_grace_period = 0,
		dot_application_period = 1,
		dot_damage = 2,
		dot_tick_period = 1,
		damage_ticks = 12,
		dot_can_stack = "extend",
		dot_can_crit = true,
		accelerate = true,
		lethal_hurt = true
	}

	-- Launcher Viper Grenade
	self.dot_entries.poison.proj_launcher_cloud = {
		dot_grace_period = 0,
		dot_application_period = 1,
		dot_damage = 2,
		dot_tick_period = 1,
		damage_ticks = 8,
		dot_can_stack = "extend",
		dot_can_crit = true,
		accelerate = true,
		lethal_hurt = true
	}

	-- Arbiter Viper Grenade
	self.dot_entries.poison.proj_launcher_arbiter_cloud = {
		dot_grace_period = 0,
		dot_application_period = 1,
		dot_damage = 2,
		dot_tick_period = 1,
		damage_ticks = 8,
		dot_can_stack = "extend",
		dot_can_crit = true,
		accelerate = true,
		lethal_hurt = true
	}

	-- Tombstone Slug
	local ammo_rip = {
		dot_grace_period = 0,
		dot_damage = 2,
		dot_tick_period = 1,
		damage_ticks = 7,
		use_weapon_damage_falloff = true,
		dot_can_stack = "extend",
		dot_can_crit = true,
		accelerate = true,
		lethal_hurt = true,
		headshot_length_scale = true
	}

	self.dot_entries.poison.ammo_rip_4 = deep_clone(ammo_rip)
	self.dot_entries.poison.ammo_rip_4.damage_ticks = 25
	
	self.dot_entries.poison.ammo_rip_pump = deep_clone(ammo_rip)
	self.dot_entries.poison.ammo_rip_pump.damage_ticks = 18
	
	self.dot_entries.poison.ammo_rip_3 = deep_clone(ammo_rip)
	self.dot_entries.poison.ammo_rip_3.damage_ticks = 18
	
	self.dot_entries.poison.ammo_rip_2 = deep_clone(ammo_rip)
	self.dot_entries.poison.ammo_rip_2.damage_ticks = 9

	self.dot_entries.poison.ammo_rip_1 = deep_clone(ammo_rip)
	self.dot_entries.poison.ammo_rip_1.damage_ticks = 7

	-- Kunai Knife DoT
	self.dot_entries.poison.melee_cqc = {
		dot_grace_period = 0,
		dot_damage = 2,
		dot_tick_period = 1,
		damage_ticks = 2,
		dot_can_stack = "extend",
		dot_can_crit = true,
		accelerate = true,
		lethal_hurt = true,
		max_values = {
			damage_ticks = 8,
			-- dot_tick_period = 0.5
		}
	}

	-- Stainless Steel Syringe DoT
	self.dot_entries.poison.melee_fear = {
		dot_grace_period = 0,
		dot_damage = 2,
		dot_tick_period = 1,
		damage_ticks = 2,
		dot_can_stack = "extend",
		dot_can_crit = true,
		accelerate = true,
		lethal_hurt = true,
		max_values = {
			damage_ticks = 8,
			-- dot_tick_period = 0.5
		}
	}

end)


-- function DOTTweakData:get_dot_data(tweak_name)
-- 	for variant, dot_entries in pairs(self.dot_entries) do
-- 		if dot_entries[tweak_name] then
--             Utils.PrintTable(dot_entries[tweak_name])
-- 			return dot_entries[tweak_name]
-- 		end
-- 	end
-- 	return nil
-- end