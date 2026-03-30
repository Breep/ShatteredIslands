class_name Summon
extends Entity

# == VIRTUAL CLASS ==

@export var _despawn_timer: float = 5.0
@export var _health_bar: SummonSimpleInfoPanel2D

var summoner: Entity

#region ============================== Enums ==============================
#endregion

#region ============================== Export ==============================
#endregion

#region ============================== Public variables ==============================
func apply_context(context: EntityContext) -> void:
	summoner = context.entity_owner
	super.apply_context(context)
	summoner.bds_registry.register_summon(self)
#endregion

#region ============================== Private variables ==============================
#endregion

#region ============================== Public functions ==============================
#endregion

#region ===== Actions (Summon-specific overrides) =====
#endregion

#region ============================== Node base functions ==============================
#endregion

#region ============================== Private functions ==============================
#endregion

#region ============================== Private ==============================
func _default_despawn() -> void:
	var tween := create_tween()
	tween.tween_property(_visual_3d, "scale", Vector3.ONE * 1.2, 0.1) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(_visual_3d, "scale", Vector3.ZERO, 0.25) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)
#endregion

#region ============================== Other callbacks ==============================
func _on_died() -> void:
	super._on_died()
	if _health_bar != null:
		_health_bar.hide()
	if _despawn_timer > 0:
		periodic_timer_registry.register_oneshot(_despawn_timer, _default_despawn)


func _on_resurrected() -> void:
	super._on_resurrected()
	if _health_bar != null:
		_health_bar.show()
#endregion
