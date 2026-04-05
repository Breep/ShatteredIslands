class_name StatusModule
extends Module

# ============================== Signals ==============================
signal stunned_changed(is_active: bool, duration: float, infinite: bool)
signal taunted_changed(is_active: bool, duration: float, infinite: bool)
signal silenced_changed(is_active: bool, duration: float, infinite: bool)
signal invulnerable_changed(is_active: bool, duration: float, infinite: bool)
signal untargetable_changed(is_active: bool, duration: float, infinite: bool)

# ============================== Constants ==============================
const TAUNT_DEFENCE_BONUS: float = 30.0

# ============================== Public variables ==============================

# ============================== Private variables ==============================
var _taunt_defence_mod: StatModifier

@onready var _timers: Dictionary[Status.Type, Timer] = {
	Status.Type.STUN: %StunTimer,
	Status.Type.TAUNT: %TauntTimer,
	Status.Type.SILENCE: %SilenceTimer,
	Status.Type.INVULNERABLE: %InvulnerabilityTimer,
	Status.Type.UNTARGETABLE: %UntargetableTimer
}

@onready var _infinite_status: Dictionary[Status.Type, bool] = {
	Status.Type.STUN: false,
	Status.Type.TAUNT: false,
	Status.Type.SILENCE: false,
	Status.Type.INVULNERABLE: false,
	Status.Type.UNTARGETABLE: false
}

# ============================== Public functions ==============================

func init(entity_owner: Entity) -> StatusModule:
	super.init(entity_owner)

	_taunt_defence_mod = StatModifier.new()
	_taunt_defence_mod.id = &"Taunt Defence Bonus"
	_taunt_defence_mod.stat_type = EntityStats.StatType.DEFENCE
	_taunt_defence_mod.calc_type = StatModifier.CalcType.ADD
	_taunt_defence_mod.value = TAUNT_DEFENCE_BONUS
	_taunt_defence_mod.tags = []

	taunted_changed.connect(_on_taunt_defence_update)

	return self


func start() -> void:
	pass


func stop() -> void:
	pass


func has_status(status_type: Status.Type) -> bool:
	return _infinite_status[status_type] or _timers[status_type].time_left > 0


func get_remaining_time(status_type: Status.Type) -> float:
	return _timers[status_type].time_left


func add_status(status_type: Status.Type, duration: float) -> void:
	if duration == -1:
		_infinite_status[status_type] = true
		_timers[status_type].stop()
		_emit_status_changed(status_type, true, 0.0, true)
		return
	
	if _infinite_status[status_type] == true or duration <= _timers[status_type].time_left:
		return
	
	_timers[status_type].stop()
	_timers[status_type].wait_time = duration
	_timers[status_type].start()
	_emit_status_changed(status_type, true, duration, false)


func remove_status(status_type: Status.Type) -> void:
	_timers[status_type].stop()
	_infinite_status[status_type] = false
	_emit_status_changed(status_type, false, 0.0, false)


# ============================== Private functions ==============================

func _emit_status_changed(status_type: Status.Type, is_active: bool, duration: float, infinite: bool) -> void:
	match status_type:
		Status.Type.STUN: stunned_changed.emit(is_active, duration, infinite)
		Status.Type.TAUNT: taunted_changed.emit(is_active, duration, infinite)
		Status.Type.SILENCE: silenced_changed.emit(is_active, duration, infinite)
		Status.Type.INVULNERABLE: invulnerable_changed.emit(is_active, duration, infinite)
		Status.Type.UNTARGETABLE: untargetable_changed.emit(is_active, duration, infinite)


func _on_taunt_defence_update(is_active: bool, _duration: float, _infinite: bool) -> void:
	if is_active:
		_owner.stat_modifiers_registry.register_modifier(_taunt_defence_mod)
	else:
		_owner.stat_modifiers_registry.unregister_modifier(_taunt_defence_mod)


func _on_stun_timer_timeout() -> void:
	remove_status(Status.Type.STUN)


func _on_silence_timer_timeout() -> void:
	remove_status(Status.Type.SILENCE)


func _on_taunt_timer_timeout() -> void:
	remove_status(Status.Type.TAUNT)


func _on_untargetable_timer_timeout() -> void:
	remove_status(Status.Type.UNTARGETABLE)


func _on_invulnerability_timer_timeout() -> void:
	remove_status(Status.Type.INVULNERABLE)
