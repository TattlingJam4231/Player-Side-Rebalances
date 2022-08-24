Hooks:Add("LocalizationManagerPostInit", "Oryo Weapon Localization", function(loc)
	LocalizationManager:add_localized_strings({
		["bm_wp_upg_a_custom_desc"] =					"Fewer pellets but larger impact. Pellets can penetrate one enemy and can penetrate walls at close range.",

		["bm_wp_upg_a_explosive_desc"] =				"Fires one explosive charge that kills or stuns targets. This ammo type is harder to find.",

		["bm_wp_upg_a_piercing_desc"] =					"Fires darts that have a longer effective range. Penetrates body armor and causes enemies to bleed.",

		["bm_wp_upg_a_slug_desc"] =						"Fires a single lead slug that has a longer effective range. Penetrates enemies, shields and walls up to four times. Penetrates body armor.",

		["bm_wp_upg_a_dragons_breath_desc"] = 			"Fires pellets that go up in sparks and flames. Burns through shields and body armor. This ammo type is harder to find.",
		
		["bm_wp_upg_i_singlefire"] = 					"Select Fire: Single/Burst"
	})
end)