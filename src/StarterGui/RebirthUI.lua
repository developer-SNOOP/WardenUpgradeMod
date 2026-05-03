--[[
    RebirthUI - Интерфейс перерождений
    Размести этот LocalScript в StarterGui/RebirthUI
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Modules = ReplicatedStorage:WaitForChild("Modules")
local GameConfig = require(Modules:WaitForChild("GameConfig"))
local Utilities = require(Modules:WaitForChild("Utilities"))

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local DoRebirthEvent = RemoteEvents:WaitForChild("DoRebirth")
local RebirthUpdateEvent = RemoteEvents:WaitForChild("RebirthUpdate")
local UpdateUIEvent = RemoteEvents:WaitForChild("UpdateUI")
local GetPlayerDataFunc = RemoteEvents:WaitForChild("GetPlayerData")

-- ===== UI =====
local mainGui = script.Parent.Parent
local rebirthFrame = Instance.new("Frame")
rebirthFrame.Name = "RebirthUI"
rebirthFrame.Size = UDim2.new(0, 350, 0, 350)
rebirthFrame.Position = UDim2.new(0.5, -175, 0.5, -175)
rebirthFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
rebirthFrame.BackgroundTransparency = 0.1
rebirthFrame.Visible = false
rebirthFrame.ZIndex = 5
rebirthFrame.Parent = mainGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = rebirthFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(200, 50, 200)
stroke.Thickness = 3
stroke.Parent = rebirthFrame

-- Заголовок
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(200, 50, 200)
titleBar.Parent = rebirthFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 16)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "ПЕРЕРОЖДЕНИЕ"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
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
    rebirthFrame.Visible = false
end)

-- Контент
local rebirthCountLabel = Instance.new("TextLabel")
rebirthCountLabel.Name = "RebirthCount"
rebirthCountLabel.Size = UDim2.new(1, -20, 0, 40)
rebirthCountLabel.Position = UDim2.new(0, 10, 0, 55)
rebirthCountLabel.BackgroundTransparency = 1
rebirthCountLabel.Text = "Перерождений: 0"
rebirthCountLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
rebirthCountLabel.TextScaled = true
rebirthCountLabel.Font = Enum.Font.GothamBold
rebirthCountLabel.Parent = rebirthFrame

local bonusLabel = Instance.new("TextLabel")
bonusLabel.Name = "BonusLabel"
bonusLabel.Size = UDim2.new(1, -20, 0, 30)
bonusLabel.Position = UDim2.new(0, 10, 0, 100)
bonusLabel.BackgroundTransparency = 1
bonusLabel.Text = "Текущий бонус: +0%"
bonusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
bonusLabel.TextScaled = true
bonusLabel.Font = Enum.Font.GothamSemibold
bonusLabel.Parent = rebirthFrame

local costLabel = Instance.new("TextLabel")
costLabel.Name = "CostLabel"
costLabel.Size = UDim2.new(1, -20, 0, 30)
costLabel.Position = UDim2.new(0, 10, 0, 140)
costLabel.BackgroundTransparency = 1
costLabel.Text = "Стоимость: 10,000 Монет"
costLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
costLabel.TextScaled = true
costLabel.Font = Enum.Font.GothamSemibold
costLabel.Parent = rebirthFrame

local warningLabel = Instance.new("TextLabel")
warningLabel.Size = UDim2.new(1, -20, 0, 40)
warningLabel.Position = UDim2.new(0, 10, 0, 180)
warningLabel.BackgroundTransparency = 1
warningLabel.Text = "Внимание: монеты и апгрейды будут сброшены!\nПитомцы сохраняются."
warningLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
warningLabel.TextScaled = true
warningLabel.Font = Enum.Font.Gotham
warningLabel.TextWrapped = true
warningLabel.Parent = rebirthFrame

local nextBonusLabel = Instance.new("TextLabel")
nextBonusLabel.Name = "NextBonusLabel"
nextBonusLabel.Size = UDim2.new(1, -20, 0, 25)
nextBonusLabel.Position = UDim2.new(0, 10, 0, 230)
nextBonusLabel.BackgroundTransparency = 1
nextBonusLabel.Text = "Следующий бонус: +25%"
nextBonusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
nextBonusLabel.TextScaled = true
nextBonusLabel.Font = Enum.Font.Gotham
nextBonusLabel.Parent = rebirthFrame

-- Кнопка перерождения
local rebirthBtn = Instance.new("TextButton")
rebirthBtn.Name = "RebirthButton"
rebirthBtn.Size = UDim2.new(0.8, 0, 0, 50)
rebirthBtn.Position = UDim2.new(0.1, 0, 1, -65)
rebirthBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 200)
rebirthBtn.Text = "ПЕРЕРОДИТЬСЯ!"
rebirthBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rebirthBtn.TextScaled = true
rebirthBtn.Font = Enum.Font.GothamBold
rebirthBtn.Parent = rebirthFrame

local rebirthBtnCorner = Instance.new("UICorner")
rebirthBtnCorner.CornerRadius = UDim.new(0, 12)
rebirthBtnCorner.Parent = rebirthBtn

rebirthBtn.MouseButton1Click:Connect(function()
    DoRebirthEvent:FireServer()
end)

-- ===== ОБНОВЛЕНИЕ =====
local function updateRebirthUI(data)
    local rebirths = data.Rebirths or 0
    rebirthCountLabel.Text = "Перерождений: " .. rebirths

    local currentBonus = math.floor(rebirths * GameConfig.Rebirth.BonusPerRebirth * 100)
    bonusLabel.Text = "Текущий бонус: +" .. currentBonus .. "%"

    local cost = GameConfig.GetRebirthCost(rebirths)
    costLabel.Text = "Стоимость: " .. Utilities.FormatNumber(cost) .. " Монет"

    local nextBonus = math.floor((rebirths + 1) * GameConfig.Rebirth.BonusPerRebirth * 100)
    nextBonusLabel.Text = "Следующий бонус: +" .. nextBonus .. "%"

    if rebirths >= GameConfig.Rebirth.MaxRebirths then
        rebirthBtn.Text = "МАКСИМУМ!"
        rebirthBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end
end

UpdateUIEvent.OnClientEvent:Connect(function(data)
    if data.Rebirths ~= nil then
        updateRebirthUI(data)
    end
end)

RebirthUpdateEvent.OnClientEvent:Connect(function(data)
    -- Эффект перерождения
    local flash = Instance.new("Frame")
    flash.Size = UDim2.new(1, 0, 1, 0)
    flash.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    flash.BackgroundTransparency = 0
    flash.ZIndex = 20
    flash.Parent = mainGui

    local fadeTween = TweenService:Create(flash, TweenInfo.new(1.5, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 1,
    })
    fadeTween:Play()
    fadeTween.Completed:Connect(function()
        flash:Destroy()
    end)
end)

spawn(function()
    wait(2)
    local data = GetPlayerDataFunc:InvokeServer()
    if data then
        updateRebirthUI(data)
    end
end)

print("[RebirthUI] Loaded successfully!")
