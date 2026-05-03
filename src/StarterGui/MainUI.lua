--[[
    MainUI - Главный интерфейс игрока (HUD)
    Размести этот LocalScript в StarterGui/MainUI

    ВАЖНО: Создай ScreenGui с именем "MainUI" в StarterGui,
    затем помести этот скрипт внутрь как LocalScript.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local Modules = ReplicatedStorage:WaitForChild("Modules")
local GameConfig = require(Modules:WaitForChild("GameConfig"))
local Utilities = require(Modules:WaitForChild("Utilities"))

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ClickEvent = RemoteEvents:WaitForChild("Click")
local UpdateUIEvent = RemoteEvents:WaitForChild("UpdateUI")
local NotificationEvent = RemoteEvents:WaitForChild("Notification")
local GetPlayerDataFunc = RemoteEvents:WaitForChild("GetPlayerData")

-- ===== СОЗДАНИЕ UI =====
local screenGui = script.Parent

-- Основной фрейм валют (верх экрана)
local currencyFrame = Instance.new("Frame")
currencyFrame.Name = "CurrencyFrame"
currencyFrame.Size = UDim2.new(0, 400, 0, 50)
currencyFrame.Position = UDim2.new(0.5, -200, 0, 10)
currencyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
currencyFrame.BackgroundTransparency = 0.3
currencyFrame.Parent = screenGui

local currencyCorner = Instance.new("UICorner")
currencyCorner.CornerRadius = UDim.new(0, 12)
currencyCorner.Parent = currencyFrame

local currencyStroke = Instance.new("UIStroke")
currencyStroke.Color = Color3.fromRGB(255, 215, 0)
currencyStroke.Thickness = 2
currencyStroke.Parent = currencyFrame

-- Иконка монет
local coinIcon = Instance.new("TextLabel")
coinIcon.Name = "CoinIcon"
coinIcon.Size = UDim2.new(0, 30, 0, 30)
coinIcon.Position = UDim2.new(0, 15, 0.5, -15)
coinIcon.BackgroundTransparency = 1
coinIcon.Text = "🪙"
coinIcon.TextScaled = true
coinIcon.Parent = currencyFrame

-- Лейбл монет
local coinLabel = Instance.new("TextLabel")
coinLabel.Name = "CoinLabel"
coinLabel.Size = UDim2.new(0, 130, 0, 30)
coinLabel.Position = UDim2.new(0, 50, 0.5, -15)
coinLabel.BackgroundTransparency = 1
coinLabel.Text = "0"
coinLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
coinLabel.TextScaled = true
coinLabel.Font = Enum.Font.GothamBold
coinLabel.TextXAlignment = Enum.TextXAlignment.Left
coinLabel.Parent = currencyFrame

-- Иконка кристаллов
local gemIcon = Instance.new("TextLabel")
gemIcon.Name = "GemIcon"
gemIcon.Size = UDim2.new(0, 30, 0, 30)
gemIcon.Position = UDim2.new(0.5, 15, 0.5, -15)
gemIcon.BackgroundTransparency = 1
gemIcon.Text = "💎"
gemIcon.TextScaled = true
gemIcon.Parent = currencyFrame

-- Лейбл кристаллов
local gemLabel = Instance.new("TextLabel")
gemLabel.Name = "GemLabel"
gemLabel.Size = UDim2.new(0, 130, 0, 30)
gemLabel.Position = UDim2.new(0.5, 50, 0.5, -15)
gemLabel.BackgroundTransparency = 1
gemLabel.Text = "0"
gemLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
gemLabel.TextScaled = true
gemLabel.Font = Enum.Font.GothamBold
gemLabel.TextXAlignment = Enum.TextXAlignment.Left
gemLabel.Parent = currencyFrame

-- ===== КНОПКИ МЕНЮ (левая сторона) =====
local menuFrame = Instance.new("Frame")
menuFrame.Name = "MenuFrame"
menuFrame.Size = UDim2.new(0, 60, 0, 350)
menuFrame.Position = UDim2.new(0, 10, 0.5, -175)
menuFrame.BackgroundTransparency = 1
menuFrame.Parent = screenGui

local menuLayout = Instance.new("UIListLayout")
menuLayout.Padding = UDim.new(0, 8)
menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
menuLayout.Parent = menuFrame

local menuButtons = {
    {Name = "ShopBtn", Text = "🛒", Color = Color3.fromRGB(50, 150, 50), TargetUI = "ShopUI"},
    {Name = "PetsBtn", Text = "🐾", Color = Color3.fromRGB(200, 100, 50), TargetUI = "PetUI"},
    {Name = "RebirthBtn", Text = "⭐", Color = Color3.fromRGB(200, 50, 200), TargetUI = "RebirthUI"},
    {Name = "ZonesBtn", Text = "🗺️", Color = Color3.fromRGB(50, 100, 200), TargetUI = "ZoneUI"},
    {Name = "CodesBtn", Text = "🎁", Color = Color3.fromRGB(200, 50, 50), TargetUI = "CodesUI"},
}

for i, btnData in ipairs(menuButtons) do
    local btn = Instance.new("TextButton")
    btn.Name = btnData.Name
    btn.Size = UDim2.new(1, 0, 0, 55)
    btn.BackgroundColor3 = btnData.Color
    btn.Text = btnData.Text
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.LayoutOrder = i
    btn.Parent = menuFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    stroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        -- Переключение видимости целевого UI
        local targetGui = screenGui:FindFirstChild(btnData.TargetUI)
        if targetGui then
            targetGui.Visible = not targetGui.Visible
        end
    end)
end

-- ===== КНОПКА КЛИКА (мобильная, внизу экрана) =====
local clickButton = Instance.new("TextButton")
clickButton.Name = "ClickButton"
clickButton.Size = UDim2.new(0, 120, 0, 120)
clickButton.Position = UDim2.new(0.5, -60, 1, -140)
clickButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
clickButton.Text = "КЛИК!"
clickButton.TextScaled = true
clickButton.Font = Enum.Font.GothamBold
clickButton.TextColor3 = Color3.fromRGB(50, 50, 50)
clickButton.Parent = screenGui

local clickCorner = Instance.new("UICorner")
clickCorner.CornerRadius = UDim.new(0.5, 0)
clickCorner.Parent = clickButton

local clickStroke = Instance.new("UIStroke")
clickStroke.Color = Color3.fromRGB(200, 170, 0)
clickStroke.Thickness = 4
clickStroke.Parent = clickButton

-- Анимация нажатия
clickButton.MouseButton1Click:Connect(function()
    ClickEvent:FireServer()

    -- Визуальная анимация
    local shrink = TweenService:Create(clickButton, TweenInfo.new(0.05), {
        Size = UDim2.new(0, 110, 0, 110),
        Position = UDim2.new(0.5, -55, 1, -135),
    })
    local grow = TweenService:Create(clickButton, TweenInfo.new(0.1, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 120, 0, 120),
        Position = UDim2.new(0.5, -60, 1, -140),
    })
    shrink:Play()
    shrink.Completed:Connect(function()
        grow:Play()
    end)
end)

