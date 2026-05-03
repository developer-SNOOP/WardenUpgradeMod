--[[
    CodesUI - Интерфейс ввода кодов
    Размести этот LocalScript в StarterGui/CodesUI
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local RedeemCodeEvent = RemoteEvents:WaitForChild("RedeemCode")

-- ===== UI =====
local mainGui = script.Parent.Parent
local codesFrame = Instance.new("Frame")
codesFrame.Name = "CodesUI"
codesFrame.Size = UDim2.new(0, 350, 0, 200)
codesFrame.Position = UDim2.new(0.5, -175, 0.5, -100)
codesFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
codesFrame.BackgroundTransparency = 0.1
codesFrame.Visible = false
codesFrame.ZIndex = 5
codesFrame.Parent = mainGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = codesFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(200, 50, 50)
stroke.Thickness = 3
stroke.Parent = codesFrame

-- Заголовок
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
titleBar.Parent = codesFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 16)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "КОДЫ"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.ZIndex = 6
closeBtn.Parent = titleBar

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 8)
closeBtnCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    codesFrame.Visible = false
end)

-- Поле ввода
local inputBox = Instance.new("TextBox")
inputBox.Name = "CodeInput"
inputBox.Size = UDim2.new(0.7, 0, 0, 45)
inputBox.Position = UDim2.new(0.05, 0, 0, 65)
inputBox.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
inputBox.Text = ""
inputBox.PlaceholderText = "Введи код..."
inputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.TextScaled = true
inputBox.Font = Enum.Font.Gotham
inputBox.ClearTextOnFocus = false
inputBox.Parent = codesFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 10)
inputCorner.Parent = inputBox

-- Кнопка активации
local redeemBtn = Instance.new("TextButton")
redeemBtn.Size = UDim2.new(0.2, 0, 0, 45)
redeemBtn.Position = UDim2.new(0.77, 0, 0, 65)
redeemBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
redeemBtn.Text = "OK"
redeemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
redeemBtn.TextScaled = true
redeemBtn.Font = Enum.Font.GothamBold
redeemBtn.Parent = codesFrame

local redeemCorner = Instance.new("UICorner")
redeemCorner.CornerRadius = UDim.new(0, 10)
redeemCorner.Parent = redeemBtn

redeemBtn.MouseButton1Click:Connect(function()
    local code = inputBox.Text
    if code and code ~= "" then
        RedeemCodeEvent:FireServer(code)
        inputBox.Text = ""
    end
end)

-- Список кодов-подсказок
local hintsLabel = Instance.new("TextLabel")
hintsLabel.Size = UDim2.new(0.9, 0, 0, 60)
hintsLabel.Position = UDim2.new(0.05, 0, 0, 125)
hintsLabel.BackgroundTransparency = 1
hintsLabel.Text = "Активные коды: RELEASE, GEMS, SIMULATOR, PETS, LIKE"
hintsLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
hintsLabel.TextScaled = true
hintsLabel.Font = Enum.Font.Gotham
hintsLabel.TextWrapped = true
hintsLabel.Parent = codesFrame

print("[CodesUI] Loaded successfully!")
