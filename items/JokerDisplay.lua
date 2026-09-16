local def_list = { jokers = {}, blinds = {} }

-- Jokers

--[[
table.insert(def_list.jokers, {
    key = 'versatile_joker',
    text = {
        -- Red Deck
        { text = "$", colour = G.C.GOLD },
        { ref_table = "card.ability.extra", ref_value = "money", retrigger_type = "mult", colour = G.C.GOLD },
        -- Blue Deck
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "x_mult", retrigger_type = "exp" }
            },
            colour = G.C.MULT
        },
        -- Green Deck
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars" },
        -- Black Deck
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xchips", retrigger_type = "exp" }
            },
            colour = G.C.CHIPS
        },
    },
    reminder_text = {
        -- Yellow Deck
        { text = "(" },
        { text = "$", colour = G.C.GOLD },
        { ref_table = "card", ref_value = "sell_cost", colour = G.C.GOLD },
        { text = ")" },
        -- Green Deck
        { ref_table = "card.joker_display_values", ref_value = "localized_text" },
    },
    --reminder_text_config = { scale = 0.35 },
    style_function = function(card, text, reminder_text, extra)
        if G.STAGE == G.STAGES.RUN and text and reminder_text and extra and not card.joker_display_set then
            if G.GAME.selected_back.name ~= 'Red Deck' then
                text.children[1] = nil
                text.children[2] = nil
            end
            if G.GAME.selected_back.name ~= 'Blue Deck' then
                text.children[3] = nil
            end
            if G.GAME.selected_back.name ~= 'Yellow Deck' then
                reminder_text.children[1] = nil
                reminder_text.children[2] = nil
                reminder_text.children[3] = nil
                reminder_text.children[4] = nil
            end
            if G.GAME.selected_back.name ~= 'Green Deck' then
                text.children[4] = nil
                text.children[5] = nil
                reminder_text.children[5] = nil
            end
            if G.GAME.selected_back.name ~= 'Black Deck' then
                text.children[6] = nil
            end
            card.joker_display_set = true
        end
        return false
    end,
    calc_function = function(card)
        if G.GAME.selected_back.name ~= 'Green Deck' then
            card.joker_display_values.dollars = G.GAME and G.GAME.dollars and math.max(math.min(math.floor(G.GAME.dollars / 5), G.GAME.interest_cap / 5), 0) * 1
            card.joker_display_values.localized_text = "(" .. localize("k_round") .. ")"
        end
    end
})
]]

table.insert(def_list.jokers, {
    key = 'crouton',
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    calc_function = function(card)
        local playing_hand = next(G.play.cards)
        local count = 0
        for _, playing_card in ipairs(G.hand.cards) do
            if playing_hand or not playing_card.highlighted then
                if not (playing_card.facing == 'back') and not playing_card.debuff then
                    count = count + JokerDisplay.calculate_card_triggers(playing_card, nil, true)
                end
            end
        end
        card.joker_display_values.x_mult = card.ability.extra.x_mult ^ count
    end
})

table.insert(def_list.jokers, {
    key = 'pinpoint',
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_chips", retrigger_type = "exp" }
            },
            border_colour = G.C.CHIPS,
        }
    },
    calc_function = function(card)
        local playing_hand = next(G.play.cards)
        local count = 0
        for _, playing_card in ipairs(G.hand.cards) do
            if playing_hand or not playing_card.highlighted then
                if not (playing_card.facing == 'back') and not playing_card.debuff and SMODS.is_zero(playing_card) then
                    count = count + JokerDisplay.calculate_card_triggers(playing_card, nil, true)
                end
            end
        end
        card.joker_display_values.x_chips = card.ability.extra.x_chips ^ count
    end
})

table.insert(def_list.jokers, {
    key = 'math_teacher',
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "chips", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.CHIPS },
})

table.insert(def_list.jokers, {
    key = 'gruyere',
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
})

table.insert(def_list.jokers, {
    key = 'mirror',
    retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
        --if held_in_hand then return 0 end
        return (SMODS.is_zero(playing_card) or SMODS.is_counterpart(playing_card)) and
            joker_card.ability.extra.retrigger * JokerDisplay.calculate_joker_triggers(joker_card) or 0
    end
})

table.insert(def_list.jokers, {
    key = 'crime_scene',
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    }
})

--table.insert(def_list.jokers, { key = 'ping_pong' })

