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
	
	--
	local weapon = self._unit:weapon()
	weapon._ammo_total = 0
	--
	
	self._health = 0
	self._dead = true

	self._unit:weapon():remove_fire_mode_interaction()
	self._unit:set_slot(26)
	self._unit:brain():set_active(false)
	self._unit:movement():set_active(false)
	self._unit:movement():on_death()
	managers.groupai:state():on_criminal_neutralized(self._unit)
	self._unit:base():on_death()
	self._unit:sound_source():post_event(self._breakdown_snd_event)
	
	self._shield_smoke_level = 0

	if self._unit:base():has_shield() and sequence_shield_death then
		self._unit:damage():run_sequence_simple(sequence_shield_death)
	elseif sequence_death then
		self._unit:damage():run_sequence_simple(sequence_death)
	end

	local turret_units = managers.groupai:state():turrets()

	if turret_units and table.contains(turret_units, self._unit) then
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
end

function SentryGunDamage:set_shield_health(shield_health_amount)
	self._shield_health = shield_health_amount
end