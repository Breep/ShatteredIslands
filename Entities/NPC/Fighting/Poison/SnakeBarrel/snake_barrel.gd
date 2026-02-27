class_name SnakeBarrel
extends Summon

const CLEANUP_TIME: int = 5

@onready var _snake_barrel_visual: Node3D = %SnakeBarrelVisual

var _max_health: int = 100
var _snake_number: int = 10
var _snake_poison_stacks: int = 10

var _ticks_before_cleanup: int = 0

func init(snake_number: int, snake_poison_stacks: int, max_health: int) -> Summon:
	_max_health = max_health
	_snake_number = snake_number
	_snake_poison_stacks = snake_poison_stacks
	return self


func process_tick() -> void:
	super.process_tick()
	if _ticks_before_cleanup > 0:
		_ticks_before_cleanup -= 1
		if _ticks_before_cleanup == 0:
			queue_free()


func _start_cleanup_timer() -> void:
	_ticks_before_cleanup = CLEANUP_TIME * TICKS_PER_SECOND


func _animate_death() -> void:
	var pop := create_tween()
	pop.tween_property(_snake_barrel_visual, "scale", Vector3.ONE * 1.5, 0.16)
	pop.tween_property(_snake_barrel_visual, "scale", Vector3.ZERO, 0.16)


func _spawn_snakes(snake_number: int) -> void:
	var spawn_location_config := SpawnLocationConfig.create_entity_relative(self, 1.5)
	for i in snake_number:
		summon_entity(Entity.EntityType.SNAKE, spawn_location_config, {})
	_start_cleanup_timer()


func _on_died() -> void:
	super._on_died()
	_animate_death()
	_spawn_snakes(_snake_number)