--table.insert(def_list.jokers, { key = 'color_splash' })

table.insert(def_list.jokers, {
    key = 'blue',
    text = {
        { text = "+1" },
    },
    text_config = { colour = G.C.CHIPS }
})

table.insert(def_list.jokers, {
    key = 'spotted_joker',
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "chips", retrigger_type = "chips" }
    },
    text_config = { colour = G.C.CHIPS },
    reminder_text = {
        { text = "(" },
        { text = "0", colour = G.C.ORANGE },
        { text = ")" },
    },
    calc_function = function(card)
        if not next(G.play.cards) then
            local count = 0
            local text, _, scoring_hand = JokerDisplay.evaluate_hand()
            if text ~= 'Unknown' then
                for _, scoring_card in pairs(scoring_hand) do
                    if SMODS.is_zero(scoring_card) then
                        count = count + JokerDisplay.calculate_card_triggers(scoring_card, nil, true)
                    end
                end
            end
            local chips = 0
            for i = 1, count do
                chips = chips + card.ability.extra.chips + card.ability.extra.chip_mod * i
            end
            card.joker_display_values.chips = chips
        end
    end
})

table.insert(def_list.jokers, {
    key = 'golden_roulette',
    text = {
        { text = "+$" },
        { ref_table = "card.ability.extra", ref_value = "money", retrigger_type = "mult" },
    },
    text_config = { colour = G.C.GOLD },
    extra = {
        {
            { text = "(" },
            { ref_table = "card.joker_display_values", ref_value = "odds" },
            { text = ")" },
        }
    },
    extra_config = { colour = G.C.GREEN, scale = 0.3 },
    calc_function = function(card)
        local numerator, denominator = SMODS.get_probability_vars(card, 5, 6, 'golden_roulette')
        card.joker_display_values.odds = localize { type = 'variable', key = "jdis_odds", vars = { numerator, denominator } }
    end
})

--table.insert(def_list.jokers, { key = 'bacteria' })

table.insert(def_list.jokers, {
    key = 'empty_joker',
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
    reminder_text = {
        { text = "(0)" },
    },
    calc_function = function(card)
        local mult = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' then
            for _, scoring_card in pairs(scoring_hand) do
                if SMODS.is_zero(scoring_card) then
                    mult = card.ability.extra.mult
                end
            end
        end
        card.joker_display_values.mult = mult
    end
})

--table.insert(def_list.jokers, { key = 'baby_jimbo' })

--table.insert(def_list.jokers, { key = 'parmesan' })

--table.insert(def_list.jokers, { key = 'chaos_card' })

--table.insert(def_list.jokers, { key = 'sim_card' })

table.insert(def_list.jokers, {
    key = 'one_doller',
    text = {
        { text = "$" },
        { ref_table = "card.ability.extra", ref_value = "money", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.GOLD },
})

--table.insert(def_list.jokers, { key = 'revolution' })

table.insert(def_list.jokers, {
    key = 'fruit_sticker',
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    calc_function = function(card)
        local count = 0
        if G.jokers then
            for _, joker_card in ipairs(G.jokers.cards) do
                for k, w in pairs(joker_card.ability) do
                    if SMODS.Sticker.obj_table[k] and w then
                        count = count + 1
                    end
                end
            end
        end
        card.joker_display_values.x_mult = card.ability.extra.x_mult ^ count
    end
})

table.insert(def_list.jokers, {
    key = 'sinful_joker',
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
    calc_function = function(card)
        local mult = 0
        if G.jokers then
            for _, joker_card in ipairs(G.jokers.cards) do
                local name = joker_card.ability.name
                if name == 'Greedy Joker' or name == 'Lusty Joker' or name == 'Wrathful Joker' or name == 'Gluttonous Joker' then
                    mult = mult + card.ability.extra.scaling
                end
            end
        end
        card.joker_display_values.mult = mult
    end
})

--table.insert(def_list.jokers, { key = 'egg_drawing' })

--table.insert(def_list.jokers, { key = 'jimbo_makeup' })

--table.insert(def_list.jokers, { key = 'jimbo_hat' })

--table.insert(def_list.jokers, { key = 'jimbo_bells' })

--table.insert(def_list.jokers, { key = 'jimbo_collar' })

--table.insert(def_list.jokers, { key = 'gary_mccready' })

table.insert(def_list.jokers, {
    key = 'ultimate_joker',
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "G.GAME", ref_value = "round", retrigger_type = "exp" }
            },
            border_colour = G.C.SECONDARY_SET.Tarot,
        }
    }
})

