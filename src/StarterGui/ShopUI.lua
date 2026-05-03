--[[
    ShopUI - Интерфейс магазина апгрейдов
    Размести этот LocalScript в StarterGui/ShopUI

    ВАЖНО: Создай Frame с именем "ShopUI" внутри ScreenGui "MainUI",
    затем помести этот скрипт внутрь как LocalScript.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Modules = ReplicatedStorage:WaitForChild("Modules")
local GameConfig = require(Modules:WaitForChild("GameConfig"))
local Utilities = require(Modules:WaitForChild("Utilities"))

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local BuyUpgradeEvent = RemoteEvents:WaitForChild("BuyUpgrade")
local UpdateUIEvent = RemoteEvents:WaitForChild("UpdateUI")
local GetPlayerDataFunc = RemoteEvents:WaitForChild("GetPlayerData")

-- ===== СОЗДАНИЕ UI МАГАЗИНА =====
local mainGui = script.Parent.Parent -- ScreenGui
local shopFrame = Instance.new("Frame")
shopFrame.Name = "ShopUI"
shopFrame.Size = UDim2.new(0, 450, 0, 500)
shopFrame.Position = UDim2.new(0.5, -225, 0.5, -250)
shopFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
shopFrame.BackgroundTransparency = 0.1
shopFrame.Visible = false
shopFrame.ZIndex = 5
shopFrame.Parent = mainGui

local shopCorner = Instance.new("UICorner")
shopCorner.CornerRadius = UDim.new(0, 16)
shopCorner.Parent = shopFrame

local shopStroke = Instance.new("UIStroke")
shopStroke.Color = Color3.fromRGB(100, 200, 100)
shopStroke.Thickness = 3
shopStroke.Parent = shopFrame

-- Заголовок
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
titleBar.Parent = shopFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 16)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "МАГАЗИН"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Кнопка закрытия
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
    shopFrame.Visible = false
end)

-- Контейнер для апгрейдов
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -60)
scrollFrame.Position = UDim2.new(0, 10, 0, 50)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 200, 100)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = shopFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

-- ===== СОЗДАНИЕ КАРТОЧЕК АПГРЕЙДОВ =====
local upgradeCards = {}
local order = 0

for upgradeName, upgradeData in pairs(GameConfig.Upgrades) do
    order = order + 1

    local card = Instance.new("Frame")
    card.Name = "Card_" .. upgradeName
    card.Size = UDim2.new(1, 0, 0, 90)
    card.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    card.LayoutOrder = order
    card.Parent = scrollFrame

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 10)
    cardCorner.Parent = card

    -- Название
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.6, 0, 0, 25)
    nameLabel.Position = UDim2.new(0, 10, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = upgradeData.DisplayName
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = card

    -- Описание
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.6, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 10, 0, 30)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = upgradeData.Description
    descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    descLabel.TextScaled = true
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = card

    -- Уровень
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Name = "LevelLabel"
    levelLabel.Size = UDim2.new(0.6, 0, 0, 20)
    levelLabel.Position = UDim2.new(0, 10, 0, 55)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = "Ур. 0 / " .. upgradeData.MaxLevel
    levelLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    levelLabel.TextScaled = true
    levelLabel.Font = Enum.Font.GothamSemibold
    levelLabel.TextXAlignment = Enum.TextXAlignment.Left
    levelLabel.Parent = card

    -- Кнопка покупки
    local buyBtn = Instance.new("TextButton")
    buyBtn.Name = "BuyButton"
    buyBtn.Size = UDim2.new(0, 120, 0, 70)
    buyBtn.Position = UDim2.new(1, -130, 0, 10)
    buyBtn.BackgroundColor3 = upgradeData.Currency == "Coins" and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(50, 100, 200)
    buyBtn.Text = Utilities.FormatNumber(upgradeData.BaseCost) .. "\n" .. (upgradeData.Currency == "Coins" and "Монет" or "Кристаллов")
    buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    buyBtn.TextScaled = true
    buyBtn.Font = Enum.Font.GothamBold
    buyBtn.Parent = card

    local buyCorner = Instance.new("UICorner")
    buyCorner.CornerRadius = UDim.new(0, 10)
    buyCorner.Parent = buyBtn

    buyBtn.MouseButton1Click:Connect(function()
        BuyUpgradeEvent:FireServer(upgradeName)
    end)

    upgradeCards[upgradeName] = {
        Card = card,
        LevelLabel = levelLabel,
        BuyButton = buyBtn,
        UpgradeName = upgradeName,
    }
end

-- ===== ОБНОВЛЕНИЕ КАРТОЧЕК =====
local function updateShopCards(data)
    if not data or not data.Upgrades then return end

    for upgradeName, cardInfo in pairs(upgradeCards) do
        local currentLevel = data.Upgrades[upgradeName] or 0
        local upgradeData = GameConfig.Upgrades[upgradeName]

        cardInfo.LevelLabel.Text = "Ур. " .. currentLevel .. " / " .. upgradeData.MaxLevel

        if currentLevel >= upgradeData.MaxLevel then
            cardInfo.BuyButton.Text = "МАКС"
            cardInfo.BuyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        else
            local cost = GameConfig.GetUpgradeCost(upgradeName, currentLevel)
            cardInfo.BuyButton.Text = Utilities.FormatNumber(cost) .. "\n" .. (upgradeData.Currency == "Coins" and "Монет" or "Кристаллов")
        end
    end
end

UpdateUIEvent.OnClientEvent:Connect(function(data)
    updateShopCards(data)
end)

-- Загрузка начальных данных
spawn(function()
    wait(1.5)
    local data = GetPlayerDataFunc:InvokeServer()
    if data then
        updateShopCards(data)
    end
end)

print("[ShopUI] Loaded successfully!")
