--[[

I'm not giving documentation for tis one since im a little lazy
feel free to modify, tinker, or use for your own scripts, i couldnt care less.

- Chrono comet devleopment or something

--]]

local PlayerUI = {}
PlayerUI.__index = PlayerUI

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local HEALTH_BAR_TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local UIManager = {
    _instances = {},
    _gui = nil
}

function UIManager.init()
    if UIManager._gui then return end

    local gui = Instance.new("ScreenGui")
    gui.Name = "ChronoHealthQOL"
    gui.IgnoreGuiInset = true
    gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets

    local teammates = Instance.new("Frame")
    teammates.Name = "Teammates"
    teammates.BackgroundColor3 = Color3.fromRGB(255, 38, 0)
    teammates.BackgroundTransparency = 1
    teammates.BorderColor3 = Color3.fromRGB(0, 0, 0)
    teammates.BorderSizePixel = 0
    teammates.Position = UDim2.fromScale(0, 0.525)
    teammates.Size = UDim2.fromScale(0.25, 0.451)

    local layout = Instance.new("UIListLayout")
    layout.Name = "UIListLayout"
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Padding = UDim.new(0.05, 0)
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Parent = teammates

    teammates.Parent = gui
    UIManager._gui = gui

    return gui
end

function UIManager.createPlayerUI(userId: number, name: string, health: number): table
    if UIManager._instances[userId] then
        return UIManager._instances[userId]
    end

    local self = setmetatable({}, PlayerUI)
    self:_init(userId, name, health)
    UIManager._instances[userId] = self

    return self
end

function UIManager.removePlayerUI(userId: number)
    local instance = UIManager._instances[userId]
    if instance then
        instance:destroy()
        UIManager._instances[userId] = nil
    end
end

function PlayerUI:_init(userId, name, health)
    self.userId = userId
    self.frame = self:_createBaseFrame()
    self:setName(name)
    self:setHealth(health)
    self:updateAvatar()
end

function PlayerUI:_createBaseFrame()
    local frame = Instance.new("Frame")
    frame.Name = tostring(self.userId)
    frame.BackgroundColor3 = Color3.fromRGB(27, 15, 14)
    frame.BackgroundTransparency = 0.8
    frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.fromScale(0.25, 0)
    frame.Size = UDim2.fromScale(0.9, 0.2)

    local horizontalLayout = Instance.new("UIListLayout")
    horizontalLayout.Name = "UIListLayout"
    horizontalLayout.FillDirection = Enum.FillDirection.Horizontal
    horizontalLayout.Padding = UDim.new(0.02, 0)
    horizontalLayout.SortOrder = Enum.SortOrder.LayoutOrder
    horizontalLayout.Parent = frame

    self:_createInternalLayout(frame)

    local corner = Instance.new("UICorner")
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Color3.fromRGB(255, 240, 222)
    stroke.Thickness = 2
    stroke.Parent = frame

    local padding = Instance.new("UIPadding")
    padding.PaddingBottom = UDim.new(0.1, 0)
    padding.PaddingLeft = UDim.new(0.02, 0)
    padding.PaddingRight = UDim.new(0.02, 0)
    padding.PaddingTop = UDim.new(0.1, 0)
    padding.Parent = frame

    frame.Parent = UIManager._gui.Teammates
    return frame
end

function PlayerUI:_createInternalLayout(frame)
    local avatar = Instance.new("ImageLabel")
    avatar.Name = "UserIcon"
    avatar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    avatar.BackgroundTransparency = 1
    avatar.BorderColor3 = Color3.fromRGB(0, 0, 0)
    avatar.BorderSizePixel = 0
    avatar.ScaleType = Enum.ScaleType.Crop
    avatar.Size = UDim2.fromScale(0.15, 1)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = avatar

    self.avatar = avatar
    avatar.Parent = frame

    local info = Instance.new("Frame")
    info.Name = "Information"
    info.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    info.BackgroundTransparency = 1
    info.BorderColor3 = Color3.fromRGB(0, 0, 0)
    info.BorderSizePixel = 0
    info.Size = UDim2.fromScale(0.8, 1)

    local infoLayout = Instance.new("UIListLayout")
    infoLayout.Name = "UIListLayout"
    infoLayout.Padding = UDim.new(0.1, 0)
    infoLayout.SortOrder = Enum.SortOrder.LayoutOrder
    infoLayout.Parent = info

    local username = Instance.new("TextLabel")
    username.Name = "Username"
    username.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    username.BackgroundTransparency = 1
    username.BorderColor3 = Color3.fromRGB(0, 0, 0)
    username.BorderSizePixel = 0
    username.FontFace = Font.new("rbxasset://fonts/families/Oswald.json")
    username.RichText = true
    username.Size = UDim2.fromScale(1, 0.5)
    username.TextColor3 = Color3.fromRGB(255, 222, 189)
    username.TextScaled = true
    username.TextWrapped = true
    username.TextXAlignment = Enum.TextXAlignment.Left
    self.username = username
    username.Parent = info

    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.AnchorPoint = Vector2.new(0, 0.5)
    bar.BackgroundColor3 = Color3.fromRGB(56, 46, 39)
    bar.BackgroundTransparency = 0.7
    bar.BorderColor3 = Color3.fromRGB(27, 42, 53)
    bar.LayoutOrder = 1
    bar.Position = UDim2.fromScale(0, 0.833)
    bar.Size = UDim2.fromScale(1, 0.374)
    bar.ZIndex = 0

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0.25, 0)
    barCorner.Parent = bar

    local barStroke = Instance.new("UIStroke")
    barStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    barStroke.Color = Color3.fromRGB(255, 240, 222)
    barStroke.Thickness = 1.3
    barStroke.Parent = bar

    local barPadding = Instance.new("UIPadding")
    barPadding.PaddingBottom = UDim.new(0, 3)
    barPadding.PaddingLeft = UDim.new(0, 4)
    barPadding.PaddingRight = UDim.new(0, 4)
    barPadding.PaddingTop = UDim.new(0, 3)
    barPadding.Parent = bar

    local healthFill = Instance.new("Frame")
    healthFill.Name = "HealthBar"
    healthFill.AnchorPoint = Vector2.new(0, 0.5)
    healthFill.BackgroundColor3 = Color3.fromRGB(255, 240, 222)
    healthFill.BorderColor3 = Color3.fromRGB(27, 42, 53)
    healthFill.Position = UDim2.fromScale(0, 0.5)
    healthFill.Size = UDim2.fromScale(1, 1)
    healthFill.ZIndex = 2

    local healthCorner = Instance.new("UICorner")
    healthCorner.CornerRadius = UDim.new(0.25, 0)
    healthCorner.Parent = healthFill

    healthFill.Parent = bar
    self.healthBar = healthFill
    bar.Parent = info
    info.Parent = frame
end

function PlayerUI:setName(name: string)
    self.username.Text = name
end

function PlayerUI:setHealth(health: number)
    health = math.clamp(health, 0, 100)

    if self._currentTween then
        self._currentTween:Cancel()
    end

    self._currentTween = TweenService:Create(
        self.healthBar,
        HEALTH_BAR_TWEEN_INFO,
        {Size = UDim2.fromScale(health/100, 1)}
    )
    self._currentTween:Play()
end

function PlayerUI:updateAvatar()
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420

    local content = Players:GetUserThumbnailAsync(self.userId, thumbType, thumbSize)
    self.avatar.Image = content
end

function PlayerUI:destroy()
    if self._currentTween then
        self._currentTween:Cancel()
    end
    self.frame:Destroy()
end

return UIManager
