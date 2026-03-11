class_name LifeManager
extends FamilyManager
## Life/Colossus family manager — card logic has been migrated to individual HeroUpgrades
## via CardContext registries. This manager is kept as a stub (no family-level passive).


func start() -> void:
	Verbose.debug("LifeManager start", Verbose.Category.FAMILY_MANAGER)


func stop() -> void:
	Verbose.debug("LifeManager stop", Verbose.Category.FAMILY_MANAGER)
