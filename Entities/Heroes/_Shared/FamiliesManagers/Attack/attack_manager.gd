class_name AttackManager
extends FamilyManager

## Attack family manager — card logic has been migrated to individual HeroUpgrades
## via CardContext registries. This manager is kept as a stub (no family-level passive).


func start() -> void:
	Verbose.debug("AttackManager start", Verbose.Category.FAMILY_MANAGER)


func stop() -> void:
	Verbose.debug("AttackManager stop", Verbose.Category.FAMILY_MANAGER)
