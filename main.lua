REPKOR = RegisterMod("Repentance+ Korean", 1)
local mod = REPKOR

------ 온라인에서 비활성화 ------
mod.offline = true
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
    local WhoAmI = player:GetPlayerType()
    if (WhoAmI ~= PlayerType.PLAYER_JACOB and WhoAmI ~= PlayerType.PLAYER_ESAU) and
    (WhoAmI ~= PlayerType.PLAYER_THEFORGOTTEN and WhoAmI ~= PlayerType.PLAYER_THESOUL) and
    (WhoAmI ~= PlayerType.PLAYER_THEFORGOTTEN_B and WhoAmI ~= PlayerType.PLAYER_THESOUL_B) and
    (Game():GetNumPlayers() > 1 or player:HasCollectible(CollectibleType.COLLECTIBLE_STRAW_MAN)) then
        mod.offline = false
    else
        mod.offline = true
        end
    end
end)


------ 경고 띄우기 ------
------ To modders who want to reference this code. THIS CODE IS UNSTABLE!!! DROP THAT IDEA RIGHT NOW!!!
local runningRep = REPENTANCE and not REPENTANCE_PLUS
local killingMom = false
local conflictKLP = false

if KoreanLocalizingPlus then
    conflictKLP = true
end

local sprite = Sprite()
local function checkConflictsAndLoadAnm2()
    killingMom = Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_CUBE_OF_MEAT):IsAvailable()
    if not killingMom then
        print("\n[ Repentance+ Korean ]\nIn your current save file, you haven't killed Mom once.\nIf you proceed as is, the achievement won't unlock!\n")
    end

    if runningRep then
        print("\n[ Repentance+ Korean ]\nz_REPENTANCE+ KOREAN mod is only available with the Repentance+ DLC.\nPLEASE DISABLE THE MOD NOW.\n")
    end

    if not killingMom or runningRep or conflictKLP then
        sprite:Load("gfx/ui/popup_warning2.anm2", true)
    else
        sprite:Load("gfx/cutscenes/backwards.anm2", true)
    end
end

local function GetScreenSize()
    local pos = Game():GetRoom():WorldToScreenPosition(Vector(0,0)) - Game():GetRoom():GetRenderScrollOffset() - Game().ScreenShakeOffset
  
    local rx = pos.X + 60 * 26 / 40
    local ry = pos.Y + 162.5 * (26 / 40)
  
    return Vector(rx*2 + 13*26, ry*2 + 7*26)
end

function RenderSub(Anm2)
    sprite:Play(Anm2)
    sprite:Update()
    sprite.Scale = Vector(1, 1)
    sprite.Color = Color(1, 1, 1, 1, 0, 0, 0)

    local warningPosX = Vector(0,0)
    if not killingMom then
        if Options.FoundHUD then
            warningPosX = GetScreenSize().X/1.33
        else
            warningPosX = GetScreenSize().X/4
        end
        sprite.Scale = Vector(0.5, 0.5)
        sprite:Render(Vector(warningPosX, GetScreenSize().Y/1.5), Vector(0,0), Vector(0,0))
    elseif runningRep or conflictKLP then
        sprite:Render(Vector(GetScreenSize().Y/1.96, GetScreenSize().Y/2.2), Vector(0,0), Vector(0,0))
    else
        sprite.Color = Color(1, 1, 1, 0.6, 0, 0, 0)
        sprite:Render(Vector(GetScreenSize().X/2, GetScreenSize().Y*0.85), Vector(0,0), Vector(0,0))
    end
end

local showAnm2 = false
local renderingTime = 15
local DisplayedTime = 0
local function updateRenderAnm2()
    if not killingMom or runningRep or conflictKLP then
        DisplayedTime = DisplayedTime + 1
        if DisplayedTime >= renderingTime then
            showAnm2 = true
        end
    end
end

