--[[
    GameConfig - Главная конфигурация симулятора
    Размести этот ModuleScript в ReplicatedStorage/Modules/GameConfig
]]

local GameConfig = {}

-- ===== ОСНОВНЫЕ НАСТРОЙКИ =====
GameConfig.GAME_NAME = "Ultimate Click Simulator"
GameConfig.VERSION = "1.0.0"
GameConfig.AUTO_SAVE_INTERVAL = 60 -- секунды между автосохранениями

-- ===== ВАЛЮТЫ =====
GameConfig.Currencies = {
    Coins = {
        DisplayName = "Монеты",
        Icon = "rbxassetid://0", -- замени на свой ID иконки
        StartAmount = 0,
        Color = Color3.fromRGB(255, 215, 0),
    },
    Gems = {
        DisplayName = "Кристаллы",
        Icon = "rbxassetid://0",
        StartAmount = 0,
        Color = Color3.fromRGB(0, 200, 255),
    },
}

-- ===== КЛИК =====
GameConfig.Click = {
    BasePower = 1, -- базовая сила клика
    Cooldown = 0.1, -- задержка между кликами (секунды)
}

-- ===== АПГРЕЙДЫ =====
GameConfig.Upgrades = {
    ClickPower = {
        DisplayName = "Сила клика",
        Description = "Увеличивает количество монет за клик",
        Icon = "rbxassetid://0",
        MaxLevel = 100,
        BaseCost = 50,
        CostMultiplier = 1.5, -- каждый уровень дороже в 1.5 раза
        PowerPerLevel = 1, -- +1 к силе клика за уровень
        Currency = "Coins",
    },
    AutoClicker = {
        DisplayName = "Авто-кликер",
        Description = "Автоматически зарабатывает монеты каждую секунду",
        Icon = "rbxassetid://0",
        MaxLevel = 50,
        BaseCost = 200,
        CostMultiplier = 1.8,
        PowerPerLevel = 2, -- +2 монет в секунду за уровень
        Currency = "Coins",
    },
    LuckBoost = {
        DisplayName = "Удача",
        Description = "Увеличивает шанс выпадения редких питомцев",
        Icon = "rbxassetid://0",
        MaxLevel = 25,
        BaseCost = 500,
        CostMultiplier = 2.0,
        PowerPerLevel = 0.02, -- +2% удачи за уровень
        Currency = "Gems",
    },
    CoinMultiplier = {
        DisplayName = "Множитель монет",
        Description = "Умножает все заработанные монеты",
        Icon = "rbxassetid://0",
        MaxLevel = 20,
        BaseCost = 1000,
        CostMultiplier = 2.5,
        PowerPerLevel = 0.1, -- +10% к множителю за уровень
        Currency = "Gems",
    },
}

-- ===== ПЕРЕРОЖДЕНИЕ (REBIRTH) =====
GameConfig.Rebirth = {
    BaseCost = 10000, -- стоимость первого перерождения
    CostMultiplier = 2.0, -- каждое перерождение дороже в 2 раза
    BonusPerRebirth = 0.25, -- +25% ко всем доходам за перерождение
    MaxRebirths = 100,
    Currency = "Coins",
    ResetUpgrades = true, -- сбрасывать ли апгрейды при перерождении
    KeepPets = true, -- сохранять ли питомцев при перерождении
}

-- ===== ЕЖЕДНЕВНЫЕ НАГРАДЫ =====
GameConfig.DailyRewards = {
    {Day = 1, Reward = "Coins", Amount = 100, DisplayName = "100 Монет"},
    {Day = 2, Reward = "Coins", Amount = 250, DisplayName = "250 Монет"},
    {Day = 3, Reward = "Gems", Amount = 5, DisplayName = "5 Кристаллов"},
    {Day = 4, Reward = "Coins", Amount = 500, DisplayName = "500 Монет"},
    {Day = 5, Reward = "Gems", Amount = 15, DisplayName = "15 Кристаллов"},
    {Day = 6, Reward = "Coins", Amount = 1000, DisplayName = "1000 Монет"},
    {Day = 7, Reward = "Gems", Amount = 50, DisplayName = "50 Кристаллов"},
}

-- ===== КОДЫ =====
GameConfig.Codes = {
    RELEASE = {Reward = "Coins", Amount = 500, MaxUses = 1},
    GEMS = {Reward = "Gems", Amount = 25, MaxUses = 1},
    SIMULATOR = {Reward = "Coins", Amount = 1000, MaxUses = 1},
    PETS = {Reward = "Gems", Amount = 50, MaxUses = 1},
    LIKE = {Reward = "Coins", Amount = 2000, MaxUses = 1},
}

-- ===== ФУНКЦИИ-ХЕЛПЕРЫ =====
function GameConfig.GetUpgradeCost(upgradeName, currentLevel)
    local upgrade = GameConfig.Upgrades[upgradeName]
    if not upgrade then return math.huge end
    if currentLevel >= upgrade.MaxLevel then return math.huge end
    return math.floor(upgrade.BaseCost * (upgrade.CostMultiplier ^ currentLevel))
end

function GameConfig.GetRebirthCost(currentRebirths)
    return math.floor(GameConfig.Rebirth.BaseCost * (GameConfig.Rebirth.CostMultiplier ^ currentRebirths))
end

function GameConfig.GetClickPower(clickLevel, rebirths)
    local basePower = GameConfig.Click.BasePower + (clickLevel * GameConfig.Upgrades.ClickPower.PowerPerLevel)
    local rebirthBonus = 1 + (rebirths * GameConfig.Rebirth.BonusPerRebirth)
    return math.floor(basePower * rebirthBonus)
end

function GameConfig.GetAutoClickPower(autoLevel, rebirths)
    local basePower = autoLevel * GameConfig.Upgrades.AutoClicker.PowerPerLevel
    local rebirthBonus = 1 + (rebirths * GameConfig.Rebirth.BonusPerRebirth)
    return math.floor(basePower * rebirthBonus)
end

function GameConfig.GetCoinMultiplier(multiplierLevel, rebirths)
    local baseMultiplier = 1 + (multiplierLevel * GameConfig.Upgrades.CoinMultiplier.PowerPerLevel)
    local rebirthBonus = 1 + (rebirths * GameConfig.Rebirth.BonusPerRebirth)
    return baseMultiplier * rebirthBonus
end

return GameConfig
