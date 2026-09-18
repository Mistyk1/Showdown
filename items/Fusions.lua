local fusions = {}

table.insert(fusions, {
    result_joker = "j_showdown_soul_gambling",
    jokers = {
        { name = "j_showdown_soul_avarice", carry_stat = "x_mult" },
        { name = "j_showdown_soul_malice", carry_stat = "retrigger" },
        { name = "j_showdown_soul_fortune", carry_stat = "x_chips" },
    },
    cost = 30,
})

return {
    enabled = Showdown.config["CrossMod"]["FusionJokers"] and FusionJokers,
    exec = function ()
        for _, fusion in ipairs(fusions) do
            if not fusion.experimental or (fusion.experimental and Showdown.config["Technical"]["Experimental"]) then
                FusionJokers.fusions:register_fusion(fusion)
            end
        end
    end,
    order = 3,
}