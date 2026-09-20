local mod = REPKOR

------

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