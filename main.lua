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

mod.version = 2.03
Isaac.DebugString("Starting Repentance+ Korean v" .. mod.version)    -- 디버깅

------ EID ------
function mod:ChangeEIDLanguage()
    return "ko_kr"    -- EID(v4.99 이상)에서 언어를 Auto로 설정했을 때 한국어가 선택되도록 변경
end
mod:AddCallback("EID_EVALUATE_AUTO_LANG", mod.ChangeEIDLanguage)

local function AddPickupWarning(descObj)
    --[[ 리펜+ 1.9.7.13 이후로 해결됨
    local targetPickup = descObj.ObjType == 5 and (
            (descObj.ObjVariant == 100 and descObj.ObjSubType == 667) or                                 -- 밀짚인형
            (descObj.ObjVariant == 300 and (descObj.ObjSubType == 95 or descObj.ObjSubType == 97)) or    -- 포가튼/야곱과 에사우의 영혼
            (descObj.ObjVariant == 350 and descObj.ObjSubType == 180)                                    -- 되찾은 영혼
        )
    if targetPickup and not REPENTOGON then
        EID:appendToDescription(descObj,
            "#{{Warning}} {{ColorError}}한글패치 관련:" ..
            "#{{Blank}} {{ColorError}}획득(사용) 이후 플레이어가 픽업을 얻을 때 텍스트가 이중으로 표시됩니다."
        )
    end]]

    local targetPickup2 = descObj.ObjType == 5 and descObj.ObjVariant == 100 and descObj.ObjSubType == 505    -- 포켓 GO
    if targetPickup2 then
        EID:appendToDescription(descObj,
            "#{{Warning}} {{ColorError}}한글패치 관련:" ..
            "#{{Blank}} {{ColorError}}아군 등장 텍스트가 잘못 표시될 수 있습니다."
        )
    end

    --[[ 더 좋은 방법이 있을 때까지 유기
    local targetWarning = descObj.ObjType == -999 and descObj.ObjVariant == -1 and descObj.ObjSubType ==  1
    if not REPENTOGON and EID:PlayersHaveCollectible(710) and EID:DetectModdedItems() and targetWarning then
        EID:appendToDescription(descObj,
            "#{{Warning}} {{ColorError}}한글패치 관련:" ..
            "#{{Blank}} {{ColorError}}아이템 번역 또한 조합된 아이템과 일치하지 않을 수 있습니다."
        )
    end]]

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
end)


------ 경고 메시지 ------
local HUD = Game():GetHUD()

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

    stageAPI = REPENTOGON and "(일부 스테이지의 이름이 번역되지 않습니다.)"
                           or "(스테이지 이름이 번역되지 않습니다. REPENTOGON+ 적용 시 일부 해결됩니다.)"
}

local warningDurations = {
    [messages.notKillingMom] = 180,
    [messages.notRunningEID] = 180,
    [messages.notEIDKorean] = 180,
 -- [messages.survey] = 360,
    [messages.hasTM] = 180
}

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    if not mod:HasData() then
        mod.notRestart = true
    end

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
    for i = 0, Game():GetNumPlayers() - 1 do
        if Isaac.GetPlayer(i):HasCollectible(CollectibleType.COLLECTIBLE_TMTRAINER) and not mod.tmWarningShown then
            mod.hasTM = true
            mod.tmWarningShown = true
            ----
            local duration = warningDurations[messages.hasTM]
            mod.warningTimers[messages.hasTM] = duration
            mod.warningMaxTimes[messages.hasTM] = duration
        else
            mod.hasTM = false
        end
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
    if HUD:IsVisible() then
        HUD:SetVisible(false)
    end

    for i = 0, Game():GetNumPlayers() - 1 do
        if (Isaac.GetPlayer(i).ControlsEnabled) then
			Isaac.GetPlayer(i).ControlsEnabled = false
		end
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
        DrawWarningString(warningFont12, "(이 상태로는 게임 진행이 불가능합니다)", 22, KColor(1, 1, 1, 0.5))
        DrawWarningString(warningFont12, "리펜턴스+ DLC를 적용 해제한 건 아닌지,", -4, KColor(1, 1, 1, 1))
        DrawWarningString(warningFont12, "리펜턴스+ DLC를 적용했는데 Steam 다운로드 대기열에", -24)
        DrawWarningString(warningFont12, "밀려있는 건 아닌지, 다시 한 번 확인해 주세요!", -44)
        return
    end

    if mod.notRestart then
        warningFontBlack:DrawStringScaledUTF8("쀏", 400, -1500, 400, 400, KColor(0, 0, 0, 1), 0, true)
        DrawWarningString(warningFont16, "한글패치 적용이 90% 완료됐어요!", 55, KColor(0.5, 1, 0.5, 1))
        DrawWarningString(warningFont12, "마지막으로 한 번만 게임을 완전히 껐다 켜면", 18)
        DrawWarningString(warningFont12, "100% 적용됩니다! 양해 부탁드려요!", 0)
        DrawWarningString(warningFont12, "(한글패치는 설치/업데이트 시 저장파일별로 셋업이 필요합니다)", -24, KColor(1, 1, 1, 0.5))
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


