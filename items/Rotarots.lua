local rot_reflection = {
	type = 'Consumable',
	order = 1,
	key = 'rot_reflection',
	set = 'Rotarot',
	atlas = 'showdown_rotarots',
    display_size = { w = 107, h = 107 },
	config = {max_highlighted = 2},
	loc_vars = function(self, info_queue, card)
		return {vars = {self.config.max_highlighted}}
	end,
    pos = coordinate(1),
	can_use = function(self)
        return G.hand and #G.hand.highlighted <= self.config.max_highlighted and #G.hand.highlighted >= 1
    end,
    use = function(self, card, area, copier)
		for i=1, #G.hand.highlighted do flipCard(G.hand.highlighted[i], i, #G.hand.highlighted) end
        delay(0.2)
		for i=1, #G.hand.highlighted do
            event({trigger = 'after', delay = 0.1, func = function()
				assert(SMODS.change_base(G.hand.highlighted[i], nil, 'showdown_Zero'))
            return true end })
        end
		for i=1, #G.hand.highlighted do unflipCard(G.hand.highlighted[i], i, #G.hand.highlighted) end
		event({trigger = 'after', delay = 0.2, func = function()
            G.hand:unhighlight_all();
        return true end })
        delay(0.5)
    end
}

local rot_vessel = {
	type = 'Consumable',
	order = 2,
	key = 'rot_vessel',
	set = 'Rotarot',
	atlas = 'showdown_rotarots',
    display_size = { w = 107, h = 107 },
	config = {max_highlighted = 1},
    loc_vars = function(self, info_queue, card)
        return {vars = {self.config.max_highlighted}}
    end,
    pos = coordinate(2),
	can_use = function(self)
        return G.hand and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        delay(0.2)
		event({trigger = 'after', delay = 0.1, func = function()
			assert(SMODS.change_base(G.hand.highlighted[1], nil, "showdown_Zero"))
		return true end })
		local edition = poll_edition('rot_vessel', nil, true, true)
        if edition then G.hand.highlighted[1]:set_edition(edition) end
		event({trigger = 'after', delay = 0.2, func = function()
            G.hand:unhighlight_all();
        return true end })
        delay(0.5)
    end
}

