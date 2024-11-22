function BlackMarketTweakData:_init_stat_index_oryo()
	self.stat_index = {
		sharp_light = {
			melee_damage_delay = 0.1,
			repeat_expire_t = 0.25,
			expire_t = 0.6,
			min_damage = 3,
			max_damage = 12,
			min_damage_effect = 1,
			max_damage_effect = 1,
			charge_time = 0.5,
			range = 185,
			concealment = 30 
		},
		blunt_light = {
			melee_damage_delay = 0.1,
			repeat_expire_t = 0.3,
			expire_t = 1,
			min_damage = 3,
			max_damage = 8,
			min_damage_effect = 4,
			max_damage_effect = 4,
			charge_time = 0.5,
			range = 185,
			concealment = 30 
		},
		blunt_medium = {
			melee_damage_delay = 0.2,
			repeat_expire_t = 0.4,
			expire_t = 1,
			min_damage = 5,
			max_damage = 24,
			min_damage_effect = 1.5,
			max_damage_effect = 1.5,
			charge_time = 1,
			range = 225,
			concealment = 29 
		},
		sharp_heavy = {
			melee_damage_delay = 0.2,
			repeat_expire_t = 0.6,
			expire_t = 1,
			min_damage = 8,
			max_damage = 48,
			min_damage_effect = 0.5,
			max_damage_effect = 0.5,
			charge_time = 2,
			range = 250,
			concealment = 28 
		},
		blunt_heavy = {
			melee_damage_delay = 0.3,
			repeat_expire_t = 0.9,
			expire_t = 1.1,
			min_damage = 12,
			max_damage = 12,
			min_damage_effect = 2,
			max_damage_effect = 8,
			charge_time = 1,
			range = 250,
			concealment = 27 
		},
		tasers = {
			melee_damage_delay = 0.15,
			repeat_expire_t = 0.6,
			expire_t = 1,
			min_damage = 2,
			max_damage = 2,
			min_damage_effect = 1,
			max_damage_effect = 1,
			charge_time = 2,
			range = 200,
			concealment = 29 
		}
	}
end


function BlackMarketTweakData:_init_melee_index_oryo()
	self.melee_index = {
		sharp_light = {
			"kabartanto",		-- Ursa Tanto Knife
			"toothbrush",		-- Nova's Shank
			"kabar", 			-- URSA Knife
			"aziz",				-- Tactical Flashlight
			"clean",			-- Alabama Razor
			"fork",				-- The Motherforker	
			"shawn",			-- Shawn's Shears
			"boxcutter",		-- Utility Knife
			"bayonet",			-- Bayonet Knife
			"gator",			-- Machete
			"sword",			-- The Pen
			"fear",				-- Stainless Steel Syringe
			"ballistic",		-- Specialist Knives
			"pugio",			-- Diving Knife
			"kampfmesser",		-- Krieger Blade
			"wing",				-- Wing Butterfly Knife
			"ostry",			-- Kazaguruma
			"bullseye",			-- Compact Hatchet
			"brick",			-- Hotline 8000x
			"scalper",			-- Scalper Tomahawk
			"switchblade",		-- Switchblade
			"grip",				-- Knuckle Daggers
			"push",				-- Push Daggers
			"meat_cleaver",		-- Dragan's Cleaver Knife
			"twins",			-- Okinawan Style Sai
			"bowie",			-- Arkansas Toothpick
			"chef",				-- Psycho Knife
			"x46",				-- X-46 Knife
			"tiger",			-- Talons
			"catch",			-- Hook
			"cleaver",			-- Cleaver Knife
			"scoutknife",		-- Scout Knife
			"gerber",			-- Berger Combat Knife
			"fairbair",			-- Trench Knife
			"tomahawk",			-- Survival Tomahawk
			"machete",			-- Machete Knife
			"becker",			-- Utility Machete
			"cqc",				-- Kunai Knife
			"rambo"				-- Trautman Knife
		},
		blunt_light = {
			"fists",			-- Fists
			"brass_knuckles",	-- 350K Brass Knuckles
			"briefcase",		-- 50 Blessings Briefcase
			"spatula",			-- Spatula
			"moneybundle",		-- Money Bundle
			"fight",			-- Empty Palm Kata
			"microphone",		-- Microphone
			"chac",				-- El Ritmo
			"buck",				-- Buckler Shield
			"detector",			-- Metal Detector
			"boxing_gloves",	-- OVERKILL Boxing Gloves
			"whiskey"			-- Rivertown Glen Bottle
		},
		blunt_medium = {
			"swagger",			-- Swagger Stick
			"cutters",			-- Bolt Cutters
			"selfie",			-- Selfie Stick
			"baton",			-- Telescopic Baton
			"slot_lever",		-- Jackpot
			"baseballbat",		-- Baseball Bat
			"oldbaton",			-- Classic Baton
			"hockey",			-- Hockey Stick
			"happy",			-- Hackaton
			"branding_iron",	-- You're Mine
			"croupier_rake",	-- Croupier's Rake
			"model24",			-- Potato Masher
			"micstand",			-- Microphone Stand
			"shillelagh",		-- Clover's Shillelagh
			"stick",			-- Shepherd's Cane
			"poker",			-- Poker
			"barbedwire",		-- Lucille Baseball Bat
			"shock"				-- Monkey Wrench
		},
		sharp_heavy = {
			"nin",				-- Pounder
			"road",				-- Chain Whip
			"iceaxe",			-- Ice Pick
			"oxide",			-- Rezkoye
			"hauteur",			-- Kento's Tanto
			"meter",			-- Two Handed Great Ruler
			"agave",			-- El Verdugo
			"cs",				-- Lumber Lite L2
			"sandsteel",		-- Shinsakuto Katana
			"pitchfork",		-- Pitchfork
			"beardy",			-- Bearded Axe
			"mining_pick",		-- Gold Fever
			"great",			-- Great Sword
			"freedom",			-- The Spear of Freedom
			"fireaxe"			-- Fire Axe
		},
		blunt_heavy = {
			"shovel",			-- K.L.A.S. Shovel
			"sap",				-- Leather Sap
			"hammer",			-- Carpenter's Delight
			"morning",			-- Morning Star
			"dingdong",			-- Ding Dong Breaching Tool
			"tenderizer"		-- Tenderizer
		},
		tasers = {
			"zeus",				-- Electrical Brass Knuckles
			"taser"				-- Buzzer
		}
	}
