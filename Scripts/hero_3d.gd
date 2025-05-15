class_name Hero3D
extends CharacterBody3D

@export var hero_id: Hero.HeroId

@export var _collision_shape: CollisionShape3D
@export var _animation_tree: AnimationTree


var gravity = 10 * Vector3.DOWN

var target_location: Vector3
var _is_moving:bool = true

var _move_speed: float = 0.5

func _process(delta: float) -> void:
	_update_animation()
	_move_speed = 0.5
	_move_toward_target(delta)


func _update_animation() -> void:
	print(velocity.length_squared())
	if velocity.length_squared() > 10:
		run()
	else:
		idle()


func look_at_target_y_only(target_position: Vector3):
	var direction = target_position - global_transform.origin
	direction.y = 0  # Eliminate vertical component
	if direction.length() > 0.1:
		look_at(global_transform.origin + direction, Vector3.UP)


func _move_toward_target(delta: float):
	if not _is_moving:
		velocity = Vector3.ZERO
		return
	
	print(" DISTANCE     ", global_position.distance_to(target_location))
	if target_location == null or global_position.distance_to(target_location) < 0.2:
		_is_moving = false
		return
	
	var direction: Vector3 = (target_location - global_position).normalized()
	velocity = direction * _move_speed * 500 * delta
	move_and_slide()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_K:
		attack()
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_J:
		idle()
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_L:
		run()


func idle():
	print("IDLE")
	_animation_tree.set("parameters/Movement/transition_request", "Idle")


func attack():
	print("ATTACK")
	_animation_tree.set("parameters/Attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	look_at_target_y_only(Vector3.ZERO)


func run():
	print("RUN")
	_animation_tree.set("parameters/Movement/transition_request", "Run")
	look_at_target_y_only(target_location)





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


func _on_tmp_timer_timeout() -> void:
	attack()
