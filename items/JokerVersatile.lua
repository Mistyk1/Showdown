local versatile_joker = {
    type = 'Joker',
    key = 'versatile_joker',
    atlas = "showdown_versatile_joker",
    pos = coordinate(1),
    config = { sprite = {x = 0, y = 0, blueprint = false}, extra = {
        money = 1,                                  -- Red Deck
        xmult_mod = 0.1,                             -- Blue Deck
        xchips = 1.5,                                -- Black Deck
        fool_copy = 1,                               -- Magic Deck
        planet = 1,                                  -- Nebula Deck
        non_face_retrigger = 1,                      -- Abandoned Deck
        hearts = 20, spades = 1.5, spades_odd = 2,    -- Checkered Deck
        generate_odd = 4,                            -- Zodiac Deck
        double_tag = 1,                              -- Anaglyph Deck
        extra_card = 1,                              -- Cheater Deck
    }},
    loc_vars = function(self, info_queue, card)
        if G.STAGE == G.STAGES.RUN then
            local loc = { key = get_versatile('desc') }
            if G.GAME.selected_back.name == 'Red Deck' then
                loc.vars = { card.ability.extra.money }
            elseif G.GAME.selected_back.name == 'Blue Deck' then
                loc.vars = { card.ability.extra.xmult_mod, card.ability.x_mult }
            elseif G.GAME.selected_back.name == 'Black Deck' then
                loc.vars = { card.ability.extra.xchips }
            elseif G.GAME.selected_back.name == 'Magic Deck' then
                loc.vars = { card.ability.extra.fool_copy }
            elseif G.GAME.selected_back.name == 'Nebula Deck' then
                loc.vars = { card.ability.extra.planet }
            elseif G.GAME.selected_back.name == 'Abandoned Deck' then
                loc.vars = { card.ability.extra.non_face_retrigger }
            elseif G.GAME.selected_back.name == 'Checkered Deck' then
                loc.vars = { card.ability.extra.hearts, card.ability.extra.spades, G.GAME.probabilities.normal, card.ability.extra.spades_odd }
            elseif G.GAME.selected_back.name == 'Zodiac Deck' then
                loc.vars = { G.GAME.probabilities.normal, card.ability.extra.generate_odd }
            elseif G.GAME.selected_back.name == 'Anaglyph Deck' then
                loc.vars = { card.ability.extra.double_tag }
            elseif G.GAME.selected_back.name == 'Cheater Deck' then
                loc.vars = { card.ability.extra.extra_card }
            end
            return loc
        end
        return { key = 'j_showdown_versatile_joker' }
    end,
    rarity = 2, cost = 6,
    blueprint_compat = false, perishable_compat = true, eternal_compat = true,
    unlocked = false,
    unlock_condition = {type = 'win_stake', stake = 4},
    calculate = function(self, card, context)
        if get_versatile('effect') then return get_versatile('effect')(self, card, context) end
    end,
    add_to_deck = function(self, card, from_debuff)
        if get_versatile('add_to_deck') then return get_versatile('add_to_deck')(self, card, from_debuff) end
        if not G.PROFILES[G.SETTINGS.profile].versatility then G.PROFILES[G.SETTINGS.profile].versatility = {} end
        if not findInTable(G.GAME.selected_back.name, G.PROFILES[G.SETTINGS.profile].versatility) then
            table.insert(G.PROFILES[G.SETTINGS.profile].versatility, G.GAME.selected_back.name)
        end
        check_versatility()
    end,
    remove_from_deck = function(self, card, from_debuff)
        if get_versatile('remove_from_deck') then return get_versatile('remove_from_deck')(self, card, from_debuff) end
    end,
    update = function(self, card, front)
        if G.STAGE == G.STAGES.RUN then
            local pos, blueprint = get_versatile('pos'), get_versatile('blueprint')
            if not (card.ability.sprite.x == pos.x and card.ability.sprite.y == pos.y) or not card.ability.sprite.blueprint == blueprint then
                card.ability.sprite.x = pos.x
                card.ability.sprite.y = pos.y
                card.ability.blueprint = blueprint
                card.config.center.pos = pos
                card.config.center.blueprint_compat = blueprint
                card:set_sprites(card.config.center)
            end
        elseif card.config.center.pos ~= coordinate(1) or card.config.center.blueprint_compat ~= false then
            card.config.center.pos = coordinate(1)
            card.config.center.blueprint_compat = false
            card:set_sprites(card.config.center)
        end
    end,
    load = function(self, card, card_table, other_card)
        card.config.center.pos = get_versatile('pos')
        card.config.center.blueprint_compat = get_versatile('blueprint')
        card:set_sprites(card.config.center)
    end
}

