class_name Summon
extends Entity

# == VIRTUAL CLASS ==

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
#endregion
