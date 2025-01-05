local TweenService = game:GetService("TweenService")

local CustomDoor = {}
CustomDoor.__index = CustomDoor

function CustomDoor.new(doorId, RoomPoint)
	if not doorId then
		return error("Door ID is required")
	end

    local self = setmetatable({}, CustomDoor)
    self.doorId = doorId
    self.doorModel = nil
    self.onOpenCallbacks = {}
    self.RoomPoint = RoomPoint
    return self
end

function CustomDoor:Create()
    self.doorModel = game:GetObjects("rbxassetid://" .. self.doorId)[1]
    self.doorModel.Parent = self.RoomPoint.Parent
    self.doorModel:SetPrimaryPartCFrame(self.RoomPoint.CFrame * CFrame.new(0, 0, 0.5))
    self:SetupDoorMechanism()
end

function CustomDoor:AddOpenCallback(callback)
    table.insert(self.onOpenCallbacks, callback)
end

function CustomDoor:SetupDoorMechanism()
    local doorPrompt = self.doorModel.Knob.PromptAtt.DoorOpen
    
    local function OpenDoor()
        doorPrompt.Enabled = false
        
        task.spawn(function()
            local knobOriginalC1 = self.doorModel.Hinge.Knob.C1
            
            TweenService:Create(self.doorModel.Hinge.Knob, 
                TweenInfo.new(0.5, Enum.EasingStyle.Back), 
                {C1 = knobOriginalC1 * CFrame.Angles(0, 0, math.rad(-35))}
            ):Play()
            
            task.wait(0.5)
            
            self.doorModel.Door.CanCollide = false
            self.doorModel.Door.Open:Play()
            self.doorModel.Hidden:Destroy()
            
            -- Execute all callbacks
            for _, callback in ipairs(self.onOpenCallbacks) do
                task.spawn(callback)
            end
                        
            TweenService:Create(self.doorModel.Hinge.Knob, 
                TweenInfo.new(0.5, Enum.EasingStyle.Back), 
                {C1 = knobOriginalC1}
            ):Play()
            
            TweenService:Create(self.doorModel.Hinge, 
                TweenInfo.new(0.5, Enum.EasingStyle.Back), 
                {CFrame = self.doorModel.Hinge.CFrame * CFrame.Angles(0, math.rad(-90), 0)}
            ):Play()
        end)
    end
    
    doorPrompt.Triggered:Connect(OpenDoor)
end

local RoomGenerator = {}
RoomGenerator.__index = RoomGenerator

function RoomGenerator.new(roomId)
    local self = setmetatable({}, RoomGenerator)
    self.roomId = roomId
    self.door = nil
    return self
end

function RoomGenerator:Generate(RoomPoint)
    local room = game:GetObjects("rbxassetid://" .. self.roomId)[1]
    room.Parent = workspace.CurrentRooms
    room.Name = "CustomRoom_Generated"..tostring(tick())
    room:SetPrimaryPartCFrame(RoomPoint.CFrame)
    
    self:GetNearestPlankedDoor(RoomPoint.Parent.Parent, RoomPoint)
    
    self.door = CustomDoor.new(self.doorId, RoomPoint)
    self.door:Create()
    
    return self.door
end

function RoomGenerator:GetNearestPlankedDoor(room, RoomPoint)
    for _, v in pairs(room:GetDescendants()) do
        if v.Name == "FakeDoor_Hotel" then
            local PlankDistance = (RoomPoint.Position - v.FakeDoor.Position).Magnitude
            
            if PlankDistance < 5 then
                for _, z in pairs(v:GetDescendants()) do
                    if z:IsA("BasePart") then
                        z.Transparency = 1
                        z.CanCollide = false
                    end
                end
            end
        end
    end
end

return {
    RoomGenerator = RoomGenerator,
    CustomDoor = CustomDoor
}
