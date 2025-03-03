local latch = {
	type = 'Blind',
	order = 1,
	key = "latch",
	name = "The Latch",
	atlas = "showdown_blinds",
	pos = { x = 0, y = 0 },
	no_collection = true,
	boss_colour = G.C.GREY,
	boss = { min = 1 },
	mult = 3,
	defeat = function(self)
		local lock = find_joker('4_locks')
		if next(lock) then
			local lockJ = lock[next(lock)]
			if not lockJ.ability.extra.locks[4] then
				lockJ.ability.extra.locks[4] = true
				forced_message(localize('k_unlocked'), lockJ, G.C.YELLOW, true)
			end
		end
	end,
	in_pool = function(self, args)
		local lock = find_joker('4_locks')
		return next(lock) and not lock[next(lock)].ability.extra.locks[4]
	end
}

local patient = {
	type = 'Blind',
	order = 2,
	key = "patient",
	name = "The Patient",
	atlas = "showdown_blinds",
	pos = { x = 0, y = 1 },
	boss_colour = G.C.BLUE,
	boss = { min = 2 },
	mult = 2,
}

local wasteful = {
	type = 'Blind',
	order = 3,
	key = "wasteful",
	name = "The Wasteful",
	atlas = "showdown_blinds",
	pos = { x = 0, y = 3 },
	boss_colour = G.C.RED,
	boss = { min = 2 },
	mult = 2,
	debuff_hand = function(self, cards, hand, handname, check)
		return G.GAME.current_round.discards_left > 0
	end
}

local shameful = {
	type = 'Blind',
	order = 4,
	key = "shameful",
	name = "The Shameful",
	atlas = "showdown_blinds",
	pos = { x = 0, y = 2 },
	boss_colour = G.C.YELLOW,
	boss = { min = 1 },
	mult = 2,
}

return {
	enabled = Showdown.config["Blinds"],
	list = function()
		local list = {
			patient,
			wasteful,
			--shameful,
		}
		if Showdown.config["Jokers"]["Final"] then
			table.insert(list, latch)
		end
		return list
	end,
	atlases = {
		{key = "showdown_blinds", path = "Blinds.png", px = 34, py = 34, atlas_table = "ANIMATION_ATLAS", frames = 21},
	},
	exec = function()
		function SMODS.patient_gain_score(blind) -- Thanks Bunco
			if not G.GAME.patient_scoring then G.GAME.patient_scoring = { score = blind.chips, triggers = 0 } end
			G.GAME.patient_scoring.triggers = G.GAME.patient_scoring.triggers + 1
			local final_chips = (G.GAME.patient_scoring.score / 100) * (100 + 50 * G.GAME.patient_scoring.triggers)
			local chip_mod -- iterate over ~120 ticks
			if type(blind.chips) ~= 'table' then
				chip_mod = math.ceil((G.GAME.blind.chips + final_chips) / 120)
			else
				chip_mod = ((G.GAME.blind.chips + final_chips) / 120):ceil()
			end
			local step = 0
			G.E_MANAGER:add_event(Event({trigger = 'after', blocking = true, func = function()
				blind.chips = blind.chips + G.SETTINGS.GAMESPEED * chip_mod
				if blind.chips < final_chips then
					blind.chip_text = number_format(blind.chips)
					if step % 5 == 0 then
						play_sound('chips1', 1.0 + (step * 0.005))
					end
					step = step + 1
				else
					blind.chips = final_chips
					blind.chip_text = number_format(blind.chips)
					return true
				end
			end}))
		end

		local gnb = get_new_boss
		function get_new_boss()
			for k, _ in pairs(G.P_BLINDS) do
				if not G.GAME.bosses_used[k] then
					G.GAME.bosses_used[k] = 0
				end
			end
			return gnb()
		end
	end
}