local rot_genie = {
	type = 'Consumable',
	order = 3,
	key = 'rot_genie',
	set = 'Rotarot',
	atlas = 'showdown_rotarots',
    display_size = { w = 107, h = 107 },
	config = { create = 1 },
    loc_vars = function(self, info_queue, card)
        if not (not fool_c or fool_c.name == 'The Fool') then
            info_queue[#info_queue+1] = fool_c
        end
        return {vars = {self.config.create}}
    end,
    generate_ui = function(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
        SMODS.Consumable.super.generate_ui(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
        local genie_c = G.GAME.last_math and G.P_CENTERS[G.GAME.last_math] or nil
        local last_math = genie_c and localize{type = 'name_text', key = genie_c.key, set = genie_c.set} or localize('k_none')
        local colour = (not genie_c) and G.C.RED or G.C.GREEN
        desc_nodes[#desc_nodes+1] = {
            {n=G.UIT.C, config={align = "bm", padding = 0.02}, nodes={
                {n=G.UIT.C, config={align = "m", colour = colour, r = 0.05, padding = 0.05}, nodes={
                    {n=G.UIT.T, config={text = ' '..last_math..' ', colour = G.C.UI.TEXT_LIGHT, scale = 0.3, shadow = true}},
                }}
            }}
        }
        if not not genie_c then
            info_queue[#info_queue+1] = genie_c
        end
    end,
    pos = coordinate(3),
	can_use = function(self)
        return (#G.consumeables.cards < G.consumeables.config.card_limit or self.area == G.consumeables) and G.GAME.last_math
    end,
    use = function(self, card, area, copier)
        local used_rot_tarot = copier or card
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            if G.consumeables.config.card_limit > #G.consumeables.cards then
                play_sound('timpani')
                local _card = create_card('Mathematic', G.consumeables, nil, nil, nil, nil, G.GAME.last_math, 'rot_genie')
                _card:add_to_deck()
                G.consumeables:emplace(_card)
                used_rot_tarot:juice_up(0.3, 0.5)
            end
            return true end }))
        delay(0.6)
    end
}

local rot_lost = {
	type = 'Consumable',
	order = 4,
	key = 'rot_lost',
	set = 'Rotarot',
	atlas = 'showdown_rotarots',
    display_size = { w = 107, h = 107 },
	config = { max_highlighted = 1, mod_conv = "m_showdown_frozen" },
    loc_vars = function(self, info_queue)
        info_queue[#info_queue+1] = G.P_CENTERS.m_showdown_frozen
		return {vars = {self.config.max_highlighted}}
	end,
    pos = coordinate(4),
	can_use = function(self)
		return G.hand and #G.hand.highlighted <= self.config.max_highlighted and #G.hand.highlighted >= 1
    end
}

local rot_angel = {
	type = 'Consumable',
	order = 5,
	key = 'rot_angel',
	set = 'Rotarot',
	atlas = 'showdown_rotarots',
    display_size = { w = 107, h = 107 },
	config = { max_highlighted = 1, mod_conv = "m_showdown_cursed" },
    loc_vars = function(self, info_queue)
        info_queue[#info_queue+1] = G.P_CENTERS.m_showdown_cursed
		return {vars = {self.config.max_highlighted}}
	end,
    pos = coordinate(5),
	can_use = function(self)
		return G.hand and #G.hand.highlighted <= self.config.max_highlighted and #G.hand.highlighted >= 1
    end
}

local rot_inventor = {
	type = 'Consumable',
	order = 6,
	key = 'rot_inventor',
	set = 'Rotarot',
	atlas = 'showdown_rotarots',
    display_size = { w = 107, h = 107 },
	config = { create = 1 },
    loc_vars = function(self, info_queue, card)
        return {vars = {self.config.create}}
    end,
    generate_ui = function(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
        SMODS.Consumable.super.generate_ui(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
        local logic_c = G.GAME.last_logic and G.P_CENTERS[G.GAME.last_logic] or nil
        local last_logic = logic_c and localize{type = 'name_text', key = logic_c.key, set = logic_c.set} or localize('k_none')
        local colour = (not logic_c) and G.C.RED or G.C.GREEN
        desc_nodes[#desc_nodes+1] = {
            {n=G.UIT.C, config={align = "bm", padding = 0.02}, nodes={
                {n=G.UIT.C, config={align = "m", colour = colour, r = 0.05, padding = 0.05}, nodes={
                    {n=G.UIT.T, config={text = ' '..last_logic..' ', colour = G.C.UI.TEXT_LIGHT, scale = 0.3, shadow = true}},
                }}
            }}
        }
        if not not logic_c then
            info_queue[#info_queue+1] = logic_c
        end
    end,
    pos = coordinate(7),
	can_use = function(self)
        return (#G.consumeables.cards < G.consumeables.config.card_limit or self.area == G.consumeables) and G.GAME.last_logic
    end,
    use = function(self, card, area, copier)
        local used_rot_tarot = copier or card
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            if G.consumeables.config.card_limit > #G.consumeables.cards then
                play_sound('timpani')
                local _card = create_card('Logic', G.consumeables, nil, nil, nil, nil, G.GAME.last_logic, 'rot_inventor')
                _card:add_to_deck()
                G.consumeables:emplace(_card)
                used_rot_tarot:juice_up(0.3, 0.5)
            end
            return true end }))
        delay(0.6)
    end
}

local rot_guard = {
	type = 'Consumable',
	order = 9,
	key = 'rot_guard',
	set = 'Rotarot',
	atlas = 'showdown_rotarots',
    display_size = { w = 107, h = 107 },
	config = { max_highlighted = 1, mod_conv = "m_showdown_taped" },
    loc_vars = function(self, info_queue)
        info_queue[#info_queue+1] = G.P_CENTERS.m_showdown_taped
		return {vars = {self.config.max_highlighted}}
	end,
    pos = coordinate(8),
	can_use = function(self)
		return G.hand and #G.hand.highlighted <= self.config.max_highlighted and #G.hand.highlighted >= 1
    end
}

-- Bunco

local rot_beast = {
	type = 'Consumable',
	order = 1000,
	key = 'rot_beast',
	set = 'Rotarot',
	atlas = 'showdown_rotarots',
    display_size = { w = 107, h = 107 },
	config = {copies = 1},
    loc_vars = function(self, info_queue)
        return {vars = {self.config.copies}}
    end,
    pos = coordinate(6),
	can_use = function(self)
        if G.hand and #G.hand.highlighted == 1 then
            local highlighted_card = G.hand.highlighted[1]
            return (highlighted_card:is_suit('bunc_Fleurons') or highlighted_card:is_suit('bunc_Halberds')) and Showdown.is_counterpart(highlighted_card)
        end
        return false
    end,
    use = function(self, card, area, copier)
		G.E_MANAGER:add_event(Event({
            func = function()
                local _first_dissolve = nil
                local new_cards = {}
                for _ = 1, self.config.copies do
                    G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                    local _card = copy_card(G.hand.highlighted[1], nil, nil, G.playing_card)
                    _card:add_to_deck()
                    G.deck.config.card_limit = G.deck.config.card_limit + 1
                    table.insert(G.playing_cards, _card)
                    G.hand:emplace(_card)
                    _card:start_materialize(nil, _first_dissolve)
                    _first_dissolve = true
                    new_cards[#new_cards+1] = _card
                end
                playing_card_joker_effects(new_cards)
                return true
            end
        }))
    end
}

return {
	enabled = (SMODS.Mods["MoreFluff"] or {}).can_load and Showdown.config["CrossMod"]["MoreFluff"],
	list = function ()
		local list = {}
		if Showdown.config["Ranks"] then
			table.insert(list, rot_reflection)
			table.insert(list, rot_vessel)
			if (SMODS.Mods["Bunco"] or {}).can_load and Showdown.config["CrossMod"]["Bunco"] then
				table.insert(list, rot_beast)
			end
		end
		if Showdown.config["Consumables"]["Mathematics"] then
			table.insert(list, rot_genie)
		end
		if Showdown.config["Enhancements"] then
			table.insert(list, rot_lost)
			table.insert(list, rot_angel)
			table.insert(list, rot_guard)
		end
		if Showdown.config["Consumables"]["Logics"] then
			table.insert(list, rot_inventor)
		end
		return list
	end,
	atlases = {
        {key = "showdown_rotarots", path = "CrossMod/MoreFluff/Consumables/Rotarots.png", px = 107, py = 107, atlas_table = "ASSET_ATLAS",}
	},
}