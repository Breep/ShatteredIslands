class_name SnakeBarrel
extends Entity

@onready var _snake_barrel_visual: Node3D = %SnakeBarrelVisual

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
