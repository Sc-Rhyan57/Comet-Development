if _G.ExecutedSnailScript then
    return
end

local Snail = game:GetObjects("rbxassetid://127523073930604")[1]

local HookHelper = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChronoAcceleration/Comet-Development/refs/heads/main/Doors/Utility/DoorsScriptUtility.lua"))()
local QuickFunctions = HookHelper.QuickFunctions

local startingRoom = QuickFunctions:GetRoom(0)
local currentRoom = QuickFunctions:GetLatestRoom()

local RoomHook = HookHelper.RoomHook:New()

local Player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Character = Player.Character

if not startingRoom or currentRoom ~= 0 then
    return QuickFunctions:CoreNotification({
        Title = "Error",
        Text = "You need to be in room 0!"
    })
end

local function runGuidingLight(Text: table, Type: string): ()
    local RemotesFolder = ReplicatedStorage.RemotesFolder
    local DeathHint = RemotesFolder.DeathHint

    firesignal(DeathHint.OnClientEvent, Text, Type)
end

local function changeDeathCause(Cause: string, Player: Player): ()
    local Humanoid = Character.Humanoid

    local GameStats = ReplicatedStorage.GameStats
    local PlayerStats = GameStats[string.format("Player_%s", Player.Name)]
    local Total = PlayerStats.Total
    local DeathCause = Total.DeathCause

    DeathCause.Value = Cause
    Humanoid:TakeDamage(100)
end

RoomHook:Wait("ServerRoomChanged")
print("INITIATED")

Snail.Parent = workspace
Snail:PivotTo(startingRoom.RoomEntrance.CFrame * CFrame.new(0, -3, 0))

local SNAIL_BASE_SPEED = 2
local SNAIL_CATCH_DISTANCE = 5
local SNAIL_VISIBILITY_CHECK_INTERVAL = 1
local lastVisibilityCheck = tick()

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local function updateSnailSize(time)
    local newSize = Vector3.new(4 + math.sin(time) / 2, Snail.SnailBody.Size.Y, Snail.SnailBody.Size.Z)
    Snail.SnailBody.Size = newSize
    Snail.SnailBody.CFrame *= CFrame.new(math.sin(time) / 200, 0, 0)
end

local function moveSnailTowardsPlayer(deltaTime)
    local characterPosition = Character.PrimaryPart.Position
    local currentPosition = Snail:GetPivot().Position
    local targetPosition = Vector3.new(characterPosition.X, currentPosition.Y, characterPosition.Z)
    local direction = (targetPosition - currentPosition).Unit

    local speed = SNAIL_BASE_SPEED + (currentPosition - targetPosition).Magnitude / 100
    local newPosition = currentPosition + direction * speed * deltaTime
    local newCFrame = CFrame.new(newPosition, newPosition + direction) * CFrame.Angles(0, math.rad(-90), 0)
    
    Snail:PivotTo(newCFrame)
    return newPosition, targetPosition
end

local function checkPlayerCollision(snailPosition, playerPosition)
    if (snailPosition - playerPosition).Magnitude < SNAIL_CATCH_DISTANCE then
        local humanoid = Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
            runGuidingLight(
                {
                    "...",
                    ".....",
                    "I don't even know what to say.",
                    "You died to a snail.",
                    "What."
                },
                "Blue"
            )
            changeDeathCause("Snail", Player)
            humanoid:TakeDamage(100)
            if not game.CoreGui:FindFirstChild("FUNNY JUMPSCARE LOL") then
                loadstring(game:HttpGet("https://raw.githubusercontent.com/ChronoAcceleration/Comet-Development/refs/heads/main/Doors/Assets/Snail/Jumpscare.lua"))()
            end
        end
    end
end

local function updateSnailVisibility()
    if tick() - lastVisibilityCheck >= SNAIL_VISIBILITY_CHECK_INTERVAL then
        lastVisibilityCheck = tick()
        local touchingParts = Snail.SnailShell:GetTouchingParts()
        local targetTransparency = #touchingParts > 1 and 1 or 0
        
        for _, part in ipairs(Snail:GetDescendants()) do
            if part:IsA("BasePart") then
                TweenService:Create(part, TweenInfo.new(2), {Transparency = targetTransparency}):Play()
            end
        end
    end
end

_G.ExecutedSnailScript = true

RunService.RenderStepped:Connect(function(deltaTime)
    local time = tick()
    updateSnailSize(time)
    local snailPosition, playerPosition = moveSnailTowardsPlayer(deltaTime)
    checkPlayerCollision(snailPosition, playerPosition)
    updateSnailVisibility()
end)
