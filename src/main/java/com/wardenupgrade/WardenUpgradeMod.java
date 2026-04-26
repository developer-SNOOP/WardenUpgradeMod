package com.wardenupgrade;

import com.wardenupgrade.item.ModItems;
import net.fabricmc.api.ModInitializer;
import net.fabricmc.fabric.api.event.lifecycle.v1.ServerTickEvents;
import net.fabricmc.fabric.api.message.v1.ServerMessageEvents;
import net.minecraft.core.particles.ParticleTypes;
import net.minecraft.network.chat.Component;
import net.minecraft.resources.Identifier;
import net.minecraft.server.level.ServerBossEvent;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.sounds.SoundEvents;
import net.minecraft.sounds.SoundSource;
import net.minecraft.world.BossEvent;
import net.minecraft.world.entity.Entity;
import net.minecraft.world.entity.ai.attributes.AttributeInstance;
import net.minecraft.world.entity.ai.attributes.Attributes;
import net.minecraft.world.entity.boss.enderdragon.EnderDragon;
import net.minecraft.world.entity.monster.warden.Warden;
import net.minecraft.world.phys.AABB;
import net.minecraft.world.phys.Vec3;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;

public class WardenUpgradeMod implements ModInitializer {
	public static final String MOD_ID = "wardenupgrade";
	public static final Logger LOGGER = LoggerFactory.getLogger(MOD_ID);

	public static final String ACTIVATION_PHRASE = "Wardenio upgrade doe level.";

	public static final Set<UUID> UPGRADED_WARDENS = new HashSet<>();
	public static final Map<UUID, Integer> WARDEN_STAGES = new HashMap<>();
	public static final Map<UUID, Integer> WARDEN_PREV_STAGES = new HashMap<>();
	public static final Map<UUID, Float> WARDEN_MAX_HP = new HashMap<>();
	public static final Map<UUID, ServerBossEvent> WARDEN_BOSS_BARS = new HashMap<>();

	// Animation tracking
	public static final Map<UUID, Integer> ANIMATION_TICKS = new HashMap<>();
	public static final int ANIMATION_DURATION = 100; // 5 seconds = 100 ticks

	public static final float UPGRADED_MAX_HEALTH = 500.0f;
	public static final float STAGE_2_THRESHOLD = 0.66f;
	public static final float STAGE_3_THRESHOLD = 0.33f;

	public static Identifier id(String path) {
		return Identifier.fromNamespaceAndPath(MOD_ID, path);
	}

	@Override
	public void onInitialize() {
		LOGGER.info("Warden Upgrade mod initializing...");

		ModItems.register();

		ServerMessageEvents.CHAT_MESSAGE.register((message, sender, params) -> {
			String text = message.signedContent();
			if (text.equals(ACTIVATION_PHRASE)) {
				handleActivation(sender);
			}
		});

		ServerTickEvents.END_SERVER_TICK.register(server -> {
			for (ServerLevel level : server.getAllLevels()) {
				tickAnimations(level);
				tickUpgradedWardens(level);
			}
		});

		LOGGER.info("Warden Upgrade mod initialized!");
	}

