-- 누가 이 븅냐링 스파게티 코드 좀 고쳐주세요!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- 누가 이 븅냐링 스파게티 코드 좀 고쳐주세요!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- 누가 이 븅냐링 스파게티 코드 좀 고쳐주세요!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- 누가 이 븅냐링 스파게티 코드 좀 고쳐주세요!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- 누가 이 븅냐링 스파게티 코드 좀 고쳐주세요!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- 누가 이 븅냐링 스파게티 코드 좀 고쳐주세요!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- 누가 이 븅냐링 스파게티 코드 좀 고쳐주세요!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- 누가 이 븅냐링 스파게티 코드 좀 고쳐주세요!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- 누가 이 븅냐링 스파게티 코드 좀 고쳐주세요!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- 누가 이 븅냐링 스파게티 코드 좀 고쳐주세요!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- 누가 이 븅냐링 스파게티 코드 좀 고쳐주세요!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- 누가 이 븅냐링 스파게티 코드 좀 고쳐주세요!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- 누가 이 븅냐링 스파게티 코드 좀 고쳐주세요!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


REPKOR = RegisterMod("Repentance+ Korean", 1)
local mod = REPKOR

------ EID ------
function mod:ChangeEIDLanguage()
    return "ko_kr"    -- EID(v4.99 이상)에서 언어를 Auto로 설정했을 때 한국어가 선택되도록 변경
end
mod:AddCallback("EID_EVALUATE_AUTO_LANG", mod.ChangeEIDLanguage)

local function AddPickupWarning(descObj)
    local targetPickup = descObj.ObjType == 5 and (
            (descObj.ObjVariant == 100 and descObj.ObjSubType == 667) or                                   -- 밀짚인형
            (descObj.ObjVariant == 300 and (descObj.ObjSubType == 95 or descObj.ObjSubType == 97)) or      -- 포가튼/야곱과 에사우의 영혼
            (descObj.ObjVariant == 350 and descObj.ObjSubType == 180)                                      -- 되찾은 영혼
        )
    if targetPickup and not REPENTOGON then
        EID:appendToDescription(descObj,
            "#{{Warning}} {{ColorError}}한글패치 관련:" ..
            "#{{Blank}} {{ColorError}}획득(사용) 이후 플레이어가 픽업을 얻을 때 텍스트가 이중으로 표시됩니다."
        )
    end

    local targetPickup2 = descObj.ObjType == 5 and descObj.ObjVariant == 100 and descObj.ObjSubType == 505    -- 포켓 GO
    if targetPickup2 then
        EID:appendToDescription(descObj,
            "#{{Warning}} {{ColorError}}한글패치 관련:" ..
            "#{{Blank}} {{ColorError}}아군 등장 텍스트가 잘못 표시될 수 있습니다."
        )
    end

    return descObj
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    if not EID then return end

    EID:addDescriptionModifier("한글패치 EID 경고용", AddPickupWarning)

    EID:addPill(
        PillEffect.PILLEFFECT_EXPERIMENTAL,
        -- 원본
        "랜덤 능력치 두가지가 증가하거나 감소합니다." ..
        -- 경고
        "#{{Warning}} {{ColorError}}한글패치 관련:" ..
        "#{{Blank}} {{ColorError}}사용 이후 표시되는 능력치 증감 설명은 부정확할 수 있으며," ..
        " {{Collectible304}} Libra 소지 시 번역되지 않습니다.",
        -- 나머지
        "실험용 알약",
        "ko_kr"
    )

    if EdenBlessingFix then    -- 왜인진 모르겠는데 패치안됨
        EID:addCollectible(
            CollectibleType.COLLECTIBLE_EDENS_BLESSING,
            "↑ {{TearsSmall}}연사 +0.7#다음 게임에서 랜덤 아이템을 하나 들고 시작합니다.#{{Blank}} {{ColorGray}}(최대 10개)",
            "에덴의 축복",
            "ko_kr"
        )
    end
