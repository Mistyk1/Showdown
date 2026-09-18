local cronch = {type = 'Sound', key = "cronch", path = "cronch.ogg"}
local mado_no1 = {type = 'Sound', key = "mado_no1", path = "madotsuki/no1.ogg"}
local mado_no2 = {type = 'Sound', key = "mado_no2", path = "madotsuki/no2.ogg"}
local uro_no1 = {type = 'Sound', key = "uro_no1", path = "urotsuki/no1.ogg"}
local uro_no2 = {type = 'Sound', key = "uro_no2", path = "urotsuki/no2.ogg"}
local uro_no3 = {type = 'Sound', key = "uro_no3", path = "urotsuki/no3.ogg"}
local minna_no = {type = 'Sound', key = "minna_no", path = "minnatsuki/no.ogg"}
local blinking = {type = 'Sound', key = "blinking", path = "beep.ogg"}

---- Final Rarity

local final = {
    type = 'Rarity',
    key = "final",
    default_weight = 0,
    badge_colour = HEX("b5a653"),
    get_weight = function(self, weight, object_type)
        return weight
    end,
}

---- Jokers

local crouton = {
    type = 'Joker',
    order = 1,
    key = 'crouton',
    name = 'crouton',
	atlas = "showdown_jokers",
    pos = coordinate(2), soul_pos = coordinate(3),
    config = {extra = {x_mult = 1.5}},
    loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.x_mult } }
	end,
    rarity = 4, cost = 20,
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    unlocked = false,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round then
            return {
                x_mult = card.ability.extra.x_mult,
                card = card
            }
        end
    end
}

local pinpoint = {
    type = 'Joker',
    order = 2,
    activated = { Showdown.config["Ranks"] },
    key = 'pinpoint',
    name = 'pinpoint',
	atlas = "showdown_jokers",
	pos = coordinate(4),
    config = {extra = {x_chips = 1.5}},
    loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.x_chips } }
	end,
    rarity = 3, cost = 8,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
	unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == 'hand_contents' then
            local zero = 0
            for j = 1, #args.cards do
                if SMODS.is_zero(args.cards[j]) then
                    zero = zero + 1
                end
            end
            if zero >= 5 then
                unlock_card(self)
            end
        end
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and context.full_hand and not context.other_card.debuff and SMODS.is_zero(context.other_card) then
            return {
                x_chips = card.ability.extra.x_chips,
                card = context.other_card
            }
        end
    end
}

local math_teacher = {
    type = 'Joker',
    order = 3,
    activated = { Showdown.config["Ranks"] },
    key = 'math_teacher',
    name = 'math_teacher',
	atlas = "showdown_jokers",
	pos = coordinate(5),
    config = {extra = {chips = 0, chip_mod = 2.5}},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {set = 'Other', key = 'counterpart_ranks'}
		return { vars = { card.ability.extra.chips, card.ability.extra.chip_mod } }
	end,
    rarity = 1, cost = 4,
    blueprint_compat = true, perishable_compat = false, eternal_compat = true,
    unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == 'hand_contents' then
            local eval = evaluate_poker_hand(args.cards)
            if next(eval['Three of a Kind']) then
                local counterpart = 0
                for j = 1, #args.cards do
                    if SMODS.is_counterpart(args.cards[j]) then counterpart = counterpart + 1 end
                end
                if counterpart >= 3 then unlock_card(self) end
            end
        end
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and SMODS.is_counterpart(context.other_card) and not context.blueprint then
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
            forced_message(localize('k_upgrade_ex'), card, G.C.CHIPS, true)
        end
		if context.joker_main and card.ability.extra.chips > 0 then
			return {
				message = localize({ type = "variable", key = "a_chips", vars = { card.ability.extra.chips } }),
				chip_mod = card.ability.extra.chips,
			}
		end
    end
}

local gruyere = {
    type = 'Joker',
    order = 4,
    activated = { Showdown.config["Ranks"] },
    key = 'gruyere',
    name = 'gruyere',
	atlas = "showdown_jokers",
	pos = coordinate(6),
    config = {extra = {mult = 0, mult_mod = 2}},
    loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult, card.ability.extra.mult_mod } }
	end,
    rarity = 1, cost = 4,
    blueprint_compat = true, perishable_compat = false, eternal_compat = true,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and SMODS.is_zero(context.other_card) and not context.blueprint then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
            forced_message(localize('k_upgrade_ex'), card, G.C.MULT, true)
        end
		if context.joker_main and card.ability.extra.mult > 0 then
			return {
				message = localize({ type = "variable", key = "a_mult", vars = { card.ability.extra.mult } }),
				mult_mod = card.ability.extra.mult,
			}
		end
    end
}

local mirror = {
    type = 'Joker',
    order = 5,
    activated = { Showdown.config["Ranks"] },
    key = 'mirror',
    name = 'mirror',
	atlas = "showdown_jokers",
	pos = coordinate(7),
    config = {extra = {retrigger = 1}},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {set = 'Other', key = 'counterpart_ranks'}
	end,
    rarity = 2, cost = 6,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if context.repetition then
            print(context.other_card.base.value..": "..context.other_card:get_id())
			if SMODS.is_zero(context.other_card) or SMODS.is_counterpart(context.other_card) then
				return {
					message = localize("k_again_ex"),
					repetitions = card.ability.extra.retrigger,
					card = card
				}
			end
		end
    end
}

local crime_scene = {
    type = 'Joker',
    order = 6,
    key = 'crime_scene',
    name = 'crime_scene',
    atlas = "showdown_jokers",
    pos = coordinate(8),
    config = {extra = {x_mult = 1, x_mult_mod = 0.25}},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_mult, card.ability.extra.x_mult_mod } }
    end,
    rarity = 3, cost = 8,
    blueprint_compat = true, perishable_compat = false, eternal_compat = true,
    unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == 'hand_contents' then
            local all_debuffed = true
            for _, card in ipairs(args.cards) do
                all_debuffed = all_debuffed and card.debuff
            end
            if all_debuffed and #args.cards >= 5 then
                unlock_card(self)
            end
        end
    end,
    calculate = function(self, card, context)
        if context.debuffed_card and not context.blueprint then
            card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_mult_mod
            forced_message(localize('k_upgrade_ex'), card, G.C.XMULT, true)
        end
        if context.joker_main and card.ability.extra.x_mult ~= 1 then
            return {
                x_mult = card.ability.extra.x_mult,
            }
        end
    end
}

local ping_pong = {
    type = 'Joker',
    order = 7,
    key = 'ping_pong',
    name = 'ping_pong',
    atlas = "showdown_jokers",
    pos = coordinate(9),
    rarity = 2, cost = 6,
    blueprint_compat = false, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.after and not context.blueprint_card and not context.blueprint and not context.retrigger_joker then
            for i=1, #context.scoring_hand do
                local _card = context.scoring_hand[i]
                if _card:get_id() == 7 or _card:get_id() == 14 then
                    flipCard(_card, i, #context.scoring_hand)
                    delay(0.2)
                    if _card:get_id() == 7 then
                        event({trigger = 'after', delay = 0.15, func = function() assert(SMODS.change_base(_card, nil, 'Ace')); return true end})
                    else
                        event({trigger = 'after', delay = 0.15, func = function() assert(SMODS.change_base(_card, nil, '7')); return true end})
                    end
                    unflipCard(_card, i, #context.scoring_hand)
                    delay(0.2)
                end
            end
        end
    end
}

local color_splash = {
    type = 'Joker',
    order = 8,
    key = 'color_splash',
    name = 'color_splash',
    atlas = "showdown_jokers",
    pos = coordinate(10),
    rarity = 2, cost = 6,
    blueprint_compat = false, perishable_compat = true, eternal_compat = true,
    unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == 'hand_contents' then
            local _, _, _, scoring_hand, _ = G.FUNCS.get_poker_hand_info(args.cards)
            local suits = {}
            for i = 1, #args.cards do
                if findInTable(args.cards[i], scoring_hand) == -1 and findInTable(args.cards[i].base.suit, suits) == -1 then
                    table.insert(suits, args.cards[i].base.suit)
                end
            end
            if #suits >= 4 then unlock_card(self) end
        end
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.after and not context.blueprint_card and not context.blueprint and not context.retrigger_joker then
            local suits = get_all_suits()
            for i=1, #G.play.cards do
                local _card = G.play.cards[i]
                if _card:get_id() ~= 1 and findInTable(_card, context.scoring_hand) == -1 then
                    flipCard(_card, i, #G.play.cards)
                    delay(0.2)
                    event({trigger = 'after', delay = 0.15, func = function()
                        assert(SMODS.change_base(_card, suits[math.random(#suits)], nil))
                    return true end})
                    unflipCard(_card, i, #G.play.cards)
                    delay(0.6)
                end
            end
        end
    end
}

local blue = {
    type = 'Joker',
    order = 9,
    key = 'blue',
    name = 'blue',
    atlas = "showdown_jokers",
    pos = coordinate(11),
    rarity = 1, cost = 1,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == 'chip_score' then
            if
                (type(args.chips) == 'number' and args.chips < 10)
                or (type(args.chips) == 'table' and args.chips.array[1] < 10)
            then
                unlock_card(self)
            end
        end
    end,
    calculate = function(self, card, context)
        if context.joker_main then
			return {
				message = localize({ type = "variable", key = "a_chips", vars = { 1 } }),
				chip_mod = 1,
			}
		end
    end,
    add_to_deck = function(self, card, from_debuff)
        check_for_unlock({type = 'blued'})
    end,
}

local spotted_joker = {
    type = 'Joker',
    order = 10,
    activated = { Showdown.config["Ranks"] },
    key = 'spotted_joker',
    name = 'spotted_joker',
	atlas = "showdown_jokers",
	pos = coordinate(12),
    config = {extra = {chips = 0, chip_mod = 0.5}},
    loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.chips, card.ability.extra.chip_mod } }
	end,
    rarity = 1, cost = 4,
    blueprint_compat = true, perishable_compat = false, eternal_compat = true,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and SMODS.is_zero(context.other_card) then
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
            return {
                chips = card.ability.extra.chips
            }
        end
    end
}

local golden_roulette = {
    type = 'Joker',
    order = 11,
    key = 'golden_roulette',
    name = 'golden_roulette',
    atlas = "showdown_jokers",
    pos = coordinate(13),
    config = {extra = {money = 6}},
    loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.money } }
	end,
    rarity = 2, cost = 7,
    blueprint_compat = true, perishable_compat = true, eternal_compat = false,
    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual then
            if not context.blueprint and SMODS.pseudorandom_probability(card, 'golden_roulette', 1, 6) then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('tarot1')
                        card.T.r = -0.2
                        card:juice_up(0.3, 0.4)
                        card.states.drag.is = true
                        card.children.center.pinch.x = true
                        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                            func = function()
                                    card:remove()
                                    card = nil
                                return true; end})) 
                        return true
                    end
                }))
                return {
                    message = localize('k_BAM'),
                    destroyed = true
                }
            else
                ease_dollars(card.ability.extra.money)
                return {
                    message = localize('$')..card.ability.extra.money,
                    colour = G.C.MONEY,
                    delay = 0.45,
                    card = card
                }
            end
		end
    end
}

local bacteria = {
    type = 'Joker',
    order = 12,
    activated = { Showdown.config["Ranks"] },
    key = 'bacteria',
    name = 'bacteria',
    atlas = "showdown_jokers",
    pos = coordinate(14),
    rarity = 1, cost = 4,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.after and not context.blueprint_card and not context.retrigger_joker then
            local eval = evaluate_poker_hand(context.scoring_hand)
            if next(eval['Flush']) then
                local notZeros = {}
                for i=1, #context.scoring_hand do
                    local _card = context.scoring_hand[i]
                    if _card:get_id() ~= 1 then table.insert(notZeros, _card) end
                end
                if #notZeros > 0 and #notZeros < #context.scoring_hand then
                    local _card = notZeros[math.random(#notZeros)]
                    flipCard(_card, nil, #context.scoring_hand)
                    delay(0.2)
                    event({trigger = 'after', delay = 0.15, func = function() assert(SMODS.change_base(_card, nil, 'showdown_Zero')); return true end})
                    unflipCard(_card, nil, #context.scoring_hand)
                    delay(0.6)
                end
            end
        end
    end
}

local empty_joker = {
    type = 'Joker',
    order = 13,
    activated = { Showdown.config["Ranks"] },
    key = 'empty_joker',
    name = 'empty_joker',
    atlas = "showdown_jokers",
    pos = coordinate(15),
    config = {extra = {mult = 12}},
    loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult } }
	end,
    rarity = 1, cost = 4,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if context.joker_main then
            for i=1, #context.scoring_hand do
                if SMODS.is_zero(context.scoring_hand[i]) then
                    return {
                        message = localize({ type = "variable", key = "a_mult", vars = { card.ability.extra.mult } }),
                        mult_mod = card.ability.extra.mult,
                    }
                end
            end
        end
    end
}

local baby_jimbo = { -- Doesn't work properly for self-destroying cards like Gros Michel
    type = 'Joker',
    order = 14,
    key = 'baby_jimbo',
    name = 'baby_jimbo',
    atlas = "showdown_jokers",
    pos = coordinate(16),
    config = {extra = {sold = false}},
    rarity = 2, cost = 6,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if
            context.removing_card
            and not card.ability.extra.sold
            and context.removed_card
            and context.removed_card ~= card
            and context.removed_card.ability.set == 'Joker'
            and context.removed_card.area == G.jokers
        then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.0,
                func = function()
                    local _card = SMODS.create_card({set = 'Spectral', area = G.consumeables, edition = {negative = true}})
                    _card:add_to_deck()
                    G.consumeables:emplace(_card)
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
                    return true
                end
            }))
            return {
                message = localize('k_plus_spectral'),
                colour = G.C.SECONDARY_SET.Spectral,
                card = card
            }
        elseif context.selling_card and context.card ~= card then
            card.ability.extra.sold = true
        elseif context.post_removing then
            card.ability.extra.sold = false
        end
    end
}

local parmesan = {
    type = 'Joker',
    order = 15,
    key = 'parmesan',
    name = 'parmesan',
    atlas = "showdown_jokers",
    pos = coordinate(17),
    rarity = 2, cost = 6,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.repetition then
            local lowestRank = 11
            for i=1, #context.scoring_hand do
                if context.scoring_hand[i].base.nominal < lowestRank then
                    lowestRank = context.scoring_hand[i].base.nominal
                end
            end
            if lowestRank > 0 then
                context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus or 0
                context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus + lowestRank
                return {
                    extra = {message = localize('k_upgrade_ex'), colour = G.C.CHIPS},
                    colour = G.C.CHIPS,
                    card = card
                }
            end
        end
    end
}

