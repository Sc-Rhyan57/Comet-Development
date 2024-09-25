--[[

I had previously had a floor is lava script, however that one was... wayyy to complicated.
This one is clean code, actual clean code. Suprising?!?! Im proud of my self.
Anyways, feel free to learn from the bogus i've made here.

-- Chrono @ Comet Development

--]]

local HookHelper = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChronoAcceleration/Comet-Development/refs/heads/main/Doors/Utility/DoorsScriptUtility.lua"))()
local RoomHook = HookHelper.RoomHook:New()
local QuickFunctions = HookHelper.QuickFunctions

-- Configuration

local BURN_CONFIGURATION = {
    ["InitialSoundCooldown"] = 5,
    ["BurnDamage"] = 15,
    ["DamagePerSecond"] = 2.5
}

-- Variables

-- [Lava]

local LavaRiseOffset = 0.1
local LavaRising = false

-- [Other]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local SoundService = game:GetService("SoundService")
SoundService.VolumetricAudio = Enum.VolumetricAudio.Enabled -- i actually dont know if this works lol

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer.PlayerGui
local MainUI = PlayerGui:WaitForChild("MainUI")
local Initiator = MainUI:WaitForChild("Initiator")
local Main_Game = Initiator:WaitForChild("Main_Game")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local DoneInitialSound = {}
local OnBurnCooldown = false

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

local function hookLavaFunction(Lava: MeshPart): ()
    RunService.RenderStepped:Connect(
        function(Delta): ()
            if LavaRising then
                Lava.Position = Lava.Position + Vector3.new(0, LavaRiseOffset * Delta, 0)
            end

            local LavaY = Lava.Position.Y
            local CharacterY = Character:GetPivot().Position.Y

            if LavaY >= CharacterY then
                burnPlayer(LocalPlayer)
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

RoomHook:Wait("ServerRoomChanged")
if _G.DEBUG_LAVA then
    notify("Game-mode started!")
end

-- Main

local Room0 = QuickFunctions:GetRoom(0)
local Room0Position = Room0:GetPivot().Position
local LavaSpawnLocation = Room0Position - Vector3.new(0, 40, 0)
local Lava0Point = LavaSpawnLocation.Y

Lava.Position = LavaSpawnLocation
Lava.Parent = workspace

createAmbient(Lava)
hookLavaFunction(Lava)
task.spawn(hookAnimateLava, Lava)
CameraModule:ShakeOnce(5, 5, 3, 5, 10, 10)

RoomHook:On(
    "ServerRoomChanged",
    function(Room: Model): ()
        local RoomPosition = Room:GetPivot().Position
        local RoomX = RoomPosition.X
        local RoomZ = RoomPosition.Z
        local LavaY = Lava.Position.Y
        Lava.Position = Vector3.new(RoomX, LavaY, RoomZ)

        local RoomNumber = tostring(Room.Name)
        if string.find(RoomNumber, "0") then
            moveLavaDown(Lava, Lava0Point)
            CameraModule:ShakeOnce(5, 5, 3, 5, 10, 10)

            if _G.DEBUG_LAVA then
                notify("Lava has returned down!")
            end
        end
    end
)
