# Propage le DisplayMode (BUYING_PHASE / FIGHTING_PHASE / PREVIEW) de l'owner vers
# son health bar. No-op pour les entités sans apply_display_mode sur le health bar.
class_name DisplayModeModule
extends EntityComponent


#region ============================== Public functions ==============================
func apply(mode: Entity.DisplayMode) -> void:
	if _owner == null:
		return

	if _owner._health_bar != null and _owner._health_bar.has_method("apply_display_mode"):
		_owner._health_bar.apply_display_mode(mode)
#endregion
