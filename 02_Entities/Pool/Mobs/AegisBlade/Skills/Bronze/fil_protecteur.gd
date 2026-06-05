class_name SE_FilProtecteur
extends SkillEffect

# Talent "Fil protecteur": la conversion de l'Aegis Blade passe à _convert_ratio (35%).
# Pose la meta lue par le passif (SE_AegisActive).

@export var _convert_ratio: float = 0.35


func apply(ctx: SkillContext) -> void:
	var blade: AegisBlade = ctx.entity as AegisBlade
	if blade == null:
		Verbose.error("SE_FilProtecteur: owner is not an AegisBlade", Verbose.Category.ENTITY_MODULE)
		return
	blade.set_meta(SE_AegisActive.META_CONVERT_RATIO, _convert_ratio)
