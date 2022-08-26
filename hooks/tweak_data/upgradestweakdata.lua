Hooks:PostHook(UpgradesTweakData, "init", "Oryo UpgradesTweakData init", function(self)

	self:_init_skill_trees_oryo()
	self:_init_perk_decks_oryo()
	self:_init_crew_bonuses_oryo()

	self.sentry_gun_base_ammo = 400
end)

-- Skill Trees
function UpgradesTweakData:_init_skill_trees_oryo()
	self:_init_mastermind_oryo()
	self:_init_enforcer_oryo()
	self:_init_ghost_oryo()
	self:_init_fugitive_oryo()
end

function UpgradesTweakData:_init_mastermind_oryo()
	self:_init_medic_oryo()
	self:_init_controller_oryo()
	self:_init_sharpshooter_oryo()
end

function UpgradesTweakData:_init_enforcer_oryo()
	self:_init_ammo_specialist_oryo()
end

function UpgradesTweakData:_init_ghost_oryo()
	self:_init_silent_killer_oryo()
end

function UpgradesTweakData:_init_fugitive_oryo()
	self:_init_revenant_oryo()
end


function UpgradesTweakData:_init_medic_oryo()

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
end

function UpgradesTweakData:_init_controller_oryo()
	
	-- Forced Friendship
	self.values.team.damage = {
		hostage_absorption = {
			0.1
		},
		hostage_absorption_limit = 4
	}
end

function UpgradesTweakData:_init_sharpshooter_oryo()

	-- Aggressive Reload
	local reload_multiplier = 1.35
	self.values.assault_rifle.reload_speed_multiplier = {reload_multiplier}
	self.values.smg.reload_speed_multiplier = {reload_multiplier}
	self.values.snp.reload_speed_multiplier = {reload_multiplier}

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
end


function UpgradesTweakData:_init_ammo_specialist_oryo()

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

	self.values.player.regain_throwable_from_ammo = {
		{
			chance = 0.06,
			chance_inc = 0.002
		}
	}
end


function UpgradesTweakData:_init_silent_killer_oryo()

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
end


function UpgradesTweakData:_init_revenant_oryo()

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
end


-- Perk Decks
function UpgradesTweakData:_init_perk_decks_oryo()
	self:_init_crew_chief_oryo()
	self:_init_muscle_oryo()
	self:_init_armorer_oryo()
	self:_init_crook_oryo()
	self:_init_hitman_oryo()
	self:_init_burglar_oryo()
	self:_init_gambler_oryo()
	self:_init_yakuza_oryo()
	self:_init_ex_president_oryo()
	self:_init_maniac_oryo()
	self:_init_biker_oryo()
	self:_init_kingpin_oryo()
	self:_init_sicario_oryo()
	self:_init_stoic_oryo()
end

function UpgradesTweakData:_init_crew_chief_oryo()
	self.definitions.team_hsituation_health_regen = {
		name_id = "menu_team_hsituation_health_regen",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "hsituation_health_regen",
			category = "health_regen"
		}
	}
	self.values.team.health_regen = self.values.team.health_regen or {}
	self.values.team.health_regen.hsituation_health_regen = {0.005}
end

function UpgradesTweakData:_init_muscle_oryo()
	self.definitions.player_meat_shield_dmg_dampener = {
		name_id = "menu_player_meat_shield_dmg_dampener",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "meat_shield_dmg_dampener",
			category = "temporary"
		}
	}
	self.values.temporary.meat_shield_dmg_dampener = {
		{
			0.65,
			7
		}
	}
	self.values.player.uncover_multiplier = {1.35}
end

function UpgradesTweakData:_init_armorer_oryo()
	self.definitions.player_armorer_damage_reduction_1 = {
		name_id = "menu_player_armorer_damage_reduction_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armorer_damage_reduction_1",
			category = "player"
		}
	}
	self.definitions.player_armorer_damage_reduction_2 = {
		name_id = "menu_player_armorer_damage_reduction_2",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armorer_damage_reduction_2",
			category = "player"
		}
	}
	self.definitions.player_armorer_damage_reduction_3 = {
		name_id = "menu_player_armorer_damage_reduction_3",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armorer_damage_reduction_3",
			category = "player"
		}
	}
	self.values.player.armorer_damage_reduction_1 = {0.8}
	self.values.player.armorer_damage_reduction_2 = {0.5}
	self.values.player.armorer_damage_reduction_3 = {0.15}
	
	self.definitions.player_armorer_damage_reduction_threshold_1 = {
		name_id = "menu_player_armorer_damage_reduction_threshold_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armorer_damage_reduction_threshold_1",
			category = "player"
		}
	}
	self.definitions.player_armorer_damage_reduction_threshold_2 = {
		name_id = "menu_player_armorer_damage_reduction_threshold_2",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armorer_damage_reduction_threshold_2",
			category = "player"
		}
	}
	self.definitions.player_armorer_damage_reduction_threshold_3 = {
		name_id = "menu_player_armorer_damage_reduction_threshold_3",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armorer_damage_reduction_threshold_3",
			category = "player"
		}
	}
	self.values.player.armorer_damage_reduction_threshold_1 = {5.0}
	self.values.player.armorer_damage_reduction_threshold_2 = {10.0}
	self.values.player.armorer_damage_reduction_threshold_3 = {15.0}
end

function UpgradesTweakData:_init_crook_oryo()
	self.values.player.level_2_dodge_addend = {
		0.1,
		0.20,
		0.30
	}
	self.values.player.level_3_dodge_addend = {
		0.1,
		0.20,
		0.30
	}
	self.values.player.level_4_dodge_addend = {
		0.1,
		0.20,
		0.30
	}
end

