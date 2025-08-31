local data = {}

data.heroes = {
	{name = "hero1", hp = 200, hp_max = 200, atk = 5, def = 10, spd =1, skills = {"attack", "fireball", "heal"}
	},
	{name = "hero2", hp = 1, hp_max = 20, atk = 5, def = 1, spd =1, skills = {"attack"}
	},
	{name = "hero3", hp = 5, hp_max = 20, atk = 500, def = 1, spd =1, skills = {"attack", "fireball"}
	},
}

data.enemy_group_num = 1

-- Temp team data for battle
data.team = {hero = {},enemy = {}}

data.config = {}
data.config.lang = "en"

return data