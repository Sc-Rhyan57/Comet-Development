local TweenService = game:GetService("TweenService")

local Room = {}
Room.__index = Room

function Room.new(roomId, doorId, roomPoint)
    if not roomId then
        return error("Room ID is required")
    end
    if not doorId then
        return error("Door ID is required")
    end
    if not roomPoint then
        return error("Room Point is required")
    end

    local self = setmetatable({}, Room)
    self.roomId = roomId
    self.doorId = doorId
    self.roomPoint = roomPoint
    self.doorModel = nil
    self.onOpenCallbacks = {}
    return self
end

function Room:CreateDoor()
    self.doorModel = game:GetObjects("rbxassetid://" .. self.doorId)[1]
    if not self.doorModel then
        return error("Failed to load door model")
    end
    
    self.doorModel.Parent = self.roomPoint.Parent
    self.doorModel:SetPrimaryPartCFrame(self.roomPoint.CFrame * CFrame.new(0, 0, 0.5))
    self:SetupDoorMechanism()
end

function Room:AddOpenCallback(callback)
    table.insert(self.onOpenCallbacks, callback)
end

function Room:SetupDoorMechanism()
    local doorPrompt = self.doorModel.Knob.PromptAtt.DoorOpen
    
    local function OpenDoor()
        doorPrompt.Enabled = false
        
        task.spawn(function()
            local knobOriginalC1 = self.doorModel.Hinge.Knob.C1
            
            TweenService:Create(
                self.doorModel.Hinge.Knob, 
                TweenInfo.new(0.5, Enum.EasingStyle.Back), 
                {C1 = knobOriginalC1 * CFrame.Angles(0, 0, math.rad(-35))}
            ):Play()
            
            task.wait(0.5)
            
            self.doorModel.Door.CanCollide = false
            self.doorModel.Door.Open:Play()
            
            if self.doorModel:FindFirstChild("Hidden") then
                self.doorModel.Hidden:Destroy()
            end
            
            for _, callback in ipairs(self.onOpenCallbacks) do
                task.spawn(callback)
            end
            
            TweenService:Create(
                self.doorModel.Hinge.Knob, 
                TweenInfo.new(0.5, Enum.EasingStyle.Back), 
                {C1 = knobOriginalC1}
            ):Play()
            
            TweenService:Create(
                self.doorModel.Hinge, 
                TweenInfo.new(1.5, Enum.EasingStyle.Sine), 
                {CFrame = self.doorModel.Hinge.CFrame * CFrame.Angles(0, math.rad(-90), 0)}
            ):Play()
        end)
    end
    
    doorPrompt.Triggered:Connect(OpenDoor)
end

function Room:Generate()
    self:HandleNearbyPlankedDoors()
    
    local room = game:GetObjects("rbxassetid://" .. self.roomId)[1]
    if not room then
        return error("Failed to load room model")
    end
    
    room.Parent = workspace.CurrentRooms
    room.Name = "CustomRoom_Generated"..tostring(tick())
    room:SetPrimaryPartCFrame(self.roomPoint.CFrame)
    
    self:CreateDoor()
    
    return self
end

function Room:HandleNearbyPlankedDoors()
    local room = self.roomPoint.Parent.Parent
    if not room then return end
    
    for _, v in pairs(room:GetDescendants()) do
        if v.Name == "FakeDoor_Hotel" then
            local plankDistance = (self.roomPoint.Position - v.FakeDoor.Position).Magnitude
            
            if plankDistance < 5 then
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

return Room
