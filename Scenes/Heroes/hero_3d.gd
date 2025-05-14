class_name Hero3D
extends CharacterBody3D

@export var hero_id: Hero.HeroId

@onready var _collision_shape: CollisionShape3D = %CollisionShape3D
@onready var _animation_tree: AnimationTree = %AnimationTree
@onready var _state_machine: AnimationNodeStateMachinePlayback = _animation_tree.get("parameters/playback")

var gravity = 10 * Vector3.DOWN

var target_location: Vector3
var _is_moving:bool = true

func _process(delta: float) -> void:
	velocity = -20 * Vector3.RIGHT * delta
	velocity += gravity * delta
	_move_toward_target(delta)
	look_at_target_y_only(Vector3.ZERO)


func look_at_target_y_only(target_position: Vector3):
	var direction = target_position - global_transform.origin
	direction.y = 0  # Eliminate vertical component
	if direction.length() > 0.001:
		look_at(global_transform.origin + direction, Vector3.UP)


func _move_toward_target(delta: float):
	if not _is_moving:
		return
	
	if target_location == null or global_position.distance_to(target_location) < 0.2:
		_is_moving = false
		return
	
	var direction: Vector3 = (target_location - global_position).normalized()
	velocity = direction * 1000 * delta
	move_and_slide()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_K:
		attack()
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_J:
		idle()
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_L:
		run()


func idle():
	_state_machine.travel("Idle")


func attack():
	_state_machine.travel("Attack")


func run():
	_state_machine.travel("run_in_place")






func get_height() -> float:
	return (_collision_shape.shape as CapsuleShape3D).height


func attach_to_attack_done_signal(attack_done_signal: Signal) -> void:
	attack_done_signal.connect(_on_attack_done)


func _on_interaction_component_interacted() -> void:
	Events.hero_interacted.emit(hero_id)


func _on_attack_done() -> void:
	if _animation_tree == null:
		return
	_animation_tree["parameters/conditions/is_attacking"] = true
	await get_tree().create_timer(0.1).timeout
	_animation_tree["parameters/conditions/is_attacking"] = false
