---Get card texture coordinates on the atlas
---@param position integer
---@param width integer|nil
---@return table
function coordinate(position, width)
    if width == nil then width = 10 end
    return {x = (position-1) % width, y = math.floor((position-1) / width)}
end

function modCompatibility(modName, filePath)
	sendInfoMessage("Mod Compatibility: "..modName.." is loaded!", "Showdown")
	filesystem.load(SMODS.current_mod.path..filePath)()
end

function event(config)
    local e = Event(config)
    G.E_MANAGER:add_event(e)
    return e
end

---Finds the index of a value in a table\
---Returns -1 if element isn't in table
---@param e any
---@param t table
---@return integer
function findInTable(e, t)
	for k, v in pairs(t) do
		if v == e then return k end
	end
	return -1
end

---Gives the list of all enhancements
---@param blacklist table|nil Enhancements that cannot be selected
---@return table
function getEnhancements(blacklist)
	if not blacklist then blacklist = {} end
	local cen_pool = {}
	for _, v in pairs(G.P_CENTER_POOLS.Enhanced) do
		if findInTable(v.key, blacklist) == -1 then
			cen_pool[#cen_pool+1] = v
		end
	end
	return cen_pool
end

---Flip a given card
---@param card table
---@param index number|nil
---@param setSize number 
function flipCard(card, index, setSize)
	if not card then printWarnMessage("No card can be flipped", "Showdown") return end
	if not setSize then printWarnMessage("No set given", "Showdown") return end
	if not index then index = 1 end
	local percent = 1.15 - (index-0.999)/(setSize-0.998)*0.3
	event({trigger = 'after', delay = 0.15, func = function()
		card:flip(); play_sound('card1', percent); card:juice_up(0.3, 0.3);
	return true end })
end

---Unflip a given card
---@param card table
---@param index number|nil
---@param setSize number
function unflipCard(card, index, setSize)
	if not card then printWarnMessage("No card can be unflipped", "Showdown") return end
	if not setSize then printWarnMessage("No set given", "Showdown") return end
	if not index then index = 1 end
	local percent = 0.85 - (index-0.999)/(setSize-0.998)*0.3
	event({trigger = 'after', delay = 0.15, func = function()
		card:flip(); play_sound('tarot2', percent, 0.6); card:juice_up(0.3, 0.3);
	return true end })
end

function forced_message(message, card, color, delay, juice) -- Thanks Bunco
    if delay == true then
        delay = 0.7 * 1.25
    elseif delay == nil then
        delay = 0
    end

    event({trigger = 'before', delay = delay, func = function()

        if juice then juice:juice_up(0.7) end

        card_eval_status_text(
            card,
            'extra',
            nil, nil, nil,
            {message = message, colour = color, instant = true}
        )
        return true
    end})
end
--[[
if not (SMODS.Mods["Paperback"] or {}).can_load then
	local start_dissolve_ref = Card.start_dissolve
	function Card:start_dissolve(dissolve_colours, silent, dissolve_time_fac, no_juice) -- Thanks Paperback
		if self.getting_sliced then
			for i = 1, #G.jokers.cards do
				G.jokers.cards[i]:calculate_joker({ removing_card = true, removed_card = self, area = self.area })
			end
		end

		start_dissolve_ref(self, dissolve_colours, silent, dissolve_time_fac, no_juice)
	end
end
]]--
baseSuits = {'Diamonds', 'Clubs', 'Hearts', 'Spades'}

---Returns all vanilla and modded suits. Arguments can be passed to have more control over the suits:
---- noModded: Exclude Modded suits
---- noVanilla: Exclude Vanilla suits
---- exotic: Include Halberds and Fleurons (Bunco)
---- include_stars: Include Stars (Paperback)
---- include_crowns: Include Crowns (Paperback)
---@param args table|nil
---@return table
function get_all_suits(args)
	if not args then args = {
		exotic = G.GAME and G.GAME.Exotic,
		include_stars = PB_UTIL and (PB_UTIL.has_suit_in_deck('paperback_Stars', true) or PB_UTIL.spectrum_played()),
		include_crowns = PB_UTIL and (PB_UTIL.has_suit_in_deck('paperback_Crowns', true) or PB_UTIL.spectrum_played())
	} end
	local suits = {}
	for i=1, #SMODS.Suit.obj_buffer do
		local suit = SMODS.Suit.obj_table[SMODS.Suit.obj_buffer[i]]
		if (not args.noVanilla and findInTable(suit.key, baseSuits) > -1) or
			(not args.noModded and (
				((suit.key == "bunc_Fleurons" or suit.key == "bunc_Halberds") and args.exotic)
				or (suit.key == "paperback_Stars" and args.include_stars)
				or (suit.key == "paperback_Crowns" and args.include_crowns)
			))
		then
			table.insert(suits, suit.key)
		end
	end
	return suits
end

local baseRanks = {'2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace'}

---Returns all vanilla and modded ranks. Arguments can be passed to have more control over the ranks:
---- blacklist: 		Manually excluded ranks
---- whitelist: 		Manually included ranks
---- noModded: 			Exclude Modded ranks
---- noVanilla: 		Exclude Vanilla ranks
---- noFace:			Exclude face cards (incompatible with onlyFace)
---- onlyFace: 			Exclude all cards that aren't faces (incompatible with noFace)
---- noCounterpart: 	Exclude 2.5, 5.5, 8.5, Butler, Princess and Lord (Showdown, incompatible with onlyCounterpart)
---- onlyCounterpart: 	Exclude all cards that aren't counterparts (Showdown, incompatible with noCounterpart)
---- noZero: 			Exclude 0 (Showdown)
---@param args table|nil
---@return table
function get_all_ranks(args)
	if not args then args = {} end
	local ranks = {}
	local counterparts = {"showdown_2.5", "showdown_5.5", "showdown_8.5", "showdown_Butler", "showdown_Princess", "showdown_Lord", }
	for i=1, #SMODS.Rank.obj_buffer do
		local rank = SMODS.Rank.obj_table[SMODS.Rank.obj_buffer[i]]
		if not args.blacklist or (args.blacklist and findInTable(rank.key, args.blacklist) == -1) then
			if not args.noVanilla then -- Vanilla
				if
					findInTable(rank.key, baseRanks) > -1
					and ((args.noFace and not rank.face) or (args.onlyFace and rank.face) or (not args.noFace and not args.onlyFace))
					and not args.onlyCounterpart
				then
					table.insert(ranks, rank.key)
				end
			end
			if not args.noModded then -- Modded
				if
					findInTable(rank.key, baseRanks) == -1
					and ((findInTable(rank.key, counterparts) == -1 and args.noCounterpart) or (findInTable(rank.key, counterparts) > -1 and args.onlyCounterpart) or (not args.noCounterpart and not args.onlyCounterpart))
					and ((args.noFace and not rank.face) or (args.onlyFace and rank.face) or (not args.noFace and not args.onlyFace))
				then
					table.insert(ranks, rank.key)
				end
			end
		end
	end
	if args.whitelist then
		for i=1, #args.whitelist do
			if findInTable(args.whitelist[i], ranks) == -1 then
				table.insert(ranks, args.whitelist[i])
			end
		end
	end
	return ranks
end

---Returns the card table associated with given rank and suit, return nil if rank or suit is unknown
---@param rank string
---@param suit string
---@return table|nil
function get_card_from_rank_suit(rank, suit)
	if not rank or not suit then return end
	for _, v in pairs(G.P_CARDS) do
		if v.value == rank and v.suit == suit then return v end
	end
	sendWarnMessage(rank.." of "..suit.." does not exist", 'Showdown')
end

function get_lowest_rank(hand)
	local lowestRank = 11
	for i=1, #hand do
		if hand[i].base.nominal < lowestRank then
			lowestRank = hand[i].base.nominal
		end
	end
	return lowestRank
end

local Cardchange_suitRef = Card.change_suit
function Card:change_suit(new_suit)
	if Showdown.is_zero(self) then G.GAME.blind:debuff_card(self)
	else Cardchange_suitRef(self, new_suit) end
end

function create_card_in_deck(rank, suit)
	local created_card = get_card_from_rank_suit(rank, suit)
	if created_card then
		G.E_MANAGER:add_event(Event({
			func = function()
				G.playing_card = (G.playing_card and G.playing_card + 1) or 1
				local card = Card(G.play.T.x + G.play.T.w/2, G.play.T.y, G.CARD_W, G.CARD_H, created_card, G.P_CENTERS.c_base, {playing_card = G.playing_card})
				card:start_materialize({G.C.SECONDARY_SET.Enhanced})
				G.play:emplace(card)
				table.insert(G.playing_cards, card)
				return true
		end}))
		delay(0.6)
		G.E_MANAGER:add_event(Event({
			func = function()
				G.deck.config.card_limit = G.deck.config.card_limit + 1
				return true
		end}))
		draw_card(G.play,G.deck, 90,'up', nil, card)
		playing_card_joker_effects({true})
		delay(0.2)
		return true
	end
	return false
end

function create_cards_in_deck(rank_list, suit_list, nb, args)
	local cards = {}
	print('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA')
	for _=1, nb do
		local rank, suit = pseudorandom_element(rank_list, pseudoseed('create_card')), pseudorandom_element(suit_list, pseudoseed('create_card'))
		local created_card, card = get_card_from_rank_suit(rank, suit), nil
		if created_card then
			G.E_MANAGER:add_event(Event({
				func = function()
					G.playing_card = (G.playing_card and G.playing_card + 1) or 1
					card = Card(G.play.T.x + G.play.T.w/2, G.play.T.y, G.CARD_W, G.CARD_H, created_card, G.P_CENTERS.c_base, {playing_card = G.playing_card})
					card:start_materialize({G.C.SECONDARY_SET.Enhanced})
					G.play:emplace(card)
					table.insert(G.playing_cards, card)
					if args.cheater_add_seal and SMODS.pseudorandom_probability(card, 'cheater_add_seal', 1, 6) then
						local seal = SMODS.poll_seal({guaranteed = true})
						print(seal)
						card:set_seal(seal, nil, true)
					end
					cards[#cards+1] = card
					return true
			end}))
		end
		delay(0.2)
	end
	G.E_MANAGER:add_event(Event({
		func = function()
			G.deck.config.card_limit = G.deck.config.card_limit + nb
			return true
	end}))
	G.E_MANAGER:add_event(Event({
		func = function()
			for i=1, #cards do
				draw_card(G.play, G.deck, i*100/#cards,'up', nil ,cards[i])
			end
			return true
	end}))
	playing_card_joker_effects(cards)
	delay(0.2)
	return cards
end

function prequire(m)
	local ok, err = pcall(require, m)
	if not ok then return nil, err end
	return err
end

function get_highest_ranks_from_deck(number)
	if G.deck then
		local ranks = {}
		for _, card in ipairs(G.deck.cards) do
			local rank = card.base.value
			if findInTable(rank, ranks) == -1 then table.insert(ranks, rank) end
		end
		table.sort(ranks, function(a, b)
			local rank_a, rank_b = SMODS.Ranks[a], SMODS.Ranks[b]
			for _, next_rank in ipairs(rank_b.next) do
				if next_rank == rank_a.key then
					return true
				end
			end
			return rank_a.sort_nominal > rank_b.sort_nominal
		end)
		if #ranks > number then
			local total_ranks = {}
			for i = 1, number do
				table.insert(total_ranks, ranks[i])
			end
			return total_ranks
		end
		return ranks
	end
end