class_name SE_RelaisBlinde
extends SkillEffect

# Talent "Relais blindé": le Rayon protecteur applique aussi _regen Regen toutes les
# _period s, aux mêmes alliés que le rayon (même zone AREA_META et même nombre de cibles
# MULTI_COUNT_META, donc profite aussi de l'ultimate).

@export var _regen: float = 10.0
@export var _period: float = 5.0


func apply(ctx: SkillContext) -> void:
	var sentinelle: Entity = ctx.entity
	sentinelle.battle_callback_registry.register_periodic(&"RelaisBlinde", _period, func() -> void:
		var radius: float = sentinelle.get_meta(SE_RayonProtecteur.AREA_META, 4.0)
		var count: int = sentinelle.get_meta(SE_RayonProtecteur.MULTI_COUNT_META, 1)
		var allies: Array[Entity] = SE_RayonProtecteur.closest_allies_in_radius(sentinelle, radius, count)
		if allies.is_empty():
			return
		for ally: Entity in allies:
			sentinelle.alterations.inflict_condition_stacks(ally, _regen, Alteration.Type.REGEN, &"Relais blindé")
		if sentinelle.has_method("flash_beams_to"):
			sentinelle.flash_beams_to(allies)
	, true)