	private void handleActivation(ServerPlayer player) {
		ServerLevel level = player.level();

		// Check if the Ender Dragon is alive
		boolean dragonAlive = false;
		ServerLevel endLevel = player.level().getServer().getLevel(net.minecraft.world.level.Level.END);
		if (endLevel != null) {
			for (Entity entity : endLevel.getAllEntities()) {
				if (entity instanceof EnderDragon dragon && dragon.isAlive()) {
					dragonAlive = true;
					break;
				}
			}
		}

		if (!dragonAlive) {
			player.sendSystemMessage(Component.literal("\u00a7c\u0414\u0440\u0430\u043a\u043e\u043d \u0434\u043e\u043b\u0436\u0435\u043d \u0431\u044b\u0442\u044c \u0436\u0438\u0432 \u0434\u043b\u044f \u0430\u043a\u0442\u0438\u0432\u0430\u0446\u0438\u0438!"));
			return;
		}

		// Find nearest Warden within 64 blocks
		AABB searchBox = player.getBoundingBox().inflate(64.0);
		List<Warden> wardens = level.getEntitiesOfClass(Warden.class, searchBox);

		if (wardens.isEmpty()) {
			player.sendSystemMessage(Component.literal("\u00a7c\u041f\u043e\u0431\u043b\u0438\u0437\u043e\u0441\u0442\u0438 \u043d\u0435\u0442 \u0412\u0430\u0440\u0434\u0435\u043d\u0430!"));
			return;
		}

		Warden warden = wardens.getFirst();
		UUID wardenId = warden.getUUID();

		if (UPGRADED_WARDENS.contains(wardenId)) {
			player.sendSystemMessage(Component.literal("\u00a7c\u042d\u0442\u043e\u0442 \u0412\u0430\u0440\u0434\u0435\u043d \u0443\u0436\u0435 \u0443\u0441\u0438\u043b\u0435\u043d!"));
			return;
		}

		// Start upgrade animation
		UPGRADED_WARDENS.add(wardenId);
		ANIMATION_TICKS.put(wardenId, 0);
		WARDEN_STAGES.put(wardenId, 1);
		WARDEN_PREV_STAGES.put(wardenId, 1);

		// Create boss bar
		ServerBossEvent bossBar = new ServerBossEvent(
				wardenId,
				Component.literal("\u2620 Upgraded Warden \u2620"),
				BossEvent.BossBarColor.BLUE,
				BossEvent.BossBarOverlay.NOTCHED_10
		);
		bossBar.setProgress(1.0f);
		bossBar.setDarkenScreen(true);
		bossBar.setCreateWorldFog(true);
		WARDEN_BOSS_BARS.put(wardenId, bossBar);

		// Add all nearby players to the boss bar
		for (ServerPlayer p : level.players()) {
			if (p.distanceTo(warden) < 64.0) {
				bossBar.addPlayer(p);
			}
		}

		// Broadcast activation message
		level.getServer().getPlayerList().broadcastSystemMessage(
				Component.literal("\u00a7d\u00a7l\u2726 \u0412\u0430\u0440\u0434\u0435\u043d \u043d\u0430\u0447\u0438\u043d\u0430\u0435\u0442 \u0442\u0440\u0430\u043d\u0441\u0444\u043e\u0440\u043c\u0430\u0446\u0438\u044e! \u2726"), false
		);

		// Play thunder sound
		level.playSound(null, warden.getX(), warden.getY(), warden.getZ(),
				SoundEvents.LIGHTNING_BOLT_THUNDER, SoundSource.HOSTILE, 2.0f, 0.5f);
	}

	private void tickAnimations(ServerLevel level) {
		Iterator<Map.Entry<UUID, Integer>> it = ANIMATION_TICKS.entrySet().iterator();
		while (it.hasNext()) {
			Map.Entry<UUID, Integer> entry = it.next();
			UUID wardenId = entry.getKey();
			int tick = entry.getValue();

			Entity entity = level.getEntityInAnyDimension(wardenId);
			if (!(entity instanceof Warden warden)) {
				it.remove();
				continue;
			}

			if (tick < ANIMATION_DURATION) {
				// Levitation effect - push warden up
				if (tick < 60) {
					Vec3 motion = warden.getDeltaMovement();
					warden.setDeltaMovement(motion.x, 0.15, motion.z);
					warden.hurtMarked = true;
				}

				// Spawn particles around the warden
				if (tick % 2 == 0) {
					double x = warden.getX();
					double y = warden.getY() + 1.0;
					double z = warden.getZ();
					for (int i = 0; i < 10; i++) {
						double offsetX = (level.getRandom().nextDouble() - 0.5) * 3.0;
						double offsetY = (level.getRandom().nextDouble() - 0.5) * 3.0;
						double offsetZ = (level.getRandom().nextDouble() - 0.5) * 3.0;
						level.sendParticles(ParticleTypes.SOUL_FIRE_FLAME,
								x + offsetX, y + offsetY, z + offsetZ,
								1, 0, 0, 0, 0.02);
						level.sendParticles(ParticleTypes.SCULK_SOUL,
								x + offsetX, y + offsetY, z + offsetZ,
								1, 0, 0, 0, 0.02);
					}
				}

				// Play periodic thunder sounds
				if (tick % 20 == 0) {
					level.playSound(null, warden.getX(), warden.getY(), warden.getZ(),
							SoundEvents.LIGHTNING_BOLT_THUNDER, SoundSource.HOSTILE, 1.5f, 0.7f);
				}

				entry.setValue(tick + 1);
			} else {
				// Animation complete - apply upgrade
				it.remove();
				applyUpgrade(warden, level);
			}
		}
	}