local function renderWarning()
    if showAnm2 then
        if not killingMom then
            if EID then return end
            RenderSub("notKillingMom")
        elseif not conflictKLP then
            RenderSub("runningRep")
        else
            RenderSub("conflictWithKLP")
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, checkConflictsAndLoadAnm2)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, updateRenderAnm2)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, renderWarning)


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
local data = include('misc.data')   -- support by raiiiny
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
                if trinket and t_queueNow[playerKey]:IsTrinket() and t_queueLastFrame[playerKey] == nil and mod.offline then
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
    local birthrightDesc = include('misc.data_birthrightDesc')

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
                    if b_description and mod.offline then
                        Game():GetHUD():ShowItemText("생득권", b_description or "???")
                    end
                else
                    local item = changes.items[tostring(itemID)]   -- 일반 아이템이라면
                    if item and mod.offline then
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
            if item ~= CollectibleType.COLLECTIBLE_DEAD_SEA_SCROLLS then                 -- 사해사본을 소지하지 않은 상태에서
                local deadSeaScrollsData = jsonData.items[tostring(item)]                -- 와일드 카드/보이드로 사해사본을 발동하면 번역되지 않는 문제 있음
                if deadSeaScrollsData then                                               -- 근데 누가 와일드 카드 그 아까운 걸 사해사본으로 씀
                    Game():GetHUD():ShowItemText(deadSeaScrollsData.name)
                    pData.deadSeaScrollsIndicator_time = Game():GetFrameCount()
                else
                    Game():GetHUD():ShowItemText("일종의 오류발생 메시지", "모드 제작자에게 연락바람")
                end
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.FakeDeadSeaScrolls)


------ 제작 가방 ------
local function BoCText(player)
    if EID.BoC and EID.BoC.BagItems and #EID.BoC.BagItems == 8 then
        local craftedOutput = EID:calculateBagOfCrafting(EID.BoC.BagItems)
        if craftedOutput and craftedOutput ~= 0 then
            local bagofCraftingData = jsonData.items[tostring(craftedOutput)]
            if bagofCraftingData then
                Game():GetHUD():ShowItemText(bagofCraftingData.name, bagofCraftingData.description)
            else
                print("[ Repentance+ Korean ]\n" .. craftedOutput .. "번 아이템의 번역어가 없습니다.")
            end
        end
    end
end

if EID then
    mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
        if player:GetPlayerType() ~= PlayerType.PLAYER_CAIN_B then return end
        BoCText(player)
    end)
else
    Isaac.DebugString("EID가 설치되지 않았습니다. 더럽혀진 카인이 아이템을 획득해도 그 아이템의 이름과 설명은 번역되지 않습니다.")
end


------ 레메게톤 ------
------ To modders who want to reference this code. THIS CODE IS UNSTABLE!!! DROP THAT IDEA RIGHT NOW!!!
local w_queueLastFrame = {}
local w_queueNow = {}
local delayedWisps = {}
local gameStarted = false   -- 게임 시작 시 초기화용

local function WispText(familiar)
    local familiarKey = tostring(familiar.InitSeed)
    local WispID = familiar.SubType
    
    w_queueNow[familiarKey] = WispID
    if WispID > 0 and w_queueLastFrame[familiarKey] == nil then
        local wisp = changes.items[tostring(WispID)]
        if wisp and mod.offline then
            Game():GetHUD():ShowItemText(wisp.name or "일종의 오류발생 메시지", wisp.description or "모드 제작자에게 연락바람")
        else
            print("[ Repentance+ Korean ]\n" .. tostring(WispID) .. "번 아이템이 모드 아이템이거나 플레이어가 2인 이상인 상태입니다.")
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
        local wispData = familiar:GetData()
        if familiar.Position:Distance(Vector(-1000, -1000)) < 1 then return end     -- 임시방편. HiddenItemManager를 사용하는 모드와 충돌 방지
        table.insert(delayedWisps, familiar)
    end
end

function mod:ShowWispText()
    if #delayedWisps > 0 then
        WispText(delayedWisps[1])   -- 1프레임 지연 실행
        table.remove(delayedWisps, 1)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.ResetWispData)
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.DetectWisp)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.ShowWispText)


