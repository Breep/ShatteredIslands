class_name ManaManager
extends FamilyManager

@export_group("Configuration")
@export var _timer_wait_time: float = 0.1

@onready var _mana_tick_timer: Timer = %ManaTickTimer


func start() -> void:
	_mana_tick_timer.start()


func stop() -> void:
	_mana_tick_timer.stop()
	_owner.stats.mana = 0


func _on_mana_tick_timer_timeout() -> void:
	var inc: float = _owner.stats.mana_regen * _timer_wait_time
	_owner.stats.mana += inc
	
	if _owner.stats.mana >= _owner.stats.mana_max:
		_owner.cast_ultimate()
		_owner.stats.mana -= _owner.stats.mana_max
