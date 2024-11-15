function SentryGunDamage:die(attacker_unit, variant, options)
	options = options or {}
	local sequence_death = options.sequence_death or self._death_sequence_name
	local sequence_shield_death = options.sequence_shield_death or self._death_with_shield_sequence_name
	local sequence_done = options.sequence_done or "done_turret_destroyed"
	local global_event = options.global_event or "turret_destroyed"

	if self._stats_name and attacker_unit == managers.player:player_unit() then
		local data = {
			name = self._stats_name,
			stats_name = self._stats_name,
			variant = variant
		}

		managers.statistics:killed(data)
	end

	if self._is_car then
		local ja22_01_data = tweak_data.achievement.ja22_01
		local total_health = self._HEALTH_INIT + self._SHIELD_HEALTH_INIT * (1 + self._repair_counter)

		if ja22_01_data.percentage_dmg < self._local_car_damage / total_health then
			print("JA22_01: Sentrygun Achievement Awarded!", "Damage: " .. math.truncate(self._local_car_damage, 1), "Percentage: " .. math.truncate(self._local_car_damage / total_health * 100, 1) .. "%")
			managers.achievment:award(ja22_01_data.award)
		else
			print("JA22_01: Not enough damage", "Damage: " .. math.truncate(self._local_car_damage, 1), "Percentage: " .. math.truncate(self._local_car_damage / total_health * 100, 1) .. "%")
		end
	else
		print("JA22_01: Sentrygun not a car")
	end
	
	-- <oryo
	local weapon = self._unit:weapon()
	weapon._ammo_total = 0
	-- oryo>
	
	self._health = 0
	self._dead = true

	self._unit:weapon():remove_fire_mode_interaction()
	self._unit:set_slot(26)
	self._unit:brain():set_active(false)
	self._unit:movement():set_active(false)
	self._unit:movement():on_death()

	if managers.groupai:state():criminal_record(self._unit:key()) then
		managers.groupai:state():on_criminal_neutralized(self._unit)
	end

	self._unit:base():on_death()

	if self._breakdown_snd_event then
		self._unit:sound_source():post_event(self._breakdown_snd_event)
	end
	
	self._shield_smoke_level = 0

	if self._unit:base():has_shield() and sequence_shield_death then
		self._unit:damage():run_sequence_simple(sequence_shield_death)
	elseif sequence_death then
		self._unit:damage():run_sequence_simple(sequence_death)
	end

	if managers.groupai:state():is_unit_turret(self._unit) then
		if global_event then
			managers.mission:call_global_event("turret_destroyed")
		end

		if self._parent_unit ~= nil and self._parent_unit:damage():has_sequence(sequence_done) then
			self._parent_unit:damage():run_sequence_simple(sequence_done)
		end

		self._unit:contour():remove("mark_unit_friendly", true)
		self._unit:contour():remove("mark_unit_dangerous", true)
		managers.groupai:state():unregister_turret(self._unit)
	elseif alive(self._unit) then
		self._turret_destroyed_snd = self._unit:sound_source():post_event("wp_sentrygun_broken_loop")
	end

	--[[ self._unit:event_listener():call("on_death") ]]
end

function SentryGunDamage:set_shield_health(shield_health_amount)
	self._shield_health = shield_health_amount
end