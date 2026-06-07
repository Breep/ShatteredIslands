class_name SE_PrismeStable
extends SkillEffect

# Talent "Prisme stable": la Sentinelle profite de _share (25%) de l'effet de son Rayon
# protecteur (elle gagne aussi ce % du Shield qu'elle distribue). Lu via SELF_SHARE_META.

@export var _share: float = 0.25


func apply(ctx: SkillContext) -> void:
	ctx.entity.set_meta(SE_RayonProtecteur.SELF_SHARE_META, _share)