local chaos_card = {
    type = 'Joker',
    order = 16,
    key = 'chaos_card',
    name = 'chaos_card',
    atlas = "showdown_jokers",
    pos = coordinate(18),
    rarity = 3, cost = 8,
    blueprint_compat = false, perishable_compat = true, eternal_compat = true,
    unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == 'hand_contents' then
            local hands = G.GAME.chaos_card_hands
            local eval = evaluate_poker_hand(args.cards)
            hands.flush = hands.flush or next(eval['Flush'])
            hands.straight = hands.straight or next(eval['Straight'])
            hands.five = hands.five or next(eval['Five of a Kind'])
            if hands.flush and hands.straight and hands.five then unlock_card(self) end
        elseif args.type == 'round_win' then
            local hands = G.GAME.chaos_card_hands
            hands.flush = false
            hands.straight = false
            hands.five = false
        end
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.after and not context.blueprint_card and not context.blueprint and not context.retrigger_joker then
            local suits = get_all_suits()
            local ranks = get_all_ranks()
            local total_ranks = {}
            for i=1, #context.scoring_hand do
                local _card = context.scoring_hand[i]
                flipCard(_card, i, #context.scoring_hand)
                delay(0.2)
                event({trigger = 'after', delay = 0.15, func = function()
                    assert(SMODS.change_base(_card, suits[math.random(#suits)], ranks[math.random(#ranks)]))
                    total_ranks[_card.base.name] = (total_ranks[_card.base.name] or 0) + 1
                return true end})
                unflipCard(_card, i, #context.scoring_hand)
                delay(0.6)
            end
            event({trigger = 'after', delay = 0.15, func = function()
                for _, i in pairs(total_ranks) do
                    if i >= 3 then
                        check_for_unlock({type = 'never_tell_odds'})
                    end
                end
            return true end})
        end
    end
}

local sim_card = {
    type = 'Joker',
    order = 17,
    activated = { Showdown.config["Ranks"] },
    key = 'sim_card',
    name = 'sim_card',
    atlas = "showdown_jokers",
    pos = coordinate(19),
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {set = 'Other', key = 'counterpart_ranks'}
	end,
    rarity = 3, cost = 8,
    blueprint_compat = false, perishable_compat = true, eternal_compat = true,
    add_to_deck = function(self, card, from_debuff)
        if next(find_joker('hiding_details')) then check_for_unlock({type = 'everything_flush'}) end
    end,
}

local one_doller = {
    type = 'Joker',
    order = 19,
    key = 'one_doller',
    name = 'one_doller',
    atlas = "showdown_jokers",
    pos = coordinate(21),
    config = {extra = {money = 1}},
    loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.money } }
	end,
    rarity = 1, cost = 1,
    blueprint_compat = false, perishable_compat = false, eternal_compat = true,
    unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == 'buying_card' then
            if args.price <= 0 then unlock_card(self) end
        end
    end,
    calculate = function(self, card, context)
        if context.buying_card or context.open_booster and not context.blueprint then
            ease_dollars(card.ability.extra.money)
            return {
                message = localize('$')..card.ability.extra.money,
                colour = G.C.MONEY,
                delay = 0.45,
                card = card
            }
        end
    end
}

local revolution = {
    type = 'Joker',
    order = 20,
    key = 'revolution',
    name = 'revolution',
    atlas = "showdown_jokers",
    pos = coordinate(22),
    rarity = 2, cost = 6,
    blueprint_compat = false, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.after and not context.blueprint_card and not context.blueprint and not context.retrigger_joker and not next(find_joker('Pareidolia')) then
            local ranks = get_all_ranks({noFace = true})
            for i=1, #context.scoring_hand do
                local _card = context.scoring_hand[i]
                if _card:is_face() then
                    flipCard(_card, i, #context.scoring_hand)
                    delay(0.2)
                    event({trigger = 'after', delay = 0.15, func = function()
                        assert(SMODS.change_base(_card, nil, ranks[math.random(#ranks)]))
                    return true end})
                    unflipCard(_card, i, #context.scoring_hand)
                    delay(0.6)
                end
            end
        end
    end
}

local fruit_sticker = {
    type = 'Joker',
    order = 21,
    key = 'fruit_sticker',
    name = 'fruit_sticker',
    atlas = "showdown_jokers",
    pos = coordinate(23),
    config = {extra = {x_mult = 1.75}},
    loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.x_mult } }
	end,
    rarity = 3, cost = 8,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    unlocked = false,
    check_for_unlock = function(self, args)
        if G.STAGE == G.STAGES.RUN and G.jokers then
            local allStickers = {}
            for i, joker in ipairs(G.jokers.cards) do
                for key, value in pairs(joker.ability) do
                    if SMODS.Sticker.obj_table[key] and value then allStickers[i] = true break end
                end
            end
            local sticker = #allStickers == G.jokers.config.card_limit
            if sticker then
                for i=1, #allStickers do
                    sticker = sticker and allStickers[i]
                end
                if sticker then unlock_card(self) end
            end
        end
    end,
    calculate = function(self, card, context)
        if context.other_card and context.ability then
            if type(context.ability.value) ~= 'table' and SMODS.Sticker.obj_table[context.ability.key] and context.ability.value then
                return {
                    x_mult = card.ability.extra.x_mult,
                    card = context.other_card
                }
            end
        end
    end
}

local sinful_joker = {
    type = 'Joker',
    order = 22,
    key = 'sinful_joker',
    name = 'sinful_joker',
    atlas = "showdown_jokers",
    pos = coordinate(24),
    config = {extra = {scaling = 3}},
    loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.scaling } }
	end,
    rarity = 3, cost = 8,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    unlocked = false,
    check_for_unlock = function(self, args)
        if next(find_joker('Greedy Joker')) and next(find_joker('Lusty Joker')) and next(find_joker('Wrathful Joker')) and next(find_joker('Gluttonous Joker')) then
            unlock_card(self)
        end
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.before then
            local jokers = {}
            for i=1, #G.jokers.cards do
                local name = G.jokers.cards[i].ability.name
                if name == 'Greedy Joker' or name == 'Lusty Joker' or name == 'Wrathful Joker' or name == 'Gluttonous Joker' then
                    table.insert(jokers, G.jokers.cards[i])
                end
            end
            for i=1, #jokers do
                jokers[i].ability.extra.s_mult = jokers[i].ability.extra.s_mult + card.ability.extra.scaling
            end
            if #jokers > 0 then
                return {
                    message = localize('k_upgrade_ex')
                }
            end
        end
    end
}

local egg_drawing = {
    type = 'Joker',
    order = 23,
    key = 'egg_drawing',
    name = 'egg_drawing',
    atlas = "showdown_jokers",
    pos = coordinate(25),
    config = {extra = {money = 4}},
    loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.money } }
	end,
    rarity = 1, cost = 5,
    blueprint_compat = false, perishable_compat = true, eternal_compat = true,
    unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == 'selling_card' then
            if args.sell_cost > 10 then unlock_card(self) end
        end
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not context.repetition and not context.individual then
            local joker = pseudorandom_element(G.jokers.cards, pseudoseed('egg_drawing'))
            joker.ability.extra_value = joker.ability.extra_value + card.ability.extra.money
            joker:set_cost()
            return {
                message = localize('k_val_up'),
                colour = G.C.MONEY,
                card = joker
            }
        end
    end
}

local jimbo_makeup = {
    type = 'Joker',
    order = 24,
    activated = { Showdown.config["Jokers"]["Final"] },
    key = 'jimbo_makeup',
    name = 'jimbo_makeup',
    atlas = "showdown_jokers",
    pos = coordinate(26),
    rarity = 3, cost = 2,
    blueprint_compat = false, perishable_compat = false, eternal_compat = false,
}

local jimbo_hat = {
    type = 'Joker',
    order = 25,
    activated = { Showdown.config["Jokers"]["Final"] },
    key = 'jimbo_hat',
    name = 'jimbo_hat',
    atlas = "showdown_jokers",
    pos = coordinate(27),
    rarity = 3, cost = 2,
    blueprint_compat = false, perishable_compat = false, eternal_compat = false,
}

local jimbo_bells = {
    type = 'Joker',
    order = 26,
    activated = { Showdown.config["Jokers"]["Final"] },
    key = 'jimbo_bells',
    name = 'jimbo_bells',
    atlas = "showdown_jokers",
    pos = coordinate(28),
    rarity = 3, cost = 2,
    blueprint_compat = false, perishable_compat = false, eternal_compat = false,
}

local jimbo_collar = {
    type = 'Joker',
    order = 27,
    activated = { Showdown.config["Jokers"]["Final"] },
    key = 'jimbo_collar',
    name = 'jimbo_collar',
    atlas = "showdown_jokers",
    pos = coordinate(29),
    rarity = 3, cost = 2,
    blueprint_compat = false, perishable_compat = false, eternal_compat = false,
}

local gary_mccready = {
    type = 'Joker',
    order = 28,
    activated = { Showdown.config["Jokers"]["Final"] },
    key = 'gary_mccready',
    name = 'gary_mccready',
    atlas = "showdown_jokers",
    pos = coordinate(30),
    config = {extra = {created = false}},
    rarity = 3, cost = 4,
    blueprint_compat = false, perishable_compat = false, eternal_compat = false,
    calculate = function(self, card, context)
        if not context.blueprint and not card.ability.extra.created then
            local makeup, hat, bells, collar = find_joker('jimbo_makeup'), find_joker('jimbo_hat'), find_joker('jimbo_bells'), find_joker('jimbo_collar')
            if next(makeup) and next(hat) and next(bells) and next(collar) then
                card.ability.extra.created = true
                if not G.GAME.won then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'immediate',
                        blocking = false,
                        blockable = false,
                        func = (function()
                            win_game()
                            check_for_unlock({type = 'win_ultimate'})
                            G.GAME.won = true
                            return true
                        end)
                    }))
                end
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.2,
                    func = function()
                        local jokers = {card, makeup[1], hat[1], bells[1], collar[1]}
                        for i=1, #jokers do
                            jokers[i]:start_dissolve(nil, i == #jokers)
                        end
                        local _card = SMODS.create_card({set = 'Joker', area = G.jokers, key = 'j_showdown_ultimate_joker', no_edition = true})
                        _card:add_to_deck()
                        G.jokers:emplace(_card)
                        return true
                    end
                }))
            end
        end
    end
}

local ultimate_joker = {
    type = 'Joker',
    order = 29,
    activated = { Showdown.config["Jokers"]["Final"] },
    key = 'ultimate_joker',
    name = 'ultimate_joker',
    atlas = "showdown_jokers",
    pos = coordinate(31),
    loc_vars = function(self, info_queue, card)
		return { vars = { G.GAME.round } }
	end,
    rarity = 'showdown_final', cost = 20,
    in_pool = function(self, args) return false end,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if context.joker_main and G.GAME.round > 1 then
            return {
                message = localize{type='variable',key='a_xmult',vars={G.GAME.round}},
                Xmult_mod = G.GAME.round,
                x_chips = G.GAME.round,
                colour = G.C.PURPLE,
                card = card
            }
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        check_for_unlock({type = 'jimbodia'})
    end,
}

local strainer = {
    type = 'Joker',
    order = 30,
    activated = { Showdown.config["Ranks"] },
    key = 'strainer',
    name = 'strainer',
    atlas = "showdown_jokers",
    pos = coordinate(32),
    config = {extra = {money = 0, moneyRequirement = 10, boss_shop = false}},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {set = 'Other', key = 'counterpart_ranks'}
        if card.ability.extra.boss_shop then
            return { key = "j_showdown_strainer_active", vars = { card.ability.extra.moneyRequirement, card.ability.extra.money } }
        else
            return { key = "j_showdown_strainer", vars = { card.ability.extra.moneyRequirement } }
        end
	end,
    rarity = 2, cost = 7,
    blueprint_compat = false, perishable_compat = true, eternal_compat = false,
    calculate = function(self, card, context)
        if not context.blueprint then
            if G.GAME and G.GAME.blind and G.GAME.blind.boss then
                card.ability.extra.boss_shop = true
            end
            if card.ability.extra.boss_shop then
                if context.buying_card or context.open_booster then
                    card.ability.extra.money = card.ability.extra.money + math.max(context.card.cost, 0)
                elseif context.reroll_shop then
                    card.ability.extra.money = card.ability.extra.money + math.max(G.GAME.current_round.reroll_cost-1, 0)
                elseif context.ending_shop and card.ability.extra.money >= 10 then
                    local ranks = get_all_ranks({onlyCounterpart = true, noFace = true, whitelist = {"showdown_Zero"}})
                    local suits = get_all_suits()
                    local created_cards = 0
                    while card.ability.extra.money >= card.ability.extra.moneyRequirement do
                        local rank = pseudorandom_element(ranks, pseudoseed('strainer'))
                        local suit = pseudorandom_element(suits, pseudoseed('strainer'))
                        if create_card_in_deck(rank, suit) then
                            card.ability.extra.money = card.ability.extra.money - card.ability.extra.moneyRequirement
                            created_cards = created_cards + 1
                            if created_cards >= 20 then
                                check_for_unlock({type = 'whole_new_deck'})
                            end
                        end
                    end
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            play_sound('tarot1')
                            card.T.r = -0.2
                            card:juice_up(0.3, 0.4)
                            card.states.drag.is = true
                            card.children.center.pinch.x = true
                            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                                func = function()
                                        G.jokers:remove_card(card)
                                        card:remove()
                                        card = nil
                                    return true; end}))
                            return true
                        end
                    }))
                    return {
                        message = localize('k_strainer_broke')
                    }
                end
            end
        end
    end
}

local billiard = {
    type = 'Joker',
    order = 31,
    activated = { Showdown.config["Ranks"] },
    key = 'billiard',
    name = 'billiard',
    atlas = "showdown_jokers",
    pos = coordinate(33),
    rarity = 2, cost = 6,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if context.scoring_hand and context.other_card and context.cardarea == G.play then
            local idx = findInTable(context.other_card, G.play.cards)
            if idx > -1 then
                local rep = 0
                if idx > 1 and SMODS.is_zero(G.play.cards[idx-1]) then
                    rep = rep + 1
                end
                if idx < #G.play.cards and SMODS.is_zero(G.play.cards[idx+1]) then
                    rep = rep + 1
                end
                if rep > 0 then
                    return {
                        repetitions = rep,
                        card = context.other_card,
                    }
                end
            end
		end
    end
}

local hiding_details = {
    type = 'Joker',
    order = 32,
    activated = { Showdown.config["Ranks"] },
    key = 'hiding_details',
    name = 'hiding_details',
    atlas = "showdown_jokers",
    pos = coordinate(34),
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {set = 'Other', key = 'counterpart_ranks'}
	end,
    rarity = 2, cost = 6,
    blueprint_compat = false, perishable_compat = true, eternal_compat = true,
    add_to_deck = function(self, card, from_debuff)
        if next(find_joker('sim_card')) then check_for_unlock({type = 'everything_flush'}) end
    end,
}

local what_a_steel = {
    type = 'Joker',
    order = 33,
    key = 'what_a_steel',
    name = 'what_a_steel',
    atlas = "showdown_jokers",
    pos = coordinate(35),
    display_size = { w = 61, h = 95 },
    pixel_size = { w = 61, h = 95 },
    config = {extra = { steel_tally = 0, cap = 20 }},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS['m_steel']
        return { vars = { card.ability.extra.steel_tally, card.ability.extra.cap } }
	end,
    rarity = 2, cost = 6,
    blueprint_compat = false, perishable_compat = true, eternal_compat = true,
    unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == 'playing_card_added' then
            if args.card.config.center == G.P_CENTERS.m_steel then
                unlock_card(self)
            end
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({func = function()
            for _, v in pairs(G.I.CARD) do
                if v.set_cost then v:set_cost() end
            end
        return true end }))
    end,
    add_to_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({func = function()
            for _, v in pairs(G.I.CARD) do
                if v.set_cost then v:set_cost() end
            end
        return true end }))
    end,
    update = function(self, card, dt)
        card.ability.extra.steel_tally = 0
        if G.playing_cards then
            for _, _card in pairs(G.playing_cards) do
                if SMODS.has_enhancement(_card, 'm_steel') and card.ability.extra.steel_tally < card.ability.extra.cap then card.ability.extra.steel_tally = card.ability.extra.steel_tally + 1 end
            end
        end
    end,
}

