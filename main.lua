REPKOR = RegisterMod("Repentance+ Korean", 1)
local mod = REPKOR

mod.rgon = REPENTOGON
mod.version = "2.39"
mod.supportVanilla = "v1.9.7.17"
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

mod:AddCallback(
    "EID_EVALUATE_AUTO_LANG",
    function()
        return "ko_kr"
    end
)

require("res.lua.warning")
require("res.lua.mcm")
require("res.lua.subtitles")
require("res.lua.gfuel")

print("Repentance+ Korean " .. string.format("%.2f", mod.version) .. " loaded.")

