local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Dọn dẹp các bản cũ
getgenv().AutoFishV7 = false
getgenv().AutoFishV8 = false
if getgenv().PU_KeyConnection then
    pcall(function() getgenv().PU_KeyConnection:Disconnect() end)
end
for _, name in ipairs({"PU_AutoFishMini", "PU_AutoFishV7", "PU_AutoFishV8"}) do
    if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
    if PlayerGui:FindFirstChild(name) then PlayerGui[name]:Destroy() end
end

local CurrentKey = Enum.KeyCode.K
local IsBindingKey = false
local IsMinimized = false

-- ================= GIAO DIỆN LIGHTWEIGHT (SIÊU NHẸ) =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PU_AutoFishV8"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = PlayerGui end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 140)
MainFrame.Position = UDim2.new(0.5, -130, 0.03, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 1.5
UIStroke.Color = Color3.fromRGB(255, 170, 40)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 34)
Header.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
Header.BorderSizePixel = 0
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(0, 12, 0.5, -4)
StatusDot.BackgroundColor3 = Color3.fromRGB(230, 65, 65)
StatusDot.Parent = Header
Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1, 0)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -65, 1, 0)
Title.Position = UDim2.new(0, 28, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Pet Universe • Lite Bot"
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(1, -30, 0.5, -12)
MinBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 52)
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 12
MinBtn.Parent = Header
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -34)
Content.Position = UDim2.new(0, 0, 0, 34)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -24, 0, 42)
ToggleBtn.Position = UDim2.new(0, 12, 0, 10)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(190, 45, 55)
ToggleBtn.Text = "TRẠNG THÁI: ĐANG TẮT"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 13
ToggleBtn.Parent = Content
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)

local KeyRow = Instance.new("Frame")
KeyRow.Size = UDim2.new(1, -24, 0, 34)
KeyRow.Position = UDim2.new(0, 12, 0, 60)
KeyRow.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
KeyRow.BorderSizePixel = 0
KeyRow.Parent = Content
Instance.new("UICorner", KeyRow).CornerRadius = UDim.new(0, 8)

local KeyLabel = Instance.new("TextLabel")
KeyLabel.Size = UDim2.new(0.55, 0, 1, 0)
KeyLabel.Position = UDim2.new(0, 10, 0, 0)
KeyLabel.BackgroundTransparency = 1
KeyLabel.Text = "Phím kích hoạt:"
KeyLabel.TextColor3 = Color3.fromRGB(175, 175, 190)
KeyLabel.Font = Enum.Font.GothamMedium
KeyLabel.TextSize = 12
KeyLabel.TextXAlignment = Enum.TextXAlignment.Left
KeyLabel.Parent = KeyRow

local KeybindBtn = Instance.new("TextButton")
KeybindBtn.Size = UDim2.new(0.42, -6, 0, 24)
KeybindBtn.Position = UDim2.new(0.58, 0, 0.5, -12)
KeybindBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 62)
KeybindBtn.Text = "[ " .. CurrentKey.Name .. " ]"
KeybindBtn.TextColor3 = Color3.fromRGB(255, 205, 70)
KeybindBtn.Font = Enum.Font.GothamBold
KeybindBtn.TextSize = 12
KeybindBtn.Parent = KeyRow
Instance.new("UICorner", KeybindBtn).CornerRadius = UDim.new(0, 6)

-- ================= THUẬT TOÁN NHẸ & TỐI ƯU HÓA CPU =================
local StaticSnapshot = {}
local LastClickedPos = Vector2.new(-999, -999)
local LastClickTime = 0

local function HasVisibleText(obj)
    if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and obj.Visible and obj.Text ~= "" then
        return true
    end
    for _, child in ipairs(obj:GetDescendants()) do
        if (child:IsA("TextLabel") or child:IsA("TextButton")) and child.Visible and child.Text ~= "" then
            return true
        end
    end
    return false
end

local function IsInsideGridOrList(obj)
    local parent = obj.Parent
    while parent and parent ~= PlayerGui do
        if parent:FindFirstChildWhichIsA("UIGridStyleLayout") or parent:IsA("ScrollingFrame") then
            return true
        end
        parent = parent.Parent
    end
    return false
end

local function IsActuallyVisible(obj)
    if not obj:IsA("GuiObject") or not obj.Visible then return false end
    if obj:IsDescendantOf(ScreenGui) then return false end
    
    local parent = obj.Parent
    while parent and parent ~= PlayerGui do
        if parent:IsA("GuiObject") and not parent.Visible then return false end
        if parent:IsA("ScreenGui") and not parent.Enabled then return false end
        parent = parent.Parent
    end
    return true
end

local function TakeStaticSnapshot()
    table.clear(StaticSnapshot)
    for _, obj in ipairs(PlayerGui:GetDescendants()) do
        if obj:IsA("GuiObject") and IsActuallyVisible(obj) then
            StaticSnapshot[obj] = obj.AbsolutePosition
        end
    end
