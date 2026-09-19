local function inject_p_card_suit_compat(suit, rank)
	local card = {
		name = rank.key .. ' of ' .. suit.key,
		value = rank.key,
		suit = suit.key,
		pos = { x = rank.pos.x, y = rank.suit_map[suit.key] or suit.pos.y },
		lc_atlas = rank.suit_map[suit.key] and rank.lc_atlas or suit.lc_atlas,
		hc_atlas = rank.suit_map[suit.key] and rank.hc_atlas or suit.hc_atlas,
	}
	if findInTable(card.suit, baseSuits) == -1 then
		if not Showdown.extraSuits[card.suit] then
			sendWarnMessage("Unknown suit for "..card.name, "Showdown")
			card.lc_atlas = 'showdown_unknownSuit'
			card.hc_atlas = 'showdown_unknownSuit'
			card.pos = {x = 0, y = 0}
		else
			card.lc_atlas = Showdown.extraSuits[card.suit].lc_atlas
			card.hc_atlas = Showdown.extraSuits[card.suit].hc_atlas
		end
	end
	G.P_CARDS[suit.card_key .. '_' .. rank.card_key] = card
end

local count2 = { -- 2.5 Card
	type = 'Rank',
	key = '2.5',
	card_key = 'W',
	shorthand = '2.5',
	pos = { x = 0 },
	nominal = 2.5,
	next = { '3' },
	prev = { '2' },
	counterpart = { is = true, value = '2' },
	secret = true,
	max_id = {
		value = -3,
	},
	hc_atlas = 'showdown_cardsHC',
	lc_atlas = 'showdown_cards',
	inject = function(self)
		for _, suit in pairs(SMODS.Suits) do
			inject_p_card_suit_compat(suit, self)
		end
	end,
} -- id: -2

local count5 = { -- 5.5 Card
	type = 'Rank',
	key = '5.5',
	card_key = 'F',
	shorthand = '5.5',
	pos = { x = 1 },
	nominal = 5.5,
	next = { '6' },
	prev = { '5' },
	counterpart = { is = true, value = '5' },
	secret = true,
	max_id = {
		value = -6,
	},
	hc_atlas = 'showdown_cardsHC',
	lc_atlas = 'showdown_cards',
	inject = function(self)
		for _, suit in pairs(SMODS.Suits) do
			inject_p_card_suit_compat(suit, self)
		end
	end,
} -- id: -5

local count8 = { -- 8.5 Card
	type = 'Rank',
	key = '8.5',
	card_key = 'E',
	shorthand = '8.5',
	pos = { x = 2 },
	nominal = 8.5,
	next = { '9' },
	prev = { '8' },
	counterpart = { is = true, value = '8' },
	secret = true,
	max_id = {
		value = -9,
	},
	hc_atlas = 'showdown_cardsHC',
	lc_atlas = 'showdown_cards',
	inject = function(self)
		for _, suit in pairs(SMODS.Suits) do
			inject_p_card_suit_compat(suit, self)
		end
	end,
} -- id: -8

local countButler = { -- Butler Card
	type = 'Rank',
	key = 'Butler',
	card_key = 'B',
	shorthand = 'B',
	pos = { x = 3 },
	nominal = 10.5,
	face_nominal = -0.35,
	next = { 'showdown_Princess', 'Queen' },
	prev = { '10' },
	face = true,
	counterpart = { is = true, value = 'Jack' },
	secret = true,
	max_id = {
		value = -12,
	},
	hc_atlas = 'showdown_cardsHC',
	lc_atlas = 'showdown_cards',
	inject = function(self)
		for _, suit in pairs(SMODS.Suits) do
			inject_p_card_suit_compat(suit, self)
		end
	end,
} -- id: -11

local countPrincess = { -- Princess Card
	type = 'Rank',
	key = 'Princess',
	card_key = 'P',
	shorthand = 'P',
	pos = { x = 4 },
	nominal = 10.5,
	face_nominal = -0.25,
	next = { 'showdown_Lord', 'King' },
	prev = { 'showdown_Butler', 'Jack' },
	face = true,
	counterpart = { is = true, value = 'Queen' },
	secret = true,
	max_id = {
		value = -13,
	},
	hc_atlas = 'showdown_cardsHC',
	lc_atlas = 'showdown_cards',
	inject = function(self)
		for _, suit in pairs(SMODS.Suits) do
			inject_p_card_suit_compat(suit, self)
		end
	end,
} -- id: -12

