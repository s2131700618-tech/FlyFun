-- =============================================================================
-- FlyGui V2.4μΩ (3D 鏡頭自由飛行完整版)
-- =============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
while not player do
	task.wait(0.1)
	player = Players.LocalPlayer
end

local playerGui = player:WaitForChild("PlayerGui", 999)
local camera = workspace.CurrentCamera
local character = player.Character or player.CharacterAdded:Wait()

player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	task.wait(0.5)
	local hum = newCharacter:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand = false end
end)
 
local isFlying = false
local speed = 1
local moveUp = false
local moveDown = false
 
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyGuiV3"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.Parent = playerGui

---------------------------------------------------
-- UI 介面
---------------------------------------------------
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 60)
mainFrame.Position = UDim2.new(0.3, 0, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true 
mainFrame.Parent = screenGui
 
local titleBar = Instance.new("TextLabel")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(0.5, 0, 0.5, 0)
titleBar.Position = UDim2.new(0.5, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
titleBar.BorderSizePixel = 0
titleBar.Text = "FLY GUI V2.4μΩ"
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.TextXAlignment = Enum.TextXAlignment.Left
titleBar.Font = Enum.Font.SourceSansBold
titleBar.TextSize = 14
titleBar.Active = true 
titleBar.Parent = mainFrame
 
local contentText = Instance.new("TextLabel")
contentText.Name = "SpeedDisplay"
contentText.Size = UDim2.new(0.25, 0, 0.5, 0)
contentText.Position = UDim2.new(0.5, 0, 0.5, 0)
contentText.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
contentText.Text = tostring(speed)
contentText.TextColor3 = Color3.fromRGB(255, 255, 255)
contentText.TextWrapped = true
contentText.Font = Enum.Font.SourceSans
contentText.TextSize = 16
contentText.Parent = mainFrame
 
local flyButton = Instance.new("TextButton")
flyButton.Name = "FlyButton"
flyButton.Size = UDim2.new(0.25, 0, 0.5, 0)
flyButton.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
flyButton.Position = UDim2.new(0.75, 0, 0.5, 0)
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.Text = "Fly"
flyButton.Parent = mainFrame

local upButton = Instance.new("TextButton")
upButton.Name = "UpButton"
upButton.Size = UDim2.new(0.25, 0, 0.5, 0)
upButton.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
upButton.Position = UDim2.new(0, 0, 0, 0)
upButton.TextColor3 = Color3.fromRGB(255, 255, 255)
upButton.Text = "Up"
upButton.Parent = mainFrame

local downButton = Instance.new("TextButton")
downButton.Name = "DownButton"
downButton.Size = UDim2.new(0.25, 0, 0.5, 0)
downButton.BackgroundColor3 = Color3.fromRGB(80, 40, 180)
downButton.Position = UDim2.new(0, 0, 0.5, 0)
downButton.TextColor3 = Color3.fromRGB(255, 255, 255)
downButton.Text = "Down"
downButton.Parent = mainFrame

local flyupButton = Instance.new("TextButton")
flyupButton.Name = "SpeedUpButton"
flyupButton.Size = UDim2.new(0.25, 0, 0.5, 0)
flyupButton.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
flyupButton.Position = UDim2.new(0.25, 0, 0, 0)
flyupButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyupButton.Text = "+"
flyupButton.Parent = mainFrame

local flydownButton = Instance.new("TextButton")
flydownButton.Name = "SpeedDownButton"
flydownButton.Size = UDim2.new(0.25, 0, 0.5, 0)
flydownButton.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
flydownButton.Position = UDim2.new(0.25, 0, 0.5, 0)
flydownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flydownButton.Text = "-"
flydownButton.Parent = mainFrame
 
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0.25, 0, 0.5, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Position = UDim2.new(0, 0, -0.5, 0)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Text = "X"
closeButton.Parent = mainFrame

local smallButton = Instance.new("TextButton")
smallButton.Name = "MinimizeButton"
smallButton.Size = UDim2.new(0.25, 0, 0.5, 0)
smallButton.BackgroundColor3 = Color3.fromRGB(220, 100, 0)
smallButton.Position = UDim2.new(0.25, 0, -0.5, 0)
smallButton.TextColor3 = Color3.fromRGB(255, 255, 255)
smallButton.Text = "_"
smallButton.Parent = mainFrame

---------------------------------------------------
-- 工具函數
---------------------------------------------------
local function getVehicleSeat()
	if not character then return nil end
	local hum = character:FindFirstChildOfClass("Humanoid")
	if hum and hum.SeatPart then
		return hum.SeatPart
	end
	return nil
end

local function getTorso()
	if not character then return nil end
	return character.PrimaryPart or character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
end

local function removeAllPhysics()
	local seat = getVehicleSeat()
	if seat then
		for _, v in ipairs(seat:GetDescendants()) do
			if v.Name == "FlyVelocity" or v.Name == "FlyGyro" or v.Name == "FlyWeld" then
				v:Destroy()
			end
		end
		local model = seat:FindFirstAncestorOfClass("Model")
		if model then
			for _, v in ipairs(model:GetDescendants()) do
				if v.Name == "FlyWeld" then
					v:Destroy()
				end
			end
		end
	end
	
	local torso = getTorso()
	if torso then
		for _, v in ipairs(torso:GetChildren()) do
			if v.Name == "FlyVelocity" or v.Name == "FlyGyro" then
				v:Destroy()
			end
		end
	end
end

local function disableFly()
	isFlying = false
	moveUp = false
	moveDown = false
	upButton.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
	downButton.BackgroundColor3 = Color3.fromRGB(80, 40, 180)
	flyButton.Text = "Fly"
	flyButton.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
	removeAllPhysics()
	if character then
		local hum = character:FindFirstChildOfClass("Humanoid")
		if hum then hum.PlatformStand = false end
	end
end

local function setupFlyPhysics()
	removeAllPhysics()
	local seat = getVehicleSeat()
	local cameraCF = camera.CFrame
	
	if seat then
		local model = seat:FindFirstAncestorOfClass("Model")
		if model then
			for _, part in ipairs(model:GetDescendants()) do
				if part:IsA("BasePart") and part ~= seat then
					part.Anchored = false
					local weld = Instance.new("WeldConstraint")
					weld.Name = "FlyWeld"
					weld.Part0 = seat
					weld.Part1 = part
					weld.Parent = seat
				end
			end
		end

		local bg = Instance.new("BodyGyro")
		bg.Name = "FlyGyro"
		bg.P = 1e5
		bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.cframe = cameraCF
		bg.Parent = seat
		
		local bv = Instance.new("BodyVelocity")
		bv.Name = "FlyVelocity"
		bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
		bv.velocity = Vector3.new(0, 0.1, 0)
		bv.Parent = seat
	else
		if character then
			local hum = character:FindFirstChildOfClass("Humanoid")
			if hum then hum.PlatformStand = true end
		end
		
		local torso = getTorso()
		if not torso then return end
		
		local bg = Instance.new("BodyGyro")
		bg.Name = "FlyGyro"
		bg.P = 1e5
		bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.cframe = cameraCF
		bg.Parent = torso
		
		local bv = Instance.new("BodyVelocity")
		bv.Name = "FlyVelocity"
		bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
		bv.velocity = Vector3.new(0, 0.1, 0)
		bv.Parent = torso
	end
end

---------------------------------------------------
-- 按鈕事件
---------------------------------------------------
flyButton.MouseButton1Click:Connect(function()
	isFlying = not isFlying
	if isFlying then
		flyButton.Text = "Stop"
		flyButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
		setupFlyPhysics()
	else
		disableFly()
	end
end)

flyupButton.MouseButton1Click:Connect(function() speed = speed + 1 contentText.Text = tostring(speed) end)
flydownButton.MouseButton1Click:Connect(function() speed = math.max(speed - 1, 1) contentText.Text = tostring(speed) end)

upButton.InputBegan:Connect(function(input) 
	if isFlying and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then 
		moveUp = true 
		upButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) 
	end 
end)
upButton.InputEnded:Connect(function(input) 
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
		moveUp = false 
		upButton.BackgroundColor3 = Color3.fromRGB(100, 60, 200) 
	end 
end)

downButton.InputBegan:Connect(function(input) 
	if isFlying and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then 
		moveDown = true 
		downButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) 
	end 
end)
downButton.InputEnded:Connect(function(input) 
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
		moveDown = false 
		downButton.BackgroundColor3 = Color3.fromRGB(80, 40, 180) 
	end 
end)

