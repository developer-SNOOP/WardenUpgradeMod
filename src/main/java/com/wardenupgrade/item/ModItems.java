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
import net.minecraft.world.item.equipment.ArmorType;
import net.minecraft.world.item.equipment.EquipmentAssets;

import java.util.Map;
import java.util.function.Function;

public class ModItems {

	public static final ToolMaterial HERO_TOOL_MATERIAL = new ToolMaterial(
			BlockTags.INCORRECT_FOR_NETHERITE_TOOL,
			2031 * 3,
			9.0f * 3,
			4.0f * 3,
			15,
			ItemTags.NETHERITE_TOOL_MATERIALS
	);

	public static final ArmorMaterial HERO_ARMOR_MATERIAL = new ArmorMaterial(
			37 * 3,
			Map.of(
					ArmorType.HELMET, 3 * 3,
					ArmorType.CHESTPLATE, 8 * 3,
					ArmorType.LEGGINGS, 6 * 3,
					ArmorType.BOOTS, 3 * 3,
					ArmorType.BODY, 11 * 3
			),
			15,
			SoundEvents.ARMOR_EQUIP_NETHERITE,
			3.0f * 3,
			0.1f * 3,
			ItemTags.NETHERITE_TOOL_MATERIALS,
			EquipmentAssets.NETHERITE
	);

	public static Item CALAMITY_ARROW;
	public static Item HERO_SWORD;
	public static Item HERO_HELMET;
	public static Item HERO_CHESTPLATE;
	public static Item HERO_LEGGINGS;
	public static Item HERO_BOOTS;

	public static void register() {
		CALAMITY_ARROW = registerItem("calamity_arrow",
				props -> new CalamityArrowItem(props.rarity(Rarity.EPIC).stacksTo(64)));

		HERO_SWORD = registerItem("hero_sword",
				props -> new Item(props
						.sword(HERO_TOOL_MATERIAL, 3.0f * 3, -2.4f)
						.rarity(Rarity.EPIC)
						.fireResistant()));

		HERO_HELMET = registerItem("hero_helmet",
				props -> new Item(props
						.humanoidArmor(HERO_ARMOR_MATERIAL, ArmorType.HELMET)
						.rarity(Rarity.EPIC)
						.fireResistant()));

		HERO_CHESTPLATE = registerItem("hero_chestplate",
				props -> new Item(props
						.humanoidArmor(HERO_ARMOR_MATERIAL, ArmorType.CHESTPLATE)
						.rarity(Rarity.EPIC)
						.fireResistant()));

		HERO_LEGGINGS = registerItem("hero_leggings",
				props -> new Item(props
						.humanoidArmor(HERO_ARMOR_MATERIAL, ArmorType.LEGGINGS)
						.rarity(Rarity.EPIC)
						.fireResistant()));

		HERO_BOOTS = registerItem("hero_boots",
				props -> new Item(props
						.humanoidArmor(HERO_ARMOR_MATERIAL, ArmorType.BOOTS)
						.rarity(Rarity.EPIC)
						.fireResistant()));

		WardenUpgradeMod.LOGGER.info("Warden Upgrade items registered!");
	}

	private static Item registerItem(String name, Function<Item.Properties, Item> factory) {
		Identifier id = WardenUpgradeMod.id(name);
		ResourceKey<Item> key = ResourceKey.create(BuiltInRegistries.ITEM.key(), id);
		Item.Properties props = new Item.Properties().setId(key);
		Item item = factory.apply(props);
		return Registry.register(BuiltInRegistries.ITEM, key, item);
	}
}
