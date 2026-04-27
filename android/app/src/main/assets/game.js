// ==============================
// FAT MORE FAT - Simulator Game
// ==============================

const game = {
    // Core state
    fat: 0,
    totalFat: 0,
    totalTaps: 0,
    fatPerTap: 1,
    fatPerSecond: 0,
    prestigePoints: 0,
    prestigeMultiplier: 1,
    prestigeCount: 0,
    totalFatAllTime: 0,

    // Combo system
    combo: 0,
    comboTimer: null,
    comboTimeout: 1500,
    maxCombo: 0,

    // Fever mode
    feverGauge: 0,
    feverActive: false,
    feverDuration: 8000,
    feverMultiplier: 5,

    // Current food
    currentFoodIndex: 0,

    // Save
    saveInterval: null,

    // Time tracking
    startTime: Date.now(),
    playTime: 0,

    // ============ FOOD DATA ============
    foods: [
        { name: "Хлеб", emoji: "🍞", value: 1, unlockAt: 0 },
        { name: "Бургер", emoji: "🍔", value: 3, unlockAt: 50 },
        { name: "Пицца", emoji: "🍕", value: 5, unlockAt: 200 },
        { name: "Хот-дог", emoji: "🌭", value: 8, unlockAt: 500 },
        { name: "Тако", emoji: "🌮", value: 12, unlockAt: 1500 },
        { name: "Пончик", emoji: "🍩", value: 18, unlockAt: 5000 },
        { name: "Торт", emoji: "🎂", value: 30, unlockAt: 15000 },
        { name: "Мороженое", emoji: "🍦", value: 45, unlockAt: 40000 },
        { name: "Шоколад", emoji: "🍫", value: 70, unlockAt: 100000 },
        { name: "Суши", emoji: "🍣", value: 100, unlockAt: 250000 },
        { name: "Стейк", emoji: "🥩", value: 160, unlockAt: 600000 },
        { name: "Лобстер", emoji: "🦞", value: 250, unlockAt: 1500000 },
        { name: "Золотое яблоко", emoji: "✨🍎", value: 500, unlockAt: 5000000 },
    ],

    // ============ UPGRADES DATA ============
    upgrades: [
        {
            id: "bigMouth",
            name: "Большой Рот",
            desc: "Увеличивает жир за тап",
            icon: "👄",
            baseCost: 10,
            costMult: 1.5,
            level: 0,
            maxLevel: 200,
            effect: (lvl) => lvl * 1,
            effectDesc: (lvl) => `+${lvl} жира/тап`,
            type: "tap"
        },
        {
            id: "goldenFork",
            name: "Золотая Вилка",
            desc: "Множитель жира за тап x2",
            icon: "🍴",
            baseCost: 100,
            costMult: 2.5,
            level: 0,
            maxLevel: 50,
            effect: (lvl) => Math.pow(2, lvl),
            effectDesc: (lvl) => `x${Math.pow(2, lvl)} множитель`,
            type: "tapMult"
        },
        {
            id: "autoEater",
            name: "Авто-Поедатель",
            desc: "Автоматически ест еду",
            icon: "🤖",
            baseCost: 50,
            costMult: 1.6,
            level: 0,
            maxLevel: 200,
            effect: (lvl) => lvl * 1,
            effectDesc: (lvl) => `+${lvl}/сек`,
            type: "auto"
        },
        {
            id: "fatBelly",
            name: "Толстый Живот",
            desc: "Бонус к авто-поеданию",
            icon: "🫃",
            baseCost: 200,
            costMult: 1.7,
            level: 0,
            maxLevel: 150,
            effect: (lvl) => lvl * 3,
            effectDesc: (lvl) => `+${lvl * 3}/сек`,
            type: "auto"
        },
        {
            id: "fridge",
            name: "Огромный Холодильник",
            desc: "Хранит много еды",
            icon: "🧊",
            baseCost: 500,
            costMult: 1.8,
            level: 0,
            maxLevel: 100,
            effect: (lvl) => lvl * 10,
            effectDesc: (lvl) => `+${lvl * 10}/сек`,
            type: "auto"
        },
        {
            id: "chef",
            name: "Личный Повар",
            desc: "Готовит деликатесы",
            icon: "👨‍🍳",
            baseCost: 2000,
            costMult: 1.9,
            level: 0,
            maxLevel: 100,
            effect: (lvl) => lvl * 25,
            effectDesc: (lvl) => `+${lvl * 25}/сек`,
            type: "auto"
        },
        {
            id: "restaurant",
            name: "Свой Ресторан",
            desc: "Бесконечная еда",
            icon: "🏪",
            baseCost: 10000,
            costMult: 2.0,
            level: 0,
            maxLevel: 50,
            effect: (lvl) => lvl * 100,
            effectDesc: (lvl) => `+${lvl * 100}/сек`,
            type: "auto"
        },
        {
            id: "foodFactory",
            name: "Фабрика Еды",
            desc: "Промышленное обжорство!",
            icon: "🏭",
            baseCost: 50000,
            costMult: 2.2,
            level: 0,
            maxLevel: 50,
            effect: (lvl) => lvl * 500,
            effectDesc: (lvl) => `+${lvl * 500}/сек`,
            type: "auto"
        },
        {
            id: "comboMaster",
            name: "Мастер Комбо",
            desc: "Комбо держится дольше",
            icon: "🔥",
            baseCost: 300,
            costMult: 2.0,
            level: 0,
            maxLevel: 20,
            effect: (lvl) => lvl * 200,
            effectDesc: (lvl) => `+${lvl * 200}мс`,
            type: "combo"
        },
        {
            id: "feverPower",
            name: "Сила Лихорадки",
            desc: "Fever множитель больше",
            icon: "🌡",
            baseCost: 1000,
            costMult: 2.5,
            level: 0,
            maxLevel: 20,
            effect: (lvl) => lvl * 1,
            effectDesc: (lvl) => `+${lvl} к fever множителю`,
            type: "fever"
        },
    ],

    // ============ ACHIEVEMENTS ============
    achievementsList: [
        { id: "first_tap", name: "Первый Укус", desc: "Нажми первый раз", icon: "🍼", check: () => game.totalTaps >= 1, reward: 5, unlocked: false },
        { id: "tap_100", name: "Обжора", desc: "100 нажатий", icon: "😋", check: () => game.totalTaps >= 100, reward: 20, unlocked: false },
        { id: "tap_1000", name: "Мега Обжора", desc: "1,000 нажатий", icon: "🤤", check: () => game.totalTaps >= 1000, reward: 100, unlocked: false },
        { id: "tap_10000", name: "Бог Обжорства", desc: "10,000 нажатий", icon: "👑", check: () => game.totalTaps >= 10000, reward: 500, unlocked: false },
        { id: "fat_100", name: "Пухляш", desc: "Набери 100 жира", icon: "🐷", check: () => game.totalFat >= 100, reward: 10, unlocked: false },
        { id: "fat_1000", name: "Толстяк", desc: "Набери 1,000 жира", icon: "🐘", check: () => game.totalFat >= 1000, reward: 50, unlocked: false },
        { id: "fat_10000", name: "Мега Толстяк", desc: "Набери 10,000 жира", icon: "🏔", check: () => game.totalFat >= 10000, reward: 200, unlocked: false },
        { id: "fat_100k", name: "Жирный Босс", desc: "Набери 100,000 жира", icon: "🌍", check: () => game.totalFat >= 100000, reward: 1000, unlocked: false },
        { id: "fat_1m", name: "Жирная Планета", desc: "Набери 1,000,000 жира", icon: "🪐", check: () => game.totalFat >= 1000000, reward: 5000, unlocked: false },
        { id: "combo_10", name: "Комбо Мастер", desc: "Сделай комбо 10x", icon: "⚡", check: () => game.maxCombo >= 10, reward: 30, unlocked: false },
        { id: "combo_50", name: "Комбо Безумие", desc: "Сделай комбо 50x", icon: "💥", check: () => game.maxCombo >= 50, reward: 200, unlocked: false },
        { id: "fever_1", name: "Лихорадка!", desc: "Активируй fever mode", icon: "🌡", check: () => game.stats.feverCount >= 1, reward: 50, unlocked: false },
        { id: "prestige_1", name: "Перерождение", desc: "Переродись 1 раз", icon: "⭐", check: () => game.prestigeCount >= 1, reward: 100, unlocked: false },
        { id: "prestige_5", name: "Мастер Престижа", desc: "Переродись 5 раз", icon: "💫", check: () => game.prestigeCount >= 5, reward: 500, unlocked: false },
        { id: "minigame_100", name: "Ловец Еды", desc: "Поймай 100 еды в мини-игре", icon: "🎯", check: () => game.stats.minigameCaught >= 100, reward: 150, unlocked: false },
        { id: "food_unlock_5", name: "Гурман", desc: "Открой 5 видов еды", icon: "🍽", check: () => game.getUnlockedFoodCount() >= 5, reward: 80, unlocked: false },
        { id: "food_unlock_all", name: "Шеф-Гурман", desc: "Открой всю еду", icon: "👨‍🍳", check: () => game.getUnlockedFoodCount() >= game.foods.length, reward: 2000, unlocked: false },
    ],

    // Stats
    stats: {
        feverCount: 0,
        minigameCaught: 0,
        minigameBest: 0,
        totalAutoFat: 0,
    },

    // ============ INITIALIZATION ============
    init() {
        this.load();
        this.renderUpgrades();
        this.renderFood();
        this.renderAchievements();
        this.updatePrestigeTab();
        this.updateStats();
        this.drawCharacter();
        this.updateFoodDisplay();
        this.updateUI();

        // Game loop
        setInterval(() => this.gameLoop(), 100);
        // Food rain
        setInterval(() => this.spawnFoodRain(), 2000);
        // Auto-save
        this.saveInterval = setInterval(() => this.save(), 10000);
        // Check achievements
        setInterval(() => this.checkAchievements(), 1000);

        this.showNotification("Добро пожаловать в Fat More Fat! 🍔");
    },

    // ============ GAME LOOP ============
    gameLoop() {
        const autoFat = this.calculateAutoFat() / 10;
        if (autoFat > 0) {
            this.fat += autoFat;
            this.totalFat += autoFat;
            this.totalFatAllTime += autoFat;
            this.stats.totalAutoFat += autoFat;
        }
        this.updateUI();
        this.playTime = Date.now() - this.startTime;
    },

    // ============ MECHANIC 1: TAP TO EAT ============
    tap() {
        const food = this.foods[this.currentFoodIndex];
        const baseFat = food.value;
        const tapUpgrade = this.upgrades.find(u => u.id === "bigMouth");
        const tapMultUpgrade = this.upgrades.find(u => u.id === "goldenFork");

        let fatGain = (baseFat + tapUpgrade.effect(tapUpgrade.level)) * tapMultUpgrade.effect(tapMultUpgrade.level);
        fatGain *= this.prestigeMultiplier;

        // Combo bonus
        if (this.combo > 0) {
            fatGain *= (1 + this.combo * 0.1);
        }

        // Fever bonus
        if (this.feverActive) {
            fatGain *= (this.feverMultiplier + this.upgrades.find(u => u.id === "feverPower").level);
        }

        this.fat += fatGain;
        this.totalFat += fatGain;
        this.totalFatAllTime += fatGain;
        this.totalTaps++;

        // Update combo
        this.updateCombo();

        // Update fever gauge
        if (!this.feverActive) {
            this.feverGauge = Math.min(100, this.feverGauge + 1.5);
            if (this.feverGauge >= 100) {
                this.activateFever();
            }
        }

        // Visual effects
        this.showTapEffect(fatGain);
        this.drawCharacter();
        this.updateUI();
    },

    // ============ MECHANIC 2: COMBO SYSTEM ============
    updateCombo() {
        this.combo++;
        if (this.combo > this.maxCombo) this.maxCombo = this.combo;

        const comboDisplay = document.getElementById("combo-display");
        const comboCount = document.getElementById("combo-count");
        comboDisplay.classList.remove("hidden");
        comboCount.textContent = this.combo;

        if (this.comboTimer) clearTimeout(this.comboTimer);

        const comboMaster = this.upgrades.find(u => u.id === "comboMaster");
        const timeout = this.comboTimeout + comboMaster.effect(comboMaster.level);

        this.comboTimer = setTimeout(() => {
            this.combo = 0;
            comboDisplay.classList.add("hidden");
        }, timeout);
    },

    // ============ MECHANIC 3: FEVER MODE ============
    activateFever() {
        this.feverActive = true;
        this.stats.feverCount++;

        const feverContainer = document.getElementById("fever-bar-container");
        feverContainer.classList.remove("hidden");

        document.getElementById("main-area").style.background =
            "radial-gradient(ellipse at center, #fff176 0%, #ff8a65 100%)";

        this.showNotification("🔥 FEVER MODE АКТИВИРОВАН! x" +
            (this.feverMultiplier + this.upgrades.find(u => u.id === "feverPower").level) + " множитель!");

        let timeLeft = this.feverDuration;
        const feverInterval = setInterval(() => {
            timeLeft -= 100;
            const pct = (timeLeft / this.feverDuration) * 100;
            document.getElementById("fever-bar").style.width = pct + "%";

            if (timeLeft <= 0) {
                clearInterval(feverInterval);
                this.feverActive = false;
                this.feverGauge = 0;
                feverContainer.classList.add("hidden");
                document.getElementById("main-area").style.background =
                    "radial-gradient(ellipse at center, #fff8e1 0%, #ffe0b2 100%)";
            }
        }, 100);
    },

    // ============ MECHANIC 4: FOOD VARIETY ============
    selectFood(index) {
        const food = this.foods[index];
        if (this.totalFat < food.unlockAt) return;
        this.currentFoodIndex = index;
        this.updateFoodDisplay();
        this.renderFood();
    },

    getUnlockedFoodCount() {
        return this.foods.filter(f => this.totalFatAllTime >= f.unlockAt).length;
    },

    updateFoodDisplay() {
        const food = this.foods[this.currentFoodIndex];
        document.getElementById("current-food-display").textContent = food.emoji;
    },

    // ============ MECHANIC 5: UPGRADES ============
    getUpgradeCost(upgrade) {
        return Math.floor(upgrade.baseCost * Math.pow(upgrade.costMult, upgrade.level));
    },

    buyUpgrade(id) {
        const upgrade = this.upgrades.find(u => u.id === id);
        if (!upgrade) return;
        const cost = this.getUpgradeCost(upgrade);
        if (this.fat < cost || upgrade.level >= upgrade.maxLevel) return;

        this.fat -= cost;
        upgrade.level++;

        this.recalculate();
        this.renderUpgrades();
        this.updateUI();
        this.drawCharacter();
    },

    recalculate() {
        // Recalculate fatPerTap
        const bigMouth = this.upgrades.find(u => u.id === "bigMouth");
        const goldenFork = this.upgrades.find(u => u.id === "goldenFork");
        const food = this.foods[this.currentFoodIndex];
        this.fatPerTap = (food.value + bigMouth.effect(bigMouth.level)) * goldenFork.effect(goldenFork.level) * this.prestigeMultiplier;

        // Recalculate fatPerSecond
        this.fatPerSecond = this.calculateAutoFat();
    },

    calculateAutoFat() {
        let auto = 0;
        this.upgrades.forEach(u => {
            if (u.type === "auto") {
                auto += u.effect(u.level);
            }
        });
        return auto * this.prestigeMultiplier;
    },

    // ============ MECHANIC 6: PRESTIGE ============
    getPrestigePointsToGain() {
        return Math.floor(Math.sqrt(this.totalFat / 10000));
    },

    doPrestige() {
        const points = this.getPrestigePointsToGain();
        if (points < 1) {
            this.showNotification("Нужно больше жира для перерождения!");
            return;
        }

        if (!confirm(`Переродиться? Вы получите ${points} очков престижа! Весь прогресс будет сброшен.`)) {
            return;
        }

        this.prestigePoints += points;
        this.prestigeMultiplier = 1 + this.prestigePoints * 0.25;
        this.prestigeCount++;

        // Reset
        this.fat = 0;
        this.totalFat = 0;
        this.combo = 0;
        this.feverGauge = 0;
        this.currentFoodIndex = 0;

        this.upgrades.forEach(u => u.level = 0);

        this.recalculate();
        this.renderUpgrades();
        this.renderFood();
        this.updatePrestigeTab();
        this.updateUI();
        this.drawCharacter();
        this.updateFoodDisplay();

        this.showNotification(`⭐ Перерождение! +${points} очков престижа! Множитель: x${this.prestigeMultiplier.toFixed(2)}`);
    },

    // ============ MECHANIC 7: MINI-GAME ============
    minigame: {
        active: false,
        canvas: null,
        ctx: null,
        score: 0,
        timeLeft: 0,
        items: [],
        basket: { x: 150, width: 60 },
        animFrame: null,
        touchX: null,

        start() {
            this.canvas = document.getElementById("minigame-canvas");
            this.ctx = this.canvas.getContext("2d");
            this.score = 0;
            this.timeLeft = 20000;
            this.items = [];
            this.active = true;
            this.basket.x = this.canvas.width / 2 - this.basket.width / 2;

            document.getElementById("minigame-start-btn").classList.add("hidden");
            document.getElementById("minigame-score").classList.remove("hidden");
            document.getElementById("mg-score").textContent = "0";

            // Event listeners
            this.canvas.addEventListener("mousemove", this.handleMove.bind(this));
            this.canvas.addEventListener("touchmove", this.handleTouch.bind(this), { passive: false });

            this.loop();
        },

        handleMove(e) {
            const rect = this.canvas.getBoundingClientRect();
            const scaleX = this.canvas.width / rect.width;
            this.basket.x = (e.clientX - rect.left) * scaleX - this.basket.width / 2;
            this.basket.x = Math.max(0, Math.min(this.canvas.width - this.basket.width, this.basket.x));
        },

        handleTouch(e) {
            e.preventDefault();
            const rect = this.canvas.getBoundingClientRect();
            const scaleX = this.canvas.width / rect.width;
            const touch = e.touches[0];
            this.basket.x = (touch.clientX - rect.left) * scaleX - this.basket.width / 2;
            this.basket.x = Math.max(0, Math.min(this.canvas.width - this.basket.width, this.basket.x));
        },

        loop() {
            if (!this.active) return;

            this.timeLeft -= 16;
            if (this.timeLeft <= 0) {
                this.end();
                return;
            }

            // Spawn items
            if (Math.random() < 0.05) {
                const emojis = ["🍔", "🍕", "🍩", "🌭", "🍫", "🎂", "🍦", "🥩"];
                const poisons = ["💀", "🧪"];
                const isPoison = Math.random() < 0.15;
                this.items.push({
                    x: Math.random() * (this.canvas.width - 30),
                    y: -30,
                    emoji: isPoison ? poisons[Math.floor(Math.random() * poisons.length)] : emojis[Math.floor(Math.random() * emojis.length)],
                    speed: 2 + Math.random() * 3,
                    poison: isPoison,
                    value: isPoison ? -3 : (1 + Math.floor(Math.random() * 3))
                });
            }

            // Update items
            this.items.forEach(item => item.y += item.speed);

            // Check catches
            this.items = this.items.filter(item => {
                if (item.y > this.canvas.height - 50 &&
                    item.x > this.basket.x - 10 &&
                    item.x < this.basket.x + this.basket.width + 10 &&
                    item.y < this.canvas.height - 10) {
                    this.score += item.value;
                    if (!item.poison) game.stats.minigameCaught++;
                    document.getElementById("mg-score").textContent = Math.max(0, this.score);
                    return false;
                }
                return item.y < this.canvas.height + 30;
            });

            this.draw();
            this.animFrame = requestAnimationFrame(() => this.loop());
        },

        draw() {
            const ctx = this.ctx;
            const w = this.canvas.width;
            const h = this.canvas.height;

            // Background
            const grad = ctx.createLinearGradient(0, 0, 0, h);
            grad.addColorStop(0, "#87ceeb");
            grad.addColorStop(1, "#98fb98");
            ctx.fillStyle = grad;
            ctx.fillRect(0, 0, w, h);

            // Timer bar
            const timerWidth = (this.timeLeft / 20000) * w;
            ctx.fillStyle = this.timeLeft > 5000 ? "#4caf50" : "#f44336";
            ctx.fillRect(0, 0, timerWidth, 6);

            // Items
            ctx.font = "28px serif";
            this.items.forEach(item => {
                ctx.fillText(item.emoji, item.x, item.y);
            });

            // Basket
            ctx.font = "36px serif";
            ctx.fillText("🧺", this.basket.x, h - 20);

            // Score
            ctx.fillStyle = "#333";
            ctx.font = "bold 18px sans-serif";
            ctx.fillText(`Счёт: ${Math.max(0, this.score)}`, 10, 28);

            // Time
            ctx.fillText(`Время: ${(this.timeLeft / 1000).toFixed(1)}с`, w - 130, 28);
        },

        end() {
            this.active = false;
            cancelAnimationFrame(this.animFrame);
            this.canvas.removeEventListener("mousemove", this.handleMove);
            this.canvas.removeEventListener("touchmove", this.handleTouch);

            if (this.score > game.stats.minigameBest) {
                game.stats.minigameBest = this.score;
            }

            const fatReward = Math.max(0, this.score) * 10 * game.prestigeMultiplier;
            game.fat += fatReward;
            game.totalFat += fatReward;
            game.totalFatAllTime += fatReward;

            document.getElementById("minigame-start-btn").classList.remove("hidden");
            document.getElementById("minigame-start-btn").textContent = "Играть снова!";

            game.showNotification(`🎮 Мини-игра окончена! Счёт: ${Math.max(0, this.score)} | +${game.formatNumber(fatReward)} жира!`);
            game.updateUI();
        }
    },

    // ============ RENDERING ============
    renderUpgrades() {
        const container = document.getElementById("upgrades-list");
        container.innerHTML = "";

        this.upgrades.forEach(upgrade => {
            const cost = this.getUpgradeCost(upgrade);
            const canAfford = this.fat >= cost && upgrade.level < upgrade.maxLevel;
            const maxed = upgrade.level >= upgrade.maxLevel;

            const div = document.createElement("div");
            div.className = `upgrade-item ${canAfford ? "" : "cannot-afford"}`;
            div.innerHTML = `
                <div class="upgrade-icon">${upgrade.icon}</div>
                <div class="upgrade-info">
                    <div class="upgrade-name">${upgrade.name}</div>
                    <div class="upgrade-desc">${upgrade.desc}</div>
                    <div class="upgrade-level">Ур. ${upgrade.level}/${upgrade.maxLevel} | ${upgrade.effectDesc(upgrade.level)}</div>
                </div>
                <button class="upgrade-buy-btn" onclick="game.buyUpgrade('${upgrade.id}')" ${canAfford ? "" : "disabled"}>
                    ${maxed ? "МАКС" : this.formatNumber(cost) + " 🍔"}
                </button>
            `;
            container.appendChild(div);
        });
    },

    renderFood() {
        const container = document.getElementById("food-list");
        container.innerHTML = "";

        this.foods.forEach((food, index) => {
            const unlocked = this.totalFatAllTime >= food.unlockAt;
            const selected = index === this.currentFoodIndex;

            const div = document.createElement("div");
            div.className = `food-item ${selected ? "selected" : ""} ${unlocked ? "" : "locked"}`;
            div.onclick = () => this.selectFood(index);
            div.innerHTML = `
                <div class="food-emoji">${food.emoji}</div>
                <div class="food-info">
                    <div class="food-name">${unlocked ? food.name : "???"}</div>
                    <div class="food-value">${unlocked ? "+" + food.value + " жира/тап" : ""}</div>
                    ${!unlocked ? `<div class="food-unlock">Разблокируется при ${this.formatNumber(food.unlockAt)} общего жира</div>` : ""}
                </div>
                ${selected ? '<span style="font-size:20px">✅</span>' : ""}
            `;
            container.appendChild(div);
        });
    },

    renderAchievements() {
        const container = document.getElementById("achievements-list");
        container.innerHTML = "";

        this.achievementsList.forEach(ach => {
            const div = document.createElement("div");
            div.className = `achievement-item ${ach.unlocked ? "unlocked" : "locked"}`;
            div.innerHTML = `
                <div class="achievement-icon">${ach.icon}</div>
                <div class="achievement-info">
                    <div class="achievement-name">${ach.unlocked ? ach.name : "???"}</div>
                    <div class="achievement-desc">${ach.desc}</div>
                    <div class="achievement-reward">${ach.unlocked ? "Получено! +" + ach.reward + " жира" : "Награда: " + ach.reward + " жира"}</div>
                </div>
            `;
            container.appendChild(div);
        });
    },

    updatePrestigeTab() {
        const points = this.getPrestigePointsToGain();
        const info = document.getElementById("prestige-info");
        info.innerHTML = `
            <p>Текущие очки престижа: <strong style="color:#7c4dff">${this.prestigePoints}</strong></p>
            <p>Текущий множитель: <strong style="color:#e040fb">x${this.prestigeMultiplier.toFixed(2)}</strong></p>
            <p>Перерождений: <strong>${this.prestigeCount}</strong></p>
            <hr style="margin:10px 0;border-color:#eee">
            <p>Очки за перерождение сейчас: <strong style="color:#ff6b35">${points}</strong></p>
            <p style="font-size:12px;color:#999">Формула: √(общий жир / 10000)</p>
            <p>Новый множитель: <strong style="color:#e040fb">x${(1 + (this.prestigePoints + points) * 0.25).toFixed(2)}</strong></p>
        `;

        document.getElementById("prestige-btn").disabled = points < 1;
    },

    updateStats() {
        const container = document.getElementById("stats-list");
        const playSeconds = Math.floor(this.playTime / 1000);
        const minutes = Math.floor(playSeconds / 60);
        const seconds = playSeconds % 60;

        container.innerHTML = `
            <div class="stat-item"><span class="stat-label">Общий жир (текущий)</span><span class="stat-value">${this.formatNumber(this.totalFat)}</span></div>
            <div class="stat-item"><span class="stat-label">Общий жир (все перерождения)</span><span class="stat-value">${this.formatNumber(this.totalFatAllTime)}</span></div>
            <div class="stat-item"><span class="stat-label">Всего нажатий</span><span class="stat-value">${this.formatNumber(this.totalTaps)}</span></div>
            <div class="stat-item"><span class="stat-label">Жир за тап</span><span class="stat-value">${this.formatNumber(this.fatPerTap)}</span></div>
            <div class="stat-item"><span class="stat-label">Жир в секунду</span><span class="stat-value">${this.formatNumber(this.fatPerSecond)}</span></div>
            <div class="stat-item"><span class="stat-label">Макс комбо</span><span class="stat-value">${this.maxCombo}x</span></div>
            <div class="stat-item"><span class="stat-label">Режимов лихорадки</span><span class="stat-value">${this.stats.feverCount}</span></div>
            <div class="stat-item"><span class="stat-label">Перерождений</span><span class="stat-value">${this.prestigeCount}</span></div>
            <div class="stat-item"><span class="stat-label">Множитель престижа</span><span class="stat-value">x${this.prestigeMultiplier.toFixed(2)}</span></div>
            <div class="stat-item"><span class="stat-label">Лучший счёт мини-игры</span><span class="stat-value">${this.stats.minigameBest}</span></div>
            <div class="stat-item"><span class="stat-label">Поймано еды в мини-игре</span><span class="stat-value">${this.stats.minigameCaught}</span></div>
            <div class="stat-item"><span class="stat-label">Открыто видов еды</span><span class="stat-value">${this.getUnlockedFoodCount()}/${this.foods.length}</span></div>
            <div class="stat-item"><span class="stat-label">Время игры</span><span class="stat-value">${minutes}м ${seconds}с</span></div>
        `;
    },

    // ============ CHARACTER DRAWING ============
    drawCharacter() {
        const canvas = document.getElementById("character-canvas");
        const ctx = canvas.getContext("2d");
        const w = canvas.width;
        const h = canvas.height;
        ctx.clearRect(0, 0, w, h);

        // Calculate fatness level (0 to 1)
        const fatLevel = Math.min(1, Math.log10(Math.max(1, this.totalFatAllTime)) / 7);
        const bodyWidth = 40 + fatLevel * 80;
        const bodyHeight = 50 + fatLevel * 70;
        const cx = w / 2;
        const cy = h / 2 + 20;

        // Shadow
        ctx.fillStyle = "rgba(0,0,0,0.1)";
        ctx.beginPath();
        ctx.ellipse(cx, cy + bodyHeight + 10, bodyWidth + 10, 10, 0, 0, Math.PI * 2);
        ctx.fill();

        // Legs
        ctx.fillStyle = "#deb887";
        ctx.fillRect(cx - bodyWidth * 0.3, cy + bodyHeight - 10, 16, 30);
        ctx.fillRect(cx + bodyWidth * 0.3 - 16, cy + bodyHeight - 10, 16, 30);

        // Shoes
        ctx.fillStyle = "#8b4513";
        ctx.beginPath();
        ctx.ellipse(cx - bodyWidth * 0.3 + 8, cy + bodyHeight + 22, 14, 8, 0, 0, Math.PI * 2);
        ctx.fill();
        ctx.beginPath();
        ctx.ellipse(cx + bodyWidth * 0.3 - 8, cy + bodyHeight + 22, 14, 8, 0, 0, Math.PI * 2);
        ctx.fill();

        // Body
        const bodyGrad = ctx.createRadialGradient(cx, cy, 0, cx, cy, bodyWidth);
        bodyGrad.addColorStop(0, "#ffcc80");
        bodyGrad.addColorStop(1, "#ff9800");
        ctx.fillStyle = bodyGrad;
        ctx.beginPath();
        ctx.ellipse(cx, cy, bodyWidth, bodyHeight, 0, 0, Math.PI * 2);
        ctx.fill();

        // Belly button
        if (fatLevel > 0.2) {
            ctx.fillStyle = "#e68a00";
            ctx.beginPath();
            ctx.ellipse(cx, cy + bodyHeight * 0.3, 3 + fatLevel * 4, 4 + fatLevel * 5, 0, 0, Math.PI * 2);
            ctx.fill();
        }

        // Shirt (stretching as character gets fatter)
        if (fatLevel < 0.8) {
            ctx.fillStyle = `rgba(66, 165, 245, ${1 - fatLevel})`;
            ctx.beginPath();
            ctx.ellipse(cx, cy - bodyHeight * 0.1, bodyWidth * 0.85, bodyHeight * 0.7, 0, 0, Math.PI * 2);
            ctx.fill();
        }

        // Arms
        ctx.fillStyle = "#ffcc80";
        const armAngle = 0.3 + fatLevel * 0.5;
        // Left arm
        ctx.save();
        ctx.translate(cx - bodyWidth, cy - bodyHeight * 0.2);
        ctx.rotate(-armAngle);
        ctx.fillRect(-6, 0, 12, 35 + fatLevel * 15);
        ctx.restore();
        // Right arm
        ctx.save();
        ctx.translate(cx + bodyWidth, cy - bodyHeight * 0.2);
        ctx.rotate(armAngle);
        ctx.fillRect(-6, 0, 12, 35 + fatLevel * 15);
        ctx.restore();

        // Head
        const headSize = 28 + fatLevel * 15;
        ctx.fillStyle = "#ffcc80";
        ctx.beginPath();
        ctx.arc(cx, cy - bodyHeight - headSize * 0.5, headSize, 0, Math.PI * 2);
        ctx.fill();

        // Double chin
        if (fatLevel > 0.3) {
            ctx.fillStyle = "#f5b041";
            ctx.beginPath();
            ctx.ellipse(cx, cy - bodyHeight + headSize * 0.3, headSize * 0.6, fatLevel * 12, 0, 0, Math.PI);
            ctx.fill();
        }

        // Eyes
        const eyeY = cy - bodyHeight - headSize * 0.6;
        const eyeSpread = 10 + fatLevel * 3;
        // White
        ctx.fillStyle = "white";
        ctx.beginPath();
        ctx.ellipse(cx - eyeSpread, eyeY, 7, 8, 0, 0, Math.PI * 2);
        ctx.fill();
        ctx.beginPath();
        ctx.ellipse(cx + eyeSpread, eyeY, 7, 8, 0, 0, Math.PI * 2);
        ctx.fill();
        // Pupil
        ctx.fillStyle = "#333";
        ctx.beginPath();
        ctx.arc(cx - eyeSpread, eyeY + 1, 4, 0, Math.PI * 2);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(cx + eyeSpread, eyeY + 1, 4, 0, Math.PI * 2);
        ctx.fill();
        // Shine
        ctx.fillStyle = "white";
        ctx.beginPath();
        ctx.arc(cx - eyeSpread + 1.5, eyeY - 1.5, 1.5, 0, Math.PI * 2);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(cx + eyeSpread + 1.5, eyeY - 1.5, 1.5, 0, Math.PI * 2);
        ctx.fill();

        // Mouth (happy eating)
        ctx.fillStyle = "#e74c3c";
        ctx.beginPath();
        const mouthWidth = 8 + fatLevel * 8;
        ctx.arc(cx, cy - bodyHeight - headSize * 0.2, mouthWidth, 0, Math.PI);
        ctx.fill();

        // Rosy cheeks
        ctx.fillStyle = "rgba(255, 100, 100, 0.3)";
        ctx.beginPath();
        ctx.ellipse(cx - eyeSpread - 8, eyeY + 10, 6, 4, 0, 0, Math.PI * 2);
        ctx.fill();
        ctx.beginPath();
        ctx.ellipse(cx + eyeSpread + 8, eyeY + 10, 6, 4, 0, 0, Math.PI * 2);
        ctx.fill();

        // Hair
        ctx.fillStyle = "#5d4037";
        ctx.beginPath();
        ctx.arc(cx, cy - bodyHeight - headSize * 1.1, headSize * 0.7, Math.PI, Math.PI * 2);
        ctx.fill();

        // Weight stage label
        const stage = this.getWeightStage();
        let stageEl = document.getElementById("weight-stage");
        if (!stageEl) {
            stageEl = document.createElement("div");
            stageEl.id = "weight-stage";
            document.getElementById("main-area").appendChild(stageEl);
        }
        stageEl.textContent = stage;
    },

    getWeightStage() {
        const fat = this.totalFatAllTime;
        if (fat < 100) return "🏃 Худой";
        if (fat < 500) return "🚶 Нормальный";
        if (fat < 2000) return "🍔 Пухлый";
        if (fat < 10000) return "🐷 Толстый";
        if (fat < 50000) return "🐘 Очень Толстый";
        if (fat < 200000) return "🏔 Мега Толстый";
        if (fat < 1000000) return "🌍 Планета Жира";
        if (fat < 10000000) return "☀️ Звезда Жира";
        return "🌌 Вселенная Жира";
    },

    // ============ UI UPDATE ============
    updateUI() {
        document.getElementById("fat-count").textContent = this.formatNumber(this.fat);
        document.getElementById("fat-per-sec").textContent = this.formatNumber(this.calculateAutoFat());
        document.getElementById("prestige-points").textContent = this.prestigePoints;

        // Update fever bar
        if (!this.feverActive) {
            const feverContainer = document.getElementById("fever-bar-container");
            if (this.feverGauge > 0) {
                feverContainer.classList.remove("hidden");
                document.getElementById("fever-bar").style.width = this.feverGauge + "%";
                document.getElementById("fever-text").textContent =
                    this.feverGauge >= 100 ? "FEVER MODE!" : Math.floor(this.feverGauge) + "%";
            }
        }

        this.recalculate();
    },

    // ============ VISUAL EFFECTS ============
    showTapEffect(amount) {
        const container = document.getElementById("tap-effect-container");
        const effect = document.createElement("div");
        effect.className = "tap-effect";
        effect.textContent = "+" + this.formatNumber(amount);
        effect.style.left = (30 + Math.random() * 200) + "px";
        effect.style.top = (50 + Math.random() * 150) + "px";

        if (this.feverActive) {
            effect.style.color = "#ff1744";
            effect.style.fontSize = "30px";
        } else if (this.combo >= 10) {
            effect.style.color = "#ff9100";
        }

        container.appendChild(effect);
        setTimeout(() => effect.remove(), 1000);
    },

    spawnFoodRain() {
        if (this.calculateAutoFat() <= 0) return;
        const container = document.getElementById("food-rain-container");
        const food = this.foods[Math.floor(Math.random() * this.getUnlockedFoodCount())];
        const item = document.createElement("div");
        item.className = "food-rain-item";
        item.textContent = food.emoji;
        item.style.left = Math.random() * 90 + "%";
        item.style.animationDuration = (2 + Math.random() * 3) + "s";
        container.appendChild(item);
        setTimeout(() => item.remove(), 5000);
    },

    // ============ TABS ============
    switchTab(tabName) {
        document.querySelectorAll(".nav-tab").forEach(t => t.classList.remove("active"));
        document.querySelectorAll(".tab-panel").forEach(p => p.classList.remove("active"));
        document.querySelector(`[data-tab="${tabName}"]`).classList.add("active");
        document.getElementById(`tab-${tabName}`).classList.add("active");

        // Refresh content
        if (tabName === "upgrades") this.renderUpgrades();
        if (tabName === "food") this.renderFood();
        if (tabName === "achievements") this.renderAchievements();
        if (tabName === "prestige") this.updatePrestigeTab();
        if (tabName === "stats") this.updateStats();
    },

    // ============ ACHIEVEMENTS CHECK ============
    checkAchievements() {
        this.achievementsList.forEach(ach => {
            if (!ach.unlocked && ach.check()) {
                ach.unlocked = true;
                this.fat += ach.reward;
                this.totalFat += ach.reward;
                this.totalFatAllTime += ach.reward;
                this.showAchievement(ach);
            }
        });
    },

    showAchievement(ach) {
        const popup = document.getElementById("achievement-popup");
        document.getElementById("achievement-popup-icon").textContent = ach.icon;
        document.getElementById("achievement-popup-text").textContent = ach.name + " +" + ach.reward;
        popup.classList.remove("hidden");

        setTimeout(() => popup.classList.add("hidden"), 2500);

        if (document.querySelector('[data-tab="achievements"]').classList.contains("active")) {
            this.renderAchievements();
        }
    },

    // ============ NOTIFICATIONS ============
    showNotification(text) {
        const el = document.getElementById("notification");
        el.textContent = text;
        el.classList.remove("hidden");
        setTimeout(() => el.classList.add("hidden"), 3000);
    },

    // ============ SAVE / LOAD ============
    save() {
        const data = {
            fat: this.fat,
            totalFat: this.totalFat,
            totalFatAllTime: this.totalFatAllTime,
            totalTaps: this.totalTaps,
            prestigePoints: this.prestigePoints,
            prestigeMultiplier: this.prestigeMultiplier,
            prestigeCount: this.prestigeCount,
            currentFoodIndex: this.currentFoodIndex,
            combo: 0,
            maxCombo: this.maxCombo,
            feverGauge: 0,
            stats: this.stats,
            upgradeLevels: this.upgrades.map(u => u.level),
            achievements: this.achievementsList.map(a => a.unlocked),
            playTime: this.playTime,
            savedAt: Date.now()
        };
        localStorage.setItem("fatMoreFat_save", JSON.stringify(data));
    },

    load() {
        const raw = localStorage.getItem("fatMoreFat_save");
        if (!raw) return;
        try {
            const data = JSON.parse(raw);
            this.fat = data.fat || 0;
            this.totalFat = data.totalFat || 0;
            this.totalFatAllTime = data.totalFatAllTime || 0;
            this.totalTaps = data.totalTaps || 0;
            this.prestigePoints = data.prestigePoints || 0;
            this.prestigeMultiplier = data.prestigeMultiplier || 1;
            this.prestigeCount = data.prestigeCount || 0;
            this.currentFoodIndex = data.currentFoodIndex || 0;
            this.maxCombo = data.maxCombo || 0;
            this.stats = data.stats || this.stats;
            this.playTime = data.playTime || 0;
            this.startTime = Date.now() - this.playTime;

            if (data.upgradeLevels) {
                data.upgradeLevels.forEach((lvl, i) => {
                    if (this.upgrades[i]) this.upgrades[i].level = lvl;
                });
            }
            if (data.achievements) {
                data.achievements.forEach((unlocked, i) => {
                    if (this.achievementsList[i]) this.achievementsList[i].unlocked = unlocked;
                });
            }

            // Offline earnings
            if (data.savedAt) {
                const elapsed = (Date.now() - data.savedAt) / 1000;
                const offlineEarnings = this.calculateAutoFat() * elapsed * 0.5;
                if (offlineEarnings > 0) {
                    this.fat += offlineEarnings;
                    this.totalFat += offlineEarnings;
                    this.totalFatAllTime += offlineEarnings;
                    setTimeout(() => {
                        this.showNotification(`💤 Оффлайн доход: +${this.formatNumber(offlineEarnings)} жира!`);
                    }, 1000);
                }
            }
        } catch (e) {
            console.error("Failed to load save:", e);
        }
    },

    // ============ UTILS ============
    formatNumber(n) {
        n = Math.floor(n);
        if (n < 1000) return n.toString();
        if (n < 1000000) return (n / 1000).toFixed(1) + "K";
        if (n < 1000000000) return (n / 1000000).toFixed(2) + "M";
        if (n < 1000000000000) return (n / 1000000000).toFixed(2) + "B";
        return (n / 1000000000000).toFixed(2) + "T";
    }
};

// Start game
window.addEventListener("load", () => game.init());
