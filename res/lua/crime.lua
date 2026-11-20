local mod = REPKOR

------

local hudMessages = {
    [1] = { name = "권총", desc = "빵야 빵야!" },
    [2] = { name = "샷건", desc = "펑!" },
    [3] = { name = "SMG", desc = "타타타타!" },
    [4] = { name = "유탄발사기", desc = "콰쾅!" },
}

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE,
    ---@param pickup EntityPickup
    function(_, pickup)
        local sprite = pickup:GetSprite()
        local strings = hudMessages[pickup.SubType]

        if sprite:GetAnimation() == "Collect" and sprite:GetFrame() == 1 then
            Game():GetHUD():ShowItemText(strings.name, strings.desc, false, true)
        end
    end,
    420
)