local diplomatic_immunity = {
    type = 'Joker',
    order = 34,
    key = 'diplomatic_immunity',
    name = 'diplomatic_immunity',
    atlas = "showdown_jokers",
    pos = coordinate(36),
    rarity = 2, cost = 6,
    blueprint_compat = false, perishable_compat = true, eternal_compat = true
}

local nitroglycerin = {
    type = 'Joker',
    order = 35,
    key = 'nitroglycerin',
    name = 'nitroglycerin',
    atlas = "showdown_jokers",
    pos = coordinate(37),
    rarity = 2, cost = 4,
    blueprint_compat = false, perishable_compat = false, eternal_compat = false,
    calculate = function(self, card, context)
        if context.selling_self and not context.blueprint and not G.booster_pack then
            for i=#G.hand.cards, 1, -1 do
                G.hand.cards[i]:start_dissolve(nil, i == #G.hand.cards)
            end
            if G.hand.config.card_limit <= 0 and #G.hand.cards == 0 then
                check_for_unlock({type = 'rico_kaboom'})
            end
        end
    end
}

local substitute_teacher = {
    type = 'Joker',
    order = 36,
    activated = { Showdown.config["Consumables"]["Mathematics"] },
    key = 'substitute_teacher',
    name = 'substitute_teacher',
    atlas = "showdown_jokers",
    pos = coordinate(38),
    config = {extra = {chips_scale = 4, mult_scale = 2}},
    loc_vars = function(self, info_queue, card)
        local mathUsed = G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.mathematic or 0
        return { vars = { card.ability.extra.chips_scale, card.ability.extra.mult_scale, mathUsed * card.ability.extra.chips_scale, mathUsed * card.ability.extra.mult_scale } }
	end,
    locked_loc_vars = function(self, info_queue, card)
        return { vars = { G.PROFILES[G.SETTINGS.profile].career_stats.c_maths_used or 0 } }
	end,
    rarity = 1, cost = 4,
    blueprint_compat = true, perishable_compat = false, eternal_compat = true,
    unlocked = false,
    check_for_unlock = function(self, args)
        if (G.PROFILES[G.SETTINGS.profile].career_stats.c_maths_used or 0) >= 20 then
            unlock_card(self)
        end
    end,
    calculate = function(self, card, context)
        local mathUsed = G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.mathematic or 0
        local chips_scale = mathUsed * card.ability.extra.chips_scale
        local mult_scale = mathUsed * card.ability.extra.mult_scale
        if context.using_consumeable and not context.blueprint and (context.consumeable.ability.set == "Mathematic") then
            G.E_MANAGER:add_event(Event({
                func = function() card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_chips_mult',vars={chips_scale, mult_scale}}}); return true
            end}))
        end
        if context.cardarea == G.jokers and context.joker_main and mathUsed > 0 then
            return {
                message = localize{type='variable',key='a_chips_mult',vars={chips_scale, mult_scale}},
                chip_mod = chips_scale,
                mult_mod = mult_scale,
            }
        end
    end
}

local world_map = {
    type = 'Joker',
    order = 37,
    activated = { Showdown.config["Ranks"] },
    key = 'world_map',
    name = 'world_map',
    atlas = "showdown_jokers",
    pos = coordinate(39),
    config = {extra = {chips_scale = 12.5, chips = 0}},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips_scale, card.ability.extra.chips } }
	end,
    rarity = 1, cost = 4,
    blueprint_compat = true, perishable_compat = false, eternal_compat = true,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers then
            if context.joker_main and card.ability.extra.chips > 0 then
                return {
                    message = localize{type='variable',key='a_chips',vars={card.ability.extra.chips}},
                    chip_mod = card.ability.extra.chips,
                    colour = G.C.CHIPS
                }
            elseif context.before and not context.blueprint then
                local eval = evaluate_poker_hand(context.scoring_hand)
                if next(eval['Flush']) then
                    local zero = false
                    for i=1, #context.scoring_hand do
                        local _card = context.scoring_hand[i]
                        if SMODS.is_zero(_card) then zero = true break end
                    end
                    if zero then
                        card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_scale
                        return {
                            message = localize('k_upgrade_ex'),
                            colour = G.C.CHIPS,
                            card = card
                        }
                    end
                end
            end
        end
    end
}

local bugged_seed = {
    type = 'Joker',
    order = 38,
    activated = { Showdown.config["Challenges"] },
    key = 'bugged_seed',
    name = 'bugged_seed',
    atlas = "showdown_jokers",
    pos = coordinate(40),
    rarity = 1, cost = 4,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == '7LB2WVPK' and self.unlocked == false then -- This is litteraly the unlock_card function without the challenge/seeded check
            if self.unlocked or self.wip then return end
            G:save_notify(self)
            self.unlocked = true
            if self.set == 'Back' then discover_card(self) end
            table.sort(G.P_CENTER_POOLS["Back"], function (a, b) return (a.order - (a.unlocked and 100 or 0)) < (b.order - (b.unlocked and 100 or 0)) end)
            G:save_progress()
            G.FILE_HANDLER.force = true
            notify_alert(self.key, self.set)
        end
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.after then
            local compatible_cards = {}
            for _, _card in ipairs(G.play.cards) do
                if not (_card.base.value == '10' and _card.base.suit == 'Spades') and not _card.ability.bugged_spade then
                    table.insert(compatible_cards, _card)
                end
            end
            if #compatible_cards > 0 then
                local _card = pseudorandom_element(compatible_cards, pseudoseed('bugged_seed'))
                _card.ability.bugged_spade = true
                flipCard(_card, nil, #G.play.cards)
                delay(0.2)
                event({trigger = 'after', delay = 0.15, func = function()
                    assert(SMODS.change_base(_card, 'Spades', '10'))
                    _card.ability.bugged_spade = nil
                return true end})
                unflipCard(_card, nil, #G.play.cards)
                delay(0.6)
            end
        end
    end
}

local sick_trick = {
    type = 'Joker',
    order = 39,
    key = 'sick_trick',
    name = 'sick_trick',
    atlas = "showdown_jokers",
    pos = coordinate(41),
    rarity = 2, cost = 6,
    blueprint_compat = false, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.after and not context.blueprint_card and not context.blueprint and not context.retrigger_joker and #context.scoring_hand > 1 then
            local idx = 1
            for i=2, #context.scoring_hand do
                if context.scoring_hand[i].base.nominal < context.scoring_hand[idx].base.nominal then idx = i end
            end
            if idx > 1 then
                flipCard(context.scoring_hand[idx], idx, #context.scoring_hand)
                flipCard(context.scoring_hand[idx-1], idx-1, #context.scoring_hand)
                delay(0.2)
                event({trigger = 'after', delay = 0.15, func = function()
                    copy_card(context.scoring_hand[idx], context.scoring_hand[idx-1])
                return true end})
                unflipCard(context.scoring_hand[idx], idx, #context.scoring_hand)
                unflipCard(context.scoring_hand[idx-1], idx-1, #context.scoring_hand)
                delay(0.6)
            end
        end
    end
}

local jaws = {
    type = 'Joker',
    order = 40,
    key = 'jaws',
    name = 'jaws',
    atlas = "showdown_jokers",
    pos = coordinate(42),
    config = {extra = {chips_scale = 2, chips = 0}},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips_scale, card.ability.extra.chips } }
	end,
    rarity = 1, cost = 4,
    blueprint_compat = true, perishable_compat = false, eternal_compat = true,
    unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == 'discard_custom' then
            local allFaces = #args.cards > 0
            for i=1, #args.cards do
                allFaces = allFaces and args.cards[i]:is_face()
            end
            if allFaces then unlock_card(self) end
        end
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main and card.ability.extra.chips > 0 then
            return {
                message = localize{type='variable',key='a_chips',vars={card.ability.extra.chips}},
                chip_mod = card.ability.extra.chips,
                colour = G.C.CHIPS
            }
        elseif not context.blueprint and context.discard and context.other_card:is_face() then
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_scale
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.CHIPS,
                card = card
            }
        end
    end
}

local locks = {
    type = 'Joker',
    order = 41,
    activated = { Showdown.config["Jokers"]["Final"] },
    key = '4_locks',
    name = '4_locks',
    atlas = "showdown_jokers",
    pos = coordinate(43),
    config = {extra = {locks = {false, false, false, false}, created = false}},
    loc_vars = function(self, info_queue, card)
        local locks = {'Locked', 'Locked', 'Locked', 'Locked'}
        for i=1, #card.ability.extra.locks do
            locks[i] = card.ability.extra.locks[i] and 'Unlocked' or 'Locked'
        end
        return { vars = locks }
	end,
    rarity = 3, cost = 8,
    blueprint_compat = false, perishable_compat = false, eternal_compat = false,
    unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == 'win_ultimate' then unlock_card(self) end
    end,
    calculate = function(self, card, context)
        if not context.blueprint and not card.ability.extra.created then
            local unlocked = true
            for i=1, #card.ability.extra.locks do
                unlocked = unlocked and card.ability.extra.locks[i]
            end
            if unlocked then
                card.ability.extra.created = true
                if not G.GAME.won then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'immediate',
                        blocking = false,
                        blockable = false,
                        func = (function()
                            win_game()
                            G.GAME.won = true
                            return true
                        end)
                    }))
                end
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.2,
                    func = function()
                        card:start_dissolve()
                        local _card = SMODS.create_card({set = 'Joker', area = G.jokers, key = 'j_showdown_unshackled_joker', no_edition = true})
                        _card:add_to_deck()
                        G.jokers:emplace(_card)
                        return true
                    end
                }))
            end
        end
    end
}

local unshackled_joker = {
    type = 'Joker',
    order = 42,
    activated = { Showdown.config["Jokers"]["Final"] },
    key = 'unshackled_joker',
    name = 'unshackled_joker',
    atlas = "showdown_jokers",
    pos = coordinate(44),
    rarity = 'showdown_final', cost = 20,
    in_pool = function(self, args) return false end,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if context.joker_main then
            local text = G.FUNCS.get_poker_hand_info(context.scoring_hand)
            if G.GAME.hands[text].level > 1 then
                return {
                    message = localize{type = 'variable', key = 'a_xmult', vars = {G.GAME.hands[text].level}},
                    Xmult_mod = G.GAME.hands[text].level
                }
            end
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        check_for_unlock({type = 'chains'})
    end,
}

local red_coins = {
    type = 'Joker',
    order = 43,
    key = 'red_coins',
    name = 'red_coins',
    atlas = "showdown_jokers",
    pos = coordinate(45),
    config = {extra = {money = 1}},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.money } }
	end,
    rarity = 1, cost = 4,
    blueprint_compat = false, perishable_compat = true, eternal_compat = true,
    add_to_deck = function(self, card, from_debuff)
        if next(find_joker('money_cutter')) then check_for_unlock({type = 'green_deck_home'}) end
    end,
}

local money_cutter = {
    type = 'Joker',
    order = 44,
    key = 'money_cutter',
    name = 'money_cutter',
    atlas = "showdown_jokers",
    pos = coordinate(46),
    config = {extra = {money = 1}},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.money } }
	end,
    rarity = 1, cost = 4,
    blueprint_compat = false, perishable_compat = true, eternal_compat = true,
    unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == 'interest' and (type(args.money) == 'number' and args.money or to_big(args.money)) >= 20 then unlock_card(self) end
    end,
    add_to_deck = function(self, card, from_debuff)
        if not from_debuff then G.GAME.modifiers.no_interest = true end
        if next(find_joker('red_coins')) then check_for_unlock({type = 'green_deck_home'}) end
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.modifiers.no_interest = next(find_joker('money_cutter')) ~= nil or G.GAME.selected_back.effect.config.no_interest
    end,
}

local passage_of_time = {
    type = 'Joker',
    order = 45,
    key = 'passage_of_time',
    name = 'passage_of_time',
    atlas = "showdown_jokers",
    pos = coordinate(47),
    config = {extra = {chips_mult = 0, scale = 2}},
    loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.scale, card.ability.extra.chips_mult } }
	end,
    rarity = 1, cost = 4,
    blueprint_compat = true, perishable_compat = false, eternal_compat = true,
    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not context.repetition and not context.individual then
            card.ability.extra.chips_mult = card.ability.extra.chips_mult + card.ability.extra.scale
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.PURPLE,
                card = card
            }
        elseif context.joker_main and card.ability.extra.chips_mult > 0 then
            return {
                message = '+'..card.ability.extra.chips_mult,
                chip_mod = card.ability.extra.chips_mult,
                mult_mod = card.ability.extra.chips_mult,
                colour = G.C.PURPLE,
                card = card
            }
        end
    end
}

local colored_glasses = {
    type = 'Joker',
    order = 46,
    key = 'colored_glasses',
    name = 'colored_glasses',
    atlas = "showdown_jokers",
    pos = coordinate(48),
    config = {extra = {mult_scale = 2, mult = 0}},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult_scale, card.ability.extra.mult } }
	end,
    rarity = 1, cost = 4,
    blueprint_compat = true, perishable_compat = false, eternal_compat = true,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main and card.ability.extra.mult > 0 then
            return {
                message = localize{type='variable',key='a_mult',vars={card.ability.extra.mult}},
                mult_mod = card.ability.extra.mult
            }
        elseif not context.blueprint and context.cardarea == G.jokers and context.before then
            local suits, wild, twoSuits = {}, 0, false
            for i=1, #G.play.cards do
                if SMODS.has_any_suit(G.play.cards[i]) then wild = wild + 1
                elseif findInTable(G.play.cards[i].base.suit, suits) == -1 then table.insert(suits, G.play.cards[i].base.suit) end
            end
            while wild >= 0 and not twoSuits do
                twoSuits = twoSuits or #suits + wild == 2
                wild = wild - 1
            end
            if twoSuits then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_scale
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.MULT,
                    card = card
                }
            end
        end
    end
}

local joker_variance_authorithy = {
    type = 'Joker',
    order = 47,
    key = 'joker_variance_authorithy',
    name = 'joker_variance_authorithy',
    atlas = "showdown_jokers",
    pos = coordinate(49),
    config = {extra = {mult = 0, mult_scale = 10}},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult_scale, card.ability.extra.mult } }
	end,
    rarity = 1, cost = 4,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main and card.ability.extra.mult > 0 then
            return {
                message = localize{type='variable',key='a_mult',vars={card.ability.extra.mult}},
                mult_mod = card.ability.extra.mult
            }
        elseif not context.blueprint and context.selling_card and context.card.ability.name == 'Joker' then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_scale
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.MULT,
                card = card
            }
        end
    end,
}

