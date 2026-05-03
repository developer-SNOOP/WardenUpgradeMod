--[[
    RebirthHandler - Система перерождений
    Размести этот Script в ServerScriptService/RebirthHandler
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local GameConfig = require(Modules:WaitForChild("GameConfig"))

local DataStoreHandler = require(ServerScriptService:WaitForChild("DataStoreHandler"))

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local DoRebirthEvent = RemoteEvents:WaitForChild("DoRebirth")
local RebirthUpdateEvent = RemoteEvents:WaitForChild("RebirthUpdate")
local NotificationEvent = RemoteEvents:WaitForChild("Notification")
local UpdateUIEvent = RemoteEvents:WaitForChild("UpdateUI")

-- ===== ПЕРЕРОЖДЕНИЕ =====
DoRebirthEvent.OnServerEvent:Connect(function(player)
    local data = DataStoreHandler.GetData(player)
    if not data then return end

    local currentRebirths = data.Rebirths or 0

    if currentRebirths >= GameConfig.Rebirth.MaxRebirths then
        NotificationEvent:FireClient(player, "Максимум перерождений достигнут!", Color3.fromRGB(255, 100, 100))
        return
    end

    local cost = GameConfig.GetRebirthCost(currentRebirths)

    if (data[GameConfig.Rebirth.Currency] or 0) < cost then
        NotificationEvent:FireClient(player, "Нужно " .. cost .. " монет для перерождения!", Color3.fromRGB(255, 100, 100))
        return
    end

    -- Выполняем перерождение
    data[GameConfig.Rebirth.Currency] = 0
    data.Rebirths = currentRebirths + 1

    -- Сбрасываем апгрейды если настроено
    if GameConfig.Rebirth.ResetUpgrades then
        for upgradeName, _ in pairs(data.Upgrades) do
            data.Upgrades[upgradeName] = 0
        end
    end

    -- Сбрасываем монеты и кристаллы
    data.Coins = 0
    -- Кристаллы не сбрасываются (премиум валюта)

    -- Сбрасываем зоны (оставляем только первую)
    data.UnlockedZones = {"Начальная поляна"}
    data.CurrentZone = "Начальная поляна"

    -- Обновляем leaderstats
    DataStoreHandler.UpdateLeaderstats(player)

    -- Телепортируем на старт
    local character = player.Character
    if character then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(0, 5, 0)
        end
    end

    local newBonus = math.floor(data.Rebirths * GameConfig.Rebirth.BonusPerRebirth * 100)

    NotificationEvent:FireClient(player, "Перерождение #" .. data.Rebirths .. "! Бонус: +" .. newBonus .. "% ко всем доходам!", Color3.fromRGB(255, 215, 0))

    -- Оповещение всех
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            NotificationEvent:FireClient(otherPlayer,
                player.Name .. " совершил перерождение #" .. data.Rebirths .. "!",
                Color3.fromRGB(255, 215, 0)
            )
        end
    end

    RebirthUpdateEvent:FireClient(player, {
        Rebirths = data.Rebirths,
        Bonus = newBonus,
    })

    UpdateUIEvent:FireClient(player, {
        Coins = data.Coins,
        Gems = data.Gems,
        Rebirths = data.Rebirths,
        Upgrades = data.Upgrades,
        UnlockedZones = data.UnlockedZones,
    })
end)

print("[RebirthHandler] Loaded successfully!")
