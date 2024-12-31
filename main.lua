REPKOR = RegisterMod("Repentance+ Korean", 1)
local mod = REPKOR

------ 리펜턴스 경고 ------
------ To modders who want to reference this code. THIS CODE IS UNSTABLE!!! DROP THAT IDEA RIGHT NOW!!!
local runningRep = REPENTANCE and not REPENTANCE_PLUS
local conflictKLP = false
if KoreanLocalizingPlus then
    conflictKLP = true
end

local function checkRepentance()
    if runningRep then
        print("\n[Repentance+ Korean]\nz_REPENTANCE+ KOREAN mod is only available with the Repentance+ DLC.\nPLEASE DISABLE THE MOD NOW.\n")
    end
end

local function GetScreenSize()
    local pos = Game():GetRoom():WorldToScreenPosition(Vector(0,0)) - Game():GetRoom():GetRenderScrollOffset() - Game().ScreenShakeOffset
  
    local rx = pos.X + 60 * 26 / 40
    local ry = pos.Y + 162.5 * (26 / 40)
  
    return Vector(rx*2 + 13*26, ry*2 + 7*26)
end

local sprite = Sprite()
if runningRep or conflictKLP then
    sprite:Load("gfx/ui/popup_warning2.anm2", true)
else
    sprite:Load("gfx/cutscenes/backwards.anm2", true)
end

function RenderSub(Anm2)
    sprite:Play(Anm2)
    sprite:Update()
    sprite.Scale = Vector(1, 1)
    if runningRep or conflictKLP then
        sprite.Color = Color(1, 1, 1, 1, 0, 0, 0)
        sprite:Render(Vector(GetScreenSize().X/1.96, GetScreenSize().Y/2.2), Vector(0,0), Vector(0,0))
    else
        sprite.Color = Color(1, 1, 1, 0.6, 0, 0, 0)
        sprite:Render(Vector(GetScreenSize().X/2, GetScreenSize().Y*0.85), Vector(0,0), Vector(0,0))
    end
end

local showAnm2 = false
local renderingTime = 15
local DisplayedTime = 0
local function updateRenderAnm2()
    if runningRep or conflictKLP then
        DisplayedTime = DisplayedTime + 1
        if DisplayedTime >= renderingTime then
            showAnm2 = true
        end
    end
end

local function NonRepentancePlus()
    if showAnm2 then
        if not conflictKLP then
            RenderSub("runningRep")
        else
            RenderSub("conflictWithKLP")
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, checkRepentance)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, updateRenderAnm2)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, NonRepentancePlus)


------ 아빠의 쪽지 자막 by blackcreamtea ------
mod.isVisible = true
mod.IsHidden = false

local VoiceSFX = SFXManager()
local function onRender()
    if Input.IsButtonTriggered(39, 0) then
        mod.IsHidden = not mod.IsHidden   -- '키로 자막 토글
    end
    if mod.IsHidden then return end

    for i = 598, 601 do
        if KoreanVoiceDubbing then
            if VoiceSFX:IsPlaying(Isaac.GetSoundIdByName("DADS_NOTE_KOREAN_" .. (i - 597))) then
                RenderSub("backwards" .. (i - 597))
            end
        else
            if VoiceSFX:IsPlaying(i) then
                RenderSub("backwards" .. (i - 597))
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, onRender)


------ EzItems by ddeeddii ------
local data = include('data')   -- support by raiiiny
local json = require('json')
local jsonData = json.decode(data)

local changes = {
    items = {},
    trinkets = {}
}
  
if not EZITEMS then
    EZITEMS = {}
  
    EZITEMS.items = {}
    EZITEMS.trinkets = {}
    EZITEMS.cards = {}
    EZITEMS.pills = {}
end
  
local function addItem(id, name, description, type)
    if not EZITEMS[type][tostring(id)] then
        EZITEMS[type][tostring(id)] = {}
    end
  
    table.insert(EZITEMS[type][tostring(id)], {name = name, description = description, mod = mod.Name, modTemplate = 'vanilla'})
    changes[type][tostring(id)] = {name = name, description = description}
