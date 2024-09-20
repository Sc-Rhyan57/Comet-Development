-- Services

local CoreGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

-- Initial Functions

local function runCoreCall(ITitle: string, IText: string, IDuration: number): ()
    local Success, Return = pcall(
        function(): boolean?
            CoreGui:SetCore("SendNotification", {
                Title = ITitle,
                Text = IText,
                Duration = IDuration
            })
        end
    )

    assert(Success, Return)
end

local function findFirstDescendant(parent, name): Instance?
    for _, descendant: Instance in pairs(parent:GetDescendants()) do
        if descendant.Name == name then
            return descendant
        end
    end
    return nil
end

local function flickerLights(room, flickerDuration, percentToFlicker, randomSeed): ()
    local targetRoom = room;
    local flickerPercentage = percentToFlicker;
    local seed = randomSeed;

    if not flickerPercentage then
        flickerPercentage = 100;
    end

    if not seed then
        seed = Random.new(tick());
    end

    local lightFixtures = {};
    for _, object in pairs(targetRoom:GetDescendants()) do
        if object:IsA("Model") and (object.Name == "LightStand_Lobby" or object.Name == "Chandelier_Lobby") then
            table.insert(lightFixtures, object);
        end
    end

    flickerPercentage = math.min(flickerPercentage, #lightFixtures);

    if flickerPercentage < 100 then
        local selectedFixtures = {};
        for i = 1, 100 do
            local randomFixture = lightFixtures[seed:NextInteger(1, #lightFixtures)];
            local isUnique = true;
            for _, selectedFixture in pairs(selectedFixtures) do
                if selectedFixture == randomFixture then
                    isUnique = false;
                end
            end
            if isUnique then
                table.insert(selectedFixtures, randomFixture);
            end
            if flickerPercentage <= #selectedFixtures then
                break;
            end
        end
        lightFixtures = selectedFixtures;
    end

    for _, fixture in pairs(lightFixtures) do
        for _, descendant in pairs(fixture:GetDescendants()) do
            if descendant:IsA("Light") then
                descendant:SetAttribute("OriginalBrightness", descendant.Brightness);
            end
        end
    end

    if flickerPercentage > 5 then
        TweenService:Create(game.Lighting, TweenInfo.new(flickerDuration / 2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, true), {
            Ambient = Color3.new(0, 0, 0)
        }):Play();
    end

    local startTime = tick();
    for _, fixture in pairs(lightFixtures) do
        task.spawn(function()
            task.wait(seed:NextNumber(1, 30) / 100);
            local adjustedDuration = flickerDuration + seed:NextNumber(-100, 100) / 250;
            for i = 1, 1000 do
                local flickerDuration = seed:NextNumber(3, 12) / 100;
                if startTime + adjustedDuration <= tick() then
                    for _, descendant in pairs(fixture:GetDescendants()) do
                        if descendant:IsA("Light") then
                            descendant.Brightness = 0;
                            TweenService:Create(descendant, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                                Brightness = descendant:GetAttribute("OriginalBrightness")
                            }):Play();
                        end
                        if descendant.Name == "Neon" then
                            descendant.Transparency = 0.8;
                            TweenService:Create(descendant, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                                Transparency = 0.1
                            }):Play();
                        end                        
                    end
                    return;
                end

                local zapSound = findFirstDescendant(fixture, "BulbZap");

                if zapSound then
                    zapSound.TimePosition = math.random(0, 13) / 20;
                    zapSound.Pitch = zapSound.Pitch + math.random(-100, 100) / 5000;
                    zapSound:Play();
                end

                for _, descendant in pairs(fixture:GetDescendants()) do
                    if descendant:IsA("Light") then
                        descendant.Brightness = descendant:GetAttribute("OriginalBrightness");
                        TweenService:Create(descendant, TweenInfo.new(flickerDuration, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0), {
                            Brightness = 0
                        }):Play();
                    end
                end

                local neonPart = fixture:FindFirstChild("Neon", true);
                if neonPart and neonPart.Name == "Neon" then
                    neonPart.Transparency = 0;
                    TweenService:Create(neonPart, TweenInfo.new(flickerDuration, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0), {
                        Transparency = 0.7
                    }):Play();
                end

                task.wait(flickerDuration + seed:NextNumber(-20, 20) / 100);
            end
        end);
    end
end

-- Game Check

local LOBBY_GAME_ID = 6516141723 -- For some reason, infinite yield decided to teleport me to "Doors but the monsters are nice" :sob: WTF????
local CURRENT_GAME_ID = game.GameId

if LOBBY_GAME_ID ~= CURRENT_GAME_ID then
    return runCoreCall(
        "Error",
        "The script you have executed is not compatible with this game! You must be in the Doors lobby to use this script!",
        10
    )
end

-- Constants

local Player = Players.LocalPlayer
local LobbyFolder = workspace:WaitForChild("Lobby")
local AssetsFolder = LobbyFolder:WaitForChild("Assets")

-- Events 

TextChatService.MessageReceived:Connect(
    function(message: TextChatMessage)
        local SourceSender = message.TextSource
        if SourceSender.Name ~= Player.Name then
            return
        end

        local SourceMessage = message.Text

        if _G.CDebug then
            print("Message: " .. SourceMessage)
        end

        if SourceMessage == "/flicker" then
            task.spawn(flickerLights, AssetsFolder, 4, 100, Random.new(tick()))
            
            if _G.CDebug then
                return runCoreCall(
                    "Success",
                    "Flickering lights in the lobby!",
                    1
                )
            end
        end
    end
)

--[[

I don't know why I bother with these useless scripts..
Maybe it might be a learning experience! Who knows...

Flicker function was ripped directly from Doors, I just shoved it into an AI for those sweet variable names.

--]]
