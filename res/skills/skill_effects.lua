local effect = {}
-- -------------------------------
-- Referenced Data
-- -------------------------------
local data = require("main.data")
local skill_data = require("res.skills.skills")
-- -------------------------------
-- Other Functions
-- -------------------------------
local function done_dead(target_team,target_id)
	if data.team[target_team][target_id].hp <= 0 then
		data.team[target_team][target_id].hp = 0
	end
	return data.team[target_team][target_id].hp <= 0
end

local function check_max_hp(target_team,target_id)
	if data.team[target_team][target_id].hp > data.team[target_team][target_id].hp_max then
		data.team[target_team][target_id].hp = data.team[target_team][target_id].hp_max
	end
end
-- -------------------------------
-- Effect Functions
-- -------------------------------
effect.take_damage = function(team_name, actor_id, target_id, target_team, skill_name)
	local e_type = "damage"
	local value = 0
	local is_hit = true
	local is_dead = false

	local actor = data.team[team_name][actor_id]
	local target_data = data.team[target_team][target_id]
	local skill = skill_data[skill_name]

	value = (actor.atk * (skill.power or 1)) - (target_data.def or 0)

	if value < 0 then
		value = 0
	end

	-- 対象のhpを更新
	data.team[target_team][target_id].hp = target_data.hp - value

	is_dead = done_dead(target_team,target_id)

	return e_type, value, is_hit, is_dead
end

local HEAL_LV1 = 48

effect.heal_hp = function(team_name, actor_id, target_id, target_team, skill_name)
	local e_type = "heal"
	local value = 0
	local is_hit = false
	local is_dead = false

	-- local actor = data.team[team_name][actor_id]
	local target_data = data.team[target_team][target_id]
	-- local skill = skill_data[skill_name]

	value = HEAL_LV1 + math.random(0, 10)

	if data.team[target_team][target_id].hp > 0 then
		data.team[target_team][target_id].hp = target_data.hp + value
		is_hit = true
	end

	if data.team[target_team][target_id].hp >= target_data.hp_max then
		data.team[target_team][target_id].hp = target_data.hp_max
	end

	check_max_hp(target_team,target_id)
	is_dead = done_dead(target_team,target_id)

	return e_type, value, is_hit, is_dead
end

return effect
