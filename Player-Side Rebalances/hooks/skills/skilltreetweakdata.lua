Hooks:PostHook(SkillTreeTweakData, "init", "Oryo SkillTreeTweakData init", function(self)

	self.skills.dance_instructor = {
		{
			upgrades = {
				"pistol_magazine_capacity_inc_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"pistol_reload_speed_multiplier"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_dance_instructor",
		desc_id = "menu_dance_instructor_desc",
		icon_xy = {
			11,
			0
		}
	}
	self.skills.expert_handling = {
		{
			upgrades = {
				"pistol_stacked_accuracy_bonus_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"pistol_fire_rate_multiplier"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_expert_handling",
		desc_id = "menu_expert_handling_desc",
		icon_xy = {
			11,
			1
		}
	}
	self.skills.fire_control = {
		{
			upgrades = {
				"player_weapon_movement_stability_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_hip_fire_accuracy_inc_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_fire_control_beta",
		desc_id = "menu_fire_control_beta_desc",
		icon_xy = {
			9,
			10
		}
	}
	self.skills.bandoliers = {
		{
			upgrades = {
				"extra_ammo_multiplier1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_pick_up_ammo_multiplier_2",
				"player_regain_throwable_from_ammo_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_bandoliers_beta",
		desc_id = "menu_bandoliers_beta_desc",
		icon_xy = {
			3,
			0
		}
	}
end)