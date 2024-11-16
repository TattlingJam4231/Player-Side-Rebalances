Hooks:PostHook(DOTTweakData, "_init_dot_entries_fire", "Oryo DOTTweakData _init_dot_entries_fire", function(self, entries, tweak_data)


	-- Flamethrower DoT
	self.dot_entries.fire.weapon_flamethrower_mk2 = {
        damage = 18,
        dot_length = 3.6,
        dot_trigger_max_distance = 3000,
        dot_tick_period = 0.5,
        scale_tick_period = 0.015,
        dot_can_crit = true
	}

	-- MA-17 Flamethrower DoT
	self.dot_entries.fire.weapon_system  = {
        damage = 18,
        dot_length = 3.6,
        dot_trigger_max_distance = 3000,
        dot_tick_period = 0.5,
        scale_tick_period = 0.01,
        dot_can_crit = true
	}


    self.dot_entries.fire.ammo_dragons_breath_4 = {
        dot_trigger_chance = 1,
        damage = 20,
        dot_tick_period = 0.5,
        damage_ticks = 12,
        dot_trigger_max_distance = 2000,
        dot_can_stack = true,
        dot_can_crit = true
    }
    self.dot_entries.fire.ammo_dragons_breath_pump = {
        dot_trigger_chance = 1,
        hurt_animation_chance = 1,
        damage = 13,
        dot_tick_period = 0.5,
        damage_ticks = 12,
        dot_trigger_max_distance = 2700,
        dot_can_stack = true,
        dot_can_crit = true
    }
    self.dot_entries.fire.ammo_dragons_breath_3 = {
        dot_trigger_chance = 1,
        damage = 13,
        dot_tick_period = 0.5,
        damage_ticks = 12,
        dot_trigger_max_distance = 2000,
        dot_can_stack = true,
        dot_can_crit = true
    }
    self.dot_entries.fire.ammo_dragons_breath_2 = {
        dot_trigger_chance = 1,
        damage = 10,
        dot_tick_period = 0.5,
        damage_ticks = 12,
        dot_trigger_max_distance = 2000,
        dot_can_stack = true,
        dot_can_crit = true
    }
    self.dot_entries.fire.ammo_dragons_breath_1 = {
        dot_trigger_chance = 1,
        damage = 10,
        dot_tick_period = 0.5,
        damage_ticks = 10,
        dot_trigger_max_distance = 2000,
        dot_can_stack = true,
        dot_can_crit = true
    }

	-- The Motherforker DoT
    self.dot_entries.fire.melee_fork = {
        damage = 10,
        dot_tick_period = 0.5,
        damage_ticks = 3,
        add_ticks = 1,
        dot_can_stack = "extend",
        dot_can_crit = true,
        dot_trigger_chance = 0.3,
        max_values = {
            damage_ticks = 9,
            add_ticks = 3,
            dot_trigger_chance = 0.7
        }
    }

	-- Spatula DoT
    self.dot_entries.fire.melee_spatula = {
        damage = 10,
        dot_tick_period = 0.5,
        damage_ticks = 3,
        add_ticks = 2,
        dot_can_stack = "extend",
        dot_can_crit = true,
        dot_trigger_chance = 0.5,
        max_values = {
            damage_ticks = 9,
            add_ticks = 6,
            dot_trigger_chance = 1
        }
    }

	-- You're Mine DoT
    self.dot_entries.fire.melee_branding_iron = {
        damage = 40,
        dot_tick_period = 0.5,
        damage_ticks = 1,
        add_ticks = 1,
        dot_can_stack = "extend",
        dot_can_crit = true,
        dot_trigger_chance = 0.5,
        max_values = {
            damage = 60,
            damage_ticks = 2,
            add_ticks = 2,
            dot_trigger_chance = 1
        }
    }

end)


Hooks:PostHook(DOTTweakData, "_init_dot_entries_poison", "Oryo DOTTweakData _init_dot_entries_poison", function(self, entries)

	-- Kunai Knife DoT
    self.dot_entries.poison.melee_cqc = {
        damage = 15,
        dot_tick_period = 0.5,
        damage_ticks = 3,
        dot_can_stack = "extend",
        dot_can_crit = true,
        hurt_animation_chance = 0.3,
        max_values = {
            damage = 45,
            dot_tick_period = 0.1,
            hurt_animation_chance = 1
        }
    }

	-- Stainless Steel Syringe DoT
    self.dot_entries.poison.melee_fear = {
        damage = 15,
        dot_tick_period = 0.5,
        damage_ticks = 3,
        dot_can_stack = "extend",
        dot_can_crit = true,
        hurt_animation_chance = 0.3,
        max_values = {
            damage = 45,
            dot_tick_period = 0.1,
            hurt_animation_chance = 1
        }
    }

end)


-- function DOTTweakData:get_dot_data(tweak_name)
-- 	for variant, dot_entries in pairs(self.dot_entries) do
-- 		if dot_entries[tweak_name] then
-- 			return dot_entries[tweak_name]
-- 		end
-- 	end

-- 	return nil
-- end