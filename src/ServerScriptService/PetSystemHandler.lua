--[[
    PetSystemHandler - Серверная логика системы питомцев
    Размести этот Script в ServerScriptService/PetSystemHandler
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local PetConfig = require(Modules:WaitForChild("PetConfig"))
local GameConfig = require(Modules:WaitForChild("GameConfig"))

local DataStoreHandler = require(ServerScriptService:WaitForChild("DataStoreHandler"))

-- Ждём RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local HatchEggEvent = RemoteEvents:WaitForChild("HatchEgg")
local EquipPetEvent = RemoteEvents:WaitForChild("EquipPet")
local UnequipPetEvent = RemoteEvents:WaitForChild("UnequipPet")
local DeletePetEvent = RemoteEvents:WaitForChild("DeletePet")
local PetUpdateEvent = RemoteEvents:WaitForChild("PetUpdate")
local NotificationEvent = RemoteEvents:WaitForChild("Notification")
local UpdateUIEvent = RemoteEvents:WaitForChild("UpdateUI")

-- ===== ВЫЛУПЛЕНИЕ ЯЙЦА =====
HatchEggEvent.OnServerEvent:Connect(function(player, eggName)
    local data = DataStoreHandler.GetData(player)
    if not data then return end

    local egg = PetConfig.Eggs[eggName]
    if not egg then return end

    -- Проверяем инвентарь
    if #data.Pets >= PetConfig.Settings.MaxInventory then
        NotificationEvent:FireClient(player, "Инвентарь питомцев полон! (" .. PetConfig.Settings.MaxInventory .. "/" .. PetConfig.Settings.MaxInventory .. ")", Color3.fromRGB(255, 100, 100))
        return
    end

    -- Проверяем стоимость
    if not DataStoreHandler.SpendCurrency(player, egg.Currency, egg.Cost) then
        NotificationEvent:FireClient(player, "Недостаточно средств!", Color3.fromRGB(255, 100, 100))
        return
    end

    -- Рассчитываем удачу
    local luckLevel = data.Upgrades.LuckBoost or 0
    local luckBonus = luckLevel * GameConfig.Upgrades.LuckBoost.PowerPerLevel

    -- Выпадение питомца
    local newPet = PetConfig.RollPet(eggName, luckBonus)
    if not newPet then
        -- Возвращаем деньги если ошибка
        DataStoreHandler.AddCurrency(player, egg.Currency, egg.Cost)
        NotificationEvent:FireClient(player, "Ошибка при открытии яйца!", Color3.fromRGB(255, 100, 100))
        return
    end

    newPet.Equipped = false
    table.insert(data.Pets, newPet)

    -- Определяем цвет уведомления по редкости
    local rarity = PetConfig.Rarities[newPet.Rarity]
    local color = rarity and rarity.Color or Color3.fromRGB(255, 255, 255)
    local rarityName = rarity and rarity.DisplayName or newPet.Rarity

    -- Отправляем обновление
    PetUpdateEvent:FireClient(player, {
        Action = "Hatched",
        Pet = newPet,
        RarityName = rarityName,
    })

    NotificationEvent:FireClient(player, "Получен питомец: " .. newPet.Name .. " (" .. rarityName .. ") x" .. newPet.Multiplier, color)

    UpdateUIEvent:FireClient(player, {
        Coins = data.Coins,
        Gems = data.Gems,
        Pets = data.Pets,
    })

    -- Оповещение всех при редком питомце
    if newPet.Rarity == "Legendary" or newPet.Rarity == "Mythical" then
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= player then
                NotificationEvent:FireClient(otherPlayer,
                    player.Name .. " получил " .. rarityName .. " питомца: " .. newPet.Name .. "!",
                    color
                )
            end
        end
    end
end)

-- ===== ЭКИПИРОВКА ПИТОМЦА =====
EquipPetEvent.OnServerEvent:Connect(function(player, petUniqueId)
    local data = DataStoreHandler.GetData(player)
    if not data then return end

    -- Считаем экипированных
    local equippedCount = 0
    for _, pet in ipairs(data.Pets) do
        if pet.Equipped then
            equippedCount = equippedCount + 1
        end
    end

    -- Находим питомца
    for _, pet in ipairs(data.Pets) do
        if pet.UniqueId == petUniqueId then
            if pet.Equipped then
                NotificationEvent:FireClient(player, "Питомец уже экипирован!", Color3.fromRGB(255, 200, 0))
                return
            end

            if equippedCount >= PetConfig.Settings.MaxEquipped then
                NotificationEvent:FireClient(player, "Максимум " .. PetConfig.Settings.MaxEquipped .. " экипированных питомцев!", Color3.fromRGB(255, 100, 100))
                return
            end

            pet.Equipped = true
            NotificationEvent:FireClient(player, pet.Name .. " экипирован!", Color3.fromRGB(100, 255, 100))

            PetUpdateEvent:FireClient(player, {
                Action = "Equipped",
                PetId = petUniqueId,
                Pets = data.Pets,
            })
            return
        end
    end

    NotificationEvent:FireClient(player, "Питомец не найден!", Color3.fromRGB(255, 100, 100))
end)

-- ===== СНЯТИЕ ПИТОМЦА =====
UnequipPetEvent.OnServerEvent:Connect(function(player, petUniqueId)
    local data = DataStoreHandler.GetData(player)
    if not data then return end

    for _, pet in ipairs(data.Pets) do
        if pet.UniqueId == petUniqueId then
            pet.Equipped = false
            NotificationEvent:FireClient(player, pet.Name .. " снят!", Color3.fromRGB(255, 200, 0))

            PetUpdateEvent:FireClient(player, {
                Action = "Unequipped",
                PetId = petUniqueId,
                Pets = data.Pets,
            })
            return
        end
    end
end)

-- ===== УДАЛЕНИЕ ПИТОМЦА =====
DeletePetEvent.OnServerEvent:Connect(function(player, petUniqueId)
    local data = DataStoreHandler.GetData(player)
    if not data then return end

    for i, pet in ipairs(data.Pets) do
        if pet.UniqueId == petUniqueId then
            local petName = pet.Name
            table.remove(data.Pets, i)
            NotificationEvent:FireClient(player, petName .. " удалён!", Color3.fromRGB(255, 200, 0))

            PetUpdateEvent:FireClient(player, {
                Action = "Deleted",
                PetId = petUniqueId,
                Pets = data.Pets,
            })
            return
        end
    end
end)

print("[PetSystemHandler] Loaded successfully!")
