class_name StatusModule
extends Module

# ============================== Signals ==============================

signal status_added(status_type: Status.Type, duration: float)
signal status_removed(status_type: Status.Type)

# Status-specific signals (emitted when status is first applied or fully removed)
signal stunned_changed(is_active: bool, duration: float)
signal taunted_changed(is_active: bool, duration: float)
signal silenced_changed(is_active: bool, duration: float)
signal invulnerable_changed(is_active: bool, duration: float)
signal untargetable_changed(is_active: bool, duration: float)

# ============================== Public variables ==============================


# ============================== Private variables ==============================

# Dictionary[Status.Type, float] - Remaining duration for each status (0 = inactive)
var _remaining_durations: Dictionary[Status.Type, float]

@onready var _stun_timer: Timer = %StunTimer
@onready var _taunt_timer: Timer = %TauntTimer
@onready var _silence_timer: Timer = %SilenceTimer
@onready var _invulnerable_timer: Timer = %InvulnerableTimer
@onready var _untargetable_timer: Timer = %UntargetableTimer

@onready var _timers: Dictionary[Status.Type, Timer] = {
	Status.Type.STUN: %StunTimer,
	Status.Type.TAUNT: %StunTimer,
	Status.Type.SILENCE: %StunTimer,
	Status.Type.INVULNERABLE: %StunTimer,
	Status.Type.UNTARGETABLE: %StunTimer
}

# ============================== Public functions ==============================

func init(entity_owner: Entity) -> StatusModule:
	super.init(entity_owner)
	
	# Initialize all statuses to 0 (inactive)
	for status_type: Status.Type in Status.Type.values():
		_remaining_durations[status_type] = 0.0
	
	return self


func start() -> void:
	pass


func stop() -> void:
	pass


func has_status(status_type: Status.Type) -> bool:
	return _remaining_durations[status_type] > 0.0


func get_remaining_time(status_type: Status.Type) -> float:
	return _remaining_durations[status_type]


func add_status(status_type: Status.Type, duration: float, source: Entity) -> void:
	var was_inactive: bool = _remaining_durations[status_type] <= 0.0
	
	match status_type:
		Status.Type.STUN:
			if duration > _stun_timer.time_left:
				_stun_timer.stop()
				_stun_timer.wait_time = duration
				_stun_timer.start()
		Status.Type.TAUNT:
			if duration > _taunt_timer.time_left:
				_taunt_timer.stop()
				_taunt_timer.wait_time = duration
				_taunt_timer.start()
		Status.Type.SILENCE:
			if duration > _silence_timer.time_left:
				_silence_timer.stop()
				_silence_timer.wait_time = duration
				_silence_timer.start()
		Status.Type.UNTARGETABLE:
			if duration > _untargetable_timer.time_left:
				_untargetable_timer.stop()
				_untargetable_timer.wait_time = duration
				_untargetable_timer.start()
		Status.Type.INVULNERABLE:
			if duration > _invulnerable_timer.time_left:
				_invulnerable_timer.stop()
				_invulnerable_timer.wait_time = duration
				_invulnerable_timer.start()
	
	# Emit status-specific signal only if newly applied
	if was_inactive:
		_emit_status_changed(status_type, true, duration)


func remove_status(status_type: Status.Type) -> void:
	if _remaining_durations[status_type] <= 0.0:
		return
	
	_remaining_durations[status_type] = 0.0
	status_removed.emit(status_type)
	_emit_status_changed(status_type, false, 0.0)


# ============================== Private functions ==============================

func _emit_status_changed(status_type: Status.Type, is_active: bool, duration: float) -> void:
	match status_type:
		Status.Type.STUN: stunned_changed.emit(is_active, duration)
		Status.Type.TAUNT: taunted_changed.emit(is_active, duration)
		Status.Type.SILENCE: silenced_changed.emit(is_active, duration)
		Status.Type.INVULNERABLE: invulnerable_changed.emit(is_active, duration)
		Status.Type.UNTARGETABLE: untargetable_changed.emit(is_active, duration)


func _on_stun_timer_timeout() -> void:
	pass # Replace with function body.


func _on_silence_timer_timeout() -> void:
	pass # Replace with function body.


func _on_taunt_timer_timeout() -> void:
	pass # Replace with function body.


func _on_untargetable_timer_timeout() -> void:
	pass # Replace with function body.


func _on_invulnerability_timer_timeout() -> void:
	pass # Replace with function body.
