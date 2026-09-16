-- Chess Blinds

local function chess_blind(obj)
	local white_piece = {
		type = 'Blind',
		order = obj.order,
		key = 'white_'..obj.key,
		name = 'White '..obj.name,
		atlas = "showdown_blinds",
		pos = { x = 0, y = obj.order + 5 },
		boss_colour = {0.8, 0.8, 0.8, 1},
		big = { min = obj.big.min, max = obj.big.max, allow_duplicates = false },
		config = { is_chess_boss = true, is_black_chess = false },
		dollars = 4,
		mult = 1.5,
		unskippable = true,
		in_pool = function (self)
			return
				G.GAME.showdown_chess and
				not G.GAME.is_black_chess and
				(self.big.min ~= nil and self.big.min >= math.max(1, G.GAME.round_resets.ante) or true) and
				(self.big.max ~= nil and self.big.max <= math.max(1, G.GAME.round_resets.ante) or true)
		end
	}
	local black_piece = {
		type = 'Blind',
		order = obj.order + 1,
		key = 'black_'..obj.key,
		name = 'Black '..obj.name,
		atlas = "showdown_blinds",
		pos = { x = 0, y = obj.order + 6 },
		boss_colour = G.C.BLACK,
		big = { min = obj.big.min, max = obj.big.max, allow_duplicates = false },
		config = { is_chess_boss = true, is_black_chess = true },
		dollars = 4,
		mult = 1.5,
		unskippable = true,
		in_pool = function (self)
			return
				G.GAME.showdown_chess and
				G.GAME.is_black_chess and
				(self.big.min ~= nil and self.big.min >= math.max(1, G.GAME.round_resets.ante) or true) and
				(self.big.max ~= nil and self.big.max <= math.max(1, G.GAME.round_resets.ante) or true)
		end
	}
	return white_piece, black_piece
end

local white_pawn, black_pawn = chess_blind{
	order = 1,
	key = "pawn",
	name = "Pawn",
	big = { min = 1 },
}
white_pawn.modify_hand = function(self, cards, poker_hands, text, mult, hand_chips)
	local eval = evaluate_poker_hand(cards)
	if G.GAME.chess_blinds_hand and next(eval[G.GAME.chess_blinds_hand]) then
		return G.GAME.showdown_chess_boosted and mult * 0.25 or mult * 0.5, hand_chips, true
	end
	return mult, hand_chips, false
end
white_pawn.loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME.showdown_chess_boosted and 0.25 or 0.5, G.GAME.chess_blinds_hand or ('['..localize('k_poker_hand')..']')} } end
white_pawn.collection_loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME.showdown_chess_boosted and 0.25 or 0.5, G.GAME.chess_blinds_hand or 'High Card'} } end
black_pawn.modify_hand = function(self, cards, poker_hands, text, mult, hand_chips)
	local eval = evaluate_poker_hand(cards)
	if G.GAME.chess_blinds_hand and next(eval[G.GAME.chess_blinds_hand]) then
		return G.GAME.showdown_chess_boosted and mult * 4 or mult * 2, hand_chips, true
	end
	return mult, hand_chips, false
end
black_pawn.loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME.showdown_chess_boosted and 4 or 2, G.GAME.chess_blinds_hand or ('['..localize('k_poker_hand')..']')} } end
black_pawn.collection_loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME.showdown_chess_boosted and 4 or 2, G.GAME.chess_blinds_hand or 'High Card'} } end

local white_rook, black_rook = chess_blind{
	order = 3,
	key = "rook",
	name = "Rook",
	big = { min = 1 },
}
white_rook.modify_hand = function(self, cards, poker_hands, text, mult, hand_chips)
	local hasSuit = false
	for _, card in ipairs(cards) do
		if not hasSuit then
			hasSuit = card:is_suit(G.GAME.chess_blinds_suit)
		end
	end
	if hasSuit then
		return G.GAME.showdown_chess_boosted and mult * 0.25 or mult * 0.5, hand_chips, true
	end
	return mult, hand_chips, false
