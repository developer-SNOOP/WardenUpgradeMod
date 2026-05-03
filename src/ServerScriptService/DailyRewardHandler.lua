--[[
    DailyRewardHandler - Система ежедневных наград
    Размести этот Script в ServerScriptService/DailyRewardHandler
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local GameConfig = require(Modules:WaitForChild("GameConfig"))
local Utilities = require(Modules:WaitForChild("Utilities"))

local DataStoreHandler = require(ServerScriptService:WaitForChild("DataStoreHandler"))

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ClaimDailyRewardEvent = RemoteEvents:WaitForChild("ClaimDailyReward")
local DailyRewardUpdateEvent = RemoteEvents:WaitForChild("DailyRewardUpdate")
local NotificationEvent = RemoteEvents:WaitForChild("Notification")
local UpdateUIEvent = RemoteEvents:WaitForChild("UpdateUI")

-- ===== ПРОВЕРКА ПРИ ВХОДЕ =====
Players.PlayerAdded:Connect(function(player)
    wait(2) -- Ждём загрузки данных

    local data = DataStoreHandler.GetData(player)
    if not data then return end

    local dailyData = data.DailyReward
    local canClaim = Utilities.Has24HoursPassed(dailyData.LastClaim)

    DailyRewardUpdateEvent:FireClient(player, {
        CanClaim = canClaim,
        CurrentStreak = dailyData.Streak,
        LastClaim = dailyData.LastClaim,
        Rewards = GameConfig.DailyRewards,
    })
end)

-- ===== ПОЛУЧЕНИЕ НАГРАДЫ =====
ClaimDailyRewardEvent.OnServerEvent:Connect(function(player)
    local data = DataStoreHandler.GetData(player)
    if not data then return end

    local dailyData = data.DailyReward

    -- Проверяем, прошло ли 24 часа
    if not Utilities.Has24HoursPassed(dailyData.LastClaim) then
        local timeLeft = 86400 - (os.time() - dailyData.LastClaim)
        NotificationEvent:FireClient(player, "Следующая награда через " .. Utilities.FormatTime(timeLeft), Color3.fromRGB(255, 200, 0))
        return
    end

    -- Обновляем стрик
    local timeSinceLastClaim = os.time() - (dailyData.LastClaim or 0)
    if timeSinceLastClaim > 172800 then -- Больше 48 часов - сброс стрика
        dailyData.Streak = 0
    end

    dailyData.Streak = dailyData.Streak + 1
    if dailyData.Streak > #GameConfig.DailyRewards then
        dailyData.Streak = 1 -- Начинаем заново после 7 дней
    end

    dailyData.LastClaim = os.time()

    -- Получаем награду
    local rewardData = GameConfig.DailyRewards[dailyData.Streak]
    if rewardData then
        DataStoreHandler.AddCurrency(player, rewardData.Reward, rewardData.Amount)

        NotificationEvent:FireClient(player, "Ежедневная награда (день " .. dailyData.Streak .. "): " .. rewardData.DisplayName .. "!", Color3.fromRGB(100, 255, 100))

        DailyRewardUpdateEvent:FireClient(player, {
            CanClaim = false,
            CurrentStreak = dailyData.Streak,
            LastClaim = dailyData.LastClaim,
            Rewards = GameConfig.DailyRewards,
            JustClaimed = rewardData,
        })

        UpdateUIEvent:FireClient(player, {
            Coins = data.Coins,
            Gems = data.Gems,
        })
    end
end)

print("[DailyRewardHandler] Loaded successfully!")