local isMinimized = false
smallButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	for _, child in ipairs(mainFrame:GetChildren()) do
		if child ~= smallButton and child ~= titleBar and child ~= closeButton then 
			child.Visible = not isMinimized 
		end
	end
	if isMinimized then 
		mainFrame.Size = UDim2.new(0, 200, 0, 30) 
		smallButton.Text = "[]" 
		closeButton.Size = UDim2.new(0.25, 0, 1, 0)
		closeButton.Position = UDim2.new(0, 0, 0, 0)
		smallButton.Size = UDim2.new(0.25, 0, 1, 0)
		smallButton.Position = UDim2.new(0.25, 0, 0, 0)
		titleBar.Size = UDim2.new(0.5, 0, 1, 0)
		titleBar.Position = UDim2.new(0.5, 0, 0, 0)
	else 
		mainFrame.Size = UDim2.new(0, 200, 0, 60) 
		smallButton.Text = "_" 
		closeButton.Size = UDim2.new(0.25, 0, 0.5, 0)
		closeButton.Position = UDim2.new(0, 0, -0.5, 0)
		smallButton.Size = UDim2.new(0.25, 0, 0.5, 0)
		smallButton.Position = UDim2.new(0.25, 0, -0.5, 0)
		titleBar.Size = UDim2.new(0.5, 0, 0.5, 0)
		titleBar.Position = UDim2.new(0.5, 0, 0, 0)
	end
