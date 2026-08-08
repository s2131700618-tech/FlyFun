-- =============================================================================
-- FlyGui V9.0 終極版 (解決大型車輛/卡車 90度倒栽蔥與物理力不足問題)
-- =============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
 
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)
local camera = workspace.CurrentCamera
local character = player.Character or player.CharacterAdded:Wait()

-- 🧹 清理舊介面
if playerGui then
	local oldGui = playerGui:FindFirstChild("UltraFlyGuiV9_Ultimate")
	if oldGui then oldGui:Destroy() end
end

player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	task.wait(0.5)
	local hum = newCharacter:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.PlatformStand = false
	end
end)
 
local isFlying = false
local speed = 1
local moveUp = false
local moveDown = false
 
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UltraFlyGuiV9_Ultimate"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

---------------------------------------------------
-- UI 介面
---------------------------------------------------
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 60)
mainFrame.Position = UDim2.new(0.25, 0, 0.5, 0)
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
titleBar.Text = "FlyGui V1.2μF ß"
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
closeButton.Size = UDim2.new(0, 50, 0, 30)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Position = UDim2.new(0, 0, -0.5, 0)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Text = "X"
closeButton.Parent = mainFrame

local smallButton = Instance.new("TextButton")
smallButton.Name = "MinimizeButton"
smallButton.Size = UDim2.new(0, 50, 0, 30)
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
	if character then
		for _, v in ipairs(character:GetDescendants()) do
			if v.Name:sub(1,3) == "Fly" then v:Destroy() end
		end
	end
	local seat = getVehicleSeat()
	if seat then
		local vehicleRoot = seat.AssemblyRootPart or seat
		for _, v in ipairs(vehicleRoot:GetDescendants()) do
			if v.Name:sub(1,3) == "Fly" then v:Destroy() end
		end
	end

	local targetParts = {getTorso(), seat}
	for _, part in ipairs(targetParts) do
		if part then
			for _, child in ipairs(part:GetChildren()) do
				if child.Name:sub(1,3) == "Fly" then child:Destroy() end
			end
		end
	end
end

local function disableFly()
	isFlying = false
	moveUp = false
	moveDown = false
	flyButton.Text = "Fly"
	flyButton.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
	
	local seat = getVehicleSeat()
	if seat then
		local vehicleRoot = seat.AssemblyRootPart or seat
		vehicleRoot.AssemblyLinearVelocity = Vector3.zero
		vehicleRoot.AssemblyAngularVelocity = Vector3.zero
		
		-- 重設車輛擺正
		local currentCF = vehicleRoot.CFrame
		local _, yaw, _ = currentCF:ToOrientation()
		vehicleRoot.CFrame = CFrame.new(currentCF.Position) * CFrame.Angles(0, yaw, 0)
	end

	removeAllPhysics()

	if character then
		local torso = getTorso()
		if torso then
			torso.AssemblyLinearVelocity = Vector3.zero
			torso.AssemblyAngularVelocity = Vector3.zero
		end

		local hum = character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.PlatformStand = false
			if not seat then
				hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
				hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
				hum:SetStateEnabled(Enum.HumanoidStateType.Running, true)
				hum:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
				hum:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
		end
	end
end

---------------------------------------------------
-- 🛠 採用全新現代物理控制 (AlignOrientation + LinearVelocity)
---------------------------------------------------
local function setupFlyPhysics()
	removeAllPhysics()
	local seat = getVehicleSeat()
	
	local targetPart = nil
	if seat then
		targetPart = seat.AssemblyRootPart or seat
	else
		targetPart = getTorso()
	end
	
	if not targetPart then return end

	local attachment = Instance.new("Attachment")
	attachment.Name = "FlyAttachment"
	attachment.Parent = targetPart

	-- 超強動力直線速度控制
	local flyForce = Instance.new("LinearVelocity")
	flyForce.Name = "FlyLinearVelocity"
	flyForce.MaxForce = 1e9 -- 提升至十億物理力，重型卡車也能秒推動
	flyForce.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	flyForce.RelativeTo = Enum.ActuatorRelativeTo.World
	flyForce.Attachment0 = attachment
	flyForce.VectorVelocity = Vector3.zero
	flyForce.Parent = targetPart

	-- 超強姿態扭力控制 (防止倒栽蔥)
	local alignOrient = Instance.new("AlignOrientation")
	alignOrient.Name = "FlyAlignOrientation"
	alignOrient.MaxTorque = 1e9 -- 強制鎖定角度，絕對不翻車
	alignOrient.MaxAngularVelocity = 100
	alignOrient.Responsiveness = 200
	alignOrient.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrient.Attachment0 = attachment
	alignOrient.CFrame = camera.CFrame
	alignOrient.Parent = targetPart

	if not seat then
		local hum = character and character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
			hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
			hum:SetStateEnabled(Enum.HumanoidStateType.Running, false)
			hum:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
			hum:ChangeState(Enum.HumanoidStateType.Swimming)
		end
	end