end
white_rook.loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME.showdown_chess_boosted and 0.25 or 0.5, G.GAME.chess_blinds_suit or ('['..localize('k_suit')..']')} } end
white_rook.collection_loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME.showdown_chess_boosted and 0.25 or 0.5, G.GAME.chess_blinds_suit or 'Spades'} } end
black_rook.modify_hand = function(self, cards, poker_hands, text, mult, hand_chips)
	local hasSuit = false
	for _, card in ipairs(cards) do
		if not hasSuit then
			hasSuit = card:is_suit(G.GAME.chess_blinds_suit)
		end
	end
	if hasSuit then
		return G.GAME.showdown_chess_boosted and mult * 4 or mult * 2, hand_chips, true
	end
	return mult, hand_chips, false
end
black_rook.loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME.showdown_chess_boosted and 4 or 2, G.GAME.chess_blinds_suit or ('['..localize('k_suit')..']')} } end
black_rook.collection_loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME.showdown_chess_boosted and 4 or 2, G.GAME.chess_blinds_suit or 'Spades'} } end

local white_knight, black_knight = chess_blind{
	order = 5,
	key = "knight",
	name = "Knight",
	big = { min = 1 },
}
local function get_chess_rank(i) return G and G.GAME and G.GAME.chess_blinds_ranks and SMODS.Ranks[G.GAME.chess_blinds_ranks[i]] end
white_knight.modify_hand = function(self, cards, poker_hands, text, mult, hand_chips)
	local hasRank = false
	for i, card in ipairs(cards) do
		if not hasRank then
			hasRank = findInTable(card.base.value, G.GAME.chess_blinds_ranks) ~= -1
		end
	end
	if hasRank then
		return G.GAME.showdown_chess_boosted and mult * 0.25 or mult * 0.5, hand_chips, true
	end
	return mult, hand_chips, false
end
white_knight.loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME.showdown_chess_boosted and 0.25 or 0.5, G.GAME and G.GAME.chess_blinds_ranks and localize(get_chess_rank(1).key, 'ranks') or ('['..localize('k_rank')..']'), G.GAME and G.GAME.chess_blinds_ranks and localize(get_chess_rank(2).key, 'ranks') or ('['..localize('k_rank')..']'), G.GAME and G.GAME.chess_blinds_ranks and localize(get_chess_rank(3).key, 'ranks') or ('['..localize('k_rank')..']')} } end
white_knight.collection_loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME.showdown_chess_boosted and 0.25 or 0.5, G.GAME and G.GAME.chess_blinds_ranks and localize(get_chess_rank(1).key, 'ranks') or 'King', G.GAME and G.GAME.chess_blinds_ranks and localize(get_chess_rank(2).key, 'ranks') or '7', G.GAME and G.GAME.chess_blinds_ranks and localize(get_chess_rank(3).key, 'ranks') or 'Ace'} } end
black_knight.modify_hand = function(self, cards, poker_hands, text, mult, hand_chips)
	local hasRank = false
	for i, card in ipairs(cards) do
		if not hasRank then
			hasRank = findInTable(card.base.value, G.GAME.chess_blinds_ranks) ~= -1
		end
	end
	if hasRank then
		return G.GAME.showdown_chess_boosted and mult * 4 or mult * 2, hand_chips, true
	end
	return mult, hand_chips, false
end
black_knight.loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME.showdown_chess_boosted and 4 or 2, G.GAME and G.GAME.chess_blinds_ranks and localize(get_chess_rank(1).key, 'ranks') or ('['..localize('k_rank')..']'), G.GAME and G.GAME.chess_blinds_ranks and localize(get_chess_rank(2).key, 'ranks') or ('['..localize('k_rank')..']'), G.GAME and G.GAME.chess_blinds_ranks and localize(get_chess_rank(3).key, 'ranks') or ('['..localize('k_rank')..']')} } end
black_knight.collection_loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME.showdown_chess_boosted and 4 or 2, G.GAME and G.GAME.chess_blinds_ranks and localize(get_chess_rank(1).key, 'ranks') or 'King', G.GAME and G.GAME.chess_blinds_ranks and localize(get_chess_rank(2).key, 'ranks') or '7', G.GAME and G.GAME.chess_blinds_ranks and localize(get_chess_rank(3).key, 'ranks') or 'Ace'} } end

