class_name FortificationDrone
extends Summon

enum Modifier {
	SHIELD,
	HP_MAX,
	SHIELD_PER_SECOND,
	RESPAWN_TIMER
}

const BEAM_SCENE: PackedScene = preload("res://Entities/NPC/Fighting/Engineer/FortificationDrone/Visual/fortification_drone_beam.tscn")

var _shield_per_second: float
var _on_spawn_shield_amount: float
var _on_spawn_hp_max: float
var _respawn_timer: float

var _linked_ally: Entity

var _beam: FortificationDroneBeam

@onready var _fortification_drone_visual: Node3D = %FortificationDroneVisual

func init(shield_amount: float, hp_max: int, shield_per_second: float, respawn_timer: float) -> Summon:
	_on_spawn_shield_amount = shield_amount
	_on_spawn_hp_max = hp_max
	_shield_per_second = shield_per_second
	_respawn_timer = respawn_timer
	return self


func _ready() -> void:
	take_condition_stacks(_on_spawn_shield_amount, Stack.Type.SHIELD, false, "Initial shield")
	_base_stats.health_max = _on_spawn_hp_max
	_base_stats.reset_from_self()
	periodic_timer_registry.register("Periodic Shield", 1.0, _periodic_beam_callback)
	spawn_completed.connect(_on_spawn_completed)
	super._ready()


func process_tick() -> void:
	super.process_tick()
	_update_beam()


func _update_beam() -> void:
	if not is_instance_valid(_linked_ally):
		if is_instance_valid(_beam):
			_beam.visible = false
		return

	if not is_instance_valid(_beam):
		_beam = BEAM_SCENE.instantiate()
		add_child(_beam)

	_beam.visible = true
	var start: Vector3 = _fortification_drone_visual.global_position
	var end: Vector3 = _linked_ally.get_collision_center()
	_beam.update_beam(start, end)
	
	if _visual_3d != null:
		_visual_3d.look_at(_linked_ally.get_collision_center())


func _unlink_from_current_ally() -> void:
	if not is_instance_valid(_linked_ally): return


func _link_to_an_ally(ally: Entity) -> void:
	if not is_instance_valid(ally): return
	_unlink_from_current_ally()
	_linked_ally = ally
	#if _movement_module != null:
		#_movement_module.follow_entity(ally)


func _periodic_beam_callback() -> void:
	if not is_instance_valid(_linked_ally): return
	inflict_condition_stacks(_linked_ally, _shield_per_second, Stack.Type.SHIELD, "Fortification Drone")
	_beam.blink()


func _on_spawn_completed() -> void:
	print("FORTI SPAWN COMPLETED")
	var ally: Entity = target_module.get_target(TargetModule.TargettingStrategy.RANDOM_HERO_ALLY)
	if ally == null: return
	_link_to_an_ally(ally)












 
