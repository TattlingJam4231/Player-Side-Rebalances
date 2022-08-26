Hooks:Add("LocalizationManagerPostInit", "Oryo Skill Localization", function(loc)
	LocalizationManager:add_localized_strings({

		--Medic------------------------------------------------------------------------------------
		["menu_fast_learner_beta_desc"] = 				"BASIC: ##2 points##\n" ..
														"Crew members you revive take ##30%## less damage for ##7## seconds.\n\n" ..
														"ACE: ##4 points##\n" ..
														"The damage reduction is increased by an additional ##50%##.",

		["menu_combat_medic_beta_desc"] = 				"BASIC: ##1 points##\n" ..
														"You gain a ##30%## damage reduction for ##7## seconds both after and during reviving another player.\n\n" ..
														"ACE: ##3 points##\n" ..
														"Reviving a crew  member gives them an additional ##15%## of their max health.",

		--Controller-------------------------------------------------------------------------------
		["menu_triathlete_beta_desc"] =					"BASIC: ##1 points##\n" ..
														"Increases your supply of cable ties by ##4##. You can cable tie hostages ##75%## faster.\n\n" ..
														"ACE: ##3 points##\n" ..
														"You and your crew gain ##1## damage absorption for each hostage you have. This effect stacks with up to a maximum of ##4## hostages.\n\n" ..
														"Note: This effect does not stack with other players Forced Friendship skill.",

		--Sharpshooter-----------------------------------------------------------------------------
		["menu_sniper_graze_damage_desc"] = 			"BASIC: ##4 points##\n" ..
														"Snipers that hit their target deal ##20%## of the damage dealt in a ##1m## radius around the bullet ##trajectory##.\n\n" ..
														"When fired in single shot fire mode, SMGs and Assault Rifles that hit their target deal ##20%## of the damage dealt in a ##2.5m## radius around the bullet ##impact##.\n\n" ..
														"ACE: ##8 points##\n" ..
														"If a Sniper would ##headshot kill## someone, the graze skill will deal ##100%## of the damage dealt instead of ##20%##.\n\n" ..
														"If an SMG or Assault Rifle fired in single shot fire mode would ##headshot## someone, the graze skill will deal ##50%## of the damage dealt instead of ##20%##.",

		["menu_single_shot_ammo_return_beta_desc"] =	"BASIC: ##3 points##\n" ..
														"Getting a headshot within ##2## seconds of your previous headshot will refund ##1## bullet to your used weapon. " ..
														"Can only be triggered by SMGs, Assault Rifles and Sniper Rifles fired in single shot fire mode.\n\n" ..
														"ACE: ##6 points##\n" ..
														"The time window is increased to ##4## seconds.",

		["menu_speedy_reload_beta_desc"] = 				"BASIC: ##3 points##\n" ..
														"Increases your reload speed with SMGs, Assault Rifles and Sniper Rifles by ##35%##\n\n" ..
														"ACE: ##6 points##\n" ..
														"Any killing headshot will increase your reload speed by ##100%## for ##4## seconds. " ..
														"Can only be triggerd by SMGs, Assault Rifles and Sniper Rifles fired in single shot fire mode.",

		--Shotgunner-------------------------------------------------------------------------------
		["menu_shotgun_cqb_beta_desc"] = 				"BASIC: ##2 points##\n" ..
														"You reload Shotguns ##15%## faster.\n\n" ..
														"ACE: ##4 points##\n" ..
														"You reload Shotguns an additional ##35%## faster. You gain a ##125%## increased steel sight zoom speed when using Shotguns.",

		--Ammo Specialist--------------------------------------------------------------------------
		["menu_bandoliers_beta_desc"] = 				"BASIC: ##4 points##\n" ..
														"Your total ammo capacity is increased by ##25%##.\n\n" ..
														"ACE: ##8 points##\n" ..
														"Increases the amount of ammo you gain from ammo boxes by ##50%##. " ..
														"Increases your chance to get a throwable from an ammo box to ##6%##. " ..
														"The chance is increased by an additional ##0.2%## for each ammo box you pick up that does not contain a throwable. " ..
														"When a throwable has been found, the chance is reset to its base value.",

		--Oppressor--------------------------------------------------------------------------------
		["menu_fire_control_beta_desc"] = 				"BASIC: ##2 points##\n" ..
														"Your accuracy penalty is decreased by ##20%## when shooting while moving.\n\n" ..
														"ACE: ##4 points##\n" ..
														"You gain ##12## weapon accuracy while firing from the hip.",

		--Silent Killer----------------------------------------------------------------------------
		["menu_unseen_strike_beta_desc"] = 				"BASIC: ##4 points##\n" ..
														"If you do not lose any armor or health for ##4## seconds, you gain ##35%## critical hit chance. " ..
														"This effect will expire ##4## seconds after taking damage.\n\n" ..
														"ACE: ##8 points##\n" ..
														"The effect will now expire ##12## seconds after taking damage.\n\n" ..
														"Note: Taking damage while the effect is active will trigger a ##4## second cooldown when the effect expires.",

		["menu_scavenger_beta_desc"] = 					"BASIC: ##1 points##\n" ..
														"When your armor breaks your movement speed is increased by ##30%## for ##7## seconds.\n\n" ..
														"ACE: ##3 points##\n" ..
														"This effect also applies to your crew when triggered.",

		--Gunslinger-------------------------------------------------------------------------------
		["menu_expert_handling_desc"] = 				"BASIC: ##3 points##\n" ..
														"Each successful pistol hit gives you a 10% increased accuracy bonus for ##10## seconds and can stack ##4## times.\n\n" ..
														"ACE: ##6 points##\n" ..
														"You gain a ##50%## increased rate of fire with pistols.",

		["menu_dance_instructor_desc"] = 				"BASIC: ##2 points##\n" ..
														"Your pistol magazine sizes are increased by ##5## bullets.\n\n" ..
														"ACE: ##4 points##\n" ..
														"You reload all pistols ##50%## faster.",

		--Revenant---------------------------------------------------------------------------------
		["menu_running_from_death_beta_desc"] = 		"BASIC: ##2 points##\n" ..
														"You reload and swap weapons ##50%## faster for ##7## seconds after being damaged or revived.\n\n" ..
														"ACE: ##4 points##\n" ..
														"You move ##30%## faster for ##7## seconds after being damaged or revived.",

		["menu_up_you_go_beta_desc"] = 					"BASIC: ##2 points##\n" ..
														"You take ##10%## less damage for ##7## seconds after being damaged or revived.\n\n" ..
														"ACE: ##4 points##\n" ..
														"You receive an additional ##20%## of your max health when revived."
	})
end)