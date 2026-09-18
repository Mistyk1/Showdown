local jean_paul = {
    type = 'Joker',
    key = 'jean_paul',
    name = 'jean_paul',
	atlas = "showdown_jokers",
	pos = coordinate(1),
    config = {extra = {talk = 0, inBlind = false}},
    rarity = 1, cost = 2,
    blueprint_compat = false, perishable_compat = false, eternal_compat = true,
    calculate = function(self, card, context)
        if card.hasSpeech and not context.blueprint and not context.repetition and card.area ~= G.rules_card_jokers then
            if context.end_of_round and not context.individual then
                card.ability.extra.inBlind = false
                say(card, {blabla = ('end_of_round'), prob = 2})
            elseif context.open_booster then
                say(card, {blabla = ('open_booster'), prob = 3})
            elseif context.buying_card then
                if context.card == card then
                    say(card, {blabla = ('buying_self'), guaranteed = true})
                elseif context.card.ability.name == 'jean_paul' and context.card ~= card then
                    say(card, {blabla = ('buying_other_self'), guaranteed = true})
                else
                    say(card, {blabla = ('buying_card'), prob = 2})
                end
            elseif context.selling_card then
                if context.card == card then
                    -- funny sound
                    check_for_unlock({type = 'sell_jean_paul'})
                elseif context.card.ability.name == 'jean_paul' and context.card ~= card then
                    say(card, {blabla = ('selling_other_self'), guaranteed = true})
                else
                    say(card, {blabla = ('selling_card'), prob = 3})
                end
            elseif context.reroll_shop then
                say(card, {blabla = ('reroll_shop'), prob = 4})
            elseif context.ending_shop then
                say(card, {blabla = ('ending_shop'), prob = 2})
            elseif context.skip_blind then
                say(card, {blabla = ('skip_blind'), prob = 2})
            elseif context.skipping_booster then
                say(card, {blabla = ('skipping_booster'), prob = 3})
            elseif context.setting_blind and not card.getting_sliced then
                card.ability.extra.inBlind = true
                say(card, {blabla = ('setting_blind'), prob = 3})
            elseif context.using_consumeable then
                if context.consumeable.ability.set == 'Tarot' then
                    say(card, {blabla = ('using_tarot'), prob = 2, quotesNb = context.consumeable.ability.name == 'The World' and 11})
                elseif context.consumeable.ability.set == 'Planet' then
                    say(card, {blabla = ('using_planet'), prob = 2})
                elseif context.consumeable.ability.set == 'Spectral' then
                    say(card, {blabla = ('using_spectral'), prob = 2})
                elseif context.consumeable.ability.set == 'Mathematic' then
                    say(card, {blabla = ('using_mathematic'), prob = 2})
                elseif context.consumeable.ability.set == 'Logic' then
                    say(card, {blabla = ('using_logic'), prob = 2})
                elseif context.consumeable.ability.set == 'Code' then
                    say(card, {blabla = ('using_code'), prob = 2})
                elseif context.consumeable.ability.set == 'Rotarot' then
                    say(card, {blabla = ('using_rotarot'), prob = 2})
                elseif context.consumeable.ability.set == 'Colour' then
                    say(card, {blabla = ('using_colour'), prob = 2})
                else
                    say(card, {blabla = ('using_unknown'), prob = 2})
                end
            end
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        SMODS.giveSpeech(card)
        check_for_unlock({type = 'get_jean_paul'})
    end,
    update = function(self, card, dt)
        if card.area ~= G.rules_card_jokers then
            if card.hasSpeech and card.ability.extra.talk <= 0 then
                if G.STAGE == G.STAGES.MAIN_MENU then
                    say(card, {blabla = ("main_menu"), prob = 250})
                elseif card.debuff then
                    say(card, {blabla = ("debuffed"), prob = 750})
                elseif card.area == G.shop_jokers then
                    say(card, {blabla = ('shop_jokers'), prob = 250})
                elseif card.area == G.jokers and card.ability.extra.inBlind then
                    say(card, {blabla = ('in_blind'), prob = 250})
                elseif card.area == G.pack_cards then
                    say(card, {blabla = ('in_booster'), prob = 250})
                else
                    say(card, {blabla = ('random'), prob = 1000, quotesNb = 20})
                end
            else
                card.ability.extra.talk = card.ability.extra.talk - 1
            end
        end
    end
}