local countLord = { -- Lord Card
	type = 'Rank',
	key = 'Lord',
	card_key = 'L',
	shorthand = 'L',
	pos = { x = 5 },
	nominal = 10.5,
	face_nominal = -0.15,
	next = { 'Ace' },
	prev = { 'showdown_Princess', 'Queen' },
	face = true,
	counterpart = { is = true, value = 'King' },
	secret = true,
	max_id = {
		value = -14,
	},
	hc_atlas = 'showdown_cardsHC',
	lc_atlas = 'showdown_cards',
	inject = function(self)
		for _, suit in pairs(SMODS.Suits) do
			inject_p_card_suit_compat(suit, self)
		end
	end,
} -- id: -13

local zero = { -- 0 Card (counts as any suit and can't be converted to a wild card)
	type = 'Rank',
	key = 'Zero',
	card_key = 'Z',
	shorthand = '0',
	pos = { x = 6 },
	nominal = 0,
	next = { 'Ace' },
	prev = { 'Ace', 'King', 'showdown_Lord' },
	secret = true,
	suit_map = {
		Hearts = 0,
		Clubs = 0,
		Diamonds = 0,
		Spades = 0,
	},
	max_id = {
		value = 0,
	},
	hc_atlas = 'showdown_cardsHC',
	lc_atlas = 'showdown_cards',
	inject = function(self)
		for _, suit in pairs(SMODS.Suits) do
			inject_p_card_suit_compat(suit, self)
		end
	end,
} -- id: 1

return {
	enabled = Showdown.config["Ranks"],
	list = function()
		local list = {
			count2,
			count5,
			count8,
			countButler,
			countPrincess,
			countLord,
			zero,
		}
		return list
	end,
	atlases = {
		-- Vanilla
		{key = "showdown_cards", path = "Ranks/Cards.png", px = 71, py = 95},
		{key = "showdown_cardsHC", path = "Ranks/CardsHC.png", px = 71, py = 95},
		{key = "showdown_unknownSuit", path = "Ranks/Unknown.png", px = 71, py = 95},
		-- Bunco
		{key = "showdown_exoticCards", path = "CrossMod/Bunco/Ranks/Cards.png", px = 71, py = 95, mod_compat = "Bunco"},
		{key = "showdown_exoticCardsHC", path = "CrossMod/Bunco/Ranks/CardsHC.png", px = 71, py = 95, mod_compat = "Bunco"},
		-- Musical Suits
		{key = "showdown_musicalCards", path = "CrossMod/MusicalSuit/Ranks/Cards.png", px = 71, py = 95, mod_compat = "MusicalSuit"},
		{key = "showdown_musicalCardsHC", path = "CrossMod/MusicalSuit/Ranks/CardsHC.png", px = 71, py = 95, mod_compat = "MusicalSuit"},
		-- Ink and Color
		{key = "showdown_inkColorCards", path = "CrossMod/InkAndColor/Ranks/Cards.png", px = 71, py = 95, mod_compat = "InkAndColor"},
		{key = "showdown_inkColorCardsHC", path = "CrossMod/InkAndColor/Ranks/CardsHC.png", px = 71, py = 95, mod_compat = "InkAndColor"},
		-- Paperback
		{key = "showdown_paperbackCards", path = "CrossMod/Paperback/Ranks/Cards.png", px = 71, py = 95, mod_compat = "paperback"},
		{key = "showdown_paperbackCardsHC", path = "CrossMod/Paperback/Ranks/CardsHC.png", px = 71, py = 95, mod_compat = "paperback"},
		-- Madcap
		{key = "showdown_madcapCards", path = "CrossMod/Madcap/Ranks/Cards.png", px = 71, py = 95, mod_compat = "rgmadcap"},
		{key = "showdown_madcapCardsHC", path = "CrossMod/Madcap/Ranks/CardsHC.png", px = 71, py = 95, mod_compat = "rgmadcap"},
		-- Entropy
		{key = "showdown_entropyCards", path = "CrossMod/Entropy/Ranks/Cards.png", px = 71, py = 95, mod_compat = "entr"},
		{key = "showdown_entropyCardsHC", path = "CrossMod/Entropy/Ranks/CardsHC.png", px = 71, py = 95, mod_compat = "entr"},
		-- Minty's Silly Little Mod
		{key = "showdown_mintyCards", path = "CrossMod/MintysSillyMod/Ranks/Cards.png", px = 71, py = 95, mod_compat = "MintysSillyMod"},
		{key = "showdown_mintyCardsHC", path = "CrossMod/MintysSillyMod/Ranks/CardsHC.png", px = 71, py = 95, mod_compat = "MintysSillyMod"},
	},
	exec = function()
		-- These are for making straights with counterparts and normal cards
		table.insert(SMODS.Ranks["Ace"].next, "showdown_2.5")
		table.insert(SMODS.Ranks["4"].next, "showdown_5.5")
		table.insert(SMODS.Ranks["7"].next, "showdown_8.5")
		table.insert(SMODS.Ranks["10"].next, "showdown_Butler")
		table.insert(SMODS.Ranks["Jack"].next, "showdown_Princess")
		table.insert(SMODS.Ranks["Queen"].next, "showdown_Lord")
		--

		SMODS.Ranks["2"].counterpart = { is = false, value = "showdown_2.5"}
		SMODS.Ranks["5"].counterpart = { is = false, value = "showdown_5.5"}
		SMODS.Ranks["8"].counterpart = { is = false, value = "showdown_8.5"}
		SMODS.Ranks["Jack"].counterpart = { is = false, value = "showdown_Butler"}
		SMODS.Ranks["Queen"].counterpart = { is = false, value = "showdown_Princess"}
		SMODS.Ranks["King"].counterpart = { is = false, value = "showdown_Lord"}

		local SMODShas_any_suitRef = SMODS.has_any_suit
		function SMODS.has_any_suit(card)
			if
				Showdown.is_zero(card)
				or (next(find_joker('sim_card')) and Showdown.is_counterpart(card))
			then
				return true
			end
			SMODShas_any_suitRef(card)
		end

		local Cardis_suit_ref = Card.is_suit
		function Card:is_suit(suit, bypass_debuff, flush_calc)
			if Showdown.is_zero(self) then return true end
			Cardis_suit_ref(card)
		end

		function Showdown.is_counterpart(card)
			return next(find_joker("hiding_details")) or (SMODS.Ranks[card.base.value] and SMODS.Ranks[card.base.value].counterpart and SMODS.Ranks[card.base.value].counterpart.is)
		end

		function Showdown.is_zero(card)
			return card.base.id == 1 or card.base.value == 'showdown_Zero'
		end

		if (SMODS.Mods["Bunco"] or {}).can_load then
			Showdown.extraSuits['bunc_Fleurons'] = {lc_atlas = 'showdown_exoticCards', hc_atlas = 'showdown_exoticCardsHC'}
			Showdown.extraSuits['bunc_Halberds'] = {lc_atlas = 'showdown_exoticCards', hc_atlas = 'showdown_exoticCardsHC'}
		end
		if (SMODS.Mods["MusicalSuit"] or {}).can_load then
			Showdown.extraSuits['Notes'] = {lc_atlas = 'showdown_musicalCards', hc_atlas = 'showdown_musicalCardsHC'}
		end
		if (SMODS.Mods["InkAndColor"] or {}).can_load then
			Showdown.extraSuits['ink_Inks'] = {lc_atlas = 'showdown_inkColorCards', hc_atlas = 'showdown_inkColorCardsHC'}
			Showdown.extraSuits['ink_Colors'] = {lc_atlas = 'showdown_inkColorCards', hc_atlas = 'showdown_inkColorCardsHC'}
		end
		if (SMODS.Mods["paperback"] or {}).can_load then
			Showdown.extraSuits['paperback_Stars'] = {lc_atlas = 'showdown_paperbackCards', hc_atlas = 'showdown_paperbackCardsHC'}
			Showdown.extraSuits['paperback_Crowns'] = {lc_atlas = 'showdown_paperbackCards', hc_atlas = 'showdown_paperbackCardsHC'}
		end
		if (SMODS.Mods["rgmadcap"] or {}).can_load then
			Showdown.extraSuits['rgmc_goblets'] = {lc_atlas = 'showdown_madcapCards', hc_atlas = 'showdown_madcapCardsHC'}
			Showdown.extraSuits['rgmc_towers'] = {lc_atlas = 'showdown_madcapCards', hc_atlas = 'showdown_madcapCardsHC'}
			Showdown.extraSuits['rgmc_blooms'] = {lc_atlas = 'showdown_madcapCards', hc_atlas = 'showdown_madcapCardsHC'}
			Showdown.extraSuits['rgmc_daggers'] = {lc_atlas = 'showdown_madcapCards', hc_atlas = 'showdown_madcapCardsHC'}
			Showdown.extraSuits['rgmc_voids'] = {lc_atlas = 'showdown_madcapCards', hc_atlas = 'showdown_madcapCardsHC'}
			Showdown.extraSuits['rgmc_lanterns'] = {lc_atlas = 'showdown_madcapCards', hc_atlas = 'showdown_madcapCardsHC'}
		end
		if (SMODS.Mods["entr"] or {}).can_load then
			Showdown.extraSuits['entr_nilsuit'] = {lc_atlas = 'showdown_entropyCards', hc_atlas = 'showdown_entropyCardsHC'}
		end
		if (SMODS.Mods["MintysSillyMod"] or {}).can_load then
			Showdown.extraSuits['minty_3s'] = {lc_atlas = 'showdown_mintyCards', hc_atlas = 'showdown_mintyCardsHC'}
		end
	end
}