local mirror = {
	type = 'Back',
	order = 1,
	name = "Mirror Deck",
	key = "Mirror",
	atlas = "showdown_decks",
	pos = coordinate(1),
	config = { unlock_stake = "stake_showdown_ruby" },
	locked_loc_vars = function(self, info_queue, card)
		if not Showdown.has_stakes then return { key = 'b_showdown_deactivated' } end
		local stake_idx = Showdown.get_stake_index(self.config.unlock_stake)
		return { vars = { localize{type = 'name_text', set = 'Stake', key = G.P_CENTER_POOLS.Stake[stake_idx].key}, colours = { get_stake_col(stake_idx) } } }
	end,
	unlocked = false,
	check_for_unlock = function (self, args)
		if not Showdown.has_stakes then return end
		local win_stake = Showdown.get_deck_win_stake_alt()
		if args.type == 'win_stake' and win_stake >= Showdown.get_stake_index(self.config.unlock_stake) and win_stake <= Showdown.get_stake_index('stake_showdown_diamond') then
			unlock_card(self)
		end
	end,
	apply = function(self, back)
		G.E_MANAGER:add_event(Event({
			func = function()
				for i = #G.playing_cards, 1, -1 do
					local card = G.playing_cards[i]
					local count = SMODS.Ranks[card.base.value].counterpart
					if count and not count.is then
						assert(SMODS.change_base(card, nil, count.value))
					elseif card.base.value == 'Ace' then
						assert(SMODS.change_base(card, nil, 'showdown_Zero'))
					end
				end
				return true
			end
		}))
	end
}

local calculus = {
	type = 'Back',
	order = 2,
	name = "Calculus Deck",
	key = "Calculus",
	atlas = "showdown_decks",
	pos = coordinate(2),
	config = { vouchers = { "v_showdown_number" }, consumables = { 'c_showdown_genie' } },
	unlocked = false,
	check_for_unlock = function (self, args)
		if G.GAME.consumeable_usage_total and (G.GAME.consumeable_usage_total.mathematic or 0) >= 10 then
			unlock_card(self)
		end
	end,
	apply = function(self, back)
		G.GAME.first_booster_calculus = true
	end
}

local starter = {
	type = 'Back',
	order = 3,
	name = "Starter Deck",
	key = "Starter",
	atlas = "showdown_decks",
	pos = coordinate(3),
	config = { showdown_starter = true },
	unlocked = false,
	check_for_unlock = function (self, args)
		if G.jokers and #G.jokers.cards >= 8 then
			unlock_card(self)
		end
	end,
	apply = function(self, back)
		if (G.GAME.selected_sleeve and G.GAME.selected_sleeve ~= 'sleeve_showdown_Starter') or not G.GAME.selected_sleeve then
			G.GAME.starting_params.dollars = -5
			give_starter()
		end
	end
}

