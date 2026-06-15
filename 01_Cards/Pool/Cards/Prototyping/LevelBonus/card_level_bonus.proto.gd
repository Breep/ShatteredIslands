# Carte de prototypage : donne un bonus de level (déterministe) à toutes les
# entités d'une catégorie spécifique (SUMMON, ACOLYTE ou BUILDING) invoquées
# par le porteur. Valide la chaîne :
#   register_level_bonus(card_name, N) sur le bon registry
#   → Entity._apply_inherited_<X>_modifiers() somme la chaîne summoner
#   → progression.level += N (clampé à [1, Entity.MAX_LEVEL])
#   → ProgressionComponent._handle_level_up() recompute les base stats.
#
# La carte n'invoque rien par elle-même — elle modifie le level des entités
# qui sont invoquées par d'autres mécaniques du porteur. À combiner avec
# card_periodic_summon.proto pour valider de bout en bout.
class_name CardPrototypingLevelBonus
extends CardEffect

enum Target { SUMMON, ACOLYTE, BUILDING }

@export var _target: Target = Target.SUMMON
## Bonus de level ajouté à chaque entité de la catégorie ciblée. Le total
## (cumul de toute la chaîne summoner) est clampé à [1, Entity.MAX_LEVEL = 20]
## côté Entity.
@export var _level_bonus: int = 1


func apply(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var registry: Resource = _get_registry(ctx.entity_owner)
	if registry == null: return
	registry.register_level_bonus(card_name, _level_bonus)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var registry: Resource = _get_registry(ctx.entity_owner)
	if registry == null: return
	registry.unregister_level_bonus(card_name)


func get_description(_card_lvl: int) -> String:
	return "+%d level aux %s invoqués par le porteur." % [
		_level_bonus, Target.find_key(_target).to_lower() + "s"
	]


func _get_registry(owner: Entity) -> Resource:
	match _target:
		Target.SUMMON: return owner.summon_modifiers_registry
		Target.ACOLYTE: return owner.acolyte_modifiers_registry
		Target.BUILDING: return owner.building_modifiers_registry
	return null
