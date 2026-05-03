--[[
    PetConfig - Конфигурация системы питомцев
    Размести этот ModuleScript в ReplicatedStorage/Modules/PetConfig
]]

local PetConfig = {}

-- ===== РЕДКОСТИ =====
PetConfig.Rarities = {
    Common = {
        DisplayName = "Обычный",
        Color = Color3.fromRGB(180, 180, 180),
        Chance = 0.50, -- 50%
        MultiplierRange = {1.0, 1.5},
    },
    Uncommon = {
        DisplayName = "Необычный",
        Color = Color3.fromRGB(0, 200, 0),
        Chance = 0.25, -- 25%
        MultiplierRange = {1.5, 2.5},
    },
    Rare = {
        DisplayName = "Редкий",
        Color = Color3.fromRGB(0, 100, 255),
        Chance = 0.15, -- 15%
        MultiplierRange = {2.5, 4.0},
    },
    Epic = {
        DisplayName = "Эпический",
        Color = Color3.fromRGB(160, 0, 255),
        Chance = 0.07, -- 7%
        MultiplierRange = {4.0, 7.0},
    },
    Legendary = {
        DisplayName = "Легендарный",
        Color = Color3.fromRGB(255, 200, 0),
        Chance = 0.025, -- 2.5%
        MultiplierRange = {7.0, 12.0},
    },
    Mythical = {
        DisplayName = "Мифический",
        Color = Color3.fromRGB(255, 50, 50),
        Chance = 0.005, -- 0.5%
        MultiplierRange = {12.0, 25.0},
    },
}

-- ===== ПИТОМЦЫ =====
PetConfig.Pets = {
    -- Обычные
    {Name = "Котик", Rarity = "Common", ModelId = "rbxassetid://0", Icon = "rbxassetid://0"},
    {Name = "Щенок", Rarity = "Common", ModelId = "rbxassetid://0", Icon = "rbxassetid://0"},
    {Name = "Хомячок", Rarity = "Common", ModelId = "rbxassetid://0", Icon = "rbxassetid://0"},
    {Name = "Кролик", Rarity = "Common", ModelId = "rbxassetid://0", Icon = "rbxassetid://0"},

    -- Необычные
    {Name = "Лисичка", Rarity = "Uncommon", ModelId = "rbxassetid://0", Icon = "rbxassetid://0"},
    {Name = "Панда", Rarity = "Uncommon", ModelId = "rbxassetid://0", Icon = "rbxassetid://0"},
    {Name = "Пингвин", Rarity = "Uncommon", ModelId = "rbxassetid://0", Icon = "rbxassetid://0"},

    -- Редкие
    {Name = "Единорог", Rarity = "Rare", ModelId = "rbxassetid://0", Icon = "rbxassetid://0"},
    {Name = "Волк", Rarity = "Rare", ModelId = "rbxassetid://0", Icon = "rbxassetid://0"},
    {Name = "Орёл", Rarity = "Rare", ModelId = "rbxassetid://0", Icon = "rbxassetid://0"},

    -- Эпические
    {Name = "Дракон", Rarity = "Epic", ModelId = "rbxassetid://0", Icon = "rbxassetid://0"},
    {Name = "Феникс", Rarity = "Epic", ModelId = "rbxassetid://0", Icon = "rbxassetid://0"},

    -- Легендарные
    {Name = "Космический Кот", Rarity = "Legendary", ModelId = "rbxassetid://0", Icon = "rbxassetid://0"},
    {Name = "Радужный Единорог", Rarity = "Legendary", ModelId = "rbxassetid://0", Icon = "rbxassetid://0"},

    -- Мифические
    {Name = "Тёмный Дракон", Rarity = "Mythical", ModelId = "rbxassetid://0", Icon = "rbxassetid://0"},
    {Name = "Небесный Страж", Rarity = "Mythical", ModelId = "rbxassetid://0", Icon = "rbxassetid://0"},
}

-- ===== ЯЙЦА =====
PetConfig.Eggs = {
    BasicEgg = {
        DisplayName = "Базовое Яйцо",
        Cost = 100,
        Currency = "Coins",
        Icon = "rbxassetid://0",
        AvailablePets = {"Котик", "Щенок", "Хомячок", "Кролик", "Лисичка", "Панда"},
        HatchTime = 1.5,
    },
    RareEgg = {
        DisplayName = "Редкое Яйцо",
        Cost = 1000,
        Currency = "Coins",
        Icon = "rbxassetid://0",
        AvailablePets = {"Пингвин", "Единорог", "Волк", "Орёл", "Дракон"},
        HatchTime = 2.0,
    },
    LegendaryEgg = {
        DisplayName = "Легендарное Яйцо",
        Cost = 50,
        Currency = "Gems",
        Icon = "rbxassetid://0",
        AvailablePets = {"Феникс", "Космический Кот", "Радужный Единорог", "Тёмный Дракон", "Небесный Страж"},
        HatchTime = 3.0,
    },
}

-- ===== НАСТРОЙКИ =====
PetConfig.Settings = {
    MaxEquipped = 3, -- максимум экипированных питомцев
    MaxInventory = 50, -- максимум питомцев в инвентаре
    FollowDistance = 5, -- расстояние следования за игроком
    FollowHeight = 3, -- высота полёта питомцев
    FollowSpeed = 16, -- скорость следования
    BobbingSpeed = 2, -- скорость покачивания
    BobbingHeight = 0.5, -- высота покачивания
}

-- ===== ФУНКЦИИ =====
function PetConfig.GetPetByName(name)
    for _, pet in ipairs(PetConfig.Pets) do
        if pet.Name == name then
            return pet
        end
    end
    return nil
end

function PetConfig.GetPetsForEgg(eggName)
    local egg = PetConfig.Eggs[eggName]
    if not egg then return {} end

    local pets = {}
    for _, petName in ipairs(egg.AvailablePets) do
        local pet = PetConfig.GetPetByName(petName)
        if pet then
            table.insert(pets, pet)
        end
    end
    return pets
end

function PetConfig.RollPet(eggName, luckBonus)
    luckBonus = luckBonus or 0
    local egg = PetConfig.Eggs[eggName]
    if not egg then return nil end

    local availablePets = PetConfig.GetPetsForEgg(eggName)
    if #availablePets == 0 then return nil end

    -- Собираем шансы с учётом удачи
    local totalWeight = 0
    local weights = {}

    for _, pet in ipairs(availablePets) do
        local rarity = PetConfig.Rarities[pet.Rarity]
        local chance = rarity.Chance

        -- Удача увеличивает шанс редких питомцев
        if pet.Rarity ~= "Common" then
            chance = chance * (1 + luckBonus)
        end

        table.insert(weights, {Pet = pet, Weight = chance})
        totalWeight = totalWeight + chance
    end

    -- Рандомный выбор
    local roll = math.random() * totalWeight
    local cumulative = 0

    for _, entry in ipairs(weights) do
        cumulative = cumulative + entry.Weight
        if roll <= cumulative then
            -- Рандомный множитель в диапазоне редкости
            local rarity = PetConfig.Rarities[entry.Pet.Rarity]
            local minMult = rarity.MultiplierRange[1]
            local maxMult = rarity.MultiplierRange[2]
            local multiplier = minMult + math.random() * (maxMult - minMult)
            multiplier = math.floor(multiplier * 100) / 100 -- округление до 2 знаков

            return {
                Name = entry.Pet.Name,
                Rarity = entry.Pet.Rarity,
                Multiplier = multiplier,
                UniqueId = game:GetService("HttpService"):GenerateGUID(false),
            }
        end
    end

    return nil
end

return PetConfig
