--[[
    Utilities - Вспомогательные функции
    Размести этот ModuleScript в ReplicatedStorage/Modules/Utilities
]]

local Utilities = {}

-- Форматирование больших чисел (1000 -> 1K, 1000000 -> 1M)
function Utilities.FormatNumber(number)
    if number < 1000 then
        return tostring(math.floor(number))
    elseif number < 1000000 then
        return string.format("%.1fK", number / 1000)
    elseif number < 1000000000 then
        return string.format("%.1fM", number / 1000000)
    elseif number < 1000000000000 then
        return string.format("%.1fB", number / 1000000000)
    else
        return string.format("%.1fT", number / 1000000000000)
    end
end

-- Форматирование времени (секунды -> ЧЧ:ММ:СС)
function Utilities.FormatTime(seconds)
    seconds = math.max(0, math.floor(seconds))
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60

    if hours > 0 then
        return string.format("%d:%02d:%02d", hours, minutes, secs)
    else
        return string.format("%d:%02d", minutes, secs)
    end
end

-- Линейная интерполяция
function Utilities.Lerp(a, b, t)
    return a + (b - a) * math.clamp(t, 0, 1)
end

-- Создание анимации мигания (для UI)
function Utilities.CreatePulse(guiObject, duration, minTransparency, maxTransparency)
    local TweenService = game:GetService("TweenService")

    local tweenIn = TweenService:Create(guiObject, TweenInfo.new(
        duration / 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut
    ), {BackgroundTransparency = maxTransparency})

    local tweenOut = TweenService:Create(guiObject, TweenInfo.new(
        duration / 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut
    ), {BackgroundTransparency = minTransparency})

    tweenIn.Completed:Connect(function()
        tweenOut:Play()
    end)
    tweenOut.Completed:Connect(function()
        tweenIn:Play()
    end)

    tweenIn:Play()
    return {tweenIn, tweenOut}
end

-- Создание эффекта появления текста с числом
function Utilities.CreateFloatingText(parent, text, color, startPosition)
    local TweenService = game:GetService("TweenService")

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = startPosition or Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(255, 255, 0)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0
    label.Parent = billboard

    -- Анимация вверх + исчезновение
    local tween = TweenService:Create(billboard, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        StudsOffset = (startPosition or Vector3.new(0, 3, 0)) + Vector3.new(0, 3, 0),
    })
    local fadeTween = TweenService:Create(label, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        TextTransparency = 1,
        TextStrokeTransparency = 1,
    })

    tween:Play()
    fadeTween:Play()

    fadeTween.Completed:Connect(function()
        billboard:Destroy()
    end)

    return billboard
end

-- Глубокое копирование таблицы
function Utilities.DeepCopy(original)
    local copy = {}
    for key, value in pairs(original) do
        if type(value) == "table" then
            copy[key] = Utilities.DeepCopy(value)
        else
            copy[key] = value
        end
    end
    return copy
end

-- Создание звукового эффекта
function Utilities.PlaySound(parent, soundId, volume, playbackSpeed)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = volume or 0.5
    sound.PlaybackSpeed = playbackSpeed or 1
    sound.Parent = parent
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
    return sound
end

-- Проверка, прошло ли 24 часа
function Utilities.Has24HoursPassed(lastTimestamp)
    if not lastTimestamp or lastTimestamp == 0 then
        return true
    end
    return (os.time() - lastTimestamp) >= 86400
end

-- Безопасный вызов RemoteEvent
function Utilities.SafeFireClient(remoteEvent, player, ...)
    local success, err = pcall(function()
        remoteEvent:FireClient(player, ...)
    end)
    if not success then
        warn("[Utilities] Failed to fire client: " .. tostring(err))
    end
end

return Utilities
