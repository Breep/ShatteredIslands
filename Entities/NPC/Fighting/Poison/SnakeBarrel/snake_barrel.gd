class_name SnakeBarrel
extends Entity

@onready var _interact_module: InteractModule = %InteractModule
@onready var _action_module: ActionModule = %ActionModule
@onready var _snake_barrel_visual: Node3D = %SnakeBarrelVisual

#region ===== Interaction [VIRTUAL]
func take_damage(damage: int, damage_type: Utils.DamageType, is_critical: bool = false, source: Entity = null, attack_type: Utils.AttackType = Utils.AttackType.UNDEF) -> int:
	return _interact_module.take_damage(damage, damage_type, is_critical, source, attack_type)

func take_damage_percent(percent: float, percent_modifier: Utils.PercentModifier, damage_type: Utils.DamageType, is_critical: bool = false, source: Entity = null) -> void:
	return _interact_module.take_damage_percent(percent, percent_modifier, damage_type, is_critical, source)

func take_condition_stacks(stacks_number: int, stack_type: Utils.StackType, source: Character = null) -> void:
	_interact_module.take_condition_stacks(stacks_number, stack_type, source)

func take_heal(heal_amount: int, source: Character = null) -> void:
	_interact_module.take_heal(heal_amount, source)

func summon_entity(entity_type: EntityType, entity_spawn_global_position: Vector3, entity_modifier: Dictionary) -> void:
	_action_module.summon_entity(entity_type, entity_spawn_global_position, entity_modifier)
#endregion

var _start_position: Vector3

func init(start_position: Vector3) -> void:
	_start_position = start_position

func connect_to_fighting_area(fighting_area: FightingArea) -> void:
	_action_module.connect_to_spawn_manager(fighting_area.spawn_manager)


func _ready() -> void:
	_snake_barrel_visual.scale = Vector3.ZERO
	stats.health = stats.health_max
	stats.health_changed.connect(_on_stats_health_changed)
	var pop := create_tween()
	pop.tween_property(_snake_barrel_visual, "scale", Vector3.ONE * 1.25, 0.08)
	pop.tween_property(_snake_barrel_visual, "scale", Vector3.ONE * 1, 0.08)


func _on_stats_health_changed(new_health: int) -> void:
	if new_health <= 0:
		signal_death()
		_animate_death()
		_spawn_snakes(5)


func _animate_death() -> void:
	var pop := create_tween()
	pop.tween_property(_snake_barrel_visual, "scale", Vector3.ONE * 1.25, 0.08)
	pop.tween_property(_snake_barrel_visual, "scale", Vector3.ZERO, 0.08)

func _spawn_snakes(snake_number: int) -> void:
	var spread: float = 0.5
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in snake_number:
		var spawn_pos := Vector3(rng.randf_range(-spread, spread), 0, rng.randf_range(-spread, spread))
		summon_entity(Entity.EntityType.SNAKE, to_global(spawn_pos), {})
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		 
