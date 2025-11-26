REPKOR = RegisterMod("Repentance+ Korean", 1)
local mod = REPKOR

mod.version = 2.16
Isaac.DebugString("Starting Repentance+ Korean v" .. mod.version)    -- 디버깅

mod.isRepentancePlus = REPENTANCE_PLUS or FontRenderSettings ~= nil
mod.runningRep = REPENTANCE and not REPENTANCE_PLUS
mod.isTruePatch = Options.Language == "kr"
mod.rgon = REPENTOGON

if mod.isRepentancePlus and mod.isTruePatch then
    Isaac.DebugString("Yay! The game language is already set to Korean!")
elseif not mod.isRepentancePlus then
    Isaac.DebugString("Nuh Uh! It did not run with Repentance+!")
    return
end

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


------ EID ------
function mod:ChangeEIDLanguage()
    return "ko_kr"
end
mod:AddCallback("EID_EVALUATE_AUTO_LANG", mod.ChangeEIDLanguage)


------ REPENTOGON+ ------
local function Localized(category, KEY)
    return Isaac.GetLocalizedString(category, KEY, 11)
end

if mod.rgon then
    mod:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, function()
        local conf = Isaac.GetItemConfig()

        for id = 1, (CollectibleType.NUM_COLLECTIBLES - 1) do
            local ok, cfg = pcall(function() return conf:GetCollectible(id) end)
            if ok and cfg and cfg.Name and cfg.Description then
                cfg.Name = Localized("Items", cfg.Name)
                cfg.Description = Localized("Items", cfg.Description)
            end
        end

        for id = 1, (TrinketType.NUM_TRINKETS - 1) do
            local ok, cfg = pcall(function() return conf:GetTrinket(id) end)
            if ok and cfg and cfg.Name and cfg.Description then
                cfg.Name = Localized("Items", cfg.Name)
                cfg.Description = Localized("Items", cfg.Description)
            end
        end
        
        for id = 1, (Card.NUM_CARDS - 1) do
            local ok, cfg = pcall(function() return conf:GetCard(id) end)
            if ok and cfg and cfg.Name and cfg.Description then
                cfg.Name = Localized("PocketItems", cfg.Name)
                cfg.Description = Localized("PocketItems", cfg.Description)
            end
        end

        for id = 0, (PillEffect.NUM_PILL_EFFECTS - 1) do
            local ok, cfg = pcall(function() return conf:GetPillEffect(id) end)
            if ok and cfg and cfg.Name then
                cfg.Name = Localized("PocketItems", cfg.Name)
            end
        end
    end)
end


------ 경고 메시지 ------
local HUD = Game():GetHUD()

local warningFontBlack = Font()
warningFontBlack:Load("font/cjk/lanapixel.fnt")

local warningFont12 = Font()
warningFont12:Load(mod.modPath .. "resources/font/teammeatex/teammeatex12.fnt")

local warningFont16 = Font()
warningFont16:Load(mod.modPath .. "resources/font/teammeatex/teammeatex16.fnt")

local installDocs = "'일반 설치 방법'"
if mod.rgon then
    installDocs = "'RGON에 설치'"
end

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
    if mod.rgon and Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_DATAMINER).Name == "데이터마이너" then return end
    if mod.isRepentancePlus and mod.isTruePatch then return end

    warningFontBlack:DrawStringScaledUTF8("쀏", 400, -1500, 400, 400, KColor(0, 0, 0, 1), 0, true)
    DrawWarningString(warningFont16, "리펜턴스+ 한글패치가 설치되지 않았습니다.", 55, KColor(1, 0.5, 0.5, 1))
    DrawWarningString(warningFont12, "https://ohy.kr/korean에서 " .. installDocs .. " 부분의", 18)
    DrawWarningString(warningFont12, "안내를 따라 한글패치를 적용해 주십시오.", 0)
    DrawWarningString(warningFont12, "(Windows 환경이 아닌 경우 Q&A 부분을 참조하십시오)", -24, KColor(1, 1, 1, 0.5))
end)

