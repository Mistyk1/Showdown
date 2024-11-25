local showdown = SMODS.current_mod
local filesystem = NFS or love.filesystem
local loc = filesystem.load(showdown.path..'localization.lua')()

---- Functions

local function get_coordinates(position, width)
    if width == nil then width = 10 end
    return {x = (position) % width, y = math.floor((position) / width)}
end

local function coordinate(position, width)
    return get_coordinates(position - 1, width)
end

local function modCompatibility(modName, filePath)
	print("Showdown compatibility: "..modName.." is loaded!")
	local mod = filesystem.load(showdown.path..filePath)()
	mod.showdown = showdown
	mod.filesystem = filesystem
	mod.loc = loc
	mod.get_coordinates = get_coordinates
	mod.coordinate = coordinate
end

---- Mod Icon

SMODS.Atlas({key = "showdown_modicon", path = "Mod_icon.png", px = 36, py = 36})

---- Decks

SMODS.Atlas({key = "showdown_decks", path = "Decks.png", px = 71, py = 95})

SMODS.Back{ -- Counterpart Deck
	name = "Counterpart Deck",
	key = "counterpart",
	atlas = "showdown_decks",
	pos = coordinate(1),
	loc_txt = loc.counterpart,
	config = {counterpart_replacing = true},
	loc_vars = function(self) return {vars = {self.config.counterpart_replacing}} end
}

---- Counterpart Cards

SMODS.Atlas({key = "showdown_cards", path = "Ranks/Cards.png", px = 71, py = 95})
SMODS.Atlas({key = "showdown_cardsHC", path = "Ranks/CardsHC.png", px = 71, py = 95})

SMODS.Rank({ -- 2.5 Card
	key = '2.5',
	card_key = 'W',
	shorthand = '2.5',
	pos = { x = 0 },
	nominal = 2.5,
	next = { '3' },
	process_loc_text = function(self)
		SMODS.process_loc_text(G.localization.misc.ranks, self.key, loc.two_half, 'name')
	end,
	decimal = true,
	hc_atlas = 'showdown_cardsHC',
	lc_atlas = 'showdown_cards'
})

SMODS.Rank({ -- 5.5 Card
	key = '5.5',
	card_key = 'F',
	shorthand = '5.5',
	pos = { x = 1 },
	nominal = 5.5,
	next = { '6' },
	process_loc_text = function(self)
		SMODS.process_loc_text(G.localization.misc.ranks, self.key, loc.five_half, 'name')
	end,
	decimal = true,
	hc_atlas = 'showdown_cardsHC',
	lc_atlas = 'showdown_cards'
})

SMODS.Rank({ -- 8.5 Card
	key = '8.5',
	card_key = 'E',
	shorthand = '8.5',
	pos = { x = 2 },
	nominal = 8.5,
	next = { '9' },
	process_loc_text = function(self)
		SMODS.process_loc_text(G.localization.misc.ranks, self.key, loc.eight_half, 'name')
	end,
	decimal = true,
	hc_atlas = 'showdown_cardsHC',
	lc_atlas = 'showdown_cards'
})

SMODS.Rank({ -- Butler Card
	key = 'Butler',
	card_key = 'B',
	shorthand = 'B',
	pos = { x = 3 },
	nominal = 10.5,
	next = { 'Princess' },
	face = true,
	process_loc_text = function(self)
		SMODS.process_loc_text(G.localization.misc.ranks, self.key, loc.butler, 'name')
	end,
	decimal = true,
	hc_atlas = 'showdown_cardsHC',
	lc_atlas = 'showdown_cards'
})

SMODS.Rank({ -- Princess Card
	key = 'Princess',
	card_key = 'P',
	shorthand = 'P',
	pos = { x = 4 },
	nominal = 10.5,
	next = { 'Lord' },
	face = true,
	process_loc_text = function(self)
		SMODS.process_loc_text(G.localization.misc.ranks, self.key, loc.princess, 'name')
	end,
	decimal = true,
	hc_atlas = 'showdown_cardsHC',
	lc_atlas = 'showdown_cards'
})

SMODS.Rank({ -- Lord Card
	key = 'Lord',
	card_key = 'L',
	shorthand = 'L',
	pos = { x = 5 },
	nominal = 10.5,
	next = { 'Ace' },
	face = true,
	process_loc_text = function(self)
		SMODS.process_loc_text(G.localization.misc.ranks, self.key, loc.lord, 'name')
	end,
	decimal = true,
	hc_atlas = 'showdown_cardsHC',
	lc_atlas = 'showdown_cards'
})

