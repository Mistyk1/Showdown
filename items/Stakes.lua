-- Draw steps for multiple stickers

--[[ it doesn't work and i don't know why :(

local stickers_alt_draw_step_1 = {
	type = 'DrawStep',
	key = 'stickers_alt_1',
	order = 41,
    func = function(card, layer)
        if (card.sticker_run_alt and G.shared_stickers[card.sticker_run_alt]) and Showdown.has_stakes and G.SETTINGS.run_stake_stickers then
            G.shared_stickers[card.sticker_run_alt].role.draw_major = card
            G.shared_stickers[card.sticker_run_alt]:draw_shader('dissolve', nil, nil, nil, card.children.center)
            G.shared_stickers[card.sticker_run_alt]:draw_shader('voucher', nil, card.ARGS.send_to_shader, nil, card.children.center)
        end
    end,
    conditions = { vortex = false, facing = 'front' },
}

local stickers_alt_draw_step_2 = {
	type = 'DrawStep',
	key = 'stickers_alt_2',
	order = 42,
    func = function(card, layer)
        if Showdown.has_stakes and card.sticker_run_alt and G.shared_stickers[card.sticker_run_alt] then
			G.shared_stickers[card.sticker_run_alt].role.draw_major = card
			local sticker_run_alt_offset = card.sticker_run_alt_offset or {}
			G.shared_stickers[card.sticker_run_alt]:draw_shader('dissolve', nil, nil, true, card.children.center, nil, card.sticker_rotation, sticker_run_alt_offset.x, sticker_run_alt_offset.y)
			if card.sticker_run_alt == 'showdown_diamond' then G.shared_stickers[card.sticker_run_alt]:draw_shader('voucher', nil, card.ARGS.send_to_shader, true, card.children.center) end
		end
    end,
    conditions = { vortex = false, facing = 'front' },
}

]]--

-- Stakes

local ruby = {
	type = 'StakeAlt',
	order = 1,
    key = 'ruby',
	pos = coordinate(2), sticker_pos = coordinate(2),
    applied_stakes = { 'white' },
	prefix_config = { applied_stakes = { mod = false } },
    colour = HEX('C6241B'),
	alternate = true,
    modifiers = function ()
		G.GAME.modifiers.no_blind_reward = G.GAME.modifiers.no_blind_reward or {}
		G.GAME.modifiers.no_blind_reward.Boss = true
    end
}

local emerald = {
	type = 'StakeAlt',
	order = 2,
    key = 'emerald',
	pos = coordinate(3), sticker_pos = coordinate(3),
    applied_stakes = { 'ruby' },
	above_stake = 'ruby',
    colour = HEX('246D4F'),
	alternate = true,
    modifiers = function ()
        G.GAME.modifiers.scaling = (G.GAME.modifiers.scaling or 1) + 1
    end
}

local onyx = {
	type = 'StakeAlt',
	order = 3,
    key = 'onyx',
	pos = coordinate(5), sticker_pos = coordinate(5),
    applied_stakes = { 'emerald' },
	above_stake = 'emerald',
    colour = HEX('424242'),
	alternate = true,
    modifiers = function ()
        G.GAME.modifiers.enable_statics_in_shop = true
    end
}

local sapphire = {
	type = 'StakeAlt',
	order = 4,
    key = 'sapphire',
	pos = coordinate(4), sticker_pos = coordinate(4),
    applied_stakes = { 'onyx' },
	above_stake = 'onyx',
    colour = HEX('006DAD'),
	alternate = true,
    modifiers = function ()
        G.GAME.starting_params.hands = G.GAME.starting_params.hands - 1
    end
}

local amethyst = {
	type = 'StakeAlt',
	order = 5,
    key = 'amethyst',
	pos = coordinate(6, 5), sticker_pos = coordinate(6, 5),
    applied_stakes = { 'sapphire' },
	above_stake = 'sapphire',
    colour = HEX('4F35AD'),
	alternate = true,
    modifiers = function ()
        G.GAME.modifiers.scaling = (G.GAME.modifiers.scaling or 1) + 1
    end
}

local topaz = {
	type = 'StakeAlt',
	order = 6,
    key = 'topaz',
	pos = coordinate(7, 5), sticker_pos = coordinate(7, 5),
    applied_stakes = { 'amethyst' },
	above_stake = 'amethyst',
    colour = HEX('AF4618'),
	alternate = true,
    modifiers = function ()
        G.GAME.modifiers.enable_eternals_in_shop = true
    end
}

local diamond = {
	type = 'StakeAlt',
	order = 7,
    key = 'diamond',
	pos = coordinate(9, 5), sticker_pos = coordinate(8, 5),
    applied_stakes = { 'topaz' },
	above_stake = 'topaz',
    colour = HEX('00C7B3'),
	shiny = true,
	alternate = true,
    modifiers = function ()
        G.GAME.interest_cap = 15
        G.GAME.modifiers.less_interest = true
    end
}

return {
	enabled = Showdown.has_stakes,
	list = {
		--stickers_alt_draw_step_1,
		--stickers_alt_draw_step_2,

		ruby,
		emerald,
		onyx,
		sapphire,
		amethyst,
		topaz,
		diamond,
	},
	atlases = {
		{key = "showdown_stakes", path = "Stakes.png", px = 29, py = 29},
		{key = "showdown_stake_stickers", path = "StakeStickers.png", px = 71, py = 95},
	},
	order = 1,
    exec = function()
        Showdown.StakeAlt = SMODS.Stake:extend{
			atlas = "showdown_stakes", sticker_atlas = "showdown_stake_stickers",
        }

		function Showdown.get_deck_win_stake_alt(_deck_key)
			if not _deck_key then
				local _stake, _stake_low = nil, nil
				local deck_count = 0
				for _, deck in pairs(G.PROFILES[G.SETTINGS.profile].deck_usage) do
					local deck_won_with = false
					for key, stake in pairs(G.P_STAKES) do
						if (deck.wins_by_key or {})[key] then
							deck_won_with = true
							if (stake.stake_level or 0) > (_stake and G.P_STAKES[_stake].stake_level or 0) and stake.alternate then
								_stake = key
							end
						end
					end
					if deck_won_with then deck_count = deck_count + 1 end
					if not _stake_low then _stake_low = _stake end
					if (_stake and G.P_STAKES[_stake] and G.P_STAKES[_stake].stake_level or 0) < (_stake_low and G.P_STAKES[_stake_low].stake_level or 0) then
						_stake_low = _stake
					end
				end
				return _stake and G.P_STAKES[_stake].order or 0, (deck_count >= #G.P_CENTER_POOLS.Back and G.P_STAKES[_stake_low].order or 0)
			end
			if G.PROFILES[G.SETTINGS.profile].deck_usage[_deck_key] and G.PROFILES[G.SETTINGS.profile].deck_usage[_deck_key].wins_by_key then
				local _stake = nil
				for key, stake in pairs(G.P_STAKES) do
					if G.PROFILES[G.SETTINGS.profile].deck_usage[_deck_key].wins_by_key[key] then
						if (stake.stake_level or 0) > (_stake and G.P_STAKES[_stake].stake_level or 0) and stake.alternate then
							_stake = key
						end
					end
				end
				if _stake then return G.P_STAKES[_stake].order end
			end
			return 0
		end

		function Showdown.get_joker_win_sticker_alt(_center, index)
			local joker_usage = G.PROFILES[G.SETTINGS.profile].joker_usage[_center.key] or {}
			if joker_usage.wins then
				local applied = {}
				local _count = 0
				local _stake = nil
				for k, v in pairs(joker_usage.wins_by_key) do
					SMODS.build_stake_chain(G.P_STAKES[k], applied)
				end
				for i, v in ipairs(G.P_CENTER_POOLS.Stake) do
					if applied[v.order] then
						_count = _count+1
						if (v.stake_level or 0) > (_stake and G.P_STAKES[_stake].stake_level or 0) and v.alternate then
							_stake = v.key
						end
					end
				end
				if index then return _count end
				if _count > 0 then return G.sticker_map[_stake] end
			end
			if index then return 0 end
		end

		function Showdown.get_deck_win_sticker_alt(_center)
			if G.PROFILES[G.SETTINGS.profile].deck_usage[_center.key] and
			G.PROFILES[G.SETTINGS.profile].deck_usage[_center.key].wins_by_key then
				local _stake = nil
				for key, stake in pairs(G.P_STAKES) do
					if G.PROFILES[G.SETTINGS.profile].deck_usage[_center.key].wins_by_key[key] then
						if (stake.stake_level or 0) > (_stake and G.P_STAKES[_stake].stake_level or 0) and stake.alternate then
							_stake = G.sticker_map[key] and key or _stake
						end
					end
				end
				if _stake then return G.sticker_map[_stake] end
			end
		end

		-- Cardsleeve compat
		function Showdown.get_sleeve_win_sticker_alt(sleeve_key)
			local profile = G.PROFILES[G.SETTINGS.profile]
			if profile.sleeve_usage and profile.sleeve_usage[sleeve_key] and profile.sleeve_usage[sleeve_key].wins_by_key then
				local _stake = nil
				for key, _ in pairs(profile.sleeve_usage[sleeve_key].wins_by_key) do
					if (G.P_STAKES[key] and G.P_STAKES[key].stake_level or 0) > (_stake and G.P_STAKES[_stake].stake_level or 0) and G.P_STAKES[key].alternate then
						_stake = key
					end
				end
				if _stake then
					return G.sticker_map[_stake]
				end
			end
		end

		local GameStart_runRef = Game.start_run
		function Game:start_run(args)
			GameStart_runRef(self, args)
            self.GAME.counterpart_turbo_boost = 1
			self.P_CENTERS.v_seed_money.config.extra = self.GAME.modifiers.less_interest and 30 or 50
			self.P_CENTERS.v_money_tree.config.extra = self.GAME.modifiers.less_interest and 60 or 100
			-- i should do a cryptid compat money bean with here
		end
    end,
    class = Showdown,
}