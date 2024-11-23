
local cooldown = 30
local spawn_groups_per_cooldown = 30

function GroupAIStateBesiege:upd_group_spawn_cooldown_oryo()

	self.spawn_groups = self.spawn_groups and self.spawn_groups + 1 or 1
	if self.spawn_groups >= spawn_groups_per_cooldown then
		self.group_spawn_cooldown_start = TimerManager:game():time()
		self.spawn_groups = 0
	end

end

function GroupAIStateBesiege:group_spawn_on_cooldown_oryo()

	if not self.group_spawn_cooldown_start then
		return false
	end

	local t = TimerManager:game():time()
	if t - self.group_spawn_cooldown_start > cooldown then
		return false
	end

	return true
end

local _perform_group_spawning_original = GroupAIStateBesiege._perform_group_spawning
function GroupAIStateBesiege:_perform_group_spawning(spawn_task, force, use_last)

	if self:group_spawn_on_cooldown_oryo() and not force then
		return
	end
	self:upd_group_spawn_cooldown_oryo()

	local my_table = {"Success"}
	PrintTable(my_table)

	_perform_group_spawning_original(self, spawn_task, force, use_last)
end