local white_bishop, black_bishop = chess_blind{
	order = 7,
	key = "bishop",
	name = "Bishop",
	big = { min = 1 },
}
white_bishop.set_blind = function(self)
	G.GAME.modifiers.discard_cost = (G.GAME.modifiers.discard_cost or 0) + (G.GAME.showdown_chess_boosted and 3 or 2)
	if G.GAME.modifiers.discard_cost == 0 then G.GAME.modifiers.discard_cost = nil end
end
white_bishop.disable = function(self)
	G.GAME.modifiers.discard_cost = (G.GAME.modifiers.discard_cost or 0) - (G.GAME.showdown_chess_boosted and 3 or 2)
	if G.GAME.modifiers.discard_cost == 0 then G.GAME.modifiers.discard_cost = nil end
end
white_bishop.defeat = function(self)
	G.GAME.modifiers.discard_cost = (G.GAME.modifiers.discard_cost or 0) - (G.GAME.showdown_chess_boosted and 3 or 2)
	if G.GAME.modifiers.discard_cost == 0 then G.GAME.modifiers.discard_cost = nil end
end
white_bishop.loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME.showdown_chess_boosted and 3 or 2} } end
white_bishop.collection_loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME.showdown_chess_boosted and 3 or 2} } end
black_bishop.set_blind = function(self)
	G.GAME.modifiers.discard_cost = (G.GAME.modifiers.discard_cost or 0) - (G.GAME.showdown_chess_boosted and 3 or 2)
	if G.GAME.modifiers.discard_cost == 0 then G.GAME.modifiers.discard_cost = nil end
end
black_bishop.disable = function(self)
	G.GAME.modifiers.discard_cost = (G.GAME.modifiers.discard_cost or 0) + (G.GAME.showdown_chess_boosted and 3 or 2)
	if G.GAME.modifiers.discard_cost == 0 then G.GAME.modifiers.discard_cost = nil end
end
black_bishop.defeat = function(self)
	G.GAME.modifiers.discard_cost = (G.GAME.modifiers.discard_cost or 0) + (G.GAME.showdown_chess_boosted and 3 or 2)
	if G.GAME.modifiers.discard_cost == 0 then G.GAME.modifiers.discard_cost = nil end
end
black_bishop.loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME.showdown_chess_boosted and 3 or 2} } end
black_bishop.collection_loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME.showdown_chess_boosted and 3 or 2} } end

local white_queen, black_queen = chess_blind{
	order = 9,
	key = "queen",
	name = "Queen",
	big = { min = 4 },
}
white_queen.debuff_hand = function(self, cards, hand, handname, check)
	local hands = {}
	for k, _ in pairs(G.GAME.hands) do
		table.insert(hands, k)
	end
	table.sort(hands, function(a, b)
		return G.GAME.hands[a].played > G.GAME.hands[b].played
	end)
	return handname == hands[1] or (G.GAME.showdown_chess_boosted and handname == hands[2])
end
white_queen.loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { key = 'bl_showdown_white_queen'..(G.GAME.showdown_chess_boosted and '_boosted' or '') } end
white_queen.collection_loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { key = 'bl_showdown_white_queen'..(G.GAME.showdown_chess_boosted and '_boosted' or '') } end
black_queen.calculate = function(self, blind, context)
	if not G.GAME.blind.disabled and context.before then
		local most_played = true
		local play_more_than = (G.GAME.hands[context.scoring_name].played or 0)
		for k, v in pairs(G.GAME.hands) do
			if k ~= context.scoring_name and v.played >= play_more_than and SMODS.is_poker_hand_visible(k) then
				most_played = false
			end
		end
		if most_played then
			card_eval_status_text(blind, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex')})
			update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(context.scoring_name, 'poker_hands'),chips = G.GAME.hands[context.scoring_name].chips, mult = G.GAME.hands[context.scoring_name].mult, level=G.GAME.hands[context.scoring_name].level})
			level_up_hand(blind, context.scoring_name, nil, G.GAME.showdown_chess_boosted and 2 or 1)
			update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
		end
	end
end
black_queen.loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME.showdown_chess_boosted and 2 or 1} } end
black_queen.collection_loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME.showdown_chess_boosted and 2 or 1} } end

