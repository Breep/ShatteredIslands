# Une Party = un groupe de joueurs persistant à travers les confrontations.
# Détient les joueurs (état de run sauvegardable) et la formation actuelle
# (héros + acolytes/bâtiments accumulés en taverne). C'est l'état "vivant"
# injecté dans chaque Encounter.
#
# Resource : sérialisable en .tres, prête à être embarquée dans le RunContext
# pour la save inter-confrontation.
class_name Party
extends Resource

@export var players: Array[PlayerState]
@export var formation: FightingFormation


# Helpers : extraire les specs par rôle depuis formation.entity_specs.
# Utilisés par les Runners pour alimenter la taverne ET le combat — les specs
# portent la donnée canonique (deck, level, etc. sur HeroSpec) que les deux
# phases ont besoin d'injecter sur l'instance Hero éphémère.
func get_hero_specs() -> Array[HeroSpec]:
	var result: Array[HeroSpec] = []
	if formation == null: return result
	for spec: EntitySpec in formation.entity_specs:
		if spec is HeroSpec:
			result.append(spec)
	return result


func get_acolyte_specs() -> Array[AcolyteSpec]:
	var result: Array[AcolyteSpec] = []
	if formation == null: return result
	for spec: EntitySpec in formation.entity_specs:
		if spec is AcolyteSpec:
			result.append(spec)
	return result
