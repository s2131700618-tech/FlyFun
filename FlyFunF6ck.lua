-- 先行定義基礎變數
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
 
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
 
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    rootPart = newCharacter:WaitForChild("HumanoidRootPart")
end)
 
-- 飛行控制變數
local isFlying = false
local speed = 1 -- 無辜的 1
 
-- 建立物理移動物件
local bodyVelocity = Instance.new("BodyVelocity")
local bodyGyro = Instance.new("BodyGyro")
bodyGyro.D = 10
bodyGyro.P = 3000
 
-- 建立 ScreenGui 容器
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UltraFlyGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")
 
---------------------------------------------------
-- UI 介面程式碼
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
titleBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
titleBar.BorderSizePixel = 0
titleBar.Text = "Ultra Fly V1.0"
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
flyupButton.Size = UDim2.new(0.25, 0, 0.05 * 10) -- 修正原先排版
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
closeButton.Size = UDim2.new(0.25, 0, 0.5, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeButton.Position = UDim2.new(0, 0, -0.5, 0)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Text = "X"
closeButton.Parent = mainFrame

local smallButton = Instance.new("TextButton")
smallButton.Name = "MyScriptButton"
smallButton.Size = UDim2.new(0.25, 0, 0.5, 0)
smallButton.BackgroundColor3 = Color3.fromRGB(255, 0, 64)
smallButton.Position = UDim2.new(0.25, 0, -0.5, 0)
smallButton.TextColor3 = Color3.fromRGB(255, 255, 255)
smallButton.Text = "_"
smallButton.Parent = mainFrame
 
---------------------------------------------------
-- 底層輸入偵測（支援載具、手機搖桿與鍵盤）
---------------------------------------------------
local moveStatus = { Forward = 0, Backward = 0, Left = 0, Right = 0 }
local moveUp = false
local moveDown = false

-- 監聽鍵盤
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.W then moveStatus.Forward = 1
    elseif input.KeyCode == Enum.KeyCode.S then moveStatus.Backward = 1
    elseif input.KeyCode == Enum.KeyCode.A then moveStatus.Left = 1
    elseif input.KeyCode == Enum.KeyCode.D then moveStatus.Right = 1
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then moveStatus.Forward = 0
    elseif input.KeyCode == Enum.KeyCode.S then moveStatus.Backward = 0
    elseif input.KeyCode == Enum.KeyCode.A then moveStatus.Left = 0
    elseif input.KeyCode == Enum.KeyCode.D then moveStatus.Right = 0
    end
end)

-- 取得目前的目標移動向量（結合手機搖桿底層與鍵盤輸入）
local function getActiveMoveDirection()
    -- 先檢查角色目前的 Humanoid（防禦性抓取）
    local hum = character:FindFirstChildOfClass("Humanoid")
    if hum and hum.MoveDirection.Magnitude > 0 then
        return hum.MoveDirection
    end
    
    -- 如果在車上，手動用底層鍵盤狀態計算方向
    local cameraCFrame = camera.CFrame
    local forward = Vector3.new(cameraCFrame.LookVector.X, 0, cameraCFrame.LookVector.Z).Unit
    local right = Vector3.new(cameraCFrame.RightVector.X, 0, cameraCFrame.RightVector.Z).Unit
    
    local dir = Vector3.new(0, 0, 0)
    if moveStatus.Forward == 1 then dir = dir + forward end
    if moveStatus.Backward == 1 then dir = dir - forward end
    if moveStatus.Right == 1 then dir = dir + right end
    if moveStatus.Left == 1 then dir = dir - right end
    
    return dir.Magnitude > 0 and dir.Unit or Vector3.new(0, 0, 0)
end

---------------------------------------------------
-- 飛行開關邏輯
---------------------------------------------------
local function disableFly()
    isFlying = false
    flyButton.Text = "Fly"
    flyButton.BackgroundColor3 = Color3.fromRGB(255, 128, 64)
    local hum = character:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
    bodyVelocity.Parent = nil
    bodyGyro.Parent = nil