local white_king, black_king = chess_blind{
	order = 11,
	key = "king",
	name = "King",
	big = { min = 4 },
}
white_king.set_blind = function(self)
	G.hand:change_size(-(G.GAME.showdown_chess_boosted and 3 or 2))
end
white_king.disable = function(self)
	G.hand:change_size(G.GAME.showdown_chess_boosted and 3 or 2)
end
white_king.defeat = function(self)
	G.hand:change_size(G.GAME.showdown_chess_boosted and 3 or 2)
end
white_king.loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME.showdown_chess_boosted and 3 or 2} } end
white_king.collection_loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME.showdown_chess_boosted and 3 or 2} } end
black_king.set_blind = function(self)
	G.hand:change_size(G.GAME.showdown_chess_boosted and 3 or 2)
end
black_king.disable = function(self)
	G.hand:change_size(-(G.GAME.showdown_chess_boosted and 3 or 2))
end
black_king.defeat = function(self)
	G.hand:change_size(-(G.GAME.showdown_chess_boosted and 3 or 2))
end
black_king.loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME.showdown_chess_boosted and 3 or 2} } end
black_king.collection_loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME.showdown_chess_boosted and 3 or 2} } end

local white_unicorn, black_unicorn = chess_blind{
	order = 13,
	key = "unicorn",
	name = "Unicorn",
	big = { min = 2 },
}
white_unicorn.calculate = function(self, blind, context)
	if not G.GAME.blind.disabled and context.before then
		for _, card in pairs(context.scoring_hand) do
			if SMODS.pseudorandom_probability(blind, 'black_unicorn', (G.GAME.showdown_chess_boosted and 2 or 1), 3) then
				card:set_debuff(true)
			end
		end
	end
end
white_unicorn.loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {(G.GAME.showdown_chess_boosted and 2 or 1) * G.GAME.probabilities.normal} } end
white_unicorn.collection_loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {(G.GAME.showdown_chess_boosted and 2 or 1) * G.GAME.probabilities.normal} } end
black_unicorn.calculate = function(self, blind, context)
	if not G.GAME.blind.disabled and context.repetition and SMODS.pseudorandom_probability(blind, 'black_unicorn', (G.GAME.showdown_chess_boosted and 2 or 1), 3) then
		return {
			repetitions = 1,
		}
	end
end
black_unicorn.loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {(G.GAME.showdown_chess_boosted and 2 or 1) * G.GAME.probabilities.normal} } end
black_unicorn.collection_loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {(G.GAME.showdown_chess_boosted and 2 or 1) * G.GAME.probabilities.normal} } end

local white_dragon, black_dragon = chess_blind{
	order = 15,
	key = "dragon",
	name = "Dragon",
	big = { min = 2 },
}
white_dragon.set_blind = function(self)
	ease_discard(-(G.GAME.showdown_chess_boosted and 2 or 1))
	ease_hands_played(-(G.GAME.showdown_chess_boosted and 2 or 1))
end
white_dragon.loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME.showdown_chess_boosted and 2 or 1} } end
white_dragon.collection_loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME.showdown_chess_boosted and 2 or 1} } end
black_dragon.set_blind = function(self)
	ease_discard(G.GAME.showdown_chess_boosted and 2 or 1)
	ease_hands_played(G.GAME.showdown_chess_boosted and 2 or 1)
end
black_dragon.loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME.showdown_chess_boosted and 2 or 1} } end
black_dragon.collection_loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME.showdown_chess_boosted and 2 or 1} } end

Showdown.princess_blind_rarity_blacklist = { 'showdown_final', 'cry_exotic', 'cry_cursed' }

