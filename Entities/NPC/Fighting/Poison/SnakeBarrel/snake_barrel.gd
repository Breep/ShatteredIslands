class_name SnakeBarrel
extends Entity

@onready var _interact_module: InteractModule = %InteractModule
@onready var _action_module: ActionModule = %ActionModule
@onready var _snake_barrel_visual: Node3D = %SnakeBarrelVisual

func projectile_attack(target: Entity, projectile_type: Projectile.ProjectileType, projectile_spawn: Node3D, projectile_stats: ProjectileStats) -> void:
	_action_module.projectile_attack(target, projectile_type, projectile_spawn, projectile_stats)


func inflict_condition_stacks(target: Entity, stacks_number: float, stack_type: Utils.StackType, action_id: StringName) -> void:
	_action_module.inflict_condition_stacks(target, stacks_number, stack_type, action_id)


#region ===== Interaction
func take_damage(damage: float, damage_type: Utils.DamageType, is_critical: bool = false, source: Entity = null, attack_type: Utils.AttackType = Utils.AttackType.UNDEF) -> float:
	return _interact_module.take_damage(damage, damage_type, is_critical, source, attack_type)

func take_damage_percent(percent: float, percent_modifier: Utils.PercentModifier, damage_type: Utils.DamageType, is_critical: bool = false, source: Entity = null) -> void:
	return _interact_module.take_damage_percent(percent, percent_modifier, damage_type, is_critical, source)

func take_condition_stacks(stacks_number: float, stack_type: Utils.StackType, is_critical: bool, source: Entity = null) -> float:
	return _interact_module.take_condition_stacks(stacks_number, stack_type, is_critical, source)

func take_heal(heal_amount: float, is_critical: bool, source: Entity = null) -> float:
	return _interact_module.take_heal(heal_amount, is_critical, source)

func summon_entity(entity_type: EntityType, entity_spawn_global_position: Vector3, entity_modifier: Dictionary) -> void:
	_action_module.summon_entity(entity_type, entity_spawn_global_position, entity_modifier)
#endregion

var _max_health: int = 100
var _snake_number: int = 10
var _snake_poison_stacks: int = 10

func init(snake_number: int, snake_poison_stacks: int, max_health: int) -> void:
	_max_health = max_health
	_snake_number = snake_number
	_snake_poison_stacks = snake_poison_stacks


func connect_to_fighting_area(fighting_area: FightingArea) -> void:
	_action_module.connect_to_spawn_manager(fighting_area.spawn_manager)


func _ready() -> void:
	_snake_barrel_visual.scale = Vector3.ZERO
	stats.health_max = _max_health
	stats.health = stats.health_max
	stats.health_changed.connect(_on_stats_health_changed)
	var pop := create_tween()
	pop.tween_property(_snake_barrel_visual, "scale", Vector3.ONE * 1.25, 0.08)
	pop.tween_property(_snake_barrel_visual, "scale", Vector3.ONE * 1, 0.08)


func _on_stats_health_changed(new_health: int) -> void:
	if new_health <= 0:
		signal_death()
		_animate_death()
		_spawn_snakes(_snake_number)


func _animate_death() -> void:
	var pop := create_tween()
	pop.tween_property(_snake_barrel_visual, "scale", Vector3.ONE * 1.25, 0.08)
	pop.tween_property(_snake_barrel_visual, "scale", Vector3.ZERO, 0.08)


func _spawn_snakes(snake_number: int) -> void:
	var spread: float = 1.5
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var spawn_node := Node3D.new()
	add_child(spawn_node)
	for i in snake_number:
		var projectile_stats := ProjectileStats.new()
		projectile_stats.poison_stacks = _snake_poison_stacks
		var target = target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
		if target == null: return
		spawn_node.position = Vector3(rng.randf_range(-spread, spread), rng.randf_range(0, spread), rng.randf_range(-spread, spread))
		projectile_attack(target, Projectile.ProjectileType.SNAKE, spawn_node, projectile_stats)
	queue_free()
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		 
