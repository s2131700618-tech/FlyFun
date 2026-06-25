-- 先行定義基礎變數
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
 
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera
local character = player.Character or player.CharacterAdded:Wait()

player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	task.wait(0.7)
	local hum = newCharacter:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.PlatformStand = false
		newCharacter.Animate.Disabled = false
	end
end)
 
local isFlying = false
local speed = 1
local moveUp = false
local moveDown = false
 
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UltraFlyGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui
 
---------------------------------------------------
-- UI 介面
---------------------------------------------------
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 60)
mainFrame.Position = UDim2.new(0.25, 0, 0.5, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true 
mainFrame.Parent = screenGui
 
local titleBar = Instance.new("TextLabel")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(0.5, 0, 0.5, 0)
titleBar.Position = UDim2.new(0.5, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
titleBar.BorderSizePixel = 0
titleBar.Text = "Ultra Fly V5.0Ω"
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.TextXAlignment = Enum.TextXAlignment.Left
titleBar.Font = Enum.Font.SourceSansBold
titleBar.TextSize = 14
titleBar.Active = true 
titleBar.Parent = mainFrame
 
local contentText = Instance.new("TextLabel")
contentText.Size = UDim2.new(0.25, 0, 0.5, 0)
contentText.Position = UDim2.new(0.5, 0, 0.5, 0)
contentText.BackgroundColor3 = Color3.fromRGB(64, 128, 255)
contentText.Text = tostring(speed)
contentText.TextColor3 = Color3.fromRGB(255, 255, 255)
contentText.TextWrapped = true
contentText.Font = Enum.Font.SourceSans
contentText.TextSize = 16
contentText.Parent = mainFrame
 
local flyButton = Instance.new("TextButton")
flyButton.Name = "MyScriptButton"
flyButton.Size = UDim2.new(0.25, 0, 0.5, 0)
flyButton.BackgroundColor3 = Color3.fromRGB(255, 128, 64)
flyButton.Position = UDim2.new(0.75, 0, 0.5, 0)
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.Text = "Fly"
flyButton.Parent = mainFrame

local upButton = Instance.new("TextButton")
upButton.Name = "MyScriptButton"
upButton.Size = UDim2.new(0.25, 0, 0.5, 0)
upButton.BackgroundColor3 = Color3.fromRGB(128, 64, 255)
upButton.Position = UDim2.new(0, 0, 0, 0)
upButton.TextColor3 = Color3.fromRGB(255, 255, 255)
upButton.Text = "Up"
upButton.Parent = mainFrame

local downButton = Instance.new("TextButton")
downButton.Name = "MyScriptButton"
downButton.Size = UDim2.new(0.25, 0, 0.5, 0)
downButton.BackgroundColor3 = Color3.fromRGB(128, 0, 255)
downButton.Position = UDim2.new(0, 0, 0.5, 0)
downButton.TextColor3 = Color3.fromRGB(255, 255, 255)
downButton.Text = "Down"
downButton.Parent = mainFrame

local flyupButton = Instance.new("TextButton")
flyupButton.Name = "MyScriptButton"
flyupButton.Size = UDim2.new(0.25, 0, 0.5, 0)
flyupButton.BackgroundColor3 = Color3.fromRGB(128, 255, 64)
flyupButton.Position = UDim2.new(0.25, 0, 0, 0)
flyupButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyupButton.Text = "+"
flyupButton.Parent = mainFrame

local flydownButton = Instance.new("TextButton")
flydownButton.Name = "MyScriptButton"
flydownButton.Size = UDim2.new(0.25, 0, 0.5, 0)
flydownButton.BackgroundColor3 = Color3.fromRGB(64, 255, 64)
flydownButton.Position = UDim2.new(0.25, 0, 0.5, 0)
flydownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flydownButton.Text = "-"
flydownButton.Parent = mainFrame
 
local closeButton = Instance.new("TextButton")
closeButton.Name = "MyScriptButton"
closeButton.Size = UDim2.new(0, 50, 0, 30)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeButton.Position = UDim2.new(0, 0, -0.5, 0)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Text = "X"
closeButton.Parent = mainFrame

local smallButton = Instance.new("TextButton")
smallButton.Name = "MyScriptButton"
smallButton.Size = UDim2.new(0, 50, 0, 30)
smallButton.BackgroundColor3 = Color3.fromRGB(255, 0, 64)
smallButton.Position = UDim2.new(0.25, 0, -0.5, 0)
smallButton.TextColor3 = Color3.fromRGB(255, 255, 255)
smallButton.Text = "_"
smallButton.Parent = mainFrame
 
---------------------------------------------------
-- 核心動力獲取
---------------------------------------------------
local function getPlayerTorso()
	if not character then return nil end
	return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
end

local function getVehiclePart()
	if not character then return nil end
	local hum = character:FindFirstChildOfClass("Humanoid")
	if hum and hum.SeatPart then
		return hum.SeatPart
	end
	return nil
end

local function disableFly()
	isFlying = false
	moveUp = false
	moveDown = false
	upButton.BackgroundColor3 = Color3.fromRGB(128, 64, 255)
	downButton.BackgroundColor3 = Color3.fromRGB(128, 0, 255)
	flyButton.Text = "Fly"
	flyButton.BackgroundColor3 = Color3.fromRGB(255, 128, 64)
	
	local seat = getVehiclePart()
	local torso = getPlayerTorso()
	
	-- 🌟【精準重置車子物理】
	if seat and seat:IsA("BasePart") then
		seat.RotVelocity = Vector3.new(0, 0, 0)
		local root = seat:GetRootPart()
		if root then
			root.RotVelocity = Vector3.new(0, 0, 0)
		end
		
		-- 🎯 只刪除車子身上的飛行組件
		local bv = seat:FindFirstChild("FlyVelocity")
		if bv then bv:Destroy() end
		local bg = seat:FindFirstChild("FlyGyro")
		if bg then bg:Destroy() end
	end
	
	-- 🌟【精準重置角色物理】
	if torso and torso:IsA("BasePart") then
		torso.RotVelocity = Vector3.new(0, 0, 0)
		
		-- 🎯 只刪除人身上的飛行組件
		local bv = torso:FindFirstChild("FlyVelocity")
		if bv then bv:Destroy() end
		local bg = torso:FindFirstChild("FlyGyro")
		if bg then bg:Destroy() end
	end
	
	-- ❌ 【徹底刪除！】原本的 workspace:GetDescendants() 迴圈被我們拔掉了
	-- 這樣就不會在大地圖中造成任何瞬間卡頓！

	-- 🌟【絲滑降落】：延遲一影格再讓動畫與物理交接，防止拉扯鏡頭
	task.defer(function()
		if character then
			local hum = character:FindFirstChildOfClass("Humanoid")
			if hum then hum.PlatformStand = false end
			if character:FindFirstChild("Animate") then character.Animate.Disabled = false end
		end
	end)
end

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
		flyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
		
		local hum = character:FindFirstChildOfClass("Humanoid")
		if hum then 
			for _, track in next, hum:GetPlayingAnimationTracks() do
				track:AdjustSpeed(0)
			end
		end
		if character:FindFirstChild("Animate") then character.Animate.Disabled = true end
		
		local seat = getVehiclePart()
		if seat then applyPhysics(seat) else applyPhysics(getPlayerTorso()) end
	else
		disableFly()
	end
end)
 
flyupButton.MouseButton1Click:Connect(function() speed = speed + 1 contentText.Text = tostring(speed) end)
flydownButton.MouseButton1Click:Connect(function() speed = math.max(speed - 1, 1) contentText.Text = tostring(speed) end)
 
-- Up/Down 按鈕狀態
upButton.InputBegan:Connect(function(input) if isFlying and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then moveUp = true upButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) end end)
upButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then moveUp = false upButton.BackgroundColor3 = Color3.fromRGB(128, 64, 255) end end)
downButton.InputBegan:Connect(function(input) if isFlying and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then moveDown = true downButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) end end)
downButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then moveDown = false downButton.BackgroundColor3 = Color3.fromRGB(128, 0, 255) end end)
				
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
-- 🛠️ 核心飛行物理循環
---------------------------------------------------
RunService.RenderStepped:Connect(function()
	if isFlying then
		local seat = getVehiclePart()
		local torso = getPlayerTorso()
		local target = seat or torso
		if not target then return end
		
		local bg = target:FindFirstChild("FlyGyro") or Instance.new("BodyGyro", target)
		local bv = target:FindFirstChild("FlyVelocity") or Instance.new("BodyVelocity", target)
		
		local cameraLook = camera.CoordinateFrame.LookVector
		local cameraRight = camera.CoordinateFrame.RightVector
		
		local isMoving = false
		local customMoveDir = Vector3.new(0,0,0)
		
		-- 1. 鍵盤輸入修正 (W變前進、A變左轉)
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then customMoveDir = customMoveDir + cameraLook isMoving = true end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then customMoveDir = customMoveDir - cameraLook isMoving = true end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then customMoveDir = customMoveDir - cameraRight isMoving = true end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then customMoveDir = customMoveDir + cameraRight isMoving = true end
		
		-- 2. 手機虛擬搖桿支援
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
		
		-- 絕對世界高度修正
		if moveUp then
			flyVelocity = flyVelocity + Vector3.new(0, (speed * 40) + 50, 0)
		elseif moveDown then
			flyVelocity = flyVelocity + Vector3.new(0, -((speed * 40) + 50), 0)
		end
		
		bv.velocity = flyVelocity
		bg.cframe = camera.CoordinateFrame
		
		if seat then
			seat.Velocity = flyVelocity
			seat.RotVelocity = Vector3.new(0,0,0)
			local root = seat:GetRootPart()
			if root and root ~= seat then
				root.Velocity = flyVelocity
				root.RotVelocity = Vector3.new(0,0,0)
			end
		end
	end
end)
				
---------------------------------------------------
-- 🛠️ 完美的絲滑拖曳邏輯 (已移除錯字 vibrancy)
---------------------------------------------------
local dragging = false
local dragStart = nil
local startPos = nil

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local guiObjects = playerGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
		local clickedTitleBar = false
		
		for _, obj in pairs(guiObjects) do
			if obj == titleBar then
				clickedTitleBar = true
				break
			end
		end
		
		if not clickedTitleBar then return end
		
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		
		local connection
		connection = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				connection:Disconnect()
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		if dragging and dragStart and startPos then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(
				startPos.X.Scale, 
				startPos.X.Offset + delta.X, 
				startPos.Y.Scale, 
				startPos.Y.Offset + delta.Y
			)
		end
	end
end)
