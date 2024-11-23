if not oryo_tweakstats then
	if not tweak_data then return end

	-- Sicario Smoke Grenade
	tweak_data.blackmarket.projectiles.smoke_screen_grenade = {
		name_id = "bm_grenade_smoke_screen_grenade",
		desc_id = "bm_grenade_smoke_screen_grenade_desc",
		unit = "units/pd2_dlc_max/weapons/wpn_fps_smoke_screen_grenade/wpn_third_smoke_screen_grenade",
		unit_dummy = "units/pd2_dlc_max/weapons/wpn_fps_smoke_screen_grenade/wpn_fps_smoke_screen_grenade_husk",
		sprint_unit = "units/pd2_dlc_max/weapons/wpn_fps_smoke_screen_grenade/wpn_third_smoke_screen_grenade_sprint",
		icon = "smoke_screen_grenade",
		texture_bundle_folder = "max",
		base_cooldown = 45,
		max_amount = 2,
		is_a_grenade = true,
		throwable = true,
		animation = "throw_grenade_com",
		anim_global_param = "projectile_frag_com",
		no_shouting = true
	}

	-- HRL Rocket
	tweak_data.projectiles.launcher_rocket = {
		damage = 1100,
		launch_speed = 2500,
		curve_pow = 1,
		player_damage = 40,
		range = {
			max = 600,
			falloff_start = 100
		},
		init_timer = 2.5,
		mass_look_up_modifier = 1,
		sound_event = "rpg_explode",
		name_id = "bm_launcher_rocket"
	}

	-- Commando Rocket
	tweak_data.projectiles.rocket_ray_frag = {
		damage = 550,
		launch_speed = 2500,
		curve_pow = 1,
		player_damage = 20,
		range = {
			max = 600,
			falloff_start = 100
		},
		init_timer = 2.5,
		mass_look_up_modifier = 1,
		sound_event = "rpg_explode",
		name_id = "bm_launcher_rocket",
		projectile_trail = true,
		adjust_z = 0,
		push_at_body_index = 0
	}

	-- China Puff Grenade
	tweak_data.projectiles.launcher_frag_china = {
		damage = 96,
		launch_speed = 1250,
		curve_pow = 0,
		player_damage = 8,
		range = 250,
		init_timer = 2.5,
		mass_look_up_modifier = 1,
		sound_event = "gl_explode",
		name_id = "bm_launcher_frag"
	}

	-- Arbiter Grenade
	tweak_data.projectiles.launcher_frag_arbiter = {
		damage = 48,
		launch_speed = 7000,
		curve_pow = 0.2,
		player_damage = 4,
		range = {
			max = 350,
			falloff_start = 150
		},
		init_timer = 2.5,
		mass_look_up_modifier = 1,
		sound_event = "gl_explode",
		name_id = "bm_launcher_frag"
	}
	
	--Basilisk 3V Grenade
	tweak_data.projectiles.launcher_frag_ms3gl = {
		damage = 32,
		launch_speed = 1250,
		curve_pow = 0,
		player_damage = 3,
		range = 350,
		init_timer = 2.5,
		mass_look_up_modifier = 1,
		sound_event = "gl_explode",
		name_id = "bm_launcher_frag"
	}

	-- Incendiary Grenade
	-- self.projectiles.fir_com = {
	-- 	damage = 3,
	-- 	curve_pow = 0.1,
	-- 	player_damage = 3,
	-- 	dot_data_name = "proj_fire_com",
	-- 	range = 500,
	-- 	name_id = "bm_grenade_fir_com",
	-- 	sound_event = "white_explosion",
	-- 	effect_name = "effects/payday2/particles/explosions/grenade_incendiary_explosion"
	-- }

	-- Molotov Grenade
	tweak_data.projectiles.molotov = {
		damage = 3,
		player_damage = 1,
		dot_data_name = "proj_molotov",
		range = 350,
		burn_duration = 12,
		burn_tick_period = 0.5,
		sound_event = "molotov_impact",
		sound_event_impact_duration = 0,
		name_id = "bm_grenade_molotov",
		alert_radius = 1500,
		fire_alert_radius = 1500
	}
	
	-- Arbiter Incendiary Grenade
	-- tweak_data.projectiles.launcher_incendiary_arbiter = {
	-- 	damage = 10,
	-- 	launch_speed = 7000,
	-- 	curve_pow = 0.1,
	-- 	player_damage = 2,
	-- 	dot_data_name = "proj_launcher_incendiary_arbiter",
	-- 	range = 350,
	-- 	init_timer = 2.5,
	-- 	mass_look_up_modifier = 1,
	-- 	sound_event = "gl_explode",
	-- 	sound_event_impact_duration = 1,
	-- 	effect_name = "effects/payday2/particles/explosions/grenade_incendiary_explosion",
	-- 	name_id = "bm_launcher_incendiary",
	-- 	burn_duration = 3,
	-- 	burn_tick_period = 0.5
	-- }
	
	-- Basilisk 3V Incendiary Grenade
	tweak_data.projectiles.launcher_incendiary_ms3gl = {
		damage = 1,
		launch_speed = 1250,
		curve_pow = 0,
		player_damage = 2,
		dot_data_name = "proj_launcher_incendiary_arbiter",
		range = 350,
		init_timer = 2.5,
		mass_look_up_modifier = 1,
		sound_event = "gl_explode",
		sound_event_impact_duration = 1,
		effect_name = "effects/payday2/particles/explosions/grenade_incendiary_explosion",
		name_id = "bm_launcher_incendiary",
		burn_duration = 3,
		burn_tick_period = 0.5
	}

	-- Viper Grenade
	tweak_data.projectiles.poison_gas_grenade = {
		damage = 25,
		player_damage = 0,
		curve_pow = 0.1,
		range = 200,
		name_id = "bm_poison_gas_grenade",
		poison_gas_range = 800,
		poison_gas_duration = 20,
		poison_gas_fade_time = 2,
		poison_gas_tick_time = 0.3,
		poison_gas_dot_data_name = "proj_gas_grenade_cloud"
	}

	-- Basilisk 3V Viper Grenade
	tweak_data.projectiles.launcher_poison = {
		damage = 8,
		launch_speed = 1250,
		projectile_trail = true,
		curve_pow = 0,
		player_damage = 0,
		range = 300,
		init_timer = 2.5,
		mass_look_up_modifier = 1,
		sound_event = "gl_electric_explode",
		name_id = "bm_launcher_frag",
		poison_gas_range = 400,
		poison_gas_duration = 15,
		poison_gas_fade_time = 2,
		poison_gas_tick_time = 0.3,
		poison_gas_dot_data_name = "proj_launcher_arbiter_cloud",
		poison_gas_effect = "effects/particles/explosions/poison_gas"
	}

	-- Basilisk 3V Conversion Grenade
	tweak_data.projectiles.launcher_poison_ms3gl_conversion = {
		damage = 12,
		launch_speed = 1250,
		projectile_trail = true,
		curve_pow = 0.1,
		player_damage = 0,
		range = 300,
		init_timer = 2.5,
		mass_look_up_modifier = 1,
		sound_event = "gl_electric_explode",
		name_id = "bm_launcher_frag",
		poison_gas_range = 600,
		poison_gas_duration = 20,
		poison_gas_fade_time = 2,
		poison_gas_tick_time = 0.3,
		poison_gas_dot_data_name = "proj_launcher_arbiter_cloud",
		poison_gas_effect = "effects/particles/explosions/poison_gas"
	}

	-- GL40 Viper Grenade
	tweak_data.projectiles.launcher_poison_gre_m79 = {
		damage = 32.5,
		launch_speed = 1250,
		projectile_trail = true,
		curve_pow = 0.1,
		player_damage = 0,
		range = 600,
		init_timer = 2.5,
		mass_look_up_modifier = 1,
		sound_event = "gl_electric_explode",
		name_id = "bm_launcher_frag",
		poison_gas_range = 600,
		poison_gas_duration = 20,
		poison_gas_fade_time = 2,
		poison_gas_tick_time = 0.3,
		poison_gas_dot_data_name = "proj_launcher_cloud",
		poison_gas_effect = "effects/particles/explosions/poison_gas"
	}

	-- Piglet Viper Grenade
	tweak_data.projectiles.launcher_poison_m32 = deep_clone(tweak_data.projectiles.launcher_poison_gre_m79)

	-- Compact 40 Viper Grenade
	tweak_data.projectiles.launcher_poison_slap = deep_clone(tweak_data.projectiles.launcher_poison_gre_m79)

	-- China Puff Viper Grenade
	tweak_data.projectiles.launcher_poison_china = {
		damage = 24,
		launch_speed = 1250,
		projectile_trail = true,
		curve_pow = 0,
		player_damage = 0,
		range = 300,
		init_timer = 2.5,
		mass_look_up_modifier = 1,
		sound_event = "gl_electric_explode",
		name_id = "bm_launcher_frag",
		poison_gas_range = 600,
		poison_gas_duration = 15,
		poison_gas_fade_time = 2,
		poison_gas_tick_time = 0.3,
		poison_gas_dot_data_name = "proj_launcher_cloud",
		poison_gas_effect = "effects/particles/explosions/poison_gas"
	}

	-- KETCHNOV Byk-1 Viper Grenade
	tweak_data.projectiles.launcher_poison_groza = deep_clone(tweak_data.projectiles.launcher_poison_china)

	-- Little Friend 7.62 Viper Grenade
	tweak_data.projectiles.launcher_poison_contraband = deep_clone(tweak_data.projectiles.launcher_poison_china)


	-- Arbiter Viper Grenade
	tweak_data.projectiles.launcher_poison_arbiter = {
		damage = 12,
		launch_speed = 7000,
		projectile_trail = true,
		curve_pow = 0.2,
		player_damage = 0,
		range = 300,
		init_timer = 2.5,
		mass_look_up_modifier = 1,
		sound_event = "gl_electric_explode",
		name_id = "bm_launcher_frag",
		poison_gas_range = 400,
		poison_gas_duration = 15,
		poison_gas_fade_time = 2,
		poison_gas_tick_time = 0.3,
		poison_gas_dot_data_name = "proj_launcher_arbiter_cloud",
		poison_gas_effect = "effects/particles/explosions/poison_gas"
	}

	-- tweak_data.projectiles.launcher_m203 = {
	-- 	damage = 130,
	-- 	launch_speed = 1250,
	-- 	curve_pow = 0.1,
	-- 	player_damage = 8,
	-- 	range = 350,
	-- 	init_timer = 2.5,
	-- 	mass_look_up_modifier = 1,
	-- 	sound_event = "gl_explode",
	-- 	name_id = "bm_launcher_frag",
	-- 	projectile_trail = true
	-- }

	-- tweak_data.projectiles.underbarrel_m203_groza = {
	-- 	damage = 130,
	-- 	launch_speed = 1250,
	-- 	curve_pow = 0.1,
	-- 	player_damage = 8,
	-- 	range = 350,
	-- 	init_timer = 2.5,
	-- 	mass_look_up_modifier = 1,
	-- 	sound_event = "gl_explode",
	-- 	name_id = "bm_launcher_frag",
	-- 	projectile_trail = true
	-- }

	-- tweak_data.projectiles.wpn_prj_four = {
	-- 	damage = 10,
	-- 	launch_speed = 1500,
	-- 	adjust_z = 0,
	-- 	mass_look_up_modifier = 1,
	-- 	name_id = "bm_prj_four",
	-- 	push_at_body_index = 0,
	-- 	dot_data = {
	-- 		type = "poison"
	-- 	},
	-- 	bullet_class = "ProjectilesPoisonBulletBase",
	-- 	sounds = {}
	-- }

	oryo_tweakstats = true
end