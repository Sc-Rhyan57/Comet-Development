--[[

hi
plz enjoy
ty

chrono from comet developemt
(ps join my server)

--]]

local UiMngr = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChronoAcceleration/Comet-Development/refs/heads/main/Doors/Utility/PlayerUiBars.lua"))()
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Gui = UiMngr.init()
Gui.Parent = PlayerGui

local Connections = {}

local function hideOriginalHealthUI(): ()
    local MainUI = PlayerGui:WaitForChild("MainUI")
    local MainFrame = MainUI:WaitForChild("MainFrame")
    local Healthbar = MainFrame:WaitForChild("Healthbar")

    Healthbar.Visible = false
    Healthbar.Position = UDim2.fromScale(100, 100) -- if the .visible doesnt work for some reason in which i doubt, but i dont bother to test
end

local function scanAndAppendPlayers(): ()
    local PlayersInGame = Players:GetPlayers()
    for _, Player : Player in PlayersInGame do
        local PlayerCharacter = Player.Character or Player.CharacterAdded:Wait() :: Model
        local PlayerHumanoid = PlayerCharacter:WaitForChild("Humanoid") :: Humanoid
        local PlayerUI = UiMngr.createPlayerUI(
            Player.UserId,
            Player.DisplayName,
            PlayerHumanoid.Health
        )

        local HealthConnection = PlayerHumanoid.HealthChanged:Connect(
            function(health)
                PlayerUI:setHealth(health)
            end
        )

        table.insert(
            Connections,
            {
                [tostring(Player.UserId)] = {
                    ["Connection"] = HealthConnection
                }
            }
        )
    end
end

local function onPlayerLeave(Player: Player): ()
    local UserId = tostring(Player.UserId)

    for i, connectionData in Connections do
        if connectionData[UserId] then
            connectionData[UserId].Connection:Disconnect()
            table.remove(Connections, i)
            break
        end
    end

    UiMngr.removePlayerUI(Player.UserId)
end

local function onPlayerAdded(Player: Player): ()
    local PlayerCharacter = Player.Character or Player.CharacterAdded:Wait()
    local PlayerHumanoid = PlayerCharacter:WaitForChild("Humanoid")
    local PlayerUI = UiMngr.createPlayerUI(
        Player.UserId,
        Player.DisplayName,
        PlayerHumanoid.Health
    )

    local HealthConnection = PlayerHumanoid.HealthChanged:Connect(
        function(health)
            PlayerUI:setHealth(health)
        end
    )

    table.insert(
        Connections,
        {
            [tostring(Player.UserId)] = {
                ["Connection"] = HealthConnection
            }
        }
    )
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerLeave)

scanAndAppendPlayers()
hideOriginalHealthUI()