table.insert(def_list.jokers, {
    key = 'strainer',
    text = {
        { text = "$" },
        { ref_table = "card.ability.extra", ref_value = "money" }
    },
    text_config = { colour = G.C.GOLD },
})

table.insert(def_list.jokers, { -- might need a rework
    key = 'billiard',
    retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
        local hand = #G.hand.highlighted > 0 and G.hand.highlighted or G.play.cards
        if hand then
            local idx = findInTable(playing_card, hand)
            local rep = 0
            if idx > -1 then
                if idx > 1 and SMODS.is_zero(hand[idx-1]) then
                    rep = rep + 1
                end
                if idx < #hand and SMODS.is_zero(hand[idx+1]) then
                    rep = rep + 1
                end
            end
            return rep * JokerDisplay.calculate_joker_triggers(joker_card)
        end
    end
})

--table.insert(def_list.jokers, { key = 'hiding_details' })

table.insert(def_list.jokers, {
    key = 'what_a_steel',
    text = {
        { ref_table = "card.ability.extra", ref_value = "steel_tally" },
        { text = "%" }
    },
    text_config = { colour = G.C.GOLD },
})

--table.insert(def_list.jokers, { key = 'diplomatic_immunity' })

--table.insert(def_list.jokers, { key = 'nitroglycerin' })

table.insert(def_list.jokers, {
    key = 'substitute_teacher',
    text = {
        { text = "+", colour = G.C.CHIPS },
        { ref_table = "card.joker_display_values", ref_value = "chips", retrigger_type = "mult", colour = G.C.CHIPS },
        { text = " +", colour = G.C.MULT },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult", colour = G.C.MULT }
    },
    calc_function = function(card)
        card.joker_display_values.chips = (G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.mathematic or 0) * card.ability.extra.chips_scale
        card.joker_display_values.mult = (G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.mathematic or 0) * card.ability.extra.mult_scale
    end
})

table.insert(def_list.jokers, {
    key = 'world_map',
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "chips", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.CHIPS },
})

--table.insert(def_list.jokers, { key = 'bugged_seed' })

--table.insert(def_list.jokers, { key = 'sick_trick' })

table.insert(def_list.jokers, {
    key = 'jaws',
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "chips", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.CHIPS },
})

table.insert(def_list.jokers, {
    key = '4_locks',
    text = {
        { ref_table = "card.joker_display_values", ref_value = "lock1", colour = G.C.RED },
        { text = " " },
        { ref_table = "card.joker_display_values", ref_value = "lock2", colour = G.C.BLUE },
        { text = " " },
        { ref_table = "card.joker_display_values", ref_value = "lock3", colour = G.C.GREEN },
        { text = " " },
        { ref_table = "card.joker_display_values", ref_value = "lock4", colour = G.C.GOLD }
    },
    calc_function = function(card)
        for i=1, #card.ability.extra.locks do
            card.joker_display_values['lock'..i] = card.ability.extra.locks[i] and 'O' or 'X'
        end
    end
})

table.insert(def_list.jokers, {
    key = 'unshackled_joker',
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            },
            border_colour = G.C.MULT,
        }
    },
    calc_function = function(card)
        local text, _, _ = JokerDisplay.evaluate_hand()
        local x_mult = 1
        if text ~= "Unknown" and G.GAME.hands[text] then
            x_mult = G.GAME.hands[text].level
        end
        card.joker_display_values.x_mult = x_mult
    end
})

