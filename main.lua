REPKOR = RegisterMod("Repentance+ Korean", 1)
local mod = REPKOR

mod.rgon = REPENTOGON
mod.version = "2.36"
mod.supportVanilla = mod.rgon and "v1.9.7.12" or "v1.9.7.17"
Isaac.DebugString(string.format("[REPKOR] Starting v%s...", mod.version))

mod.isRepentancePlus = REPENTANCE_PLUS or FontRenderSettings ~= nil
mod.runningRep = REPENTANCE and not REPENTANCE_PLUS
mod.isTruePatch = mod.isRepentancePlus and Options.Language == "kr"

if mod.isTruePatch then
    Isaac.DebugString("[REPKOR] patch successful.")
elseif mod.runningRep then
    Isaac.DebugString("[REPKOR] running on repentance.")
else
    Isaac.DebugString("[REPKOR] not patched.")
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
mod:AddCallback(
    "EID_EVALUATE_AUTO_LANG",
    function()
        return "ko_kr"
    end
)


------ 경고 메시지 ------
local HUD = Game():GetHUD()

local warningFontBlack = Font()
warningFontBlack:Load("font/cjk/lanapixel.fnt")

local warningBoldFont = Font()
warningBoldFont:Load(mod.modPath .. "resources/font/pftempestasevencondensed.fnt")

local warningFont10 = Font()
warningFont10:Load(mod.modPath .. "resources/font/warning/kr_font10.fnt")

local warningFont12 = Font()
warningFont12:Load(mod.modPath .. "resources/font/warning/kr_font12.fnt")

local warningQRFont = Font()
warningQRFont:Load(mod.modPath .. "resources/font/warning/forqrcode.fnt")

local installGuideQR = {
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "abbbbbbbaaaabaaabaabababbbbbbba",
    "abaaaaababbabbbaaaaabaabaaaaaba",
    "ababbbabababaabaababaaababbbaba",
    "ababbbabaaabbaaaabbabaababbbaba",
    "ababbbababaaabbbabbbbaababbbaba",
    "abaaaaabaabbaababaabababaaaaaba",
    "abbbbbbbababababababababbbbbbba",
    "aaaaaaaaabbabababbbbbaaaaaaaaaa",
    "abbbbbabbabbabaaaaabbbbbababbaa",
    "abaaabaaaaaaabbababbbabbaababaa",
    "abaababbaabbbbabbaabbababbabaaa",
    "aabbbbbaaaaababaaaabbababaabbba",
    "aabbabbbabbaababbababaaababbaaa",
    "ababaaaaaaaaabaaabaaaabaababbba",
    "aabbbbbbabaabbababaaabaabbaaaaa",
    "aabbabbaabbabbbbaababaaaabbbaba",
    "aaaabaabbbabaaabbaaaabbabbbbbba",
    "abbaabbabbabbbbabbabbbaababbbba",
    "abaaababbaaaaaabbaabbabaabababa",
    "abbbbbbabbaaabaaabaababbaaababa",
    "aaabbaabaababbbabbbbbbbbbbbabba",
    "aaaaaaaaaaaababbbbababaaabbaaba",
    "abbbbbbbabbabbbbabbabbababaaaba",
    "abaaaaabaaaabbbbbaabbbaaababbaa",
    "ababbbabababbaaaaaaaabbbbbbbaba",
    "ababbbababbaaaaaabbbabaaabaaaaa",
    "ababbbabababaaabaaabaaabaaabaaa",
    "abaaaaabababbaabbabbbbabaaaabba",
    "abbbbbbbabbbaabbbbbbbabbbaababa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
}

local repWarningQR = {
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "abbbbbbbaaabbbbbbaabababbbbbbba",
    "abaaaaababbbbababaaaaaabaaaaaba",
    "ababbbabaabbbaabaabbaaababbbaba",
    "ababbbababbbabaababaaaababbbaba",
    "ababbbabaaabbbabbabbabababbbaba",
    "abaaaaababaabaaaaabbbbabaaaaaba",
    "abbbbbbbababababababababbbbbbba",
    "aaaaaaaaabaaabbbbbbaabaaaaaaaaa",
    "ababbabbbbbbabaaabaaaabbbababaa",
    "aabaabbabbbbbabaabaaababaabaaba",
    "abbbbbbbabaaababaabaaaaaaababaa",
    "aaabbbbabaaaabbabbabaabbbbbabaa",
    "aabbababaaabaabaababbbbbbabaaba",
    "aaabaababbbbbaabbabaababaabbaaa",
    "ababbbabbaaabbbaaaabababaababaa",
    "aaaaabbabbababaaaabbabaaaababaa",
    "aaabaabbaaabaaabbabbabbaaabaaba",
    "abababbaabababbbbaabbaabbaaabba",
    "aabbbbbbaaabbabbbbbbabaaaaaabaa",
    "aaaababaabbaabbababaaabaaabbbaa",
    "abbaababaabbaabaaabaabbbbbbbaaa",
    "aaaaaaaaabbbaabaaaababaaabaaaaa",
    "abbbbbbbababbbabaaaaabababbabba",
    "abaaaaababaababbbaabbbaaababbaa",
    "ababbbabaababaaabbaaabbbbbbbaba",
    "ababbbababbbaabaaaaabbababbbaaa",
    "ababbbabababbaaaaaabababbaaaaaa",
    "abaaaaabaaabbaabbabbabababaabba",
    "abbbbbbbabbaaaabaabbbbbaabbbaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
}

