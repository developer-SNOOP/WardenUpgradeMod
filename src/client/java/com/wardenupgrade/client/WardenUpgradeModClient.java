package com.wardenupgrade.client;

import net.fabricmc.api.ClientModInitializer;

public class WardenUpgradeModClient implements ClientModInitializer {

	@Override
	public void onInitializeClient() {
		// Boss bar HP display is handled server-side via ServerBossEvent
		// Client module reserved for future visual enhancements
	}
}
