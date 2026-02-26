class_name SerenityManager
extends FamilyManager

## Serenity family manager — card logic has been migrated to individual HeroUpgrades
## via CardContext registries. This manager is kept as a stub (no family-level passive).

func start() -> void:
	Verbose.debug("SerenityManager start", Verbose.Category.FAMILY_MANAGER)


func stop() -> void:
	Verbose.debug("SerenityManager stop", Verbose.Category.FAMILY_MANAGER)