table.insert(def_list.jokers, {
    key = 'red_coins',
    text = {
        { text = "$" },
        { ref_table = "card.ability.extra", ref_value = "money", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.GOLD },
})

table.insert(def_list.jokers, {
    key = 'money_cutter',
    text = {
        { text = "$" },
        { ref_table = "card.ability.extra", ref_value = "money", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.GOLD },
    reminder_text = {
        { text = "(No interest)" },
    }
})

table.insert(def_list.jokers, {
    key = 'passage_of_time',
    text = {
        { text = "+", colour = G.C.CHIPS },
        { ref_table = "card.ability.extra", ref_value = "chips_mult", retrigger_type = "mult", colour = G.C.CHIPS },
        { text = " +", colour = G.C.MULT },
        { ref_table = "card.ability.extra", ref_value = "chips_mult", retrigger_type = "mult", colour = G.C.MULT }
    }
})

table.insert(def_list.jokers, {
    key = 'colored_glasses',
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
})

table.insert(def_list.jokers, {
    key = 'joker_variance_authorithy',
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
})

table.insert(def_list.jokers, {
    key = 'banana',
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
    extra = {
        {
            { text = "(" },
            { ref_table = "card.joker_display_values", ref_value = "odds" },
            { text = ")" },
        }
    },
    extra_config = { colour = G.C.GREEN, scale = 0.3 },
    calc_function = function(card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, 2, 'banana')
        card.joker_display_values.odds = localize { type = 'variable', key = "jdis_odds", vars = { numerator, denominator } }
    end
})

table.insert(def_list.jokers, {
    key = 'label',
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "active_text" },
    },
    calc_function = function(card)
        local rerolleable = card.ability.extra.can_reroll
        card.joker_display_values.active = rerolleable
        card.joker_display_values.active_text = localize(rerolleable and 'k_can_reroll' or 'k_cannot_reroll')
    end,
    style_function = function(card, text, reminder_text, extra)
        if reminder_text and reminder_text.children[1] then
            reminder_text.children[1].config.colour = card.joker_display_values.active and G.C.GREEN or G.C.RED
            reminder_text.children[1].config.scale = card.joker_display_values.active and 0.35 or 0.3
            return true
        end
        return false
    end
})

--table.insert(def_list.jokers, { key = 'silver_stars' })

table.insert(def_list.jokers, {
    key = 'gold_star',
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xchips", retrigger_type = "exp" }
            },
            border_colour = G.C.CHIPS,
        }
    }
})

--table.insert(def_list.jokers, { key = 'shady_dealer' })

--table.insert(def_list.jokers, { key = 'yipeee' })

--table.insert(def_list.jokers, { key = 'dealer_luigi' })

table.insert(def_list.jokers, {
    key = 'whatever',
    text = {
        { text = "+" },
        { ref_table = "card", ref_value = "sell_cost", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.SECONDARY_SET.Planet },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "last_hand", colour = G.C.ORANGE },
        { text = ")" },
    },
    calc_function = function(card)
        card.joker_display_values.last_hand = G.GAME.last_played_hand or localize('k_none')
    end
})

table.insert(def_list.jokers, {
    key = 'madotsuki',
    extra = {
        {
            { text = "(" },
            { ref_table = "card.joker_display_values", ref_value = "odds" },
            { text = ")" },
        }
    },
    extra_config = { colour = G.C.GREEN, scale = 0.3 },
    calc_function = function(card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.edition_chance, 'madotsuki')
        card.joker_display_values.odds = localize { type = 'variable', key = "jdis_odds", vars = { numerator, denominator } }
    end
})

table.insert(def_list.jokers, {
    key = 'urotsuki',
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "x_chips", retrigger_type = "exp" }
            },
            border_colour = G.C.CHIPS,
        }
    }
})

table.insert(def_list.jokers, {
    key = 'minnatsuki',
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
    calc_function = function(card)
        if not next(G.play.cards) then
            local count = 0
            if G.jokers then
                for _, joker_card in ipairs(G.jokers.cards) do
                    if card ~= joker_card then
                        count = count + 1
                    end
                end
            end
            card.joker_display_values.mult = count * (card.ability.extra.mult + card.ability.extra.mult_scale)
        end
    end
})

--table.insert(def_list.jokers, { key = 'pop_up' })

table.insert(def_list.jokers, {
    key = 'matplotlib',
    text = {
        { text = "+", colour = G.C.CHIPS },
        { ref_table = "card.joker_display_values", ref_value = "chips", retrigger_type = "mult", colour = G.C.CHIPS },
        { text = " +", colour = G.C.MULT },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult", colour = G.C.MULT }
    },
    calc_function = function(card)
        local chips_count = 0
        local mult_count = 0
        local other_way = false
        if G.jokers then
            for _, joker_card in ipairs(G.jokers.cards) do
                if card == joker_card then
                    other_way = true
                elseif other_way then
                    mult_count = mult_count + 1
                else
                    chips_count = chips_count + 1
                end
            end
        end
        card.joker_display_values.chips = chips_count * card.ability.extra.chips
        card.joker_display_values.mult = mult_count * card.ability.extra.mult
    end
})

table.insert(def_list.jokers, {
    key = 'cake',
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
})

