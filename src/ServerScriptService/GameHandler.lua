--[[
    GameHandler - Основной игровой обработчик (клики, автокликер, коды)
    Размести этот Script в ServerScriptService/GameHandler
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local GameConfig = require(Modules:WaitForChild("GameConfig"))
local ZoneConfig = require(Modules:WaitForChild("ZoneConfig"))

-- Ждём DataStoreHandler
local ServerScriptService = game:GetService("ServerScriptService")
local DataStoreHandler = require(ServerScriptService:WaitForChild("DataStoreHandler"))

-- ===== СОЗДАНИЕ REMOTE EVENTS =====
local RemoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not RemoteEvents then
    RemoteEvents = Instance.new("Folder")
    RemoteEvents.Name = "RemoteEvents"
    RemoteEvents.Parent = ReplicatedStorage
end

local function createRemote(name, className)
    className = className or "RemoteEvent"
    local remote = RemoteEvents:FindFirstChild(name)
    if not remote then
        remote = Instance.new(className)
        remote.Name = name
        remote.Parent = RemoteEvents
    end
    return remote
end

-- Remote Events
local ClickEvent = createRemote("Click")
local BuyUpgradeEvent = createRemote("BuyUpgrade")
local RedeemCodeEvent = createRemote("RedeemCode")
local UpdateUIEvent = createRemote("UpdateUI")
local NotificationEvent = createRemote("Notification")
local UnlockZoneEvent = createRemote("UnlockZone")
local TeleportZoneEvent = createRemote("TeleportZone")

-- Remote Functions
local GetPlayerDataFunc = createRemote("GetPlayerData", "RemoteFunction")

-- Также создаём пустые для других систем
createRemote("HatchEgg")
createRemote("EquipPet")
createRemote("UnequipPet")
createRemote("DeletePet")
createRemote("PetUpdate")
createRemote("DoRebirth")
createRemote("RebirthUpdate")
createRemote("ClaimDailyReward")
createRemote("DailyRewardUpdate")

-- ===== АНТИЧИТ: Кулдаун кликов =====
local lastClickTime = {}

-- ===== ОБРАБОТКА КЛИКОВ =====
ClickEvent.OnServerEvent:Connect(function(player)
    local now = tick()
    local lastClick = lastClickTime[player.UserId] or 0

    if (now - lastClick) < GameConfig.Click.Cooldown then
        return -- Слишком быстро кликает
    end
    lastClickTime[player.UserId] = now

    local data = DataStoreHandler.GetData(player)
    if not data then return end

    -- Вычисляем силу клика
    local clickPower = GameConfig.GetClickPower(data.Upgrades.ClickPower, data.Rebirths)
    local coinMultiplier = GameConfig.GetCoinMultiplier(data.Upgrades.CoinMultiplier, data.Rebirths)

    -- Бонус от зоны
    local currentZone = ZoneConfig.GetZoneByName(data.CurrentZone)
    local zoneMultiplier = currentZone and currentZone.CoinMultiplier or 1

    -- Бонус от питомцев
    local petMultiplier = 1
    for _, pet in ipairs(data.Pets) do
        if pet.Equipped then
            petMultiplier = petMultiplier + (pet.Multiplier - 1)
        end
    end

    local totalCoins = math.floor(clickPower * coinMultiplier * zoneMultiplier * petMultiplier)

    -- Шанс на кристаллы от зоны
    local gemChance = currentZone and currentZone.GemChance or 0
    local gemsEarned = 0
    if math.random() < gemChance then
        gemsEarned = 1
        DataStoreHandler.AddCurrency(player, "Gems", gemsEarned)
    end

    DataStoreHandler.AddCurrency(player, "Coins", totalCoins)
    data.TotalClicks = (data.TotalClicks or 0) + 1

    -- Отправляем обновление UI
    UpdateUIEvent:FireClient(player, {
        Coins = data.Coins,
        Gems = data.Gems,
        CoinsEarned = totalCoins,
        GemsEarned = gemsEarned,
        TotalClicks = data.TotalClicks,
    })
end)

-- ===== ПОКУПКА АПГРЕЙДОВ =====
BuyUpgradeEvent.OnServerEvent:Connect(function(player, upgradeName)
    local data = DataStoreHandler.GetData(player)
    if not data then return end

    local upgrade = GameConfig.Upgrades[upgradeName]
    if not upgrade then return end

    local currentLevel = data.Upgrades[upgradeName] or 0
    if currentLevel >= upgrade.MaxLevel then
        NotificationEvent:FireClient(player, "Максимальный уровень!", Color3.fromRGB(255, 100, 100))
        return
    end

    local cost = GameConfig.GetUpgradeCost(upgradeName, currentLevel)
    if not DataStoreHandler.SpendCurrency(player, upgrade.Currency, cost) then
        NotificationEvent:FireClient(player, "Недостаточно средств!", Color3.fromRGB(255, 100, 100))
        return
    end

    data.Upgrades[upgradeName] = currentLevel + 1

    NotificationEvent:FireClient(player, upgrade.DisplayName .. " улучшен до ур. " .. (currentLevel + 1) .. "!", Color3.fromRGB(100, 255, 100))

    -- Отправляем обновление UI
    UpdateUIEvent:FireClient(player, {
        Coins = data.Coins,
        Gems = data.Gems,
        Upgrades = data.Upgrades,
    })
end)

-- ===== РАЗБЛОКИРОВКА ЗОН =====
UnlockZoneEvent.OnServerEvent:Connect(function(player, zoneName)
    local data = DataStoreHandler.GetData(player)
    if not data then return end

    local zone = ZoneConfig.GetZoneByName(zoneName)
    if not zone then return end

    -- Проверяем, не разблокирована ли уже
    for _, unlockedZone in ipairs(data.UnlockedZones) do
        if unlockedZone == zoneName then
            NotificationEvent:FireClient(player, "Зона уже разблокирована!", Color3.fromRGB(255, 200, 0))
            return
        end
    end

    -- Проверяем предыдущую зону
    if zone.Order > 1 then
        local prevZone = ZoneConfig.GetZoneByOrder(zone.Order - 1)
        if prevZone then
            local prevUnlocked = false
            for _, uz in ipairs(data.UnlockedZones) do
                if uz == prevZone.Name then
                    prevUnlocked = true
                    break
                end
            end
            if not prevUnlocked then
                NotificationEvent:FireClient(player, "Сначала разблокируй предыдущую зону!", Color3.fromRGB(255, 100, 100))
                return
            end
        end
    end

    -- Покупка
    if not DataStoreHandler.SpendCurrency(player, zone.UnlockCurrency, zone.UnlockCost) then
        NotificationEvent:FireClient(player, "Недостаточно средств!", Color3.fromRGB(255, 100, 100))
        return
    end

    table.insert(data.UnlockedZones, zoneName)
    NotificationEvent:FireClient(player, "Зона '" .. zoneName .. "' разблокирована!", Color3.fromRGB(100, 255, 100))

    UpdateUIEvent:FireClient(player, {
        Coins = data.Coins,
        Gems = data.Gems,
        UnlockedZones = data.UnlockedZones,
    })
end)

-- ===== ТЕЛЕПОРТ В ЗОНУ =====
TeleportZoneEvent.OnServerEvent:Connect(function(player, zoneName)
    local data = DataStoreHandler.GetData(player)
    if not data then return end

    -- Проверяем разблокировку
    local unlocked = false
    for _, uz in ipairs(data.UnlockedZones) do
        if uz == zoneName then
            unlocked = true
            break
        end
    end

    if not unlocked then
        NotificationEvent:FireClient(player, "Зона заблокирована!", Color3.fromRGB(255, 100, 100))
        return
    end

    local zone = ZoneConfig.GetZoneByName(zoneName)
    if not zone then return end

    data.CurrentZone = zoneName

    -- Телепортируем персонажа
    local character = player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(zone.SpawnPosition)
        end
    end

    NotificationEvent:FireClient(player, "Телепорт в '" .. zoneName .. "'!", Color3.fromRGB(100, 200, 255))
end)

-- ===== КОДЫ =====
RedeemCodeEvent.OnServerEvent:Connect(function(player, code)
    local data = DataStoreHandler.GetData(player)
    if not data then return end

    code = string.upper(tostring(code))
    local codeData = GameConfig.Codes[code]

    if not codeData then
        NotificationEvent:FireClient(player, "Неверный код!", Color3.fromRGB(255, 100, 100))
        return
    end

    -- Проверяем, использовал ли уже
    if data.UsedCodes[code] then
        NotificationEvent:FireClient(player, "Код уже использован!", Color3.fromRGB(255, 200, 0))
        return
    end

    -- Даём награду
    DataStoreHandler.AddCurrency(player, codeData.Reward, codeData.Amount)
    data.UsedCodes[code] = true

    local currencyName = GameConfig.Currencies[codeData.Reward] and GameConfig.Currencies[codeData.Reward].DisplayName or codeData.Reward
    NotificationEvent:FireClient(player, "Получено " .. codeData.Amount .. " " .. currencyName .. "!", Color3.fromRGB(100, 255, 100))

    UpdateUIEvent:FireClient(player, {
        Coins = data.Coins,
        Gems = data.Gems,
    })
end)

-- ===== ПОЛУЧЕНИЕ ДАННЫХ КЛИЕНТОМ =====
GetPlayerDataFunc.OnServerInvoke = function(player)
    local data = DataStoreHandler.GetData(player)
    if not data then return nil end
    return {
        Coins = data.Coins,
        Gems = data.Gems,
        Rebirths = data.Rebirths,
        Upgrades = data.Upgrades,
        Pets = data.Pets,
        UnlockedZones = data.UnlockedZones,
        CurrentZone = data.CurrentZone,
        DailyReward = data.DailyReward,
        TotalClicks = data.TotalClicks,
        TotalCoinsEarned = data.TotalCoinsEarned,
    }
end

-- ===== АВТОКЛИКЕР =====
spawn(function()
    while true do
        wait(1)
        for _, player in ipairs(Players:GetPlayers()) do
            local data = DataStoreHandler.GetData(player)
            if data then
                local autoLevel = data.Upgrades.AutoClicker or 0
                if autoLevel > 0 then
                    local autoPower = GameConfig.GetAutoClickPower(autoLevel, data.Rebirths)
                    local coinMultiplier = GameConfig.GetCoinMultiplier(data.Upgrades.CoinMultiplier, data.Rebirths)

                    local currentZone = ZoneConfig.GetZoneByName(data.CurrentZone)
                    local zoneMultiplier = currentZone and currentZone.CoinMultiplier or 1

                    local petMultiplier = 1
                    for _, pet in ipairs(data.Pets) do
                        if pet.Equipped then
                            petMultiplier = petMultiplier + (pet.Multiplier - 1)
                        end
                    end

                    local totalCoins = math.floor(autoPower * coinMultiplier * zoneMultiplier * petMultiplier)
                    DataStoreHandler.AddCurrency(player, "Coins", totalCoins)

                    UpdateUIEvent:FireClient(player, {
                        Coins = data.Coins,
                        Gems = data.Gems,
                        AutoCoins = totalCoins,
                    })
                end

                -- Обновляем время игры
                data.PlayTime = (data.PlayTime or 0) + 1
            end
        end
    end
end)

-- Очистка при выходе
Players.PlayerRemoving:Connect(function(player)
    lastClickTime[player.UserId] = nil
end)

print("[GameHandler] Loaded successfully!")
