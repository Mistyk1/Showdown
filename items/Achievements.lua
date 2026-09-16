local order_nb = 0
local trophies = {
	locked = { x = 0, y = 0 },
	bronze = { x = 1, y = 0 },
	silver = { x = 2, y = 0 },
	gold = { x = 3, y = 0 },
	green = { x = 0, y = 1 },
}
local function make_achievement(key, trophy, hidden)
	order_nb = order_nb + 1
	return {
		type = 'Achievement',
		order = order_nb,
		key = key,
		atlas = 'showdown_trophies',
		pos = trophy or trophies.bronze,
		hidden_text = hidden or false,
		bypass_all_unlocked = true,
		--reset_on_startup = true,
		unlock_condition = function(self, args)
			if args.type == key then
				return true
			end
		end,
	}
end

local completionist_plus_plus_plus = make_achievement('completionist_plus_plus_plus', trophies.green, true) -- Completionist+++
local you_can_stop_now = make_achievement('you_can_stop_now', trophies.green, true) -- ok you can stop now
local get_jean_paul = make_achievement('get_jean_paul', trophies.bronze) -- :3
local sell_jean_paul = make_achievement('sell_jean_paul', trophies.bronze, true) -- :(
local jean_paul_tag = make_achievement('jean_paul_tag', trophies.silver, true) -- :D
local jimbodia = make_achievement('jimbodia', trophies.green, true) -- Jimbodia
local chains = make_achievement('chains', trophies.green, true) -- Free from the chains
local versatility = make_achievement('versatility', trophies.gold) -- Versatility
local blued = make_achievement('blued', trophies.bronze, true) -- You've been Blue'd!
local metal_cap = make_achievement('metal_cap', trophies.gold) -- Metal Cap
local cronch = make_achievement('cronch', trophies.silver, true) -- cronch
local green_deck_home = make_achievement('green_deck_home', trophies.silver) -- We have Green Deck at home
local rico_kaboom = make_achievement('rico_kaboom', trophies.silver, true) -- Yes Rico, kaboom
local whole_new_deck = make_achievement('whole_new_deck', trophies.gold, true) -- A whole new deck
local minecraft_reference = make_achievement('minecraft_reference', trophies.gold, true) -- How did we get here?
local never_tell_odds = make_achievement('never_tell_odds', trophies.gold) -- Never tell me the odds
local should_check = make_achievement('should_check', trophies.silver, true) -- You should get that checked
local self_reference = make_achievement('self_reference', trophies.silver, true) -- Self-referential rule
local fargo_proud = make_achievement('fargo_proud', trophies.gold) -- Fargo would be proud
local everything_flush = make_achievement('everything_flush', trophies.silver, true) -- Everything is a Flush
local double_hand = make_achievement('double_hand', trophies.gold) -- Double hand
local who_am_i = make_achievement('who_am_i', trophies.silver) -- Who am I anyways?
local fargo_proud = make_achievement('fargo_proud', trophies.gold, true) -- Fargo would be proud

return {
	enabled = Showdown.config["Achievements"],
	list = function()
		local list = {}
		if Showdown.config["Jokers"]["Jean-Paul"] then
			table.insert(list, get_jean_paul)
			table.insert(list, sell_jean_paul)
			table.insert(list, jean_paul_tag)
		end
		if Showdown.config["Jokers"]["Versatile"] then
			table.insert(list, versatility)
		end
		if Showdown.config["Jokers"]["Normal"] then
			table.insert(list, jimbodia)
			table.insert(list, chains)
			table.insert(list, blued)
			table.insert(list, metal_cap)
			table.insert(list, cronch)
			table.insert(list, green_deck_home)
			--table.insert(list, rico_kaboom)
			table.insert(list, whole_new_deck)
			table.insert(list, never_tell_odds)
			table.insert(list, should_check)
			table.insert(list, self_reference)
			table.insert(list, fargo_proud)
			if Showdown.config["Ranks"] then
				table.insert(list, everything_flush)
				table.insert(list, double_hand)
			end
		end
		if Showdown.config["Decks"] then
			table.insert(list, minecraft_reference)
		end
		if Showdown.has_stakes then
			--table.insert(list, completionist_plus_plus_plus)
			--table.insert(list, you_can_stop_now)
		end
		if Showdown.config["Consumables"]["Mathematics"] then
			table.insert(list, who_am_i)
		end
		return list
	end,
	atlases = {
		{key = "showdown_trophies", path = "Trophies.png", px = 66, py = 66},
	},
	exec = function ()
		function Showdown.versatility_description(ach)
			ach.config.speech_bubble_align = {align='tm', offset = {x=0,y=0},parent = ach}
			ach.children.speech_bubble = UIBox{
				definition = Showdown.speech_bubble('versatility_desc_bruh', 'quips', nil, true),
				config = ach.config.speech_bubble_align
			}
			ach.children.speech_bubble:set_role{
				role_type = 'Major',
				xy_bond = 'Strong',
				r_bond = 'Strong',
				major = ach,
			}
			--[[
			if not G.PROFILES[G.SETTINGS.profile].versatility then G.PROFILES[G.SETTINGS.profile].versatility = {} end
			local no_versatile_deck = {}
			local decks = {}
			for k, v in pairs(G.P_CENTERS) do
				if v.set == 'Back' and findInTable(v.name, G.PROFILES[G.SETTINGS.profile].versatility) == -1 then
					decks[k] = v
				end
			end
			table.sort(decks, function(a, b)
				return a.order < b.order
			end)
			for k, v in pairs(decks) do
				if v.unlocked then
					table.insert(no_versatile_deck, {
						--type = 'name_text',
						type = 'name',
						set = 'Back',
						key = k
					})
				else
					table.insert(no_versatile_deck, {
						type = 'quips',
						key = 'using_unknown_8', -- i reused a jean-paul quip lol
					})
				end
			end
			ach.config.speech_bubble_align = {align='tm', offset = {x=0,y=0},parent = ach}
			ach.children.speech_bubble = UIBox{
				definition = Showdown.speech_bubble('versatility_desc', 'quips', nil, true, no_versatile_deck),
				config = ach.config.speech_bubble_align
			}
			ach.children.speech_bubble:set_role{
				role_type = 'Major',
				xy_bond = 'Strong',
				r_bond = 'Strong',
				major = ach,
			}
			]]--
		end
	end
}