end)


--[[-- 온라인 -----
mod.offline = true
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
    local player = Isaac.GetPlayer()
    local WhoAmI = player:GetPlayerType()
    if (WhoAmI ~= PlayerType.PLAYER_JACOB and WhoAmI ~= PlayerType.PLAYER_ESAU) and
    (WhoAmI ~= PlayerType.PLAYER_THEFORGOTTEN and WhoAmI ~= PlayerType.PLAYER_THESOUL) and
    (WhoAmI ~= PlayerType.PLAYER_THEFORGOTTEN_B and WhoAmI ~= PlayerType.PLAYER_THESOUL_B) and
    Game():GetNumPlayers() > 1 or player:HasCollectible(CollectibleType.COLLECTIBLE_STRAW_MAN) then
     -- mod.offline = false
        mod.offline = true    -- 임시방편
    else
        mod.offline = true
    end
end)]]


------ 경고 메시지 ------
mod.warningTimers = {}
mod.warningsToShow = {}
mod.warningMaxTimes = {}
mod.warningRed = 1
mod.warningScale = 0.5
mod.warningOpacity = 0.75

mod.runningRep = REPENTANCE and not REPENTANCE_PLUS    -- 리펜턴스 DLC인가?
mod.notRestart = false                                 -- 설치 후 재실행을 했는가?
mod.saveDataDummy = tonumber(mod:LoadData()) or 0

mod.notKillingMom = false                              -- 엄마를 처치했는가?
mod.notRunningEID = false                              -- EID가 실행 중인가?
mod.notEIDKorean = false                               -- EID가 한국어로 설정돼있는가?

mod.detectStageAPI = false                             -- StageAPI가 켜져있는가?
mod.stageAPITimer = 0
mod.stageAPIoffset = 0

mod.hasTM = false                                      -- TMTRAINER를 소지 중인가?
mod.tmWarningShown = false

local messages = {
    notKillingMom = "지금 모드를 적용하면 도전 과제가 해금되지 않을 수 있습니다!",
    notRunningEID = "아이템 설명모드를 감지하지 못했습니다! 일부 번역 기능이 동작하지 않습니다!",
    notEIDKorean = "아이템 설명모드가 한국어로 설정돼있지 않습니다. Mod Config Menu Pure를 구독한 후 수동으로 설정하세요.",
    hasTM = "TMTRAINER를 소지 중입니다! 일부 번역 기능이 동작하지 않습니다!",

    stageAPI = REPENTOGON and "('지하 묘지' 스테이지의 이름만 번역되지 않습니다.)"
                           or "(스테이지 이름이 번역되지 않습니다. REPENTOGON+ 적용 시 해결됩니다.)"
}

local warningDurations = {
    [messages.notKillingMom] = 180,
    [messages.notRunningEID] = 180,
    [messages.notEIDKorean] = 180,
    [messages.hasTM] = 180
}

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    if not mod:HasData() then
        mod.notRestart = true
    end
    mod.saveDataDummy = mod.saveDataDummy + 1
    mod:SaveData(mod.saveDataDummy)

    if EID then
        if EID.ModVersion > 4.2 and EID.ModVersion < 4.99 then
            if EID.Config["Language"] ~= "ko_kr" then
                mod.notEIDKorean = true
                ----
                local duration = warningDurations[messages.notEIDKorean]
                mod.warningTimers[messages.notEIDKorean] = duration
                mod.warningMaxTimes[messages.notEIDKorean] = duration
            end
        end
    else
        mod.notRunningEID = true
        ----
        local duration = warningDurations[messages.notRunningEID]
        mod.warningTimers[messages.notRunningEID] = duration
        mod.warningMaxTimes[messages.notRunningEID] = duration
    end

    if StageAPI then
        mod.detectStageAPI = true
        mod.stageAPITimer = 60
        mod.stageAPIoffset = 8
    end

    mod.notKillingMom = not Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_CUBE_OF_MEAT):IsAvailable()
    if mod.notKillingMom and not EID then
        local duration = warningDurations[messages.notKillingMom]
        mod.warningTimers[messages.notKillingMom] = duration
        mod.warningMaxTimes[messages.notKillingMom] = duration
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function()
    if Isaac.GetPlayer():HasCollectible(CollectibleType.COLLECTIBLE_TMTRAINER) and not mod.tmWarningShown then
        mod.hasTM = true
        mod.tmWarningShown = true
        ----
        local duration = warningDurations[messages.hasTM]
        mod.warningTimers[messages.hasTM] = duration
        mod.warningMaxTimes[messages.hasTM] = duration
    else
        mod.hasTM = false
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    for string, time in pairs(mod.warningTimers) do
        mod.warningTimers[string] = time - 1
        if mod.warningTimers[string] <= 0 then
            mod.warningTimers[string] = nil
            mod.warningMaxTimes[string] = nil
        end
    end
    
    if mod.stageAPITimer > 0 then
        mod.stageAPITimer = mod.stageAPITimer - 1
    end
