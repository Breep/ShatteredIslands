class_name GammaTurret
extends Summon

enum Modifier {
	TURRET_AD,
	TURRET_SHIELD,
	MASTER
}

@onready var animation_hovering_module: AnimHoveringModule = %AnimHoveringModule

var _ad: float
var _shield: int
var _master: Entity

func init(shield: int, ad: float, master: Entity) -> Summon:
	_shield = shield
	_ad = ad
	_master = master
	return self


func _ready() -> void:
	base_stats.health_max = 1
	base_stats.attack_damage = _ad
	stat_modifiers_registry.recompute_all()
	if not is_instance_valid(_master): _master = summoner
	_movement_module.orbit_entity(_master, 2, 2, MovementModule.OrbitFacing.NONE)
	_master.died.connect(func() -> void:
		_on_died()
		)
	super._ready()
	conditions.add_stack(Stack.Type.SHIELD, _shield, _master, &"Gamma Turret")

func _on_died() -> void:
	animation_hovering_module.stop_hover()
	super._on_died()
	_play_fall_anim()


func _play_fall_anim() -> void:
	var tween := create_tween().set_parallel()
	tween.tween_property(_visual_3d, "position:y", 0.0, 0.6) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(_visual_3d, "rotation:z", deg_to_rad(25.0), 0.6) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
