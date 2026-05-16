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


# Helpers : extraire les scènes par rôle depuis formation.entity_specs.
# Utilisé par les Runners pour alimenter la taverne (qui ne consomme pas
# une FightingFormation entière, juste les scènes des unités joueur).
func get_hero_scenes() -> Array[PackedScene]:
	var result: Array[PackedScene] = []
	if formation == null: return result
	for spec: EntitySpec in formation.entity_specs:
		if spec is HeroSpec:
			result.append(spec.scene)
	return result


func get_acolyte_scenes() -> Array[PackedScene]:
	var result: Array[PackedScene] = []
	if formation == null: return result
	for spec: EntitySpec in formation.entity_specs:
		if spec is AcolyteSpec:
			result.append(spec.scene)
	return result
