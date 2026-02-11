class_name SnakeBarrel
extends Summon

@onready var _snake_barrel_visual: Node3D = %SnakeBarrelVisual

var _max_health: int = 100
var _snake_number: int = 10
var _snake_poison_stacks: int = 10

func init(snake_number: int, snake_poison_stacks: int, max_health: int) -> Summon:
	_max_health = max_health
	_snake_number = snake_number
	_snake_poison_stacks = snake_poison_stacks
	return self


func _animate_death() -> void:
	var pop := create_tween()
	pop.tween_property(_snake_barrel_visual, "scale", Vector3.ONE * 1.25, 0.08)
	pop.tween_property(_snake_barrel_visual, "scale", Vector3.ZERO, 0.08)


func _spawn_snakes(snake_number: int) -> void:
	var spawn_location_config := SpawnLocationConfig.create_entity_relative(self, 1.5)
	for i in snake_number:
		summon_entity(Entity.EntityType.SNAKE, spawn_location_config, {})
	queue_free()


func _on_died(_entity: Entity) -> void:
	super._on_died(_entity)
	_animate_death()
	_spawn_snakes(_snake_number)
