-- =============================================================================
-- FlyGui V3 完美修復版：解決「按停止時人會從車上脫離」的問題
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
screenGui.Name = "UltraFlyGuiV3_NoSeatEjectFixed"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui
 
---------------------------------------------------
-- UI 介面 (所有按鈕完好如初)
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
titleBar.Text = "UltraSelf! Fly V3μΩ"
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
flyButton.Name = "MyScriptButton"
flyButton.Size = UDim2.new(0.25, 0, 0.5, 0)
flyButton.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
flyButton.Position = UDim2.new(0.75, 0, 0.5, 0)
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.Text = "Fly"
flyButton.Parent = mainFrame

local upButton = Instance.new("TextButton")
upButton.Name = "MyScriptButton"
upButton.Size = UDim2.new(0.25, 0, 0.5, 0)
upButton.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
upButton.Position = UDim2.new(0, 0, 0, 0)
upButton.TextColor3 = Color3.fromRGB(255, 255, 255)
upButton.Text = "Up"
upButton.Parent = mainFrame

local downButton = Instance.new("TextButton")
downButton.Name = "MyScriptButton"
downButton.Size = UDim2.new(0.25, 0, 0.5, 0)
downButton.BackgroundColor3 = Color3.fromRGB(80, 40, 180)
downButton.Position = UDim2.new(0, 0, 0.5, 0)
downButton.TextColor3 = Color3.fromRGB(255, 255, 255)
downButton.Text = "Down"
downButton.Parent = mainFrame

local flyupButton = Instance.new("TextButton")
flyupButton.Name = "MyScriptButton"
flyupButton.Size = UDim2.new(0.25, 0, 0.5, 0)
flyupButton.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
flyupButton.Position = UDim2.new(0.25, 0, 0, 0)
flyupButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyupButton.Text = "+"
flyupButton.Parent = mainFrame

local flydownButton = Instance.new("TextButton")
flydownButton.Name = "MyScriptButton"
flydownButton.Size = UDim2.new(0.25, 0, 0.5, 0)
flydownButton.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
flydownButton.Position = UDim2.new(0.25, 0, 0.5, 0)
flydownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flydownButton.Text = "-"
flydownButton.Parent = mainFrame
 
local closeButton = Instance.new("TextButton")
closeButton.Name = "MyScriptButton"
closeButton.Size = UDim2.new(0, 50, 0, 30)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Position = UDim2.new(0, 0, -0.5, 0)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Text = "X"
closeButton.Parent = mainFrame

local smallButton = Instance.new("TextButton")
smallButton.Name = "MyScriptButton"
smallButton.Size = UDim2.new(0, 50, 0, 30)
smallButton.BackgroundColor3 = Color3.fromRGB(220, 100, 0)
smallButton.Position = UDim2.new(0.25, 0, -0.5, 0)
smallButton.TextColor3 = Color3.fromRGB(255, 255, 255)
smallButton.Text = "_"
smallButton.Parent = mainFrame
 
---------------------------------------------------
-- 工具探測函數
---------------------------------------------------
local function getPlayerTorso()
	if not character then return nil end
	return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
end

local function getVehicleSeat()
	if not character then return nil end
	local hum = character:FindFirstChildOfClass("Humanoid")
	if hum and hum.SeatPart then
		return hum.SeatPart
	end
	return nil
end