------ 아빠의 쪽지 자막 ------
local json = require('json')

mod.config = {
    subtitles = true,
    subOffset = 45,
    subOpacity = 2/3,
}

if ModConfigMenu then
    ModConfigMenu.AddSetting("Rep+ Korean", "자막", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        Attribute = "Toggle subtitles",
        CurrentSetting = function()
            return mod.config.subtitles
        end,
        Display = function()
            if mod.config.subtitles then
                return "Ascent 자막: 켜기"
            else
                return "Ascent 자막: 끄기"
            end
        end,
        OnChange = function(newOption)
            mod.config.subtitles = newOption;
        end,
        Info = "'아빠의 쪽지' 아이템을 획득 후 나오는 Ascent 시퀀스의 자막을 표시할지 설정합니다."
    });
    ModConfigMenu.AddSetting("Rep+ Korean", "자막", {
        Type = ModConfigMenu.OptionType.NUMBER,
        Attribute = "Subtitles Y offset",
        Minimum = -10,
        Maximum = 1000,
        ModifyBy = 5,
        CurrentSetting = function()
            return mod.config.subOffset
        end,
        Display = function() return
            "자막 오프셋: " .. mod.config.subOffset
        end,
        OnChange = function(newOption)
            mod.config.subOffset = newOption;
        end,
        Info = "자막이 화면 하단으로부터 얼마나 떨어져 있는지 조정합니다. (기본값: 45)"
    });
    ModConfigMenu.AddSetting("Rep+ Korean", "자막", {
        Type = ModConfigMenu.OptionType.NUMBER,
        Attribute = "Subtitles opacity",
        Minimum = 0,
        Maximum = 1,
        ModifyBy = 0.01,
        CurrentSetting = function()
            return mod.config.subOpacity
        end,
        Display = function() return
            "자막 불투명도: " .. string.format("%.0f", mod.config.subOpacity * 100) .. "%"
        end,
        OnChange = function(newOption)
            mod.config.subOpacity = newOption;
        end,
        Info = "자막의 불투명도를 설정합니다. (기본값: 67%)"
    });
end

mod:AddPriorityCallback(
    ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.IMPORTANT,
    ---@param isContinued boolean
    function(_, isContinued)
        if not mod:HasData() then return end

        local jsonString = mod:LoadData()
        local loadedConfig = json.decode(jsonString)
        if type(loadedConfig) ~= "table" then return end

        mod.config.subOffset = loadedConfig.subOffset or 45
        mod.config.subOpacity = loadedConfig.subOpacity or 2/3
        if loadedConfig.subtitles == nil then
            mod.config.subtitles = true
        else
            mod.config.subtitles = loadedConfig.subtitles
        end
    end
)

mod:AddPriorityCallback(
    ModCallbacks.MC_PRE_GAME_EXIT, CallbackPriority.LATE,
    function(shouldSave)
        local jsonString = json.encode(mod.config)
        mod:SaveData(jsonString)
    end
)

local subtitleFont = Font()
subtitleFont:Load(mod.modPath .. "resources/font/pftempestasevencondensed.fnt", true)

mod.Subtitles = include('data.dadsnote_sub')
mod.subStart = {}         -- 실제 시작 시각(초)
mod.playingSounds = {}    -- 이전 프레임에서의 상태