end
  
local getterFunctions = {
    items = Isaac.GetItemIdByName,
    trinkets = Isaac.GetTrinketIdByName,
}

local function parseJsonData()
    for itemType, root in pairs(jsonData) do
        for itemId, item in pairs(root) do
        if itemType == 'metadata' then
            goto continue
        end
  
        local trueId = itemId
  
        if tonumber(itemId) == nil then
            trueId = getterFunctions[itemType](itemId)
            if trueId ~= -1 then
                addItem(trueId, item.name, item.description, itemType)
            else
                print('[ EzTools | ' .. tostring(mod.Name) .. ']' .. itemType .. ' "' .. tostring(itemId) .. '" not found, skipping custom name/description...')
            end
        else
            addItem(trueId, item.name, item.description, itemType)
        end
  
        ::continue::
        end  
    end
end
  
 local itemVariants = {
    items = 100,
    trinkets = 350
}

--[[ local function updateEid ()
    for type, itemTypeData in pairs(changes) do                                 -- EID에서 이름을 data.lua에서의 이름으로 덮어씌우게 변경합니다.
        for id, itemData in pairs(itemTypeData) do                              -- 굳이?여서 주석 처리
            EID:addDescriptionModifier(
            'EZITEMS | ' .. tostring(mod.Name) .. ' | ' .. itemData.name,
            function (descObj) return descObj.ObjType == 5 and descObj.ObjVariant == itemVariants[type] and descObj.ObjSubType == tonumber(id) end,
            function (descObj) descObj.Name = itemData.name; return descObj end
            )
        end
    end
end --]]
  
local function checkConflicts()
    for type, itemTypeData in pairs(changes) do
        for id, itemData in pairs(itemTypeData) do
            if EZITEMS[type][tostring(id)] then
                local removeOwn = false
                for idx, conflict in ipairs(EZITEMS[type][tostring(id)]) do
                    if conflict.mod ~= mod.Name then
                        print('')
                        print('[ ' .. tostring(mod.Name) .. ' ]')
                        print('[ EzTools Conflict ] Item (type "' .. type .. '") with id "' .. tostring(id) .. '" (name: "' .. itemData.name .. '") is already in use by mod "' .. conflict.mod .. '"')
                        print('[ EzTools Conflict ] Mod "' .. conflict.mod .. '" has higher priority, so "' .. mod.Name .. '"\'s item will not be loaded')
                        print('[ EzTools Conflict ] Summary: (' .. itemData.name .. ') -> (' .. conflict.name .. ')')
                        print('')
  
                        changes[type][tostring(id)] = nil
                        removeOwn = true
                        conflict.resolved = true
                    elseif conflict.mod == mod.Name and removeOwn then
                        EZITEMS[type][tostring(id)][idx] = nil
                        removeOwn = false
                    end
                end
            end
        end
    end
end
  
parseJsonData()
checkConflicts()

--[[ if EID then
    updateEid()
end --]]

if next(changes.trinkets) ~= nil then
    local t_queueLastFrame = {}
    local t_queueNow = {}
    
    mod:AddCallback(
        ModCallbacks.MC_POST_PLAYER_UPDATE,
  
        ---@param player EntityPlayer
        function(_, player)
            local playerKey = tostring(player.InitSeed)
            
            t_queueNow[playerKey] = player.QueuedItem.Item
            if (t_queueNow[playerKey] ~= nil) then
                local trinket = changes.trinkets[tostring(t_queueNow[playerKey].ID)]
                if trinket and t_queueNow[playerKey]:IsTrinket() and t_queueLastFrame[playerKey] == nil then
                    Game():GetHUD():ShowItemText(trinket.name, trinket.description)
                end
            end
            t_queueLastFrame[playerKey] = t_queueNow[playerKey]
        end
    )
end

