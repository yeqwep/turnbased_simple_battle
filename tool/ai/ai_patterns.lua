local ai = {}

ai["random"] = function(team_name, team, prop)
	local id = math.random(1,#prop.skills)
	local skill_key = prop.skills[id]
	return skill_key
end

return ai