SMODS.Rank({ -- 0 Card (counts as any suit and can't be converted to a wild card)
	key = 'Zero',
	card_key = 'Z',
	shorthand = '0',
	pos = { x = 6 },
	nominal = 0,
	next = { 'Ace' },
	process_loc_text = function(self)
		SMODS.process_loc_text(G.localization.misc.ranks, self.key, loc.zero, 'name')
	end,
	suit_map = {
		Hearts = 0,
		Clubs = 0,
		Diamonds = 0,
		Spades = 0,
		Halberds = 0,
		Fleurons = 0,
	},
	straight_edge = true,
	hc_atlas = 'showdown_cardsHC',
	lc_atlas = 'showdown_cards'
})

---- Consumables

-- Tarot

SMODS.Atlas({key = "showdown_tarots", path = "Consumables/Tarots.png", px = 71, py = 95})

SMODS.Consumable({ -- The Reflection
	key = 'Reflection',
	set = 'Tarot',
	atlas = 'showdown_tarots',
	loc_txt = loc.reflection,
	config = {max_highlighted = 2},
    loc_vars = function(self) return {vars = {self.config.max_highlighted}} end,
    pos = coordinate(1),
	can_use = function()
		-- if up to 2 cards are selected and have counterparts
        return true
    end,
    use = function()
		print("The Reflection card is used")
        -- convert selected cards into their counterparts
    end
})

SMODS.Consumable({ -- The Vessel
	key = 'Vessel',
	set = 'Tarot',
	atlas = 'showdown_tarots',
	loc_txt = loc.vessel,
	config = {max_highlighted = 1},
    loc_vars = function(self) return {vars = {self.config.max_highlighted}} end,
    pos = coordinate(2),
	can_use = function()
		-- if a card is selected
        return true
    end,
    use = function()
		print("The Vessel card is used")
        -- convert selected card to a 0 with a random enhancement or seal
    end
})

SMODS.Consumable({ -- The Genie
	key = 'Genie',
	set = 'Tarot',
	atlas = 'showdown_tarots',
	loc_txt = loc.genie,
	config = {max_highlighted = 1},
    loc_vars = function(self) return {vars = {self.config.max_highlighted}} end,
    pos = coordinate(3),
	can_use = function()
		-- if there's still room for consumables
        return true
    end,
    use = function()
		print("The Genie card is used")
        -- create a random mathematic card
    end
})

-- Spectral

SMODS.Atlas({key = "showdown_spectrals", path = "Consumables/Spectrals.png", px = 71, py = 95})

SMODS.Consumable({ -- Mist
	key = 'Mist',
	set = 'Spectral',
	atlas = 'showdown_spectrals',
	loc_txt = loc.mist,
	config = {max_highlighted = 6},
    loc_vars = function(self) return {vars = {self.config.max_highlighted}} end,
    pos = coordinate(1),
	can_use = function()
		-- if hand has at least 6 cards
        return true
    end,
    use = function()
		print("Mist card is used")
        -- select 6 random cards and converts them into either an ace or a 0
    end
})

SMODS.Consumable({ -- Vision
	key = 'Vision',
	set = 'Spectral',
	atlas = 'showdown_spectrals',
	loc_txt = loc.vision,
    pos = coordinate(2),
	can_use = function()
		-- if hand contains card
        return true
    end,
    use = function()
		print("Vision card is used")
        -- convert all cards in hand into their higher/equal counterpart and removes their enhancement, edition or seal
    end
})

-- Mathematic (gives bonus for current ante)

SMODS.Atlas({key = 'showdown_mathematic_undiscovered', path = 'Consumables/MathematicsUndiscovered.png', px = 71, py = 95})
SMODS.Atlas({key = 'showdown_mathematic', path = 'Consumables/Mathematics.png', px = 71, py = 95})

SMODS.ConsumableType{
    key = 'Mathematic',
    primary_colour = G.C.SHOWDOWN_MATHEMATIC,
    secondary_colour = G.C.SHOWDOWN_MATHEMATIC_DARK,
    loc_txt = loc.mathematic,
    collection_rows = {4, 4}
}

SMODS.UndiscoveredSprite{
    key = 'Mathematic',
    atlas = 'showdown_mathematic_undiscovered',
    pos = coordinate(1)
}

SMODS.Consumable({ -- Constant
	key = 'Constant',
	set = 'Mathematic',
	atlas = 'showdown_mathematic',
	loc_txt = loc.constant,
    pos = coordinate(1),
	can_use = function()
        -- idk
        return true
    end,
    use = function()
		print("Constant card is used")
        -- idk
    end
})

SMODS.Consumable({ -- Variable
	key = 'Variable',
	set = 'Mathematic',
	atlas = 'showdown_mathematic',
	loc_txt = loc.variable,
    pos = coordinate(2),
	can_use = function()
        -- idk
        return true
    end,
    use = function()
		print("Variable card is used")
        -- idk
    end
})

SMODS.Consumable({ -- Function
	key = 'Function',
	set = 'Mathematic',
	atlas = 'showdown_mathematic',
	loc_txt = loc.functio, -- no n because it fucks with lua
    pos = coordinate(3),
	can_use = function()
        -- idk
        return true
    end,
    use = function()
		print("Function card is used")
        -- idk
    end
})

SMODS.Consumable({ -- Shape
	key = 'Shape',
	set = 'Mathematic',
	atlas = 'showdown_mathematic',
	loc_txt = loc.shape,
    pos = coordinate(4),
	can_use = function()
        -- idk
        return true
    end,
    use = function()
		print("Shape card is used")
        -- idk
    end
})

SMODS.Consumable({ -- Vector
	key = 'Vector',
	set = 'Mathematic',
	atlas = 'showdown_mathematic',
	loc_txt = loc.vector,
    pos = coordinate(5),
	can_use = function()
        -- idk
        return true
    end,
    use = function()
		print("Vector card is used")
        -- idk
    end
})

SMODS.Consumable({ -- Probability
	key = 'Probability',
	set = 'Mathematic',
	atlas = 'showdown_mathematic',
	loc_txt = loc.probability,
    pos = coordinate(6),
	can_use = function()
        -- idk
        return true
    end,
    use = function()
		print("Probability card is used")
        -- idk
    end
})

SMODS.Consumable({ -- Sequence
	key = 'Sequence',
	set = 'Mathematic',
	atlas = 'showdown_mathematic',
	loc_txt = loc.sequence,
    pos = coordinate(7),
	can_use = function()
        -- idk
        return true
    end,
    use = function()
		print("Sequence card is used")
        -- idk
    end
})

SMODS.Consumable({ -- ?
	key = '?',
	set = 'Mathematic',
	atlas = 'showdown_mathematic',
	loc_txt = loc.a,
    pos = coordinate(8),
	can_use = function()
        -- idk
        return true
    end,
    use = function()
		print("? card is used")
        -- idk
    end
})

SMODS.Consumable({ -- I HAVE TO DELETE THIS (this is for undiscovered sprite)
	key = 'test',
	set = 'Mathematic',
	atlas = 'showdown_mathematic',
	loc_txt = loc.a,
    pos = coordinate(9),
})

---- Vouchers
---
SMODS.Atlas({key = 'showdown_vouchers', path = 'Consumables/Vouchers.png', px = 71, py = 95})

SMODS.Voucher({ -- Irrational Numbers
	key = 'Irrational',
	atlas = 'showdown_vouchers',
	loc_txt = loc.irrational,
    unlocked = false,
	pos = coordinate(1),
	check_for_unlock = function()
        -- if 20 counterpart cards in deck
    end,
})

SMODS.Voucher({ -- Transcendant Numbers
	key = 'Transcendant',
	atlas = 'showdown_vouchers',
	loc_txt = loc.transcendant,
    unlocked = false,
    requires = {'showdown_Irrational'},
	pos = coordinate(2, 1),
	check_for_unlock = function()
        -- if 10 counterpart cards in deck with one or more modifiers
    end,
})

---- Jokers

--SMODS.Atlas({key = "showdown_jokers", path = "Ranks/Cards.png", px = 71, py = 95})

SMODS.Joker({
	key = 'Pinpoint',
	rarity = 2,
	--atlas = 'showdown_jokers',
	loc_txt = loc.pinpoint,
})

if (SMODS.Mods["Bunco"] or {}).can_load then
	modCompatibility("Bunco", "compat/buncoCompat.lua")
end
if (SMODS.Mods["Cryptid"] or {}).can_load then
	modCompatibility("Cryptid", "compat/cryptidCompat.lua")
end