if next(changes.items) ~= nil then
    local i_queueLastFrame = {}
    local i_queueNow = {}
    local birthrightDesc = include("data_birthrightDesc")
    
    mod:AddCallback(
        ModCallbacks.MC_POST_PLAYER_UPDATE,

        ---@param player EntityPlayer
        function(_, player)
            local playerKey = tostring(player.InitSeed)
            
            i_queueNow[playerKey] = player.QueuedItem.Item
            if i_queueNow[playerKey] and i_queueNow[playerKey]:IsCollectible() and i_queueLastFrame[playerKey] == nil then
                local itemID = i_queueNow[playerKey].ID
                if itemID == CollectibleType.COLLECTIBLE_BIRTHRIGHT then   -- 생득권이라면
                    local b_playerType = player:GetPlayerType()
                    local b_description = birthrightDesc[b_playerType]
                    if b_description then
                        Game():GetHUD():ShowItemText("생득권", b_description or "???")
                    end
                else
                    local item = changes.items[tostring(itemID)]   -- 일반 아이템이라면
                    if item then
                        Game():GetHUD():ShowItemText(item.name, item.description)
                    end
                end
            end
            i_queueLastFrame[playerKey] = i_queueNow[playerKey]
        end
    )
end


------ 사해사본 by siraxtas ------
function mod:FakeDeadSeaScrolls(item, rng)
    for _, player in pairs(Isaac.FindByType(EntityType.ENTITY_PLAYER, -1, -1, false, false)) do
        local pData = player:GetData()
        player = player:ToPlayer()
        if player:GetActiveItem() == CollectibleType.COLLECTIBLE_DEAD_SEA_SCROLLS then
            if item ~= CollectibleType.COLLECTIBLE_DEAD_SEA_SCROLLS then
                local deadSeaScrollsData = jsonData.items[tostring(item)]
                if deadSeaScrollsData then
                    Game():GetHUD():ShowItemText(deadSeaScrollsData.name)
                    pData.deadSeaScrollsIndicator_time = Game():GetFrameCount()
                else
                    print("ㅋ" .. tostring(item))
                end
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.FakeDeadSeaScrolls)

------ 레메게톤 ------
------ To modders who want to reference this code. THIS CODE IS UNSTABLE!!! DROP THAT IDEA RIGHT NOW!!!
local w_queueLastFrame = {}
local w_queueNow = {}
local delayedWisps = {}
local gameStarted = false   -- 게임 시작 시 초기화용

local function SetWispText(familiar)
    local familiarKey = tostring(familiar.InitSeed)
    local WispID = familiar.SubType
    
    w_queueNow[familiarKey] = WispID
    if WispID > 0 and w_queueLastFrame[familiarKey] == nil then
        local wisp = changes.items[tostring(WispID)]
        if wisp then
            Game():GetHUD():ShowItemText(wisp.name or "일종의 오류발생 메시지", wisp.description or "모드 제작자에게 연락바람")
        else
            print("[ EzTools | " .. tostring(mod.Name) .. "] Wisp ID " .. tostring(WispID) .. " not found in data")
        end
    end
    w_queueLastFrame[familiarKey] = w_queueNow[familiarKey]
end

function mod:ResetWispData()
    gameStarted = true
    delayedWisps = {}
end

function mod:DetectWisp(familiar)
    if familiar.Type == 3 and familiar.Variant == 237 and gameStarted then
        table.insert(delayedWisps, familiar)
    end
end

function mod:ShowWispText()
    if #delayedWisps > 0 then
        SetWispText(delayedWisps[1])   -- 1프레임 지연 실행
        table.remove(delayedWisps, 1)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.ResetWispData)
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.DetectWisp)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.ShowWispText)


------ 알약 ------
------ To modders who want to reference this code. THIS CODE IS UNSTABLE!!! DROP THAT IDEA RIGHT NOW!!!
local pillNames = include("data_pillNames")
local pillDescriptions = {
    [PillEffect.PILLEFFECT_I_FOUND_PILLS] = "...먹어 버렸어",
    [PillEffect.PILLEFFECT_EXPERIMENTAL] = ""
}

