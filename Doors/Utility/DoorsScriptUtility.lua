--[[

This is my first OOP script in a while, so please excuse any mistakes I make.
This is designed to help you create any custom **MODIFICATION** to the game, such as turning off the lights in a room when it's opened.
-- Chrono @ Comet Development

IN DEVELOPMENT

--]]

local StarterGui = game:GetService("StarterGui")
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

local CurrentRoomHooks = {}
local CurrentEntityHooks = {}

function RoomHook:New()
    local meta = setmetatable({}, RoomHook)
    meta.events = {}
    table.insert(CurrentRoomHooks, meta)
    return meta
end

function RoomHook:On(event, callback)
    local event_Lowered = string.lower(event)
    if not self.events[event_Lowered] then
        self.events[event_Lowered] = {}
    end
    table.insert(self.events[event_Lowered], callback)
end

function RoomHook:Once(event, callback)
    local event_Lowered = string.lower(event)
    if not self.events[event_Lowered] then
        self.events[event_Lowered] = {}
    end

    local function onceCallback(...)
        callback(...)
        for i, cb in ipairs(self.events[event_Lowered]) do
            if cb == onceCallback then
                table.remove(self.events[event_Lowered], i)
                break
            end
        end
    end

    table.insert(self.events[event_Lowered], onceCallback)
end

function RoomHook:Wait(event)
    event = string.lower(event)
    local bindableEvent = Instance.new("BindableEvent", ReplicatedStorage)
    
    local function callback(...)
        bindableEvent:Fire(...)
    end
    
    self:Once(event, callback)
    bindableEvent.Event:Once(
        function(): ()
            bindableEvent:Destroy()
        end
    )
    
    return bindableEvent.Event:Wait()
end

local function triggerRoomHook(event, ...)
    for _, Hook in ipairs(CurrentRoomHooks) do
        local event_Lowered = string.lower(event)
        if Hook.events[event_Lowered] then
            for _, callback in ipairs(Hook.events[event_Lowered]) do 
                callback(...)
            end
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
        triggerRoomHook("ServerRoomChanged", RoomModel)

        local Door = RoomModel:FindFirstChild("Door")
        if not Door then
            return
        end

        local Lock = Door:FindFirstChild("Lock")
        if not Lock then
            return
        end

        triggerRoomHook("LockedRoom", RoomModel)
    end
)

-- // Entity Hooks \\ --

EntityHook = {}
EntityHook.__index = EntityHook

function EntityHook:New()
    local meta = setmetatable({}, EntityHook)
    meta.events = {}
    table.insert(CurrentEntityHooks, meta)
    return meta
end

function EntityHook:On(event, callback)
    local event_Lowered = string.lower(event)
    if not self.events[event_Lowered] then
        self.events[event_Lowered] = {}
    end
    table.insert(self.events[event_Lowered], callback)
end

local function triggerEntityHook(event, ...)
    for _, Hook in ipairs(CurrentEntityHooks) do
        local event_Lowered = string.lower(event)
        if Hook.events[event_Lowered] then
            for _, callback in ipairs(Hook.events[event_Lowered]) do 
                callback(...)
            end
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

function QuickFunctions:CoreNotification(Params: table): ()
    local Success, Return = pcall(
        function(): boolean?
            StarterGui:SetCore(
                "SendNotification",
                Params
            )
        end
    )

    assert(Success, Return)
end

-- // Return \\ --

return {
    RoomHook = RoomHook,
    EntityHook = EntityHook,
    QuickFunctions = QuickFunctions
}
