--[[
    DataStoreHandler - Сохранение и загрузка данных игроков
    Размести этот Script в ServerScriptService/DataStoreHandler
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local GameConfig = require(Modules:WaitForChild("GameConfig"))

local PlayerDataStore = DataStoreService:GetDataStore("PlayerData_v1")

local DataStoreHandler = {}
DataStoreHandler.PlayerData = {}

-- Шаблон данных нового игрока
local DEFAULT_DATA = {
    Coins = 0,
    Gems = 0,
    Rebirths = 0,
    Upgrades = {
        ClickPower = 0,
        AutoClicker = 0,
        LuckBoost = 0,
        CoinMultiplier = 0,
    },
    Pets = {}, -- {Name, Rarity, Multiplier, UniqueId, Equipped}
    UnlockedZones = {"Начальная поляна"},
    CurrentZone = "Начальная поляна",
    DailyReward = {
        LastClaim = 0,
        Streak = 0,
    },
    UsedCodes = {},
    TotalClicks = 0,
    TotalCoinsEarned = 0,
    PlayTime = 0,
    JoinDate = 0,
    LastSave = 0,
}

-- Загрузка данных игрока
function DataStoreHandler.LoadData(player)
    local key = "Player_" .. player.UserId
    local data = nil
    local success, err = pcall(function()
        data = PlayerDataStore:GetAsync(key)
    end)

    if success then
        if data then
            -- Мигрировать недостающие поля из шаблона
            for k, v in pairs(DEFAULT_DATA) do
                if data[k] == nil then
                    if type(v) == "table" then
                        data[k] = {}
                        for k2, v2 in pairs(v) do
                            data[k][k2] = v2
                        end
                    else
                        data[k] = v
                    end
                end
            end
            -- Проверяем подтаблицы Upgrades
            for k, v in pairs(DEFAULT_DATA.Upgrades) do
                if data.Upgrades[k] == nil then
                    data.Upgrades[k] = v
                end
            end
        else
            -- Новый игрок
            data = {}
            for k, v in pairs(DEFAULT_DATA) do
                if type(v) == "table" then
                    data[k] = {}
                    for k2, v2 in pairs(v) do
                        data[k][k2] = v2
                    end
                else
                    data[k] = v
                end
            end
            data.JoinDate = os.time()
        end
    else
        warn("[DataStore] Failed to load data for " .. player.Name .. ": " .. tostring(err))
        -- Даём дефолтные данные чтобы игрок мог играть
        data = {}
        for k, v in pairs(DEFAULT_DATA) do
            if type(v) == "table" then
                data[k] = {}
                for k2, v2 in pairs(v) do
                    data[k][k2] = v2
                end
            else
                data[k] = v
            end
        end
        data.JoinDate = os.time()
    end

    DataStoreHandler.PlayerData[player.UserId] = data

    -- Обновляем leaderstats
    DataStoreHandler.UpdateLeaderstats(player)

    return data
end

-- Сохранение данных игрока
function DataStoreHandler.SaveData(player)
    local data = DataStoreHandler.PlayerData[player.UserId]
    if not data then return false end

    data.LastSave = os.time()
    local key = "Player_" .. player.UserId

    local success, err = pcall(function()
        PlayerDataStore:SetAsync(key, data)
    end)

    if not success then
        warn("[DataStore] Failed to save data for " .. player.Name .. ": " .. tostring(err))
    end

    return success
end

-- Получить данные игрока
function DataStoreHandler.GetData(player)
    return DataStoreHandler.PlayerData[player.UserId]
end

-- Добавить валюту
function DataStoreHandler.AddCurrency(player, currencyName, amount)
    local data = DataStoreHandler.PlayerData[player.UserId]
    if not data then return false end

    data[currencyName] = (data[currencyName] or 0) + amount
    if currencyName == "Coins" then
        data.TotalCoinsEarned = (data.TotalCoinsEarned or 0) + amount
    end

    DataStoreHandler.UpdateLeaderstats(player)
    return true
end

-- Потратить валюту
function DataStoreHandler.SpendCurrency(player, currencyName, amount)
    local data = DataStoreHandler.PlayerData[player.UserId]
    if not data then return false end

    if (data[currencyName] or 0) < amount then
        return false
    end

    data[currencyName] = data[currencyName] - amount
    DataStoreHandler.UpdateLeaderstats(player)
    return true
end

-- Обновить leaderstats
function DataStoreHandler.UpdateLeaderstats(player)
    local data = DataStoreHandler.PlayerData[player.UserId]
    if not data then return end

    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = player
    end

    -- Монеты
    local coins = leaderstats:FindFirstChild("Coins")
    if not coins then
        coins = Instance.new("IntValue")
        coins.Name = "Coins"
        coins.Parent = leaderstats
    end
    coins.Value = math.floor(data.Coins or 0)

    -- Кристаллы
    local gems = leaderstats:FindFirstChild("Gems")
    if not gems then
        gems = Instance.new("IntValue")
        gems.Name = "Gems"
        gems.Parent = leaderstats
    end
    gems.Value = math.floor(data.Gems or 0)

    -- Перерождения
    local rebirths = leaderstats:FindFirstChild("Rebirths")
    if not rebirths then
        rebirths = Instance.new("IntValue")
        rebirths.Name = "Rebirths"
        rebirths.Parent = leaderstats
    end
    rebirths.Value = data.Rebirths or 0
end

-- Подключение игроков
Players.PlayerAdded:Connect(function(player)
    DataStoreHandler.LoadData(player)
end)

Players.PlayerRemoving:Connect(function(player)
    DataStoreHandler.SaveData(player)
    DataStoreHandler.PlayerData[player.UserId] = nil
end)

-- Автосохранение
spawn(function()
    while true do
        wait(GameConfig.AUTO_SAVE_INTERVAL)
        for _, player in ipairs(Players:GetPlayers()) do
            DataStoreHandler.SaveData(player)
        end
    end
end)

-- Сохранение при выключении сервера
game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        DataStoreHandler.SaveData(player)
    end
end)

return DataStoreHandler