local lastStats = {}
local pendingStatComparison = false

function mod:SavePlayerStats(player)
    lastStats = {
        HP = player:GetMaxHearts(),
        Speed = player.MoveSpeed,
        Tears = player.MaxFireDelay,
        Range = player.TearRange,
        ShotSpeed = player.ShotSpeed,
        Luck = player.Luck
    }
end

function mod:CompareStats(player)
    if not pendingStatComparison then return end
    pendingStatComparison = false

    local ExpillChanges = { increased = {}, decreased = {} }
    local ExpillCurrentStats = {
        HP = player:GetMaxHearts(),
        Speed = player.MoveSpeed,
        Tears = player.MaxFireDelay,
        Range = player.TearRange,
        ShotSpeed = player.ShotSpeed,
        Luck = player.Luck
    }

    local statNames = {
        HP = "체력",
        Speed = "이동 속도",
        Tears = "공격 속도",
        Range = "사거리",
        ShotSpeed = "투사체 속도",
        Luck = "행운"
    }

    for stat, value in pairs(lastStats) do
        if stat == "Tears" then
            if ExpillCurrentStats[stat] < value then
                table.insert(ExpillChanges.increased, statNames[stat] .. " 증가")
            elseif ExpillCurrentStats[stat] > value then
                table.insert(ExpillChanges.decreased, statNames[stat] .. " 감소")
            end
        else
            if ExpillCurrentStats[stat] > value then
                table.insert(ExpillChanges.increased, statNames[stat] .. " 증가")
            elseif ExpillCurrentStats[stat] < value then
                table.insert(ExpillChanges.decreased, statNames[stat] .. " 감소")
            end
        end
    end

    local ExpillDescription = ""
    if #ExpillChanges.increased > 0 then
        ExpillDescription = table.concat(ExpillChanges.increased, ", ")
    end
    if #ExpillChanges.decreased > 0 then
        if ExpillDescription ~= "" then
            ExpillDescription = ExpillDescription .. ", "
        end
        ExpillDescription = ExpillDescription .. table.concat(ExpillChanges.decreased, ", ")
    end

    Game():GetHUD():ShowItemText("실험약", ExpillDescription)
end

function mod:FakePillText(pillEffect, player)
    if pillEffect == PillEffect.PILLEFFECT_EXPERIMENTAL then
        pendingStatComparison = true
    elseif pillNames[pillEffect] then
        Game():GetHUD():ShowItemText(pillNames[pillEffect], pillDescriptions[pillEffect])
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    mod:CompareStats(player)
    mod:SavePlayerStats(player)
end)

mod:AddCallback(ModCallbacks.MC_USE_PILL, mod.FakePillText)


------ 카드 ------
------ To modders who want to reference this code. THIS CODE IS UNSTABLE!!! DROP THAT IDEA RIGHT NOW!!!
local cardNames = include("data_cardNames")
local cardDescriptions = include("data_cardDescriptions")

local textDisplayed = false
local resetTimer = 0

function mod:FakeCardText(pickup)
    if pickup.Variant == PickupVariant.PICKUP_TAROTCARD and pickup:IsDead() then    -- 상점에서 카드 살 땐 HUD.ShowItemText 미작동
        local cardID = pickup.SubType                                               -- 아마 수정이 오래 걸릴 듯
        if cardNames[cardID] and not textDisplayed then
            Game():GetHUD():ShowItemText(cardNames[cardID], cardDescriptions[cardID])
            textDisplayed = true
            resetTimer = 18   -- 변경 금지
        end
    end
end

function mod:ResetTextFlag()
    if resetTimer > 0 then
        resetTimer = resetTimer - 1
        if resetTimer == 0 then
            textDisplayed = false
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.FakeCardText, PickupVariant.PICKUP_TAROTCARD)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.ResetTextFlag)


