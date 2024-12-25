REPKOR = RegisterMod("Repentance+ Korean", 1)
local mod = REPKOR

-- 리펜턴스 경고
local showMessage = false

local function checkRepentance()
    if REPENTANCE and not REPENTANCE_PLUS then
     -- local alreadyShow = false
        print("\n[Repentance+ Korean]\nz_REPENTANCE+ KOREAN mod is only available with the Repentance+ DLC.\nPLEASE DISABLE THE MOD NOW.\n")
     -- alreadyShow = true
        showMessage = true
    end
end

local font = Font()
font:Load("font/cjk/lanapixel.fnt")

local function NonRepentancePlus()
    local renderMessageWidth = 1
    local renderMessageY = 240
    local renderMessageY2 = 250

    if Options.MaxScale == 3 and Options.Fullscreen == true then
        renderMessageWidth = 0.66666 * 2
        renderMessageY = 242
        renderMessageY2 = 254
    end

    if showMessage then
        font:DrawStringScaledUTF8("리펜턴스+ 한글패치가 리펜턴스에서 실행되었습니다.",10,230,renderMessageWidth,renderMessageWidth,KColor(1,0,0,1),0,true)
        font:DrawStringScaledUTF8("z_REPENTANCE+ KOREAN를 적용 해제 후 게임을 재시작하거나",10,renderMessageY,renderMessageWidth,renderMessageWidth,KColor(1,0,0,1),0,true)
        font:DrawStringScaledUTF8("리펜턴스+ DLC로 실행하십시오.",10,renderMessageY2,renderMessageWidth,renderMessageWidth,KColor(1,0,0,1),0,true)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, checkRepentance)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, NonRepentancePlus)

--[[ if EID then
    if EID:getLanguage() ~= "ko_kr" then
        if alreadyShow then
            print("The language setting for EID is not Korean!\n")
        else
           print("아이템 설명모드의 언어가 한국어가 아닙니다!\nF10이나 L키로 Mod Config Menu를 열고\nEID-General-Language를 Korean으로 설정하세요.")
        end
    end                                                  --- EID의 언어가 한국어가 아닐 경우 콘솔 메시지로 안내합니다.
end                                                      --- 근데 en_us인데 한국어 뜨는 경우가 있어서 보류 중

local function SetEIDLanguageToKorean()
    if EID then
        if EID:getLanguage() ~= "ko_kr" then
            EID.Config["Language"] = "ko_kr"             --- 설치 시 EID의 언어를 자동으로 한국어로 설정합니다.
            EID:fixDefinedFont()                         --- 근데 처음 켜면 폰트가 깨지는 버그를 못 고치겠어서 보류 중
        end
    end
end --]]


-- 아빠의 쪽지 자막
local game = Game()
local SubSprite = Sprite()
local VoiceSFX = SFXManager()
SubSprite:Load("gfx/cutscenes/backwards.anm2", true)

local function GetScreenSize()
    local pos = Game():GetRoom():WorldToScreenPosition(Vector(0,0)) - Game():GetRoom():GetRenderScrollOffset() - Game().ScreenShakeOffset
  
    local rx = pos.X + 60 * 26 / 40
    local ry = pos.Y + 162.5 * (26 / 40)
  
    return Vector(rx*2 + 13*26, ry*2 + 7*26)
end

function RenderSub(Anm2)
    SubSprite:Play(Anm2)
    SubSprite:Update()
    SubSprite.Scale = Vector(1, 1)
    SubSprite.Color = Color(1, 1, 1, 0.6, 0, 0, 0)
    SubSprite:Render(Vector(GetScreenSize().X/2, GetScreenSize().Y*0.85), Vector(0,0), Vector(0,0))
end

mod.isVisible = true
mod.IsHidden = false
local function onRender()
    if Input.IsButtonTriggered(39, 0) then
        mod.IsHidden = not mod.IsHidden -- '키로 자막 토글
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

-- mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, SetEIDLanguageToKorean)
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

local function updateEid ()
    for type, itemTypeData in pairs(changes) do
        for id, itemData in pairs(itemTypeData) do
            EID:addDescriptionModifier(
            'EZITEMS | ' .. tostring(mod.Name) .. ' | ' .. itemData.name,
            function (descObj) return descObj.ObjType == 5 and descObj.ObjVariant == itemVariants[type] and descObj.ObjSubType == tonumber(id) end,
            function (descObj) descObj.Name = itemData.name; return descObj end
            )
        end
    end
end
  
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

if EID then
    updateEid()
end
  
if next(changes.trinkets) ~= nil then
    local t_queueLastFrame
    local t_queueNow
    mod:AddCallback(
        ModCallbacks.MC_POST_PLAYER_UPDATE,
  
        ---@param player EntityPlayer
        function(_, player)
            t_queueNow = player.QueuedItem.Item
            if (t_queueNow ~= nil) then
            local trinket = changes.trinkets[tostring(t_queueNow.ID)]
                if trinket and t_queueNow:IsTrinket() and t_queueLastFrame == nil then
                    game:GetHUD():ShowItemText(trinket.name, trinket.description)
                end
            end
            t_queueLastFrame = t_queueNow
        end
    )
end
  
if next(changes.items) ~= nil then
    local i_queueLastFrame
    local i_queueNow
    mod:AddCallback(
        ModCallbacks.MC_POST_PLAYER_UPDATE,
  
        ---@param player EntityPlayer
        function(_, player)
            i_queueNow = player.QueuedItem.Item
            if (i_queueNow ~= nil) then
                local item = changes.items[tostring(i_queueNow.ID)]
                if item and i_queueNow:IsCollectible() and i_queueLastFrame == nil then
                    game:GetHUD():ShowItemText(item.name, item.description)
                end
            end
            i_queueLastFrame = i_queueNow
        end
    )
end


-- 행운의 동전
local delayLuckyPenny = nil

function mod:LuckyPennyPickup(pickup, collider)
    if pickup.Variant == PickupVariant.PICKUP_COIN and pickup.SubType == CoinSubType.COIN_LUCKYPENNY then
        if collider.Type == EntityType.ENTITY_PLAYER then
            delayLuckyPenny = true
        end
    end
end

function mod:DelayedLuckyPennyText()
    if delayLuckyPenny then
        game:GetHUD():ShowItemText("행운의 동전", "행운 증가")
        delayLuckyPenny = nil   -- 초기화
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.LuckyPennyPickup, PickupVariant.PICKUP_COIN)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.DelayedLuckyPennyText)

-- 알약/카드
local pillNames = include("data_pillNames")
local pillDescriptions = {
    [PillEffect.PILLEFFECT_I_FOUND_PILLS] = "...먹어 버렸어"
}

function mod:FakePillText(pillEffect)
    if pillNames[pillEffect] then
        game:GetHUD():ShowItemText(pillNames[pillEffect], pillDescriptions[pillEffect])
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
            game:GetHUD():ShowItemText(cardNames[cardID], cardDescriptions[cardID])
            textDisplayed = true
            resetTimer = 18 -- 변경 금지
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