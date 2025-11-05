class_name SnakeBarrel
extends Entity

@onready var _interact_module: InteractModule = %InteractModule

#region ===== Interaction [VIRTUAL]
func take_damage(damage: int, damage_type: Utils.DamageType, is_critical: bool = false, source: Entity = null, attack_type: Utils.AttackType = Utils.AttackType.UNDEF) -> int:
	return _interact_module.take_damage(damage, damage_type, is_critical, source, attack_type)

func take_damage_percent(percent: float, percent_modifier: Utils.PercentModifier, damage_type: Utils.DamageType, is_critical: bool = false, source: Entity = null) -> void:
	return _interact_module.take_damage_percent(percent, percent_modifier, damage_type, is_critical, source)

func take_condition_stacks(stacks_number: int, stack_type: Utils.StackType, source: Character = null) -> void:
	_interact_module.take_condition_stacks(stacks_number, stack_type, source)

func take_heal(heal_amount: int, source: Character = null) -> void:
	_interact_module.take_heal(heal_amount, source)
#endregion


func _ready() -> void:
	stats.health = stats.health_max
	stats.health_changed.connect(_on_stats_health_changed)


func _on_stats_health_changed(new_health: int) -> void:
	if new_health <= 0:
		signal_death()
