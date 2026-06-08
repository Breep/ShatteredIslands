class_name SE_RayonProtecteur
extends SkillEffect

# Passif "Rayon protecteur": toutes les _period s, donne _shield Shield aux alliés les plus
# proches dans un rayon (AREA_META, 4 par défaut ; 7 via "Pare-choc"). Le nombre de cibles
# vaut MULTI_COUNT_META (1 par défaut ; porté à 3 temporairement par l'ultimate "Surcharge
# défensive"). Si "Prisme stable" est actif (SELF_SHARE_META), la Sentinelle gagne aussi
# une fraction du Shield distribué.

const AREA_META := &"sentinelle_area"
const SELF_SHARE_META := &"sentinelle_self_share"
const MULTI_COUNT_META := &"sentinelle_multi_count"

@export var _shield: float = 20.0
@export var _radius: float = 4.0
@export var _period: float = 1.0


func apply(ctx: SkillContext) -> void:
	var sentinelle: Entity = ctx.entity
	sentinelle.set_meta(AREA_META, _radius)

	sentinelle.battle_callback_registry.register_periodic(&"RayonProtecteur", _period, func() -> void:
		var radius: float = sentinelle.get_meta(AREA_META, _radius)
		var count: int = sentinelle.get_meta(MULTI_COUNT_META, 1)
		var allies: Array[Entity] = closest_allies_in_radius(sentinelle, radius, count)
		if allies.is_empty():
			return
		var self_share: float = sentinelle.get_meta(SELF_SHARE_META, 0.0)
		for ally: Entity in allies:
			sentinelle.alterations.inflict_condition_stacks(ally, _shield, Alteration.Type.SHIELD, &"Rayon protecteur")
			if self_share > 0.0:
				sentinelle.alterations.take_condition_stacks(_shield * self_share, Alteration.Type.SHIELD, false, &"Prisme stable")
		if sentinelle.has_method("flash_beams_to"):
			sentinelle.flash_beams_to(allies)
	, true)


## Retourne les _count alliés (hors soi) les plus proches dans le rayon, triés par distance.
static func closest_allies_in_radius(sentinelle: Entity, radius: float, count: int) -> Array[Entity]:
	var allies: Array[Entity] = []
	for ally: Entity in sentinelle.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES, radius):
		if ally == sentinelle or not is_instance_valid(ally):
			continue
		allies.append(ally)
	allies.sort_custom(func(a: Entity, b: Entity) -> bool:
		return a.global_position.distance_to(sentinelle.global_position) < b.global_position.distance_to(sentinelle.global_position)
	)
	if allies.size() > count:
		allies.resize(count)
	return allies
