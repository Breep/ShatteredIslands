class_name DeflectionShield
extends Summon

enum Modifier {
	BLOCKED_PROJECTILES,
	SHIELD_PER_BLOCK,
}

var _blocked_projectiles: int
var _shield_per_block: float

@onready var _health_bar: SummonSimpleInfoPanel2D = %HealthBar

func init(blocked_projectiles: int, shield_per_block: float) -> Summon:
	_blocked_projectiles = blocked_projectiles
	_shield_per_block = shield_per_block
	return self


func _ready() -> void:
	base_stats.health_max = _blocked_projectiles
	_health_bar.setup_grid_bar(1, -1)
	take_status(Status.Type.INVULNERABLE, -1, "Invulnerable")
	take_status(Status.Type.UNTARGETABLE, -1, "Untargetable")
	stat_modifiers_registry.recompute_all()
	_movement_module.orbit_entity(summoner, 2, 2)
	super._ready()
