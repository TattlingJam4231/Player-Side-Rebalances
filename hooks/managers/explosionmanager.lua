function ExplosionManager:_damage_characters(detect_results, params, variant, damage_func_name)
	local user_unit = params.user
	local owner = params.owner
	local damage = params.damage
	local hit_pos = params.hit_pos
	local col_ray = params.col_ray
	local range = params.range
	local curve_pow = params.curve_pow
	local verify_callback = params.verify_callback
	local ignite_character = params.ignite_character
	damage_func_name = damage_func_name or "damage_explosion"
	local counts = {
		cops = {
			kills = 0,
			hits = 0
		},
		gangsters = {
			kills = 0,
			hits = 0
		},
		civilians = {
			kills = 0,
			hits = 0
		},
		criminals = {
			kills = 0,
			hits = 0
		}
	}
	local criminal_names = CriminalsManager.character_names()

	local function get_first_body_hit(bodies_hit)
		for _, hit_body in ipairs(bodies_hit or {}) do
			if alive(hit_body) then
				return hit_body
			end
		end
	end

	local dir, len, type, count_table, hit_body = nil

    local units_hit = {}
	for key, unit in pairs(detect_results.characters_hit) do
		hit_body = get_first_body_hit(detect_results.bodies_hit[key])
		dir = hit_body and hit_body:center_of_mass() or alive(unit) and unit:position()
		len = mvector3.direction(dir, hit_pos, dir)
		local can_damage = not verify_callback

		if verify_callback then
			can_damage = verify_callback(unit)
		end

		if alive(unit) and can_damage then
			if unit:character_damage()[damage_func_name] then
				local action_data = {
					variant = variant or "explosion"
				}

				if damage > 0 then
                    action_data.damage = self:get_explosion_falloff_oryo(damage, range, curve_pow, len) -- Player-Side Rebalances: falloff start
				else
					action_data.damage = 0
				end

				action_data.attacker_unit = user_unit
				action_data.weapon_unit = owner
				action_data.col_ray = col_ray or {
					position = unit:position(),
					ray = dir
				}
				action_data.ignite_character = ignite_character

				unit:character_damage()[damage_func_name](unit:character_damage(), action_data)
			else
				debug_pause("unit: ", unit, " is missing " .. tostring(damage_func_name) .. " implementation")
			end
		end

		if alive(unit) and unit:base() and unit:base()._tweak_table then
			type = unit:base()._tweak_table

			if table.contains(criminal_names, CriminalsManager.convert_new_to_old_character_workname(type)) then
				count_table = counts.criminals
			elseif CopDamage.is_civilian(type) then
				count_table = counts.civilians
			elseif CopDamage.is_gangster(type) then
				count_table = counts.gangsters
			else
				count_table = counts.cops
			end

			count_table.hits = count_table.hits + 1

			if unit:character_damage():dead() then
				count_table.kills = count_table.kills + 1
			end
		end
	end

	local results = {
		count_cops = counts.cops.hits,
		count_gangsters = counts.gangsters.hits,
		count_civilians = counts.civilians.hits,
		count_criminals = counts.criminals.hits,
		count_cop_kills = counts.cops.kills,
		count_gangster_kills = counts.gangsters.kills,
		count_civilian_kills = counts.civilians.kills,
		count_criminal_kills = counts.criminals.kills
	}

	return results
end

function ExplosionManager:_damage_bodies(detect_results, params)
	local user_unit = params.user
	local hit_pos = params.hit_pos
	local damage = params.damage
	local range = params.range
	local curve_pow = params.curve_pow

	for _, bodies in pairs(detect_results.bodies_hit) do
		for _, hit_body in ipairs(bodies) do
			local apply_dmg = alive(hit_body) and hit_body:extension() and hit_body:extension().damage

			if apply_dmg then
				local dir = hit_body:center_of_mass()
				local len = mvector3.direction(dir, hit_pos, dir)
				local prop_damage = self:get_explosion_falloff_oryo(damage, range, curve_pow, len) -- Player-Side Rebalances: falloff start
				prop_damage = math.max(prop_damage, math.min(damage, 1))

				self:_apply_body_damage(true, hit_body, user_unit, dir, prop_damage)
			end
		end
	end
end

function ExplosionManager:client_damage_and_push(position, normal, user_unit, dmg, range, curve_pow)
	local bodies = World:find_bodies("intersect", "sphere", position, range, managers.slot:get_mask("bullet_impact_targets"))
	local units_to_push = {}

	for _, hit_body in ipairs(bodies) do
		local hit_unit = hit_body:unit()
		units_to_push[hit_body:unit():key()] = hit_unit
		local apply_dmg = hit_body:extension() and hit_body:extension().damage and hit_unit:id() == -1
		local dir, len, damage = nil

		if apply_dmg then
			dir = hit_body:center_of_mass()
			len = mvector3.direction(dir, position, dir)
			damage = self:get_explosion_falloff_oryo(damage, range, curve_pow, len) -- Player-Side Rebalances: falloff start
			damage = math.max(damage, math.min(dmg, 1))

			self:_apply_body_damage(false, hit_body, user_unit, dir, damage)
		end
	end

	self:units_to_push(units_to_push, position, range)
end

-- <Player-Side Rebalances: added new explosion functionality, can set a range at which falloff starts with range.falloff_start
function ExplosionManager:get_explosion_falloff_oryo(damage, range, curve_pow, distance)
    local falloff_start = 0
    if type(range) == "table" then
        falloff_start = range.falloff_start
        range = range.max
    end
    return math.max(damage * math.pow(math.clamp(1 - (distance - falloff_start)/ (math.max(range - falloff_start, 1)), 0, 1), curve_pow), 1)
end
-- Player-Side Rebalances>


-- <Player-Side Rebalances: backwards compatibility with new falloff_start
local units_to_push_original = ExplosionManager.units_to_push
function ExplosionManager:units_to_push(units_to_push, hit_pos, range)
    if type(range) == "table" then
        range = range.max
    end
    units_to_push_original(self, units_to_push, hit_pos, range)
end

local player_feedback_original = ExplosionManager.player_feedback
function ExplosionManager:player_feedback(position, normal, range, custom_params)
    if type(range) == "table" then
        range = range.max
    end
    player_feedback_original(self, position, normal, range, custom_params)
end

local _detect_hits_original = ExplosionManager._detect_hits
function ExplosionManager:_detect_hits(params)
    local params = deep_clone(params)
    if type(params.range) == "table" then
        params.range = params.range.max
    end
    return _detect_hits_original(self, params)
end
-- Player-Side Rebalances>