return {
	enabled = Showdown.config["Jokers"]["Versatile"],
	list = function ()
		local list = {
			versatile_joker,
		}
		return list
	end,
	atlases = {
		{key = "showdown_versatile_joker", path = "Jokers/VersatileJoker.png", px = 71, py = 95},
	},
	exec = function ()
		Showdown.versatile['Unknown'] = { desc = 'j_showdown_versatile_joker_unknown', pos = coordinate(1), blueprint = true }
        Showdown.versatile['Red Deck'] = { desc = 'j_showdown_versatile_joker_red', pos = coordinate(2), blueprint = false, effect = function(self, card, context)
            if context.discard and context.other_card == context.full_hand[1] then
                ease_dollars(card.ability.extra.money)
                return {
                    message = localize('$')..card.ability.extra.money,
                    colour = G.C.MONEY,
                    delay = 0.45,
                    card = card
                }
            end
        end }
        Showdown.versatile['Blue Deck'] = { desc = 'j_showdown_versatile_joker_blue', pos = coordinate(3), blueprint = true, effect = function(self, card, context)
            if not context.blueprint and context.cardarea == G.jokers and context.before then
                card.ability.x_mult = card.ability.x_mult + card.ability.extra.xmult_mod
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.MULT,
                    card = card
                }
            end
        end }
        Showdown.versatile['Yellow Deck'] = { desc = 'j_showdown_versatile_joker_yellow', pos = coordinate(4), blueprint = false, effect = function(self, card, context)
            if not context.blueprint and context.cash_out then
                card.ability.extra_value = card.ability.extra_value + context.interest
                card:set_cost()
                forced_message(localize('k_val_up'), card, nil, true)
            end
        end }
        Showdown.versatile['Green Deck'] = { desc = 'j_showdown_versatile_joker_green', pos = coordinate(5), blueprint = false, add_to_deck = function(self, card, from_debuff)
            G.GAME.interest_amount = G.GAME.interest_amount + 1
            G.GAME.modifiers.no_interest = false
        end, remove_from_deck = function(self, card, from_debuff)
            G.GAME.interest_amount = G.GAME.interest_amount - 1
            G.GAME.modifiers.no_interest = true
        end }
        Showdown.versatile['Black Deck'] = { desc = 'j_showdown_versatile_joker_black', pos = coordinate(6), blueprint = true, effect = function(self, card, context)
            if context.other_joker and (context.other_joker.config.center.rarity == 1 or context.other_joker.config.center.rarity == 3) and card ~= context.other_joker then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        context.other_joker:juice_up(0.5, 0.5)
                        return true
                    end
                }))
                return {
                    xchips = card.ability.extra.xchips
                }
            end
        end }
        Showdown.versatile['Magic Deck'] = { desc = 'j_showdown_versatile_joker_magic', pos = coordinate(7), blueprint = true, effect = function(self, card, context)
            if context.using_fool then
                for _=1, card.ability.extra.fool_copy do
                    if G.consumeables.config.card_limit > #G.consumeables.cards then
                        local _card = create_card('Tarot_Planet', G.consumeables, nil, nil, nil, nil, context.created_card.config.center_key, 'fool')
                        _card:add_to_deck()
                        G.consumeables:emplace(_card)
                    end
                end
            end
        end, add_to_deck = function(self, card, from_debuff)
            G.E_MANAGER:add_event(Event({func = function()
                G.consumeables.config.card_limit = G.consumeables.config.card_limit + 1
            return true end }))
        end, remove_from_deck = function(self, card, from_debuff)
            G.E_MANAGER:add_event(Event({func = function()
                G.consumeables.config.card_limit = G.consumeables.config.card_limit - 1
            return true end }))
        end }
        Showdown.versatile['Nebula Deck'] = { desc = 'j_showdown_versatile_joker_nebula', pos = coordinate(8), blueprint = false }
        Showdown.versatile['Ghost Deck'] = { desc = 'j_showdown_versatile_joker_ghost', pos = coordinate(9), blueprint = false, add_to_deck = function(self, card, from_debuff)
            G.E_MANAGER:add_event(Event({func = function()
                for k, v in pairs(G.I.CARD) do
                    if v.set_cost then v:set_cost() end
                end
            return true end }))
        end, remove_from_deck = function(self, card, from_debuff)
            G.E_MANAGER:add_event(Event({func = function()
                for k, v in pairs(G.I.CARD) do
                    if v.set_cost then v:set_cost() end
                end
            return true end }))
        end }
        Showdown.versatile['Abandoned Deck'] = { desc = 'j_showdown_versatile_joker_abandoned', pos = coordinate(10), blueprint = true, effect = function(self, card, context)
            if context.repetition and context.cardarea == G.play and not context.other_card:is_face() then
                return {
                    message = localize('k_again_ex'),
                    repetitions = card.ability.extra.non_face_retrigger,
                    card = card
                }
            end
        end }
        Showdown.versatile['Checkered Deck'] = { desc = 'j_showdown_versatile_joker_checkered', pos = coordinate(11), blueprint = true, effect = function(self, card, context)
            if context.individual and context.cardarea == G.play then
                if context.other_card:is_suit("Spades") and pseudorandom('versatile_checkered') < G.GAME.probabilities.normal/card.ability.extra.spades_odd then
                    return {
                        x_chips = card.ability.extra.spades,
                        card = card
                    }
                end
                if context.other_card:is_suit("Hearts") then
                    return {
                        mult = card.ability.extra.hearts,
                        card = card
                    }
                end
            end
        end }
        Showdown.versatile['Zodiac Deck'] = { desc = 'j_showdown_versatile_joker_zodiac', pos = coordinate(12), blueprint = true, effect = function(self, card, context)
            if
                context.using_consumeable
                and (context.consumeable.ability.set == "Tarot" or context.consumeable.ability.set == "Planet")
                and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit
                and pseudorandom('versatile_zodiac') < G.GAME.probabilities.normal/card.ability.extra.generate_odd
            then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                local loc = { card = card }
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.0,
                    func = (function()
                            local _card = create_card('Tarot_Planet',G.consumeables, nil, nil, nil, nil, nil, 'versatile_zodiac')
                            _card:add_to_deck()
                            G.consumeables:emplace(_card)
                            G.GAME.consumeable_buffer = 0
                            if _card.ability.set == 'Tarot' then
                                loc.message = localize('k_plus_tarot')
                            elseif _card.ability.set == 'Planet' then
                                loc.message = localize('k_plus_planet')
                            end
                        return true
                    end)}))
                return loc
            end
        end }
        Showdown.versatile['Painted Deck'] = { desc = 'j_showdown_versatile_joker_painted', pos = coordinate(13), blueprint = false, add_to_deck = function(self, card, from_debuff)
            G.jokers.config.card_limit = G.jokers.config.card_limit + 2
        end, remove_from_deck = function(self, card, from_debuff)
            G.jokers.config.card_limit = G.jokers.config.card_limit - 2
        end }
        Showdown.versatile['Anaglyph Deck'] = { desc = 'j_showdown_versatile_joker_anaglyph', pos = coordinate(14), blueprint = false }
        Showdown.versatile['Plasma Deck'] = { desc = 'j_showdown_versatile_joker_plasma', pos = coordinate(15), blueprint = false }
        Showdown.versatile['Erratic Deck'] = { desc = 'j_showdown_versatile_joker_erratic', pos = coordinate(16), blueprint = true, effect = function(self, card, context)
            if context.end_of_round and not context.repetition and not context.individual then
                local ranks, suits = {}, {}
                for _, _card in ipairs(G.playing_cards) do
                    if not ranks[_card.base.value] then ranks[_card.base.value] = 1
                    else ranks[_card.base.value] = ranks[_card.base.value] + 1 end
                    if not suits[_card.base.suit] then suits[_card.base.suit] = 1
                    else suits[_card.base.suit] = suits[_card.base.suit] + 1 end
                end
                local finalRank, finalRankNB = 'Ace', 0
                for k, v in pairs(ranks) do if v > finalRankNB then
                    finalRank = k
                    finalRankNB = v
                end end
                local finalSuit, finalSuitNB = 'Spades', 0
                for k, v in pairs(suits) do if v > finalSuitNB then
                    finalSuit = k
                    finalSuitNB = v
                end end
                local created_card = get_card_from_rank_suit(finalRank, finalSuit)
                if created_card then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                            local _card = Card(G.play.T.x + G.play.T.w/2, G.play.T.y, G.CARD_W, G.CARD_H, created_card, G.P_CENTERS.c_base, {playing_card = G.playing_card})
                            _card:start_materialize({G.C.SECONDARY_SET.Enhanced})
                            G.play:emplace(_card)
                            table.insert(G.playing_cards, _card)
                            return true
                    end}))
                    delay(0.6)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.deck.config.card_limit = G.deck.config.card_limit + 1
                            return true
                    end}))
                    draw_card(G.play,G.deck, 90,'up', nil)
                    playing_card_joker_effects({true})
                    delay(0.2)
                end
            end
        end }
        Showdown.versatile['Challenge Deck'] = { desc = 'j_showdown_versatile_joker_challenge', pos = coordinate(17), blueprint = false, add_to_deck = function(self, card, from_debuff)
            ease_hands_played(1)
            ease_discard(1)
        end, remove_from_deck = function(self, card, from_debuff)
            ease_hands_played(-1)
            ease_discard(-1)
        end }
        Showdown.versatile['Mirror Deck'] = { desc = 'j_showdown_versatile_joker_mirror', pos = coordinate(18), blueprint = false, effect = function(self, card, context)
            if context.before and not context.blueprint then
                local hazZero = false
                for i=1, #context.scoring_hand do
                    hazZero = hazZero or SMODS.is_zero(context.scoring_hand[i])
                end
                local enhancements = {}
                for _, v in ipairs(G.hand.cards) do
                    if (v.config.center ~= G.P_CENTERS.c_base and (hazZero and v.config.center ~= G.P_CENTERS.m_wild or not hazZero)) and not findInTable(v.config.center, enhancements) then
                        table.insert(enhancements, v.config.center)
                    end
                end
                if #enhancements > 0 then
                    for i=1, #context.scoring_hand do
                        local _card = context.scoring_hand[i]
                        if _card.config.center == G.P_CENTERS.c_base and not _card.debuff then
                            _card:set_ability(pseudorandom_element(enhancements, pseudoseed('versatile_mirror')), nil, true)
                        end
                    end
                end
            end
        end }
        Showdown.versatile['Calculus Deck'] = { desc = 'j_showdown_versatile_joker_calculus', pos = coordinate(19), blueprint = true, effect = function(self, card, context)
            if context.using_consumeable and context.consumeable.ability.set == 'Mathematic' then
                G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                local _card = copy_card(pseudorandom_element(G.hand.cards, pseudoseed('versatile_calculus')), nil, nil, G.playing_card)
                _card:add_to_deck()
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                table.insert(G.playing_cards, _card)
                G.hand:emplace(_card)
                _card:start_materialize()
                playing_card_joker_effects({_card})
            end
        end }
        Showdown.versatile['Starter Deck'] = { desc = 'j_showdown_versatile_joker_starter', pos = coordinate(20), blueprint = false }
        Showdown.versatile['Cheater Deck'] = { desc = 'j_showdown_versatile_joker_cheater', pos = coordinate(21), blueprint = false }

        ---Get deck specifications for Versatile Joker
        ---@param type string
        ---@return string | table | boolean | function
        function get_versatile(type)
            local name = G.GAME.selected_back.name
            if Showdown.versatile[name] then
                return Showdown.versatile[name][type]
            end
            return Showdown.versatile['Unknown'][type]
        end

        ---Unlock the Versatility achievement if Versatile Joker has been played on every deck at least once
        function check_versatility()
            local versatile = true
            for k, _ in pairs(Showdown.versatile) do
                versatile = versatile and G.PROFILES[G.SETTINGS.profile].versatility[k]
            end
            if versatile then check_for_unlock({type = 'versatility'}) end
        end

        local add_tagRef = add_tag
        function add_tag(_tag)
            add_tagRef(_tag)
            local versatile = find_joker('versatile_joker')
            if _tag.key == 'tag_double' and #versatile > 0 and G.GAME.selected_back.name == 'Anaglyph Deck' then
                local bonusTag = 0
                for i=1, #versatile do
                    bonusTag = bonusTag + find_joker('versatile_joker')[i].ability.extra.double_tag
                end
                if bonusTag >= 1 then for j=1, bonusTag do add_tagRef(Tag('tag_double')) end end
            end
        end
	end,
}