class_name MovementManager
extends Node

signal energy_changed(energy: float)

var _source: Character # Ref to character owner
var _target_position: Vector3
var _is_moving: bool = false
var _fighting_state: FightingManager.FightingState

@onready var _energy_regen_timer: Timer = %EnergyRegenTimer

func start(source: Character, fighting_state: FightingManager.FightingState) -> void:
	if source == null:
		printerr("MovementManager: source undef")
		return
	
	_source = source
	_fighting_state = fighting_state
	_energy_regen_timer.start()


func set_fighting_state(new_state: FightingManager.FightingState) -> void:
	_fighting_state = new_state


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_move_toward_target(delta)


func _move_toward_target(delta: float):
	if not _is_moving or _source.stats.energy <= 0:
		_is_moving = false
	
	if not _is_moving:
		return
	
	if _target_position == null or _source.global_position.distance_to(_target_position) < 0.1:
		return
	
	var previous_position = _source.global_position
	var direction: Vector3 = (_target_position - _source.global_position).normalized()
	
	if _fighting_state == FightingManager.FightingState.STARTING:
		_source.velocity = direction * _source.stats.move_speed * 2
	else:
		_source.velocity = direction * _source.stats.move_speed
	
	_source.move_and_slide()
	var distance_moved = _source.global_position.distance_to(previous_position)
	
	if _fighting_state != FightingManager.FightingState.STARTING:
		_source.stats.energy -= distance_moved
		energy_changed.emit(_source.stats.energy)


func set_target_position(target_position: Vector3) -> void:
	_target_position = target_position
	_is_moving = true


func _on_energy_regen_timer_timeout() -> void:
	var period: float  = _energy_regen_timer.wait_time
	_source.stats.energy += _source.stats.energy_regen * period
	_source.stats.energy = clampf(_source.stats.energy, 0, _source.stats.energy_max)
	energy_changed.emit(_source.stats.energy)
