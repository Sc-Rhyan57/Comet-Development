local FUNNYJUMPSCARELOL = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local ImageLabel = Instance.new("ImageLabel")

FUNNYJUMPSCARELOL.Name = "FUNNY JUMPSCARE LOL"
FUNNYJUMPSCARELOL.Parent = game.CoreGui
FUNNYJUMPSCARELOL.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = FUNNYJUMPSCARELOL
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Size = UDim2.new(1, 0, 1, 0)

ImageLabel.Parent = Frame
ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageLabel.BackgroundTransparency = 1.000
ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
ImageLabel.BorderSizePixel = 0
ImageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
ImageLabel.Size = UDim2.new(0.0500000007, 0, 0.100000001, 0)
ImageLabel.Image = "rbxassetid://8318773866"

-- Scripts:

local function EZEQDfake_script() -- FUNNYJUMPSCARELOL.LocalScript 
    local script = Instance.new('LocalScript', FUNNYJUMPSCARELOL)

    script.Parent.Jumpscare:Play()
    game.TweenService:Create(script.Parent.Frame.ImageLabel, TweenInfo.new(0.15), {Size = UDim2.fromScale(1,1)}):Play()

    task.wait(1)

    for ,v in pairs(script.Parent:GetDescendants()) do
        if v:IsA("ImageLabel") or v:IsA("Frame") then
            game.TweenService:Create(v, TweenInfo.new(1), {BackgroundTransparency = 0.5}):Play()
        end
    end

    task.wait(1)

    script.Parent.Jumpscare:Stop()
    script.Parent.Jumpscare2:Play()
    script.Parent.Frame.BackgroundTransparency = 0
    script.Parent.Frame.ImageLabel.ImageTransparency = 0
    script.Parent.Frame.ImageLabel.BackgroundTransparency = 0
    script.Parent.Frame.ImageLabel.Image = "http://www.roblox.com/asset/?id=3124557274"


    task.wait(3)

    script.Parent:Destroy()
end
coroutine.wrap(EZEQD_fake_script)() 
