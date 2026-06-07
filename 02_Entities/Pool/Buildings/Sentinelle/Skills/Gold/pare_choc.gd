class_name SE_PareChoc
extends SkillEffect

# Talent "Pare-choc": étend la zone du Rayon protecteur à _radius (7 au lieu de 4). Écrit
# AREA_META, lu par le Rayon protecteur et le Relais blindé.

@export var _radius: float = 7.0


func apply(ctx: SkillContext) -> void:
	ctx.entity.set_meta(SE_RayonProtecteur.AREA_META, _radius)
