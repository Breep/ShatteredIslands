# Propage le DisplayMode (BUYING_PHASE / FIGHTING_PHASE / PREVIEW) de l'owner vers
# son animation et son health bar. Hero-spécifique aujourd'hui (cast vers
# HeroAnimationModule + HeroSimpleInfoPanel2D), généralisable aux acolytes plus tard.
# No-op pour les entités sans HeroAnimationModule / sans apply_display_mode sur le
# health bar.
class_name DisplayModeModule
extends EntityComponent


#region ============================== Public functions ==============================
func apply(mode: Hero.DisplayMode) -> void:
	if _owner == null:
		return

	var hero_anim := _owner.animation as HeroAnimationModule
	if hero_anim != null:
		hero_anim.apply_display_mode(mode)

	if _owner._health_bar != null and _owner._health_bar.has_method("apply_display_mode"):
		_owner._health_bar.apply_display_mode(mode)
#endregion
