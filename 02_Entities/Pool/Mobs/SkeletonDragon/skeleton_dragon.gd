class_name SkeletonDragon
extends Entity

@export var _flight_ability: ShatteringFlightAbility
@export var _breath_controller: BreathVfxController
@export var _breath_ability: DevastatingBreathAbility

# Guards the once-per-fight ground roar; re-arms when the dragon leaves the fight.
var _roared: bool = false
# A flight (Vol fracassant) requested while the ultimate is casting waits here until the
# ultimate fully finishes; drained in process_tick.
var _flight_queued: bool = false


func _ready() -> void:
	super._ready()
	fighting_state_changed.connect(_on_fighting_state_changed_roar)
	ultimate_casted.connect(_on_ultimate_casted)


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


# Ground roar (+ sound) the first time the dragon enters combat; re-arm on leaving it.
func _on_fighting_state_changed_roar(new_state: FightingState) -> void:
	if new_state != FightingState.FIGHTING:
		_roared = false
		_flight_queued = false # drop any flight queued behind an interrupted ultimate
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