------ 알약 ------
------ To modders who want to reference this code. THIS CODE IS UNSTABLE!!! DROP THAT IDEA RIGHT NOW!!!
local pillNames = include('misc.data_pillNames')
local pillDescriptions = {
    [PillEffect.PILLEFFECT_I_FOUND_PILLS] = "...먹어 버렸어",
    [PillEffect.PILLEFFECT_EXPERIMENTAL] = ""
}

local lastStats = {}
local pendingStatComparison = {}

function mod:SavePlayerStats(player)
    lastStats[player.InitSeed] = {
        HP = player:GetMaxHearts(),
        Speed = player.MoveSpeed,
        Tears = player.MaxFireDelay,
        Range = player.TearRange,
        ShotSpeed = player.ShotSpeed,
        Luck = player.Luck
    }
end

function mod:CompareStats(player)
    if not pendingStatComparison[player.InitSeed] then return end
    pendingStatComparison[player.InitSeed] = false

    if player:HasCollectible(CollectibleType.COLLECTIBLE_LIBRA) then return end   -- 천칭자리 소지 시 번역 비활성화
    
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

    for stat, value in pairs(lastStats[player.InitSeed]) do
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

    if mod.offline then
        Game():GetHUD():ShowItemText("실험약", ExpillDescription)
    end
end

function mod:FakePillText(pillEffect, player)
    if pillEffect == PillEffect.PILLEFFECT_EXPERIMENTAL then
        pendingStatComparison[player.InitSeed] = true
    elseif pillNames[pillEffect] and mod.offline then
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
local cardNames = include('misc.data_cardNames')
local cardDescriptions = include('misc.data_cardDescriptions')

local textDisplayed = false
local resetTimer = 0
local bagFlagTimer = 0

local pickupCollected = {}
local pickupJustTouched = {}
local byBagofCrafting = false

mod.meaninglessLOL = {}
mod.pickupIDLookup = {}
mod.runeIDs = {}

function mod:getBagOfCraftingID(Variant, SubType)
	local entry = mod.pickupIDLookup[Variant.."."..SubType]
	if entry ~= nil then
		return entry
	elseif Variant == 300 then
		if SubType == 0 then
			return nil
		elseif mod.runeIDs[SubType] then
			return {23}
		else
			return {21}
		end
	end
	return nil
end

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup,collider,_)
	if collider.Type == EntityType.ENTITY_PLAYER or collider.Type == EntityType.ENTITY_FAMILIAR or
		collider.Type == EntityType.ENTITY_BUMBINO or collider.Type == EntityType.ENTITY_ULTRA_GREED then
        pickupJustTouched[pickup.Index] = true
	end
end)

---@diagnostic disable-next-line: duplicate-set-field
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    for _, pickup in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, -1, false, false)) do
        if pickup:GetSprite():GetAnimation() == "Collect" and not pickupCollected[pickup.Index] then
            pickupCollected[pickup.Index] = true
            if not pickupJustTouched[pickup.Index] then
                local REPKORcraftingIDs = mod:getBagOfCraftingID(pickup.Variant, pickup.SubType)
                if REPKORcraftingIDs ~= nil then
                    for _,v in ipairs(REPKORcraftingIDs) do
						if #mod.meaninglessLOL >= 8 then table.remove(mod.meaninglessLOL, 1) end
						table.insert(mod.meaninglessLOL, v)
                        byBagofCrafting = true
                        bagFlagTimer = 18        -- 오로지 제작 가방으로 카드를 수집할 때 텍스트가 뜨는 걸 방지하기 위한 코드
					end                          -- Original by EID Developers
                end
            end
        end
        pickupJustTouched[pickup.Index] = nil
    end
end)

function mod:FakeCardText()
    if byBagofCrafting then return end
    for _, pickup in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, -1, false, false)) do
        if pickup:IsDead() then
            local cardID = pickup.SubType
            if cardNames[cardID] and not textDisplayed and mod.offline then
                Game():GetHUD():ShowItemText(cardNames[cardID], cardDescriptions[cardID])
                textDisplayed = true
                resetTimer = 18      -- 왜인지는 모르는데 꼭 이렇게 코드를 짜야지 카드를 들자마자 텍스트가 뜸
                break                -- 피격 등의 이유로 18 프레임 내에 카드를 다시 들게 되면 HUD.ShowItemText 미작동
            end
        end
    end
