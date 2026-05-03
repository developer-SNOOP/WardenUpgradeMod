--[[
    WorldBuilder - Автоматическое построение игрового мира
    Размести этот Script в ServerScriptService/WorldBuilder

    Этот скрипт автоматически генерирует зоны, объекты для кликов,
    яйца питомцев и декорации при запуске сервера.
]]

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local ZoneConfig = require(Modules:WaitForChild("ZoneConfig"))
local PetConfig = require(Modules:WaitForChild("PetConfig"))

-- ===== НАСТРОЙКИ ОСВЕЩЕНИЯ =====
local function setupLighting()
    Lighting.Ambient = Color3.fromRGB(150, 150, 150)
    Lighting.Brightness = 2
    Lighting.ClockTime = 12
    Lighting.FogEnd = 10000
    Lighting.GlobalShadows = true

    -- Bloom эффект
    local bloom = Instance.new("BloomEffect")
    bloom.Intensity = 0.3
    bloom.Size = 24
    bloom.Threshold = 0.9
    bloom.Parent = Lighting

    -- SunRays
    local sunRays = Instance.new("SunRaysEffect")
    sunRays.Intensity = 0.05
    sunRays.Spread = 0.5
    sunRays.Parent = Lighting

    -- ColorCorrection
    local cc = Instance.new("ColorCorrectionEffect")
    cc.Brightness = 0.05
    cc.Contrast = 0.1
    cc.Saturation = 0.2
    cc.Parent = Lighting
end

-- ===== СОЗДАНИЕ КЛИКАБЕЛЬНОГО ОБЪЕКТА =====
local function createClickObject(parent, position, size, color, name)
    local part = Instance.new("Part")
    part.Name = name or "ClickBlock"
    part.Size = size or Vector3.new(6, 6, 6)
    part.Position = position
    part.Color = color or Color3.fromRGB(255, 215, 0)
    part.Material = Enum.Material.Neon
    part.Anchored = true
    part.CanCollide = true
    part.Parent = parent

    -- Добавляем ClickDetector
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.MaxActivationDistance = 32
    clickDetector.Parent = part

    -- Текст сверху
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "КЛИКАЙ!"
    label.TextColor3 = Color3.fromRGB(255, 255, 0)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0
    label.Parent = billboard

    -- Подсветка
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color or Color3.fromRGB(255, 215, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Parent = part

    return part
end

-- ===== СОЗДАНИЕ ЯЙЦА =====
local function createEggObject(parent, position, eggName, eggData)
    local egg = Instance.new("Part")
    egg.Name = "Egg_" .. eggName
    egg.Shape = Enum.PartType.Ball
    egg.Size = Vector3.new(5, 7, 5)
    egg.Position = position
    egg.Color = Color3.fromRGB(255, 200, 100)
    egg.Material = Enum.Material.SmoothPlastic
    egg.Anchored = true
    egg.CanCollide = true
    egg.Parent = parent

    -- Деформация для формы яйца
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.Sphere
    mesh.Scale = Vector3.new(0.8, 1, 0.8)
    mesh.Parent = egg

    -- ClickDetector
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.MaxActivationDistance = 20
    clickDetector.Parent = egg

    -- Текст
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 250, 0, 80)
    billboard.StudsOffset = Vector3.new(0, 5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = egg

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = eggData.DisplayName
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Parent = billboard

    local costLabel = Instance.new("TextLabel")
    costLabel.Size = UDim2.new(1, 0, 0.5, 0)
    costLabel.Position = UDim2.new(0, 0, 0.5, 0)
    costLabel.BackgroundTransparency = 1
    costLabel.Text = eggData.Cost .. " " .. (eggData.Currency == "Coins" and "Монет" or "Кристаллов")
    costLabel.TextColor3 = eggData.Currency == "Coins" and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(0, 200, 255)
    costLabel.TextScaled = true
    costLabel.Font = Enum.Font.GothamSemibold
    costLabel.TextStrokeTransparency = 0
    costLabel.Parent = billboard

    -- Подсветка
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 200, 100)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.Parent = egg

    -- Атрибут для идентификации
    egg:SetAttribute("EggName", eggName)

    -- Партиклы
    local attachment = Instance.new("Attachment")
    attachment.Parent = egg

    local sparkles = Instance.new("ParticleEmitter")
    sparkles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    sparkles.Rate = 10
    sparkles.Lifetime = NumberRange.new(0.5, 1.5)
    sparkles.Speed = NumberRange.new(1, 3)
    sparkles.SpreadAngle = Vector2.new(180, 180)
    sparkles.Size = NumberSequence.new(0.3, 0)
    sparkles.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
    sparkles.Parent = attachment

    return egg
