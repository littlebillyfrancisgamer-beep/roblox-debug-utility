local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DebugUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 280)
mainFrame.Position = UDim2.new(0, 20, 0, 40)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = mainFrame

-- Top bar (drag handle)
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 36)
topBar.BackgroundColor3 = Color3.fromRGB(34, 34, 44)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 14)
topBarCorner.Parent = topBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -120, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Debug Menu"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

-- Toggle button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 70, 0, 24)
toggleButton.Position = UDim2.new(1, -80, 0, 6)
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
toggleButton.Text = "Close"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 12
toggleButton.AutoButtonColor = false
toggleButton.Parent = topBar

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleButton

-- Content
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -20, 1, -56)
content.Position = UDim2.new(0, 10, 0, 46)
content.BackgroundTransparency = 1
content.Parent = mainFrame

local labels = {}

local function addLabel(text, yPos, color)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 20)
	label.Position = UDim2.new(0, 0, 0, yPos)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color or Color3.fromRGB(220, 220, 220)
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = content
	table.insert(labels, label)
end

-- Calculate account age
local function getAccountAge()
	local createdTime = player.CreatedTime
	local currentTime = os.time()
	local accountAgeSeconds = currentTime - createdTime
	local accountAgeDays = math.floor(accountAgeSeconds / 86400)
	return accountAgeDays
end

local accountAge = getAccountAge()

addLabel("Player: " .. player.Name, 0, Color3.fromRGB(255, 255, 255))
addLabel("User ID: " .. tostring(player.UserId), 22)
addLabel("Account Age: " .. tostring(accountAge) .. " days", 44, Color3.fromRGB(150, 200, 255))
addLabel("Place ID: " .. tostring(game.PlaceId), 66)
addLabel("Job ID: " .. tostring(game.JobId), 88)
addLabel("Character: " .. tostring(player.Character and player.Character.Name or "None"), 110)

-- FPS
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, 0, 0, 20)
fpsLabel.Position = UDim2.new(0, 0, 0, 132)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: 0"
fpsLabel.TextColor3 = Color3.fromRGB(90, 255, 120)
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 12
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.Parent = content

local isOpen = true

local function updateButtonText()
	if isOpen then
		toggleButton.Text = "Close"
	else
		toggleButton.Text = "Open"
	end
end

local function animatePanel(open)
	local goalSize = open and UDim2.new(0, 300, 0, 280) or UDim2.new(0, 300, 0, 36)
	local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local tween = TweenService:Create(mainFrame, tweenInfo, {
		Size = goalSize
	})
	tween:Play()

	if not open then
		content.Visible = false
	else
		content.Visible = true
	end

	updateButtonText()
end

toggleButton.MouseButton1Click:Connect(function()
	isOpen = not isOpen
	animatePanel(isOpen)
end)

-- Dragging
local dragging = false
local dragStart
local startPos

local function dragInput(input)
	local delta = input.Position - dragStart
	mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)

topBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput(input)
	end
end)

-- Open/Close with keyboard shortcut
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.RightShift then
		isOpen = not isOpen
		animatePanel(isOpen)
	end
end)

-- FPS update
local frames = 0
local lastTick = tick()

RunService.RenderStepped:Connect(function()
	frames += 1
	local now = tick()
	if now - lastTick >= 1 then
		local fps = math.floor(frames / (now - lastTick))
		fpsLabel.Text = "FPS: " .. tostring(fps)
		frames = 0
		lastTick = now
	end
end)

animatePanel(true)
