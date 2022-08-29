function CopDamage:add_crit_chance_oryo(attack_data)
	local add_crit = 0

	if attack_data.is_fire_dot_damage then -- Player-Side Rebalances: check to prevent acces violation caused by calling a method from a null unit
		return add_crit
	end

	if attack_data.weapon_unit then
		local weapon_unit = self:get_unit_oryo(attack_data.weapon_unit)

		if weapon_unit and weapon_unit:base() and weapon_unit:base()._ammo_data and weapon_unit:base()._ammo_data.crit_chance then
			add_crit = add_crit + weapon_unit:base()._ammo_data.crit_chance
		end
	end

	return add_crit
end

function CopDamage:get_unit_oryo(_unit)
	local data_type = type(_unit)
	local unit = nil

	if data_type == 'number' then
		local peer = managers.network:session():peer(_unit)
		unit = peer:unit()
	else
		unit = _unit
	end

	return unit
end

-- <Player-Side Rebalances
local damage_fire_original = CopDamage.damage_fire
function CopDamage:damage_fire(attack_data)

	local flammable = nil
	local char_tweak = tweak_data.character[self._unit:base()._tweak_table]
	flammable = char_tweak.flammable == nil and true or char_tweak.flammable

	if flammable then
		attack_data.fire_dot_data = attack_data.fire_dot_data or {
			dot_trigger_max_distance = 3000,
			dot_trigger_chance = 100,
			dot_length = 0,
			dot_damage = 0
		}
	end

	return damage_fire_original(self, attack_data)
end
-- Player-Side Rebalances>

-- <Player-Side Rebalances
local damage_dot_original = CopDamage.damage_dot
function CopDamage:damage_dot(attack_data)
	
	if attack_data.attacker_unit == managers.player:player_unit() and attack_data.dot_can_crit and not attack_data.critical_hit then
		local critical_hit, crit_damage = self:roll_critical_hit(attack_data, attack_data.damage)
		if critical_hit then
			attack_data.damage = crit_damage
			attack_data.critical_hit = true
		else
			attack_data.critical_hit = false
		end
	end

	if attack_data.variant == "fire" then
		attack_data.fire_dot_data = {}
		attack_data.fire_dot_data.start_dot_dance_antimation = true
	end

	local result = damage_dot_original(self, attack_data)

	local is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)
	if result and result.type == "death" and not is_civilian and managers.player:has_category_upgrade("temporary", "overkill_damage_multiplier") and attack_data.attacker_unit == managers.player:player_unit() and alive(attack_data.weapon_unit) and not attack_data.weapon_unit:base().thrower_unit and attack_data.weapon_unit:base().is_category and attack_data.weapon_unit:base():is_category("shotgun", "saw") then
		managers.player:activate_temporary_upgrade("temporary", "overkill_damage_multiplier")
	end

	return result
end
-- Player-Side Rebalances>

-- <Player-Side Rebalances
local damage_bullet_original = CopDamage.damage_bullet
function CopDamage:damage_bullet(attack_data)

	if bullet_class == "FireBulletBase" or bullet_class == "FlameBulletBase" then
		attack_data.fire_dot_data = {}
		attack_data.fire_dot_data.start_dot_dance_antimation = true
	end

	local result = damage_bullet_original(self, attack_data)

	local bullet_class = attack_data.weapon_unit:base()._ammo_data and attack_data.weapon_unit:base()._ammo_data.bullet_class
	if bullet_class == "FireBulletBase" or bullet_class == "FlameBulletBase" then
		result_type = "fire_hurt"
		result = {
			type = result_type,
			variant = attack_data.variant
		}
	end

	return result
end
-- Player-Side Rebalances>

function CopDamage:roll_critical_hit(attack_data, damage)
	damage = damage or attack_data.damage

	if not self:can_be_critical(attack_data) then
		return false, damage
	end
	
	local critical_hits = self._char_tweak.critical_hits or {}
	local critical_hit = false
	local critical_value = CopDamage:add_crit_chance_oryo(attack_data) + (critical_hits.base_chance or 0) + managers.player:critical_hit_chance() * (critical_hits.player_chance_multiplier or 1)

	if critical_value > 0 then
		local critical_roll = math.rand(1)
		critical_hit = critical_roll < critical_value
	end

	if critical_hit then
		local critical_damage_mul = critical_hits.damage_mul or self._char_tweak.headshot_dmg_mul

		if critical_damage_mul then
			damage = damage * critical_damage_mul
		else
			damage = self._health * 10
		end
	end

	return critical_hit, damage
end