end

function mod:ResetTextFlag()
    if resetTimer > 0 then
        resetTimer = resetTimer - 1
        if resetTimer == 0 then
            textDisplayed = false
        end
    elseif bagFlagTimer > 0 then
        bagFlagTimer = bagFlagTimer - 1
        if bagFlagTimer == 0 then
            byBagofCrafting = false
        end
    end
end

function mod:BoCOnNewRoom(_)
	pickupsCollected = {}
    byBagofCrafting = false
    bagFlagTimer = 0
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.FakeCardText)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.ResetTextFlag)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.BoCOnNewRoom)


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
    if delayLuckyPenny and mod.offline then
        Game():GetHUD():ShowItemText("행운의 동전", "행운 증가")
        delayLuckyPenny = nil
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.LuckyPennyPickup, PickupVariant.PICKUP_COIN)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.DelayedLuckyPennyText)


------ 포켓 GO ------
------ To modders who want to reference this code. THIS CODE IS UNSTABLE!!! DROP THAT IDEA RIGHT NOW!!!
local friendlyNames = {
    [10] = { [0] = "험상궂은 게이퍼" },
    [14] = { [0] = "푸터" },
    [18] = { [0] = "공격 파리" },
    [39] = { [0] = "비스" },
    [234] = { [0] = "원 투스" },
    [258] = { [0] = "뚱뚱한 박쥐" }
}
local friendlyEntityCounts = {}

function mod:MarkPokeGOMonster(entity)
    if entity:ToNPC() then
        entity:GetData().IsPokeGOMonster = true
    end
end

function mod:ShowPokeGOText()
    if Game():GetRoom():GetFrameCount() == 0 then
        local currentCounts = {}
        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            if entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and entity:ToNPC() then
                local entityType = entity.Type
                local entityVariant = entity.Variant
                local entityName = friendlyNames[entityType] and friendlyNames[entityType][entityVariant]

                if entityName and entity:GetData().IsPokeGOMonster then
                    local friendlyEntityKey = entityName .. "_" .. entity.InitSeed
                    currentCounts[friendlyEntityKey] = (currentCounts[friendlyEntityKey] or 0) + 1

                    if not friendlyEntityCounts[friendlyEntityKey] or currentCounts[friendlyEntityKey] > friendlyEntityCounts[friendlyEntityKey] then
                        Game():GetHUD():ShowFortuneText(entityName .. "(이)가 튀어나왔다!")
                    end
                end
            end
        end

        friendlyEntityCounts = currentCounts
    end
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if npc.SpawnerType == EntityType.ENTITY_PLAYER and npc.SpawnerVariant == 0 then
        mod:MarkPokeGOMonster(npc)
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    mod:ShowPokeGOText()
end)


------ 운세/규칙 by kittenchilly ------
include('misc.fortune_apioverride')
mod.Fortunes = include('misc.fortune_cookie')
mod.Rules = include('misc.fortune_rule')
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

local function ShowSpecialSeed()
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
            local sprite = fortuneMachine:GetSprite()
            local fortuneData = fortuneMachine:GetData()

            if sprite:IsPlaying("Prize") then
                local frame = sprite:GetFrame()
                if sprite:GetAnimation() == "Prize" and frame >= 4 then
                    if not fortuneData.prizeTriggered then
                        local pickupFound = false
                        for _, pickup in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, -1, -1)) do
                            if pickup.FrameCount <= 0 then
                            pickupFound = true
                            end
                        end
                        if not pickupFound then
                            mod:ShowFortune()
                        end
                        fortuneData.prizeTriggered = true
                    end
                end

                if frame == 0 then
                    fortuneData.prizeTriggered = false
                end
            else
                fortuneData.prizeTriggered = false
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
        if math.random() < 0.1 then   -- 10% 확률로 시드 표시
            ShowSpecialSeed()
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
    if math.random() < 0.1 then   -- 10% 확률로 시드 표시
        ShowSpecialSeed()
    else
        mod:ShowRule()
    end
    return
