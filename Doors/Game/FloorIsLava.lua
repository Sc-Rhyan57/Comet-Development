--[[

I had previously had a floor is lava script, however that one was... wayyy to complicated.
This one is clean code, actual clean code. Suprising?!?! Im proud of my self.
Anyways, feel free to learn from the bogus i've made here.

-- Chrono @ Comet Development
-- Modified by Claude to make lava go down every 5 doors

--]]

local Executor = identifyexecutor() or "Unknown"
if Executor == "Solara 3.0" or "Unknown" then
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/ChronoAcceleration/Comet-Development/refs/heads/main/Doors/Game/Solara/FloorIsLava.lua"))()
end

local HookHelper = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChronoAcceleration/Comet-Development/refs/heads/main/Doors/Utility/DoorsScriptUtility.lua"))()
local RoomHook = HookHelper.RoomHook:New()
local QuickFunctions = HookHelper.QuickFunctions

-- Configuration

local BURN_CONFIGURATION = {
    ["InitialSoundCooldown"] = 5,
    ["BurnDamage"] = 5,
    ["DamagePerSecond"] = 1.5,
    ["LockedRoomGracePeriod"] = 10
}

-- Variables

-- [Lava]

local LavaRiseOffset = 0.0045
local LavaRising = false

-- [Other]

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
-- SoundService.VolumetricAudio = Enum.VolumetricAudio.Enabled // i actually dont know if this works lol (it doesnt)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local MainUI = PlayerGui:WaitForChild("MainUI")
local Initiator = MainUI:WaitForChild("Initiator")
local Main_Game = Initiator:WaitForChild("Main_Game")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local DoneInitialSound = {}
local OnBurnCooldown = false
local CurrentlyModifyingLighting = false

-- New variable for door counter
local DoorCounter = 0

-- Functions

local function createMainSound(ID: number): Sound
    local StringID = tostring(ID)
    local Sound = Instance.new("Sound", SoundService)
    Sound.SoundId = "rbxassetid://" .. StringID
    Sound.Name = "tmp_" .. StringID
    return Sound
end

local function burnPlayer(Player: Player): ()
    local PlayerCharacter = Player.Character
    assert(PlayerCharacter, "How do i burn them bruh")
    local PlayerCharacterRoot = PlayerCharacter.PrimaryPart

    if not DoneInitialSound[Player.UserId] then
        local BurnSound = createMainSound(7978512659)
        BurnSound.PlaybackSpeed = 1.2
        BurnSound.Volume = 0.5
        BurnSound.Parent = PlayerCharacterRoot
        BurnSound:Play()
        
        DoneInitialSound[Player.UserId] = true
        task.delay(
            BURN_CONFIGURATION.InitialSoundCooldown,
            function(): ()
                DoneInitialSound[Player.UserId] = false
            end
        )
        BurnSound.Ended:Once(
            function(): ()
                BurnSound:Destroy()
            end
        )
    end

    if OnBurnCooldown then
        return
    end

    if Player == LocalPlayer then
        Humanoid:TakeDamage(BURN_CONFIGURATION.BurnDamage)
        OnBurnCooldown = true

        task.delay(
            BURN_CONFIGURATION.DamagePerSecond,
            function(): ()
                OnBurnCooldown = false
            end
        )
    end
end

local function createAmbient(Lava: MeshPart): ()
    local AmbientMain = createMainSound(9112823563)
    local AmbientSecondary = createMainSound(9112823197)

    AmbientMain.Volume = 0
    AmbientMain.PlaybackSpeed = 0.25
    AmbientMain.Looped = true
    AmbientMain:Play()

    AmbientSecondary.Parent = Lava
    AmbientSecondary.Volume = 0
    AmbientSecondary.PlaybackSpeed = 0.6
    AmbientSecondary.Looped = true
    AmbientSecondary:Play()

    TweenService:Create(AmbientMain, TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Volume = 0.3}):Play()
    TweenService:Create(AmbientSecondary, TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Volume = 0.5}):Play()
end

local function createColorCorrection(): ()
    local Correction = Instance.new("ColorCorrectionEffect", Lighting)
    Correction.TintColor = Color3.fromRGB(255, 123, 57)
    Correction.Enabled = false
    Correction.Brightness = .1
    Correction.Name = "LavaCorrection"
end

