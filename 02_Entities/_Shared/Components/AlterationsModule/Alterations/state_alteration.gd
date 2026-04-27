class_name StateAlteration
extends Alteration

## Alteration whose state is a plain boolean — no timer, no stack count.
## Placeholder for future purely on/off flags that don't fit Stack or Timed.

signal state_changed(is_active: bool)

var _active: bool = false
var _applications: int = 0


var is_active: bool:
	get: return _active


func apply() -> void:
	if stackable:
		_applications += 1
	if _active: return
	_active = true
	state_changed.emit(true)
	_on_added()


func cancel() -> void:
	if stackable and _applications > 1:
		_applications -= 1
		return
	if not _active: return
	_applications = 0
	_active = false
	state_changed.emit(false)
	_on_removed()
