class_name ProtoShield
extends Summon

enum Modifier {
	SHIELD,
	HP_MAX
}

@onready var _anim_hovering_module: AnimHoveringModule = %AnimHoveringModule
@onready var _anim_rotating_mode_x: AnimRotatingModule = %AnimRotatingModuleX
@onready var _anim_rotating_mode_y: AnimRotatingModule = %AnimRotatingModuleY

var _on_spawn_shield_amount: float
var _on_spawn_hp_max: float

func init(shield_amount: float, hp_max: int) -> Summon:
	_on_spawn_shield_amount = shield_amount
	_on_spawn_hp_max = hp_max
	return self


func _ready() -> void:
	take_condition_stacks(_on_spawn_shield_amount, Alteration.Type.SHIELD, false, "Initial shield")
	take_status(Alteration.Type.TAUNT, -1, "Initial taunt", self)
	_base_stats.health_max = _on_spawn_hp_max
	stat_modifiers_registry.recompute_all()
	super._ready()


func _on_died() -> void:
	super._on_died()
	_anim_hovering_module.stop_hover()
	_anim_rotating_mode_x.stop_rotating()
	_anim_rotating_mode_y.stop_rotating()
	_play_fall_anim()


func _play_fall_anim() -> void:
	var tween := create_tween().set_parallel()
	tween.tween_property(_visual_3d, "position:y", 0.0, 0.6) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(_visual_3d, "rotation:z", deg_to_rad(25.0), 0.6) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
