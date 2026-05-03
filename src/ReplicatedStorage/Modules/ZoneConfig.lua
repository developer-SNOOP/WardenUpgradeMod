--[[
    ZoneConfig - Конфигурация зон/миров
    Размести этот ModuleScript в ReplicatedStorage/Modules/ZoneConfig
]]

local ZoneConfig = {}

-- ===== ЗОНЫ =====
ZoneConfig.Zones = {
    {
        Name = "Начальная поляна",
        Order = 1,
        UnlockCost = 0,
        UnlockCurrency = "Coins",
        CoinMultiplier = 1.0,
        GemChance = 0.01, -- 1% шанс получить кристалл
        Description = "Уютная поляна для начинающих",
        Color = Color3.fromRGB(100, 200, 100),
        SpawnPosition = Vector3.new(0, 5, 0),
        Size = Vector3.new(100, 1, 100),
    },
    {
        Name = "Лесная чаща",
        Order = 2,
        UnlockCost = 5000,
        UnlockCurrency = "Coins",
        CoinMultiplier = 2.0,
        GemChance = 0.02,
        Description = "Густой лес с удвоенными наградами",
        Color = Color3.fromRGB(34, 139, 34),
        SpawnPosition = Vector3.new(150, 5, 0),
        Size = Vector3.new(120, 1, 120),
    },
    {
        Name = "Пустыня сокровищ",
        Order = 3,
        UnlockCost = 25000,
        UnlockCurrency = "Coins",
        CoinMultiplier = 4.0,
        GemChance = 0.04,
        Description = "Жаркая пустыня полная сокровищ",
        Color = Color3.fromRGB(237, 201, 175),
        SpawnPosition = Vector3.new(300, 5, 0),
        Size = Vector3.new(140, 1, 140),
    },
    {
        Name = "Ледяные горы",
        Order = 4,
        UnlockCost = 100000,
        UnlockCurrency = "Coins",
        CoinMultiplier = 8.0,
        GemChance = 0.06,
        Description = "Замёрзшие горы с огромными наградами",
        Color = Color3.fromRGB(173, 216, 230),
        SpawnPosition = Vector3.new(500, 5, 0),
        Size = Vector3.new(160, 1, 160),
    },
    {
        Name = "Вулканический остров",
        Order = 5,
        UnlockCost = 500000,
        UnlockCurrency = "Coins",
        CoinMultiplier = 16.0,
        GemChance = 0.10,
        Description = "Опасный вулкан с невероятными наградами",
        Color = Color3.fromRGB(178, 34, 34),
        SpawnPosition = Vector3.new(750, 5, 0),
        Size = Vector3.new(180, 1, 180),
    },
    {
        Name = "Облачный мир",
        Order = 6,
        UnlockCost = 2000000,
        UnlockCurrency = "Coins",
        CoinMultiplier = 32.0,
        GemChance = 0.15,
        Description = "Небесный мир среди облаков",
        Color = Color3.fromRGB(200, 220, 255),
        SpawnPosition = Vector3.new(1000, 100, 0),
        Size = Vector3.new(200, 1, 200),
    },
    {
        Name = "Космическая станция",
        Order = 7,
        UnlockCost = 100,
        UnlockCurrency = "Gems",
        CoinMultiplier = 64.0,
        GemChance = 0.20,
        Description = "Космическая станция - высшая зона!",
        Color = Color3.fromRGB(20, 20, 50),
        SpawnPosition = Vector3.new(1300, 200, 0),
        Size = Vector3.new(250, 1, 250),
    },
}

-- ===== ФУНКЦИИ =====
function ZoneConfig.GetZoneByName(name)
    for _, zone in ipairs(ZoneConfig.Zones) do
        if zone.Name == name then
            return zone
        end
    end
    return nil
end

function ZoneConfig.GetZoneByOrder(order)
    for _, zone in ipairs(ZoneConfig.Zones) do
        if zone.Order == order then
            return zone
        end
    end
    return nil
end

function ZoneConfig.GetNextZone(currentZoneName)
    local current = ZoneConfig.GetZoneByName(currentZoneName)
    if not current then return nil end
    return ZoneConfig.GetZoneByOrder(current.Order + 1)
end

function ZoneConfig.CanUnlockZone(zoneName, playerCoins, playerGems)
    local zone = ZoneConfig.GetZoneByName(zoneName)
    if not zone then return false end

    if zone.UnlockCurrency == "Coins" then
        return playerCoins >= zone.UnlockCost
    elseif zone.UnlockCurrency == "Gems" then
        return playerGems >= zone.UnlockCost
    end
    return false
end

return ZoneConfig
