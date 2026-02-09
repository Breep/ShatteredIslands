class_name StatusModule
extends Module

# ============================== Signals ==============================

signal status_added(status_type: Status.Type, duration: float)
signal status_removed(status_type: Status.Type)

# Status-specific signals (emitted when status is first applied or fully removed)
signal stunned_changed(is_active: bool)
signal taunted_changed(is_active: bool)
signal silenced_changed(is_active: bool)
signal invulnerable_changed(is_active: bool)
signal untargetable_changed(is_active: bool)

# ============================== Private variables ==============================

# Dictionary[Status.Type, float] - Remaining duration for each status (0 = inactive)
var _remaining_durations: Dictionary[Status.Type, float]

@onready var _stun_timer: Timer = %StunTimer
@onready var _taunt_timer: Timer = %TauntTimer
@onready var _silence_timer: Timer = %SilenceTimer
@onready var _invulnerable_timer: Timer = %InvulnerableTimer
@onready var _untargetable_timer: Timer = %UntargetableTimer

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
	
	# "Best only" behavior: keep the longest duration
	if duration > _remaining_durations[status_type]:
		_remaining_durations[status_type] = duration
	
	status_added.emit(status_type, duration)
	
	# Emit status-specific signal only if newly applied
	if was_inactive:
		_emit_status_changed(status_type, true)


func remove_status(status_type: Status.Type) -> void:
	if _remaining_durations[status_type] <= 0.0:
		return
	
	_remaining_durations[status_type] = 0.0
	status_removed.emit(status_type)
	_emit_status_changed(status_type, false)


# ============================== Node functions ==============================

func _process(delta: float) -> void:
	for status_type: Status.Type in Status.Type.values():
		if _remaining_durations[status_type] <= 0.0:
			continue
		
		_remaining_durations[status_type] -= delta
		
		# Check if status just expired
		if _remaining_durations[status_type] <= 0.0:
			_remaining_durations[status_type] = 0.0
			status_removed.emit(status_type)
			_emit_status_changed(status_type, false)


# ============================== Private functions ==============================

func _emit_status_changed(status_type: Status.Type, is_active: bool) -> void:
	match status_type:
		Status.Type.STUN: stunned_changed.emit(is_active)
		Status.Type.TAUNT: taunted_changed.emit(is_active)
		Status.Type.SILENCE: silenced_changed.emit(is_active)
		Status.Type.INVULNERABLE: invulnerable_changed.emit(is_active)
		Status.Type.UNTARGETABLE: untargetable_changed.emit(is_active)