end
 
local function getTargetRoot()
    -- ✨ 核心修正：如果玩家坐在車上，我們直接讓「整台車（Seat）」一起飛！
    local hum = character:FindFirstChildOfClass("Humanoid")
    if hum whistle and hum.SeatPart then
        return hum.SeatPart
    end
    return character:FindFirstChild("HumanoidRootPart")
end

flyButton.MouseButton1Click:Connect(function()
    local targetRoot = getTargetRoot()
    if not targetRoot then return end
    isFlying = not isFlying
    
    if isFlying then
        local hum = character:FindFirstChildOfClass("Humanoid")
        flyButton.Text = "Stop"
        flyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        if hum then hum:ChangeState(Enum.HumanoidStateType.Physics) end
        
        bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = targetRoot
        
        bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
        bodyGyro.CFrame = targetRoot.CFrame
        bodyGyro.Parent = targetRoot
    else
        disableFly()
    end
end)
 
flyupButton.MouseButton1Click:Connect(function()
    speed = speed + 1
    contentText.Text = tostring(speed)
end)
 
flydownButton.MouseButton1Click:Connect(function()
    speed = math.max(speed - 1, 1)
    contentText.Text = tostring(speed)
end)
 
upButton.MouseButton1Down:Connect(function() moveUp = true end)
upButton.MouseButton1Up:Connect(function() moveUp = false end)
downButton.MouseButton1Down:Connect(function() moveDown = true end)
downButton.MouseButton1Up:Connect(function() moveDown = false end)
                
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
    else
        mainFrame.Size = UDim2.new(0, 200, 0, 60)
        smallButton.Text = "_"
    end
end)
                
closeButton.MouseButton1Click:Connect(function()
    disableFly()
    screenGui:Destroy()
end)
                
-- 每幀強力更新
RunService.RenderStepped:Connect(function()
    if isFlying then
        local targetRoot = getTargetRoot()
        if not targetRoot then return end
        
        -- 確保物理移動物件一直綁在正確的目標（人或車）上
        if bodyVelocity.Parent ~= targetRoot then bodyVelocity.Parent = targetRoot end
        if bodyGyro.Parent ~= targetRoot then bodyGyro.Parent = targetRoot end
        
        local moveDirection = getActiveMoveDirection()
        local velocity = Vector3.new(0, 0, 0)
        
        if moveDirection.Magnitude > 0 then
            local cameraCFrame = camera.CFrame
            local look = cameraCFrame.LookVector
            local right = cameraCFrame.RightVector
            
            local forwardProj = Vector3.new(look.X, 0, look.Z).Unit
            local rightProj = Vector3.new(right.X, 0, right.Z).Unit
            
            local forwardAmount = moveDirection:Dot(forwardProj)
            local rightAmount = moveDirection:Dot(rightProj)
            
            -- 看哪裡就飛哪裡（速度乘 50 倍）
            local true3DDirection = (look * forwardAmount) + (right * rightAmount)
            if true3DDirection.Magnitude > 0 then
                velocity = true3DDirection.Unit * (speed * 50)
            end
        end
        
        -- 獨立的 UI 按鈕高度控制
        if moveUp then
            velocity = velocity + Vector3.new(0, speed * 50, 0)
        elseif moveDown then
            velocity = velocity + Vector3.new(0, -speed * 50, 0)
        end
        
        bodyVelocity.Velocity = velocity
        
        -- 保持載具或人水平平衡，並朝向鏡頭前方
        local lookAt = camera.CFrame.LookVector
        bodyGyro.CFrame = CFrame.new(targetRoot.Position, targetRoot.Position + Vector3.new(lookAt.X, 0, lookAt.Z))
    end
end)
                
---------------------------------------------------
-- ✨ 終極修正：專為行動裝置設計的「不鎖死、不消失」拖曳功能
---------------------------------------------------
local dragToggle = false
local dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- 當手指或滑鼠放開時（不論在哪放開），一律解除拖曳鎖定
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = false
    end
end)
