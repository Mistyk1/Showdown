local consumable_type = {
	type = 'ConsumableType',
    key = 'Mathematic',
    primary_colour = G.C.SHOWDOWN_CALCULUS,
    secondary_colour = G.C.SHOWDOWN_CALCULUS_DARK,
    collection_rows = {4, 4},
	--select_card = function(card, pack)
		--
	--end,
}

local undiscovered_sprite = {
	type = 'UndiscoveredSprite',
    key = 'Mathematic',
    atlas = 'showdown_mathematic_undiscovered',
    pos = coordinate(1)
}

local constant = {
	type = 'Consumable',
	order = 1,
	key = 'constant',
	set = 'Mathematic',
	atlas = 'showdown_mathematic',
    pos = coordinate(1),
	config = {max_highlighted = 1},
    loc_vars = function(self, info_queue, card)
		return { key = self.config.max_highlighted > 1 and 'c_showdown_constant_multiple' or 'c_showdown_constant', vars = {self.config.max_highlighted} }
	end,
	can_use = function(self, card, area, copier)
        return G.hand and (#G.hand.highlighted <= self.config.max_highlighted and #G.hand.highlighted > 0) and #G.hand.cards >= 2
    end,
    use = function(self, card, area, copier)
		local ranks = {}
		local cards = {}
		for _, _card in pairs(G.hand.highlighted) do
			table.insert(cards, _card)
		end
		for _, _card in pairs(cards) do
			local rank = _card:get_id()
			if findInTable(rank, ranks) == -1 then
				table.insert(ranks, rank)
				print(rank)
			end
		end
		local toEnhance = {}
		for i=1, #G.hand.cards do
			local _card = G.hand.cards[i]
			if
				findInTable(_card, cards) == -1
				and findInTable(_card:get_id(), ranks) ~= -1
				--and _card.ability.effect == "Base"
			then
				toEnhance[#toEnhance+1] = _card
				print(_card:get_id())
			end
		end
		for _, _card in pairs(cards) do
			event({trigger = 'after', delay = 0.1, func = function() math_destroy_card(_card) return true end })
		end
        delay(0.2)
		for i=1, #toEnhance do flipCard(toEnhance[i], i, #toEnhance) end
        delay(0.2)
		local cen_pool = getEnhancements()
		local cen_pool_zero = getEnhancements({"m_wild"})
		for i=1, #toEnhance do
            event({trigger = 'after', delay = 0.1, func = function()
				toEnhance[i]:set_ability(pseudorandom_element(SMODS.is_zero(toEnhance[i]) and cen_pool_zero or cen_pool, pseudoseed('spe_card')), true)
            return true end })
        end
		for i=1, #toEnhance do unflipCard(toEnhance[i], i, #toEnhance) end
    end
}

local variable = {
	type = 'Consumable',
	order = 2,
	key = 'variable',
	set = 'Mathematic',
	atlas = 'showdown_mathematic',
    pos = coordinate(2),
	config = {max_highlighted = 3, minMoney = 0, maxMoney = 5},
    loc_vars = function(self, info_queue, card) return {vars = {self.config.max_highlighted, self.config.minMoney, self.config.maxMoney}} end,
	can_use = function(self, card, area, copier)
        return #G.hand.highlighted >= 1 and (#G.hand.highlighted <= self.config.max_highlighted and #G.hand.highlighted > 0)
    end,
    use = function(self, card, area, copier)
		local money = 0
		for i = #G.hand.highlighted, 1, -1 do
            event({trigger = 'after', delay = 0.1, func = function()
				math_destroy_card(G.hand.highlighted[i], {nil, i == #G.hand.highlighted})
			return true end })
			money = money + math.random(self.config.minMoney, self.config.maxMoney)
        end
		delay(0.6)
		if money > 0 then ease_dollars(money) end
    end
}

local func = {
	type = 'Consumable',
	order = 3,
	key = 'function',
	set = 'Mathematic',
	atlas = 'showdown_mathematic',
    pos = coordinate(3),
	config = { max_highlighted = 4, toDestroy = 1 },
    loc_vars = function(self, info_queue, card) return { vars = {self.config.max_highlighted, self.config.toDestroy} } end,
	can_use = function(self, card, area, copier)
        return G.hand and (#G.hand.highlighted <= self.config.max_highlighted and #G.hand.highlighted > 0)
    end,
    use = function(self, card, area, copier)
		local cards = {}
		for i, _card in ipairs(G.hand.highlighted) do
			table.insert(cards, _card)
			flipCard(_card, i, #G.hand.highlighted)
		end
		for _ = 1, self.config.toDestroy do
            event({trigger = 'after', delay = 0.1, func = function()
				local _card = pseudorandom_element(cards, pseudoseed('showdown_mathematic'))
				if math_destroy_card(_card) then
					table.remove(G.hand.highlighted, findInTable(_card, G.hand.highlighted))
					table.remove(cards, findInTable(_card, cards))
				end
            return true end })
        end
        delay(0.2)
		local cen_pool = getEnhancements()
		local cen_pool_zero = getEnhancements({"m_wild"})
		for _, _card in pairs(cards) do
            event({trigger = 'after', delay = 0.1, func = function()
				_card:set_ability(pseudorandom_element(SMODS.is_zero(_card) and cen_pool_zero or cen_pool, pseudoseed('showdown_mathematic')), true);
            return true end })
        end
		for i, _card in ipairs(cards) do unflipCard(_card, i, #cards) end
		event({trigger = 'after', delay = 0.2, func = function()
            G.hand:unhighlight_all();
        return true end })
        delay(0.5)
    end
}

local shape = {
	type = 'Consumable',
	order = 4,
	key = 'shape',
	set = 'Mathematic',
	atlas = 'showdown_mathematic',
    pos = coordinate(4),
	config = {max_highlighted = 4},
    loc_vars = function(self, info_queue, card) return { vars = {self.config.max_highlighted} } end,
	can_use = function(self, card, area, copier)
        return G.hand and (#G.hand.highlighted <= self.config.max_highlighted and #G.hand.highlighted > 0)
    end,
    use = function(self, card, area, copier)
		local cards = {}
		for _, _card in ipairs(G.hand.highlighted) do
			table.insert(cards, _card)
		end
		for i = 1, #cards / 2 do
            event({trigger = 'after', delay = 0.1, func = function()
				local _card = pseudorandom_element(cards, pseudoseed('seed'))
				if math_destroy_card(_card, {silent = i == 1}) then
					table.remove(cards, findInTable(_card, cards))
					table.remove(G.hand.highlighted, findInTable(_card, G.hand.highlighted))
				end
            return true end })
        end
        delay(0.2)
		for _, _card in ipairs(cards) do
            event({trigger = 'after', delay = 0.1, func = function()
				local edition = poll_edition(nil, nil, nil, true)
				_card:set_edition(edition, true)
            return true end })
        end
		event({trigger = 'after', delay = 0.2, func = function()
            G.hand:unhighlight_all();
        return true end })
        delay(0.5)
    end
}

local vector = {
	type = 'Consumable',
	order = 5,
	key = 'vector',
	set = 'Mathematic',
	atlas = 'showdown_mathematic',
    pos = coordinate(5),
	config = {max_highlighted = 2},
    loc_vars = function(self, info_queue, card) return {vars = {self.config.max_highlighted, (G.GAME and G.GAME.showdown_vector or 0)}} end,
	can_use = function(self, card, area, copier)
        if G.hand and #G.hand.highlighted <= self.config.max_highlighted and #G.hand.highlighted >= 1 then
            return true
        end
        return false
    end,
    use = function()
		G.GAME.showdown_vector = (G.GAME.showdown_vector or 0) + #G.hand.highlighted
		for i=#G.hand.highlighted, 1, -1 do
            event({trigger = 'after', delay = 0.1, func = function() math_destroy_card(G.hand.highlighted[i], {nil, i == #G.hand.highlighted}) return true end })
        end
    end
}

local function joker_probability_compat(jonkler)
	if not jonkler then return false end
	return true
end

local probability = {
	type = 'Consumable',
	order = 6,
	key = 'probability',
	set = 'Mathematic',
	atlas = 'showdown_mathematic',
    pos = coordinate(6),
	config = {max_highlighted = 3, mult_joker = 1.25, extra = { initial_odds = 2, odds = 5 }},
    loc_vars = function(self, info_queue, card)
		return { vars = {self.config.max_highlighted, self.config.mult_joker, G.GAME.probabilities.normal * self.config.extra.initial_odds, self.config.extra.odds} }
	end,
	can_use = function(self, card, area, copier)
        if G.hand and #G.hand.highlighted <= self.config.max_highlighted and #G.hand.highlighted >= 1 and #G.jokers.cards >= 1 then
            return joker_probability_compat(G.jokers.cards[1])
        end
        return false
    end,
    use = function(self, card, area, copier)
		local first_dissolved = true
		local joker = G.jokers.cards[1]
		for i=#G.hand.highlighted, 1, -1 do
            event({trigger = 'after', delay = 0.1, func = function()
				if G.hand.highlighted ~= nil and SMODS.pseudorandom_probability(card, 'showdown_probability', self.config.extra.initial_odds, card.ability.extra.odds) then
                	if math_destroy_card(G.hand.highlighted[i], {nil, first_dissolved}) then first_dissolved = false end
					for k, v in pairs(joker.ability) do
						if
							(type(v) == "number" or type(v) == "table")
							and not (k == "id")
							and not (k == "colour")
							and not (k == "suit_nominal")
							and not (k == "base_nominal")
							and not (k == "face_nominal")
							and not (k == "qty")
							and not ((k == "x_mult" or k == "Xmult") and v == 1 and not joker.ability.override_x_mult_check)
							and not (k == "selected_d6_face")
							and not (k == "x")
							and not (k == "y")
						then
							if type(v) == "table" then
								for kk, vv in pairs(v) do
									if type(vv) == "number" then
										v[kk] = tonumber(('%%.%dg'):format(2.11):format(vv * card.ability.mult_joker))
									end
								end
							elseif not ((k == "x_mult" or k == "Xmult") and v == 1) then joker.ability[k] = tonumber(('%%.%dg'):format(2.11):format(v * card.ability.mult_joker)) end
						end
					end
				end
            return true end })
        end
    end,
	generate_ui = function(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
		SMODS.Consumable.super.generate_ui(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
		--[[ if G.GAME and card.area and (card.area == G.consumeables or (card.area == G.pack_cards and G.GAME.used_vouchers['v_showdown_axiom'])) then
			local jonkler_compat = joker_probability_compat(G.jokers.cards[1])
			desc_nodes[#desc_nodes+1] = {
				{n=G.UIT.C, config={align = "bm", minh = 0.4}, nodes={
					{n=G.UIT.C, config={ref_table = self, align = "m", colour = jonkler_compat and G.C.GREEN or G.C.RED, r = 0.05, padding = 0.06}, nodes={
						{n=G.UIT.T, config={text = ' '..localize(jonkler_compat and 'k_compatible' or 'k_incompatible')..' ',colour = G.C.UI.TEXT_LIGHT, scale = 0.32*0.9}},
					}}
				}}
			}
		end ]]
	end,
}

local sequence = {
	type = 'Consumable',
	order = 7,
	key = 'sequence',
	set = 'Mathematic',
	atlas = 'showdown_mathematic',
    pos = coordinate(7),
	config = {max_highlighted = 3, extra = { levels = 3 }},
    loc_vars = function(self, info_queue, card) return {vars = {self.config.extra.levels}} end,
	can_use = function()
        if G.hand and #G.hand.highlighted <= 5 and #G.hand.highlighted >= 1 then
            return true
        end
        return false
    end,
    use = function(self, card, area, copier)
		local text, disp_text = G.FUNCS.get_poker_hand_info(G.hand.highlighted)
		local used_consumable = copier or card
		update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(text, 'poker_hands'),chips = G.GAME.hands[text].chips, mult = G.GAME.hands[text].mult, level=G.GAME.hands[text].level})
		level_up_hand(used_consumable, text, nil, self.config.extra.levels)
		update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
		for i=#G.hand.highlighted, 1, -1 do
            event({trigger = 'after', delay = 0.1, func = function()
                if G.hand.highlighted ~= nil then math_destroy_card(G.hand.highlighted[i], {nil, i == 1}); end
            return true end })
        end
    end
}

local operation = {
	type = 'Consumable',
	order = 8,
	key = 'operation',
	set = 'Mathematic',
	atlas = 'showdown_mathematic',
    pos = coordinate(8),
	config = {max_highlighted = 2},
    loc_vars = function(self, info_queue, card) return {vars = {self.config.max_highlighted}} end,
	can_use = function()
        if G.hand and #G.hand.highlighted == 2 then
            return true
        end
        return false
    end,
    use = function(self, card, area, copier)
		local card1 = G.hand.highlighted[1]
		local card2 = G.hand.highlighted[2]
		event({trigger = 'after', delay = 0.1, func = function()
			math_destroy_card(card1, {nil, true})
			math_destroy_card(card2)
		return true end })
		delay(0.2)
		event({trigger = 'after', delay = 0.7, func = function()
			local function randomValue(value1, value2, notValue)
				if value1 == notValue then return value2
				elseif value2 == notValue then return value1
				elseif SMODS.pseudorandom_probability(card, 'showdown_Probability', 1, 2) then
					return value1
				else
					return value2
				end
			end
			local cardValues1 = {
				enhancement = next(SMODS.get_enhancements(card1)),
				edition = card1.edition,
				seal = card1.seal
			}
			local cardValues2 = {
				enhancement = next(SMODS.get_enhancements(card2)),
				edition = card2.edition,
				seal = card2.seal
			}

			local edition = randomValue(cardValues1.edition, cardValues2.edition)
			local seal = randomValue(cardValues1.seal, cardValues2.seal)
			local enhancement = randomValue(cardValues1.enhancement, cardValues2.enhancement)
			local stickers = {}
			for _, v in ipairs(SMODS.Sticker.obj_buffer) do
                if card1.ability[v] or card2.ability[v] then
                    table.insert(stickers, v)
                    break
                end
            end
			if edition and seal and enhancement and #stickers > 0 then
				check_for_unlock({type = 'who_am_i'})
			end

			local _card = SMODS.create_card({ set = 'Base', no_edition = true, edition = edition, enhancement = enhancement, seal = seal })
			for _, v in ipairs(stickers) do
				_card:add_sticker(v, true)
			end
			SMODS.add_to_deck(_card, G.hand)
		return true end })
    end
}

return {
	enabled = Showdown.config["Consumables"]["Mathematics"],
	list = function ()
		local list = {
			consumable_type,
			undiscovered_sprite,
			constant,
			variable,
			func,
			shape,
			vector,
			probability,
			sequence,
			operation,
		}
		return list
	end,
	atlases = {
		{key = 'showdown_mathematic_undiscovered', path = 'Consumables/MathematicsUndiscovered.png', px = 71, py = 95},
		{key = 'showdown_mathematic', path = 'Consumables/Mathematics.png', px = 71, py = 95},
	},
	exec = function()
		function math_destroy_card(card, args)
			if not card then return end
			if not args then args = {} end
			card:start_dissolve(args.dissolve_colours, args.silent, args.dissolve_time_fac, args.no_juice)
		end
	end,
}