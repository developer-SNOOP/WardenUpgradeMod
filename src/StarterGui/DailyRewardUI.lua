--[[
    DailyRewardUI - Интерфейс ежедневных наград
    Размести этот LocalScript в StarterGui/DailyRewardUI
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Modules = ReplicatedStorage:WaitForChild("Modules")
local GameConfig = require(Modules:WaitForChild("GameConfig"))
local Utilities = require(Modules:WaitForChild("Utilities"))

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ClaimDailyRewardEvent = RemoteEvents:WaitForChild("ClaimDailyReward")
local DailyRewardUpdateEvent = RemoteEvents:WaitForChild("DailyRewardUpdate")

-- ===== UI =====
local mainGui = script.Parent.Parent
local dailyFrame = Instance.new("Frame")
dailyFrame.Name = "DailyRewardUI"
dailyFrame.Size = UDim2.new(0, 500, 0, 300)
dailyFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
dailyFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
dailyFrame.BackgroundTransparency = 0.1
dailyFrame.Visible = false
dailyFrame.ZIndex = 8
dailyFrame.Parent = mainGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = dailyFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 200, 0)
stroke.Thickness = 3
stroke.Parent = dailyFrame

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 45)
titleLabel.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
titleLabel.Text = "ЕЖЕДНЕВНЫЕ НАГРАДЫ"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = dailyFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 16)
titleCorner.Parent = titleLabel

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.ZIndex = 9
closeBtn.Parent = dailyFrame

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 8)
closeBtnCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    dailyFrame.Visible = false
end)

-- Контейнер дней
local daysFrame = Instance.new("Frame")
daysFrame.Size = UDim2.new(1, -20, 0, 140)
daysFrame.Position = UDim2.new(0, 10, 0, 55)
daysFrame.BackgroundTransparency = 1
daysFrame.Parent = dailyFrame

local daysLayout = Instance.new("UIListLayout")
daysLayout.FillDirection = Enum.FillDirection.Horizontal
daysLayout.Padding = UDim.new(0, 6)
daysLayout.SortOrder = Enum.SortOrder.LayoutOrder
daysLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
daysLayout.Parent = daysFrame

local dayCards = {}
for i, reward in ipairs(GameConfig.DailyRewards) do
    local dayCard = Instance.new("Frame")
    dayCard.Name = "Day" .. i
    dayCard.Size = UDim2.new(0, 60, 1, 0)
    dayCard.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    dayCard.LayoutOrder = i
    dayCard.Parent = daysFrame

    local dayCorner = Instance.new("UICorner")
    dayCorner.CornerRadius = UDim.new(0, 8)
    dayCorner.Parent = dayCard

    local dayStroke = Instance.new("UIStroke")
    dayStroke.Name = "DayStroke"
    dayStroke.Color = Color3.fromRGB(100, 100, 100)
    dayStroke.Thickness = 2
    dayStroke.Parent = dayCard

    local dayLabel = Instance.new("TextLabel")
    dayLabel.Size = UDim2.new(1, 0, 0, 25)
    dayLabel.Position = UDim2.new(0, 0, 0, 5)
    dayLabel.BackgroundTransparency = 1
    dayLabel.Text = "День " .. i
    dayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    dayLabel.TextScaled = true
    dayLabel.Font = Enum.Font.GothamSemibold
    dayLabel.Parent = dayCard

    local rewardIcon = Instance.new("TextLabel")
    rewardIcon.Size = UDim2.new(1, 0, 0, 40)
    rewardIcon.Position = UDim2.new(0, 0, 0, 30)
    rewardIcon.BackgroundTransparency = 1
    rewardIcon.Text = reward.Reward == "Coins" and "🪙" or "💎"
    rewardIcon.TextScaled = true
    rewardIcon.Parent = dayCard

    local amountLabel = Instance.new("TextLabel")
    amountLabel.Size = UDim2.new(1, 0, 0, 20)
    amountLabel.Position = UDim2.new(0, 0, 0, 75)
    amountLabel.BackgroundTransparency = 1
    amountLabel.Text = Utilities.FormatNumber(reward.Amount)
    amountLabel.TextColor3 = reward.Reward == "Coins" and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(0, 200, 255)
    amountLabel.TextScaled = true
    amountLabel.Font = Enum.Font.GothamBold
    amountLabel.Parent = dayCard

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(1, 0, 0, 20)
    statusLabel.Position = UDim2.new(0, 0, 1, -25)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = ""
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.Parent = dayCard

    dayCards[i] = {Card = dayCard, Stroke = dayStroke, Status = statusLabel}
end

-- Кнопка получения
local claimBtn = Instance.new("TextButton")
claimBtn.Name = "ClaimButton"
claimBtn.Size = UDim2.new(0.6, 0, 0, 45)
claimBtn.Position = UDim2.new(0.2, 0, 1, -60)
claimBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
claimBtn.Text = "ПОЛУЧИТЬ НАГРАДУ!"
claimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
claimBtn.TextScaled = true
claimBtn.Font = Enum.Font.GothamBold
claimBtn.ZIndex = 9
claimBtn.Parent = dailyFrame

local claimCorner = Instance.new("UICorner")
claimCorner.CornerRadius = UDim.new(0, 12)
claimCorner.Parent = claimBtn

claimBtn.MouseButton1Click:Connect(function()
    ClaimDailyRewardEvent:FireServer()
end)

-- ===== ОБНОВЛЕНИЕ =====
DailyRewardUpdateEvent.OnClientEvent:Connect(function(data)
    local streak = data.CurrentStreak or 0
    local canClaim = data.CanClaim

    for i, cardInfo in ipairs(dayCards) do
        if i <= streak then
            cardInfo.Stroke.Color = Color3.fromRGB(100, 255, 100)
            cardInfo.Status.Text = "Получено"
            cardInfo.Status.TextColor3 = Color3.fromRGB(100, 255, 100)
        elseif i == streak + 1 and canClaim then
            cardInfo.Stroke.Color = Color3.fromRGB(255, 215, 0)
            cardInfo.Status.Text = "Доступно!"
            cardInfo.Status.TextColor3 = Color3.fromRGB(255, 215, 0)
        else
            cardInfo.Stroke.Color = Color3.fromRGB(100, 100, 100)
            cardInfo.Status.Text = ""
        end
    end

    if canClaim then
        claimBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        claimBtn.Text = "ПОЛУЧИТЬ НАГРАДУ!"
    else
        claimBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        local timeLeft = 86400 - (os.time() - (data.LastClaim or 0))
        claimBtn.Text = "Через " .. Utilities.FormatTime(math.max(0, timeLeft))
    end

    -- Показываем UI если можно забрать
    if canClaim then
        dailyFrame.Visible = true
    end
end)

print("[DailyRewardUI] Loaded successfully!")
