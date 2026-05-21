class_name PoisonManager
extends FamilyManager

## Poison family manager — card logic has been migrated to individual HeroUpgrades
## via CardContext registries. This manager now only handles family-level mechanics
## (if any are added in the future).

var _poison_stats: FamilyPoisonStats

func _ready() -> void:
	_poison_stats = _owner.families_stats.poison


func start() -> void:
	Verbose.debug("PoisonManager start", Verbose.Category.FAMILY_MANAGER)


func stop() -> void:
	Verbose.debug("PoisonManager stop", Verbose.Category.FAMILY_MANAGER)
