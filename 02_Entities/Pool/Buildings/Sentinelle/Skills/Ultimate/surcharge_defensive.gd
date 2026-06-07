class_name SE_SurchargeDefensive
extends SkillEffect

# Ultimate "Surcharge défensive": pendant _duration s, le Rayon protecteur (et le Relais
# blindé) s'appliquent aux _count alliés les plus proches au lieu d'un seul. La durée laisse
# le temps au Relais blindé (proc toutes les 5 s) de se déclencher au moins une fois.

@export var _count: int = 3
@export var _duration: float = 5.0


func apply(ctx: SkillContext) -> void:
	var sentinelle: Entity = ctx.entity
	sentinelle.set_meta(SE_RayonProtecteur.MULTI_COUNT_META, _count)
	sentinelle.battle_callback_registry.register_oneshot(_duration, func() -> void:
		sentinelle.set_meta(SE_RayonProtecteur.MULTI_COUNT_META, 1)
	)