-- ===== ИНФО-ПАНЕЛЬ (перерождения, статистика) =====
local infoFrame = Instance.new("Frame")
infoFrame.Name = "InfoFrame"
infoFrame.Size = UDim2.new(0, 200, 0, 80)
infoFrame.Position = UDim2.new(1, -210, 0, 10)
infoFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
infoFrame.BackgroundTransparency = 0.3
infoFrame.Parent = screenGui

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 12)
infoCorner.Parent = infoFrame

local rebirthLabel = Instance.new("TextLabel")
rebirthLabel.Name = "RebirthLabel"
rebirthLabel.Size = UDim2.new(1, -20, 0, 25)
rebirthLabel.Position = UDim2.new(0, 10, 0, 5)
rebirthLabel.BackgroundTransparency = 1
rebirthLabel.Text = "Перерождения: 0"
rebirthLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
rebirthLabel.TextScaled = true
rebirthLabel.Font = Enum.Font.GothamBold
rebirthLabel.TextXAlignment = Enum.TextXAlignment.Left
rebirthLabel.Parent = infoFrame

local clickPowerLabel = Instance.new("TextLabel")
clickPowerLabel.Name = "ClickPowerLabel"
clickPowerLabel.Size = UDim2.new(1, -20, 0, 20)
clickPowerLabel.Position = UDim2.new(0, 10, 0, 32)
clickPowerLabel.BackgroundTransparency = 1
clickPowerLabel.Text = "Сила клика: 1"
clickPowerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
clickPowerLabel.TextScaled = true
clickPowerLabel.Font = Enum.Font.Gotham
clickPowerLabel.TextXAlignment = Enum.TextXAlignment.Left
clickPowerLabel.Parent = infoFrame

