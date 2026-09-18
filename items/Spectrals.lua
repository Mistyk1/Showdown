local mist = {
	type = 'Consumable',
	order = 1,
	key = 'mist',
	set = 'Spectral',
	atlas = 'showdown_spectrals',
	config = { change = 6 },
    loc_vars = function(self) return {vars = {self.config.change}} end,
    pos = coordinate(1),
	can_use = function()
		return #G.hand.cards >= 6
    end,
    use = function(self, card, area, copier)
		local temp_hand = {}
		for k, v in ipairs(G.hand.cards) do temp_hand[#temp_hand+1] = v end
		table.sort(temp_hand, function (a, b) return not a.playing_card or not b.playing_card or a.playing_card < b.playing_card end)
		pseudoshuffle(temp_hand, pseudoseed('immolate'))
		for i=1, self.config.change do flipCard(temp_hand[i], i, self.config.change) end
		for i=1, self.config.change do
			local rank = "Ace"
			if SMODS.pseudorandom_probability(card, 'showdown_Probability', 1, 2) then rank = "showdown_Zero" end
			event({trigger = 'after', delay = 0.1, func = function()
				assert(SMODS.change_base(temp_hand[i], nil, rank))
			return true end })
		end
		for i=1, self.config.change do unflipCard(temp_hand[i], i, self.config.change) end
    end
}

local vision = {
	type = 'Consumable',
	order = 2,
	key = 'vision',
	set = 'Spectral',
	atlas = 'showdown_spectrals',
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {set = 'Other', key = 'counterpart_ranks'}
	end,
    pos = coordinate(2),
	can_use = function()
		return #G.hand.cards and #G.hand.cards >= 1
    end,
    use = function(self, card, area, copier)
		for i=1, #G.hand.cards do flipCard(G.hand.cards[i], i, #G.hand.cards) end
		for i=1, #G.hand.cards do
			event({trigger = 'after', delay = 0.1, func = function()
				local _card = G.hand.cards[i]
				local changed = false
				while not changed do
					local rawRank = _card.base.value
					local count = SMODS.Ranks[rawRank].counterpart
					if count then
						assert(SMODS.change_base(_card, nil, count.value))
						local upgrades = {}
						if _card.config.center.name ~= "Default Base" then table.insert(upgrades, "enhancement") end
						if _card.edition then table.insert(upgrades, "edition") end
						if _card.seal then table.insert(upgrades, "seal") end
						if next(upgrades) then
							local toRemove = upgrades[math.random(#upgrades)]
							if toRemove == "enhancement" then
								_card:set_ability(G.P_CENTERS["c_base"])
							elseif toRemove == "edition" then
								_card.edition = nil
							elseif toRemove == "seal" then
								_card.seal = nil
							end
						end
						changed = true
					else
						local rank = SMODS.Rank.obj_table[rawRank]
						assert(SMODS.change_base(_card, nil, rank.next[1]))
					end
				end
			return true end })
		end
		delay(0.2)
		for i=1, #G.hand.cards do unflipCard(G.hand.cards[i], i, #G.hand.cards) end
    end
}

local blue_key = {
	type = 'Consumable',
	order = 3,
	key = 'blue_key',
	set = 'Spectral',
	atlas = 'showdown_spectrals',
	no_collection = true,
    pos = coordinate(3),
	can_use = function(self, card, area, copier)
		local lockJ = next(find_joker('4_locks')) and find_joker('4_locks')[next(find_joker('4_locks'))]
		return lockJ and not lockJ.ability.extra.locks[2]
    end,
    use = function(self, card, area, copier)
		local lockJ = find_joker('4_locks')[next(find_joker('4_locks'))]
		lockJ.ability.extra.locks[2] = true
		forced_message(localize('k_unlocked'), lockJ, G.C.BLUE, true)
    end,
	in_pool = function(self, args)
		return next(find_joker('4_locks')) and not find_joker('4_locks')[next(find_joker('4_locks'))].ability.extra.locks[2]
	end
}

local transformation = {
	type = 'Consumable',
	order = 4,
	key = 'transformation',
	set = 'Spectral',
	atlas = 'showdown_spectrals',
    pos = coordinate(4),
	config = { max_highlighted = 2, mod_conv = "m_showdown_chipped" },
    loc_vars = function(self, info_queue)
        info_queue[#info_queue+1] = G.P_CENTERS.m_showdown_chipped
		return {vars = {self.config.max_highlighted}}
	end,
}

return {
	enabled = Showdown.config["Consumables"]["Spectrals"],
	list = function ()
		local list = {
			transformation,
		}
		if Showdown.config["Ranks"] then
			table.insert(list, mist)
			table.insert(list, vision)
		end
		if Showdown.config["Jokers"]["Final"] then
			table.insert(list, blue_key)
		end
		return list
	end,
	atlases = {
		{key = "showdown_spectrals", path = "Consumables/Spectrals.png", px = 71, py = 95},
	},
}