table.insert(def_list.jokers, {
    key = 'window',
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
})

table.insert(def_list.jokers, {
    key = 'break_the_ice',
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "chips", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.CHIPS },
})

table.insert(def_list.jokers, {
    key = 'funnel',
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "x_chips", retrigger_type = "exp" }
            },
            border_colour = G.C.CHIPS,
        }
    }
})

table.insert(def_list.jokers, {
    key = 'jimbocoin',
    text = {
        { text = "+$" },
        { ref_table = "card.ability.extra", ref_value = "money", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.GOLD },
})

table.insert(def_list.jokers, {
    key = 'thorn_photograph',
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "localized_text", colour = G.C.ORANGE },
        { text = ")" },
    },
    calc_function = function(card)
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        local face_cards = {}
        if text ~= 'Unknown' then
            for _, scoring_card in pairs(scoring_hand) do
                if not scoring_card:is_face() then
                    table.insert(face_cards, scoring_card)
                end
            end
        end
        local first_face = JokerDisplay.calculate_leftmost_card(face_cards)
        card.joker_display_values.x_mult = first_face and
            (card.ability.extra.x_mult ^ JokerDisplay.calculate_card_triggers(first_face, scoring_hand)) or 1
        card.joker_display_values.localized_text = localize("k_numbered_cards")
    end
})

table.insert(def_list.jokers, {
    key = 'atom',
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "localized_text", colour = G.C.ORANGE },
        { text = ")" },
    },
    calc_function = function(card)
        card.joker_display_values.localized_text = localize('High Card', "poker_hands")
    end
})

table.insert(def_list.jokers, {
    key = 'stencil',
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "scaling" },
        { text = "/" },
        { ref_table = "card.ability.extra", ref_value = "scaling" },
        { text = ")" },
    },
    calc_function = function(card)
        card.joker_display_values.scaling = card.ability.extra.scaling - card.ability.extra.scaling_progress
    end
})

table.insert(def_list.jokers, {
    key = 'o_fortuna',
    extra = {
        {
            { text = "(" },
            { ref_table = "card.joker_display_values", ref_value = "odds" },
            { text = ")" },
        }
    },
    extra_config = { colour = G.C.GREEN, scale = 0.3 },
    calc_function = function(card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.duplication_chance, 'o_fortuna')
        card.joker_display_values.odds = localize { type = 'variable', key = "jdis_odds", vars = { numerator, denominator } }
    end
})

table.insert(def_list.jokers, {
    key = 'floating_point',
    text = {
        { text = "+$", colour = G.C.GOLD },
        { ref_table = "card.joker_display_values", ref_value = "money" },
    },
    text_config = { colour = G.C.GOLD },
    calc_function = function(card)
        local count_non_face = 0
        local count_face = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' then
            for _, scoring_card in pairs(scoring_hand) do
                if SMODS.is_counterpart(scoring_card) then
                    if scoring_card:is_face() then
                        count_face = count_face + JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                    else
                        count_non_face = count_non_face + JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                    end
                end
            end
        end
        card.joker_display_values.money = count_non_face * card.ability.extra.money + count_face * card.ability.extra.money_face
    end
})

table.insert(def_list.jokers, {
    key = 'ena',
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "x_chips", retrigger_type = "exp" }
            },
            border_colour = G.C.CHIPS,
        }
    }
})

table.insert(def_list.jokers, {
    key = '10111',
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "localized_text", colour = G.C.ORANGE },
        { text = ")" },
    },
    calc_function = function(card)
        card.joker_display_values.localized_text = localize('k_'..card.ability.extra.consumeable_type:lower())
    end,
    style_function = function(card, text, reminder_text, extra)
        if reminder_text and reminder_text.children[2] then
            reminder_text.children[2].config.colour = Showdown.binary_10111_joker_consumeable_type_colours[card.ability.extra.consumeable_type] or G.C.ORANGE
        end
        return false
    end
})

--table.insert(def_list.jokers, { key = 'turbo' })

--table.insert(def_list.jokers, { key = 'mouthwash' })

--table.insert(def_list.jokers, { key = 'esotericism' })

