class_name SkeletonDragon
extends Entity

@export var _flight_ability: ShatteringFlightAbility
@export var _breath_controller: BreathVfxController
@export var _breath_ability: DevastatingBreathAbility

# Delay after landing on the island (IDLE) before the dragon's welcome bark.
const _WELCOME_DELAY: float = 3.0
# Delay after the combat-start roar before the dragon's taunt line, so they don't clash.
const _TAUNT_AFTER_ROAR_DELAY: float = 1.0

# Guards the once-per-fight ground roar; re-arms when the dragon leaves the fight.
var _roared: bool = false
# Guards the once-per-arrival welcome bark scheduling (IDLE can be entered more than once).
var _welcome_scheduled: bool = false
# A flight (Vol fracassant) requested while the ultimate is casting waits here until the
# ultimate fully finishes; drained in process_tick.
var _flight_queued: bool = false


func _ready() -> void:
	super._ready()
	ultimate_casted.connect(_on_ultimate_casted)
	fighting_state_changed.connect(_on_fighting_state_changed_voice)
	if _flight_ability != null:
		_flight_ability.flight_landing_impact.connect(_on_flight_landing_impact)
	# A skipped/synchronous spawn settles us into the pre-fight IDLE during super._ready(),
	# before the handler above is connected — so the IDLE emit is missed. Handle it here.
	if fighting_state == FightingState.IDLE:
		_schedule_welcome()


func process_tick() -> void:
	super.process_tick()
	if _flight_ability != null:
		_flight_ability.process_tick()
	if _breath_ability != null:
		_breath_ability.process_tick()
	# Drain a flight queued during the ultimate, now that it has fully finished (ticked above).
	if _flight_queued and (_breath_ability == null or not _breath_ability.is_active()):
		_flight_queued = false
		start_flight()


func start_flight() -> void:
	if _flight_ability == null:
		Verbose.warn("start_flight: no flight ability", Verbose.Category.ENTITY)
		return
	# An ongoing ultimate must finish its full cast first — queue the flight behind it.
	if _breath_ability != null and _breath_ability.is_active():
		_flight_queued = true
		return
	_flight_ability.trigger_flight()


func get_flight_ability() -> ShatteringFlightAbility:
	return _flight_ability


func get_breath_controller() -> BreathVfxController:
	return _breath_controller


func get_breath_ability() -> DevastatingBreathAbility:
	return _breath_ability


# Voice lines + ground roar driven by the fight lifecycle: a welcome bark ~3s after the
# dragon lands on its island (IDLE, pre-fight), then the roar and a taunt the first time
# combat starts. Roar/state guards re-arm whenever the dragon leaves the fight.
func _on_fighting_state_changed_voice(new_state: FightingState) -> void:
	if new_state != FightingState.FIGHTING:
		_roared = false
		_flight_queued = false # drop any flight queued behind an interrupted ultimate
		if new_state == FightingState.IDLE:
			_schedule_welcome()
		return
	if _roared:
		return
	_roared = true
	var anim: SkeletonDragonAnimationComponent = animation as SkeletonDragonAnimationComponent
	if anim != null:
		anim.play_roar()
	AudioManager.play_3d("dragon_roar", global_position)


func _on_ultimate_casted() -> void:
	AudioManager.play_3d("dragon_breathing_fire", global_position)


func _on_died() -> void:
	super._on_died()
	AudioManager.play_3d("skeleton_drake_die", global_position)
	_schedule_taunt()


# Welcome the players a few seconds after arriving on the island — but only while still
# pre-fight: if combat starts during the delay, the bark is dropped.
func _schedule_welcome() -> void:
	if _welcome_scheduled:
		return
	_welcome_scheduled = true
	get_tree().create_timer(_WELCOME_DELAY).timeout.connect(func() -> void:
		if fighting_state == FightingState.IDLE:
			AudioManager.play_sfx("dragon_voice_bienvenue"))


# Taunt line shortly after the combat-start roar so the two don't overlap.
func _schedule_taunt() -> void:
	get_tree().create_timer(_TAUNT_AFTER_ROAR_DELAY).timeout.connect(func() -> void:
		AudioManager.play_sfx("dragon_voice_demeure"))


# Laugh on the flight's ground-contact frame (the landing slam).
func _on_flight_landing_impact() -> void:
	AudioManager.play_sfx("dragon_voice_hahaha")
