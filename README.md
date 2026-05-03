# Ultimate Click Simulator - Roblox Studio

Полностью готовый симулятор для Roblox Studio с системой кликов, питомцами, перерождениями, зонами и многим другим!

## Особенности игры

- **Система кликов** - кликай по объектам и зарабатывай монеты
- **Апгрейды** - улучшай силу клика, авто-кликер, удачу и множитель монет
- **Питомцы** - открывай яйца и получай питомцев от обычных до мифических
- **Перерождения (Rebirth)** - перерождайся для получения постоянных бонусов
- **7 уникальных зон** - от Начальной поляны до Космической станции
- **Ежедневные награды** - 7-дневный цикл наград за вход
- **Система кодов** - активируй промо-коды для бонусов
- **Лидерборд** - соревнуйся с другими игроками
- **Автосохранение** - данные сохраняются автоматически

## Структура проекта

```
src/
├── ReplicatedStorage/
│   └── Modules/
│       ├── GameConfig.lua      -- Главная конфигурация игры
│       ├── PetConfig.lua       -- Конфигурация питомцев и яиц
│       ├── ZoneConfig.lua      -- Конфигурация зон/миров
│       └── Utilities.lua       -- Вспомогательные функции
├── ServerScriptService/
│   ├── DataStoreHandler.lua    -- Сохранение/загрузка данных
│   ├── GameHandler.lua         -- Основная логика (клики, апгрейды, коды)
│   ├── PetSystemHandler.lua    -- Система питомцев
│   ├── RebirthHandler.lua      -- Система перерождений
│   ├── DailyRewardHandler.lua  -- Ежедневные награды
│   └── WorldBuilder.lua        -- Автопостроение игрового мира
├── StarterGui/
│   ├── MainUI.lua              -- Главный интерфейс (HUD)
│   ├── ShopUI.lua              -- Магазин апгрейдов
│   ├── PetUI.lua               -- Интерфейс питомцев
│   ├── RebirthUI.lua           -- Интерфейс перерождений
│   ├── DailyRewardUI.lua       -- Ежедневные награды
│   ├── ZoneUI.lua              -- Выбор зон
│   └── CodesUI.lua             -- Ввод промо-кодов
```

## Пошаговая установка в Roblox Studio

### Шаг 1: Создание нового проекта
1. Открой **Roblox Studio**
2. Нажми **"New"** (Новый) и выбери **"Baseplate"**
3. Сохрани проект с любым названием

### Шаг 2: Включение API сервисов
1. В меню выбери **Game Settings** (Настройки игры) > **Security**
2. Включи **"Enable Studio Access to API Services"** (Включить доступ Studio к API сервисам)
3. Включи **"Allow HTTP Requests"** (Разрешить HTTP запросы)
4. Нажми **Save** (Сохранить)

### Шаг 3: Настройка ReplicatedStorage (Модули)
1. В **Explorer** (панель справа) найди **ReplicatedStorage**
2. Щёлкни правой кнопкой > **Insert Object** > **Folder**
3. Назови папку **"Modules"**
4. Внутри папки Modules создай 4 **ModuleScript**:
   - `GameConfig` — скопируй содержимое из `src/ReplicatedStorage/Modules/GameConfig.lua`
   - `PetConfig` — скопируй из `src/ReplicatedStorage/Modules/PetConfig.lua`
   - `ZoneConfig` — скопируй из `src/ReplicatedStorage/Modules/ZoneConfig.lua`
   - `Utilities` — скопируй из `src/ReplicatedStorage/Modules/Utilities.lua`

### Шаг 4: Настройка ServerScriptService (Серверные скрипты)
1. В Explorer найди **ServerScriptService**
2. Создай 6 **Script** (обычных серверных скриптов):
   - `DataStoreHandler` — скопируй из `src/ServerScriptService/DataStoreHandler.lua`
   - `GameHandler` — скопируй из `src/ServerScriptService/GameHandler.lua`
   - `PetSystemHandler` — скопируй из `src/ServerScriptService/PetSystemHandler.lua`
   - `RebirthHandler` — скопируй из `src/ServerScriptService/RebirthHandler.lua`
   - `DailyRewardHandler` — скопируй из `src/ServerScriptService/DailyRewardHandler.lua`
   - `WorldBuilder` — скопируй из `src/ServerScriptService/WorldBuilder.lua`