local banana = {
    type = 'Joker',
    order = 48,
    key = 'banana',
    name = 'banana',
    atlas = "showdown_banana",
    pos = { x = 0, y = 0 },
    display_size = { w = 35, h = 43 },
    config = {extra = {mult = 15, mult_scale = 5}},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult_scale, card.ability.extra.mult, G.GAME.probabilities.normal } }
	end,
    rarity = 2, cost = 6,
    blueprint_compat = true, perishable_compat = false, eternal_compat = true,
    unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == 'extinct' and args.name == 'Cavendish' then unlock_card(self) end
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not context.repetition and not context.individual then
            if SMODS.pseudorandom_probability(card, 'banana', 1, 2) then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_scale
                return {
                    message = localize('k_upgrade_ex')
                }
            else
                card.ability.extra.mult = card.ability.extra.mult - card.ability.extra.mult_scale
                if card.ability.extra.mult > 0 then
                    return {
                        message = localize('k_downgrade_ex')
                    }
                else
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            if Showdown.config["Technical"]["Easter Eggs"] then
                                play_sound('showdown_cronch')
                            end
                            card.T.r = -0.2
                            card:juice_up(0.3, 0.4)
                            card.states.drag.is = true
                            card.children.center.pinch.x = true
                            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                                func = function()
                                        G.jokers:remove_card(card)
                                        card:remove()
                                        card = nil
                                    return true; end}))
                            return true
                        end
                    }))
                    check_for_unlock({type = 'cronch'})
                    return {
                        message = localize('k_extinct_ex')
                    }
                end
            end
        elseif context.cardarea == G.jokers and context.joker_main then
            return {
                message = localize{type='variable',key='a_mult',vars={card.ability.extra.mult}},
                mult_mod = card.ability.extra.mult,
            }
        end
    end
}

local label = {
    type = 'Joker',
    order = 49,
    key = 'label',
    name = 'label',
    atlas = "showdown_jokers",
    pos = coordinate(50),
    config = {extra = {can_reroll = false}},
    rarity = 1, cost = 3,
    blueprint_compat = false, perishable_compat = false, eternal_compat = false,
    unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == 'tag_used' and (G.GAME.tag_used or 0) >= 12 then unlock_card(self) end
    end,
    calculate = function(self, card, context)
        if context.ending_shop then
            card.ability.extra.can_reroll =
                (not (G.GAME.round_resets.blind_states.Small == 'Defeated' or G.GAME.round_resets.blind_states.Small == 'Skipped' or G.GAME.round_resets.blind_states.Small == 'Hide'))
                or not (G.GAME.round_resets.blind_states.Big == 'Defeated' or G.GAME.round_resets.blind_states.Big == 'Skipped' or G.GAME.round_resets.blind_states.Big == 'Hide')
        elseif context.setting_blind and not card.getting_sliced then
            card.ability.extra.can_reroll = false
        elseif context.selling_self and not context.blueprint and card.ability.extra.can_reroll then
            if not (G.GAME.round_resets.blind_states.Small == 'Defeated' or G.GAME.round_resets.blind_states.Small == 'Skipped' or G.GAME.round_resets.blind_states.Small == 'Hide') then
                reroll_tags_and_blind('small')
            end
            if not (G.GAME.round_resets.blind_states.Big == 'Defeated' or G.GAME.round_resets.blind_states.Big == 'Skipped' or G.GAME.round_resets.blind_states.Big == 'Hide') then
                reroll_tags_and_blind('big')
            end
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        card.ability.extra.can_reroll =
            not from_debuff
            and ((not (G.GAME.round_resets.blind_states.Small == 'Defeated' or G.GAME.round_resets.blind_states.Small == 'Skipped' or G.GAME.round_resets.blind_states.Small == 'Hide'))
            or not (G.GAME.round_resets.blind_states.Big == 'Defeated' or G.GAME.round_resets.blind_states.Big == 'Skipped' or G.GAME.round_resets.blind_states.Big == 'Hide'))
            and G.STATE == G.STATES.BLIND_SELECT
    end,
    generate_ui = function(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
        SMODS.Joker.super.generate_ui(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
        if G.GAME and card and (card.area == G.jokers or card.area == G.rules_card_jokers) then
            desc_nodes[#desc_nodes+1] = {
                {n=G.UIT.C, config={align = "bm", minh = 0.4}, nodes={
                    {n=G.UIT.C, config={ref_table = self, align = "m", colour = card.ability.extra.can_reroll and G.C.GREEN or G.C.RED, r = 0.05, padding = 0.06}, nodes={
                        {n=G.UIT.T, config={text = ' '..localize(card.ability.extra.can_reroll and 'k_can_reroll' or 'k_cannot_reroll')..' ',colour = G.C.UI.TEXT_LIGHT, scale = 0.32*0.9}},
                    }}
                }}
            }
        end
    end,
}

local silver_stars = {
    type = 'Joker',
    order = 50,
    key = 'silver_stars',
    name = 'silver_stars',
    atlas = "showdown_jokers",
    pos = coordinate(51),
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS['j_showdown_gold_star']
	end,
    rarity = 2, cost = 6,
    blueprint_compat = false, perishable_compat = false, eternal_compat = false,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.before and not context.blueprint then
            local steel = 0
            for _, _card in ipairs(context.scoring_hand) do
                if _card.config.center == G.P_CENTERS.m_steel then
                    steel = steel + 1
                end
            end
            if steel >= 5 then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.2,
                    func = function()
                        card:start_dissolve()
                        local _card = SMODS.create_card({set = 'Joker', area = G.jokers, key = 'j_showdown_gold_star'})
                        _card:add_to_deck()
                        G.jokers:emplace(_card)
                        return true
                    end
                }))
            end
        end
    end,
}

local gold_star = {
    type = 'Joker',
    order = 51,
    key = 'gold_star',
    name = 'gold_star',
    atlas = "showdown_jokers",
    pos = coordinate(52),
    config = {extra = {xchips = 3}},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xchips } }
	end,
    rarity = 2, cost = 6,
    in_pool = function(self, args) return false end,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if context.joker_main and card.ability.extra.xchips ~= 1 then
            return {
                x_chips = card.ability.extra.xchips,
            }
        end
    end,
}

local shady_dealer = {
    type = 'Joker',
    order = 52,
    key = 'shady_dealer',
    name = 'shady_dealer',
    atlas = "showdown_jokers",
    pos = coordinate(53),
    config = {extra = {hands = 3, money = 0}},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.hands, card.ability.extra.money } }
	end,
    rarity = 1, cost = 4,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == 'money' and (type(G.GAME.dollars) == 'number' and G.GAME.dollars or to_big(G.GAME.dollars)) <= -20 then unlock_card(self) end
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not (context.blueprint_card or card).getting_sliced and G.GAME.dollars <= card.ability.extra.money then
            G.E_MANAGER:add_event(Event({func = function()
                ease_hands_played(card.ability.extra.hands)
                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_hands', vars = {card.ability.extra.hands}}})
            return true end }))
        end
    end,
}

local yipeee = {
    type = 'Joker',
    order = 53,
    key = 'yipeee',
    name = 'yipeee',
    atlas = "showdown_jokers",
    pos = coordinate(54),
    display_size = { w = 71, h = 71 },
    pixel_size = { w = 71, h = 71 },
    config = {extra = {sold = false}},
    rarity = 1, cost = 3,
    blueprint_compat = false, perishable_compat = false, eternal_compat = false,
    calculate = function(self, card, context)
        if context.selling_self and not context.blueprint then
            card.ability.extra.sold = true
        elseif context.removing_card and context.removed_card == card and card.ability.extra.sold and not context.blueprint then
            G.E_MANAGER:add_event(Event({
                func = (function()
                    if G.jokers and #G.jokers.cards < G.jokers.config.card_limit then
                        local _card = SMODS.create_card({set = 'Joker', area = G.jokers, key = 'j_popcorn'})
                        _card:add_to_deck()
                        G.jokers:emplace(_card)
                        if G.jokers and #G.jokers.cards < G.jokers.config.card_limit then
                            _card = SMODS.create_card({set = 'Joker', area = G.jokers, key = 'j_diet_cola'})
                            _card:add_to_deck()
                            G.jokers:emplace(_card)
                        end
                    end
                return true end)
            }))
        end
    end,
}

local dealer_luigi = {
    type = 'Joker',
    order = 54,
    activated = { Showdown.config["Stickers"] },
    key = 'dealer_luigi',
    name = 'dealer_luigi',
    atlas = "showdown_jokers",
    pos = coordinate(55),
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {set = 'Other', key = 'showdown_cloud'}
        info_queue[#info_queue+1] = {set = 'Other', key = 'showdown_mushroom'}
        info_queue[#info_queue+1] = {set = 'Other', key = 'showdown_flower'}
        info_queue[#info_queue+1] = {set = 'Other', key = 'showdown_luigi'}
        info_queue[#info_queue+1] = {set = 'Other', key = 'showdown_mario'}
        info_queue[#info_queue+1] = {set = 'Other', key = 'showdown_star'}
	end,
    rarity = 3, cost = 8,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual then
            local no_casino_stickers = {}
            for _, joker in ipairs(G.jokers.cards) do
                if not have_casino_sticker(joker) then table.insert(no_casino_stickers, joker) end
            end
            if #no_casino_stickers > 0 then
                local random_joker = pseudorandom_element(no_casino_stickers, pseudoseed('dealer_luigi'))
                play_sound("gold_seal", 1.2, 0.4)
				random_joker:juice_up(0.3, 0.3)
                pseudorandom_element(Showdown.casino, pseudoseed('dealer_luigi')):apply(random_joker, true, true)
            end
        end
    end,
}

local whatever = {
    type = 'Joker',
    order = 55,
    key = 'whatever',
    name = 'whatever',
    atlas = "showdown_jokers",
    pos = coordinate(56),
    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME.last_played_hand or localize('k_none') } }
	end,
    rarity = 2, cost = 6,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == 'upgrade_hand' and not SMODS.PokerHand.obj_table[args.hand].visible and args.level >= 15 then
            unlock_card(self)
        end
    end,
    calculate = function(self, card, context)
        if context.selling_self and not context.blueprint then
            update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(G.GAME.last_played_hand, 'poker_hands'),chips = G.GAME.hands[G.GAME.last_played_hand].chips, mult = G.GAME.hands[G.GAME.last_played_hand].mult, level=G.GAME.hands[G.GAME.last_played_hand].level})
            level_up_hand(nil, G.GAME.last_played_hand, nil, card.sell_cost)
            update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        if not from_debuff then
            card.base_cost = 4
            card:set_cost()
        end
    end,
}

local madotsuki = {
    type = 'Joker',
    order = 56,
    key = 'madotsuki',
    name = 'madotsuki',
    atlas = "showdown_jokers",
    pos = coordinate(57), soul_pos = coordinate(58),
    config = {extra = {edition_chance = 10}},
    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME.probabilities.normal, card.ability.extra.edition_chance } }
	end,
    rarity = 3, cost = 8,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.after then
            local no_editions = {}
            for i=1, #context.scoring_hand do
                local _card = context.scoring_hand[i]
                if not _card.edition then
                    table.insert(no_editions, _card)
                end
            end
            for _, _card in ipairs(no_editions) do
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    blocking = false,
                    blockable = false,
                    func = (function()
                        if SMODS.pseudorandom_probability(card, 'madotsuki', 1, card.ability.extra.edition_chance) then
                            local edition = poll_edition('madotsuki', nil, true, true)
                            if edition then _card:set_edition(edition)
                            else print('No edition was polled with Madotsuki') end
                            delay(0.6)
                        end
                    return true end)
                }))
            end
        end
    end,
}

local urotsuki = {
    type = 'Joker',
    order = 57,
    key = 'urotsuki',
    name = 'urotsuki',
    atlas = "showdown_jokers",
    pos = coordinate(59), soul_pos = coordinate(60),
    config = {extra = {x_chips_scale = 0.1, x_chips = 1}},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_chips_scale, card.ability.extra.x_chips } }
	end,
    rarity = 3, cost = 8,
    blueprint_compat = true, perishable_compat = false, eternal_compat = true,
    calculate = function(self, card, context)
        if context.buying_card and not context.blueprint then
            card.ability.extra.x_chips = card.ability.extra.x_chips + card.ability.extra.x_chips_scale
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.CHIPS,
                card = card
            }
        elseif context.cardarea == G.jokers and context.joker_main and card.ability.extra.x_chips ~= 1 then
            return {
                x_chips = card.ability.extra.x_chips
            }
        end
    end,
}

local minnatsuki = {
    type = 'Joker',
    order = 58,
    key = 'minnatsuki',
    name = 'minnatsuki',
    atlas = "showdown_jokers",
    pos = coordinate(61), soul_pos = coordinate(62),
    config = {extra = {mult_scale = 2, mult = 0}},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult_scale, card.ability.extra.mult } }
	end,
    rarity = 3, cost = 8,
    blueprint_compat = true, perishable_compat = false, eternal_compat = true,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.before and not context.blueprint then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_scale
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.MULT,
                card = card
            }
        elseif context.other_joker and card ~= context.other_joker then
            G.E_MANAGER:add_event(Event({
                func = function()
                    context.other_joker:juice_up(0.5, 0.5)
                    return true
                end
            }))
            return {
                message = localize{type='variable',key='a_mult',vars={card.ability.extra.mult}},
                mult_mod = card.ability.extra.mult,
                card = context.other_joker
            }
        end
    end,
}

local pop_up = {
    type = 'Joker',
    order = 59,
    key = 'pop_up',
    name = 'pop_up',
    atlas = "showdown_jokers",
    pos = coordinate(63),
    display_size = { w = 71, h = 71 },
    pixel_size = { w = 71, h = 71 },
    rarity = 1, cost = 4,
    blueprint_compat = false, perishable_compat = true, eternal_compat = true,
    --calculate = function(self, card, context) end,
}

local matplotlib = {
    type = 'Joker',
    order = 60,
    key = 'matplotlib',
    name = 'matplotlib',
    atlas = "showdown_jokers",
    pos = coordinate(64),
    config = {extra = {mult = 5, chips = 15}},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.chips } }
	end,
    rarity = 1, cost = 4,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if context.other_joker and card ~= context.other_joker then
            G.E_MANAGER:add_event(Event({
                func = function()
                    context.other_joker:juice_up(0.5, 0.5)
                    return true
                end
            }))
            if context.other_joker.rank < card.rank then
                return {
                    message = localize{type='variable',key='a_mult',vars={card.ability.extra.mult}},
                    mult_mod = card.ability.extra.mult
                }
            else
                return {
                    message = localize{type='variable',key='a_chips',vars={card.ability.extra.chips}},
                    chip_mod = card.ability.extra.chips
                }
            end
        end
    end,
}

local cake = {
    type = 'Joker',
    order = 61,
    activated = { Showdown.config["Ranks"] },
    key = 'cake',
    name = 'cake',
    atlas = "showdown_jokers",
    pos = coordinate(65),
    config = {extra = {mult = 0, mult_scale = 1.5}},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {set = 'Other', key = 'counterpart_ranks'}
        return { vars = { card.ability.extra.mult_scale, card.ability.extra.mult } }
	end,
    rarity = 1, cost = 4,
    blueprint_compat = true, perishable_compat = false, eternal_compat = true,
    calculate = function(self, card, context)
        if not context.blueprint and context.individual and context.cardarea == G.hand and context.full_hand then
            if SMODS.is_counterpart(context.other_card) then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_scale
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.MULT,
                    card = card
                }
            end
        elseif context.cardarea == G.jokers and context.joker_main and card.ability.extra.mult > 0 then
            return {
                message = localize{type='variable',key='a_mult',vars={card.ability.extra.mult}},
                mult_mod = card.ability.extra.mult
            }
        end
    end,
}