table.insert(def_list.jokers, {
    key = 'pegman',
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "count", retrigger_type = "mult" },
    },
    text_config = { colour = G.C.ORANGE },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "localized_text", colour = G.C.ORANGE },
        { text = ")" },
    },
    calc_function = function(card)
        local no_aces = true
        for _, _card in pairs(G.play.cards) do
            no_aces = no_aces and _card:get_id() ~= 14
        end
        if no_aces then
            for _, _card in pairs(G.hand.cards) do
                no_aces = no_aces and _card:get_id() ~= 14
            end
        end
        card.joker_display_values.count = no_aces and 1 or 0
        card.joker_display_values.localized_text = localize("Ace", "ranks")
    end,
})

--table.insert(def_list.jokers, { key = 'overjoy' })

--table.insert(def_list.jokers, { key = 'nothing_matter' })

table.insert(def_list.jokers, {
    key = 'infection',
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "x_mult", retrigger_type = "exp" }
            },
        }
    }
})

table.insert(def_list.jokers, {
    key = 'love_letter',
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            },
        }
    },
    reminder_text = {
        { text = "(King, Queen)" },
    },
    calc_function = function(card)
        local x_mult = 1
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        local king = false
        local queen = false
        if text ~= 'Unknown' then
            for _, scoring_card in pairs(scoring_hand) do
                if not king and scoring_card:get_id() == 13 then king = true end
                if not queen and scoring_card:get_id() == 12 then queen = true end
                if king and queen and x_mult == 1 then
                    x_mult = card.ability.extra.x_mult
                end
            end
        end
        card.joker_display_values.x_mult = x_mult
    end
})

table.insert(def_list.jokers, {
    key = 'brain_battery',
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "x_chips", retrigger_type = "exp" }
            },
            border_colour = G.C.CHIPS,
        }
    }
})

table.insert(def_list.jokers, {
    key = 'warped_joker',
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "chips", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.CHIPS },
})

table.insert(def_list.jokers, {
    key = 'rules_card',
    reminder_text = {},
    calc_function = function(card)
        local copied_joker, copied_debuff = JokerDisplay.calculate_blueprint_copy(card)
        JokerDisplay.copy_display(card, copied_joker, copied_debuff)
    end,
    get_blueprint_joker = function(card)
        return card.ability.extra.reference_to_copied_card and card.ability.extra.reference_to_copied_card.calculate_joker and card.ability.extra.reference_to_copied_card
    end
})

table.insert(def_list.jokers, {
    key = 'terms_of_service',
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            },
        }
    },
    calc_function = function(card)
        card.joker_display_values.x_mult = 1 + (table_length(G.GAME.used_vouchers) * card.ability.extra.x_mult_scale) + ((G.GAME.starting_voucher_count or 0) * card.ability.extra.x_mult_scale)
    end
})

--table.insert(def_list.jokers, { key = 'point_of_no_return' })

table.insert(def_list.jokers, {
    key = 'encore',
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "chips", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.CHIPS },
})

table.insert(def_list.jokers, {
    key = 'soul_avarice',
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "x_mult", retrigger_type = "exp" }
            },
        }
    }
})

table.insert(def_list.jokers, {
    key = 'soul_malice',
    extra = {
        {
            { text = "(" },
            { ref_table = "card.joker_display_values", ref_value = "odds" },
            { text = ")" },
        }
    },
    extra_config = { colour = G.C.GREEN, scale = 0.3 },
    calc_function = function(card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.destruction_chance, 'soul_malice')
        card.joker_display_values.odds = localize { type = 'variable', key = "jdis_odds", vars = { numerator, denominator } }
    end
})

table.insert(def_list.jokers, {
    key = 'soul_fortune',
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "x_chips", retrigger_type = "exp" }
            },
            border_colour = G.C.CHIPS,
        }
    }
})

table.insert(def_list.jokers, {
    key = 'soul_gambling',
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "x_mult", retrigger_type = "exp" }
            },
        },
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "x_chips", retrigger_type = "exp" }
            },
            border_colour = G.C.CHIPS,
        }
    }
})

table.insert(def_list.jokers, {
    key = 'blinking_block',
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "value", retrigger_type = "exp" }
            },
            border_colour = G.C.XMULT,
        }
    },
    calc_function = function(card)
        card.joker_display_values.value = card.ability.extra.is_mult and card.ability.extra.x_mult or card.ability.extra.x_chips
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children[1] then
            text.children[1].config.colour = card.ability.extra.is_mult and G.C.XMULT or G.C.CHIPS
        end
        return false
    end
})

table.insert(def_list.jokers, {
    key = 'tooth_decay',
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
})