---------------------------------------------------
-- 🛠️ 核心關閉飛行（🌟 徹底修復：按停止不脫離座位）
---------------------------------------------------
local function disableFly()
	isFlying = false
	moveUp = false
	moveDown = false
	upButton.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
	downButton.BackgroundColor3 = Color3.fromRGB(80, 40, 180)
	flyButton.Text = "Fly"
	flyButton.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
	
	local seat = getVehicleSeat()
	local torso = getPlayerTorso()
	
	-- 1. 清除車座上的飛行物理力
	if seat then
		local bv = seat:FindFirstChild("FlyVelocity")
		if bv then bv:Destroy() end
		local bg = seat:FindFirstChild("FlyGyro")
		if bg then bg:Destroy() end
	end
	
	-- 2. 清除人體上的飛行物理力
	if torso then
		local bv = torso:FindFirstChild("FlyVelocity")
		if bv then bv:Destroy() end
		local bg = torso:FindFirstChild("FlyGyro")
		if bg then bg:Destroy() end
	end
	
	-- 3. 🌟 【關鍵修復】防止解除 PlatformStand 時人被彈出座位
	if character then
		local hum = character:FindFirstChildOfClass("Humanoid")
		if hum then 
			hum.PlatformStand = false
			-- 如果原本就在車上，強力鎖定讓人「坐好」，絕對不觸發跳出
			if seat then
				task.wait(0.02)
				seat:Sit(hum) 
			else
				-- 走路飛行解除時才給 Freefall 落地
				hum:ChangeState(Enum.HumanoidStateType.Freefall)
			end
		end
	end
end

---------------------------------------------------
-- 🛠️ 啟用飛行物理主推力
---------------------------------------------------
local function applyPhysics(target)
	if not target then return end
	if target:FindFirstChild("FlyGyro") then target.FlyGyro:Destroy() end
	if target:FindFirstChild("FlyVelocity") then target.FlyVelocity:Destroy() end
	
	local bg = Instance.new("BodyGyro")
	bg.Name = "FlyGyro"
	bg.P = 1e5
	bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
	bg.cframe = camera.CoordinateFrame
	bg.Parent = target
	
	local bv = Instance.new("BodyVelocity")
	bv.Name = "FlyVelocity"
	bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
	bv.velocity = Vector3.new(0, 0.1, 0)
	bv.Parent = target
end

flyButton.MouseButton1Click:Connect(function()
	isFlying = not isFlying
	if isFlying then
		flyButton.Text = "Stop"
		flyButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
		
		local seat = getVehicleSeat()
		local hum = character:FindFirstChildOfClass("Humanoid")
		
		-- 🌟 坐在車上飛行時，絕對不要開啟 PlatformStand，否則會破壞座位銲接
		if hum and not seat then 
			hum.PlatformStand = true 
		end
		
		if seat then applyPhysics(seat) else applyPhysics(getPlayerTorso()) end
	else
		disableFly()
	end
end)
 
-- 速度調整
flyupButton.MouseButton1Click:Connect(function() speed = speed + 1 contentText.Text = tostring(speed) end)
flydownButton.MouseButton1Click:Connect(function() speed = math.max(speed - 1, 1) contentText.Text = tostring(speed) end)
 
-- 高度調整
upButton.InputBegan:Connect(function(input) if isFlying and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then moveUp = true upButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) end end)
upButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then moveUp = false upButton.BackgroundColor3 = Color3.fromRGB(100, 60, 200) end end)
downButton.InputBegan:Connect(function(input) if isFlying and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then moveDown = true downButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) end end)
downButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then moveDown = false downButton.BackgroundColor3 = Color3.fromRGB(80, 40, 180) end end)
				
-- 縮小
local isMinimized = false
smallButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	for _, child in ipairs(mainFrame:GetChildren()) do
		if child ~= smallButton and child ~= titleBar and child ~= closeButton then child.Visible = not isMinimized end
	end
	if isMinimized then mainFrame.Size = UDim2.new(0, 200, 0, 30) smallButton.Text = "[]" else mainFrame.Size = UDim2.new(0, 200, 0, 60) smallButton.Text = "_" end
end)

-- 關閉
closeButton.MouseButton1Click:Connect(function() disableFly() screenGui:Destroy() end)
				
