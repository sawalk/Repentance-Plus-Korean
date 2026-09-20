local mod = REPKOR

------

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

local rgonNoticeTimer = 750

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

local rgonNoticeQR = {
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "abbbbbbbaabaababbaabababbbbbbba",
    "abaaaaababaaabbaaabaaaabaaaaaba",
    "ababbbabaaabaaabbbbbbbababbbaba",
    "ababbbababbabaababaabbababbbaba",
    "ababbbabaabbabbaabbabbababbbaba",
    "abaaaaababbaaaabbabaaaabaaaaaba",
    "abbbbbbbababababababababbbbbbba",
    "aaaaaaaaabbabbbabaaabbaaaaaaaaa",
    "ababbabbbbbabababaaaaabbbababaa",
    "ababaaaaabaaabaabbbaaababbababa",
    "abbbaabbbaabbbaaaabbaabbbbabbaa",
    "aababbaaabaaaaaabbbbabaaabaaaba",
    "aabbbbabbbaaaaabbabbabbbaabbaaa",
    "aabababababaaabbbbbababbbbabbaa",
    "aabbababbbbabbabbaaabaaabbbaaaa",
    "aababbbabbaaaaaaabbbabaaaababaa",
    "abbaaabbbbbababbbabbabbaaabaaba",
    "abababbaabababbbbaabbaabbaaabba",
    "aabbbbbbaaabbabbbbbbabaaaaaabaa",
    "aaaababaabbaabbababaabbaaabbbaa",
    "abbaababaabbaabaabbbabbbbbbbbba",
    "aaaaaaaaababaabbbbbbabaaabaabba",
    "abbbbbbbabbbbbabaabaabababbaaba",
    "abaaaaabababaabbbababbaaababbaa",
    "ababbbabaaabaaaabaababbbbbbbaba",
    "ababbbabababaabaaabbbbababaaaaa",
    "ababbbababbabaaaaaaaababbaabaaa",
    "abaaaaabaaabbabbabbbaabbabaabba",
    "abbbbbbbabbaaaabbbbbbababbbbaaa",
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

---@param qrCodeAB table
---@param offset number
---@param scale number
local function DrawQRCodeString(qrCodeAB, offset, scale)
    local x = Isaac.GetScreenWidth() / 2 - warningQRFont:GetStringWidthUTF8(installGuideQR[1]) * (scale / 2)
    local y = Isaac.GetScreenHeight() / 2 - offset

    for yOffset, line in pairs(qrCodeAB) do
        warningQRFont:DrawStringScaled(line, x, y + yOffset * scale, scale, scale, KColor(1, 1, 1, 1))
    end
end

---@param font Font
---@param text string
---@param offset number
---@param color KColor
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

---@param shaderName string
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

---@param shaderName string
function mod:showInstallGuide(shaderName)
    if mod.isRepentancePlus and mod.isTruePatch then return end
    if mod.runningRep then return end

    if mod.rgon then
	    local isShader = shaderName == "UI_DrawKrPatchSubtitle_DummyShader"
        if shaderName ~= nil and not isShader then return end

        warningFontBlack:DrawStringScaledUTF8("쀏", 400, -1500, 400, 400, KColor(0, 0, 0, 1), 0, true)
        DrawQRCodeString(rgonNoticeQR, 91, 3)
        DrawWarningString(warningBoldFont, "https://ohy.kr/rgonkrpatch", -8, KColor(0.25, 0.75, 1, 1))
        DrawWarningString(warningFont12, "위 글을 참고하여 REPENTOGON 런처에서 언어를", -34)
        DrawWarningString(warningFont12, "한국어로 바꾼 후 재실행해 주세요.", -49)
    else
        warningFontBlack:DrawStringScaledUTF8("쀏", 400, -1500, 400, 400, KColor(0, 0, 0, 1), 0, true)
        DrawQRCodeString(installGuideQR, 97, 3)
        DrawWarningString(warningBoldFont, "https://ohy.kr/krpatchtutorial", -2, KColor(0.25, 0.75, 1, 1))
        DrawWarningString(warningFont12, "한글패치가 처음이신 분, 업데이트 후 패치가 풀리신 분들은", -29)
        DrawWarningString(warningFont12, "위의 영상 가이드를 확인해 주세요!", -45)
        DrawWarningString(warningFont10, "(설치된 패치가 지원하는 게임 버전: " .. mod.supportVanilla .. ")", -65, KColor(1, 1, 1, 0.5))
        DrawWarningString(warningFont10, "(Linux 사용자라면 한글패치 창작마당을 확인해 주세요)", -79, KColor(1, 1, 1, 0.5))
    end
end

function mod:showRgonNotice()
    if not mod.isTruePatch then return end
    if not mod.rgon then return end

    if rgonNoticeTimer > 0 then
        warningFontBlack:DrawStringScaledUTF8("리펜턴스+ 한글패치는 REPENTOGON+(v1.1.2~)와 완벽히 호환되지 않습니다.", 72, 150, 0.5, 0.5, KColor(1, 1, 1, 1), 0, true)
        warningFontBlack:DrawStringScaledUTF8("자세한 사항은 한글패치 창작마당 페이지를 참고하십시오.", 72, 158, 0.5, 0.5, KColor(1, 1, 1, 1), 0, true)
        rgonNoticeTimer = rgonNoticeTimer - 1
    end
end

if mod.rgon then
    mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, mod.showRepWarning)
    mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, mod.showInstallGuide)
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.showRepWarning)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.showInstallGuide)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.showRgonNotice)