function UpgradesTweakData:_init_hitman_oryo()
	self.values.player.perk_armor_regen_timer_multiplier = {
		0.90,
		0.80,
		0.70,
		0.60,
		0.50
	}
	
	self.definitions.akimbo_fire_rate_multiplier = {
		name_id = "menu_akimbo_fire_rate_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "fire_rate_multiplier",
			category = "akimbo"
		}
	}
	self.values.akimbo.fire_rate_multiplier = {1.25}
end

function UpgradesTweakData:_init_burglar_oryo()
	self.values.player.tier_dodge_chance = {
		0.15,
		0.25,
		0.35
	}
end

function UpgradesTweakData:_init_gambler_oryo()
	self.definitions.player_loose_ammo_restore_health_alt = {
		name_id = "menu_player_loose_ammo_restore_health_alt",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "loose_ammo_restore_health_alt",
			category = "player"
		}
	}
	self.definitions.player_loose_ammo_restore_armor = {
		name_id = "menu_player_loose_ammo_restore_armor",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "loose_ammo_restore_armor",
			category = "player"
		}
	}
	self.definitions.temporary_loose_ammo_crit_bonus = {
		name_id = "menu_temporary_loose_ammo_crit_bonus",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "loose_ammo_crit_bonus",
			category = "temporary"
		}
	}

	self.loose_ammo_restore_health_values = {
		{
			0,
			0
		},
		{
			0,
			0
		},
		{
			0,
			0
		},
		multiplier = 0.2,
		cd = 2.5,
		base = 0
	}
	self.values.temporary.loose_ammo_restore_health = {}
	for i, data in ipairs(self.loose_ammo_restore_health_values) do
		table.insert(self.values.temporary.loose_ammo_restore_health, {
			{
				8,
				16
			},
			self.loose_ammo_restore_health_values.cd
		})
	end
		
	self.loose_ammo_give_team_ratio = 0.25
	self.values.temporary.loose_ammo_give_team = {
		{
			true,
			2.5
		}
	}
	self.values.player.loose_ammo_restore_health_alt = {4}
	self.values.player.loose_ammo_restore_armor = {5}
	self.values.temporary.loose_ammo_crit_bonus = {
		{
			3,
			7
		},
		7.5,
		30,
		60
	}
end

function UpgradesTweakData:_init_yakuza_oryo()
	self.definitions.temporary_shallow_grave = {
		name_id = "menu_temporary_shallow_grave",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "shallow_grave",
			category = "temporary"
		}
	}
	self.values.temporary.shallow_grave = {}
end

function UpgradesTweakData:_init_ex_president_oryo()
	self.values.player.body_armor.skill_max_health_store = {
		15,
		14,
		13.5,
		12.5,
		12,
		10.5,
		9.5
		-- 4
	}
	self.definitions.player_president_dodge_chance = {
		name_id = "menu_player_president_dodge_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "president_dodge_chance",
			category = "player"
		}
	}
	self.values.player.president_dodge_chance = {0.25}
end

function UpgradesTweakData:_init_maniac_oryo()
	self.cocaine_stacks_convert_levels = {30, 25}
	self.cocaine_stacks_tick_t = 3
	self.max_cocaine_stacks_per_tick = 180
	self.cocaine_stacks_decay_percentage_per_tick = 0.5
	self.cocaine_stacks_decay_amount_per_tick = 0
	self.cocaine_stacks_decay_t = 3
	self.cocaine_stacks_decay_trigger_t = 9
	self.max_total_cocaine_stacks = 600
	
	
	self.definitions.player_cocaine_stacks_damage_reduction = {
		name_id = "menu_player_cocaine_stacks_damage_reduction",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "cocaine_stacks_damage_reduction",
			category = "player"
		}
	}
	self.definitions.player_cocaine_stacks_damaged_1 = {
		name_id = "menu_player_cocaine_stacks_damaged_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "cocaine_stacks_damaged_1",
			category = "player"
		}
	}
	self.definitions.player_cocaine_stacks_damaged_2 = {
		name_id = "menu_player_cocaine_stacks_damaged_2",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "cocaine_stacks_damaged_2",
			category = "player"
		}
	}
	self.definitions.player_cocaine_stacks_interaction_speed = {
		name_id = "menu_player_cocaine_stacks_interaction_speed",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "cocaine_stacks_interaction_speed",
			category = "player"
		}
	}
	self.values.player.cocaine_stack_absorption_multiplier = {1.5}
	self.values.player.cocaine_stacks_damage_reduction = {0.75}
	self.values.player.cocaine_stacks_dr_threshold = {450}
	self.values.player.cocaine_stacks_damaged_1 = {0.07}
	self.values.player.cocaine_stacks_damaged_2 = {0.05}
	self.values.player.cocaine_stacks_damaged_cooldown = {0.5}
	self.values.player.cocaine_stacks_interaction_speed = {0.67}
end

function UpgradesTweakData:_init_biker_oryo()
	self.values.player.less_health_wild_cooldown = {
		{
			0.1,
			0.2
		}
	}
	self.values.player.less_armor_cooldown = {
		{
			0.1,
			0.2
		}
	}
end

function UpgradesTweakData:_init_kingpin_oryo()
	self.values.player.chico_injector_health_to_speed = {
		{
			0.5,
			1
		}
	}

end

function UpgradesTweakData:_init_sicario_oryo()
	self.values.player.dodge_shot_gain = {
		{
			0.2,
			4
		}
	}
end

function UpgradesTweakData:_init_stoic_oryo()
	self.definitions.player_damage_control_reduced_regen = {
		name_id = "menu_player_damage_control_reduced_regen",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "damage_control_reduced_regen",
			category = "player"
		}
	}
	self.values.player.damage_control_reduced_regen = {0.75}
end


-- Crew Bonuses
function UpgradesTweakData:_init_crew_bonuses_oryo()

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
end