end

---------------------------------------------------
-- UI 按鈕綁定
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

upButton.InputBegan:Connect(function(input) if isFlying and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then moveUp = true upButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) end end)
upButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then moveUp = false upButton.BackgroundColor3 = Color3.fromRGB(100, 60, 200) end end)

downButton.InputBegan:Connect(function(input) if isFlying and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then moveDown = true downButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) end end)
downButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then moveDown = false downButton.BackgroundColor3 = Color3.fromRGB(80, 40, 180) end end)

local isMinimized = false
smallButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	for _, child in ipairs(mainFrame:GetChildren()) do
		if child ~= smallButton and child ~= titleBar and child ~= closeButton then child.Visible = not isMinimized end
	end
	if isMinimized then mainFrame.Size = UDim2.new(0, 200, 0, 30) smallButton.Text = "[]" else mainFrame.Size = UDim2.new(0, 200, 0, 60) smallButton.Text = "_" end
end)

closeButton.MouseButton1Click:Connect(function() disableFly() screenGui:Destroy() end)

---------------------------------------------------
-- 🎯 核心動力鎖定循環
---------------------------------------------------
RunService.Heartbeat:Connect(function()
	if not isFlying then return end
	
	local seat = getVehicleSeat()
	local torso = getTorso()
	local targetPart = seat and (seat.AssemblyRootPart or seat) or torso
	
	if not targetPart then return end

	local flyForce = targetPart:FindFirstChild("FlyLinearVelocity")
	local alignOrient = targetPart:FindFirstChild("FlyAlignOrientation")
	
	if not flyForce or not alignOrient then
		setupFlyPhysics()
		return
	end

	-- 清除車輛自帶角速度防止強行自轉
	targetPart.AssemblyAngularVelocity = Vector3.zero

	local cameraCF = camera.CFrame
	local forwardVector = cameraCF.LookVector
	local rightVector = cameraCF.RightVector
	local realSpeed = speed * 50

	local moveDir = Vector3.zero
	local isMoving = false

	if seat then
		if UserInputService:IsKeyDown(Enum.KeyCode.W) or (seat:IsA("VehicleSeat") and seat.Throttle > 0) then moveDir = moveDir + forwardVector isMoving = true end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) or (seat:IsA("VehicleSeat") and seat.Throttle < 0) then moveDir = moveDir - forwardVector isMoving = true end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) or (seat:IsA("VehicleSeat") and seat.Steer < 0) then moveDir = moveDir - rightVector isMoving = true end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) or (seat:IsA("VehicleSeat") and seat.Steer > 0) then moveDir = moveDir + rightVector isMoving = true end
	else
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + forwardVector isMoving = true end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - forwardVector isMoving = true end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - rightVector isMoving = true end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + rightVector isMoving = true end

		local hum = character and character:FindFirstChildOfClass("Humanoid")
		if not isMoving and hum and hum.MoveDirection.Magnitude > 0.1 then
			local rawDir = hum.MoveDirection
			local flatForward = Vector3.new(forwardVector.X, 0, forwardVector.Z).Unit
			local flatRight = Vector3.new(rightVector.X, 0, rightVector.Z).Unit
			
			local relativeForward = rawDir:Dot(flatForward)
			local relativeRight = rawDir:Dot(flatRight)
			
			moveDir = (forwardVector * relativeForward + rightVector * relativeRight)
			isMoving = true
		end
	end

	local finalVel = Vector3.zero
	if isMoving and moveDir.Magnitude > 0 then
		finalVel = moveDir.Unit * realSpeed
	end

	if moveUp or UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		finalVel = Vector3.new(finalVel.X, realSpeed, finalVel.Z)
	elseif moveDown or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
		finalVel = Vector3.new(finalVel.X, -realSpeed, finalVel.Z)
	end

	-- 寫入最強物理控制
	flyForce.VectorVelocity = finalVel
	alignOrient.CFrame = cameraCF
end)

---------------------------------------------------
-- UI 拖曳 logic
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