local window = {
    type = 'Joker',
    order = 62,
    key = 'window',
    name = 'window',
    atlas = "showdown_jokers",
    pos = coordinate(66),
    config = {extra = {mult = 0, mult_scale = 4}},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult_scale, card.ability.extra.mult } }
	end,
    rarity = 1, cost = 4,
    blueprint_compat = true, perishable_compat = false, eternal_compat = true,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.before and not context.blueprint then
            local eval = evaluate_poker_hand(context.scoring_hand)
            if next(eval['Four of a Kind']) then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_scale
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.MULT,
                    card = card
                }
            end
        elseif context.cardarea == G.jokers and context.joker_main and card.ability.extra.mult > 0 then
            return {
                message = localize{type='variable',key='a_mult',vars={card.ability.extra.mult}},
                mult_mod = card.ability.extra.mult
            }
        end
    end,
}

local break_the_ice = {
    type = 'Joker',
    order = 63,
    key = 'break_the_ice',
    name = 'break_the_ice',
    atlas = "showdown_jokers",
    pos = coordinate(67),
    config = {extra = {chips = 0, chips_scale = 75}},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_glass
        return { vars = { card.ability.extra.chips_scale, card.ability.extra.chips } }
	end,
    rarity = 2, cost = 6,
    blueprint_compat = true, perishable_compat = false, eternal_compat = true,
    calculate = function(self, card, context)
        if
            not context.blueprint
            and (
                context.cards_destroyed
                or context.remove_playing_cards
                or (context.using_consumeable and context.consumeable.ability.name == 'The Hanged Man')
            )
        then
            local glasses = 0
            if (context.using_consumeable and context.consumeable.ability.name == 'The Hanged Man') then
                for _, v in ipairs(G.hand.highlighted) do
                    if SMODS.has_enhancement(v, 'm_glass') then glasses = glasses + 1 end
                end
            else
                for _, v in ipairs(context.cards_destroyed and context.glass_shattered or context.remove_playing_cards and context.removed) do
                    if v.shattered then glasses = glasses + 1 end
                end
            end
            if glasses > 0 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_scale*glasses
                                return true
                            end
                        }))
                        card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_chips', vars = {card.ability.extra.chips + card.ability.extra.chips_scale*glasses}}})
                        return true
                    end
                }))
            end
        elseif context.cardarea == G.jokers and context.joker_main and card.ability.extra.chips > 0 then
            return {
                message = localize{type='variable',key='a_chips',vars={card.ability.extra.chips}},
                chip_mod = card.ability.extra.chips,
                colour = G.C.CHIPS
            }
        end
    end,
}

local funnel = {
    type = 'Joker',
    order = 64,
    key = 'funnel',
    name = 'funnel',
    atlas = "showdown_jokers",
    pos = coordinate(68),
    config = {extra = {x_chips = 1, x_chips_scale = 0.2}},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_chips_scale, card.ability.extra.x_chips } }
	end,
    rarity = 2, cost = 6,
    blueprint_compat = true, perishable_compat = false, eternal_compat = true,
    calculate = function(self, card, context)
        if context.using_tag and not context.blueprint then
            card.ability.extra.x_chips = card.ability.extra.x_chips + card.ability.extra.x_chips_scale
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.CHIPS,
                card = card
            }
        elseif context.cardarea == G.jokers and context.joker_main and card.ability.extra.x_chips ~= 1 then
            return {
                x_chips = card.ability.extra.x_chips
            }
        end
    end,
}

local jimbocoin = {
    type = 'Joker',
    order = 65,
    key = 'jimbocoin',
    name = 'jimbocoin',
    atlas = "showdown_jokers",
    pos = coordinate(69),
    config = {extra = { money_scale = 1, money = 0 }},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_gold
        return { vars = { card.ability.extra.money_scale, card.ability.extra.money } }
	end,
    rarity = 2, cost = 6,
    blueprint_compat = true, perishable_compat = false, eternal_compat = true,
    unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == 'money_gain_in_round' and args.money_gain >= 25 then
            unlock_card(self)
        end
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card.config.center == G.P_CENTERS.m_gold and not context.blueprint then
            card.ability.extra.money = card.ability.extra.money + card.ability.extra.money_scale
            forced_message(localize('k_upgrade_ex'), card, G.C.MONEY, true)
		end
    end,
    calc_dollar_bonus = function(self, card)
        if card.ability.extra.money > 0 then return card.ability.extra.money end
    end
}

local thorn_photograph = {
    type = 'Joker',
    order = 66,
    key = 'thorn_photograph',
    name = 'thorn_photograph',
    atlas = "showdown_jokers",
    pos = coordinate(70),
    config = {extra = { x_mult = 1.75 }},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_mult } }
	end,
    rarity = 1, cost = 4,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local first_numbered = nil
            for i = 1, #context.scoring_hand do
                if not context.scoring_hand[i]:is_face() then first_numbered = context.scoring_hand[i]; break end
            end
            if context.other_card == first_numbered then
                return {
                    x_mult = card.ability.extra.x_mult,
                    colour = G.C.RED,
                    card = card
                }
            end
		end
    end
}

local atom = {
    type = 'Joker',
    order = 67,
    key = 'atom',
    name = 'atom',
    atlas = "showdown_jokers",
    pos = coordinate(71),
    rarity = 1, cost = 4,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == 'modify_rank' and args.card and args.card.base.id == 14 then
            unlock_card(self)
        end
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.after then
            local eval = evaluate_poker_hand(context.scoring_hand)
            if next(eval['High Card']) then
                for i = 1, #context.scoring_hand do
                    local _card = context.scoring_hand[i]
                    flipCard(_card, i, #context.scoring_hand)
                    delay(0.2)
                    event({trigger = 'after', delay = 0.15, func = function()
                        assert(SMODS.modify_rank(_card, 1))
                    return true end})
                    unflipCard(_card, i, #context.scoring_hand)
                    delay(0.6)
                end
            end
		end
    end
}

local stencil = {
    type = 'Joker',
    order = 68,
    key = 'stencil',
    name = 'stencil',
    atlas = "showdown_jokers",
    pos = coordinate(72),
    config = {extra = { seals_to_put = 0, scaling = 6, scaling_progress = 0 }},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.seals_to_put, card.ability.extra.scaling, card.ability.extra.scaling - card.ability.extra.scaling_progress } }
	end,
    rarity = 3, cost = 8,
    blueprint_compat = true, perishable_compat = false, eternal_compat = true,
    calculate = function(self, card, context)
        if (context.cards_destroyed or context.remove_playing_cards) and not context.blueprint then
            local destroyed_cards = card.ability.extra.scaling_progress + #(context.cards_destroyed and context.glass_shattered or context.removed)
            local seals = 0
            while destroyed_cards >= card.ability.extra.scaling do
                destroyed_cards = destroyed_cards - card.ability.extra.scaling
                seals = seals + 1
            end
            card.ability.extra.scaling_progress = destroyed_cards
            if seals > 0 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            card.ability.extra.seals_to_put = card.ability.extra.seals_to_put + seals
                          return true
                        end
                        }))
                        card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex')})
                        return true
                    end
                }))
            end
        elseif context.cardarea == G.jokers and context.after and card.ability.extra.seals_to_put > 0 then
            local eligible_cards = {}
            for _, _card in ipairs(G.hand.cards) do
                if not _card.seal then table.insert(eligible_cards, _card) end
            end
            if #eligible_cards > 0 then
                local stenciled_cards = {}
                for _ = 1, math.min(card.ability.extra.seals_to_put, #eligible_cards) do
                    local _card = pseudorandom_element(eligible_cards, pseudoseed('stencil'))
                    table.insert(stenciled_cards, _card)
                    table.remove(eligible_cards, findInTable(_card, eligible_cards))
                end
                for _, _card in ipairs(stenciled_cards) do
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            _card:set_seal(SMODS.poll_seal({type_key = 'stencil', guaranteed = true}), nil, true)
                            if context.blueprint_card then context.blueprint_card:juice_up() else card:juice_up() end
                            return true
                        end
                    }))
                end
            end
        end
    end
}

local o_fortuna = {
    type = 'Joker',
    order = 69, -- nice
    key = 'o_fortuna',
    name = 'o_fortuna',
    atlas = "showdown_jokers",
    pos = coordinate(73),
    config = {extra = { duplication_chance = 3 }},
    loc_vars = function(self, info_queue, card)
        return { vars = { SMODS.get_probability_vars(card, 1, card.ability.extra.duplication_chance, 'o_fortuna') } }
	end,
    rarity = 3, cost = 8,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == 'using_consumeable' and args.card.edition and args.card.edition.type == 'negative' then
            unlock_card(self)
        end
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and context.consumeable.ability.set == "Tarot" and SMODS.pseudorandom_probability(card, 'o_fortuna', 1, card.ability.extra.duplication_chance) then
            G.E_MANAGER:add_event(Event({
                func = function()
                    if G.consumeables.config.card_limit > #G.consumeables.cards then
                        local _card = SMODS.create_card({set = 'Tarot', area = G.consumeables, key = context.consumeable.config.center.key})
                        _card:add_to_deck()
                        G.consumeables:emplace(_card)
                    end
                return true
            end}))
        end
    end
}

local floating_point = {
    type = 'Joker',
    order = 70,
    activated = { Showdown.config["Ranks"] },
    key = 'floating_point',
    name = 'floating_point',
    atlas = "showdown_jokers",
    pos = coordinate(74),
    config = {extra = { money = 1.5, money_face = 2.5 }},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {set = 'Other', key = 'counterpart_ranks'}
        return { vars = { card.ability.extra.money, card.ability.extra.money_face } }
	end,
    rarity = 1, cost = 4,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and SMODS.is_counterpart(context.other_card) then
            return {
                dollars = context.other_card:is_face() and card.ability.extra.money_face or card.ability.extra.money,
                card = context.other_card
            }
        end
    end
}

local ena = {
    type = 'Joker',
    order = 71,
    key = 'ena',
    name = 'ena',
    atlas = "showdown_jokers",
    pos = coordinate(75), soul_pos = coordinate(76),
    config = {extra = { x_chips = 1, x_chips_scale = 0.25 }},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_chips_scale, card.ability.extra.x_chips } }
	end,
    rarity = 4, cost = 10,
    blueprint_compat = true, perishable_compat = false, eternal_compat = true,
    calculate = function(self, card, context)
        if context.card_added and context.card.ability.set == 'Joker' and not context.blueprint then
            card.ability.extra.x_chips = card.ability.extra.x_chips + card.ability.extra.x_chips_scale
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.CHIPS,
                card = card
            }
        elseif context.cardarea == G.jokers and context.joker_main and card.ability.extra.x_chips ~= 1 then
            return {
                x_chips = card.ability.extra.x_chips
            }
        end
    end
}

Showdown.binary_10111_joker_consumeable_type_colours = {
    ['Tarot'] = G.C.SECONDARY_SET.Tarot,
    ['Planet'] = G.C.SECONDARY_SET.Planet,
    ['Spectral'] = G.C.SECONDARY_SET.Spectral,
    ['Mathematic'] = G.C.SHOWDOWN_CALCULUS,
    ['Logic'] = G.C.SHOWDOWN_BOOLEAN,
}

local binary_10111 = {
    type = 'Joker',
    order = 72,
    key = '10111',
    name = '10111',
    atlas = "showdown_jokers",
    pos = coordinate(77),
    config = {extra = { consumeable_type = 'Tarot' }},
    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME and card.ability.extra.consumeable_type and localize('k_'..card.ability.extra.consumeable_type:lower()) or ('['..localize('k_consumeable_type')..']'), colours = { Showdown.binary_10111_joker_consumeable_type_colours[card.ability.extra.consumeable_type] or G.C.ORANGE } } }
	end,
    rarity = 2, cost = 6,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if context.using_consumeable and context.consumeable.ability.set == "Logic" then
            G.E_MANAGER:add_event(Event({
                func = function()
                    if G.consumeables.config.card_limit > #G.consumeables.cards then
                        local _card = SMODS.create_card({set = card.ability.extra.consumeable_type, area = G.consumeables})
                        _card:add_to_deck()
                        G.consumeables:emplace(_card)
                    end
                return true
            end}))
        elseif context.end_of_round and G.GAME.blind.boss and not context.blueprint then
            local eligible_types = {}
            for type, _ in pairs(SMODS.ConsumableTypes) do
                if Showdown.binary_10111_joker_consumeable_type_colours[type] and type ~= card.ability.extra.consumeable_type then
                    table.insert(eligible_types, type)
                end
            end
            if #eligible_types == 0 then eligible_types = { 'Tarot' } end
            card.ability.extra.consumeable_type = pseudorandom_element(eligible_types, pseudoseed('10111'))
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        if not from_debuff then
            card.ability.extra.consumeable_type = ''
            local eligible_types = {}
            for type, _ in pairs(SMODS.ConsumableTypes) do
                if Showdown.binary_10111_joker_consumeable_type_colours[type] and type ~= card.ability.extra.consumeable_type then
                    table.insert(eligible_types, type)
                end
            end
            if #eligible_types == 0 then eligible_types = { 'Tarot' } end
            card.ability.extra.consumeable_type = pseudorandom_element(eligible_types, pseudoseed('10111'))
        end
    end,
}

local turbo = {
    type = 'Joker',
    order = 73,
    activated = { Showdown.config["Ranks"] },
    key = 'turbo',
    name = 'turbo',
    atlas = "showdown_jokers",
    pos = coordinate(78),
    config = {extra = { counterpart_value_boost = 3 }},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {set = 'Other', key = 'counterpart_ranks'}
        --return { vars = { card.ability.extra.counterpart_value_boost } }
        return { vars = { 3 } }
	end,
    rarity = 2, cost = 6,
    blueprint_compat = false, perishable_compat = true, eternal_compat = true,
    add_to_deck = function(self, card, from_debuff)
        --G.GAME.counterpart_turbo_boost = G.GAME.counterpart_turbo_boost * card.ability.extra.counterpart_value_boost
        G.GAME.counterpart_turbo_boost = G.GAME.counterpart_turbo_boost * 3
    end,
    remove_from_deck = function(self, card, from_debuff)
        --G.GAME.counterpart_turbo_boost = G.GAME.counterpart_turbo_boost / card.ability.extra.counterpart_value_boost
        G.GAME.counterpart_turbo_boost = G.GAME.counterpart_turbo_boost / 3
    end,
}

local mouthwash = {
    type = 'Joker',
    order = 74,
    key = 'mouthwash',
    name = 'mouthwash',
    atlas = "showdown_jokers",
    pos = coordinate(79),
    rarity = 1, cost = 4,
    blueprint_compat = false, perishable_compat = false, eternal_compat = false,
    calculate = function(self, card, context)
        if context.selling_self and not context.blueprint then
            for _, area in ipairs({ G.jokers.cards, G.consumeables.cards, G.hand.cards }) do
                for _, _card in ipairs(area) do
                    _card.ability.mouthwash_no_debuff = true
                    _card:set_debuff(false)
                end
            end
        end
    end,
}