end)

local function GetCurrentModPath()
	if debug then
		return string.sub(debug.getinfo(GetCurrentModPath).source,2) .. "/../"
	end
	--use some very hacky trickery to get the path to this mod
	local _, err = pcall(require, "")
	local _, basePathStart = string.find(err, "no file '", 1)
	local _, modPathStart = string.find(err, "no file '", basePathStart)
	local modPathEnd, _ = string.find(err, ".lua'", modPathStart)
	local modPath = string.sub(err, modPathStart+1, modPathEnd-1)
	modPath = string.gsub(modPath, "\\", "/")
	modPath = string.gsub(modPath, "//", "/")
	modPath = string.gsub(modPath, ":/", ":\\")

	return modPath
end
mod.modPath = GetCurrentModPath()

local warningFontBlack = Font()
warningFontBlack:Load("font/cjk/lanapixel.fnt")

local warningFont12 = Font()
warningFont12:Load(mod.modPath .. "resources/font/teammeatex/teammeatex12.fnt")

local warningFont16 = Font()
warningFont16:Load(mod.modPath .. "resources/font/teammeatex/teammeatex16.fnt")

local function DrawWarningString(font, text, offset, color)
    if Game():GetHUD():IsVisible() then
        Game():GetHUD():SetVisible(false)
    end

    if Isaac.GetPlayer().ControlsEnabled then
	    Isaac.GetPlayer().ControlsEnabled = false
    end

	local x = Isaac.GetScreenWidth() / 2 - font:GetStringWidthUTF8(text) / 2
    local y = Isaac.GetScreenHeight() / 2 - offset
    font:DrawStringUTF8(text, x, y, color or KColor(1, 1, 1, 1), 0, true)
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    --[[ if Isaac.GetScreenPointScale() == 3 then
        mod.warningScale = 0.66
    else
        mod.warningScale = 0.5
    end ]]

    if mod.runningRep then
        warningFontBlack:DrawStringScaledUTF8("쀏", 400, -1500, 400, 400, KColor(0, 0, 0, 1), 0, true)
        DrawWarningString(warningFont16, "리펜턴스+ 한글패치가", 79, KColor(1, 0.5, 0.5, 1))
        DrawWarningString(warningFont16, "리펜턴스에서 실행되었습니다!", 55, KColor(1, 0.5, 0.5, 1))
        DrawWarningString(warningFont12, "현재 상태로는 게임 진행이 불가합니다.", 22, KColor(1, 1, 1, 0.5))
        DrawWarningString(warningFont12, "일시정지 키로 게임을 나가고 아래 매뉴얼을 따르세요.", 4, KColor(1, 1, 1, 0.5))
        DrawWarningString(warningFont12, "리펜턴스로 하시려면 z_REPENTANCE+ KOREAN 모드를 꺼주세요.", -24)
        DrawWarningString(warningFont12, "리펜턴스+로 하시려면 DLC를 제대로 적용했는지 다시 확인하세요.", -44)
        return
    end

    if mod.notRestart then
        warningFontBlack:DrawStringScaledUTF8("쀏", 400, -1500, 400, 400, KColor(0, 0, 0, 1), 0, true)
        DrawWarningString(warningFont16, "게임을 재실행해야 합니다!", 55, KColor(1, 0.5, 0.5, 1))
        DrawWarningString(warningFont12, "한글패치는 최소 한 번 게임에 진입한 저장파일에서만", 18)
        DrawWarningString(warningFont12, "정상적으로 작동합니다. 양해바랍니다.", 0)
        DrawWarningString(warningFont12, "(현재 상태로는 게임 진행이 불가합니다)", -24, KColor(1, 1, 1, 0.5))
        return
    end
    
    for warning, time in pairs(mod.warningTimers) do
        local maxTime = mod.warningMaxTimes[warning] or 180
        Isaac.RenderScaledText(
            "[한글패치] " .. warning,
            12,
            Isaac.GetScreenHeight() - (12 + mod.stageAPIoffset),
            mod.warningScale, mod.warningScale,
            1, mod.warningRed, mod.warningRed,
            math.min(time / maxTime, 1) * 0.75
        )
    end

    if mod.detectStageAPI and mod.stageAPITimer > 0 then
        Isaac.RenderScaledText(
            messages.stageAPI,
            58,
            Isaac.GetScreenHeight() - 12,
            0.5, 0.5,
            1, 1, 1,
            (mod.stageAPITimer / 60) * 0.5
        )
    end
