class_name ProtoShield
extends Summon

enum Modifier {
	SHIELD,
	HP_MAX
}

var _on_spawn_shield_amount: float
var _on_spawn_hp_max: float

func init(shield_amount: float, hp_max: int) -> Summon:
	_on_spawn_shield_amount = shield_amount
	_on_spawn_hp_max = hp_max
	return self


func _ready() -> void:
	take_condition_stacks(_on_spawn_shield_amount, Stack.Type.SHIELD, false, "Initial shield")
	take_status(Status.Type.TAUNT, -1, "Initial taunt", self)
	_base_stats.health_max = _on_spawn_hp_max
	stat_modifiers_registry.recompute_all()
	super._ready()