end


function BlackMarketTweakData:_init_default_stats_oryo()
	for category, weapons in pairs(self.melee_index) do
		for _, weapon in ipairs(weapons) do
			self.melee_weapons[weapon].melee_damage_delay = self.stat_index[category].melee_damage_delay
			self.melee_weapons[weapon].repeat_expire_t = self.stat_index[category].repeat_expire_t
			-- self.melee_weapons[weapon].expire_t = self.stat_index[category].expire_t
			self.melee_weapons[weapon].stats.min_damage = self.stat_index[category].min_damage
			self.melee_weapons[weapon].stats.max_damage = self.stat_index[category].max_damage
			self.melee_weapons[weapon].stats.min_damage_effect = self.stat_index[category].min_damage_effect
			self.melee_weapons[weapon].stats.max_damage_effect = self.stat_index[category].max_damage_effect
			self.melee_weapons[weapon].stats.charge_time = self.stat_index[category].charge_time
			self.melee_weapons[weapon].stats.range = self.stat_index[category].range
			self.melee_weapons[weapon].stats.concealment = self.stat_index[category].concealment
		end
	end
end



Hooks:PostHook(BlackMarketTweakData, "_init_melee_weapons", "Oryo BlackMarketTweakData _init_melee_weapons", function(self)

	-- 30		|	30
		--[[ self.melee_weapons.weapon = {
			name_id = "bm_melee_weapon",
			type = "weapon",
			unit = nil,
			animation = nil,
			instant = true,
			free = true,
			expire_t = 0.6,
			repeat_expire_t = 0.6,
			stats = {
				min_damage = 3,
				max_damage = 3,
				min_damage_effect = 1,
				max_damage_effect = 1,
				charge_time = 0,
				range = 150,
				weapon_type = "blunt"
			},
			sounds = {
				hit_body = "melee_hit_body",
				hit_gen = "melee_hit_gen"
			}
		} ]]

	self:_init_stat_index_oryo()
	self:_init_melee_index_oryo()
	self:_init_default_stats_oryo()

	-- Kunai Knife
	self.melee_weapons.cqc.stats.min_damage = 2
	self.melee_weapons.cqc.stats.max_damage = 8

	-- Stainless Steel Syringe
	self.melee_weapons.fear.stats.min_damage = 2
	self.melee_weapons.fear.stats.max_damage = 8

	-- The Motherforker	
	self.melee_weapons.fork.stats.min_damage = 1.5
	self.melee_weapons.fork.stats.max_damage = 6
	self.melee_weapons.fork.dot_data_name = "melee_fork"

	-- Spatula
	self.melee_weapons.spatula.stats.min_damage = 1.5
	self.melee_weapons.spatula.stats.max_damage = 1.5
	self.melee_weapons.spatula.dot_data_name = "melee_spatula"

	-- You're Mine
	self.melee_weapons.branding_iron.stats.min_damage = 4
	self.melee_weapons.branding_iron.stats.max_damage = 10
	self.melee_weapons.branding_iron.dot_data_name = "melee_branding_iron"
end)