end)


------ 아빠의 쪽지 자막 by blackcreamtea ------
local subtitleSprite = Sprite()
subtitleSprite:Load("gfx/cutscenes/backwards.anm2", true)

local function RenderSub(Anm2)
    subtitleSprite:Play(Anm2)
    subtitleSprite:Update()
    subtitleSprite.Scale = Vector(1, 1)
    subtitleSprite.Color = Color(1, 1, 1, 0.6, 0, 0, 0)
    subtitleSprite:Render(Vector(Isaac.GetScreenWidth() / 2, Isaac.GetScreenHeight() * 0.9))
end

local VoiceSFX = SFXManager()
mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
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
end)


------ EzItems by ddeeddii ------
local json = require('json')
local data = include('data.items_and_trinkets')
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
                if trinket and t_queueNow[playerKey]:IsTrinket() and t_queueLastFrame[playerKey] == nil and not REPENTOGON then
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

    local gFuelDesc = include('data.gfuel')
    local birthrightDesc = include('data.birthright')

    mod:AddCallback(
        ModCallbacks.MC_POST_PLAYER_UPDATE,

        ---@param player EntityPlayer
        function(_, player)
            local playerKey = tostring(player.InitSeed)
            
            i_queueNow[playerKey] = player.QueuedItem.Item
            if i_queueNow[playerKey] and i_queueNow[playerKey]:IsCollectible() and i_queueLastFrame[playerKey] == nil then
                local itemID = i_queueNow[playerKey].ID
                if itemID == -1 and i_queueNow[playerKey].Name == "G FUEL!" then    -- G FUEL!
                    local g_random = math.random(1, 50)
                    local g_description = gFuelDesc[g_random]
                    if g_description then
                        Game():GetHUD():ShowItemText("G FUEL!", g_description or "일종의 오류발생 메시지. 한글패치 제작자에게 연락바람")
                    end
                elseif itemID == 619 then    -- 생득권이라면
                    local b_playerType = player:GetPlayerType()
                    local b_description = birthrightDesc[b_playerType]
                    if b_description then
                        Game():GetHUD():ShowItemText("생득권", b_description or "???")
                    end
                else
                    local item = changes.items[tostring(itemID)]    -- 일반 아이템이라면
                    if item and not REPENTOGON then
                        Game():GetHUD():ShowItemText(item.name, item.description)
                    end
                end
            end
            i_queueLastFrame[playerKey] = i_queueNow[playerKey]
        end
    )
