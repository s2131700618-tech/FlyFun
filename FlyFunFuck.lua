-- =============================================================================
-- FlyGui V5.3 (UI 語法修復 + 1 顯示 = 50 速度 + 車輛不下車保護)
-- =============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
 
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera
local character = player.Character or player.CharacterAdded:Wait()

player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
end)
 
local isFlying = false
local speed = 1 -- 預設數字顯示為 1
local moveUp = false
local moveDown = false
 
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UltraFlyGuiV5_FixUI"
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
titleBar.Text = "FlyGui V3.5ΩF"
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.TextXAlignment = Enum.TextXAlignment.Left
titleBar.Font = Enum.Font.SourceSansBold
titleBar.TextSize = 14
titleBar.Active = true 
titleBar.Parent = mainFrame
 
local contentText = Instance.new("TextLabel")
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
flyButton.Size = UDim2.new(0.25, 0, 0.5, 0)
flyButton.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
flyButton.Position = UDim2.new(0.75, 0, 0.5, 0)
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.Text = "Fly"
flyButton.Parent = mainFrame

local upButton = Instance.new("TextButton")
upButton.Size = UDim2.new(0.25, 0, 0.5, 0)
upButton.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
upButton.Position = UDim2.new(0, 0, 0, 0)
upButton.TextColor3 = Color3.fromRGB(255, 255, 255)
upButton.Text = "Up"
upButton.Parent = mainFrame

local downButton = Instance.new("TextButton")
downButton.Size = UDim2.new(0.25, 0, 0.5, 0)
downButton.BackgroundColor3 = Color3.fromRGB(80, 40, 180)
downButton.Position = UDim2.new(0, 0, 0.5, 0)
downButton.TextColor3 = Color3.fromRGB(255, 255, 255)
downButton.Text = "Down"
downButton.Parent = mainFrame

local flyupButton = Instance.new("TextButton")
flyupButton.Size = UDim2.new(0.25, 0, 0.5, 0)
flyupButton.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
flyupButton.Position = UDim2.new(0.25, 0, 0, 0)
flyupButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyupButton.Text = "+"
flyupButton.Parent = mainFrame

local flydownButton = Instance.new("TextButton")
flydownButton.Size = UDim2.new(0.25, 0, 0.5, 0)
flydownButton.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
flydownButton.Position = UDim2.new(0.25, 0, 0.5, 0)
flydownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flydownButton.Text = "-"
flydownButton.Parent = mainFrame
 
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 50, 0, 30)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Position = UDim2.new(0, 0, -0.5, 0)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Text = "X"
closeButton.Parent = mainFrame

local smallButton = Instance.new("TextButton")
smallButton.Size = UDim2.new(0, 50, 0, 30)
smallButton.BackgroundColor3 = Color3.fromRGB(220, 100, 0)
smallButton.Position = UDim2.new(0.25, 0, -0.5, 0)
smallButton.TextColor3 = Color3.fromRGB(255, 255, 255)
smallButton.Text = "_"
smallButton.Parent = mainFrame

---------------------------------------------------
-- 工具函數 (判斷控制標的)
---------------------------------------------------
local function getControlTarget()
	if not character then return nil, false end
	local hum = character:FindFirstChildOfClass("Humanoid")
	
	if hum and hum.SeatPart then
		local seat = hum.SeatPart
		local targetPart = seat.AssemblyRootPart or seat
		return targetPart, true
	end
	
	local root = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
	if root then
		return root.AssemblyRootPart or root, false
	end
	return nil, false
end

---------------------------------------------------
-- 🧼 關閉飛行
---------------------------------------------------
local function disableFly()
	isFlying = false
	moveUp = false
	moveDown = false
	upButton.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
	downButton.BackgroundColor3 = Color3.fromRGB(80, 40, 180)
	flyButton.Text = "Fly"
	flyButton.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
	
	local targetPart, isSitting = getControlTarget()
	
	if targetPart then
		local attach = targetPart:FindFirstChild("FlyAttachment")
		if attach then attach:Destroy() end
		local lv = targetPart:FindFirstChild("FlyLinearVelocity")
		if lv then lv:Destroy() end
		local align = targetPart:FindFirstChild("FlyAlignOrientation")
		if align then align:Destroy() end
	end
	
	-- 徒步時恢復，開車時不上彈起身，確保不脫離座椅
	if character and not isSitting then
		local hum = character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
			hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
			hum:SetStateEnabled(Enum.HumanoidStateType.Running, true)
			hum:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end
end