local esotericism = {
    type = 'Joker',
    order = 75,
    key = 'esotericism',
    name = 'esotericism',
    atlas = "showdown_jokers",
    pos = coordinate(80),
    rarity = 1, cost = 4,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if context.end_of_round and G.GAME.blind.boss then
            G.E_MANAGER:add_event(Event({
                func = function()
                    if G.consumeables.config.card_limit > #G.consumeables.cards then
                        local _card = SMODS.create_card({set = SMODS.pseudorandom_probability(card, 'esotericism', 1, 3) and 'Spectral' or 'Tarot', area = G.consumeables})
                        _card:add_to_deck()
                        G.consumeables:emplace(_card)
                    end
                return true
            end}))
        end
    end
}

local pegman = {
    type = 'Joker',
    order = 76,
    key = 'pegman',
    name = 'pegman',
    atlas = "showdown_jokers",
    pos = coordinate(81),
    rarity = 2, cost = 6,
    blueprint_compat = false, perishable_compat = true, eternal_compat = true,
    unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == 'modify_deck' then
            local count = 0
            for _, card in pairs(G.playing_cards) do
                if card.base.id == 14 then count = count + 1 end
            end
            if count >= 10 then unlock_card(self) end
        end
    end,
    calculate = function(self, card, context)
        if context.after then
            local no_aces = true
            for _, _card in pairs(G.play.cards) do
                no_aces = no_aces and _card:get_id() ~= 14
            end
            if no_aces then
                for _, _card in pairs(G.hand.cards) do
                    no_aces = no_aces and _card:get_id() ~= 14
                end
                if no_aces then
                    local suit = pseudorandom_element(get_all_suits(), pseudoseed('create_card'))
                    local created_card, _card = get_card_from_rank_suit('Ace', suit), nil
                    if created_card then
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                                _card = Card(G.play.T.x + G.play.T.w/2, G.play.T.y, G.CARD_W, G.CARD_H, created_card, G.P_CENTERS.c_base, {playing_card = G.playing_card})
                                _card:start_materialize({G.C.SECONDARY_SET.Enhanced})
                                G.play:emplace(_card)
                                table.insert(G.playing_cards, _card)
                                return true
                        end}))
                    end
                    delay(0.2)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.deck.config.card_limit = G.deck.config.card_limit + 1
                            playing_card_joker_effects({_card})
                            draw_card(G.play, G.deck, 100, 'up', nil, _card)
                            return true
                    end}))
                    delay(0.2)
                end
            end
        end
    end
}

local overjoy = {
    type = 'Joker',
    order = 77,
    key = 'overjoy',
    name = 'overjoy',
    atlas = "showdown_jokers",
    pos = coordinate(82),
    config = {extra = { level_mult = 2 }},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.level_mult } }
	end,
    rarity = 2, cost = 6,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local text = G.FUNCS.get_poker_hand_info(context.scoring_hand)
            local hand_level = G.GAME.hands[text].level
            context.other_card.ability.perma_bonus = (context.other_card.ability.perma_bonus or 0) + hand_level * card.ability.extra.level_mult
            return {
                extra = {message = localize('k_upgrade_ex'), colour = G.C.CHIPS},
                colour = G.C.CHIPS,
                card = card
            }
        end
    end
}

local nothing_matter = {
    type = 'Joker',
    order = 78,
    activated = { Showdown.config["Ranks"] },
    key = 'nothing_matter',
    name = 'nothing_matter',
    atlas = "showdown_jokers",
    pos = coordinate(83),
    rarity = 2, cost = 6,
    blueprint_compat = false, perishable_compat = true, eternal_compat = true,
}

local infection = {
	type = 'Joker',
    order = 79,
    key = 'infection',
    name = 'infection',
    atlas = "showdown_jokers",
    pos = coordinate(84),
    config = {extra = { x_mult = 1.5 }},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_mult, G.GAME.showdown_infection and G.GAME.showdown_infection.rate or 0 } }
	end,
    rarity = 2, cost = 4,
    blueprint_compat = true, perishable_compat = true, eternal_compat = false,
    calculate = function(self, card, context)
        if context.joker_main and card.ability.extra.x_mult ~= 1 then
            return {
                message = localize{type='variable',key='a_xmult',vars={card.ability.extra.x_mult}},
                Xmult_mod = card.ability.extra.x_mult,
            }
        elseif context.end_of_round and not context.repetition and not context.individual then
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('tarot1')
                    card.T.r = -0.2
                    card:juice_up(0.3, 0.4)
                    card.states.drag.is = true
                    card.children.center.pinch.x = true
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                        func = function()
                            card:remove()
                            card = nil
                        return true; end}))
                    return true
                end
            }))
            if not G.GAME.showdown_infection then G.GAME.showdown_infection = {value = 1.5, rate = 0} end
            G.GAME.showdown_infection.value = tonumber(('%%.%dg'):format(2.11):format((G.GAME.showdown_infection.value * 1.1)))
            if G.GAME.showdown_infection.rate < 100 then
                G.GAME.showdown_infection.rate = G.GAME.showdown_infection.rate + 5
                if G.GAME.showdown_infection.rate >= 100 then check_for_unlock({type = 'should_check'}) end
            end
            return {
                message = localize('k_bye_bye'),
                destroyed = true
            }
        end
    end,
    set_ability = function (self, card, initial, delay_sprites)
        card.ability.extra.x_mult = G.GAME.showdown_infection and G.GAME.showdown_infection.value or 1.5
    end,
}

local love_letter = {
    type = 'Joker',
    order = 80,
    key = 'love_letter',
    name = 'love_letter',
    atlas = "showdown_jokers",
    pos = coordinate(85),
    config = {extra = { x_mult = 2 }},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_mult } }
	end,
    rarity = 1, cost = 4,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main and card.ability.extra.x_mult ~= 1 then
            local king = false
            local queen = false
            for i=1, #context.scoring_hand do
                if not king and context.scoring_hand[i]:get_id() == 13 then king = true end
                if not queen and context.scoring_hand[i]:get_id() == 12 then queen = true end
                if king and queen then
                    return {
                        message = localize{type='variable',key='a_xmult',vars={card.ability.extra.x_mult}},
                        Xmult_mod = card.ability.extra.x_mult
                    }
                end
            end
        end
    end,
}

local brain_battery = {
    type = 'Joker',
    order = 81,
    key = 'brain_battery',
    name = 'brain_battery',
    atlas = "showdown_jokers",
    pos = coordinate(86),
    config = {extra = { x_chips = 1, x_chips_scale = 1 }},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_chips_scale, card.ability.extra.x_chips } }
	end,
    rarity = 3, cost = 8,
    blueprint_compat = true, perishable_compat = false, eternal_compat = true,
    unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == 'selling_card' and G.jokers then
            for _, v in pairs(G.jokers.cards) do
                if v.ability.name == 'Campfire' and v.ability.x_mult >= 5 then unlock_card(self) end
            end
        end
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main and card.ability.extra.x_chips > 1 then
            return {
                x_chips = card.ability.extra.x_chips
            }
        elseif not context.blueprint then
            if context.post_trigger and context.other_card ~= card and not context.other_context.fixed_probability and not context.other_context.mod_probability then
                card.ability.extra.x_chips = card.ability.extra.x_chips + card.ability.extra.x_chips_scale
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.CHIPS,
                    card = card
                }
            elseif context.end_of_round and card.ability.extra.x_chips > 1 then
                card.ability.extra.x_chips = 1
                return {
                    message = localize('k_reset'),
                    colour = G.C.BLUE
                }
            end
        end
    end,
}

local warped_joker = {
    type = 'Joker',
    order = 82,
    activated = { Showdown.config["Ranks"] },
    key = 'warped_joker',
    name = 'warped_joker',
    atlas = "showdown_jokers",
    pos = coordinate(87),
    config = {extra = {chips_scale = 7.5, chips = 0}},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {set = 'Other', key = 'counterpart_ranks'}
        return { vars = { card.ability.extra.chips_scale, card.ability.extra.chips } }
	end,
    rarity = 1, cost = 4,
    blueprint_compat = true, perishable_compat = false, eternal_compat = true,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers then
            if context.joker_main and card.ability.extra.chips > 0 then
                return {
                    message = localize{type='variable',key='a_chips',vars={card.ability.extra.chips}},
                    chip_mod = card.ability.extra.chips,
                    colour = G.C.CHIPS
                }
            elseif context.before and not context.blueprint then
                local all_count = true
                for i=1, #G.hand.cards do
                    all_count = all_count and SMODS.is_counterpart(G.hand.cards[i])
                end
                if all_count then
                    card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_scale
                    return {
                        message = localize('k_upgrade_ex'),
                        colour = G.C.CHIPS,
                        card = card
                    }
                end
            end
        end
    end
}

local function create_card_for_rules_card(card, center)
    if card.ability.extra.reference_to_copied_card and card.ability.extra.reference_to_copied_card.calculate_joker then
        card.ability.extra.reference_to_copied_card.getting_sliced = true
        G.E_MANAGER:add_event(Event({func = function()
            card.ability.extra.reference_to_copied_card:start_dissolve({HEX("57ecab")}, true, 1.6)
        return true end }))
    end
    if center then
        G.E_MANAGER:add_event(Event({func = function()
            local previous_bypass_create_card_edition = SMODS.bypass_create_card_edition
            SMODS.bypass_create_card_edition = true
            local _card = create_card('Joker', G.rules_card_jokers, nil, nil, true, nil, center, 'rules_card')
            SMODS.bypass_create_card_edition = previous_bypass_create_card_edition
            _card:add_to_deck()
            G.rules_card_jokers:emplace(_card)
            card.ability.extra.reference_to_copied_card = _card
        return true end }))
        card.ability.extra.created_this_round = true
    end
end

local rules_card = {
    type = 'Joker',
    order = 83,
    key = 'rules_card',
    name = 'rules_card',
    atlas = "showdown_jokers",
    pos = coordinate(88),
    config = {extra = {copied_joker = nil, reference_to_copied_card = nil, created_this_round = false}},
    loc_vars = function(self, info_queue, card)
        if card.ability.extra.copied_joker and card.ability.extra.reference_to_copied_card then
            info_queue[#info_queue+1] = G.P_CENTERS[card.ability.extra.copied_joker]
        end
        return { vars = { card.ability.extra.copied_joker and localize{type = 'name_text', set = 'Joker', key = card.ability.extra.copied_joker, nodes = {}} or localize('k_none') } }
	end,
    rarity = 2, cost = 6,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if G.rules_card_jokers then
            if not context.blueprint then
                if context.end_of_round and G.GAME.sold_jokers and not card.ability.extra.created_this_round then
                    local old_joker = card.ability.extra.copied_joker
                    card.ability.extra.copied_joker = pseudorandom_element(G.GAME.sold_jokers, pseudoseed('rules_card'))
                    if card.ability.extra.copied_joker == 'j_showdown_rules_card' then
                        check_for_unlock({type = 'self_reference'})
                    end
                    if card.ability.extra.copied_joker ~= old_joker then
                        create_card_for_rules_card(card, card.ability.extra.copied_joker)
                    end
                elseif context.setting_blind and card.ability.extra.created_this_round then
                    card.ability.extra.created_this_round = false
                end
            end
            -- Ability copying
            if card.ability.extra.reference_to_copied_card and card.ability.extra.reference_to_copied_card.calculate_joker then
                local other_joker_ret = card.ability.extra.reference_to_copied_card:calculate_joker(context)
                if other_joker_ret then
                    other_joker_ret.card = card
                    other_joker_ret.colour = G.C.BLUE
                    return other_joker_ret
                end
            end
        end
    end,
    load = function(self, card, card_table, other_card)
        if card_table.ability.extra.reference_to_copied_card and not card_table.ability.extra.reference_to_copied_card.calculate_joker then
            create_card_for_rules_card(card_table, card_table.ability.extra.copied_joker)
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        if card.ability.extra.reference_to_copied_card then
            card.ability.extra.reference_to_copied_card.getting_sliced = true
            G.E_MANAGER:add_event(Event({func = function()
                card.ability.extra.reference_to_copied_card:start_dissolve({HEX("57ecab")}, nil, 1.6)
            return true end }))
        end
    end,
}

local terms_of_service = {
    type = 'Joker',
    order = 84,
    key = 'terms_of_service',
    name = 'terms_of_service',
    atlas = "showdown_jokers",
    pos = coordinate(89),
    config = {extra = { x_mult_scale = 0.5 }},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_mult_scale, 1 + (table_length(G.GAME.used_vouchers) * card.ability.extra.x_mult_scale) + ((G.GAME.starting_voucher_count or 0) * card.ability.extra.x_mult_scale) } }
	end,
    rarity = 3, cost = 8,
    blueprint_compat = true, perishable_compat = false, eternal_compat = true,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main and context.scoring_hand and (table_length(G.GAME.used_vouchers) * card.ability.extra.x_mult_scale) + ((G.GAME.starting_voucher_count or 0) * card.ability.extra.x_mult_scale) > 0 then
            return {
                x_mult = 1 + (table_length(G.GAME.used_vouchers) * card.ability.extra.x_mult_scale) + ((G.GAME.starting_voucher_count or 0) * card.ability.extra.x_mult_scale)
            }
        end
    end
}

local point_of_no_return = {
    type = 'Joker',
    order = 85,
    key = 'point_of_no_return',
    name = 'point_of_no_return',
    atlas = "showdown_jokers",
    pos = coordinate(90),
    rarity = 2, cost = 6,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.after and not context.blueprint_card and not context.retrigger_joker then
            for i=1, #context.scoring_hand do
                local _card = context.scoring_hand[i]
                if _card:get_id() ~= 1 then
                    flipCard(_card, i, #context.scoring_hand)
                    delay(0.2)
                    local rank = SMODS.Rank.obj_table[_card.base.value]
                    event({trigger = 'after', delay = 0.15, func = function()
                        assert(SMODS.change_base(_card, nil, rank.prev[1]))
                    return true end})
                    unflipCard(_card, i, #context.scoring_hand)
                    delay(0.6)
                end
            end
        end
    end
}

local encore = {
    type = 'Joker',
    order = 86,
    activated = { Showdown.config["Ranks"] },
    key = 'encore',
    name = 'encore',
    atlas = "showdown_jokers",
    pos = coordinate(91),
    config = {extra = { chips_scale = 3, chips = 0 }},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips_scale, card.ability.extra.chips } }
	end,
    locked_loc_vars = function(self, info_queue, card)
        return { vars = { G.PROFILES[G.SETTINGS.profile].career_stats.c_cards_retriggered } }
	end,
    rarity = 1, cost = 4,
    blueprint_compat = true, perishable_compat = false, eternal_compat = true,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then -- Thanks Cryptid
			if not context.other_card.encore_check then
				context.other_card.encore_check = true
				local _card = context.other_card
				G.E_MANAGER:add_event(Event({
					func = function()
						if _card then
							_card.encore_check = nil
						end
						return true
					end,
				}))
			else
				card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_scale
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.CHIPS,
                    card = card
                }
			end
		end
        if context.cardarea == G.jokers and context.joker_main and card.ability.extra.chips > 0 then
            return {
                message = localize{type='variable',key='a_chips',vars={card.ability.extra.chips}},
                chip_mod = card.ability.extra.chips,
                colour = G.C.CHIPS
            }
        end
    end
}

