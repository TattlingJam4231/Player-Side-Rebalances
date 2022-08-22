if not wr_tweakstats then
	if not tweak_data then return end

	tweak_data.projectiles.launcher_rocket = {
		damage = 620,
		launch_speed = 2500,
		curve_pow = 0.1,
		player_damage = 40,
		range = 800,
		init_timer = 2.5,
		mass_look_up_modifier = 1,
		sound_event = "rpg_explode",
		name_id = "bm_launcher_rocket"
	}

	tweak_data.projectiles.rocket_ray_frag = {
		damage = 210,
		launch_speed = 2500,
		curve_pow = 0.1,
		player_damage = 20,
		range = 600,
		init_timer = 2.5,
		mass_look_up_modifier = 1,
		sound_event = "rpg_explode",
		name_id = "bm_launcher_rocket",
		projectile_trail = true,
		adjust_z = 0,
		push_at_body_index = 0
	}

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

	tweak_data.projectiles.launcher_frag_arbiter = {
		damage = 54,
		launch_speed = 7000,
		curve_pow = 0.4,
		player_damage = 4,
		range = 350,
		init_timer = 2.5,
		mass_look_up_modifier = 1,
		sound_event = "gl_explode",
		name_id = "bm_launcher_frag"
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
	
	-- tweak_data.projectiles.molotov = {
	-- 	damage = 3,
	-- 	player_damage = 2,
	-- 	fire_dot_data = {
	-- 		dot_trigger_chance = 35,
	-- 		dot_damage = 1,
	-- 		dot_length = 3,
	-- 		dot_trigger_max_distance = 3000,
	-- 		dot_tick_period = 0.5
	-- }
	
	-- tweak_data.projectiles.launcher_incendiary = {
	-- 	damage = 10,
	-- 	launch_speed = 1250,
	-- 	curve_pow = 0.1,
	-- 	player_damage = 2,
	-- 	fire_dot_data = {
	-- 		dot_trigger_chance = 35,
	-- 		dot_damage = 25,
	-- 		dot_length = 6.1,
	-- 		dot_trigger_max_distance = 3000,
	-- 		dot_tick_period = 0.5
	-- }
	
	-- tweak_data.projectiles.launcher_incendiary_arbiter = {
	-- 	damage = 10,
	-- 	launch_speed = 7000,
	-- 	curve_pow = 0.1,
	-- 	player_damage = 2,
	-- 	fire_dot_data = {
	-- 		dot_trigger_chance = 35,
	-- 		dot_damage = 25,
	-- 		dot_length = 6.1,
	-- 		dot_trigger_max_distance = 3000,
	-- 		dot_tick_period = 0.5
	-- }
	
	-- tweak_data.projectiles.fir_com = {
	-- 	damage = 3,
	-- 	curve_pow = 0.1,
	-- 	player_damage = 3,
	-- 	fire_dot_data = {
	-- 		dot_trigger_chance = 100,
	-- 		dot_damage = 25,
	-- 		dot_length = 2.1,
	-- 		dot_trigger_max_distance = 3000,
	-- 		dot_tick_period = 0.5
	-- 	},
	-- 	range = 500,
	-- 	name_id = "bm_grenade_fir_com",
	-- 	sound_event = "white_explosion",
	-- 	effect_name = "effects/payday2/particles/explosions/grenade_incendiary_explosion"
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

	wr_tweakstats = true
end