local white_princess, black_princess = chess_blind{
	order = 17,
	key = "princess",
	name = "Princess",
	big = { min = 4 },
}
white_princess.defeat = function(self)
	local eligible_jokers = {}
	for _, joker in ipairs(G.jokers.cards) do
		if joker:is_rarity(G.GAME.princess_blind_rarity) then table.insert(eligible_jokers, joker) end
	end
	if #eligible_jokers > 0 then
		local destroyed_joker = pseudorandom_element(eligible_jokers, pseudoseed('white_princess'))
		if SMODS.is_eternal(destroyed_joker) then
			G.E_MANAGER:add_event(Event({func = function()
				destroyed_joker:juice_up(0.4, 0.4)
				play_sound('cancel', 0.8+(0.9 + 0.2*math.random())*0.2)
			return true end }))
		elseif not destroyed_joker.getting_sliced then
			destroyed_joker.getting_sliced = true
			G.GAME.joker_buffer = G.GAME.joker_buffer - 1
			G.E_MANAGER:add_event(Event({func = function()
				G.GAME.joker_buffer = 0
				destroyed_joker:start_dissolve({HEX("57ecab")}, nil, 1.6)
			return true end }))
		end
	end
end
white_princess.loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME and G.GAME.princess_blind_rarity and localize('k_'..G.GAME.princess_blind_rarity:lower()) or ('['..localize('k_rarity')..']')} } end
white_princess.collection_loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME and G.GAME.princess_blind_rarity and localize('k_'..G.GAME.princess_blind_rarity:lower()) or localize('k_uncommon')} } end
black_princess.defeat = function(self)
	local jokers_to_create = math.min(1, G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer))
	G.GAME.joker_buffer = G.GAME.joker_buffer + jokers_to_create
	G.E_MANAGER:add_event(Event({
		func = function()
			if jokers_to_create > 0 then
				local card = create_card('Joker', G.jokers, nil, G.GAME.princess_blind_rarity, nil, nil, nil, 'black_princess')
				card:add_to_deck()
				G.jokers:emplace(card)
				card:start_materialize()
				G.GAME.joker_buffer = 0
			end
			return true
		end}))
	return nil, true
end
black_princess.loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME and G.GAME.princess_blind_rarity and localize('k_'..G.GAME.princess_blind_rarity:lower()) or ('['..localize('k_rarity')..']')} } end
black_princess.collection_loc_vars = function(self, cards, poker_hands, text, mult, hand_chips) return { vars = {G.GAME and G.GAME.princess_blind_rarity and localize('k_'..G.GAME.princess_blind_rarity:lower()) or localize('k_uncommon')} } end

-- Boss Blinds

local latch = {
	type = 'Blind',
	order = 19,
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
	order = 20,
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
	order = 21,
	key = "wasteful",
	name = "The Wasteful",
	atlas = "showdown_blinds",
	pos = { x = 0, y = 3 },
	boss_colour = G.C.RED,
	boss = { min = 2 },
	mult = 2,
	debuff_hand = function(self, cards, hand, handname, check)
		self.triggered = false
		if G.GAME.current_round.discards_left > 0 then
			self.triggered = true
			return true
		end
		return false
	end
}

local shameful = {
	type = 'Blind',
	order = 22,
	key = "shameful",
	name = "The Shameful",
	atlas = "showdown_blinds",
	pos = { x = 0, y = 2 },
	boss_colour = G.C.YELLOW,
	boss = { min = 4 },
	mult = 2,
	debuff_hand = function(self, cards, hand, handname, check)
		local unenhanced = false
		for _, card in ipairs(cards) do
			unenhanced = unenhanced or card.config.center == G.P_CENTERS.c_base
		end
		self.triggered = unenhanced
		return unenhanced
	end
}

local brick = {
	type = 'Blind',
	order = 23,
	key = "brick",
	name = "The Brick",
	atlas = "showdown_blinds",
	pos = { x = 0, y = 24 },
	boss_colour = HEX('C6515B'),
	boss = { min = 2 },
	mult = 2,
	recalc_debuff = function(self, card, from_blind)
		local triggered = (card.ability.set == 'Default' or card.ability.set == 'Enhanced') and not SMODS.is_counterpart(card)
		self.triggered = triggered
		return triggered
	end,
	in_pool = function(self, args)
		local counterparts = 0
		if G.deck then
			for _, card in ipairs(G.deck.cards) do
				if SMODS.is_counterpart(card) then counterparts = counterparts + 1 end
			end
		end
		return counterparts >= 10
	end
}