local function RenderSub(scene)
    local startTime = mod.subStart[scene]
    if not startTime then return end

    local now = Isaac.GetTime() / 1000
    local elapsed = now - startTime
    if elapsed < 0 then return end

    local subs = mod.Subtitles[scene]
    if not subs then return end

    for _, entry in ipairs(subs) do
        if elapsed >= entry.start and elapsed < (entry.start + entry.dur) then
            local text = entry.text

            local x = Isaac.GetScreenWidth() / 2 - subtitleFont:GetStringWidthUTF8(text) / 2
            local y = Isaac.GetScreenHeight() - mod.config.subOffset

            subtitleFont:DrawStringUTF8(text, x, y, KColor(1, 1, 1, mod.config.subOpacity), 0, true)
            break
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if not mod.config.subtitles then return end

    local VoiceSFX = SFXManager()
    for i = 598, 601 do
        local scene = i - 597
        local soundId = i
        if KoreanVoiceDubbing then
            soundId = Isaac.GetSoundIdByName("DADS_NOTE_KOREAN_" .. scene)
        end

        local nowPlaying = VoiceSFX:IsPlaying(soundId)

        if nowPlaying and not mod.playingSounds[scene] then
            mod.playingSounds[scene] = true
            mod.subStart[scene] = Isaac.GetTime() / 1000
        end

        if not nowPlaying and mod.playingSounds[scene] then
            mod.playingSounds[scene] = nil
        end

        if nowPlaying then
            RenderSub(scene)
        end
    end
end)


------ EzItems by ddeeddii ------
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
                    HUD:ShowItemText(trinket.name, trinket.description)
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
    local birthrightDesc = include('data.player_birthright')

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
                        HUD:ShowItemText("G FUEL!", g_description or "일종의 오류발생 메시지. 한글패치 제작자에게 연락바람")
                    end
                elseif itemID == 619 then    -- 생득권이라면
                    local b_playerType = player:GetPlayerType()
                    local b_description = birthrightDesc[b_playerType]
                    if b_description then
                        HUD:ShowItemText("생득권", b_description or "???")
                    end
                else
                    local item = changes.items[tostring(itemID)]    -- 일반 아이템이라면
                    if item and not REPENTOGON then
                        HUD:ShowItemText(item.name, item.description)
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
            HUD:ShowItemText(d_data.name)
        elseif mod.hasTM then
            return
        elseif not REPENTOGON then
            HUD:ShowItemText("일종의 오류발생 메시지", "한글패치 제작자에게 연락바람")
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
            HUD:ShowItemText(BoCItems.name, BoCItems.description)
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
            HUD:ShowItemText(wisp.name or "일종의 오류발생 메시지", wisp.description or "한글패치 제작자에게 연락바람")
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
    if ANDROMEDA then
        for i = 0, Game():GetNumPlayers() - 1 do
            if Isaac.GetPlayer(i):GetName() == "AndromedaB" and familiar.SubType == CollectibleType.COLLECTIBLE_ANALOG_STICK then
                Isaac.DebugString("[ Repentance+ Korean ]\nThis message is output for compatibility with Andromeda mod.")    -- 안드로메다의 위습 시스템을 읽지 않게 함.
                return
            end
        end
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

    HUD:ShowItemText("실험약", e_description)
end

function mod:FakePillText(pillEffect, player, flag)
    if flag >= 2048 then    -- 이꼬챔버
        return
    end

    if pillEffect == 49 then
        pendingStatComparison[player.InitSeed] = true
    elseif pillNames[pillEffect] then
        HUD:ShowItemText(pillNames[pillEffect], pillDescriptions[pillEffect])
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

local pickedUpCards = {}        -- InitSeed 기준으로 플레이어가 닿은 후보 표시
local pickupJustTouched = {}    -- 인덱스 기반으로 닿은 픽업 기록
local pickupCollected = {}      -- 인덱스 기반으로 Collect 처리 기록
local consumedByBoC = {}        -- 제작 가방으로 처리됐는지
local showQueue = {}            -- 텍스트 표시를 다음 프레임으로 미루기 위한 큐

mod.craftingBag = {}
mod.pickupIDLookup = {}
mod.runeIDs = {}

local function pid(pickup)
    return pickup.InitSeed
end

function mod:getBagOfCraftingID(Variant, SubType)   -- 제작 가방 판별
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


mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider, _)
    local id = pid(pickup)

    if collider.Type == EntityType.ENTITY_PLAYER
    or collider.Type == EntityType.ENTITY_FAMILIAR
    or collider.Type == EntityType.ENTITY_BUMBINO
    or collider.Type == EntityType.ENTITY_ULTRA_GREED then
        pickupJustTouched[pickup.Index] = true    -- 인덱스 기반으로 pickupJustTouched에 닿은 기록을 남김
    end

    if collider.Type == EntityType.ENTITY_PLAYER then
        pickedUpCards[id] = true    -- 플레이어가 닿으면 InitSeed 기준으로 pickedUpCards에 후보 표시
    end
