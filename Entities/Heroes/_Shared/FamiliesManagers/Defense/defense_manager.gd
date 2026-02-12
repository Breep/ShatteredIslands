class_name DefenseManager
extends FamilyManager

## Defense family manager — card logic has been migrated to individual HeroUpgrades
## via CardContext registries. This manager is kept as a stub (no family-level passive).


func start() -> void:
	Verbose.debug("DefenseManager start", Verbose.Category.FAMILY_MANAGER)


func stop() -> void:
	Verbose.debug("DefenseManager stop", Verbose.Category.FAMILY_MANAGER)
