local mirror = {
	type = 'Sleeve',
	order = 1,
	key = "Mirror",
	atlas = "showdown_sleeves",
	pos = coordinate(1),
	unlocked = false,
	unlock_condition = {deck = "b_showdown_Mirror", stake = "stake_showdown_emerald"},
	loc_vars = function(self)
		return { key = self.key..(self.get_current_deck_key() == "b_showdown_Mirror" and "_alt" or "") }
	end,
	locked_loc_vars = function(self)
		if not Showdown.has_stakes then return { key = 'sleeve_showdown_deactivated' } end
		return CardSleeves.Sleeve.locked_loc_vars(self)
	end,
	apply = function(self, sleeve)
        CardSleeves.Sleeve.apply(self)
		if self.get_current_deck_key() ~= "b_showdown_Mirror" then
            SMODS.Back.obj_table["b_showdown_Mirror"].apply(self, sleeve)
        else
			G.E_MANAGER:add_event(Event({
				func = function()
					local card = SMODS.create_card({set = 'Joker', key = 'j_showdown_hiding_details', area = G.jokers, edition = {negative = true}})
					card:add_to_deck()
					G.jokers:emplace(card)
					return true
				end
			}))
        end
	end,
}

local calculus = {
	type = 'Sleeve',
	order = 2,
	key = "Calculus",
	atlas = "showdown_sleeves",
	pos = coordinate(2),
	unlocked = false,
	unlock_condition = {deck = "b_showdown_Calculus", stake = "stake_black"},
	loc_vars = function(self)
		local key, vars
        if self.get_current_deck_key() ~= "b_showdown_Calculus" then
            key = self.key
			self.config = { vouchers = { "v_showdown_number" }, consumables = { 'c_showdown_genie' } }
        else
            key = self.key .. "_alt"
			self.config = { vouchers = { "v_showdown_axiom" }, consumables = { 'c_showdown_genie' } }
        end
		return { key = key, vars = vars }
	end,
}

local starter = {
	type = 'Sleeve',
	order = 3,
	key = "Starter",
	atlas = "showdown_sleeves",
	pos = coordinate(3),
	config = { showdown_starter = true },
	unlocked = false,
	unlock_condition = {deck = "b_showdown_Starter", stake = "stake_black"},
	loc_vars = function(self)
		return { key = self.key..(self.get_current_deck_key() == "b_showdown_Starter" and "_alt" or "") }
	end,
	apply = function(self, sleeve)
        CardSleeves.Sleeve.apply(self)
		if self.get_current_deck_key() ~= "b_showdown_Starter" then
            G.GAME.starting_params.dollars = -5
			give_starter()
        else
            G.GAME.starting_params.dollars = 0
			give_starter(true)
        end
	end
}

local cheater = {
	type = 'Sleeve',
	order = 4,
	key = "Cheater",
	atlas = "showdown_sleeves",
	pos = coordinate(4),
	config = { showdown_cheater = true },
	unlocked = false,
	unlock_condition = {deck = "b_showdown_Cheater", stake = "stake_blue"},
	loc_vars = function(self)
		return { key = self.key..(self.get_current_deck_key() == "b_showdown_Cheater" and "_alt" or ""), vars = { (G.GAME and G.GAME.probabilities.normal) or 1 } }
	end,
	apply = function(self, sleeve)
        CardSleeves.Sleeve.apply(self)
		if self.get_current_deck_key() ~= "b_showdown_Cheater" then
			SMODS.Back.obj_table["b_showdown_Cheater"].apply(self, sleeve)
		else
            G.GAME.cheater_seal = true
        end
	end,
	calculate = function(self, card, context)
        return SMODS.Back.obj_table["b_showdown_Cheater"]:calculate(card, context)
	end,
}