local ceiling = {
	type = 'Blind',
	order = 24,
	key = "ceiling",
	name = "The Ceiling",
	atlas = "showdown_blinds",
	pos = { x = 0, y = 25 },
	boss_colour = HEX('e22fc5'),
	boss = { min = 2 },
	mult = 2,
	debuff_hand = function(self, cards, hand, handname, check)
		local ranks = get_highest_ranks_from_deck(4)
		local not_highest = true
		for _, card in ipairs(cards) do
			not_highest = not_highest and findInTable(card.base.value, ranks) ~= -1
		end
		self.triggered = not not_highest
		return not_highest
	end,
	in_pool = function(self, args)
		local ranks = {}
		if G.deck then
			for _, card in ipairs(G.deck.cards) do
				local rank = card.base.value
				if findInTable(rank, ranks) == -1 then table.insert(ranks, rank) end
			end
		end
		return #ranks >= 8
	end
}

-- Showdown Boss Blinds

local emerald_shard = {
	type = 'Blind',
	order = 25,
	key = "emerald_shard",
	name = "Emerald Shard",
	atlas = "showdown_blinds",
	pos = { x = 0, y = 26 },
	boss_colour = G.C.GREEN,
	boss = { showdown = true },
	mult = 2,
	dollars = 8,
	set_blind = function(self)
		G.GAME.emerald_shard_debuffed_cards = {}
		local not_debuffed_cards = #G.deck.cards - math.floor((#G.deck.cards / 2) + 0.5)
		for _, card in ipairs(G.deck.cards) do
			table.insert(G.GAME.emerald_shard_debuffed_cards, card)
		end
		for _ = 1, not_debuffed_cards do
			if #G.GAME.emerald_shard_debuffed_cards > 0 then
				local _card = pseudorandom_element(G.GAME.emerald_shard_debuffed_cards, pseudoseed('emerald_shard'))
				table.remove(G.GAME.emerald_shard_debuffed_cards, findInTable(_card, G.GAME.emerald_shard_debuffed_cards))
			end
		end
	end,
	recalc_debuff = function(self, card, from_blind)
		self.triggered = false
		if findInTable(card, G.GAME.emerald_shard_debuffed_cards) ~= -1 then
			self.triggered = true
			return true
		end
		return false
	end,
}