local soul_avarice = {
    type = 'Joker',
    order = 87,
    key = 'soul_avarice',
    name = 'soul_avarice',
    atlas = "showdown_jokers",
    pos = coordinate(92),
    config = {extra = { x_mult_mod = 0.02, x_mult = 1 }},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_mult_mod, card.ability.extra.x_mult } }
	end,
    rarity = 2, cost = 6,
    blueprint_compat = true, perishable_compat = false, eternal_compat = true,
    unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == 'lose_game' and args.dollars > 100 then
            unlock_card(self)
        end
    end,
    calculate = function(self, card, context)
        if context.ease_money and not context.blueprint then
            card.ability.extra.x_mult = card.ability.extra.x_mult + (card.ability.extra.x_mult_mod * context.amount)
            forced_message(localize('k_upgrade_ex'), card, G.C.XMULT, true)
        end
        if context.joker_main and card.ability.extra.x_mult ~= 1 then
            return {
                x_mult = card.ability.extra.x_mult,
            }
        end
    end
}

local soul_malice = {
    type = 'Joker',
    order = 88,
    key = 'soul_malice',
    name = 'soul_malice',
    atlas = "showdown_jokers",
    pos = coordinate(93),
    config = {extra = { retrigger = 1, destruction_chance = 5 }},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.retrigger, SMODS.get_probability_vars(card, 1, card.ability.extra.destruction_chance, 'soul_malice') } }
	end,
    rarity = 2, cost = 6,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == 'lose_game' and #args.jokers > 0 then
            local has_blueprint = false
            local has_sock_and_buskin = false
            for _, joker_name in ipairs(args.jokers) do
                has_blueprint = has_blueprint or joker_name == 'Blueprint'
                has_sock_and_buskin = has_sock_and_buskin or joker_name == 'Sock and Buskin'
            end
            if has_blueprint and has_sock_and_buskin then
                unlock_card(self)
            end
        end
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            return {
                repetitions = card.ability.extra.retrigger,
                card = card
            }
        elseif context.destroying_card and context.cardarea == G.play and not context.destroy_card.debuff and SMODS.pseudorandom_probability(card, 'soul_malice', 1, card.ability.extra.destruction_chance) then
            return { remove = true }
        end
    end
}

local soul_fortune = {
    type = 'Joker',
    order = 89,
    key = 'soul_fortune',
    name = 'soul_fortune',
    atlas = "showdown_jokers",
    pos = coordinate(94),
    config = {extra = {x_chips_scale = 0.05, x_chips = 1}},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_chips_scale, card.ability.extra.x_chips } }
	end,
    rarity = 2, cost = 6,
    blueprint_compat = true, perishable_compat = false, eternal_compat = true,
    unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == 'lose_game' and args.last_hand_debuffed then
            unlock_card(self)
        end
    end,
    calculate = function(self, card, context)
        if context.joker_main and card.ability.extra.x_chips ~= 1 then
            return {
                x_chips = card.ability.extra.x_chips
            }
        end
        if not context.blueprint then
            if context.cardarea == G.jokers and context.after and not context.blueprint_card and not context.blueprint and not context.retrigger_joker then
                for _, _card in ipairs(context.scoring_hand) do
                    if not _card.ability.showdown_soul_fortune then
                        event({trigger = 'after', delay = 0.15, func = function()
                            _card.ability.showdown_soul_fortune = true
                            _card:set_debuff(true)
                        return true end})
                    end
                end
            end
            if context.debuffed_card then
                card.ability.extra.x_chips = card.ability.extra.x_chips + card.ability.extra.x_chips_scale
                forced_message(localize('k_upgrade_ex'), card, G.C.CHIPS, true)
            end
            if context.selling_self then
                for _, _card in ipairs(G.playing_cards) do
                    _card.ability.showdown_soul_fortune = false
                    _card:set_debuff(false)
                end
            end
        end
    end,
	update = function(self, card, dt)
        if G.deck then
            for _, _card in pairs(G.deck.cards) do
                if _card.ability.showdown_soul_fortune then
                    _card:set_debuff(true)
                end
            end
        end
	end
}

local soul_gambling = {
    type = 'Joker',
    order = 90,
    activated = { (SMODS.Mods["FusionJokers"] or {}).can_load and Showdown.config["CrossMod"]["FusionJokers"] },
    key = 'soul_gambling',
    name = 'soul_gambling',
    atlas = "showdown_jokers_fusion",
    pos = coordinate(1),
    config = {extra = {money = 1, x_mult_mod = 0.02, x_chips_scale = 0.05, retrigger = 1, x_mult = 1, x_chips = 1}},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.money, card.ability.extra.x_mult_mod, card.ability.extra.x_chips_scale, card.ability.extra.retrigger, card.ability.extra.x_mult, card.ability.extra.x_chips } }
	end,
    rarity = "fuse_fusion", cost = 12,
    blueprint_compat = true, perishable_compat = false, eternal_compat = true,
    calculate = function(self, card, context)
        if context.joker_main then
            local ret = {}
            if card.ability.extra.x_chips ~= 1 then ret.x_chips = card.ability.extra.x_chips end
            if card.ability.extra.x_mult ~= 1 then ret.x_mult = card.ability.extra.x_mult end
            return ret
        end
        if context.repetition and context.cardarea == G.play then
            return {
                repetitions = card.ability.extra.retrigger,
                card = card
            }
        end
        if not context.blueprint then
            if context.ease_money then
                card.ability.extra.x_mult = card.ability.extra.x_mult + (card.ability.extra.x_mult_mod * context.amount)
                forced_message(localize('k_upgrade_ex'), card, G.C.XMULT, true)
            end
            if context.cardarea == G.jokers and context.after and not context.blueprint_card and not context.retrigger_joker then
                local dollars = 0
                for _, _card in ipairs(context.scoring_hand) do
                    if not _card.ability.showdown_soul_fortune then
                        event({trigger = 'after', delay = 0.15, func = function()
                            _card.ability.showdown_soul_fortune = true
                            _card:set_debuff(true)
                        return true end})
                    else
                        event({trigger = 'after', delay = 0.15, func = function()
                            _card.ability.showdown_soul_fortune = false
                            _card:set_debuff(false)
                        return true end})
                        dollars = dollars + card.ability.extra.money
                    end
                end
                if dollars > 0 then
                    event({trigger = 'after', delay = 0.15, func = function()
                        ease_dollars(dollars)
                    return true end})
                end
            end
            if context.debuffed_card then
                card.ability.extra.x_chips = card.ability.extra.x_chips + card.ability.extra.x_chips_scale
                forced_message(localize('k_upgrade_ex'), card, G.C.CHIPS, true)
            end
            if context.selling_self then
                for _, _card in ipairs(G.playing_cards) do
                    _card.ability.showdown_soul_fortune = false
                    _card:set_debuff(false)
                end
            end
        end
    end,
	update = function(self, card, dt)
        if G.deck then
            for _, _card in pairs(G.deck.cards) do
                if _card.ability.showdown_soul_fortune then
                    _card:set_debuff(true)
                end
            end
        end
	end
}

local blinking_block = {
    type = 'Joker',
    order = 91,
    key = 'blinking_block',
    name = 'blinking_block',
    atlas = "showdown_jokers",
    pos = coordinate(95),
    config = {extra = { is_mult = true, x_mult = 2, x_chips = 2 }},
    loc_vars = function(self, info_queue, card)
        return { key = 'j_showdown_blinking_block_'..(card.ability.extra.is_mult and 'mult' or 'chips'), vars = { card.ability.extra.is_mult and card.ability.extra.x_mult or card.ability.extra.x_chips } }
	end,
    rarity = 2, cost = 6,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if context.joker_main then
            if card.ability.extra.is_mult and card.ability.extra.x_mult ~= 1 then
                return {
                    x_mult = card.ability.extra.x_mult,
                }
            elseif not card.ability.extra.is_mult and card.ability.extra.x_chips ~= 1 then
                return {
                    x_chips = card.ability.extra.x_chips,
                }
            end
        end
        -- See change_blinking_block_states() for state change
    end,
    add_to_deck = function(self, card, from_debuff)
        if not card.ability.extra.is_mult then
            card.children.center:set_sprite_pos(coordinate(96))
        end
    end,
	set_sprites = function(self, card, front)
		if card.ability and card.ability.extra and not card.ability.extra.is_mult then
            card.children.center:set_sprite_pos(coordinate(96))
        end
	end,
}

local tooth_decay = {
    type = 'Joker',
    order = 92,
    key = 'tooth_decay',
    name = 'tooth_decay',
    atlas = "showdown_jokers",
    pos = coordinate(97),
    config = {extra = { mult_scale = 5, mult = 0 }},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        return { vars = { card.ability.extra.mult_scale, card.ability.extra.mult } }
	end,
    rarity = 2, cost = 6,
    blueprint_compat = true, perishable_compat = false, eternal_compat = true,
    calculate = function(self, card, context)
        if context.destroying_card and context.cardarea == G.play and SMODS.has_enhancement(context.destroy_card, 'm_stone') and not context.destroy_card.debuff then
			card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_scale
            forced_message(localize('k_upgrade_ex'), card, G.C.XMULT, true)
            return { remove = true }
        end
        if context.cardarea == G.jokers and context.joker_main and card.ability.extra.mult > 0 then
            return {
                message = localize{type='variable',key='a_mult',vars={card.ability.extra.mult}},
                mult_mod = card.ability.extra.mult,
                colour = G.C.MULT
            }
        end
    end
}

local gamma_pulse = {
    type = 'Joker',
    order = 93,
    key = 'gamma_pulse',
    name = 'gamma_pulse',
    atlas = "showdown_jokers",
    pos = coordinate(98),
    config = {extra = { level_upgrade = 1 }},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.level_upgrade } }
	end,
    rarity = 3, cost = 8,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if (context.setting_blind and not (context.blueprint_card or card).getting_sliced) then
            local handname, _tally = nil, -1
            for k, v in ipairs(G.handlist) do
                if G.GAME.hands[v].visible and G.GAME.hands[v].played > _tally then
                    handname = v
                    _tally = G.GAME.hands[v].played
                end
            end
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_level_up_ex')})
            update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(handname, 'poker_hands'),chips = G.GAME.hands[handname].chips, mult = G.GAME.hands[handname].mult, level=G.GAME.hands[handname].level})
            level_up_hand(card, handname, nil, card.ability.extra.level_upgrade)
            update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
		end
    end
}

local patchwork_joker = {
    type = 'Joker',
    order = 94,
    key = 'patchwork_joker',
    name = 'patchwork_joker',
    atlas = "showdown_jokers",
    pos = coordinate(99),
    config = {extra = {x_chips_scale = 0.15, x_chips = 1}},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_chips_scale, card.ability.extra.x_chips } }
	end,
    rarity = 3, cost = 8,
    blueprint_compat = false, perishable_compat = true, eternal_compat = true,
    unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == 'hand_contents' then
            local enhancements = {}
            for _, card in ipairs(args.cards) do
                local enh = next(SMODS.get_enhancements(card))
                if enh and findInTable(enh, enhancements) == -1 then
                    table.insert(enhancements, enh)
                end
            end
            if #enhancements >= 5 then unlock_card(self) end
        end
    end,
    calculate = function(self, card, context)
        if context.joker_main and card.ability.extra.x_chips ~= 1 then
            return {
                x_chips = card.ability.extra.x_chips
            }
        end
    end,
    update = function(self, card, dt)
        local enhanced_cards = 0
        if G.playing_cards then
            for _, _card in pairs(G.playing_cards) do
                if next(SMODS.get_enhancements(_card)) then enhanced_cards = enhanced_cards + 1 end
            end
        end
        card.ability.extra.x_chips = 1 + card.ability.extra.x_chips_scale * enhanced_cards
    end,
}

local gummy_worms = {
    type = 'Joker',
    order = 95,
    key = 'gummy_worms',
    name = 'gummy_worms',
    atlas = "showdown_jokers",
    pos = coordinate(100),
    config = {extra = {x_chips = 2, x_chips_reduction = 0.2}},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_chips, card.ability.extra.x_chips_reduction } }
	end,
    rarity = 2, cost = 6,
    blueprint_compat = false, perishable_compat = false, eternal_compat = false,
    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not context.repetition and not context.individual then
            if card.ability.extra.x_chips - card.ability.extra.x_chips_reduction <= 1 then 
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    card = card,
                    message = localize('k_eaten_ex'),
                    colour = G.C.FILTER
                }
            else
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra,
                    ref_value = "x_chips",
                    scalar_value = "x_chips_reduction",
                    operation = "-",
                    message_key = 'a_xchips_minus',
                    colour = G.C.CHIPS
                })
            end
        end
        if context.joker_main then
            return {
                x_chips = card.ability.extra.x_chips
            }
        end
    end,
}

local deviantt = {
    type = 'Joker',
    order = 96,
    key = 'deviantt',
    name = 'deviantt',
    atlas = "showdown_jokers",
    pos = coordinate(101), soul_pos = coordinate(102),
    config = {extra = { x_chips = 2.5 }},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_chips } }
	end,
    rarity = 4, cost = 10,
    unlocked = false,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if context.other_joker and (context.other_joker:is_rarity("Legendary") or context.other_joker:is_rarity("showdown_Final")) then
            G.E_MANAGER:add_event(Event({
                func = function()
                    context.other_joker:juice_up(0.5, 0.5)
                    return true
                end
            }))
            return {
                xchips = card.ability.extra.x_chips
            }
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        local mutant, abominationn = find_joker('mutant'), find_joker('abominationn')
        if next(mutant) and next(abominationn) then
            check_for_unlock({type = 'fargo_proud'})
        end
    end,
}

local abominationn = {
    type = 'Joker',
    order = 97,
    key = 'abominationn',
    name = 'abominationn',
    atlas = "showdown_jokers",
    pos = coordinate(103), soul_pos = coordinate(104),
    config = {extra = { blind_requirement_division = 2 }},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.blind_requirement_division } }
	end,
    rarity = 4, cost = 10,
    unlocked = false,
    blueprint_compat = true, perishable_compat = true, eternal_compat = true,
    calculate = function(self, card, context)
        if context.setting_blind and not (context.blueprint_card or card).getting_sliced then
            G.E_MANAGER:add_event(Event({func = function()
                Showdown.modify_blind_score(G.GAME.blind.chips / card.ability.extra.blind_requirement_division)
            return true end }))
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        local deviantt, mutant = find_joker('deviantt'), find_joker('mutant')
        if next(deviantt) and next(mutant) then
            check_for_unlock({type = 'fargo_proud'})
        end
    end,
}

local mutant = {
    type = 'Joker',
    order = 98,
    key = 'mutant',
    name = 'mutant',
    atlas = "showdown_jokers",
    pos = coordinate(105), soul_pos = coordinate(106),
    rarity = 4, cost = 10,
    unlocked = false,
    blueprint_compat = false, perishable_compat = true, eternal_compat = true,
    add_to_deck = function(self, card, from_debuff)
        if not G.GAME.mutant_legendary_pool then
            G.GAME.mutant_legendary_pool = {}
        end
        G.GAME.mutant_legendary_pool.rate = 0.1
        G.GAME.mutant_legendary_pool.in_shop = true

        local deviantt, abominationn = find_joker('deviantt'), find_joker('abominationn')
        if next(deviantt) and next(abominationn) then
            check_for_unlock({type = 'fargo_proud'})
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.mutant_legendary_pool.in_shop = next(find_joker('mutant')) ~= nil
    end,
    load = function(self, card, card_table, other_card)
        if not G.GAME.mutant_legendary_pool then
            G.GAME.mutant_legendary_pool = {}
        end
        G.GAME.mutant_legendary_pool.rate = 0.1
        G.GAME.mutant_legendary_pool.in_shop = true
    end
}

