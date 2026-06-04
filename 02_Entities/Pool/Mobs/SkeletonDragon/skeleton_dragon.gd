class_name SkeletonDragon
extends Entity

@export var _flight_ability: ShatteringFlightAbility
@export var _breath_controller: BreathVfxController


func process_tick() -> void:
	super.process_tick()
	if _flight_ability != null:
		_flight_ability.process_tick()


func start_flight() -> void:
	if _flight_ability == null:
		Verbose.warn("start_flight: no flight ability", Verbose.Category.ENTITY)
		return
	_flight_ability.trigger_flight()


func get_flight_ability() -> ShatteringFlightAbility:
	return _flight_ability


func get_breath_controller() -> BreathVfxController:
	return _breath_controller