------ 행운의 동전 ------
local delayLuckyPenny = nil

function mod:LuckyPennyPickup(pickup, collider)
    if pickup.Variant == PickupVariant.PICKUP_COIN and pickup.SubType == CoinSubType.COIN_LUCKYPENNY then
        if collider.Type == EntityType.ENTITY_PLAYER then
            delayLuckyPenny = true
        end
    end
end

function mod:DelayedLuckyPennyText()   -- 1프레임 지연 실행
    if delayLuckyPenny then
        Game():GetHUD():ShowItemText("행운의 동전", "행운 증가")
        delayLuckyPenny = nil
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.LuckyPennyPickup, PickupVariant.PICKUP_COIN)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.DelayedLuckyPennyText)


--[[
------ 포켓 GO ------
------ To modders who want to reference this code. THIS CODE IS UNSTABLE!!! DROP THAT IDEA RIGHT NOW!!!
function mod:ShowPockGOText()
    if Game():GetRoom():GetFrameCount() == 0 then
        for i, entity in ipairs(Isaac.GetRoomEntities()) do
            if entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
                if entity:ToNPC() then
                    local entityName
                    if entity.Type == 10 and entity.Variant == 0 then
                        entityName = "험상궂은 게이퍼"
                    elseif entity.Type == 14 then
                        entityName = "푸터"
                    elseif entity.Type == 18 then
                        entityName = "공격 파리"                  -- 포켓 GO로 생성된 몹이 다른 방을 넘어갔을 때도
                    elseif entity.Type == 39 then                 -- HUD.ShowFortuneText가 작동되는 문제 때문에 주석 처리
                        entityName = "비스"                       -- 아마 수정이 오래 걸릴 듯
                    elseif entity.Type == 234 then
                        entityName = "원 투스"
                    elseif entity.Type == 258 then
                        entityName = "뚱뚱한 박쥐"
                    end
                    if entityName ~= nil then
                        Game():GetHUD():ShowFortuneText(entityName .. "(이)가 튀어나왔다!")
                    else
                        Game():GetHUD():ShowFortuneText("entityName 값이 없습니다.","모드 제작자에게 연락바람")
                    end
                end
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.ShowPockGOText) --]]


------ 운세 / 규칙 by kittenchilly ------
include("fortune_apioverride")
mod.Fortunes = include("fortunes_cookie")
mod.Rules = include("fortunes_rule")
mod.SpecialSeeds = {
    "SL0W 4ME2", "HART BEAT", "CAM0 K1DD", "CAM0 F0ES", "CAM0 DR0P", "FART SNDS", "B00B T00B", "DYSL EX1A",
    "KEEP TRAK", "KEEP AWAY", "DRAW KCAB", "CHAM P10N", "1MN0 B0DY", "BL1N DEYE", "BASE MENT", "C0CK FGHT",
    "C0NF ETT1", "FEAR M1NT", "CLST RPH0", "FRA1 DN0T", "BL00 00DY", "BRWN SNKE", "PAC1 F1SM", "D0NT ST0P",
    "THEG H0ST", "30M1 N1TS", "MED1 C1NE", "FACE D0WN", "C0ME BACK", "FREE 2PAY", "PAY2 PLAY", "T0PH EAVY",
    "T1NY D0ME", "PTCH BLCK", "TEAR GL0W", "ANDA NTE", "LARG HET0", "ALLE GR0", "PRES T0", "THEB LANK",
    "HARD HARD", "BRTL B0NS", "KAPP A", "CHRS TMAS", "H0H0 H0H0", "K1DS M0DE", "1CES KATE", "DARK NESS",
    "LABY RNTH", "L0ST", "VNKN 0WN", "MAZE", "BL1N D", "CVRS ED", "N1TE L1TE", "THRE AD", "F0VN D",
    "N0W1 KN0W", "BRA1 LLE", "PATH F1ND", "BLCK CNDL", "N0RE TVRN", "G0NE S00N", "ALM1 GHTY", "BRAV ERY",
    "C0WR D1CE", "AX1S ALGN", "SVPE RH0T", "M0DE SEVN"
}

