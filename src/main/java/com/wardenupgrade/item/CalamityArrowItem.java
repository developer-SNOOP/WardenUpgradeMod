package com.wardenupgrade.item;

import net.minecraft.world.effect.MobEffectInstance;
import net.minecraft.world.effect.MobEffects;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.entity.projectile.arrow.AbstractArrow;
import net.minecraft.world.entity.projectile.arrow.Arrow;
import net.minecraft.world.item.ArrowItem;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.level.Level;

public class CalamityArrowItem extends ArrowItem {

	public CalamityArrowItem(Properties properties) {
		super(properties);
	}

	@Override
	public AbstractArrow createArrow(Level level, ItemStack ammo, LivingEntity shooter, ItemStack weapon) {
		Arrow arrow = new Arrow(level, shooter, ammo, weapon);
		// Slowness X for 10 ticks (0.5 seconds) = stun effect
		arrow.addEffect(new MobEffectInstance(MobEffects.SLOWNESS, 10, 9, false, true));
		// Movement slowdown to simulate stun
		arrow.addEffect(new MobEffectInstance(MobEffects.MINING_FATIGUE, 10, 9, false, true));
		// Wither effect for 60 ticks (3 seconds) - deals 0.5 hp/sec damage
		arrow.addEffect(new MobEffectInstance(MobEffects.WITHER, 60, 0, false, true));
		return arrow;
	}
}