return {
	enabled = Showdown.config["Jokers"]["Jean-Paul"],
	list = function ()
		local list = {
            jean_paul,
        }
		return list
	end,
    exec = function()
        local function lookFor(card)
            local jokers = find_joker(card.ability.name)
            if G.shop_jokers then
                for _, v in pairs(G.shop_jokers) do
                    if v and type(v) == 'table' and v.ability and v.ability.name == card.ability.name and not v.debuff then
                        table.insert(jokers, v)
                    end
                end
            end
            for k,v in pairs(jokers) do
                if v == card then return k end
            end
            return 0
        end
        
        function say(card, args)
            if not card.hasSpeech then print(card.ability.name.." tried to speak. But sadly, he remembers that he does not have any mouth...") return end
            if not args.prob and not args.guaranteed then print(card.ability.name.." tried to speak. But sadly, he doesn't know how to count...") return end
            if not args then args = {} end
            if args.guaranteed or math.random(args.prob) == 1 then
                card.add_speech_bubble(args.blabla and (args.blabla..'_'..math.random(args.quotesNb or 10)) or '')
                local queue = card.ability.name..'_'..lookFor(card)
                if not G.E_MANAGER.queues[queue] then G.E_MANAGER.queues[queue] = {}
                else G.E_MANAGER:clear_queue(queue) end
                card.say_stuff(5 * (math.min(G.SETTINGS.GAMESPEED, 16) ^ 0.5), true, queue)
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = args.delay or G.SETTINGS.GAMESPEED * 5,
                    func = function()
                        card:remove_speech_bubble()
                      return true
                    end
                }), queue)
                card.ability.extra.talk = math.random(750, 2500)
            end
        end
        
        function Showdown.speech_bubble(text_key, text_type, loc_vars, align_text, additional_text)
            local text = {}
            localize{type = text_type or 'tutorial', key = text_key or 'sb_1', vars = loc_vars or {}, nodes = text}
            if additional_text and type(additional_text) == 'table' then
                for _, v in ipairs(additional_text) do
                    --[[local loc_text = localize{type = v.type or 'tutorial', set = v.set, key = v.key or 'sb_1', vars = v.loc_vars or {}, nodes = text}
                    if type(loc_text) == "nil" then
                        text[#text+1] = { loc_text }
                    end]]--
                    localize{type = v.type or 'tutorial', set = v.set, key = v.key or 'sb_1', vars = v.loc_vars or {}, nodes = text}
                end
            end
            local row = {}
            for _, v in ipairs(text) do
                row[#row+1] = {n=G.UIT.R, config={align = align_text and 'cm' or "cl"}, nodes = v}
            end
            local t = {n = G.UIT.ROOT, config = {align = "cm", minh = 0, r = 0.3, padding = 0.07, minw = 1, colour = G.C.JOKER_GREY, shadow = true}, nodes={
                          {n = G.UIT.C, config = {align = "cm", minh = 0, r = 0.2, padding = 0.1, minw = 1, colour = G.C.WHITE}, nodes = {
                            {n = G.UIT.C, config = {align = "cm", minh = 0, r = 0.2, padding = 0.03, minw = 1, colour = G.C.WHITE}, nodes = row}}
                          }
                        }}
            return t
        end
        
        -- Taken from card_character
        -- I originally used card_character to make Jean-Paul speak, but on top of being annoying to use here, I couldn't load it when reloading a game
        -- So I decided to give speech directly to the card :3
        -- If i did things right, giveSpeech and say are public functions which means that is you want to, you can give speech to any joker you want
        -- (If you do this, think about updating your lovely patches like I did for Jean-Paul (lines 117 to 127 in jokers.toml))
        function SMODS.giveSpeech(card)
            card.hasSpeech = true
        
            card.add_speech_bubble = function(text_key, loc_vars)
                if card.children.speech_bubble then card.children.speech_bubble:remove() end
                card.config.speech_bubble_align = {align='bm', offset = {x=0,y=0}, parent = card}
                card.children.speech_bubble = UIBox{
                    definition = Showdown.speech_bubble(text_key, 'quips', loc_vars),
                    config = card.config.speech_bubble_align
                }
                card.children.speech_bubble:set_role{
                    role_type = 'Minor',
                    xy_bond = 'Weak',
                    r_bond = 'Strong',
                    major = card,
                }
                card.children.speech_bubble.states.visible = false
            end
        
            card.remove_speech_bubble = function()
                if card.children.speech_bubble then card.children.speech_bubble:remove(); card.children.speech_bubble = nil end
            end
        
            card.say_stuff = function(n, first, queue)
                if first then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.1,
                        func = function()
                            if card.children.speech_bubble then card.children.speech_bubble.states.visible = true end
                            card.say_stuff(n, false)
                          return true
                        end
                    }), queue)
                else
                    if n <= 0 then return end
                    play_sound('voice'..math.random(1, 11), (math.random()*0.2+1), 0.5)
                    card:juice_up(nil, 0.05)
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        blockable = false, blocking = false,
                        delay = 0.13,
                        func = function()
                            card.say_stuff(n-1, false)
                        return true
                        end
                    }), queue)
                end
            end
        
            local drawRef = card.draw
            card.draw = function(layer)
                if card.children.speech_bubble then
                    card.children.speech_bubble:draw()
                end
                drawRef(layer)
            end
            
            local moveRef = card.move
            card.move = function(self, dt)
                moveRef(self, dt)
                if self.children.speech_bubble and G.STAGE ~= G.STAGES.MAIN_MENU then
                    self.children.speech_bubble:set_alignment(self:align_h_popup())
                end
            end
        end
    end,
}