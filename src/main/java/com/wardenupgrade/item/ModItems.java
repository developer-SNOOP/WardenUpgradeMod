package com.wardenupgrade.item;

import com.wardenupgrade.WardenUpgradeMod;
import net.minecraft.core.Registry;
import net.minecraft.core.registries.BuiltInRegistries;
import net.minecraft.resources.Identifier;
import net.minecraft.resources.ResourceKey;
import net.minecraft.sounds.SoundEvents;
import net.minecraft.tags.BlockTags;
import net.minecraft.tags.ItemTags;
import net.minecraft.world.item.Item;
import net.minecraft.world.item.Rarity;
import net.minecraft.world.item.ToolMaterial;
import net.minecraft.world.item.equipment.ArmorMaterial;
import net.minecraft.world.item.equipment.ArmorMaterials;
import net.minecraft.world.item.equipment.ArmorType;
import net.minecraft.world.item.equipment.EquipmentAsset;
import net.minecraft.world.item.equipment.EquipmentAssets;

import java.util.Map;

public class ModItems {

	// Hero tool material: 3x netherite stats
	// Netherite: durability=2031, speed=9.0, attackDamageBonus=4.0, enchantValue=15
	public static final ToolMaterial HERO_TOOL_MATERIAL = new ToolMaterial(
			BlockTags.INCORRECT_FOR_NETHERITE_TOOL,
			2031 * 3,   // durability 3x
			9.0f * 3,   // speed 3x
			4.0f * 3,   // attack damage bonus 3x
			15,         // enchant value
			ItemTags.NETHERITE_TOOL_MATERIALS
	);

	// Hero armor material: 3x netherite stats
	// Netherite: durability=37, defense (3,6,8,3,11), enchantValue=15, toughness=3.0, knockbackResistance=0.1
	public static final ArmorMaterial HERO_ARMOR_MATERIAL = new ArmorMaterial(
			37 * 3, // durability multiplier 3x
			Map.of(
					ArmorType.HELMET, 3 * 3,
					ArmorType.CHESTPLATE, 8 * 3,
					ArmorType.LEGGINGS, 6 * 3,
					ArmorType.BOOTS, 3 * 3,
					ArmorType.BODY, 11 * 3
			),
			15,
			SoundEvents.ARMOR_EQUIP_NETHERITE,
			3.0f * 3, // toughness 3x
			0.1f * 3, // knockback resistance 3x
			ItemTags.NETHERITE_TOOL_MATERIALS,
			EquipmentAssets.NETHERITE // Use netherite visuals as base
	);

	// Items
	public static Item CALAMITY_ARROW;
	public static Item HERO_SWORD;
	public static Item HERO_HELMET;
	public static Item HERO_CHESTPLATE;
	public static Item HERO_LEGGINGS;
	public static Item HERO_BOOTS;

	public static void register() {
		CALAMITY_ARROW = registerItem("calamity_arrow",
				new CalamityArrowItem(new Item.Properties()
						.rarity(Rarity.EPIC)
						.stacksTo(64)));

		HERO_SWORD = registerItem("hero_sword",
				new Item(new Item.Properties()
						.sword(HERO_TOOL_MATERIAL, 3.0f * 3, -2.4f)
						.rarity(Rarity.EPIC)
						.fireResistant()));

		HERO_HELMET = registerItem("hero_helmet",
				new Item(new Item.Properties()
						.humanoidArmor(HERO_ARMOR_MATERIAL, ArmorType.HELMET)
						.rarity(Rarity.EPIC)
						.fireResistant()));

		HERO_CHESTPLATE = registerItem("hero_chestplate",
				new Item(new Item.Properties()
						.humanoidArmor(HERO_ARMOR_MATERIAL, ArmorType.CHESTPLATE)
						.rarity(Rarity.EPIC)
						.fireResistant()));

		HERO_LEGGINGS = registerItem("hero_leggings",
				new Item(new Item.Properties()
						.humanoidArmor(HERO_ARMOR_MATERIAL, ArmorType.LEGGINGS)
						.rarity(Rarity.EPIC)
						.fireResistant()));

		HERO_BOOTS = registerItem("hero_boots",
				new Item(new Item.Properties()
						.humanoidArmor(HERO_ARMOR_MATERIAL, ArmorType.BOOTS)
						.rarity(Rarity.EPIC)
						.fireResistant()));

		WardenUpgradeMod.LOGGER.info("Warden Upgrade items registered!");
	}

	private static Item registerItem(String name, Item item) {
		Identifier id = WardenUpgradeMod.id(name);
		ResourceKey<Item> key = ResourceKey.create(BuiltInRegistries.ITEM.key(), id);
		return Registry.register(BuiltInRegistries.ITEM, key, item);
	}
}
