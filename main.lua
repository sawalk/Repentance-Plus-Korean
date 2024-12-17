REPKOR = RegisterMod("Repentance+ Korean", 1)

if REPENTANCE and not REPENTANCE_PLUS then
    local alreadyShow = false
    print("\n[Repentance+ Korean]\nz_REPENTANCE+ KOREAN mod is only available with the Repentance+ DLC. PLEASE DISABLE THE MOD NOW.\n")
    alreadyShow = true
end

-- if EID then
--     if EID:getLanguage() ~= "ko_kr" then
--         if alreadyShow then
--             print("The language setting for EID is not Korean!\n")
--         else
--            print("아이템 설명모드의 언어가 한국어가 아닙니다!\nF10이나 L키로 Mod Config Menu를 열고\nEID-General-Language를 Korean으로 설정하세요.")
--         end
--     end  --- EID의 언어가 한국어가 아닐 경우 콘솔 메시지로 안내합니다.
-- end      --- 근데 en_us인데 한국어 뜨는 경우가 있어서 보류 중
--
-- local function SetEIDLanguageToKorean()
--     if EID then
--         if EID:getLanguage() ~= "ko_kr" then
--             EID.Config["Language"] = "ko_kr" --- 설치 시 EID의 언어를 자동으로 한국어로 설정합니다.
--             EID:fixDefinedFont()             --- 근데 뭐 때문인지 처음 켜면 폰트가 깨져서 보류 중
--         end
--     end
-- end

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

REPKOR.isVisible = true
REPKOR.IsHidden = false
local function onRender()
    if Input.IsButtonTriggered(39, 0) then
        REPKOR.IsHidden = not REPKOR.IsHidden -- '키로 자막 토글
    end
    if REPKOR.IsHidden then return end

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

-- REPKOR:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, SetEIDLanguageToKorean)
REPKOR:AddCallback(ModCallbacks.MC_POST_RENDER, onRender)

-- EzItems
local mod = REPKOR
local data = include('data')
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
                    game:GetHUD():ShowItemText(trinket.name, trinket.description, false, true)
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
                    game:GetHUD():ShowItemText(item.name, item.description, false, true)
                end
            end
            i_queueLastFrame = i_queueNow
        end
    )
end