end

-- ===== СОЗДАНИЕ ПОРТАЛА ЗОНЫ =====
local function createZonePortal(parent, position, zone, nextZone)
    local portal = Instance.new("Part")
    portal.Name = "Portal_" .. (nextZone and nextZone.Name or "End")
    portal.Size = Vector3.new(10, 15, 2)
    portal.Position = position
    portal.Color = nextZone and nextZone.Color or Color3.fromRGB(128, 128, 128)
    portal.Material = Enum.Material.ForceField
    portal.Anchored = true
    portal.CanCollide = false
    portal.Transparency = 0.3
    portal.Parent = parent

    -- Текст портала
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 300, 0, 100)
    billboard.StudsOffset = Vector3.new(0, 9, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = portal

    if nextZone then
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = nextZone.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextStrokeTransparency = 0
        nameLabel.Parent = billboard

        local costLabel = Instance.new("TextLabel")
        costLabel.Size = UDim2.new(1, 0, 0.5, 0)
        costLabel.Position = UDim2.new(0, 0, 0.5, 0)
        costLabel.BackgroundTransparency = 1
        costLabel.Text = nextZone.UnlockCost .. " " .. (nextZone.UnlockCurrency == "Coins" and "Монет" or "Кристаллов")
        costLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        costLabel.TextScaled = true
        costLabel.Font = Enum.Font.GothamSemibold
        costLabel.TextStrokeTransparency = 0
        costLabel.Parent = billboard
    end

    portal:SetAttribute("NextZone", nextZone and nextZone.Name or "")

    return portal
end

-- ===== СОЗДАНИЕ ЗОНЫ =====
local function buildZone(zone)
    local zoneFolder = Instance.new("Folder")
    zoneFolder.Name = "Zone_" .. zone.Name
    zoneFolder.Parent = Workspace

    -- Платформа зоны
    local platform = Instance.new("Part")
    platform.Name = "Platform"
    platform.Size = zone.Size + Vector3.new(0, 2, 0)
    platform.Position = zone.SpawnPosition - Vector3.new(0, 3, 0)
    platform.Color = zone.Color
    platform.Material = Enum.Material.Grass
    platform.Anchored = true
    platform.CanCollide = true
    platform.Parent = zoneFolder

    -- Стены (невидимые)
    local wallHeight = 30
    local walls = {
        {size = Vector3.new(zone.Size.X, wallHeight, 2), pos = zone.SpawnPosition + Vector3.new(0, wallHeight/2 - 3, zone.Size.Z/2)},
        {size = Vector3.new(zone.Size.X, wallHeight, 2), pos = zone.SpawnPosition + Vector3.new(0, wallHeight/2 - 3, -zone.Size.Z/2)},
        {size = Vector3.new(2, wallHeight, zone.Size.Z), pos = zone.SpawnPosition + Vector3.new(zone.Size.X/2, wallHeight/2 - 3, 0)},
        {size = Vector3.new(2, wallHeight, zone.Size.Z), pos = zone.SpawnPosition + Vector3.new(-zone.Size.X/2, wallHeight/2 - 3, 0)},
    }

    for i, wallData in ipairs(walls) do
        local wall = Instance.new("Part")
        wall.Name = "Wall_" .. i
        wall.Size = wallData.size
        wall.Position = wallData.pos
        wall.Transparency = 1
        wall.Anchored = true
        wall.CanCollide = true
        wall.Parent = zoneFolder
    end

    -- Спавн-точка
    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "SpawnPoint"
    spawn.Size = Vector3.new(6, 1, 6)
    spawn.Position = zone.SpawnPosition
    spawn.Color = Color3.fromRGB(255, 255, 255)
    spawn.Anchored = true
    spawn.CanCollide = true
    spawn.Neutral = true
    spawn.Parent = zoneFolder

    -- Кликабельный объект в центре
    local clickPos = zone.SpawnPosition + Vector3.new(0, 5, -15)
    createClickObject(zoneFolder, clickPos, Vector3.new(8, 8, 8), zone.Color, "MainClickBlock")

    -- Дополнительные кликабельные объекты
    for i = 1, 3 do
        local angle = (i - 1) * (2 * math.pi / 3)
        local offset = Vector3.new(math.cos(angle) * 20, 4, math.sin(angle) * 20 - 15)
        createClickObject(zoneFolder, zone.SpawnPosition + offset, Vector3.new(5, 5, 5), zone.Color, "ClickBlock_" .. i)
    end

    -- Табличка с названием зоны
    local signboard = Instance.new("Part")
    signboard.Name = "ZoneSign"
    signboard.Size = Vector3.new(15, 8, 1)
    signboard.Position = zone.SpawnPosition + Vector3.new(0, 7, 20)
    signboard.Color = Color3.fromRGB(60, 40, 20)
    signboard.Material = Enum.Material.Wood
    signboard.Anchored = true
    signboard.Parent = zoneFolder

    local signGui = Instance.new("SurfaceGui")
    signGui.Face = Enum.NormalId.Front
    signGui.Parent = signboard

    local signText = Instance.new("TextLabel")
    signText.Size = UDim2.new(1, 0, 0.6, 0)
    signText.BackgroundTransparency = 1
    signText.Text = zone.Name
    signText.TextColor3 = Color3.fromRGB(255, 255, 255)
    signText.TextScaled = true
    signText.Font = Enum.Font.GothamBold
    signText.Parent = signGui

    local descText = Instance.new("TextLabel")
    descText.Size = UDim2.new(1, 0, 0.4, 0)
    descText.Position = UDim2.new(0, 0, 0.6, 0)
    descText.BackgroundTransparency = 1
    descText.Text = zone.Description
    descText.TextColor3 = Color3.fromRGB(200, 200, 200)
    descText.TextScaled = true
    descText.Font = Enum.Font.Gotham
    descText.Parent = signGui

    -- Декорации (деревья/камни)
    for i = 1, 8 do
        local angle = (i / 8) * math.pi * 2
        local radius = zone.Size.X / 3
        local treePos = zone.SpawnPosition + Vector3.new(
            math.cos(angle) * radius,
            0,
            math.sin(angle) * radius
        )

        -- Ствол
        local trunk = Instance.new("Part")
        trunk.Name = "Tree_" .. i
        trunk.Size = Vector3.new(2, 8, 2)
        trunk.Position = treePos + Vector3.new(0, 4, 0)
        trunk.Color = Color3.fromRGB(101, 67, 33)
        trunk.Material = Enum.Material.Wood
        trunk.Anchored = true
        trunk.Parent = zoneFolder

        -- Крона
        local leaves = Instance.new("Part")
        leaves.Name = "Leaves_" .. i
        leaves.Shape = Enum.PartType.Ball
        leaves.Size = Vector3.new(8, 8, 8)
        leaves.Position = treePos + Vector3.new(0, 10, 0)
        leaves.Color = zone.Color
        leaves.Material = Enum.Material.Grass
        leaves.Anchored = true
        leaves.Parent = zoneFolder
    end

    return zoneFolder
end

-- ===== ПОСТРОЕНИЕ МИРА =====
local function buildWorld()
    print("[WorldBuilder] Building world...")

    -- Настройка освещения
    setupLighting()

    -- Удаляем дефолтную Baseplate
    local basePlate = Workspace:FindFirstChild("Baseplate")
    if basePlate then
        basePlate:Destroy()
    end

    -- Строим каждую зону
    for i, zone in ipairs(ZoneConfig.Zones) do
        local zoneFolder = buildZone(zone)

        -- Яйца в первых зонах
        if i <= 3 then
            local eggNames = {}
            if i == 1 then eggNames = {"BasicEgg"} end
            if i == 2 then eggNames = {"BasicEgg", "RareEgg"} end
            if i == 3 then eggNames = {"RareEgg", "LegendaryEgg"} end

            for j, eggName in ipairs(eggNames) do
                local eggData = PetConfig.Eggs[eggName]
                if eggData then
                    local offset = Vector3.new(-15 + (j - 1) * 15, 4, 15)
                    createEggObject(zoneFolder, zone.SpawnPosition + offset, eggName, eggData)
                end
            end
        end

        -- Портал к следующей зоне
        local nextZone = ZoneConfig.GetZoneByOrder(i + 1)
        if nextZone then
            local portalPos = zone.SpawnPosition + Vector3.new(zone.Size.X / 2 + 5, 5, 0)
            createZonePortal(zoneFolder, portalPos, zone, nextZone)
        end
    end

    print("[WorldBuilder] World built successfully! (" .. #ZoneConfig.Zones .. " zones)")
end

-- Запускаем построение
buildWorld()