end


------ 사해사본 by 双笙子佯谬 ------
local deadSeaScrollsList = {34,35,37,38,39,41,42,44,45,56,49,58,77,65,66,78,83,84,85,86,93,97,107,102,47,123,136,146,158,160,171,192}

local function getNextDeadSeaScrollsItem(rng)
    return deadSeaScrollsList[rng:RandomInt(#deadSeaScrollsList) + 1]
end

local lastPredictedID = nil    -- 마지막으로 예측된 아이템 ID 저장
local activePredictor = {
    [124] = getNextDeadSeaScrollsItem,
}

local function PredictDeadSeaScrolls(player)
    local predFunc = activePredictor[124]
    if predFunc then
        local rng = RNG()
        rng:SetSeed(player:GetCollectibleRNG(124):GetSeed(), 35)
        lastPredictedID = predFunc(rng)
    end
end

local function FakeDeadSeaScrolls()
    if lastPredictedID and lastPredictedID ~= 0 then
        local d_data = jsonData.items[tostring(lastPredictedID)]
        if d_data and not REPENTOGON and not mod.hasTM then
            Game():GetHUD():ShowItemText(d_data.name)
        elseif mod.hasTM then
            return
        elseif not REPENTOGON then
            Game():GetHUD():ShowItemText("일종의 오류발생 메시지", "한글패치 제작자에게 연락바람")
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    PredictDeadSeaScrolls(player)
end)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, item, rng, player, flags)
    if item == 124 then
        FakeDeadSeaScrolls()
        PredictDeadSeaScrolls(player)
    end
    return true
end, 124)


------ 제작 가방 ------
if EID then
    local previousBagItems = {}    -- 이전 제작 가방 아이템 목록
    local lastPlayerType = -1

    local function ShowCraftedItem(player)
        local recipeID = EID:calculateBagOfCrafting(previousBagItems)
        local BoCItems = jsonData.items[tostring(recipeID)]
        
        if not REPENTOGON then
            Game():GetHUD():ShowItemText(BoCItems.name, BoCItems.description)
        end
    end

    mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
        if player:GetPlayerType() ~= lastPlayerType then
            previousBagItems = {}
            lastPlayerType = player:GetPlayerType()
        end

        if lastPlayerType ~= 23 then return end    -- 더렵하진 카인이 아니면 종료

        local currentBagCount = #EID.BoC.BagItems
        if #previousBagItems == 8 and currentBagCount == 0 then
            ShowCraftedItem()
        end
        previousBagItems = EID.BoC.BagItems
    end)
else
    Isaac.DebugString("EID가 설치되지 않았습니다. 더럽혀진 카인이 아이템을 획득해도 그 아이템의 이름과 설명은 번역되지 않습니다.")
end


------ 레메게톤 ------
------ To modders who want to reference this code. THIS CODE IS UNSTABLE!!! DROP THAT IDEA RIGHT NOW!!!
local w_queueLastFrame = {}    -- 이전 프레임에 처리된 위습 데이터를 저장
local w_queueNow = {}          -- 현재 프레임에 처리되는 위습 데이터를 저장
local delayedWisps = {}        -- 일정 프레임 지연 후 처리할 위습을 저장
local gameStarted = false      -- 게임 시작 시 초기화용

local function WispText(familiar)
    local familiarKey = tostring(familiar.InitSeed)
    local WispID = familiar.SubType
    
    w_queueNow[familiarKey] = WispID
    if WispID > 0 and w_queueLastFrame[familiarKey] == nil then
        local wisp = changes.items[tostring(WispID)]
        if wisp and not REPENTOGON then
            Game():GetHUD():ShowItemText(wisp.name or "일종의 오류발생 메시지", wisp.description or "한글패치 제작자에게 연락바람")
        else
            if not REPENTOGON then
                print("[ Repentance+ Korean ]\n" .. tostring(WispID) .. "번 아이템이 모드 아이템이거나 플레이어가 2인 이상인 상태입니다.")
            end
        end
    end
    w_queueLastFrame[familiarKey] = w_queueNow[familiarKey]
