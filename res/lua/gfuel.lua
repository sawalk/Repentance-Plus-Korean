local mod = REPKOR

------

local i_queueLastFrame = {}
local i_queueNow = {}
local gFuelDesc = {
    ["FASTER UP!"] = "더 빠른 증가!",
    ["GENEROSITY UP!"] = "관대함 증가!",
    ["G UP!"] = "G 증가!",
    ["WISDOM UP!"] = "지혜 증가!",
    ["GAMER SPEED UP!"] = "게이머 속도 증가!",
    ["REACTION UP!"] = "반응 증가!",
    ["A STAT UP!"] = "능력치 하나 증가!",
    ["GOOD UP!"] = "좋음 증가!",
    ["BUILDING SPEED UP!"] = "건축 속도 증가!",
    ["MIX UP!"] = "혼합 증가!",
    ["SLEEP HOURS DOWN!"] = "수면 시간 감소!",
    ["MISERY UP!"] = "비참함 증가!",
    ["MANA UP!"] = "마력 증가!",
    ["MOVEMENT UP!"] = "움직임 증가!",
    ["RESPECT UP!"] = "존경 증가!",
    ["SHOTS UP!"] = "발사량 증가!",
    ["SENTIENCE UP!"] = "지각력 증가!",
    ["WHITE BLOOD CELLS UP!"] = "백혈구 증가!",
    ["FAME UP!"] = "명성 증가!",
    ["THOU ART HERO!"] = "너는 영웅이다!",
    ["BLOOD UP!"] = "혈액 증가!",
    ["POPULATION UP!"] = "인구 증가!",
    ["FAVOR UP!"] = "호의 증가!",
    ["RANK UP! REACHED RANK: ISAAC'S FACE"] = "랭크 상승! 도달 랭크: 아이작의 얼굴",
    ["STRENGTH UP!"] = "힘 증가!",
    ["RISK UP!"] = "위험 증가!",
    ["EXPLOSIONS UP!"] = "폭발력 증가!",
    ["FEAR UP!"] = "공포 증가!",
    ["BONES UP!"] = "뼈 증가!",
    ["SHARPNESS UP!"] = "날카로움 증가!",
	["BUILDING SPEED UP!"] = "건축 속도 증가!",
    ["SOUL UP!"] = "영혼 증가!",
    ["VITALITY UP!"] = "생명력 증가!",
    ["SUNSHINE UP!"] = "햇살 증가!",
    ["VOLUME UP!"] = "볼륨 증가!",
    ["SUSPICION UP!"] = "의심 증가!",
    ["MORALITY UP!"] = "도덕성 증가!",
    ["AMBITION UP!"] = "야망 증가!",
    ["DISC SPEED UP!"] = "디스크 속도 증가!",
    ["HURTFUL WORDS RESISTANCE UP!"] = "언어폭력 저항성 증가!",
    ["AMMO CAPACITY UP!"] = "탄약 용량 증가!",
    ["ACIDITY UP!"] = "산성도 증가!",
    ["HEIGHT UP!"] = "키 증가!",
    ["GOD'S LIGHT UP!"] = "신의 빛 증가!",
    ["TEAR TASTE UP!"] = "눈물 맛 증가!",
    ["AIR RESISTANCE UP!"] = "공기 저항 증가!",
    ["SHUTTER SPEED UP!"] = "셔터 속도 증가!",
    ["MOMENTUM UP!"] = "운동량 증가!",
    ["ACCEPTANCE UP!"] = "수용력 증가!",
    ["HUMOR UP!"] = "유머 증가!",
}

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        local playerKey = tostring(player.InitSeed)
        
        i_queueNow[playerKey] = player.QueuedItem.Item
        if i_queueNow[playerKey] and i_queueNow[playerKey]:IsCollectible() and i_queueLastFrame[playerKey] == nil then
            local itemID = i_queueNow[playerKey].ID
            if itemID == -1 and i_queueNow[playerKey].Name == "G FUEL!" then    -- G FUEL!
                local g_origin = i_queueNow[playerKey].Description
                local g_description = ""

                if g_origin and g_origin ~= "" then
                    g_description = gFuelDesc[g_origin]
                else
                    g_description = gFuelDesc[(player:GetCollectibleRNG(itemID):RandomInt(50) + 1)]
                end

                if g_description then
                    Game():GetHUD():ShowItemText("G FUEL!", g_description or "한글패치 제작자에게 연락주세요")
                end
            end
        end
        i_queueLastFrame[playerKey] = i_queueNow[playerKey]
    end
)