end)


------ 축복 받은 느낌! ------
------ To modders who want to reference this code. THIS CODE IS UNSTABLE!!! DROP THAT IDEA RIGHT NOW!!!
local lastSacrificeAngelChance = nil
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    if Game():GetRoom():GetType() == RoomType.ROOM_SACRIFICE then
        local currentAngelChance = Game():GetLevel():GetAngelRoomChance()

        if lastSacrificeAngelChance == nil then
            lastSacrificeAngelChance = currentAngelChance
        end

        if currentAngelChance > lastSacrificeAngelChance then
            Game():GetHUD():ShowFortuneText("축복 받은 느낌!")
        end
        lastSacrificeAngelChance = currentAngelChance
    else
        lastSacrificeAngelChance = nil
    end
end)

local lastConfessionalAngelChance = nil
local previousCurses = nil
function mod:checkConfessional()
    local confessionals = Isaac.FindByType(EntityType.ENTITY_SLOT, 17)
    if #confessionals > 0 then
        for _, confessional in ipairs(confessionals) do
            local confessionalSprite = confessional:GetSprite()
            if confessionalSprite:IsPlaying("Prize") and (TMplus or tmmc or confessionalSprite:GetFrame() == 4) then
                local currentAngelChance = Game():GetLevel():GetAngelRoomChance()
                local currentCurses = Game():GetLevel():GetCurses()

                if lastConfessionalAngelChance == nil then
                    lastConfessionalAngelChance = currentAngelChance
                end

                if currentAngelChance > lastConfessionalAngelChance then
                    Game():GetHUD():ShowFortuneText("축복 받은 느낌!")
                elseif previousCurses ~= nil and previousCurses ~= 0 and currentCurses == 0 then
                    Game():GetHUD():ShowFortuneText("축복 받은 느낌!")
                end

                lastConfessionalAngelChance = currentAngelChance
                previousCurses = currentCurses
            end
        end
    else
        lastConfessionalAngelChance = nil
    end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.checkConfessional)



------ 휴지통 ------
--[[   기획만 해둔 코드들입니다.


-- 예의 밥말아쳐먹은 코드
local function GetCurrentModPath()
    if debug then
        return string.sub(debug.getinfo(GetCurrentModPath).source, 2) .. "/../"
    else
        return nil
    end
end

local function GetModsPath()
    local currentModPath = GetCurrentModPath()
    if not currentModPath then return nil end
    return string.match(currentModPath, "(.+/mods/)")
end

local modsPath = GetModsPath()
if wakaba_krdesc and modsPath then
    local filePath = modsPath .. "fiendfolio-reheated-eidkr_2852472516/main.lua"
    local backupPath = filePath .. ".backup"

    local function createBackup()
        if not io.open(backupPath, "r") then
            local file = io.open(filePath, "r")
            if file then
                local content = file:read("*all")
                file:close()

                local backupFile = io.open(backupPath, "w")
                backupFile:write(content)
                backupFile:close()
            end
        end
    end

    local function modifyFile()
        local file = io.open(filePath, "r")
        if file then
            local content = file:read("*all")
            file:close()

            content = content:gsub(
                "if Options.Language ~= \"kr\" then return end",
                "if not REPKOR and Options.Language ~= \"kr\" then return end"
            )

            local writeFile = io.open(filePath, "w")
            writeFile:write(content)
            writeFile:close()
        end
    end

    local function restoreBackup()
        local backupFile = io.open(backupPath, "r")
        if backupFile then
            local content = backupFile:read("*all")
            backupFile:close()

            local writeFile = io.open(filePath, "w")
            writeFile:write(content)
            writeFile:close()

            os.remove(backupPath)
        end
    end

    createBackup()
    modifyFile()
    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, restoreBackup)
end
--]]