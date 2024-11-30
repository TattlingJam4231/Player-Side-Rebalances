Hooks:PostHook(DOTTweakData, "_init_dot_entries_fire", "Oryo DOTTweakData _init_dot_entries_fire", function(self, entries, tweak_data)


	self.dot_entries.fire.default_fire = {
		PROCESSED = true,
		name = "default",
		variant = "fire",
		damage_class = "FlameBulletBase",
		dot_trigger_chance = 1,
		dot_grace_period = 0,
		dot_damage = 4.0,
		dot_tick_period = 0.5,
		damage_ticks = 3,
		dot_trigger_max_distance = 3000,
		dot_can_stack = true,
		dot_can_crit = true
	}

	-- Flamethrower
	self.dot_entries.fire.weapon_flamethrower_mk2 = {
		dot_damage = 1.0,
		damage_ticks = 3,
		dot_trigger_max_distance = false
	}
	self.dot_entries.fire.ammo_flamethrower_mk2_rare = {
		dot_damage = 1.2,
		damage_ticks = 2,
		dot_trigger_max_distance = false
	}
	self.dot_entries.fire.ammo_flamethrower_mk2_welldone = {
		dot_damage = 0.9,
		damage_ticks = 4,
		dot_trigger_max_distance = false
	}

	-- MA-17 Flamethrower
	self.dot_entries.fire.weapon_system  = {
		dot_damage = 0.8,
		damage_ticks = 3,
		dot_trigger_max_distance = false
	}
	self.dot_entries.fire.ammo_system_low = {
		dot_damage = 1.0,
		damage_ticks = 2,
		dot_trigger_max_distance = false
	}
	self.dot_entries.fire.ammo_system_high = {
		dot_damage = 0.7,
		damage_ticks = 4,
		dot_trigger_max_distance = false
	}

	-- Cash Blaster
	self.dot_entries.fire.weapon_money = {
		burn_sound_name = "no_sound",
		fire_effect_variant = "endless_money",
		dot_damage = 0.4,
		damage_ticks = 2,
		dot_trigger_max_distance = false,
	}

	-- Infernal Flamethrower
	self.dot_entries.fire.weapon_kacchainsaw_flamethrower  = {
		dot_damage = 0.2,
		damage_ticks = 3
	}

	-- Incendiary Grenade
	self.dot_entries.fire.proj_fire_com = {
		dot_damage = 8,
		damage_ticks = 12,
		dot_trigger_max_distance = false
	}

	-- Molotov
	self.dot_entries.fire.proj_molotov = {
		dot_application_period = 1.5,
		dot_damage = 8,
		damage_ticks = 10,
		dot_trigger_max_distance = false,
		is_molotov = true
	}
	self.dot_entries.fire.proj_molotov_groundfire = {
		dot_application_period = 1.5,
		dot_damage = 8,
		damage_ticks = 12,
		dot_trigger_max_distance = false,
		is_molotov = true
	}

	-- Launcher Incendiary Grenade
	self.dot_entries.fire.proj_launcher_incendiary = {
		dot_application_period = 1.5,
		dot_damage = 8,
		damage_ticks = 6,
		dot_trigger_max_distance = false
	}
	self.dot_entries.fire.proj_launcher_incendiary_groundfire = deep_clone(self.dot_entries.fire.proj_molotov_groundfire)

	-- Arbiter Incendiary Grenade
	self.dot_entries.fire.proj_launcher_incendiary_arbiter = {
		dot_application_period = 1.5,
		dot_damage = 8,
		damage_ticks = 3,
		dot_trigger_max_distance = false
	}
	self.dot_entries.fire.proj_launcher_incendiary_arbiter_groundfire = deep_clone(self.dot_entries.fire.proj_molotov_groundfire)

	-- Dragon's Breath
	local ammo_dragons_breath = {
		dot_damage = 2.2,
		damage_ticks = 12,
		dot_trigger_max_distance = 2000
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

	
	-- Comically Large Spoon of Gold
	self.dot_entries.fire.melee_spoon_gold = {
		dot_damage = 0.6,
		damage_ticks = 6,
		dot_trigger_max_distance = false,
		max_values = {
			dot_damage = 4.0
		}
	}

	-- The Motherforker
	self.dot_entries.fire.melee_fork = {
		dot_trigger_chance = 0.5,
		dot_damage = 1.0,
		damage_ticks = 6,
		max_values = {
			dot_trigger_chance = 1,
			dot_damage = 4.0,
			damage_ticks = 3
		}
	}

	-- Spatula
	self.dot_entries.fire.melee_spatula = {
		dot_damage = 1.5,
		damage_ticks = 2,
		max_values = {
			dot_damage = 5.0
		}
	}

	-- You're Mine
	self.dot_entries.fire.melee_branding_iron = {
		dot_damage = 1.0,
		damage_ticks = 2,
		max_values = {
			dot_damage = 3.5,
			damage_ticks = 4
		}
	}

end)


Hooks:PostHook(DOTTweakData, "_init_dot_entries_poison", "Oryo DOTTweakData _init_dot_entries_poison", function(self, entries)


	self.dot_entries.poison.default_poison = {
		PROCESSED = true,
		name = "default",
		variant = "poison",
		damage_class = "PoisonBulletBase",
		dot_grace_period = 0,
		dot_damage = 2,
		damage_ticks = 12,
		dot_tick_period = 1,
		dot_can_stack = "extend",
		dot_can_crit = true,
		accelerate = true,
		lethal_hurt = true
	}

	-- Viper Grenade
	self.dot_entries.poison.proj_gas_grenade_cloud = {
		damage_ticks = 12
	}

	-- Launcher Viper Grenade
	self.dot_entries.poison.proj_launcher_cloud = {
		dot_application_period = 1,
		damage_ticks = 8
	}

	-- Arbiter Viper Grenade
	self.dot_entries.poison.proj_launcher_arbiter_cloud = {
		dot_application_period = 1,
		damage_ticks = 8
	}

	-- Tombstone Slug
	local ammo_rip = {
		damage_ticks = 7,
		use_weapon_damage_falloff = true,
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

	-- Kunai Knife
	self.dot_entries.poison.melee_cqc = {
		damage_ticks = 2,
		max_values = {
			damage_ticks = 8,
			-- dot_tick_period = 0.5
		}
	}

	-- Stainless Steel Syringe
	self.dot_entries.poison.melee_fear = {
		damage_ticks = 2,
		max_values = {
			damage_ticks = 8,
			-- dot_tick_period = 0.5
		}
	}

end)