local function hookAnimateLava(Lava: MeshPart): () -- Propietary
    local folder = Instance.new('Folder')
    folder.Name = 'LavaValues'
    local numval1 = Instance.new('IntValue')
    numval1.Name = 'waitx'
    local numval2 = Instance.new('IntValue')
    numval2.Name = 'waity'
    local numval3 = Instance.new('IntValue')
    numval3.Name = 'offsetx'
    local numval4 = Instance.new('IntValue')
    numval4.Name = 'offsety'
        
    numval1.Parent = folder
    numval2.Parent = folder
    numval3.Parent = folder
    numval4.Parent = folder
    folder.Parent = ReplicatedStorage

    while true do
        local waitx
        local waity
        local offsetx
        local offsety
        local waittime = 0
        
        ReplicatedStorage.LavaValues.waitx.Value =  math.random(10,30)
        ReplicatedStorage.LavaValues.waity.Value =  math.random(10,30)
        ReplicatedStorage.LavaValues.offsetx.Value =  math.random(-80,80)/10
        ReplicatedStorage.LavaValues.offsety.Value =  math.random(-80,80)/10
        
        waitx = ReplicatedStorage.LavaValues.waitx.Value
        waity = ReplicatedStorage.LavaValues.waity.Value
        offsetx = ReplicatedStorage.LavaValues.offsetx.Value
        offsety = ReplicatedStorage.LavaValues.offsety.Value
        
        if waitx > waity then
            waittime = waitx
        else
            waittime = waity
        end
        
        TweenService:Create(Lava.Texture, TweenInfo.new(waitx, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {OffsetStudsU = offsetx}):Play()
        TweenService:Create(Lava.Texture, TweenInfo.new(waity, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {OffsetStudsV = offsety}):Play()
        
        task.wait(waittime-.1)
    end
end

local function modifyLighting(Submerged: boolean, Correction: ColorCorrectionEffect): ()
    if CurrentlyModifyingLighting then
        return
    end

    if Submerged then
        CurrentlyModifyingLighting = true
        Correction.Enabled = true

        local LightingTween = TweenService:Create(
            Lighting,
            TweenInfo.new(.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {
                FogEnd = 75,
                FogStart = 10,
                FogColor = Color3.fromRGB(203, 91, 26)
            }
        )

        LightingTween:Play()
        LightingTween.Completed:Wait()
        CurrentlyModifyingLighting = false
    else
        CurrentlyModifyingLighting = true
        Correction.Enabled = false

        local LightingTween = TweenService:Create(
            Lighting,
            TweenInfo.new(.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {
                FogEnd = 250,
                FogStart = 150,
                FogColor = Color3.fromRGB(14, 13, 18)
            }
        )

        LightingTween:Play()
        LightingTween.Completed:Wait()
        CurrentlyModifyingLighting = false
    end
end

local function hookLavaFunction(Lava: MeshPart): ()
    RunService.Heartbeat:Connect(
        function(): ()
            if LavaRising then
                Lava.Position = Lava.Position + Vector3.new(0, LavaRiseOffset, 0)
            end

            local LavaY = Lava.Position.Y
            local CharacterY = Character:GetPivot().Position.Y

            if LavaY >= CharacterY then
                burnPlayer(LocalPlayer)
                modifyLighting(true, Lighting.LavaCorrection)
            else
                modifyLighting(false, Lighting.LavaCorrection)
            end
        end
    )
end

local function moveLavaDown(Lava: MeshPart, YPosition: number): ()
    LavaRising = false
    local ResetMovement = TweenService:Create(
        Lava, 
        TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
        {
            Position = Vector3.new(Lava.Position.X, YPosition, Lava.Position.Z)
        }
    )

    ResetMovement:Play()
    ResetMovement.Completed:Wait()
    LavaRising = true
end

local function notify(Text: string): ()
    local Data = {
        Title = "Lava",
        Text = Text,
        Duration = 5
    }

    QuickFunctions:CoreNotification(Data)
end

-- Preload

local Lava = game:GetObjects("rbxassetid://133244054852579")[1]
local CameraModule = require(Main_Game).camShaker

--[[
Minidocs for chrono's peanut brain:
:ShakeOnce(magnitude, roughness, fadein, fadeout, posinfluence, rotinfluence)
--]]

-- Await Door

if _G.DEBUG_LAVA then
    notify("Script initialized!")
end

RoomHook:Wait("ServerRoomChanged")

if _G.DEBUG_LAVA then
    notify("Game-mode started!")
end

-- Main

local Room0 = QuickFunctions:GetRoom(0)
local Room0Position = Room0:GetPivot().Position
local LavaSpawnLocation = Room0Position - Vector3.new(0, 20, 0)
local Lava0Point = LavaSpawnLocation.Y

Lava.Position = LavaSpawnLocation
Lava.SurfaceLight.Range = 10
Lava.SurfaceLight.Brightness = .85
Lava.Parent = workspace

createAmbient(Lava)
hookLavaFunction(Lava)
task.spawn(hookAnimateLava, Lava)
createColorCorrection()

CameraModule:ShakeOnce(5, 5, 3, 5, 10, 10)
LavaRising = true

RoomHook:On(
    "ServerRoomChanged",
    function(Room: Model): ()
        local RoomPosition = Room:GetPivot().Position
        local RoomX = RoomPosition.X
        local RoomZ = RoomPosition.Z
        local LavaY = Lava.Position.Y
        Lava.Position = Vector3.new(RoomX, LavaY, RoomZ)

        local RoomNumber = tostring(Room.Name)
        if not string.find(RoomNumber, "0") then
            DoorCounter = DoorCounter + 1
            
            if DoorCounter % 5 == 0 then
                moveLavaDown(Lava, Lava0Point)
                CameraModule:ShakeOnce(5, 5, 3, 5, 10, 10)

                if _G.DEBUG_LAVA then
                    notify("Lava has returned down after 5 doors!")
                end
            end
        else
            DoorCounter = 0
            moveLavaDown(Lava, Lava0Point)
            CameraModule:ShakeOnce(5, 5, 3, 5, 10, 10)

            if _G.DEBUG_LAVA then
                notify("Lava has returned down at checkpoint!")
            end
        end
    end
)

RoomHook:On(
    "LockedRoom",
    function()
        if _G.DEBUG_LAVA then
            notify("Locked room detected, grace period active!")
        end

        LavaRiseOffset = 0.001

        task.delay(
            BURN_CONFIGURATION.LockedRoomGracePeriod,
            function(): ()
                if _G.DEBUG_LAVA then
                    notify("Grace period has ended!")
                end

                LavaRiseOffset = 0.0045
            end
        )
    end
)