------ 스크롤 공지 ------
--[[
local MOVE_DURATION = 1600    -- 메시지 이동 시간

local warningFontScroll = Font()
warningFontScroll:Load(mod.modPath .. "resources/font/old_kr/kr_font12.fnt")

mod.messageFrame = nil
mod.startX = nil
mod.already = false

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if not mod.rgon then return end
    if Isaac.GetString("Items", "DATAMINER_NAME") == "데이터마이너" then return end

    if Game():GetRoom():IsClear() and mod.messageFrame ~= nil and mod.messageFrame <= MOVE_DURATION then
        local t = mod.messageFrame
        local x = mod.startX - (Isaac.GetScreenWidth() + 1250) * (t / MOVE_DURATION)
        local y = Isaac.GetScreenHeight() * 0.1
        local color = KColor(1, 1, 1, 1)

        warningFontBlack:DrawStringScaledUTF8("쀏", 400, Isaac.GetScreenHeight() * 0.1 - 5, 400, 1.4, KColor(0, 0, 0, 2/3), 0, true)
        warningFontScroll:DrawStringUTF8(
            "리펜턴스+ 한글패치는 REPENTOGON+와 호환되지 않습니다." ..
            "강제로 REPENTOGON+에 한글패치를 적용할 경우 게임이 손상될 수 있습니다. " ..
            "자세한 내용은 한글패치 창작마당 페이지(https://ohy.kr/korean)를 참고하십시오.",
            x + 50,
            y,
            color,
            0
        )

        if not Game():IsPaused() then
            mod.messageFrame = mod.messageFrame + 1
        end
        mod.already = true
    else
        if not mod.already then
            mod.messageFrame = 0
            mod.startX = Isaac.GetScreenWidth()
        end
    end
end)]]


------ MCM + 아빠의 쪽지 자막 ------
local json = require('json')
local MCMLoaded, MCM = pcall(require, "scripts.modconfig")

mod.config = {
    dubbing = true,
    subtitles = true,
    subOffset = 45,
    subOpacity = 2/3,
}

if MCMLoaded and MCM then
    local data_str = Isaac.LoadModData(mod)
    if data_str and data_str ~= "" then
        mod.config = json.decode(data_str)
    end

    local function save()
        mod.config.hint = "koca" .. (mod.config.dubbing    and "1" or "0") .. 
                          "kocb" .. (mod.config.subtitles  and "1" or "0") ..
                          "kocc" .. (mod.config.subOffset  and "1" or "0") ..
                          "kocd" .. (mod.config.subOpacity and "1" or "0")
        Isaac.SaveModData(mod, json.encode(mod.config))
    end

    MCM.AddText("Rep+ Korean", "CC", " ");
    MCM.AddSetting("Rep+ Korean", "CC", {
        Type = MCM.OptionType.BOOLEAN,
        Attribute = "Toggle subtitles",
        CurrentSetting = function()
            return mod.config.subtitles
        end,
        Display = function()
            return "승천 시퀀스 자막: " .. (mod.config.subtitles and "켜기" or "끄기")
        end,
        OnChange = function(newOption)
            mod.config.subtitles = newOption;
        end,
        Info = "'아빠의 쪽지' 아이템을 획득 후 나오는 승천 시퀀스의 자막을 표시할지 설정합니다."
    });
    MCM.AddSetting("Rep+ Korean", "CC", {
        Type = MCM.OptionType.NUMBER,
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
            mod.config.subOffset = newOption
            save()
        end,
        Info = "자막이 화면 하단으로부터 얼마나 떨어져 있는지 조정합니다. (기본값: 45)"
    });
    MCM.AddSetting("Rep+ Korean", "CC", {
        Type = MCM.OptionType.NUMBER,
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
            mod.config.subOpacity = newOption
            save()
        end,
        Info = "자막의 불투명도를 설정합니다. (기본값: 67%)"
    });
    MCM.AddText("Rep+ Korean", "Dub", " ");
    MCM.AddText("Rep+ Korean", "Dub", "게임을 재시작해야 설정이 적용됩니다.");
    MCM.AddText("Rep+ Korean", "Dub", " ");
    MCM.AddSetting("Rep+ Korean", "Dub", {
        Type = MCM.OptionType.BOOLEAN,
        Attribute = "Toggle dubbing",
        CurrentSetting = function()
            return mod.config.dubbing
        end,
        Display = function()
            return "한국어 더빙: " .. (mod.config.dubbing and "켜기" or "끄기")
        end,
        OnChange = function(newOption)
            mod.config.dubbing = newOption
            save()
        end,
        Info = "한국어 더빙을 켜고 끕니다."
    });
end

local subtitleFont = Font()
subtitleFont:Load( mod.modPath .. "resources/font/pftempestasevencondensed.fnt", true)

mod.Subtitles = include('res.dadsnote_sub')
mod.subStart = {}         -- 실제 시작 시각(초)
mod.playingSounds = {}    -- 이전 프레임에서의 상태

function mod:RenderSub(scene)
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
    if not mod.isTruePatch then return end

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
            mod:RenderSub(scene)
        end
    end
end)


------ G FUEL! ------
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
                    HUD:ShowItemText("G FUEL!", g_description or "한글패치 제작자에게 연락주세요")
                end
            end
        end
        i_queueLastFrame[playerKey] = i_queueNow[playerKey]
    end
)


------ 버전 출력 ------
print("Repentance+ Korean " .. string.format("%.2f", mod.version) .. " loaded.")