end, 300)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    for _, pickup in ipairs(Isaac.FindByType(5, 300, -1, false, false)) do
        if not pickup then return end

        local idx = pickup.Index
        local id = pid(pickup)

        if pickup:GetSprite():GetAnimation() == "Collect" and not pickupCollected[idx] then    -- Collect에 진입했고 아직 처리하지 않았으면 처리
            pickupCollected[idx] = true

            if not pickupJustTouched[idx] then    -- 인덱스 기준으로 '닿지 않은 상태'라면 제작 가방 판정
                local REPKORcraftingIDs = mod:getBagOfCraftingID(pickup.Variant, pickup.SubType)

                if REPKORcraftingIDs ~= nil then
                    for _, v in ipairs(REPKORcraftingIDs) do
                        if #mod.craftingBag >= 8 then table.remove(mod.craftingBag, 1) end
                        table.insert(mod.craftingBag, v)
                    end
                    
                    consumedByBoC[id] = true    -- InitSeed 기준으로 제작 가방 판정 기록
                end
            end
        end

        pickupJustTouched[idx] = nil    -- 다음 프레임을 위해 인덱스 기반으로 닿은 기록 초기화
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    for _, pickup in ipairs(Isaac.FindByType(5, 300, -1, false, false)) do    -- 현재 프레임에 뒤져버린 픽업들 중 플레이어가 닿아서 후보로 표시된 것들을 showQueue에 넣음
        if not pickup then return end
        local id = pid(pickup)

        if pickup:IsDead() and pickedUpCards[id] then
            table.insert(showQueue, {id = id, pickupRef = pickup})
            pickedUpCards[id] = nil    -- 큐로 보냈으니 후뵤 표시는 제거
        end
    end

    if #showQueue > 0 then
        for _, entry in ipairs(showQueue) do
            local id = entry.id
            local pickupRef = entry.pickupRef

            if consumedByBoC[id] then    -- 만약 Collect 처리에서 가방으로 흡수되었다면 --
                consumedByBoC[id] = nil                                                 --
            else                                                                        --
                if pickupRef and not pickupRef:Exists() then                            --
                    -- 스킵띠 <-----------------------------------------------------------
                else
                    local cardID = pickupRef and pickupRef.SubType
                    if cardID and cardNames[cardID] and not REPENTOGON then
                        HUD:ShowItemText(cardNames[cardID], cardDescriptions[cardID])
                    end
                end
            end
        end

        showQueue = {}    -- 큐 비우기
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()    -- 새 방 진입 시 전체 초기화
    pickedUpCards = {}
    pickupJustTouched = {}
    pickupCollected = {}
    consumedByBoC = {}
    showQueue = {}
end)


------ 포켓 슬롯 번역 by Goganidze ------
mod.pocketItemStr = {}
mod.checkedPills = {}

local function BuildPocketItemString()
    mod.pocketItemStr = {}
    local ic = Isaac.GetItemConfig()
    local numPlayers = Game():GetNumPlayers()

    for i = 0, numPlayers - 1 do
        local player = Isaac.GetPlayer(i)
        if not player or not player:Exists() or not player:ToPlayer() then
            goto skip
        end

        local TrslName = nil
        local card = player:GetCard(0)
        local pill = player:GetPill(0)

        if card ~= 0 and cardNames[card] then
            if cardNames[card] ~= ic:GetCard(card).Name then    -- 카드의 원본 이름이 교체되었을 때만 작동
                TrslName = cardNames[card]

                if Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) and cardDescriptions[card] then    -- 탭 키 누르면 이름 대신 설명 표시
                    TrslName = cardDescriptions[card]
                end
            end

        elseif pill ~= 0 and pill ~= 14 then
            local pID = Game():GetItemPool():GetPillEffect(pill)
            local check = mod.checkedPills[pID] or player:HasCollectible(75, false) or player:HasCollectible(654, false)

            if check and pillNames[pID] then
                if pillNames[pID] ~= ic:GetPillEffect(pID).Name then    -- 알약의 원본 이름이 교체되었을 때만 작동
                    TrslName = pillNames[pID]

                    if Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) and pillDescriptions[pID] then
                        if pillDescriptions[pID] ~= "" then
                            TrslName = pillDescriptions[pID]
                        end
                    end
                end
            end
        else
            local pocketItem = player:GetActiveItem(ActiveSlot.SLOT_POCKET)
            if pocketItem and pocketItem ~= 0 then
                local item = changes.items[tostring(pocketItem)]
                if item and item.name and
                   item.name ~= ic:GetCollectible(pocketItem).Name then    -- 액티브의 원본 이름이 교체되었을 때만 작동
                    TrslName = item.name
                    if Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) and item.description then
                        TrslName = item.description
                    end
                    IsActiveItem = true
                end
            end
        end

        local id = #mod.pocketItemStr + 1
        mod.pocketItemStr[id] = {
            Name = TrslName or "",
            IsActiveItem = IsActiveItem,
            PType = player:GetPlayerType(),
            CtrlIdx = player.ControllerIndex
        }

        ::skip::
    end