local cheater = {
	type = 'Back',
	order = 4,
	name = "Cheater Deck",
	key = "Cheater",
	atlas = "showdown_decks",
	pos = coordinate(4),
	config = { showdown_cheater = true },
	loc_vars = function(self, info_queue, card)
		return { vars = { (G.GAME and G.GAME.probabilities.normal) or 1 } }
	end,
	unlocked = false,
	check_for_unlock = function (self, args)
		if G.deck and G.deck.config.card_limit >= 80 then
			unlock_card(self)
		end
	end,
	calculate = function(self, card, context)
		if context.post_hand then
			local nbCards = 1
			for _, joker in pairs(find_joker('versatile_joker')) do
				nbCards = nbCards + joker.ability.extra.extra_card
			end
			for _, joker in pairs(find_joker('versatile_joker_all_in_one')) do
				nbCards = nbCards + joker.ability.extra.extra_card
			end
			local ranks = get_all_ranks({onlyFace = true, whitelist = {"showdown_Zero"}})
			local suits = get_all_suits()
			local cards = {}
			for _=1, nbCards do
				local rank, suit = pseudorandom_element(ranks, pseudoseed('create_card')), pseudorandom_element(suits, pseudoseed('create_card'))
				local created_card, _card = get_card_from_rank_suit(rank, suit), nil
				if created_card then
					G.E_MANAGER:add_event(Event({
						func = function()
							G.playing_card = (G.playing_card and G.playing_card + 1) or 1
							_card = Card(G.play.T.x + G.play.T.w/2, G.play.T.y, G.CARD_W, G.CARD_H, created_card, G.P_CENTERS.c_base, {playing_card = G.playing_card})
							_card:start_materialize({G.C.SECONDARY_SET.Enhanced})
							G.play:emplace(_card)
							table.insert(G.playing_cards, _card)
							if G.GAME.cheater_seal and SMODS.pseudorandom_probability(card, 'cheater_add_seal', 1, 6) then
								_card:set_seal(SMODS.poll_seal({guaranteed = true}), nil, true)
							end
							cards[#cards+1] = _card
							return true
					end}))
				end
				delay(0.2)
			end
			G.E_MANAGER:add_event(Event({
				func = function()
					G.deck.config.card_limit = G.deck.config.card_limit + nbCards
					playing_card_joker_effects(cards)
					return true
			end}))
			G.E_MANAGER:add_event(Event({
				func = function()
					for i=1, #cards do
						draw_card(G.play, G.deck, i*100/#cards,'up', nil ,cards[i])
					end
					return true
			end}))
			delay(0.2)
		elseif
			context.destroying_card
			and context.cardarea == G.play
			and not context.destroy_card.debuff
			and not (next(find_joker('versatile_joker')) or next(find_joker('versatile_joker_all_in_one')))
			and (not G.GAME.cheater_seal or (G.GAME.cheater_seal and not context.destroy_card:get_seal())) -- This is for the Cheater Sleeve
			and SMODS.pseudorandom_probability(card, 'cheater', 1, 4)
		then
            return { remove = true }
		end
	end,
	apply = function(self, back)
		G.E_MANAGER:add_event(Event({
			func = function()
				local hasZero = false
				local countFaces = {
					['2'] = 'showdown_Lord',
					['3'] = 'showdown_Princess',
					['4'] = 'showdown_Butler',
				}
				for i = #G.playing_cards, 1, -1 do
					local card = G.playing_cards[i]
					if not hasZero and not countFaces[card.base.value] and not card:is_face() then
						assert(SMODS.change_base(card, nil, 'showdown_Zero'))
						hasZero = true
					elseif countFaces[card.base.value] and not G.GAME.starting_params.no_faces then
						assert(SMODS.change_base(card, nil, countFaces[card.base.value]))
					elseif not card:is_face() then
						card:remove()
					end
				end
				return true
			end
		}))
	end
}

local engineer = {
	type = 'Back',
	order = 5,
	name = "Engineer Deck",
	key = "Engineer",
	atlas = "showdown_decks",
	pos = coordinate(5),
	config = { unlock_stake = "stake_showdown_onyx" },
	locked_loc_vars = function(self, info_queue, card)
		if not Showdown.has_stakes then return { key = 'b_showdown_deactivated' } end
		local stake_idx = Showdown.get_stake_index(self.config.unlock_stake)
		return { vars = { localize{type = 'name_text', set = 'Stake', key = G.P_CENTER_POOLS.Stake[stake_idx].key}, colours = { get_stake_col(stake_idx) } } }
	end,
	unlocked = false,
	check_for_unlock = function (self, args)
		if not Showdown.has_stakes then return end
		local win_stake = Showdown.get_deck_win_stake_alt()
		if args.type == 'win_stake' and win_stake >= Showdown.get_stake_index(self.config.unlock_stake) and win_stake <= Showdown.get_stake_index('stake_showdown_diamond') then
			unlock_card(self)
		end
	end,
	apply = function(self, back)
		G.GAME.showdown_engineer = true
	end
}

local chess = {
	type = 'Back',
	order = 6,
	name = "Chess Deck",
	key = "Chess",
	atlas = "showdown_decks",
	pos = coordinate(6),
	config = { unlock_stake = "stake_showdown_topaz" },
	locked_loc_vars = function(self, info_queue, card)
		if not Showdown.has_stakes then return { key = 'b_showdown_deactivated' } end
		local stake_idx = Showdown.get_stake_index(self.config.unlock_stake)
		return { vars = { localize{type = 'name_text', set = 'Stake', key = G.P_CENTER_POOLS.Stake[stake_idx].key}, colours = { get_stake_col(stake_idx) } } }
	end,
	unlocked = false,
	check_for_unlock = function (self, args)
		if not Showdown.has_stakes then return end
		local win_stake = Showdown.get_deck_win_stake_alt()
		if args.type == 'win_stake' and win_stake >= Showdown.get_stake_index(self.config.unlock_stake) and win_stake <= Showdown.get_stake_index('stake_showdown_diamond') then
			unlock_card(self)
		end
	end,
	apply = function(self, back)
		G.GAME.showdown_chess = true
	end
}

local slotted = {
	type = 'Back',
	order = 7,
	name = "Slotted Deck",
	key = "Slotted",
	atlas = "showdown_decks",
	pos = coordinate(7),
	config = { unlock_stake = "stake_showdown_sapphire" },
	locked_loc_vars = function(self, info_queue, card)
		if not Showdown.has_stakes then return { key = 'b_showdown_deactivated' } end
		local stake_idx = Showdown.get_stake_index(self.config.unlock_stake)
		return { vars = { localize{type = 'name_text', set = 'Stake', key = G.P_CENTER_POOLS.Stake[stake_idx].key}, colours = { get_stake_col(stake_idx) } } }
	end,
	unlocked = false,
	check_for_unlock = function (self, args)
		if not Showdown.has_stakes then return end
		local win_stake = Showdown.get_deck_win_stake_alt()
		if args.type == 'win_stake' and win_stake >= Showdown.get_stake_index(self.config.unlock_stake) and win_stake <= Showdown.get_stake_index('stake_showdown_diamond') then
			unlock_card(self)
		end
	end,
	apply = function(self, back)
		SMODS.change_voucher_limit(1)
		SMODS.change_booster_limit(1)
		change_shop_size(-1)
	end
}

local one_of_a_kind = {
	type = 'Back',
	order = 8,
	name = "One of a Kind Deck",
	key = "one_of_a_kind",
	atlas = "showdown_decks",
	pos = coordinate(8),
	config = { unlock_stake = "stake_showdown_emerald" },
	locked_loc_vars = function(self, info_queue, card)
		if not Showdown.has_stakes then return { key = 'b_showdown_deactivated' } end
		local stake_idx = Showdown.get_stake_index(self.config.unlock_stake)
		return { vars = { localize{type = 'name_text', set = 'Stake', key = G.P_CENTER_POOLS.Stake[stake_idx].key}, colours = { get_stake_col(stake_idx) } } }
	end,
	unlocked = false,
	check_for_unlock = function (self, args)
		if not Showdown.has_stakes then return end
		local win_stake = Showdown.get_deck_win_stake_alt()
		if args.type == 'win_stake' and win_stake >= Showdown.get_stake_index(self.config.unlock_stake) and win_stake <= Showdown.get_stake_index('stake_showdown_diamond') then
			unlock_card(self)
		end
	end,
	apply = function(self, back)
		SMODS.change_booster_limit(1)
		G.GAME.showdown_one_of_a_kind = true
	end
}

local one_of_a_kind_draw_step = {
	type = 'DrawStep',
	key = 'one_of_a_kind_draw_step',
	order = 50,
	func = function(self, layer)
		local in_run_setup = not not (
			self.ability.set == "Back"
			or self.params.viewed_back
			or self.params.run_select_selection_choice
			or self.params.run_select_preview_card
			or (self.area and (self.area.config.run_select or self.area.config.run_select_deck_preview))
		)
		local back = (self.ability.set == "Back" and self.config.center)
			or (self.params.viewed_back == true and G.GAME.viewed_back and G.GAME.viewed_back.effect.center)
			or (self.playing_card and not in_run_setup and G.GAME.selected_back_key)

        if back and (back.unlocked or not in_run_setup) and back.key == 'b_showdown_one_of_a_kind' then
            self.children.center:draw_shader('negative_shine', nil, self.ARGS.send_to_shader)
        end
	end,
    conditions = { vortex = false, facing = 'back' },
}

local radar = {
	type = 'Back',
	experimental = true,
	order = 9,
	name = "Radar Deck",
	key = "Radar",
	atlas = "showdown_deck_radar",
	pos = { x = 0, y = 0 },
	unlocked = false,
	check_for_unlock = function (self, args)
		--unlock_card(self)
	end,
	apply = function(self, back)
		--
	end
}

return {
	enabled = Showdown.config["Decks"],
	list = function()
		local list = {
			starter,
			slotted,
			one_of_a_kind,
			one_of_a_kind_draw_step,
			radar,
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
		{key = "showdown_decks", path = "Decks.png", px = 71, py = 95},
		{key = "showdown_deck_radar", path = "DeckRadar.png", px = 71, py = 95},
	},
	order = 2,
	exec = function()
		function give_starter(starter_sleeve)
			G.E_MANAGER:add_event(Event({
				func = function()
					if G.jokers then
						local card = create_card("Joker", G.jokers, nil, starter_sleeve and 1, nil, nil, nil, "showdown_starter")
						card:add_to_deck()
						card:start_materialize()
						G.jokers:emplace(card)
						return true
					end
				end,
			}))
			G.E_MANAGER:add_event(Event({
				func = function()
					if G.consumeables then
						local card = create_card(pseudorandom_element(SMODS.ConsumableType.ctype_buffer), G.consumeables, nil, nil, nil, nil, nil, "showdown_starter")
						card:add_to_deck()
						G.consumeables:emplace(card)
						return true
					end
				end,
			}))
			local vouchers = {}
			local back = G.P_CENTERS[G.GAME.selected_back.effect.center.key]
			local given_by_deck = back.config.vouchers or (back.config.voucher and {back.config.voucher}) or {}
			for _, v in pairs(G.P_CENTER_POOLS.Voucher) do
				if v.unlocked and not (v.requires and next(v.requires)) and findInTable(v.key, given_by_deck) == -1 then
					table.insert(vouchers, v.key)
				end
			end
			if next(vouchers) then
				local randomVoucher = pseudorandom_element(vouchers)
				G.GAME.used_vouchers[randomVoucher] = true
				G.GAME.starting_voucher_count = (G.GAME.starting_voucher_count or 0) + 1
				G.E_MANAGER:add_event(Event({
					func = function()
						Card.apply_to_run(nil, G.P_CENTERS[randomVoucher])
						return true
					end
				}))
			end
		end

		local Backapply_to_runRef = Back.apply_to_run
		function Back:apply_to_run()
			Backapply_to_runRef(self)
			if G.PROFILES[G.SETTINGS.profile].starter_next_run then
				G.PROFILES[G.SETTINGS.profile].starter_next_run = false
				give_starter()
			end
			if self.effect.config.showdown_cheater then
				G.GAME.showdown_cheater = true
				G.GAME.cheater_destroy_odd = 6
			end
			Showdown.tag_related_joker['j_showdown_versatile'] = G.GAME.selected_back.name == 'Anaglyph Deck' and G.GAME.showdown_engineer
		end

        local updateRef = Game.update
        local radar_dt = 0
        function Game:update(dt)
            updateRef(self, dt)
            radar_dt = radar_dt + dt
            if G.P_CENTERS and G.P_CENTERS.b_showdown_Radar and radar_dt > 0.04 then
                radar_dt = 0
                local obj = G.P_CENTERS.b_showdown_Radar
				obj.pos.x = obj.pos.x + 1
				if obj.pos.y <= 4 and obj.pos.x == 10 then
					obj.pos.x = 0
					obj.pos.y = obj.pos.y + 1
				elseif obj.pos.y == 5 and obj.pos.x == 6 then
					obj.pos.x = 0
					obj.pos.y = 0
				end
            end
			for _, v in pairs(G.I.CARD) do
				if v.children.back and v.children.back.atlas.name == "showdown_deck_radar" then
					v.children.back:set_sprite_pos(G.P_CENTERS.b_showdown_Radar.pos or G.P_CENTERS["b_red"].pos)
				end
			end
        end

		function Card:create_tag_card() -- Thanks Bunco
			self = Card(self.T.x, self.T.y, 0.8*G.CARD_W, 0.8*G.CARD_W, nil, G.P_CENTERS.c_base)
    		local _size = 1
			local tag = G.P_TAGS[get_next_tag_key()]

			-- Tag appearance
			local tag_sprite = SMODS.create_sprite(0, 0, _size*1, _size*1, SMODS.get_atlas((not tag.hide_ability) and tag.atlas or "tags"), (tag.hide_ability) and G.tag_undiscovered.pos or tag.pos, tag.sprite_args)
			tag_sprite.T.scale = 1
			tag_sprite:define_draw_steps({
				{shader = 'dissolve', shadow_height = 0.05},
				{shader = 'dissolve'},
			})
			tag_sprite.float = true
			tag_sprite.states.hover.can = true
			tag_sprite.states.drag.can = false
			tag_sprite.states.collide.can = true
			tag_sprite:set_role({role_type = 'Glued', major = self, draw_major = self,
			xy_bond = 'Strong',
			wh_bond = 'Strong',
			r_bond = 'Strong',
			scale_bond = 'Strong'})
			self.children.back = tag_sprite
			self.ability.tag_card = {tag = Tag(tag.key)}

			self.hover = function()
				if not G.CONTROLLER.dragging.target or G.CONTROLLER.using_touch then
					if not self.hovering and self.states.visible then
						self.hovering = true
						if self == tag_sprite then
							self.hover_tilt = 3
							self:juice_up(0.05, 0.02)
							play_sound('paper1', math.random()*0.1 + 0.55, 0.42)
							play_sound('tarot2', math.random()*0.1 + 0.55, 0.09)
						end

						self.ability.tag_card.tag:get_uibox_table(tag_sprite)
						self.config.h_popup = G.UIDEF.card_h_popup(tag_sprite)
						self.config.h_popup_config = (self.T.x > G.ROOM.T.w*0.4) and
							{align =  'cl', offset = {x=-0.1,y=0},parent = self} or
							{align =  'cr', offset = {x=0.1,y=0},parent = self}
						Node.hover(self)
						if self.children.alert then
							self.children.alert:remove()
							self.children.alert = nil
							if self.key and G.P_TAGS[self.key] then G.P_TAGS[self.key].alerted = true end
							G:save_progress()
						end
					end
				end
			end
			self.stop_hover = function()
				self.hovering = false
				Node.stop_hover(self)
				self.hover_tilt = 0
			end
			self.children.center = tag_sprite

			return self
		end

		G.FUNCS.can_use_tag_card = function(e)
			e.config.colour = G.C.GREEN
			e.config.button = 'use_tag_card'
		end

		G.FUNCS.use_tag_card = function(e)
			local card = e.config.ref_table
			add_tag(Tag(card.ability.tag_card.tag.key))

			play_sound('other1')
			e.config.button = nil
			G.FUNCS.end_consumeable(nil, 0.2)
		end
		
        Showdown.versatile['Starter Deck'] = { desc = 'j_showdown_versatile_joker_starter', pos = coordinate(20), blueprint = false }
		Showdown.versatile['Slotted Deck'] = { desc = 'j_showdown_versatile_joker_slotted', pos = coordinate(26), blueprint = false,
		add_to_deck = function(self, card, from_debuff)
			G.E_MANAGER:add_event(Event({func = function()
                for _, v in pairs(G.I.CARD) do
                    if v.set_cost then v:set_cost() end
                end
            return true end }))
        end, remove_from_deck = function(self, card, from_debuff)
            G.E_MANAGER:add_event(Event({func = function()
                for _, v in pairs(G.I.CARD) do
                    if v.set_cost then v:set_cost() end
                end
            return true end }))
        end }
		Showdown.versatile['One of a Kind Deck'] = { desc = 'j_showdown_versatile_joker_one_of_a_kind', pos = coordinate(27), blueprint = false,
		add_to_deck = function(self, card, from_debuff)
			SMODS.change_booster_limit(1)
			G.GAME.showdown_one_of_a_kind_max_cards = true
        end, remove_from_deck = function(self, card, from_debuff)
			SMODS.change_booster_limit(-1)
			G.GAME.showdown_one_of_a_kind_max_cards = next(find_joker('j_showdown_versatile_joker')) ~= nil
        end }
		if Showdown.config["Ranks"] then
			Showdown.versatile['Mirror Deck'] = { desc = 'j_showdown_versatile_joker_mirror', pos = coordinate(18), blueprint = false, calculate = function(self, card, context)
				if context.before and not context.blueprint then
					local hazZero = false
					for i=1, #context.scoring_hand do
						hazZero = hazZero or Showdown.is_zero(context.scoring_hand[i])
					end
					local enhancements = {}
					for _, v in ipairs(G.hand.cards) do
						if (not SMODS.has_enhancement(v, 'c_base') and (hazZero and not SMODS.has_enhancement(v, 'm_wild') or not hazZero)) and findInTable(v.config.center, enhancements) == -1 then
							table.insert(enhancements, v.config.center)
						end
					end
					if #enhancements > 0 then
						local couterparts = {}
						for _, v in ipairs(context.scoring_hand) do
							if Showdown.is_counterpart(v) and SMODS.has_enhancement(v, 'c_base') then
								couterparts[#couterparts+1] = v
								v:set_ability(pseudorandom_element(enhancements, pseudoseed('versatile_mirror')), nil, true)
								G.E_MANAGER:add_event(Event({
									func = function()
										v:juice_up()
										return true
									end
								}))
							end
						end
						if #couterparts > 0 then
							return {
								message = localize('k_enhanced'),
								colour = G.C.COUNTERPART_RANKS,
								card = card
							}
						end
					end
				end
			end }
			Showdown.versatile['Cheater Deck'] = { desc = 'j_showdown_versatile_joker_cheater', pos = coordinate(21), blueprint = false }
		end
		if Showdown.config["Consumables"]["Mathematics"] then
			Showdown.versatile['Calculus Deck'] = { desc = 'j_showdown_versatile_joker_calculus', pos = coordinate(19), blueprint = true, calculate = function(self, card, context)
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
		end
		if Showdown.config["Tags"]["Switches"] then
			Showdown.versatile['Engineer Deck'] = { desc = 'j_showdown_versatile_joker_engineer', pos = coordinate(22), blueprint = false }
		end
		if Showdown.config["Blinds"] then
        	Showdown.versatile['Chess Deck'] = { desc = 'j_showdown_versatile_joker_chess', pos = coordinate(25), blueprint = false, add_to_deck = function(self, card, from_debuff)
				if G.GAME.blind and G.GAME.blind.name ~= '' and G.GAME.blind.config and G.GAME.blind.config.is_chess_boss and not G.GAME.blind.config.is_black_chess and not G.GAME.blind.disabled then
					G.GAME.blind:disable()
					play_sound('timpani')
					card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('ph_blind_disabled')})
				end
			end, calculate = function(self, card, context)
				if context.setting_blind and not card.getting_sliced and not context.blueprint and context.blind.config and context.blind.config.is_chess_boss and not context.blind.config.is_black_chess then
					G.E_MANAGER:add_event(Event({func = function()
						G.E_MANAGER:add_event(Event({func = function()
							G.GAME.blind:disable()
							play_sound('timpani')
							delay(0.4)
							return true end }))
						card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('ph_blind_disabled')})
					return true end }))
					return nil, true
				end
			end }
		end

		function Showdown.get_stake_index(stake)
			for i, v in ipairs(G.P_CENTER_POOLS.Stake) do
				if v.key == stake then return v.order end
			end
		end
	end
}