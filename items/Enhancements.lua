local ghost = {
	type = 'Enhancement',
	order = 1,
	key = 'ghost',
	atlas = 'showdown_enhancements',
	pos = coordinate(1, 7),
	config = {extra = {x_mult = 1.25, x_chips = 1.25, shatter_chance = 8}},
	loc_vars = function(self, info_queue, card)
		if card then
			return {vars = {card.ability.extra.x_mult, card.ability.extra.x_chips, card.ability.extra.shatter_chance, G.GAME.probabilities.normal}}
		end
		return {vars = {self.config.extra.x_mult, self.config.extra.x_chips, self.config.extra.shatter_chance, G.GAME.probabilities.normal}}
	end,
	calculate = function(self, card, context)
		if context.post_joker or (context.main_scoring and context.cardarea == G.play) then
			return {
				x_mult = card.ability.extra.x_mult,
				x_chips = card.ability.extra.x_chips,
				card = card
			}
		elseif
			context.destroy_card
			and context.cardarea == G.play
			and context.destroy_card == card
			and not card.debuff
			and SMODS.pseudorandom_probability(card, 'ghost', 1, card.ability.extra.shatter_chance)
		then
			return { remove = not SMODS.is_eternal(card) }
		end
	end
}

local holy = {
	type = 'Enhancement',
	order = 2,
	key = 'holy',
	atlas = 'showdown_enhancements',
	pos = coordinate(2, 7),
	config = {extra = {x_mult = 1, x_mult_gain = 0.05}},
	loc_vars = function(self, info_queue, card)
		if card then
			return {vars = {card.ability.extra.x_mult, card.ability.extra.x_mult_gain}}
		end
		return {vars = {self.config.extra.x_mult, self.config.extra.x_mult_gain}}
	end,
	calculate = function(self, card, context)
		if context.post_joker or (context.main_scoring and context.cardarea == G.play) then
			card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_mult_gain
			return {
				x_mult = card.ability.extra.x_mult
			}
		end
	end
}

local cut = {
	type = 'Enhancement',
	order = 3,
	key = 'cut',
	atlas = 'showdown_enhancements',
	pos = coordinate(3, 7),
	config = {extra = {x_mult = 2.5, chips = 100}},
	loc_vars = function(self, info_queue, card)
		if card then
			return {vars = {card.ability.extra.x_mult, card.ability.extra.chips}}
		end
		return {vars = {self.config.extra.x_mult, self.config.extra.chips}}
	end,
	calculate = function(self, card, context)
		if context.post_joker or (context.main_scoring and context.cardarea == G.play) then
			return {
				x_mult = card.ability.extra.x_mult,
				chips = -card.ability.extra.chips
			}
		end
	end
}

local chipped = {
	type = 'Enhancement',
	order = 4,
	key = 'chipped',
	atlas = 'showdown_enhancements',
	pos = coordinate(4, 7),
	calculate = function(self, card, context)
		if context.main_scoring and context.cardarea == "unscored" then
			G.E_MANAGER:add_event(Event({
			trigger = "before",
			delay = 0.0,
			func = function()
				local _card = SMODS.create_card({set = 'Consumeables', area = G.consumeables, edition = {negative = true}})
				_card:add_to_deck()
				G.consumeables:emplace(_card)
				return true
			end,
			}))
		elseif
			context.destroy_card
			and context.cardarea == G.play
			and context.destroy_card == card
			and not card.debuff
		then
			return { remove = not SMODS.is_eternal(card) }
		end
	end
}

-- More Fluff

local frozen = {
	type = 'Enhancement',
	order = 1000,
	key = 'frozen',
	atlas = 'showdown_enhancementsMoreFluff',
	pos = coordinate(1, 7),
	config = {extra = {x_mult = 2, x_chips = 2}},
	loc_vars = function(self, info_queue, card)
		if card then
			return {vars = {card.ability.extra.x_mult, card.ability.extra.x_chips}}
		end
		return {vars = {self.config.extra.x_mult, self.config.extra.x_chips}}
	end,
	calculate = function(self, card, context)
		if context.post_joker or (context.main_scoring and context.cardarea == G.play) then
			return {
				x_mult = card.ability.extra.x_mult,
				x_chips = card.ability.extra.x_chips,
				card = card
			}
		elseif
			context.destroy_card
			and context.cardarea == G.play
			and context.destroy_card == card
			and not card.debuff
		then
			return { remove = true }
		end
	end
}

local cursed = {
	type = 'Enhancement',
	order = 1001,
	key = 'cursed',
	atlas = 'showdown_enhancementsMoreFluff',
	pos = coordinate(2, 7),
	config = {extra = {x_chips = 1, x_chips_gain = 0.05}},
	loc_vars = function(self, info_queue, card)
		if card then
			return {vars = {card.ability.extra.x_chips, card.ability.extra.x_chips_gain}}
		end
		return {vars = {self.config.extra.x_chips, self.config.extra.x_chips_gain}}
	end,
	calculate = function(self, card, context)
		if context.post_joker or (context.main_scoring and context.cardarea == G.play) then
			card.ability.extra.x_chips = card.ability.extra.x_chips + card.ability.extra.x_chips_gain
			return {
				x_chips = card.ability.extra.x_chips
			}
		end
	end
}

local taped = {
	type = 'Enhancement',
	order = 1002,
	key = 'taped',
	atlas = 'showdown_enhancementsMoreFluff',
	pos = coordinate(3, 7),
	config = {extra = {chips_gain_percent = 5}},
	loc_vars = function(self, info_queue, card)
		if card then
			return {vars = {card.ability.extra.chips_gain_percent}}
		end
		return {vars = {self.config.extra.chips_gain_percent}}
	end,
	calculate = function(self, card, context)
		if context.post_joker or (context.main_scoring and context.cardarea == G.play) then
			return {
				chips = (mult or 0) * 0.01 * card.ability.extra.chips_gain_percent
			}
		end
	end
}

return {
	enabled = Showdown.config["Enhancements"],
	list = function ()
		local list = {
			ghost,
			holy,
			cut,
			chipped,
		}
		if (SMODS.Mods["MoreFluff"] or {}).can_load and Showdown.config["CrossMod"]["MoreFluff"] then
			table.insert(list, frozen)
			table.insert(list, cursed)
			table.insert(list, taped)
		end
		return list
	end,
	atlases = {
		{key = 'showdown_enhancements', path = 'Enhancements.png', px = 71, py = 95},
		{key = 'showdown_enhancementsMoreFluff', path = 'CrossMod/MoreFluff/Enhancements.png', px = 71, py = 95},
	},
	exec = function()
		local Centergenerate_uiRef = SMODS.Center.generate_ui
		function SMODS.Center.generate_ui(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
			if specific_vars and not specific_vars.debuffed then
				if specific_vars.act_as then
					localize{type = 'other', key = 'act_as', nodes = desc_nodes, vars = {specific_vars.act_as}}
				end
				if specific_vars.default_wild then
					localize{type = 'other', key = 'default_wild', nodes = desc_nodes, vars = {}}
				end
			end
			Centergenerate_uiRef(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
		end
	end
}