--table.insert(def_list.jokers, { key = 'gamma_pulse' })

table.insert(def_list.jokers, {
    key = 'patchwork_joker',
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "x_chips", retrigger_type = "exp" }
            },
            border_colour = G.C.CHIPS,
        }
    }
})

table.insert(def_list.jokers, {
    key = 'gummy_worms',
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "x_chips", retrigger_type = "exp" }
            },
            border_colour = G.C.CHIPS,
        }
    }
})

table.insert(def_list.jokers, {
    key = 'deviantt',
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "count", colour = G.C.ORANGE },
        { text = "x" },
        { ref_table = "card.joker_display_values", ref_value = "localized_text", colour = G.C.RARITY[4] },
        { text = ")" },
    },
    calc_function = function(card)
        local count = 0
        if G.jokers then
            for _, joker_card in ipairs(G.jokers.cards) do
                if joker_card:is_rarity("Legendary") or joker_card:is_rarity("showdown_Final") then
                    count = count + 1
                end
            end
        end
        card.joker_display_values.count = count
        card.joker_display_values.localized_text = localize("k_legendary")
    end,
    mod_function = function(card, mod_joker)
        return { x_chips = ((card:is_rarity("Legendary") or card:is_rarity("showdown_Final")) and mod_joker.ability.extra.x_chips ^ JokerDisplay.calculate_joker_triggers(mod_joker) or nil) }
    end
})

--table.insert(def_list.jokers, { key = 'abominationn' })

--table.insert(def_list.jokers, { key = 'mutant' })

-- Blinds
-- (Chess blinds are excluded because Blind display is used only for Matador and Matador only works for Boss Blinds)

--table.insert(def_list.blinds, { key = 'latch' })

--[[
table.insert(def_list.blinds, {
    key = 'patient',
    trigger_function = function(blind, text, poker_hands, scoring_hand, full_hand)
        return G.GAME.current_round.hands_left > 1
    end
})

table.insert(def_list.blinds, {
    key = 'wasteful',
    trigger_function = function(blind, text, poker_hands, scoring_hand, full_hand)
        return G.GAME.current_round.discards_left > 0
    end
})

table.insert(def_list.blinds, {
    key = 'shameful',
    trigger_function = function(blind, text, poker_hands, scoring_hand, full_hand)
        local unenhanced = false
		for _, card in ipairs(full_hand) do
            if card then
			    unenhanced = unenhanced or card.config.center == G.P_CENTERS.c_base
            end
		end
		return unenhanced
    end
})

table.insert(def_list.blinds, {
    key = 'brick',
    trigger_function = function(blind, text, poker_hands, scoring_hand, full_hand)
        if text ~= 'Unknown' then
            for _, scoring_card in pairs(scoring_hand) do
                if scoring_card and not SMODS.is_counterpart(scoring_card) then
                    return true
                end
            end
        end
        return false
    end
})

table.insert(def_list.blinds, {
    key = 'ceiling',
    trigger_function = function(blind, text, poker_hands, scoring_hand, full_hand)
        if text ~= 'Unknown' then
            local ranks = get_highest_ranks_from_deck(4)
            local highest = false
            for _, scoring_card in ipairs(scoring_hand) do
                if scoring_card and not highest then
                    highest = highest or findInTable(scoring_card.base.value, ranks) ~= -1
                end
            end
            return highest
        end
        return false
    end
})

table.insert(def_list.blinds, {
    key = 'emerald_shard',
    trigger_function = function(blind, text, poker_hands, scoring_hand, full_hand)
        if text ~= 'Unknown' then
            for _, scoring_card in pairs(scoring_hand) do
                if scoring_card and findInTable(scoring_card, G.GAME.emerald_shard_debuffed_cards) ~= -1 then
                    return true
                end
            end
        end
        return false
    end
})
]]--

return {
    enabled = JokerDisplay,
    exec = function ()
        for _, def in ipairs(def_list.jokers) do
            JokerDisplay.Definitions["j_showdown_"..def.key] = def
        end
        for _, def in ipairs(def_list.blinds) do
            JokerDisplay.Blind_Definitions["bl_showdown_"..def.key] = def
        end

        local JokerDisplayGet_display_areas = JokerDisplay.get_display_areas
        function JokerDisplay.get_display_areas()
            local areas = JokerDisplayGet_display_areas()
            table.insert(areas, G.rules_card_jokers)
            return areas
        end
    end,
    order = 3,
}