class_name GoblinFocus
extends Spell

enum Modifier {
	DAMAGE,
	STACK_TYPE,
	STACK_NUMBER
}

var _owner: Entity
var _damage: float
var _stack_type: Alteration.Type
var _stack_number: int
var target_: Entity
var _move_speed: float = 15
const ACCELERATION: float = 30
var _direction: Vector3

func init(source: Entity, modifiers: Dictionary, target: Entity, on_hit_callbacks: Array = []) -> void:
	_damage = modifiers.get(Modifier.DAMAGE)
	_stack_type = modifiers.get(Modifier.STACK_TYPE)
	_stack_number = modifiers.get(Modifier.STACK_NUMBER)
	target_ = target
	_owner = source


func _ready() -> void:
	if target_ == null:
		printerr("Goblin Focus: No target assigned to [", get_path(), "]")
		queue_free()
		return
	global_position = _owner._attack_spawn_marker.global_position
	
	# Init projectile
	look_at(target_.global_position)
	_direction = (target_.global_position - global_position)
	_direction.y = 0
	_direction = _direction.normalized()
	rotation.x = 0
	AudioManager.play_3d("meteor", global_position, 0.95)


func _process(delta: float) -> void:
	#_elapsed += delta
	#var linear_t := clampf(_elapsed / _deploy_time, 0.0, 1.0)
	#var eased_t := linear_t * linear_t #* linear_t * linear_t
	_move_speed += ACCELERATION * delta
	global_position += _direction * _move_speed * delta
	


func _on_body_entered(body: Node3D) -> void:
	if not body is Entity: return
	var entity: Entity = body
	
	if entity.team != _owner.team:
		_owner.damage.direct(entity, _damage, Utils.ActionType.DAMAGE_PHYSICAL, &"GoblinFocus")
		_owner.alterations.direct_stack(entity, _stack_number, _stack_type, &"GoblinFocus")
		


func _on_despawn_timer_timeout() -> void:
	queue_free()