local function showSpecialSeed()
    local seed = mod.SpecialSeeds[math.random(#mod.SpecialSeeds)]
    Game():GetHUD():ShowFortuneText(seed)
end

local function split(pString, pPattern)
    local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)
    while s do
       if s ~= 1 or cap ~= "" then
      table.insert(Table,cap)
       end
       last_end = e+1
       s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= #pString then
       cap = pString:sub(last_end)
       table.insert(Table, cap)
    end
    return Table
end

local function fortuneArray(array)
    Game():GetHUD():ShowFortuneText(
        array[1], 
        array[2] or nil, 
        array[3] or nil, 
        array[4] or nil, 
        array[5] or nil, 
        array[6] or nil, 
        array[7] or nil, 
        array[8] or nil, 
        array[9] or nil, 
        array[10] or nil
    )
end

function mod:ShowFortune(forcedtune)
    if forcedtune then
        local fortune = split(forcedtune, "\n")
        fortuneArray(fortune)
    else
        mod.FortuneTable = mod.FortuneTable or {}
        if #mod.FortuneTable <= 1 then
            local fortunelist = mod.Fortunes
            local fortunetablesetup = split(mod.Fortunes, "\n\n")
            for i = 1, #fortunetablesetup do
                table.insert(mod.FortuneTable, split(fortunetablesetup[i], "\n"))
            end
        end
        local choice = math.random(#mod.FortuneTable)
        local fortune = mod.FortuneTable[choice]
        fortuneArray(fortune)
    end
end

function mod:ShowRule(forcedrule)
    if forcedrule then
        local rule = split(forcedrule, "\n")
        fortuneArray(rule)
    else
        mod.RuleTable = mod.RuleTable or {}
        if #mod.RuleTable <= 1 then
            local rulelist = mod.Rules
            local ruletablesetup = split(mod.Rules, "\n\n")
            for i = 1, #ruletablesetup do
                table.insert(mod.RuleTable, split(ruletablesetup[i], "\n"))
            end
        end
        local choice = math.random(#mod.RuleTable)
        local rule = mod.RuleTable[choice]
        fortuneArray(rule)
    end
end

function mod:checkFortuneMachine()
	local totalFortune = Isaac.FindByType(EntityType.ENTITY_SLOT, 3)
	if #totalFortune > 0 then
		for _, fortuneMachine in ipairs(totalFortune) do
			local fortunsprite = fortuneMachine:GetSprite()
			if fortunsprite:IsPlaying("Prize") then
				if fortunsprite:GetFrame() == 4 then
					local pickupFound
					for _, pickup in pairs(Isaac.FindByType(5, -1, -1)) do
						if pickup and pickup.Type == 5 and pickup.FrameCount <= 0 then
							pickupFound = true
						end
					end
					if not pickupFound then
						mod:ShowFortune()
					end
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.checkFortuneMachine)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
	local pickupFound
	for _, pickup in pairs(Isaac.FindByType(5, -1, -1)) do
		if pickup and pickup.Type == 5 and pickup.FrameCount <= 0 then
			pickupFound = true
		end
	end
	if not pickupFound then
		mod:ShowFortune()
	end
end, CollectibleType.COLLECTIBLE_FORTUNE_COOKIE)

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card)
    if card == Card.CARD_RULES then
        if math.random() < 0.1 then   -- 10% 확률로 시드
            showSpecialSeed()
        else
            mod:ShowRule()
        end
    end
end)

APIOverride.OverrideClassFunction(Game, "ShowFortune", function()
	mod:ShowFortune()
	return
end)

APIOverride.OverrideClassFunction(Game, "ShowRule", function()
    if math.random() < 0.1 then   -- 10% 확률로 시드
        showSpecialSeed()
    else
        mod:ShowRule()
    end
    return
end)