end

local function IsValidHandCircle(obj)
    if not IsActuallyVisible(obj) then return false end
    if IsInsideGridOrList(obj) then return false end
    
    local size = obj.AbsoluteSize
    if size.X < 48 or size.X > 170 or size.Y < 48 or size.Y > 170 then return false end
    if math.abs(size.X - size.Y) > 20 then return false end
    if HasVisibleText(obj) then return false end
    
    local oldPos = StaticSnapshot[obj]
    if oldPos and (obj.AbsolutePosition - oldPos).Magnitude < 8 then
        return false
    end
    
    if not (obj:IsA("ImageButton") or obj:IsA("ImageLabel") or obj:FindFirstChildWhichIsA("ImageLabel", true) or obj:FindFirstChildWhichIsA("ImageButton", true)) then
        return false
    end

    return true
end

local function ClickCircle(target)
    local inset = GuiService:GetGuiInset()
    local pos = target.AbsolutePosition
    local size = target.AbsoluteSize
    local center = Vector2.new(pos.X + size.X / 2, pos.Y + size.Y / 2)
    
    if (center - LastClickedPos).Magnitude < 25 and (tick() - LastClickTime) < 0.4 then
        return false
    end
    
    LastClickedPos = center
    LastClickTime = tick()
    
    task.wait(0.04)
    if not getgenv().AutoFishV8 or not IsActuallyVisible(target) then return false end
    
    pos = target.AbsolutePosition
    size = target.AbsoluteSize
    local clickX = pos.X + (size.X / 2)
    local clickY = pos.Y + (size.Y / 2) + inset.Y
    
    local btn = target:IsA("GuiButton") and target or target:FindFirstChildWhichIsA("GuiButton", true) or (target.Parent and target.Parent:IsA("GuiButton") and target.Parent)
    if btn then
        pcall(function()
            if firesignal then
                firesignal(btn.MouseButton1Click)
                firesignal(btn.Activated)
            elseif getconnections then
                for _, c in pairs(getconnections(btn.MouseButton1Click)) do c:Fire() end
            end
        end)
    end
    
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
        task.wait(0.02)
        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)
    end)
    
    return true
end

local function StartLoop()
    TakeStaticSnapshot()
    task.spawn(function()
        while getgenv().AutoFishV8 do
            pcall(function()
                for _, obj in ipairs(PlayerGui:GetDescendants()) do
                    if not getgenv().AutoFishV8 then break end
                    if IsValidHandCircle(obj) then
                        if ClickCircle(obj) then
                            task.wait(0.1)
                            break
                        end
                    end
                end
            end)
            -- TĂNG THỜI GIAN CHỜ LÊN 0.1S ĐỂ GIẢM ẢNH HƯỞNG CPU CHO MÁY YẾU
            task.wait(0.1)
        end
    end)
end

local function UpdateToggleUI()
    local targetColor = getgenv().AutoFishV8 and Color3.fromRGB(35, 165, 85) or Color3.fromRGB(190, 45, 55)
    local dotColor = getgenv().AutoFishV8 and Color3.fromRGB(60, 240, 120) or Color3.fromRGB(230, 65, 65)
    
    ToggleBtn.BackgroundColor3 = targetColor
    StatusDot.BackgroundColor3 = dotColor
    
    if getgenv().AutoFishV8 then
        ToggleBtn.Text = "TRẠNG THÁI: ĐANG BẬT (" .. CurrentKey.Name .. ")"
    else
        ToggleBtn.Text = "TRẠNG THÁI: ĐANG TẮT (" .. CurrentKey.Name .. ")"
    end
end

local function ToggleAutoFish()
    if IsBindingKey then return end
    getgenv().AutoFishV8 = not getgenv().AutoFishV8
    UpdateToggleUI()
    if getgenv().AutoFishV8 then
        StartLoop()
    end
end

ToggleBtn.MouseButton1Click:Connect(ToggleAutoFish)

KeybindBtn.MouseButton1Click:Connect(function()
    IsBindingKey = true
    KeybindBtn.Text = "Nhấn phím..."
end)

MinBtn.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    MinBtn.Text = IsMinimized and "+" or "—"
    MainFrame.Size = IsMinimized and UDim2.new(0, 260, 0, 34) or UDim2.new(0, 260, 0, 140)
end)

getgenv().PU_KeyConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if IsBindingKey then
            if input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode ~= Enum.KeyCode.Escape then
                CurrentKey = input.KeyCode
            end
            IsBindingKey = false
            KeybindBtn.Text = "[ " .. CurrentKey.Name .. " ]"
            UpdateToggleUI()
            return
        end
        
        if input.KeyCode == CurrentKey then
            ToggleAutoFish()
        end
    end
end)

UpdateToggleUI()
