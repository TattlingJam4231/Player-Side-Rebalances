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


    self.dot_entries.fire.ammo_dragons_breath_4 = {
        dot_trigger_chance = 1,
        dot_grace_period = 0,
        dot_damage = 5.0,
        dot_tick_period = 0.5,
        damage_ticks = 12,
        dot_trigger_max_distance = 2000,
        dot_can_stack = true,
        dot_can_crit = true
    }
    self.dot_entries.fire.ammo_dragons_breath_pump = {
        dot_trigger_chance = 1,
        dot_grace_period = 0,
        dot_damage = 4.0,
        dot_tick_period = 0.5,
        damage_ticks = 12,
        dot_trigger_max_distance = 2700,
        dot_can_stack = true,
        dot_can_crit = true
    }
    self.dot_entries.fire.ammo_dragons_breath_3 = {
        dot_trigger_chance = 1,
        dot_grace_period = 0,
        dot_damage = 4.0,
        dot_tick_period = 0.5,
        damage_ticks = 12,
        dot_trigger_max_distance = 2000,
        dot_can_stack = true,
        dot_can_crit = true
    }
    self.dot_entries.fire.ammo_dragons_breath_2 = {
        dot_trigger_chance = 1,
        dot_grace_period = 0,
        dot_damage = 2.5,
        dot_tick_period = 0.5,
        damage_ticks = 12,
        dot_trigger_max_distance = 2000,
        dot_can_stack = true,
        dot_can_crit = true
    }
    self.dot_entries.fire.ammo_dragons_breath_1 = {
        dot_trigger_chance = 1,
        dot_grace_period = 0,
        dot_damage = 2.0,
        dot_tick_period = 0.5,
        damage_ticks = 12,
        dot_trigger_max_distance = 2000,
        dot_can_stack = true,
        dot_can_crit = true
    }

	-- The Motherforker DoT
    self.dot_entries.fire.melee_fork = {
        dot_trigger_chance = 0.3,
        dot_grace_period = 0,
        dot_damage = 1.0,
        dot_tick_period = 0.5,
        damage_ticks = 3,
        add_ticks = 1,
        dot_can_stack = "extend",
        dot_can_crit = true,
        max_values = {
            damage_ticks = 9,
            add_ticks = 3,
            dot_trigger_chance = 0.7
        }
    }

	-- Spatula DoT
    self.dot_entries.fire.melee_spatula = {
        dot_trigger_chance = 0.5,
        dot_grace_period = 0,
        dot_damage = 1.0,
        dot_tick_period = 0.5,
        damage_ticks = 3,
        add_ticks = 2,
        dot_can_stack = "extend",
        dot_can_crit = true,
        max_values = {
            damage_ticks = 9,
            add_ticks = 6,
            dot_trigger_chance = 1
        }
    }

	-- You're Mine DoT
    self.dot_entries.fire.melee_branding_iron = {
        dot_trigger_chance = 0.5,
        dot_grace_period = 0,
        dot_damage = 4.0,
        dot_tick_period = 0.5,
        damage_ticks = 1,
        add_ticks = 1,
        dot_can_stack = "extend",
        dot_can_crit = true,
        max_values = {
            dot_damage = 6.0,
            damage_ticks = 2,
            add_ticks = 2,
            dot_trigger_chance = 1
        }
    }

end)


Hooks:PostHook(DOTTweakData, "_init_dot_entries_poison", "Oryo DOTTweakData _init_dot_entries_poison", function(self, entries)

	-- Kunai Knife DoT
    self.dot_entries.poison.melee_cqc = {
        dot_damage = 1.5,
        dot_tick_period = 0.5,
        damage_ticks = 3,
        dot_can_stack = "extend",
        dot_can_crit = true,
        hurt_animation_chance = 0.3,
        max_values = {
            dot_damage = 4.5,
            dot_tick_period = 0.1,
            hurt_animation_chance = 1
        }
    }

	-- Stainless Steel Syringe DoT
    self.dot_entries.poison.melee_fear = {
        dot_damage = 1.5,
        dot_tick_period = 0.5,
        damage_ticks = 3,
        dot_can_stack = "extend",
        dot_can_crit = true,
        hurt_animation_chance = 0.3,
        max_values = {
            dot_damage = 4.5,
            dot_tick_period = 0.1,
            hurt_animation_chance = 1
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