	private void applyUpgrade(Warden warden, ServerLevel level) {
		// Set max health to 500
		AttributeInstance healthAttr = warden.getAttribute(Attributes.MAX_HEALTH);
		if (healthAttr != null) {
			healthAttr.setBaseValue(UPGRADED_MAX_HEALTH);
			warden.setHealth(UPGRADED_MAX_HEALTH);
			WARDEN_MAX_HP.put(warden.getUUID(), UPGRADED_MAX_HEALTH);
		}

		// Increase attack damage (3x)
		AttributeInstance attackAttr = warden.getAttribute(Attributes.ATTACK_DAMAGE);
		if (attackAttr != null) {
			attackAttr.setBaseValue(attackAttr.getBaseValue() * 3.0);
		}

		// Increase speed
		AttributeInstance speedAttr = warden.getAttribute(Attributes.MOVEMENT_SPEED);
		if (speedAttr != null) {
			speedAttr.setBaseValue(speedAttr.getBaseValue() * 1.5);
		}

		// Increase knockback resistance
		AttributeInstance kbAttr = warden.getAttribute(Attributes.KNOCKBACK_RESISTANCE);
		if (kbAttr != null) {
			kbAttr.setBaseValue(1.0);
		}

		// Play upgrade complete sound
		level.playSound(null, warden.getX(), warden.getY(), warden.getZ(),
				SoundEvents.WITHER_SPAWN, SoundSource.HOSTILE, 2.0f, 0.5f);

		// Broadcast completion
		level.getServer().getPlayerList().broadcastSystemMessage(
				Component.literal("\u00a7b\u00a7l\u2726 \u0412\u0430\u0440\u0434\u0435\u043d \u0443\u0441\u0438\u043b\u0435\u043d! \u041f\u043e\u044f\u0432\u0438\u043b\u0430\u0441\u044c \u0437\u043b\u043e\u0432\u0435\u0449\u0430\u044f \u0430\u0443\u0440\u0430! \u2726"), false
		);

		// Spawn aura particles
		double x = warden.getX();
		double y = warden.getY() + 1.5;
		double z = warden.getZ();
		for (int i = 0; i < 50; i++) {
			double offsetX = (level.getRandom().nextDouble() - 0.5) * 4.0;
			double offsetY = (level.getRandom().nextDouble() - 0.5) * 4.0;
			double offsetZ = (level.getRandom().nextDouble() - 0.5) * 4.0;
			level.sendParticles(ParticleTypes.SOUL_FIRE_FLAME,
					x + offsetX, y + offsetY, z + offsetZ,
					3, 0, 0.05, 0, 0.05);
		}
	}

	private void tickUpgradedWardens(ServerLevel level) {
		Iterator<UUID> it = UPGRADED_WARDENS.iterator();
		while (it.hasNext()) {
			UUID wardenId = it.next();
			Entity entity = level.getEntityInAnyDimension(wardenId);

			if (!(entity instanceof Warden warden) || !warden.isAlive()) {
				it.remove();
				WARDEN_STAGES.remove(wardenId);
				WARDEN_PREV_STAGES.remove(wardenId);
				WARDEN_MAX_HP.remove(wardenId);
				ANIMATION_TICKS.remove(wardenId);
				ServerBossEvent bar = WARDEN_BOSS_BARS.remove(wardenId);
				if (bar != null) {
					bar.removeAllPlayers();
				}
				continue;
			}

			// Still in animation
			if (ANIMATION_TICKS.containsKey(wardenId)) {
				continue;
			}

			// Update boss bar - add/remove players based on distance
			ServerBossEvent bossBar = WARDEN_BOSS_BARS.get(wardenId);
			if (bossBar != null) {
				float maxHp = WARDEN_MAX_HP.getOrDefault(wardenId, UPGRADED_MAX_HEALTH);
				float currentHp = warden.getHealth();
				bossBar.setProgress(Math.clamp(currentHp / maxHp, 0.0f, 1.0f));

				// Update players in range
				for (ServerPlayer p : level.players()) {
					if (p.distanceTo(warden) < 64.0) {
						bossBar.addPlayer(p);
					} else {
						bossBar.removePlayer(p);
					}
				}
			}

			// Spawn aura particles every 5 ticks
			if (level.getServer().getTickCount() % 5 == 0) {
				double x = warden.getX();
				double y = warden.getY() + 1.5;
				double z = warden.getZ();
				for (int i = 0; i < 3; i++) {
					double angle = level.getRandom().nextDouble() * Math.PI * 2;
					double radius = 1.5 + level.getRandom().nextDouble();
					level.sendParticles(ParticleTypes.SOUL_FIRE_FLAME,
							x + Math.cos(angle) * radius,
							y + (level.getRandom().nextDouble() - 0.5) * 2.0,
							z + Math.sin(angle) * radius,
							1, 0, 0.02, 0, 0.01);
				}
			}

			// Track HP and stages
			float maxHp = WARDEN_MAX_HP.getOrDefault(wardenId, UPGRADED_MAX_HEALTH);
			float currentHp = warden.getHealth();
			float hpPercent = currentHp / maxHp;

			int newStage;
			if (hpPercent <= STAGE_3_THRESHOLD) {
				newStage = 3;
			} else if (hpPercent <= STAGE_2_THRESHOLD) {
				newStage = 2;
			} else {
				newStage = 1;
			}

			int prevStage = WARDEN_PREV_STAGES.getOrDefault(wardenId, 1);
			if (newStage != prevStage) {
				WARDEN_STAGES.put(wardenId, newStage);
				WARDEN_PREV_STAGES.put(wardenId, newStage);
				onStageTransition(warden, level, newStage);
			}
		}
	}

