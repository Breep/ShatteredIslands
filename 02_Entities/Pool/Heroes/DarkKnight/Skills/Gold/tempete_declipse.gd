class_name SE_TempeteDEclipse
extends SkillEffect

# Gold Tempête d'Éclipse: l'ultimate Éclipse déclenche Lame d'Ombre _extra_triggers
# fois de plus (5 → 7 par défaut). Lu par SE_Eclipse via META_ULT_EXTRA.

@export var _extra_triggers: int = 2


func apply(ctx: SkillContext) -> void:
	if ctx.entity == null:
		return
	ctx.entity.set_meta(SE_LameDOmbre.META_ULT_EXTRA, _extra_triggers)
