class_name FortificationDrone
extends Entity


func _init() -> void:
	super._init()
	category = Category.SUMMON

#region ============================== Enum ==============================
enum Modifier {
	SHIELD,
	HP_MAX,
	SHIELD_PER_SECOND,
	RESPAWN_TIMER
}
#endregion


#region ============================== Signals ==============================
const BEAM_SCENE: PackedScene = preload("res://02_Entities/Pool/Mobs/FortificationDrone/Visual/fortification_drone_beam.tscn")
const SHIELD_COUNT_MAX: int = 3
#endregion


#region ============================== Private variables ==============================
var _shield_per_second: float
var _on_spawn_shield_amount: float
var _on_spawn_hp_max: float
var _respawn_timer: float
var _linked_ally: Entity
var _beam: FortificationDroneBeam
var _shield_count: int # Number of shield done on the linked_ally

@onready var _anim_hovering_module: AnimHoveringModule = %AnimHoveringModule
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	alterations.take_stack(_on_spawn_shield_amount, Alteration.Type.SHIELD, false, "Initial shield")
	#_base_stats.health_max = _on_spawn_hp_max
	stat_modifiers_registry.recompute_all()
	battle_callback_registry.register_periodic("Periodic Shield", 1.0, _periodic_beam_callback)
	spawn_completed.connect(_on_spawn_completed)
	super._ready()
#endregion


#region ============================== Public API ==============================
func process_tick() -> void:
	super.process_tick()
	_update_beam()


func init(shield_amount: float, hp_max: int, shield_per_second: float, respawn_timer: float) -> Entity:
	_on_spawn_shield_amount = shield_amount
	_on_spawn_hp_max = hp_max
	_shield_per_second = shield_per_second
	_respawn_timer = respawn_timer
	return self
#endregion


func _update_beam() -> void:
	if not is_instance_valid(_linked_ally):
		if is_instance_valid(_beam):
			_beam.visible = false
		return

	if not is_instance_valid(_beam):
		_beam = BEAM_SCENE.instantiate()
		add_child(_beam)

	_beam.visible = true
	var start: Vector3 = _visual_3d.global_position
	var end: Vector3 = _linked_ally.get_collision_center()
	_beam.update_beam(start, end)
	
	if _visual_3d != null:
		_visual_3d.look_at(_linked_ally.get_collision_center())


func _unlink_from_current_ally() -> void:
	if not is_instance_valid(_linked_ally): return
	if _linked_ally.died.is_connected(_on_linked_ally_died):
		_linked_ally.died.disconnect(_on_linked_ally_died)
	_linked_ally = null


func _link_to_an_ally(ally: Entity) -> void:
	if not is_instance_valid(ally): return
	_unlink_from_current_ally()
	_linked_ally = ally
	
	if not _linked_ally.died.is_connected(_on_linked_ally_died):
		_linked_ally.died.connect(_on_linked_ally_died)
	
	if movement != null:
		movement.orbit_entity(ally, 4.0, -0.3)


func _change_linked_ally() -> void:
	var ally: Entity = target.get_target(TargetComponent.TargettingStrategy.LOWEST_HP_PERCENT_HERO_ALLY)
	if ally == null:
		ally = target.get_target(TargetComponent.TargettingStrategy.RANDOM_ALLY)
	if ally == null: return
	_link_to_an_ally(ally)
	_shield_count = 0


func _periodic_beam_callback() -> void:
	if not is_instance_valid(_linked_ally): return
	alterations.direct_stack(_linked_ally, _shield_per_second, Alteration.Type.SHIELD, "Fortification Drone")
	_beam.blink()
	_shield_count += 1
	if _shield_count == SHIELD_COUNT_MAX:
		_change_linked_ally()


func _on_spawn_completed() -> void:
	var ally: Entity = target.get_target(TargetComponent.TargettingStrategy.LOWEST_HP_PERCENT_HERO_ALLY)
	if ally == null:
		ally = target.get_target(TargetComponent.TargettingStrategy.RANDOM_ALLY)
	if ally == null: return
	_link_to_an_ally(ally)


func _on_linked_ally_died(entity: Entity) -> void:
	if entity != _linked_ally:
		printerr("Unlinked ally died: SHOULD NOT HAPPEN :'(")
	_change_linked_ally()


func _on_died() -> void:
	super._on_died()
	_unlink_from_current_ally()
	_anim_hovering_module.stop_hover()
	_play_fall_anim()
	battle_callback_registry.register_oneshot(_respawn_timer, resurrect.bind(100))


func _on_resurrected() -> void:
	super._on_resurrected()
	alterations.take_stack(_on_spawn_shield_amount, Alteration.Type.SHIELD, false, "Initial shield")
	var tween := create_tween().set_parallel()
	tween.tween_property(_visual_3d, "position:y", 2.8, 0.8) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(_visual_3d, "rotation:z", 0.0, 0.8) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.chain().tween_callback(func() -> void:
		_anim_hovering_module.start_hover()
		_change_linked_ally()
	)


func _play_fall_anim() -> void:
	var tween := create_tween().set_parallel()
	tween.tween_property(_visual_3d, "position:y", 0.0, 0.6) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(_visual_3d, "rotation:z", deg_to_rad(25.0), 0.6) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)





 