local function DrawQRCodeString(qrCodeAB, offset, scale)
    local x = Isaac.GetScreenWidth() / 2 - warningQRFont:GetStringWidthUTF8("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa") * (scale / 2)
    local y = Isaac.GetScreenHeight() / 2 - offset

    for yOffset, line in pairs(qrCodeAB) do
        warningQRFont:DrawStringScaled(line, x, y + yOffset * scale, scale, scale, KColor(1, 1, 1, 1))
    end
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

    MusicManager():Pause()

    local x = Isaac.GetScreenWidth() / 2 - font:GetStringWidthUTF8(text) / 2
    local y = Isaac.GetScreenHeight() / 2 - offset
    font:DrawStringUTF8(text, x, y, color or KColor(1, 1, 1, 1), 0, true)
end

function mod:showRepWarning(shaderName)
    if not mod.runningRep then return end

    if mod.rgon then
	    local isShader = shaderName == "UI_DrawKrPatchSubtitle_DummyShader"
        if shaderName ~= nil and not isShader then return end
    end

    warningFontBlack:DrawStringScaledUTF8("쀏", 400, -1500, 400, 400, KColor(0, 0, 0, 1), 0, true)
    DrawQRCodeString(repWarningQR, 81, 3)
    DrawWarningString(warningBoldFont, "http://ohy.kr/repplus", -18, KColor(0.25, 0.75, 1, 1))
    DrawWarningString(warningFont12, "리펜턴스+ DLC를 설치해 주세요!", -45)
    DrawWarningString(warningFont10, "(지금은 리펜턴스에서 실행되고 있어요)", -65, KColor(1, 1, 1, 0.5))
end

function mod:showInstallGuide(shaderName)
    if mod.isRepentancePlus and mod.isTruePatch then return end
    if mod.runningRep then return end

    if mod.rgon then
	    local isShader = shaderName == "UI_DrawKrPatchSubtitle_DummyShader"
        if shaderName ~= nil and not isShader then return end
    end

    warningFontBlack:DrawStringScaledUTF8("쀏", 400, -1500, 400, 400, KColor(0, 0, 0, 1), 0, true)
    DrawQRCodeString(installGuideQR, 97, 3)
    DrawWarningString(warningBoldFont, "https://ohy.kr/krpatchtutorial", -2, KColor(0.25, 0.75, 1, 1))
    DrawWarningString(warningFont12, "한글패치가 처음이신 분, 업데이트 후 패치가 풀리신 분들은", -29)
    DrawWarningString(warningFont12, "위의 영상 가이드를 확인해 주세요!", -45)
    DrawWarningString(warningFont10, "(설치된 패치가 지원하는 게임 버전: " .. mod.supportVanilla .. ")", -65, KColor(1, 1, 1, 0.5))
    DrawWarningString(warningFont10, "(Linux 사용자라면 한글패치 창작마당을 확인해 주세요)", -79, KColor(1, 1, 1, 0.5))
end

if mod.rgon then
    mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, mod.showRepWarning)
    mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, mod.showInstallGuide)
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.showRepWarning)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.showInstallGuide)


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
    ModConfigMenu.RemoveCategory("Rep+ Korean")

    local data_str = Isaac.LoadModData(mod)
    if data_str and data_str ~= "" then
        local success, decoded = pcall(json.decode, data_str)
        if success and type(decoded) == "table" then
            mod.config = decoded
        else
            Isaac.DebugString("[REPKOR] Json decode failed: " .. (decoded or "unknown error") .. " | Configs are set by default.")
            Isaac.SaveModData(mod, json.encode(mod.config))
        end
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
            save()
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

local function renderSub(scene)
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

function mod:onSubtitleRender(shaderName)
    if not mod.config then return end
    if not mod.config.subtitles then return end

    if mod.rgon then
	    local isShader = shaderName == "UI_DrawKrPatchSubtitle_DummyShader"
        
        if not (Game():IsPaused() and Isaac.GetPlayer(0).ControlsEnabled) and not isShader then return end -- no render when unpaused
        if (Game():IsPaused() and Isaac.GetPlayer(0).ControlsEnabled) and isShader then return end -- no shader when paused
        if shaderName ~= nil and not isShader then return end -- final failsafe
    end

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
            renderSub(scene)
        end
    end
end

if mod.rgon then mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, mod.onSubtitleRender) end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.onSubtitleRender)


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

