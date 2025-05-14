class_name MovementModule
extends Node

signal energy_changed(energy: float)

var _source: Character # Ref to character owner
var _target_position: Vector3
var _is_moving: bool = false
var _fighting_state: GlobalFightingManager.FightingState

var _is_stopped: bool = false

@onready var _energy_regen_timer: Timer = %EnergyRegenTimer

func init(source: Character, fighting_state: GlobalFightingManager.FightingState) -> void:
	if source == null:
		printerr("MovementManager: source undef")
		return
	
	_source = source
	_fighting_state = fighting_state
	Events.map_clicked.connect(_on_events_map_clicked)
	#if not _source.player.is_bot:
		#Events.map_clicked.connect(_on_events_map_clicked)


func start() -> void:
	_source.stats.energy = _source.stats.energy_max
	_energy_regen_timer.start()
	_is_stopped = false


func stop() -> void:
	_is_stopped = true
	_energy_regen_timer.stop()


func set_fighting_state(new_state: GlobalFightingManager.FightingState) -> void:
	_fighting_state = new_state


func set_target_position(target_position: Vector3) -> void:
	_target_position = target_position
	_is_moving = true


func _process(delta: float) -> void:
	if _is_stopped:
		return
	_move_toward_target(delta)


func _move_toward_target(delta: float):
	if _source.stats.energy <= 0:
		_is_moving = false
	
	if not _is_moving:
		return
	
	if _target_position == null or _source.global_position.distance_to(_target_position) < 0.1:
		_is_moving = false
		return
	
	var previous_position = _source.global_position
	var direction: Vector3 = (_target_position - _source.global_position).normalized()
	
	
	_source.velocity = direction * _get_move_speed() * delta
	#print("DIRECTION ", direction)
	_source.move_and_slide()
	var distance_moved = _source.global_position.distance_to(previous_position)
	print("POS= ", _source.global_position)
	
	if _fighting_state != GlobalFightingManager.FightingState.STARTING:
		_source.stats.energy -= distance_moved
		energy_changed.emit(_source.stats.energy)


func _get_move_speed() -> float:
	var move_speed: float = _source.stats.move_speed
	if _fighting_state == GlobalFightingManager.FightingState.STARTING:
		return move_speed * 2
	else:
		return move_speed


func _on_energy_regen_timer_timeout() -> void:
	var period: float  = _energy_regen_timer.wait_time
	_source.stats.energy += _source.stats.energy_regen * period
	_source.stats.energy = clampf(_source.stats.energy, 0, _source.stats.energy_max)
	energy_changed.emit(_source.stats.energy)


func _on_events_map_clicked(battle_id: int, clicked_position: Vector3) -> void:
	if not battle_id == _source.battle_id:
		return
	
	clicked_position.y = 0
	print("SHOULD MOVE to ", clicked_position, "/", _source.global_position)
	_target_position = clicked_position
	_is_moving = true