return {
	enabled = Showdown.config["Blinds"],
	list = function()
		local list = {}
		if Showdown.config["Decks"] or ((SMODS.Mods["CardSleeves"] or {}).can_load and Showdown.config["CrossMod"]["CardSleeves"]) then
			table.insert(list, white_pawn)
			table.insert(list, black_pawn)
			table.insert(list, white_rook)
			table.insert(list, black_rook)
			table.insert(list, white_knight)
			table.insert(list, black_knight)
			table.insert(list, white_bishop)
			table.insert(list, black_bishop)
			table.insert(list, white_queen)
			table.insert(list, black_queen)
			table.insert(list, white_king)
			table.insert(list, black_king)
			table.insert(list, white_unicorn)
			table.insert(list, black_unicorn)
			table.insert(list, white_dragon)
			table.insert(list, black_dragon)
			table.insert(list, white_princess)
			table.insert(list, black_princess)
		end
		if Showdown.config["Jokers"]["Final"] then
			table.insert(list, latch)
		end
		if Showdown.config["Ranks"] then
			table.insert(list, brick)
		end
		table.insert(list, patient)
		table.insert(list, wasteful)
		table.insert(list, shameful)
		table.insert(list, ceiling)
		table.insert(list, emerald_shard)
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
			local chip_mod -- iterate over ~480 ticks
			if type(blind.chips) ~= 'table' then
				chip_mod = math.ceil((G.GAME.blind.chips + final_chips) / 480)
			else
				chip_mod = ((G.GAME.blind.chips + final_chips) / 480):ceil()
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

		local G_FUNCS_evaluate_round_ref = G.FUNCS.evaluate_round
		G.FUNCS.evaluate_round = function()
			if G.GAME.patient_scoring then G.GAME.patient_scoring = nil end
			G_FUNCS_evaluate_round_ref()
		end

		function Showdown.reset_chess_blinds_targets()
			local _poker_hands = {}
			for k, v in pairs(G.GAME.hands) do
				if v.played_this_round > 0 then _poker_hands[#_poker_hands+1] = k end
			end
			if #_poker_hands then
				_poker_hands[1] = "High Card"
			end
			G.GAME.chess_blinds_hand = pseudorandom_element(_poker_hands, pseudoseed('chess_blinds_hand'))
			G.GAME.chess_blinds_suit = pseudorandom_element(get_all_suits(), pseudoseed('chess_blinds_suit'))
			G.GAME.chess_blinds_ranks = {}
			local ranks = get_all_ranks()
			for _ = 0, 2 do
				local rand_rank = pseudorandom_element(ranks, pseudoseed('chess_blinds_ranks'))
				table.remove(ranks, findInTable(rand_rank, ranks))
				table.insert(G.GAME.chess_blinds_ranks, rand_rank)
			end
			G.GAME.princess_blind_rarity_pool = {}
			for _, v in pairs(SMODS.Rarity.obj_buffer) do
				local in_pool = true
				for _, w in ipairs(Showdown.princess_blind_rarity_blacklist) do
					in_pool = in_pool and v ~= w
				end
				if in_pool then
					table.insert(G.GAME.princess_blind_rarity_pool, v)
				end
			end
			G.GAME.princess_blind_rarity = pseudorandom_element(G.GAME.showdown_chess_boosted and G.GAME.princess_blind_rarity_pool or { 'Common', 'Uncommon', 'Rare' }, pseudoseed('princess_blind_rarity'))
		end

		local SMODS_Blind_call = SMODS.Blind.__call
		function SMODS.Blind:__call(o)
			if o.big and not (o.config and o.config.is_chess_boss) then
				if o.in_pool then
					local old_in_pool = o.in_pool
					o.in_pool = function (self)
						return not G.GAME.showdown_chess and old_in_pool(self)
					end
				else
					o.in_pool = function (self)
						return not G.GAME.showdown_chess --and self.big.min >= math.max(1, G.GAME.round_resets.ante) and self.big.max <= math.max(1, G.GAME.round_resets.ante)
					end
				end
			end
			return SMODS_Blind_call(o)
		end

		SMODS.Blind:take_ownership('big', {
			in_pool = function (self)
				return not G.GAME.showdown_chess
			end
		})

		G.FUNCS.reroll_big = function(e)
			stop_use()
			G.E_MANAGER:add_event(Event({
				trigger = 'immediate',
				func = function()
				play_sound('other1')
				G.blind_select_opts.big:set_role({xy_bond = 'Weak'})
				G.blind_select_opts.big.alignment.offset.y = 20
				return true
				end
			}))
			G.E_MANAGER:add_event(Event({
			trigger = 'after',
			delay = 0.3,
			func = (function()
				local par = G.blind_select_opts.big.parent
				G.GAME.round_resets.blind_choices.Big = SMODS.get_new_blind('big')

				G.blind_select_opts.big:remove()
				G.blind_select_opts.big = UIBox{
				T = {par.T.x, 0, 0, 0, },
				definition =
					{n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
					UIBox_dyn_container({create_UIBox_blind_choice('Big')},false,get_blind_main_colour('Big'), mix_colours(G.C.BLACK, get_blind_main_colour('Big'), 0.8))
					}},
				config = {align="bmi",
							offset = {x=0,y=G.ROOM.T.y + 9},
							major = par,
							xy_bond = 'Weak'
						}
				}
				par.config.object = G.blind_select_opts.big
				par.config.object:recalculate()
				G.blind_select_opts.big.parent = par
				G.blind_select_opts.big.alignment.offset.y = 0
				
				G.E_MANAGER:add_event(Event({blocking = false, trigger = 'after', delay = 0.5,func = function()
					--G.CONTROLLER.locks.boss_reroll = nil
					return true
				end
				}))

				save_run()
				for i = 1, #G.GAME.tags do
				if G.GAME.tags[i]:apply_to_run({type = 'new_blind_choice'}) then break end
				end
				return true
			end)
			}))
		end

		if not (SMODS.Mods["Cryptid"] or {}).can_load then
			local gnb = get_new_boss
			function get_new_boss()
				for k, _ in pairs(G.P_BLINDS) do -- this is for adding bosses mid-run
					if not G.GAME.bosses_used[k] then
						G.GAME.bosses_used[k] = 0
					end
				end
				return gnb()
			end
		end
	end
}