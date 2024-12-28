REPKOR = RegisterMod("Repentance+ Korean", 1)
local mod = REPKOR

-- 리펜턴스 경고
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


-- 아빠의 쪽지 자막 by blackcreamtea
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


-- EzItems by ddeeddii
local data = include('data') -- support by raiiiny
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
    for type, itemTypeData in pairs(changes) do                                   -- EID에서 이름을 data.lua에서의 이름으로 덮어씌우게 변경합니다.
        for id, itemData in pairs(itemTypeData) do                                -- 굳이?여서 주석 처리
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
                    local i_playerType = player:GetPlayerType()
                    local i_description = birthrightDesc[i_playerType]
                    if i_description then
                        Game():GetHUD():ShowItemText("생득권", i_description or "???")
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


-- 알약/카드
local pillNames = include("data_pillNames")
local pillDescriptions = {
    [PillEffect.PILLEFFECT_I_FOUND_PILLS] = "...먹어 버렸어"
}

function mod:FakePillText(pillEffect)
    if pillNames[pillEffect] then
        Game():GetHUD():ShowItemText(pillNames[pillEffect], pillDescriptions[pillEffect])
    end
end

mod:AddCallback(ModCallbacks.MC_USE_PILL, mod.FakePillText)

local cardNames = include("data_cardNames")
local cardDescriptions = include("data_cardDescriptions")

local textDisplayed = false
local resetTimer = 0

function mod:FakeCardText(pickup)
    if pickup.Variant == PickupVariant.PICKUP_TAROTCARD and pickup:IsDead() then
        local cardID = pickup.SubType
        if cardNames[cardID] and not textDisplayed then
            Game():GetHUD():ShowItemText(cardNames[cardID], cardDescriptions[cardID])
            textDisplayed = true
            resetTimer = 18    -- 변경 금지
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


-- 행운의 동전
local delayLuckyPenny = nil

function mod:LuckyPennyPickup(pickup, collider)
    if pickup.Variant == PickupVariant.PICKUP_COIN and pickup.SubType == CoinSubType.COIN_LUCKYPENNY then
        if collider.Type == EntityType.ENTITY_PLAYER then
            delayLuckyPenny = true
        end
    end
end

function mod:DelayedLuckyPennyText()   -- 1프레임 뒤에 실행
    if delayLuckyPenny then
        Game():GetHUD():ShowItemText("행운의 동전", "행운 증가")
        delayLuckyPenny = nil   -- 초기화
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.LuckyPennyPickup, PickupVariant.PICKUP_COIN)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.DelayedLuckyPennyText)