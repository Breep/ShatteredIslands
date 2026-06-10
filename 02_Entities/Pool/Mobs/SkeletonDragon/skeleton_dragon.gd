class_name SkeletonDragon
extends Entity

@export var _flight_ability: ShatteringFlightAbility
@export var _breath_controller: BreathVfxController
@export var _breath_ability: DevastatingBreathAbility

# Guards the once-per-fight ground roar; re-arms when the dragon leaves the fight.
var _roared: bool = false


func _ready() -> void:
	super._ready()
	fighting_state_changed.connect(_on_fighting_state_changed_roar)


func process_tick() -> void:
	super.process_tick()
	if _flight_ability != null:
		_flight_ability.process_tick()
	if _breath_ability != null:
		_breath_ability.process_tick()


func start_flight() -> void:
	if _flight_ability == null:
		Verbose.warn("start_flight: no flight ability", Verbose.Category.ENTITY)
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
		return
	if _roared:
		return
	_roared = true
	var anim: SkeletonDragonAnimationComponent = animation as SkeletonDragonAnimationComponent
	if anim != null:
		anim.play_roar()
	AudioManager.play_3d("dragon_roar", global_position)
