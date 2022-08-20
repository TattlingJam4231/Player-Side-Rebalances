Hooks:PostHook(UpgradesTweakData, "init", "Oryo UpgradesTweakData init", function(self)

	local reload_multiplier = 1.35
	self.values.assault_rifle.reload_speed_multiplier = {reload_multiplier}
	self.values.smg.reload_speed_multiplier = {reload_multiplier}
	self.values.snp.reload_speed_multiplier = {reload_multiplier}
	
	-- Forced Friendship
	self.values.team.damage = {
		hostage_absorption = {
			0.1
		},
		hostage_absorption_limit = 4
	}

	-- Ammo Efficiency
	self.values.player.head_shot_ammo_return = {
		{
			headshots = 2,
			ammo = 1,
			time = 2
		},
		{
			headshots = 2,
			ammo = 1,
			time = 4
		}
	}

	-- Graze
	self.values.snp.graze_damage = {
		{
			radius = 100,
			damage_factor = 0.2,
			damage_factor_headshot = 0.2,
			damage_factor_headshot_kill = 0.2
		},
		{
			radius = 100,
			damage_factor = 0.2,
			damage_factor_headshot = 0.5,
			damage_factor_headshot_kill = 1
		}
	}

	-- Sharpeyed
	self.values.team.crew_scavenge = {
		{
			1.1,
			1.2,
			1.3
		}
	}
	self.crew_descs.crew_scavenge = {
		value1 = "10%",
		value2 = "+10%"
	}

	-- Fully Loaded
	self.values.player.pick_up_ammo_multiplier_2 = {
		1.5
	}
	self.definitions.player_pick_up_ammo_multiplier_2 = {
		name_id = "menu_player_pick_up_ammo_multiplier_2",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "pick_up_ammo_multiplier_2",
			category = "player"
		}
	}

	-- Combat Medic
	self.revive_health_multiplier = {
		0.15
	}
	self.values.temporary.revive_damage_reduction = {
		{
			0.7,
			7
		}
	}

	-- Painkillers
	self.values.temporary.passive_revive_damage_reduction = {
		{
			0.7,
			7
		},
		{
			0.2,
			7
		}
	}

	-- Up You Go
	self.values.temporary.revived_damage_resist = {
		{
			0.9,
			7
		}
	}
	self.values.player.revived_health_regain = {
		0.2
	}

	-- Running From Death
	self.values.temporary.swap_weapon_faster = {
		{
			1.5,
			7
		}
	}
	self.values.temporary.reload_weapon_faster = {
		{
			1.5,
			7
		}
	}
	self.values.temporary.increased_movement_speed = {
		{
			1.3,
			7
		}
	}

	-- Unseen Strike
	self.values.temporary.unseen_strike = {
		{
			1.35,
			4
		},
		{
			1.35,
			12
		}
	}

	-- Second Wind
	self.values.temporary.damage_speed_multiplier = {
		{
			1.3,
			7
		}
	}
	self.values.temporary.team_damage_speed_multiplier_received = {
		{
			1.3,
			7
		}
	}
	-- Fully Loaded
	self.values.player.regain_throwable_from_ammo = {
		{
			chance = 0.06,
			chance_inc = 0.002
		}
	}
end)