local engineer = {
	type = 'Sleeve',
	order = 5,
	key = "Engineer",
	atlas = "showdown_sleeves",
	pos = coordinate(5),
	unlocked = false,
	unlock_condition = {deck = "b_showdown_Engineer", stake = "stake_showdown_amethyst"},
	loc_vars = function(self)
		return { key = self.key..(self.get_current_deck_key() == "b_showdown_Engineer" and "_alt" or "") }
	end,
	locked_loc_vars = function(self)
		if not Showdown.has_stakes then return { key = 'sleeve_showdown_deactivated' } end
		return CardSleeves.Sleeve.locked_loc_vars(self)
	end,
	apply = function(self, sleeve)
        CardSleeves.Sleeve.apply(self)
		if self.get_current_deck_key() ~= "b_showdown_Engineer" then
            SMODS.Back.obj_table["b_showdown_Engineer"].apply(self, sleeve)
        else
			G.E_MANAGER:add_event(Event({
				func = function()
					local keys = {}
					for k, v in pairs(Showdown.tag_related_joker) do
						if v then table.insert(keys, k) end
					end
					local card = SMODS.create_card({set = 'Joker', key = keys[math.random(#keys)], area = G.jokers})
					card:add_to_deck()
					G.jokers:emplace(card)
					return true
				end
			}))
        end
	end
}

local chess = {
	type = 'Sleeve',
	order = 6,
	key = "Chess",
	atlas = "showdown_sleeves",
	pos = coordinate(6),
	unlocked = false,
	unlock_condition = {deck = "b_showdown_Chess", stake = "stake_showdown_amethyst"},
	loc_vars = function(self)
		return { key = self.key..(self.get_current_deck_key() == "b_showdown_Chess" and "_alt" or "") }
	end,
	locked_loc_vars = function(self)
		if not Showdown.has_stakes then return { key = 'sleeve_showdown_deactivated' } end
		return CardSleeves.Sleeve.locked_loc_vars(self)
	end,
	apply = function(self, sleeve)
        CardSleeves.Sleeve.apply(self)
		if self.get_current_deck_key() ~= "b_showdown_Chess" then
            SMODS.Back.obj_table["b_showdown_Chess"].apply(self, sleeve)
        else
			G.GAME.showdown_chess_boosted = true
        end
	end
}

local slotted = {
	type = 'Sleeve',
	experimental = true,
	order = 7,
	key = "Slotted",
	atlas = "showdown_sleeves",
	pos = coordinate(6),
	unlocked = false,
	unlock_condition = {deck = "b_showdown_Slotted", stake = "stake_showdown_amethyst"},
	loc_vars = function(self)
		return { key = self.key..(self.get_current_deck_key() == "b_showdown_Slotted" and "_alt" or "") }
	end,
	locked_loc_vars = function(self)
		if not Showdown.has_stakes then return { key = 'sleeve_showdown_deactivated' } end
		return CardSleeves.Sleeve.locked_loc_vars(self)
	end,
	apply = function(self, sleeve)
        CardSleeves.Sleeve.apply(self)
		if self.get_current_deck_key() ~= "b_showdown_Slotted" then
            SMODS.Back.obj_table["b_showdown_Slotted"].apply(self, sleeve)
        else
			G.GAME.starting_params.joker_slots = G.GAME.starting_params.joker_slots + 1
        	G.GAME.starting_params.consumable_slots = G.GAME.starting_params.consumable_slots + 1
			change_shop_size(-1)
        end
	end
}

return {
	enabled = (SMODS.Mods["CardSleeves"] or {}).can_load and Showdown.config["CrossMod"]["CardSleeves"],
	list = function()
		local list = {
			starter,
			slotted,
		}
		if Showdown.config["Ranks"] then
			table.insert(list, mirror)
			table.insert(list, cheater)
		end
		if Showdown.config["Consumables"]["Mathematics"] then
			table.insert(list, calculus)
		end
		if Showdown.config["Tags"]["Switches"] then
			table.insert(list, engineer)
		end
		if Showdown.config["Blinds"] then
			table.insert(list, chess)
		end
		return list
	end,
	atlases = {
		{key = "showdown_sleeves", path = "CrossMod/CardSleeves/sleeves.png", px = 73, py = 94},
	},
	order = 2,
    class = CardSleeves,
}