end)

closeButton.MouseButton1Click:Connect(function() disableFly() screenGui:Destroy() end)

RunService.Heartbeat:Connect(function()
	if not isFlying then return end
	
	local seat = getVehicleSeat()
	local targetPart = seat or getTorso()
	if not targetPart then return end
	
	local realSpeed = speed * 50
	local cameraCF = camera.CFrame
	local cameraLook = cameraCF.LookVector
	local cameraRight = cameraCF.RightVector
	local cameraUp = cameraCF.UpVector -- 取得相機畫面的垂直方向

	local bg = targetPart:FindFirstChild("FlyGyro")
	local bv = targetPart:FindFirstChild("FlyVelocity")
	
	if not bg or not bv then
		setupFlyPhysics()
		return
	end

	-- 1. 處理 W/A/S/D 平面移動
	local moveDir = Vector3.new(0, 0, 0)
	local isMoving = false

	if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Vector3.new(cameraLook.X, 0, cameraLook.Z).Unit isMoving = true end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Vector3.new(cameraLook.X, 0, cameraLook.Z).Unit isMoving = true end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cameraRight isMoving = true end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cameraRight isMoving = true end

	local hum = character and character:FindFirstChildOfClass("Humanoid")
	if not isMoving and hum and hum.MoveDirection.Magnitude > 0.1 then
		local rawDir = hum.MoveDirection
		local relForward = rawDir:Dot(cameraLook)
		local relRight = rawDir:Dot(cameraRight)
		moveDir = (cameraLook * relForward + cameraRight * relRight)
		isMoving = true
	end

	local finalVelocity = Vector3.new(0, 0, 0)
	
	-- 疊加 WASD 移動向量
	if isMoving and moveDir.Magnitude > 0 then
		finalVelocity = finalVelocity + (moveDir.Unit * realSpeed)
	end

	-- 3. 疊加上下升降向量（支援畫面 UP/DOWN 按鈕、空白鍵、Shift）
	local verticalMove = Vector3.new(0, 0, 0)
	if moveUp or UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		verticalMove = cameraUp * realSpeed
	elseif moveDown or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
		verticalMove = -cameraUp * realSpeed
	end

	if verticalMove.Magnitude > 0 then
		finalVelocity = finalVelocity + verticalMove -- 完美疊加！可以一邊前進一邊上升
	end

	-- 4. 套用合成後的最終速度與視角
	bv.velocity = finalVelocity
	bg.cframe = cameraCF
end)

---------------------------------------------------
-- UI 拖曳邏輯
---------------------------------------------------
local dragging = false
local dragStart = nil
local startPos = nil

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local guiObjects = playerGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
		local clickedTitle = false
		for _, obj in pairs(guiObjects) do if obj == titleBar then clickedTitle = true break end end
		if not clickedTitle then return end
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		local conn
		conn = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false conn:Disconnect() end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		if dragging and dragStart and startPos then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end
end)