---------------------------------------------------
-- 🛠️ 啟用物理飛行
---------------------------------------------------
local function enableFly()
	local targetPart, isSitting = getControlTarget()
	if not targetPart then return end

	local oldAttach = targetPart:FindFirstChild("FlyAttachment")
	if oldAttach then oldAttach:Destroy() end
	local oldLv = targetPart:FindFirstChild("FlyLinearVelocity")
	if oldLv then oldLv:Destroy() end
	local oldAlign = targetPart:FindFirstChild("FlyAlignOrientation")
	if oldAlign then oldAlign:Destroy() end

	local attachment = Instance.new("Attachment")
	attachment.Name = "FlyAttachment"
	attachment.Parent = targetPart

	local flyForce = Instance.new("LinearVelocity")
	flyForce.Name = "FlyLinearVelocity"
	flyForce.MaxForce = math.huge
	flyForce.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	flyForce.RelativeTo = Enum.ActuatorRelativeTo.World
	flyForce.Attachment0 = attachment
	flyForce.VectorVelocity = Vector3.new(0, 0, 0)
	flyForce.Parent = targetPart

	local alignOrient = Instance.new("AlignOrientation")
	alignOrient.Name = "FlyAlignOrientation"
	alignOrient.MaxTorque = math.huge
	alignOrient.Responsiveness = 200
	alignOrient.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrient.Attachment0 = attachment
	alignOrient.CFrame = camera.CFrame
	alignOrient.Parent = targetPart

	if not isSitting then
		local hum = character:FindFirstChildOfClass("Humanoid")
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
-- UI 按鈕邏輯
---------------------------------------------------
flyButton.MouseButton1Click:Connect(function()
	isFlying = not isFlying
	if isFlying then
		flyButton.Text = "Stop"
		flyButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
		enableFly()
	else
		disableFly()
	end
end)

flyupButton.MouseButton1Click:Connect(function() speed = speed + 1 contentText.Text = tostring(speed) end)
flydownButton.MouseButton1Click:Connect(function() speed = math.max(speed - 1, 1) contentText.Text = tostring(speed) end)

upButton.InputBegan:Connect(function(input) if isFlying and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then moveUp = true upButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) end end)
upButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then moveUp = false upButton.BackgroundColor3 = Color3.fromRGB(100, 60, 200) end end)

-- 已修復原本崩潰的語法
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
-- 🛠 核心計算循環 (1 單位顯示 = 50 實體速度)
---------------------------------------------------
RunService.Heartbeat:Connect(function()
	if isFlying then
		local targetPart, isSitting = getControlTarget()
		if not targetPart then return end

		local flyForce = targetPart:FindFirstChild("FlyLinearVelocity")
		local alignOrient = targetPart:FindFirstChild("FlyAlignOrientation")
		
		if not flyForce or not alignOrient then
			enableFly()
			return
		end

		local hum = character:FindFirstChildOfClass("Humanoid")
		
		if not isSitting and hum then
			if hum:GetState() ~= Enum.HumanoidStateType.Swimming then
				hum:ChangeState(Enum.HumanoidStateType.Swimming)
			end
		end

		local cameraCF = camera.CFrame
		local forwardVector = cameraCF.LookVector
		local rightVector = cameraCF.RightVector
		
		local moveDir = Vector3.new(0, 0, 0)
		local isMoving = false

		-- PC 鍵盤
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + forwardVector isMoving = true end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - forwardVector isMoving = true end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - rightVector isMoving = true end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + rightVector isMoving = true end

		-- 車輛油門
		if isSitting and targetPart:IsA("VehicleSeat") then
			local seat = targetPart
			if seat.Throttle > 0 then moveDir = moveDir + forwardVector isMoving = true end
			if seat.Throttle < 0 then moveDir = moveDir - forwardVector isMoving = true end
			if seat.Steer < 0 then moveDir = moveDir - rightVector isMoving = true end
			if seat.Steer > 0 then moveDir = moveDir + rightVector isMoving = true end
		end

		-- 手機觸控搖桿
		if not isMoving and hum and hum.MoveDirection.Magnitude > 0.1 then
			local rawDir = hum.MoveDirection
			local flatForward = Vector3.new(forwardVector.X, 0, forwardVector.Z).Unit
			local flatRight = Vector3.new(rightVector.X, 0, rightVector.Z).Unit
			
			local relativeForward = rawDir:Dot(flatForward)
			local relativeRight = rawDir:Dot(flatRight)
			
			moveDir = (forwardVector * relativeForward + rightVector * relativeRight)
			isMoving = true
		end

		-- 設定：1 數字 = 50 飛天速度
		local realSpeed = speed * 50
		local finalVelocity = Vector3.new(0, 0, 0)

		if isMoving and moveDir.Magnitude > 0 then
			finalVelocity = moveDir.Unit * realSpeed
		end

		-- 上升 / 下降 (Up / Down)
		if moveUp or (UserInputService:IsKeyDown(Enum.KeyCode.Space)) then
			finalVelocity = Vector3.new(finalVelocity.X, realSpeed, finalVelocity.Z)
		elseif moveDown or (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)) then
			finalVelocity = Vector3.new(finalVelocity.X, -realSpeed, finalVelocity.Z)
		end

		flyForce.VectorVelocity = finalVelocity
		alignOrient.CFrame = cameraCF
	end
end)

---------------------------------------------------
-- UI 拖曳
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