**ВАЖНО:** `DataStoreHandler` должен быть типа **ModuleScript** (не обычный Script), так как другие скрипты его require-ят!

### Шаг 5: Настройка StarterGui (Клиентские скрипты / UI)
1. В Explorer найди **StarterGui**
2. Создай **ScreenGui** и назови его **"MainUI"**
3. Внутри ScreenGui создай 7 **LocalScript**:
   - `MainUI` — скопируй из `src/StarterGui/MainUI.lua`
   - `ShopUI` — скопируй из `src/StarterGui/ShopUI.lua`
   - `PetUI` — скопируй из `src/StarterGui/PetUI.lua`
   - `RebirthUI` — скопируй из `src/StarterGui/RebirthUI.lua`
   - `DailyRewardUI` — скопируй из `src/StarterGui/DailyRewardUI.lua`
   - `ZoneUI` — скопируй из `src/StarterGui/ZoneUI.lua`
   - `CodesUI` — скопируй из `src/StarterGui/CodesUI.lua`

### Шаг 6: Тестирование
1. Нажми кнопку **Play** (зелёный треугольник) в Roblox Studio
2. Если всё настроено правильно, ты увидишь:
   - Автоматически сгенерированный мир с зонами
   - HUD с монетами и кристаллами вверху экрана
   - Кнопки меню слева
   - Большую кнопку "КЛИК!" внизу
3. Проверь каждую систему:
   - Кликай по объектам и кнопке для заработка монет
   - Открой магазин и купи апгрейд
   - Открой раздел питомцев
   - Попробуй ввести код (например RELEASE)

### Шаг 7: Публикация
1. **File** > **Publish to Roblox** (Опубликовать в Roblox)
2. Заполни название, описание и иконку
3. Включи **Genre** > **All** для максимального охвата
4. В **Game Settings** > **Monetization** можешь настроить геймпасы

## Настройка под себя

### Изменение баланса
Все числа (цены, множители, шансы) находятся в файлах конфигурации:
- `GameConfig.lua` — апгрейды, перерождения, коды, ежедневные награды
- `PetConfig.lua` — питомцы, редкости, яйца
- `ZoneConfig.lua` — зоны и их множители

### Добавление новых питомцев
В `PetConfig.lua` добавь новую запись в таблицу `PetConfig.Pets`:
```lua
{Name = "Новый Питомец", Rarity = "Epic", ModelId = "rbxassetid://ТВОЙ_ID", Icon = "rbxassetid://ТВОЙ_ID"},
```

### Добавление новых зон
В `ZoneConfig.lua` добавь новую запись в таблицу `ZoneConfig.Zones`.

### Добавление новых кодов
В `GameConfig.lua` добавь запись в `GameConfig.Codes`:
```lua
НОВЫЙКОД = {Reward = "Coins", Amount = 5000, MaxUses = 1},
```

### Добавление моделей питомцев
1. Найди модели питомцев в **Toolbox** или создай свои
2. Получи `AssetId` модели
3. Замени `rbxassetid://0` на реальный ID в `PetConfig.lua`

## Промо-коды (активные)
| Код | Награда |
|-----|---------|
| RELEASE | 500 Монет |
| GEMS | 25 Кристаллов |
| SIMULATOR | 1000 Монет |
| PETS | 50 Кристаллов |
| LIKE | 2000 Монет |

## Советы для популярности
1. **Иконка и превью** — создай яркую иконку в стиле симулятора
2. **Описание** — напиши привлекательное описание с эмодзи
3. **Обновления** — регулярно добавляй новый контент (питомцев, зоны)
4. **Группа** — создай группу и публикуй игру от её имени
5. **Социальные сети** — рекламируй игру в ТикТок, YouTube
6. **Геймпасы** — добавь VIP, x2 монеты и другие геймпасы для монетизации
7. **Коды** — регулярно добавляй новые коды для привлечения игроков

## Лицензия
Свободное использование. Можешь модифицировать как угодно!