local zoneLabel = Instance.new("TextLabel")
zoneLabel.Name = "ZoneLabel"
zoneLabel.Size = UDim2.new(1, -20, 0, 20)
zoneLabel.Position = UDim2.new(0, 10, 0, 54)
zoneLabel.BackgroundTransparency = 1
zoneLabel.Text = "Зона: Начальная поляна"
zoneLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
zoneLabel.TextScaled = true
zoneLabel.Font = Enum.Font.Gotham
zoneLabel.TextXAlignment = Enum.TextXAlignment.Left
zoneLabel.Parent = infoFrame

-- ===== СИСТЕМА УВЕДОМЛЕНИЙ =====
local notifFrame = Instance.new("Frame")
notifFrame.Name = "NotificationFrame"
notifFrame.Size = UDim2.new(0, 400, 0, 300)
notifFrame.Position = UDim2.new(0.5, -200, 0, 70)
notifFrame.BackgroundTransparency = 1
notifFrame.ClipsDescendants = true
notifFrame.Parent = screenGui

local notifLayout = Instance.new("UIListLayout")
notifLayout.Padding = UDim.new(0, 5)
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
notifLayout.Parent = notifFrame

local notifCounter = 0

NotificationEvent.OnClientEvent:Connect(function(text, color)
    notifCounter = notifCounter + 1
    local order = notifCounter

    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(1, 0, 0, 30)
    notif.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    notif.BackgroundTransparency = 0.3
    notif.Text = " " .. text
    notif.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    notif.TextScaled = true
    notif.Font = Enum.Font.GothamSemibold
    notif.TextXAlignment = Enum.TextXAlignment.Left
    notif.LayoutOrder = order
    notif.Parent = notifFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notif

    -- Исчезновение через 3 секунды
    delay(3, function()
        local fade = TweenService:Create(notif, TweenInfo.new(0.5), {
            BackgroundTransparency = 1,
            TextTransparency = 1,
        })
        fade:Play()
        fade.Completed:Connect(function()
            notif:Destroy()
        end)
    end)
end)

-- ===== ОБНОВЛЕНИЕ UI =====
local function updateUI(data)
    if data.Coins then
        coinLabel.Text = Utilities.FormatNumber(data.Coins)
    end
    if data.Gems then
        gemLabel.Text = Utilities.FormatNumber(data.Gems)
    end
    if data.Rebirths then
        rebirthLabel.Text = "Перерождения: " .. data.Rebirths
    end
    if data.Upgrades then
        local clickPower = GameConfig.GetClickPower(data.Upgrades.ClickPower or 0, data.Rebirths or 0)
        clickPowerLabel.Text = "Сила клика: " .. Utilities.FormatNumber(clickPower)
    end
    if data.CoinsEarned and data.CoinsEarned > 0 then
        -- Показываем +монеты
        local floatText = Instance.new("TextLabel")
        floatText.Size = UDim2.new(0, 100, 0, 30)
        floatText.Position = UDim2.new(0.5, -50 + math.random(-30, 30), 0.5, math.random(-30, 30))
        floatText.BackgroundTransparency = 1
        floatText.Text = "+" .. Utilities.FormatNumber(data.CoinsEarned)
        floatText.TextColor3 = Color3.fromRGB(255, 215, 0)
        floatText.TextScaled = true
        floatText.Font = Enum.Font.GothamBold
        floatText.TextStrokeTransparency = 0
        floatText.ZIndex = 10
        floatText.Parent = screenGui

        local flyUp = TweenService:Create(floatText, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = floatText.Position + UDim2.new(0, 0, 0, -60),
            TextTransparency = 1,
            TextStrokeTransparency = 1,
        })
        flyUp:Play()
        flyUp.Completed:Connect(function()
            floatText:Destroy()
        end)
    end
end

UpdateUIEvent.OnClientEvent:Connect(updateUI)

-- ===== КЛИК ПО ОБЪЕКТАМ В МИРЕ =====
local mouse = player:GetMouse()
mouse.Button1Down:Connect(function()
    if mouse.Target then
        local clickDetector = mouse.Target:FindFirstChild("ClickDetector")
        if clickDetector then
            -- Проверяем, яйцо ли это
            local eggName = mouse.Target:GetAttribute("EggName")
            if eggName then
                local HatchEggEvent = RemoteEvents:FindFirstChild("HatchEgg")
                if HatchEggEvent then
                    HatchEggEvent:FireServer(eggName)
                end
            else
                -- Обычный клик
                ClickEvent:FireServer()
            end
        end
    end
end)

-- ===== ЗАГРУЗКА НАЧАЛЬНЫХ ДАННЫХ =====
spawn(function()
    wait(1)
    local data = GetPlayerDataFunc:InvokeServer()
    if data then
        updateUI(data)
    end
end)

print("[MainUI] Loaded successfully!")
