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
	teammates.BackgroundTransparency = 1
	teammates.Position = UDim2.fromScale(0, 0.525)
	teammates.Size = UDim2.fromScale(0.25, 0.451)

	local layout = Instance.new("UIListLayout")
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
	frame.Size = UDim2.fromScale(0.9, 0.2)

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.25, 0)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Color3.fromRGB(255, 240, 222)
	stroke.Thickness = 2
	stroke.Parent = frame

	self:_createInternalLayout(frame)

	frame.Parent = UIManager._gui.Teammates
	return frame
end

function PlayerUI:_createInternalLayout(frame)
	-- Avatar
	local avatar = Instance.new("ImageLabel")
	avatar.Name = "UserIcon"
	avatar.BackgroundTransparency = 1
	avatar.Size = UDim2.fromScale(0.15, 1)
	avatar.ScaleType = Enum.ScaleType.Crop

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = avatar

	self.avatar = avatar
	avatar.Parent = frame

	local info = Instance.new("Frame")
	info.Name = "Information"
	info.BackgroundTransparency = 1
	info.Size = UDim2.fromScale(0.8, 1)

	local username = Instance.new("TextLabel")
	username.BackgroundTransparency = 1
	username.FontFace = Font.new("rbxasset://fonts/families/Oswald.json")
	username.Size = UDim2.fromScale(1, 0.5)
	username.TextColor3 = Color3.fromRGB(255, 222, 189)
	username.TextScaled = true
	username.RichText = true
	self.username = username
	username.Parent = info

	local bar = Instance.new("Frame")
	bar.Name = "Bar"
	bar.BackgroundColor3 = Color3.fromRGB(56, 46, 39)
	bar.BackgroundTransparency = 0.7
	bar.Size = UDim2.fromScale(1, 0.374)

	local healthFill = Instance.new("Frame")
	healthFill.Name = "HealthBar"
	healthFill.BackgroundColor3 = Color3.fromRGB(255, 240, 222)
	healthFill.Size = UDim2.fromScale(1, 1)
	healthFill.Parent = bar

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.25, 0)
	corner.Parent = bar

	local cornerFill = corner:Clone()
	cornerFill.Parent = healthFill

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
