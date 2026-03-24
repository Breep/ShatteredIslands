class_name Summon
extends Entity

# == VIRTUAL CLASS ==

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
#endregion

#region ============================== Other callbacks ==============================
func _on_died() -> void:
	super._on_died()
	if _health_bar != null:
		_health_bar.hide()
#endregion
