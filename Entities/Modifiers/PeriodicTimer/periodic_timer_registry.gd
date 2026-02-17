class_name PeriodicTimerRegistry
extends Node

## Registry that creates and manages periodic timers on behalf of cards.
## Cards (Resources) can't own Nodes, so this registry owns the Timer children.
## Supports pause/resume (for STUN) and full cleanup on battle end.

var _timers: Dictionary[StringName, Timer] = {}
var _paused_timers: Dictionary[StringName, float] = {} # id -> time_left


func register(id: StringName, period: float, callback: Callable, autostart: bool = false) -> void:
	if _timers.has(id):
		unregister(id)

	var timer := Timer.new()
	timer.wait_time = period
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(callback)
	_timers[id] = timer

	if autostart:
		timer.start()


func unregister(id: StringName) -> void:
	if not _timers.has(id):
		return

	var timer: Timer = _timers[id]
	timer.stop()
	timer.queue_free()
	_timers.erase(id)
	_paused_timers.erase(id)


func start_all() -> void:
	for id: StringName in _timers.keys():
		Verbose.debug("Starting [" + id + "] periodic timer")
		_timers[id].start()


func stop_all() -> void:
	for id: StringName in _timers.keys():
		Verbose.debug("Stopping [" + id + "] periodic timer")
		_timers[id].stop()
	_paused_timers.clear()


func pause_all() -> void:
	for id: StringName in _timers.keys():
		var timer: Timer = _timers[id]
		if not timer.is_stopped():
			_paused_timers[id] = timer.time_left
			timer.stop()


func resume_all() -> void:
	for id: StringName in _timers.keys():
		if _paused_timers.has(id):
			_timers[id].start(_paused_timers[id])
	_paused_timers.clear()


func clear_all() -> void:
	for id: StringName in _timers.keys():
		_timers[id].stop()
		_timers[id].queue_free()
	_timers.clear()
	_paused_timers.clear()