end

function mod:ResetWispData()
    gameStarted = true
    delayedWisps = {}
end

function mod:DetectWisp(familiar)
    if ANDROMEDA and Isaac.GetPlayer(0):GetName() == "AndromedaB" and familiar.SubType == CollectibleType.COLLECTIBLE_ANALOG_STICK then
        Isaac.DebugString("[ Repentance+ Korean ]\nThis message is output for compatibility with Andromeda mod.")    -- 안드로메다의 위습 시스템을 읽지 않게 함.
        return
    end
    
    if familiar.Type == 3 and familiar.Variant == 237 and gameStarted then
        local wispData = familiar:GetData()
        if familiar.Position:Distance(Vector(-1000, -1000)) < 1 then return end    -- HiddenItemManager의 위습을 읽지 않게 함.
        table.insert(delayedWisps, familiar)
    end
end

function mod:ShowWispText()
    if #delayedWisps > 0 then
        WispText(delayedWisps[1])    -- 1프레임 지연 실행
        table.remove(delayedWisps, 1)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.ResetWispData)
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.DetectWisp)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.ShowWispText)


------ 알약 ------
------ To modders who want to reference this code. THIS CODE IS UNSTABLE!!! DROP THAT IDEA RIGHT NOW!!!
local pillNames = include('data.pill_names')
local pillDescriptions = {
    [PillEffect.PILLEFFECT_I_FOUND_PILLS] = "...먹어 버렸어",
    [PillEffect.PILLEFFECT_EXPERIMENTAL] = ""
}

local lastStats = {}    -- 알약 사용 이전 플레이어의 능력치 저장
local pendingStatComparison = {}    -- 스탯 비교가 필요한 플레이어를 표시

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

    if player:HasCollectible(304) then return end    -- 천칭자리 소지 시 번역 비활성화
    
    local e_changes = { increased = {}, decreased = {} }
    local e_currentstats = {
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
            if e_currentstats[stat] < value then
                table.insert(e_changes.increased, statNames[stat] .. " 증가")
            elseif e_currentstats[stat] > value then
                table.insert(e_changes.decreased, statNames[stat] .. " 감소")
            end
        else
            if e_currentstats[stat] > value then
                table.insert(e_changes.increased, statNames[stat] .. " 증가")
            elseif e_currentstats[stat] < value then
                table.insert(e_changes.decreased, statNames[stat] .. " 감소")
            end
        end
    end

    local e_description = ""
    if #e_changes.increased > 0 then
        e_description = table.concat(e_changes.increased, ", ")
    end
    if #e_changes.decreased > 0 then
        if e_description ~= "" then
            e_description = e_description .. ", "
        end
        e_description = e_description .. table.concat(e_changes.decreased, ", ")
    end

    Game():GetHUD():ShowItemText("실험약", e_description)
end

function mod:FakePillText(pillEffect, player)
    if pillEffect == 49 then
        pendingStatComparison[player.InitSeed] = true
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
local cardNames = include('data.card_names')
local cardDescriptions = include('data.card_descs')

local pickedUpCards = {}    -- 플레이어가 수집한 카드의 인덱스
local pickupCollected = {}    -- 해당 픽업의 인덱스를 키로 하여, 픽업이 "Collect" 애니메이션 상태일 때 이미 처리되었는지 여부를 기록
local pickupJustTouched = {}    -- 특정 엔티티가 픽업에 닿았는지

local byBagofCrafting = false    -- 제작 가방을 통해 카드를 수집했음을 나타내는 플래그로, 이 값이 참이면 카드 텍스트 표시를 방지
local bagFlagTimer = 0    -- 제작 가방으로 카드를 수집한 후 카드 텍스트가 표시되지 않도록 하는 타이머입니다.

mod.craftingBag = {}
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
    for _, pickup in ipairs(Isaac.FindByType(5, 300, -1, false, false)) do
        if pickup:GetSprite():GetAnimation() == "Collect" and not pickupCollected[pickup.Index] then
            pickupCollected[pickup.Index] = true
            if not pickupJustTouched[pickup.Index] then
                local REPKORcraftingIDs = mod:getBagOfCraftingID(pickup.Variant, pickup.SubType)
                if REPKORcraftingIDs ~= nil then
                    for _,v in ipairs(REPKORcraftingIDs) do
						if #mod.craftingBag >= 8 then table.remove(mod.craftingBag, 1) end
						table.insert(mod.craftingBag, v)
                        byBagofCrafting = true
                        bagFlagTimer = 18        -- 제작 가방으로 카드를 수집할 때 텍스트가 뜨는 걸 방지하기 위한 코드
					end                          -- Original by EID Developers
                end
            end
        end
        pickupJustTouched[pickup.Index] = nil
    end
end)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup,collider,_)
	if collider.Type == EntityType.ENTITY_PLAYER then
        pickedUpCards[pickup.Index] = true
	end