end

mod:AddCallback(ModCallbacks.MC_USE_PILL, function(_, pillEffect, player, flag)
    if player:GetPill(0) ~= 14 then
        mod.checkedPills[pillEffect] = true
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, cont)
    if not cont then
        mod.pocketItemStr = {}
        mod.checkedPills = {}
    end 
end)

local poeketFont = Font()
poeketFont:Load(mod.modPath .. "resources/font/luaminioutlined.fnt")

local function RenderPocketItemName()
    if not HUD:IsVisible() then return end
    if Game():GetNumPlayers() > 1 then return end    -- 멀티 유기

    local shakeOffset = Game().ScreenShakeOffset
    local fontSize, sizeOffset = 1, -2

    for i, k in pairs(mod.pocketItemStr) do
        if not k or not k.Name or k.Name == "" then
            goto skip
        end

        local id = i - 1
        local str = k.Name
        local alpha = 0.5
        local pType = k.PType
        local activeOffset = 0
        if k.IsActiveItem then
            activeOffset = -3
        end

        if (pType == PlayerType.PLAYER_JACOB or pType == PlayerType.PLAYER_ESAU) then
            goto skip    -- 병머 유기
        end

        if id == 0 then
            local Corner = Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight())
            local Offset = -Vector(Options.HUDOffset * 16 + 30, Options.HUDOffset * 6 + 22)
            local Pos = Corner + Offset + shakeOffset
            poeketFont:DrawStringScaledUTF8(str, Pos.X + 1 + activeOffset, Pos.Y + 13 + sizeOffset, fontSize, fontSize, KColor(1, 1, 1, alpha), 1, false)
        end

        ::skip::
    end
end

local renderCollback = ModCallbacks.MC_POST_RENDER
if Renderer then    -- RGON
    renderCollback = ModCallbacks.MC_HUD_RENDER
end

mod:AddCallback(renderCollback, function()
    BuildPocketItemString()
    RenderPocketItemName()
end)


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
        HUD:ShowItemText("행운의 동전", "행운 증가")
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
    [234] = { [0] = "이빨 빠진 박쥐" },
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
                        HUD:ShowFortuneText(entityName .. "가 튀어나왔다!")
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
    HUD:ShowFortuneText(seed)
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
    HUD:ShowFortuneText(
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
mod.YOU_FEEL_BLESSED = "축복받은 느낌!"

local lastSacrificeAngelChance = nil    -- 이전 프레임의 천사방 확률 저장
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    if Game():GetRoom():GetType() == RoomType.ROOM_SACRIFICE then
        local currentAngelChance = Game():GetLevel():GetAngelRoomChance()

        if lastSacrificeAngelChance == nil then
            lastSacrificeAngelChance = currentAngelChance
        end

        if currentAngelChance > lastSacrificeAngelChance then
            HUD:ShowFortuneText(mod.YOU_FEEL_BLESSED)
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
                    HUD:ShowFortuneText(mod.YOU_FEEL_BLESSED)
                elseif previousCurses ~= nil and previousCurses ~= 0 and currentCurses == 0 then
                    HUD:ShowFortuneText(mod.YOU_FEEL_BLESSED)
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
local minibossNames = include("data.miniboss_names")

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    local player = Isaac.GetPlayer(0)    -- 0번 컨트롤러의 화면에서 표시되어야 하므로
    local pType = player:GetPlayerType()
    if pType > 40 then return end    -- 모드 캐릭터는 일단 제외

    local room = Game():GetRoom()
    local rType = room:GetType()
    if rType ~= RoomType.ROOM_SHOP and
       rType ~= RoomType.ROOM_DEVIL and
       rType ~= RoomType.ROOM_MINIBOSS and
       rType ~= RoomType.ROOM_SECRET
    then return end

    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        if ent:IsActiveEnemy() and minibossNames[ent.Type] then
            local playerName = playerNames[pType] or player:GetName()

            local nameTable = minibossNames[ent.Type]
            local vb = ent.Variant or 0
            local minibossName = nameTable[vb] or nameTable[0]

            HUD:ShowItemText(playerName .. " VS " .. minibossName)
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
print("Repentance+ Korean " .. string.format("%.2f", mod.version) .. " loaded.")