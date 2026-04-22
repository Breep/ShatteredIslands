class_name TimedAlteration
extends Alteration

## Alteration whose state is a float time remaining (seconds).
## process_tick decrements `_time_left` every physics tick. When it reaches 0
## `expired` fires and the module will call _on_removed().
## `_time_left == INFINITE` (-1) means the alteration is active indefinitely.

signal time_changed(time_left: float, infinite: bool)
signal expired()
## Fires once when the alteration transitions from inactive to active.
signal activated(duration: float, infinite: bool)
## Fires once when the alteration transitions from active to inactive (expiry or cancel).
signal deactivated()

const INFINITE: float = -1.0

var _time_left: float = 0.0
var _infinite: bool = false


func _init() -> void:
	stackable = false


var time_left: float:
	get: return _time_left

var is_active: bool:
	get: return _infinite or _time_left > 0.0

var is_infinite: bool:
	get: return _infinite


## Apply/refresh the alteration. `duration` == INFINITE (-1) makes it permanent.
## Default (stackable=false): a longer duration replaces; shorter is a no-op.
## stackable=true: duration is added to remaining.
func apply(duration: float) -> void:
	if duration == INFINITE:
		var was_active_inf := is_active
		_infinite = true
		_time_left = 0.0
		time_changed.emit(_time_left, true)
		if not was_active_inf:
			_on_added()
			activated.emit(INFINITE, true)
		return

	if duration <= 0: return
	if _infinite: return

	var was_active := is_active
	if stackable:
		_time_left += duration
	elif duration > _time_left:
		_time_left = duration
	else:
		return

	time_changed.emit(_time_left, false)
	if not was_active:
		_on_added()
		activated.emit(_time_left, false)


## Cancel immediately.
func cancel() -> void:
	if not is_active: return
	_time_left = 0.0
	_infinite = false
	time_changed.emit(0.0, false)
	_on_removed()
	deactivated.emit()
	expired.emit()


func process_tick() -> void:
	if not is_active or _infinite: return
	_time_left -= TICK_DELTA
	if _time_left <= 0.0:
		_time_left = 0.0
		time_changed.emit(0.0, false)
		_on_removed()
		deactivated.emit()
		expired.emit()
	else:
		time_changed.emit(_time_left, false)