end, 300)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if byBagofCrafting then return end
    for _, pickup in ipairs(Isaac.FindByType(5, 300, -1, false, false)) do
        if pickup:IsDead() and pickedUpCards[pickup.Index] then
            local cardID = pickup.SubType
            if cardNames[cardID] and not textDisplayed and not REPENTOGON then
                Game():GetHUD():ShowItemText(cardNames[cardID], cardDescriptions[cardID])
                pickedUpCards[pickup.Index] = nil
            end
        end
    end
end)

function mod:ResetBagFlag()
    if bagFlagTimer > 0 then
        bagFlagTimer = bagFlagTimer - 1
        if bagFlagTimer == 0 then
            byBagofCrafting = false
        end
    end
end

function mod:BoCOnNewRoom(_)
    pickedUpCards = {}
    pickupJustTouched = {}
	pickupsCollected = {}
    byBagofCrafting = false
    bagFlagTimer = 0
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.ResetBagFlag)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.BoCOnNewRoom)


------ 행운의 동전 ------
local delayLuckyPenny = nil    -- 1프레임 지연 실행용

function mod:LuckyPennyPickup(pickup, collider)
    if pickup.Variant == 20 and pickup.SubType == 5 then
        if collider.Type == EntityType.ENTITY_PLAYER then
            delayLuckyPenny = true
        end
    end
end

function mod:DelayedLuckyPennyText()
    if delayLuckyPenny then
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
local friendlyEntityCounts = {}    -- 이전에 표시된 엔티티의 등장 횟수를 저장

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
include('data.fortune_apioverride')
mod.Fortunes = include('data.fortune_cookie')
mod.Rules = include('data.fortune_rule')
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
        if math.random() < 0.1 then    -- 10% 확률로 시드 표시
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
    if math.random() < 0.1 then    -- 10% 확률로 시드 표시
        ShowSpecialSeed()
    else
        mod:ShowRule()
    end
    return
end)


------ 축복 받은 느낌! ------
------ To modders who want to reference this code. THIS CODE IS UNSTABLE!!! DROP THAT IDEA RIGHT NOW!!!
local lastSacrificeAngelChance = nil    -- 이전 프레임의 천사방 확률 저장

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    if Game():GetRoom():GetType() == RoomType.ROOM_SACRIFICE then
        local currentAngelChance = Game():GetLevel():GetAngelRoomChance()

        if lastSacrificeAngelChance == nil then
            lastSacrificeAngelChance = currentAngelChance
        end

        if currentAngelChance > lastSacrificeAngelChance then
            Game():GetHUD():ShowFortuneText("축복받은 느낌!")
        end
        lastSacrificeAngelChance = currentAngelChance
    else
        lastSacrificeAngelChance = nil
    end