---------------------------------------------------
-- 🛠 核心物理循環
---------------------------------------------------
RunService.RenderStepped:Connect(function()
	if isFlying then
		local seat = getVehicleSeat()
		local torso = getPlayerTorso()
		
		-- 車子飛行邏輯
		if seat then
			local bg = seat:FindFirstChild("FlyGyro")
			local bv = seat:FindFirstChild("FlyVelocity")
			if not bg or not bv then return end
			
			local cameraLook = camera.CoordinateFrame.LookVector
			local cameraRight = camera.CoordinateFrame.RightVector
			local isMoving = false
			local customMoveDir = Vector3.new(0,0,0)
			
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then customMoveDir = customMoveDir + cameraLook isMoving = true end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then customMoveDir = customMoveDir - cameraLook isMoving = true end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then customMoveDir = customMoveDir - cameraRight isMoving = true end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then customMoveDir = customMoveDir + cameraRight isMoving = true end
			
			local hum = character:FindFirstChildOfClass("Humanoid")
			if not isMoving and hum and hum.MoveDirection.Magnitude > 0 then
				local forwardProj = hum.MoveDirection:Dot(camera.CoordinateFrame.RightVector:Cross(Vector3.new(0,1,0)))
				local rightProj = hum.MoveDirection:Dot(camera.CoordinateFrame.RightVector)
				customMoveDir = -(cameraLook * forwardProj) + (cameraRight * rightProj)
				isMoving = true
			end
			
			local flyVelocity = Vector3.new(0, 0.1, 0)
			if isMoving and customMoveDir.Magnitude > 0 then
				flyVelocity = customMoveDir.Unit * (speed * 50)
			end
			
			if moveUp then flyVelocity = flyVelocity + Vector3.new(0, (speed * 30) + 30, 0)
			elseif moveDown then flyVelocity = flyVelocity + Vector3.new(0, -((speed * 30) + 30), 0) end
			
			bv.velocity = flyVelocity
			bg.cframe = camera.CoordinateFrame
			
		-- 走路人體飛行邏輯
		elseif torso then
			local bg = torso:FindFirstChild("FlyGyro")
			local bv = torso:FindFirstChild("FlyVelocity")
			if not bg or not bv then return end
			
			local cameraLook = camera.CoordinateFrame.LookVector
			local cameraRight = camera.CoordinateFrame.RightVector
			local isMoving = false
			local customMoveDir = Vector3.new(0,0,0)
			
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then customMoveDir = customMoveDir + cameraLook isMoving = true end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then customMoveDir = customMoveDir - cameraLook isMoving = true end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then customMoveDir = customMoveDir - cameraRight isMoving = true end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then customMoveDir = customMoveDir + cameraRight isMoving = true end
			
			local hum = character:FindFirstChildOfClass("Humanoid")
			if not isMoving and hum and hum.MoveDirection.Magnitude > 0 then
				local forwardProj = hum.MoveDirection:Dot(camera.CoordinateFrame.RightVector:Cross(Vector3.new(0,1,0)))
				local rightProj = hum.MoveDirection:Dot(camera.CoordinateFrame.RightVector)
				customMoveDir = -(cameraLook * forwardProj) + (cameraRight * rightProj)
				isMoving = true
			end
			
			local flyVelocity = Vector3.new(0, 0.1, 0)
			if isMoving and customMoveDir.Magnitude > 0 then
				flyVelocity = customMoveDir.Unit * (speed * 60)
			end
			
			if moveUp then flyVelocity = flyVelocity + Vector3.new(0, (speed * 40) + 50, 0)
			elseif moveDown then flyVelocity = flyVelocity + Vector3.new(0, -((speed * 40) + 50), 0) end
			
			bv.velocity = flyVelocity
			bg.cframe = camera.CoordinateFrame
			
			if character then
				for _, part in ipairs(character:GetChildren()) do
					if part:IsA("BasePart") then
						part.Velocity = flyVelocity
						part.RotVelocity = Vector3.new(0,0,0)
					end
				end
			end
		end
	end
end)
				
---------------------------------------------------
-- 絲滑拖曳邏輯
---------------------------------------------------
local dragging = false
local dragStart = nil
local startPos = nil

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local guiObjects = playerGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
		local clickedTitleBar = false
		for _, obj in pairs(guiObjects) do if obj == titleBar then clickedTitleBar = true break end end
		if not clickedTitleBar then return end
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		local connection
		connection = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false connection:Disconnect() end
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
