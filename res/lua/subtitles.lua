local mod = REPKOR

------

local subtitleFont = Font()
subtitleFont:Load( mod.modPath .. "resources/font/pftempestasevencondensed.fnt", true)

mod.Subtitles = include('res.lua._dadsnote_sub')
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