return {
	enabled = Showdown.config["Jokers"]["Normal"],
	list = {
            --- Sounds
			cronch,
            mado_no1,
            mado_no2,
            uro_no1,
            uro_no2,
            uro_no3,
            minna_no,
            blinking,
            --- Rarities
            final,
            --- Jokers
            crouton,
            crime_scene,
            ping_pong,
            color_splash,
            blue,
            golden_roulette,
            empty_joker,
            --baby_jimbo,
            parmesan,
            chaos_card,
            one_doller,
            revolution,
            sinful_joker,
            egg_drawing,
            what_a_steel,
            diplomatic_immunity,
            nitroglycerin,
            sick_trick,
            jaws,
            red_coins,
            money_cutter,
            passage_of_time,
            colored_glasses,
            joker_variance_authorithy,
            banana,
            label,
            silver_stars,
            gold_star,
            shady_dealer,
            yipeee,
            fruit_sticker,
            whatever,
            madotsuki,
            urotsuki,
            minnatsuki,
            pop_up,
            matplotlib,
            window,
            break_the_ice,
            funnel,
            jimbocoin,
            thorn_photograph,
            atom,
            stencil,
            o_fortuna,
            ena,
            mouthwash,
            esotericism,
            pegman,
            overjoy,
            infection,
            love_letter,
            brain_battery,
            rules_card,
            terms_of_service,
            encore,
            soul_avarice,
            soul_malice,
            soul_fortune,
            soul_gambling,
            blinking_block,
            tooth_decay,
            gamma_pulse,
            patchwork_joker,
            gummy_worms,
            deviantt,
            abominationn,
            mutant,
            --- Ranks Jokers
            pinpoint,
            math_teacher,
            gruyere,
            mirror,
            spotted_joker,
            bacteria,
            sim_card,
            strainer,
            billiard,
            hiding_details,
            world_map,
            cake,
            floating_point,
            turbo,
            nothing_matter,
            warped_joker,
            point_of_no_return,
            --- Final Jokers
            jimbo_makeup,
			jimbo_hat,
			jimbo_bells,
			jimbo_collar,
			gary_mccready,
			ultimate_joker,
			locks,
			unshackled_joker,
            --- Mathematic Jokers
            substitute_teacher,
            --- Logic Jokers
            binary_10111,
            --- Sticker Jokers
            dealer_luigi,
            --- Challenge Jokers
            bugged_seed,
    },
	atlases = {
		{key = "showdown_jokers", path = "Jokers/Jokers.png", px = 71, py = 95},
        {key = "showdown_banana", path = "Jokers/banana.png", px = 35, py = 43},
        {key = "showdown_jokers_fusion", path = "CrossMod/FusionJokers/Jokers.png", px = 71, py = 95, mod_compat = "FusionJokers"},
	},
	exec = function()
        local updateRef = Game.update
        local banana_dt = 0
        function Game:update(dt)
            updateRef(self, dt)
            banana_dt = banana_dt + dt
            if G.P_CENTERS.j_showdown_banana and banana_dt > 0.1 then
                banana_dt = 0
                local obj = G.P_CENTERS.j_showdown_banana
                obj.pos.x = obj.pos.x < 7 and obj.pos.x + 1 or 0
            end
        end

        function reroll_tags_and_blind(blind)
            local blindUpper = blind:gsub("^%l", string.upper)
            G.GAME.round_resets.blind_tags[blindUpper] = get_next_tag_key()
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                play_sound('other1')
                G.blind_select_opts[blind]:set_role({xy_bond = 'Weak'})
                G.blind_select_opts[blind].alignment.offset.y = 20
                return true
                end
            }))
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.3,
                func = (function()
                    local par = G.blind_select_opts[blind].parent

                    G.blind_select_opts[blind]:remove()
                    G.blind_select_opts[blind] = UIBox{
                        T = {par.T.x, 0, 0, 0, },
                        definition =
                        {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
                            UIBox_dyn_container({create_UIBox_blind_choice(blindUpper)},false,get_blind_main_colour(blindUpper))
                        }},
                        config = {align="bmi",
                                offset = {x=0,y=G.ROOM.T.y + 9},
                                major = par,
                                xy_bond = 'Weak'
                                }
                    }
                    par.config.object = G.blind_select_opts[blind]
                    par.config.object:recalculate()
                    G.blind_select_opts[blind].parent = par
                    G.blind_select_opts[blind].alignment.offset.y = 0
                    return true
                end)
            }))
        end

        G.FUNCS.no_sell_madotsuki = function()
            if pseudorandom('mado_no') < 1/2 then
                play_sound('showdown_mado_no1')
            else
                play_sound('showdown_mado_no2')
            end
        end

        G.FUNCS.no_sell_urotsuki = function()
            local no = pseudorandom('uro_no')
            if no < 1/3 then
                play_sound('showdown_uro_no1')
            elseif no > 2/3 then
                play_sound('showdown_uro_no2')
            else
                play_sound('showdown_uro_no3')
            end
        end

        G.FUNCS.no_sell_minnatsuki = function()
            play_sound('showdown_minna_no')
        end

        local GFUNCSCan_sell_cardRef = G.FUNCS.can_sell_card
        G.FUNCS.can_sell_card = function(e)
            GFUNCSCan_sell_cardRef(e)
            local card = e.config.ref_table
            if not card:can_sell_card() and Showdown.config["Technical"]["Easter Eggs"] then
                if card.ability.name == 'madotsuki' then
                    e.config.button_alt = 'no_sell_madotsuki'
                elseif card.ability.name == 'urotsuki' then
                    e.config.button_alt = 'no_sell_urotsuki'
                elseif card.ability.name == 'minnatsuki' then
                    e.config.button_alt = 'no_sell_minnatsuki'
                end
            end
        end

        local UIElementClickRef = UIElement.click
        function UIElement:click()
            UIElementClickRef(self)
            if self.config.button_alt then
                G.FUNCS[self.config.button_alt](self)
            end
        end

        local TagApply_to_runRef = Tag.apply_to_run
        function Tag:apply_to_run(_context)
            if self.triggered then return end
            if self.config.type == _context.type or next(find_joker('funnel')) then
                SMODS.calculate_context({using_tag = true, tag = self})
            end
            if #find_joker('funnel') == 0 then
                return TagApply_to_runRef(self, _context)
            else
                G.E_MANAGER:add_event(Event({
                delay = 0.4,
                trigger = 'after',
                func = (function()
                    attention_text({
                        text = '-',
                        colour = G.C.WHITE,
                        scale = 1, 
                        hold = 0.3/G.SETTINGS.GAMESPEED,
                        cover = self.HUD_tag,
                        cover_colour = G.C.CHIPS,
                        align = 'cm',
                        })
                    play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                    play_sound('negative', 1.6 + math.random()*0.1, 0.4)
                    return true
                end)
                }))
                G.E_MANAGER:add_event(Event({
                    func = (function()
                        self.HUD_tag.states.visible = false
                        return true
                    end)
                }))
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.7,
                    func = (function()
                        self:remove()
                        return true
                    end)
                }))
                self.triggered = true
            end
        end

        function check_for_area_space(card, area)
            local highlighted = {}
            local has_nothing_matter = next(find_joker('nothing_matter'))
            for _, _card in pairs(area.highlighted) do
                if not (SMODS.is_zero(_card) and has_nothing_matter) then
                    table.insert(highlighted, _card)
                end
            end
            if not (SMODS.is_zero(card) and has_nothing_matter) then
                table.insert(highlighted, card)
            end
            return #highlighted >= area.config.highlighted_limit + 1
        end

        function play_check()
            local highlighted = {}
            local has_nothing_matter = next(find_joker('nothing_matter'))
            for _, card in pairs(G.hand.highlighted) do
                if not (SMODS.is_zero(card) and has_nothing_matter) then
                    table.insert(highlighted, card)
                end
            end
            return #highlighted > math.max(G.GAME.starting_params.play_limit, 1)
        end

        function discard_check()
            local highlighted = {}
            local has_nothing_matter = next(find_joker('nothing_matter'))
            for _, card in pairs(G.hand.highlighted) do
                if not (SMODS.is_zero(card) and has_nothing_matter) then
                    table.insert(highlighted, card)
                end
            end
            return #highlighted > math.max(G.GAME.starting_params.discard_limit, 1)
        end

        local CardSellCard = Card.sell_card
        function Card:sell_card()
            if not G.GAME.sold_jokers then G.GAME.sold_jokers = {} end
            if findInTable(self.config.center.key, G.GAME.sold_jokers) == -1 then table.insert(G.GAME.sold_jokers, self.config.center.key) end
            CardSellCard(self)
        end

		local cardSetDebuffRef = Card.set_debuff
		function Card:set_debuff(should_debuff)
			if self.ability.showdown_soul_fortune then self.debuff = true
			else cardSetDebuffRef(self, should_debuff) end
		end

        function change_blinking_block_states()
            if G.jokers then
                local bip = 0
                local function juice(cards)
                    G.E_MANAGER:add_event(Event({ trigger = 'after', delay = 0.5, blocking = false, blockable = false, timer = 'REAL', func = (function()
                        if bip < 3 then
                            if bip == 0 then play_sound('showdown_blinking') end
                            for _, _card in pairs(cards) do _card:juice_up(0.2, 0.2) end
                            bip = bip + 1
                            juice(cards)
                        else
                            for _, _card in pairs(cards) do
                                _card:juice_up(0.3, 0.3)
                                _card.ability.extra.is_mult = not _card.ability.extra.is_mult
                                _card.children.center:set_sprite_pos(coordinate(_card.ability.extra.is_mult and 95 or 96))
                            end
                        end
                    return true end)}))
                end
                local blinking_blocks = find_joker('blinking_block')
                if #blinking_blocks > 0 then juice(blinking_blocks) end
            end
        end

        local poll_obj_ref = SMODS.poll_object
        function SMODS.poll_object(args) -- Thanks All in Jest
            if args.type == 'Joker' and args.rarities == nil and G.GAME.mutant_legendary_pool ~= nil and G.GAME.mutant_legendary_pool.in_shop then
                local p = pseudorandom('rarity'..G.GAME.round_resets.ante..(args.append or ''))
                --print(p..' '..G.GAME.mutant_legendary_pool.rate)
                if p < G.GAME.mutant_legendary_pool.rate then
                    args.rarities = {'Legendary'}
                end
            end
            return poll_obj_ref(args)
        end

        Showdown.tag_related_joker['j_diet_cola'] = true
        Showdown.tag_related_joker['j_showdown_label'] = true
        Showdown.tag_related_joker['j_showdown_pop_up'] = true
        Showdown.tag_related_joker['j_showdown_funnel'] = true
        -- SMODS.Mods check with mod id
        if (SMODS.Mods["Cryptid"] or {}).can_load then
            Showdown.tag_related_joker['j_cry_pickle'] = true
            Showdown.tag_related_joker['j_cry_pity_prize'] = true
            Showdown.tag_related_joker['j_cry_smallestm'] = true
            Showdown.tag_related_joker['j_cry_energia'] = true
            Showdown.binary_10111_joker_consumeable_type_colours['Code'] = HEX("14b341")
        end
        if (SMODS.Mods["Bunco"] or {}).can_load then
            Showdown.tag_related_joker['j_bunc_zero_shapiro'] = true
            Showdown.tag_related_joker['j_bunc_headache'] = true
            Showdown.binary_10111_joker_consumeable_type_colours['Polymino'] = G.C.BUNCO_VIRTUAL_DARK
            table.insert(Showdown.rules_card_blacklist, 'j_bunc_conquest') -- it crashes the game lol
        end
        if (SMODS.Mods["UnStable"] or {}).can_load then
            Showdown.tag_related_joker['j_unstb_king_of_pop'] = true
            Showdown.tag_related_joker['j_unstb_quintuplets'] = true
            Showdown.tag_related_joker['j_unstb_graphic_card'] = true
            Showdown.binary_10111_joker_consumeable_type_colours['Auxiliary'] = G.C.UNSTB_AUX
        end
        if (SMODS.Mods["Ortalab"] or {}).can_load then
            Showdown.tag_related_joker['j_ortalab_mystery_soda'] = true
            Showdown.binary_10111_joker_consumeable_type_colours['Loteria'] = G.ARGS.LOC_COLOURS['ortalab_loteria']
            Showdown.binary_10111_joker_consumeable_type_colours['Zodiac'] = G.ARGS.LOC_COLOURS['ortalab_zodiac']
            Showdown.binary_10111_joker_consumeable_type_colours['Mythos'] = G.ARGS.LOC_COLOURS['ortalab_mythos']
        end
        if (SMODS.Mods["MoreFluff"] or {}).can_load then
            Showdown.tag_related_joker['j_mf_rosetinted'] = true
            Showdown.binary_10111_joker_consumeable_type_colours['Rotarot'] = G.C.SECONDARY_SET.Rotarot
            Showdown.binary_10111_joker_consumeable_type_colours['Colour'] = HEX("4f6367")
            Showdown.binary_10111_joker_consumeable_type_colours['Shape'] = HEX("316ea0")
        end
        if (SMODS.Mods["bb"] or {}).can_load then
            Showdown.tag_related_joker['j_bb_gifts'] = true
        end
        if (SMODS.Mods["aikoyorisshenanigans"] or {}).can_load then
            Showdown.tag_related_joker['j_aikoyorisshenanigans_pandora_paradoxxx'] = true
        end
        if (SMODS.Mods["allinjest"] or {}).can_load then
            Showdown.tag_related_joker['j_allinjest_little_devil'] = true
            Showdown.tag_related_joker['j_allinjest_fulehung'] = true
            Showdown.tag_related_joker['j_allinjest_ijoker_co'] = true
            Showdown.tag_related_joker['j_allinjest_sot'] = true
            Showdown.tag_related_joker['j_allinjest_entropy'] = true
            Showdown.tag_related_joker['j_allinjest_tagart'] = true
            Showdown.tag_related_joker['j_allinjest_downing_street'] = true
            Showdown.tag_related_joker['j_allinjest_mahoney'] = true
            Showdown.tag_related_joker['j_allinjest_illuminated_joker'] = true
            Showdown.tag_related_joker['j_allinjest_elf'] = true
            Showdown.tag_related_joker['j_allinjest_sanguine_joker'] = true
            Showdown.tag_related_joker['j_allinjest_death_of_a_salesman'] = true
            Showdown.tag_related_joker['j_allinjest_graffiti'] = true
            Showdown.tag_related_joker['j_allinjest_toto'] = true
        end

        if Cryptid and Cryptid.food then
            table.insert(Cryptid.food, 'j_showdown_gruyere')
            table.insert(Cryptid.food, 'j_showdown_parmesan')
            table.insert(Cryptid.food, 'j_showdown_banana')
            table.insert(Cryptid.food, 'j_showdown_cake')
            table.insert(Cryptid.food, 'j_showdown_mouthwash')
            table.insert(Cryptid.food, 'j_showdown_gummy_worms')
        end
	end,
    order = 2,
}