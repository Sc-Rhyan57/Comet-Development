--[[

This is my first OOP script in a while, so please excuse any mistakes I make.
This is designed to help you create any custom **MODIFICATION** to the game, such as turning off the lights in a room when it's opened.
-- Chrono @ Comet Development

CURRENTLY UNDER DEVELOPMENT

--]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameData = ReplicatedStorage:WaitForChild("GameData")
local LatestRoom = GameData:WaitForChild("LatestRoom")

local CurrentRooms = workspace:WaitForChild("CurrentRooms")
local CurrentCamera = workspace.CurrentCamera

-- // Room Hooks \\ --

RoomHook = {}
RoomHook.__index = RoomHook

function RoomHook:New()
    local meta = setmetatable({}, RoomHook)
    meta.events = {}
    return meta
end

function RoomHook:On(event, callback)
    event = string.lower(event)
    if not self.events[event] then
        self.events[event] = {}
    end
    table.insert(self.events[event], callback)
end

function RoomHook:Wait(event)
    event = string.lower(event)
    local bindableEvent = Instance.new("BindableEvent")
    
    local function callback(...)
        bindableEvent:Fire(...)
    end
    
    self:On(event, callback)
    bindableEvent.Event:Once(
        function(): ()
            bindableEvent:Destroy()
        end
    )
    
    return bindableEvent.Event:Wait()
end

local function triggerRoomHook(event, ...)
    event = string.lower(event)
    if RoomHook.events[event] then
        for _, callback in ipairs(RoomHook.events[event]) do
            callback(...)
        end
    end
end

Player:GetAttributeChangedSignal("CurrentRoom"):Connect(
    function(): ()
        local CurrentRoom = Player:GetAttribute("CurrentRoom")
        local RoomModel = CurrentRooms:FindFirstChild(tostring(CurrentRoom))
        assert(RoomModel, "Room " .. tostring(CurrentRoom) .. " does not exist.")
        return triggerRoomHook("PlayerRoomChanged", RoomModel)
    end
)

LatestRoom.Changed:Connect(
    function(): ()
        local RoomModel = CurrentRooms:FindFirstChild(tostring(LatestRoom.Value))
        assert(RoomModel, "Room " .. tostring(LatestRoom.Value) .. " does not exist.")
        return triggerRoomHook("ServerRoomChanged", RoomModel)
    end
)

-- // Entity Hooks \\ --

EntityHook = {}
EntityHook.__index = EntityHook

function EntityHook:New()
    local meta = setmetatable({}, EntityHook)
    meta.events = {}
    return meta
end

function EntityHook:On(event, callback)
    event = string.lower(event)
    if not self.events[event] then
        self.events[event] = {}
    end
    table.insert(self.events[event], callback)
end

local function triggerEntityHook(event, ...)
    event = string.lower(event)
    if EntityHook.events[event] then
        for _, callback in ipairs(EntityHook.events[event]) do
            callback(...)
        end
    end
end

workspace.ChildAdded:Connect(
    function(child): ()
        local Character = Player.Character
        assert(Character, "Character does not exist.")

        if child.Name == "Eyes" then
            return triggerEntityHook("eyes", child)
        elseif child.Name == "RushMoving" then
            local CharacterPosition = Character:GetPivot().Position
            local RushPosition = child:GetPivot().Position
            local Magnitude = (CharacterPosition - RushPosition).Magnitude

            if Magnitude <= 200 then
                return triggerEntityHook("rush", child)
            end
        elseif child.Name == "AmbushMoving" then
            local Character = Player.Character
            assert(Character, "Character does not exist.")

            local CharacterPosition = Character:GetPivot().Position
            local RushPosition = child:GetPivot().Position
            local Magnitude = (CharacterPosition - RushPosition).Magnitude

            if Magnitude <= 200 then
                return triggerEntityHook("ambush", child)
            end
        end
    end
)

CurrentCamera.ChildAdded:Connect(
    function(child): ()
        if child.Name == "LiveScreech" then
            return triggerEntityHook("screech", child)
        end
    end
)

-- // Useful Functions \\ --

QuickFunctions = {}

function QuickFunctions:GetRoom(Room: any): Model
    local RoomName = tostring(Room)
    local RoomModel = CurrentRooms:FindFirstChild(RoomName)

    return RoomModel
end

-- // Return \\ --

return {
    RoomHook = RoomHook,
    EntityHook = EntityHook,
    QuickFunctions = QuickFunctions
}
