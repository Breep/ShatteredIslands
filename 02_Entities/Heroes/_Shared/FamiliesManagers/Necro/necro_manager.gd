class_name NecroManager
extends FamilyManager

## Necro family manager — card logic has been migrated to individual HeroUpgrades
## via CardContext registries. This manager is kept as a stub (no family-level passive).


func start() -> void:
	Verbose.debug("NecroManager start", Verbose.Category.FAMILY_MANAGER)


func stop() -> void:
	Verbose.debug("NecroManager stop", Verbose.Category.FAMILY_MANAGER)