	private void onStageTransition(Warden warden, ServerLevel level, int stage) {
		// Play wither spawn sound
		level.playSound(null, warden.getX(), warden.getY(), warden.getZ(),
				SoundEvents.WITHER_SPAWN, SoundSource.HOSTILE, 2.0f, 0.8f + stage * 0.2f);

		// Broadcast stage message
		level.getServer().getPlayerList().broadcastSystemMessage(
				Component.literal("\u00a74\u00a7l\u26a0 \u0412\u0430\u0440\u0434\u0435\u043d \u0432\u043f\u0430\u0434\u0430\u0435\u0442 \u0432 \u044f\u0440\u043e\u0441\u0442\u044c! \u0421\u0442\u0430\u0434\u0438\u044f " + stage + " \u26a0"), false
		);

		// Update boss bar color based on stage
		ServerBossEvent bossBar = WARDEN_BOSS_BARS.get(warden.getUUID());
		if (bossBar != null) {
			BossEvent.BossBarColor color = switch (stage) {
				case 2 -> BossEvent.BossBarColor.PURPLE;
				case 3 -> BossEvent.BossBarColor.RED;
				default -> BossEvent.BossBarColor.BLUE;
			};
			bossBar.setColor(color);
			bossBar.setName(Component.literal("\u2620 Upgraded Warden - Stage " + stage + " \u2620"));
		}

		// Apply stage-specific buffs
		if (stage == 2) {
			AttributeInstance attackAttr = warden.getAttribute(Attributes.ATTACK_DAMAGE);
			if (attackAttr != null) {
				attackAttr.setBaseValue(attackAttr.getBaseValue() * 1.5);
			}
			AttributeInstance speedAttr = warden.getAttribute(Attributes.MOVEMENT_SPEED);
			if (speedAttr != null) {
				speedAttr.setBaseValue(speedAttr.getBaseValue() * 1.3);
			}
		} else if (stage == 3) {
			AttributeInstance attackAttr = warden.getAttribute(Attributes.ATTACK_DAMAGE);
			if (attackAttr != null) {
				attackAttr.setBaseValue(attackAttr.getBaseValue() * 1.5);
			}
			AttributeInstance speedAttr = warden.getAttribute(Attributes.MOVEMENT_SPEED);
			if (speedAttr != null) {
				speedAttr.setBaseValue(speedAttr.getBaseValue() * 1.5);
			}
		}

		// Explosion of particles
		double x = warden.getX();
		double y = warden.getY() + 1.5;
		double z = warden.getZ();
		for (int i = 0; i < 80; i++) {
			double offsetX = (level.getRandom().nextDouble() - 0.5) * 5.0;
			double offsetY = (level.getRandom().nextDouble() - 0.5) * 5.0;
			double offsetZ = (level.getRandom().nextDouble() - 0.5) * 5.0;
			level.sendParticles(ParticleTypes.SOUL_FIRE_FLAME,
					x + offsetX, y + offsetY, z + offsetZ,
					2, 0, 0.1, 0, 0.08);
			level.sendParticles(ParticleTypes.SCULK_SOUL,
					x + offsetX, y + offsetY, z + offsetZ,
					2, 0, 0.1, 0, 0.08);
		}

		// Screen shake effect via hurt animation packet
		for (ServerPlayer player : level.players()) {
			if (player.distanceTo(warden) < 64.0) {
				player.connection.send(
						new net.minecraft.network.protocol.game.ClientboundHurtAnimationPacket(player)
				);
			}
		}
	}
}
