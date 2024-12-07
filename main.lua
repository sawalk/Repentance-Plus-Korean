REPKOR = RegisterMod("Repentance+ Korean", 1)
print("\n[리펜턴스+ 한글패치]\ngiveitem 명령어 사용 시 아이템을 이름으로 검색하실 수 없습니다.\n명령어를 입력할 때 c1과 같은 아이템 코드로 입력하십시오.\n")

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
        REPKOR.IsHidden = not REPKOR.IsHidden
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

REPKOR:AddCallback(ModCallbacks.MC_POST_RENDER, onRender)