end)

local lastConfessionalAngelChance = nil    -- 이전 프레임의 천사방 확률 저장
local previousCurses = nil    -- 이전 프레임의 저주 상태 저장

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
                    Game():GetHUD():ShowFortuneText("축복받은 느낌!")
                elseif previousCurses ~= nil and previousCurses ~= 0 and currentCurses == 0 then
                    Game():GetHUD():ShowFortuneText("축복받은 느낌!")
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


------ 미니 보스 ------
local playerNames = include("data.player_names")
local minibossNames = {
    [EntityType.ENTITY_SLOTH] = {
        [0] = "나태",
        [1] = "초 나태",
        [2] = "왕 교만"    -- 뭐여ㅅㅂ
    },
    [EntityType.ENTITY_LUST] = {
        [0] = "성욕",
        [1] = "초 성욕"
    },
    [EntityType.ENTITY_WRATH] = {
        [0] = "분노",
        [1] = "초 분노"
    },
    [EntityType.ENTITY_GLUTTONY] = {
        [0] = "대식",
        [1] = "초 대식"
    },
    [EntityType.ENTITY_GREED] = {
        [0] = "탐욕",
        [1] = "초 탐욕"
    },
    [EntityType.ENTITY_ENVY] = {
        [0] = "질투",
        [1] = "초 질투"
    },
    [EntityType.ENTITY_PRIDE] = {
        [0] = "교만",
        [1] = "초 교만"
    },
    [EntityType.ENTITY_FALLEN] = {
        [1] = "크람푸스"
    }
}

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    local player = Isaac.GetPlayer(0)
    local pType = player:GetPlayerType()
    if pType > 40 then return end    -- 모드 캐릭터는 일단 제외

    local room = Game():GetRoom()
    local rType = room:GetType()
    if rType ~= RoomType.ROOM_MINIBOSS and rType ~= RoomType.ROOM_DEVIL then return end

    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        if ent:IsActiveEnemy() and minibossNames[ent.Type] then
            local playerName = playerNames[pType] or player:GetName()

            local nameTable = minibossNames[ent.Type]
            local vb = ent.Variant or 0
            local minibossName = nameTable[vb] or nameTable[0]

            Game():GetHUD():ShowItemText(playerName .. " VS " .. minibossName)
            break
        end
    end
end)


------ REPENTOGON ------
if REPENTOGON then
    mod:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, function()
        local conf = Isaac.GetItemConfig()

        if jsonData.items then
            for key, entry in pairs(jsonData.items) do
                local id = tonumber(key)
                if id and id ~= -1 then
                    local cfg = conf:GetCollectible(id)
                    cfg.Name = entry.name
                    cfg.Description = entry.description
                end
            end
        end

        if jsonData.trinkets then
            for key, entry in pairs(jsonData.trinkets) do
                local id = tonumber(key)
                if id and id ~= -1 then
                    local cfg = conf:GetTrinket(id)
                    cfg.Name = entry.name
                    cfg.Description = entry.description
                end
            end
        end

        if cardNames then
            for id, name in pairs(cardNames) do
                local cfg = conf:GetCard(id)
                if cfg then cfg.Name = name end
            end
        end
        if cardDescriptions then
            for id, desc in pairs(cardDescriptions) do
                local cfg = conf:GetCard(id)
                if cfg then cfg.Description = desc end
            end
        end

        if pillNames then
            for effect, name in pairs(pillNames) do
                local cfg = conf:GetPillEffect(effect)
                if cfg then cfg.Name = name end
            end
        end

        local stageNames = include("data.stages")
        for stageType, name in pairs(stageNames) do
            RoomConfig.GetStage(stageType):SetDisplayName(name)
        end
    end)
end


------ 버전 출력 ------
mod.version = 1.93
print("Repentance+ Korean " .. string.format("%.2f", mod.version) .. " loaded.")