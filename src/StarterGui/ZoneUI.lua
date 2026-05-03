--[[
    ZoneUI - Интерфейс выбора зон
    Размести этот LocalScript в StarterGui/ZoneUI
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Modules = ReplicatedStorage:WaitForChild("Modules")
local ZoneConfig = require(Modules:WaitForChild("ZoneConfig"))
local Utilities = require(Modules:WaitForChild("Utilities"))

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local UnlockZoneEvent = RemoteEvents:WaitForChild("UnlockZone")
local TeleportZoneEvent = RemoteEvents:WaitForChild("TeleportZone")
local UpdateUIEvent = RemoteEvents:WaitForChild("UpdateUI")
local GetPlayerDataFunc = RemoteEvents:WaitForChild("GetPlayerData")

-- ===== UI =====
local mainGui = script.Parent.Parent
local zoneFrame = Instance.new("Frame")
zoneFrame.Name = "ZoneUI"
zoneFrame.Size = UDim2.new(0, 400, 0, 500)
zoneFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
zoneFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
zoneFrame.BackgroundTransparency = 0.1
zoneFrame.Visible = false
zoneFrame.ZIndex = 5
zoneFrame.Parent = mainGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = zoneFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(50, 100, 200)
stroke.Thickness = 3
stroke.Parent = zoneFrame

-- Заголовок
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
titleBar.Parent = zoneFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 16)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "ЗОНЫ"
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
    zoneFrame.Visible = false
end)

-- Список зон
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -60)
scrollFrame.Position = UDim2.new(0, 10, 0, 50)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 6
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = zoneFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

-- Создание карточек зон
local zoneCards = {}

for i, zone in ipairs(ZoneConfig.Zones) do
    local card = Instance.new("Frame")
    card.Name = "Zone_" .. zone.Name
    card.Size = UDim2.new(1, 0, 0, 70)
    card.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    card.LayoutOrder = i
    card.Parent = scrollFrame

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 10)
    cardCorner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Name = "ZoneStroke"
    cardStroke.Color = zone.Color
    cardStroke.Thickness = 2
    cardStroke.Parent = card

    -- Цветная полоска слева
    local colorBar = Instance.new("Frame")
    colorBar.Size = UDim2.new(0, 6, 1, -10)
    colorBar.Position = UDim2.new(0, 5, 0, 5)
    colorBar.BackgroundColor3 = zone.Color
    colorBar.Parent = card

    local colorCorner = Instance.new("UICorner")
    colorCorner.CornerRadius = UDim.new(0, 3)
    colorCorner.Parent = colorBar

    -- Название
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.5, 0, 0, 22)
    nameLabel.Position = UDim2.new(0, 18, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = zone.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = card

    -- Множитель
    local multLabel = Instance.new("TextLabel")
    multLabel.Size = UDim2.new(0.5, 0, 0, 18)
    multLabel.Position = UDim2.new(0, 18, 0, 28)
    multLabel.BackgroundTransparency = 1
    multLabel.Text = "Монеты x" .. zone.CoinMultiplier .. " | Кристаллы " .. (zone.GemChance * 100) .. "%"
    multLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    multLabel.TextScaled = true
    multLabel.Font = Enum.Font.Gotham
    multLabel.TextXAlignment = Enum.TextXAlignment.Left
    multLabel.Parent = card

    -- Описание
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.55, 0, 0, 16)
    descLabel.Position = UDim2.new(0, 18, 0, 48)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = zone.Description
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    descLabel.TextScaled = true
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = card

    -- Кнопка действия
    local actionBtn = Instance.new("TextButton")
    actionBtn.Name = "ActionBtn"
    actionBtn.Size = UDim2.new(0, 100, 0, 50)
    actionBtn.Position = UDim2.new(1, -110, 0, 10)
    actionBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    actionBtn.Text = "Закрыто"
    actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    actionBtn.TextScaled = true
    actionBtn.Font = Enum.Font.GothamBold
    actionBtn.Parent = card

    local actionCorner = Instance.new("UICorner")
    actionCorner.CornerRadius = UDim.new(0, 8)
    actionCorner.Parent = actionBtn

    zoneCards[zone.Name] = {
        Card = card,
        ActionBtn = actionBtn,
        Zone = zone,
    }
end

-- ===== ОБНОВЛЕНИЕ ЗОНИРОВАНИЯ =====
local function updateZoneUI(unlockedZones, currentZone)
    if not unlockedZones then return end

    for zoneName, cardInfo in pairs(zoneCards) do
        local isUnlocked = false
        for _, uz in ipairs(unlockedZones) do
            if uz == zoneName then
                isUnlocked = true
                break
            end
        end

        local btn = cardInfo.ActionBtn
        if isUnlocked then
            if currentZone == zoneName then
                btn.Text = "Тут!"
                btn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
            else
                btn.Text = "Телепорт"
                btn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
            end

            -- Подключаем телепорт
            for _, conn in ipairs(btn:GetConnections("MouseButton1Click") or {}) do
                -- Отключаем старые
            end

            btn.MouseButton1Click:Connect(function()
                if currentZone ~= zoneName then
                    TeleportZoneEvent:FireServer(zoneName)
                end
            end)
        else
            local cost = cardInfo.Zone.UnlockCost
            local currency = cardInfo.Zone.UnlockCurrency == "Coins" and "Монет" or "Кристаллов"
            btn.Text = Utilities.FormatNumber(cost) .. "\n" .. currency
            btn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)

            btn.MouseButton1Click:Connect(function()
                UnlockZoneEvent:FireServer(zoneName)
            end)
        end
    end
end

UpdateUIEvent.OnClientEvent:Connect(function(data)
    if data.UnlockedZones then
        updateZoneUI(data.UnlockedZones, data.CurrentZone)
    end
end)

spawn(function()
    wait(2)
    local data = GetPlayerDataFunc:InvokeServer()
    if data then
        updateZoneUI(data.UnlockedZones, data.CurrentZone)
    end
end)

print("[ZoneUI] Loaded successfully!")
