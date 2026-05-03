--[[
    PetUI - Интерфейс питомцев
    Размести этот LocalScript в StarterGui/PetUI

    ВАЖНО: Создай Frame с именем "PetUI" внутри ScreenGui "MainUI",
    затем помести этот скрипт внутрь как LocalScript.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Modules = ReplicatedStorage:WaitForChild("Modules")
local PetConfig = require(Modules:WaitForChild("PetConfig"))
local Utilities = require(Modules:WaitForChild("Utilities"))

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local EquipPetEvent = RemoteEvents:WaitForChild("EquipPet")
local UnequipPetEvent = RemoteEvents:WaitForChild("UnequipPet")
local DeletePetEvent = RemoteEvents:WaitForChild("DeletePet")
local PetUpdateEvent = RemoteEvents:WaitForChild("PetUpdate")
local GetPlayerDataFunc = RemoteEvents:WaitForChild("GetPlayerData")

-- ===== СОЗДАНИЕ UI ПИТОМЦЕВ =====
local mainGui = script.Parent.Parent
local petFrame = Instance.new("Frame")
petFrame.Name = "PetUI"
petFrame.Size = UDim2.new(0, 500, 0, 450)
petFrame.Position = UDim2.new(0.5, -250, 0.5, -225)
petFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
petFrame.BackgroundTransparency = 0.1
petFrame.Visible = false
petFrame.ZIndex = 5
petFrame.Parent = mainGui

local petCorner = Instance.new("UICorner")
petCorner.CornerRadius = UDim.new(0, 16)
petCorner.Parent = petFrame

local petStroke = Instance.new("UIStroke")
petStroke.Color = Color3.fromRGB(200, 100, 50)
petStroke.Thickness = 3
petStroke.Parent = petFrame

-- Заголовок
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
titleBar.Parent = petFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 16)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -100, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "ПИТОМЦЫ"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local countLabel = Instance.new("TextLabel")
countLabel.Name = "CountLabel"
countLabel.Size = UDim2.new(0, 80, 1, 0)
countLabel.Position = UDim2.new(1, -120, 0, 0)
countLabel.BackgroundTransparency = 1
countLabel.Text = "0/" .. PetConfig.Settings.MaxInventory
countLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
countLabel.TextScaled = true
countLabel.Font = Enum.Font.GothamBold
countLabel.Parent = titleBar

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
    petFrame.Visible = false
end)

-- Сетка питомцев
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -60)
scrollFrame.Position = UDim2.new(0, 10, 0, 50)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 100, 50)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = petFrame

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 90, 0, 110)
gridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.Parent = scrollFrame

-- ===== ОБНОВЛЕНИЕ СПИСКА ПИТОМЦЕВ =====
local function refreshPetList(pets)
    -- Очищаем
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    if not pets then return end

    countLabel.Text = #pets .. "/" .. PetConfig.Settings.MaxInventory

    for i, pet in ipairs(pets) do
        local rarity = PetConfig.Rarities[pet.Rarity]
        local rarityColor = rarity and rarity.Color or Color3.fromRGB(180, 180, 180)
        local rarityName = rarity and rarity.DisplayName or pet.Rarity

        local petCard = Instance.new("Frame")
        petCard.Name = "Pet_" .. i
        petCard.Size = UDim2.new(0, 90, 0, 110)
        petCard.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        petCard.LayoutOrder = i
        petCard.Parent = scrollFrame

        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0, 8)
        cardCorner.Parent = petCard

        -- Рамка редкости
        local cardStroke = Instance.new("UIStroke")
        cardStroke.Color = rarityColor
        cardStroke.Thickness = pet.Equipped and 3 or 1
        cardStroke.Parent = petCard

        -- Иконка питомца
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(1, 0, 0, 35)
        iconLabel.Position = UDim2.new(0, 0, 0, 3)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = "🐾"
        iconLabel.TextScaled = true
        iconLabel.Parent = petCard

        -- Имя
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -4, 0, 18)
        nameLabel.Position = UDim2.new(0, 2, 0, 38)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = pet.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.Parent = petCard

        -- Редкость
        local rarityLabel = Instance.new("TextLabel")
        rarityLabel.Size = UDim2.new(1, 0, 0, 14)
        rarityLabel.Position = UDim2.new(0, 0, 0, 56)
        rarityLabel.BackgroundTransparency = 1
        rarityLabel.Text = rarityName
        rarityLabel.TextColor3 = rarityColor
        rarityLabel.TextScaled = true
        rarityLabel.Font = Enum.Font.GothamSemibold
        rarityLabel.Parent = petCard

        -- Множитель
        local multLabel = Instance.new("TextLabel")
        multLabel.Size = UDim2.new(1, 0, 0, 14)
        multLabel.Position = UDim2.new(0, 0, 0, 70)
        multLabel.BackgroundTransparency = 1
        multLabel.Text = "x" .. pet.Multiplier
        multLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        multLabel.TextScaled = true
        multLabel.Font = Enum.Font.GothamBold
        multLabel.Parent = petCard

        -- Кнопка экипировки/снятия
        local actionBtn = Instance.new("TextButton")
        actionBtn.Size = UDim2.new(1, -8, 0, 20)
        actionBtn.Position = UDim2.new(0, 4, 1, -24)
        actionBtn.BackgroundColor3 = pet.Equipped and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(50, 150, 50)
        actionBtn.Text = pet.Equipped and "Снять" or "Надеть"
        actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        actionBtn.TextScaled = true
        actionBtn.Font = Enum.Font.GothamBold
        actionBtn.Parent = petCard

        local actionCorner = Instance.new("UICorner")
        actionCorner.CornerRadius = UDim.new(0, 6)
        actionCorner.Parent = actionBtn

        actionBtn.MouseButton1Click:Connect(function()
            if pet.Equipped then
                UnequipPetEvent:FireServer(pet.UniqueId)
            else
                EquipPetEvent:FireServer(pet.UniqueId)
            end
        end)
    end
