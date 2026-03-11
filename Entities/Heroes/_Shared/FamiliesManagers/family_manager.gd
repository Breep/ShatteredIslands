class_name FamilyManager
extends Node

var _owner: Hero # Ref to Hero owner
var level: int = 0 # Family level (0-4), computed from deck or overridden via prototyping

var _optional_timers: Array[Timer]
var _optional_spells: Array[Node]

func _ready() -> void:
	if _owner == null:
		printerr("FamilyManager: Need a hero owner [", get_path(), "]")
		queue_free()


func init(hero_owner: Hero) -> FamilyManager:
	_owner = hero_owner
	return self


func start() -> void:
	printerr("FamilyManager: virtual start() called [", get_path(), "]")


func stop() -> void:
	printerr("FamilyManager: virtual stop() called [", get_path(), "]")


var _paused_timers: Dictionary = {}

func pause() -> void:
	for timer: Timer in _optional_timers:
		if not is_instance_valid(timer) or timer.is_queued_for_deletion():
			continue
			
		if not timer.is_stopped():
			_paused_timers[timer] = timer.time_left
			timer.stop()


func resume() -> void:
	for timer: Timer in _paused_timers.keys():
		if not is_instance_valid(timer) or timer.is_queued_for_deletion():
			continue
			
		var time_left: float = _paused_timers[timer]
		timer.start(time_left)
	
	_paused_timers.clear()