end

-- ===== ОБРАБОТКА ОБНОВЛЕНИЙ =====
PetUpdateEvent.OnClientEvent:Connect(function(data)
    if data.Pets then
        refreshPetList(data.Pets)
    end

    -- Анимация вылупления
    if data.Action == "Hatched" and data.Pet then
        local rarity = PetConfig.Rarities[data.Pet.Rarity]

        -- Создаём оверлей
        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        overlay.BackgroundTransparency = 0.5
        overlay.ZIndex = 10
        overlay.Parent = mainGui

        local hatchCard = Instance.new("Frame")
        hatchCard.Size = UDim2.new(0, 250, 0, 300)
        hatchCard.Position = UDim2.new(0.5, -125, 0.5, -150)
        hatchCard.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        hatchCard.ZIndex = 11
        hatchCard.Parent = overlay

        local hatchCorner = Instance.new("UICorner")
        hatchCorner.CornerRadius = UDim.new(0, 16)
        hatchCorner.Parent = hatchCard

        local hatchStroke = Instance.new("UIStroke")
        hatchStroke.Color = rarity and rarity.Color or Color3.fromRGB(255, 255, 255)
        hatchStroke.Thickness = 4
        hatchStroke.Parent = hatchCard

        local newLabel = Instance.new("TextLabel")
        newLabel.Size = UDim2.new(1, 0, 0, 40)
        newLabel.Position = UDim2.new(0, 0, 0, 10)
        newLabel.BackgroundTransparency = 1
        newLabel.Text = "НОВЫЙ ПИТОМЕЦ!"
        newLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        newLabel.TextScaled = true
        newLabel.Font = Enum.Font.GothamBold
        newLabel.ZIndex = 12
        newLabel.Parent = hatchCard

        local petIcon = Instance.new("TextLabel")
        petIcon.Size = UDim2.new(1, 0, 0, 80)
        petIcon.Position = UDim2.new(0, 0, 0, 50)
        petIcon.BackgroundTransparency = 1
        petIcon.Text = "🐾"
        petIcon.TextScaled = true
        petIcon.ZIndex = 12
        petIcon.Parent = hatchCard

        local petName = Instance.new("TextLabel")
        petName.Size = UDim2.new(1, 0, 0, 30)
        petName.Position = UDim2.new(0, 0, 0, 140)
        petName.BackgroundTransparency = 1
        petName.Text = data.Pet.Name
        petName.TextColor3 = Color3.fromRGB(255, 255, 255)
        petName.TextScaled = true
        petName.Font = Enum.Font.GothamBold
        petName.ZIndex = 12
        petName.Parent = hatchCard

        local rarityLabel = Instance.new("TextLabel")
        rarityLabel.Size = UDim2.new(1, 0, 0, 25)
        rarityLabel.Position = UDim2.new(0, 0, 0, 175)
        rarityLabel.BackgroundTransparency = 1
        rarityLabel.Text = data.RarityName or data.Pet.Rarity
        rarityLabel.TextColor3 = rarity and rarity.Color or Color3.fromRGB(255, 255, 255)
        rarityLabel.TextScaled = true
        rarityLabel.Font = Enum.Font.GothamBold
        rarityLabel.ZIndex = 12
        rarityLabel.Parent = hatchCard

        local multLabel = Instance.new("TextLabel")
        multLabel.Size = UDim2.new(1, 0, 0, 30)
        multLabel.Position = UDim2.new(0, 0, 0, 205)
        multLabel.BackgroundTransparency = 1
        multLabel.Text = "Множитель: x" .. data.Pet.Multiplier
        multLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        multLabel.TextScaled = true
        multLabel.Font = Enum.Font.GothamSemibold
        multLabel.ZIndex = 12
        multLabel.Parent = hatchCard

        local okBtn = Instance.new("TextButton")
        okBtn.Size = UDim2.new(0.6, 0, 0, 35)
        okBtn.Position = UDim2.new(0.2, 0, 1, -45)
        okBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        okBtn.Text = "КРУТО!"
        okBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        okBtn.TextScaled = true
        okBtn.Font = Enum.Font.GothamBold
        okBtn.ZIndex = 12
        okBtn.Parent = hatchCard

        local okCorner = Instance.new("UICorner")
        okCorner.CornerRadius = UDim.new(0, 10)
        okCorner.Parent = okBtn

        okBtn.MouseButton1Click:Connect(function()
            overlay:Destroy()
        end)

        -- Автоматически закрыть через 5 секунд
        delay(5, function()
            if overlay.Parent then
                overlay:Destroy()
            end
        end)
    end
end)

-- Загрузка начальных данных
spawn(function()
    wait(2)
    local data = GetPlayerDataFunc:InvokeServer()
    if data and data.Pets then
        refreshPetList(data.Pets)
    end
end)

print("[PetUI] Loaded successfully!")
