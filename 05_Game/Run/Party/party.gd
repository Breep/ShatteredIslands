# Une Party = un groupe de joueurs persistant à travers les confrontations.
# Détient les joueurs et la formation actuelle (héros + acolytes/bâtiments
# accumulés en taverne). C'est l'état "vivant" injecté dans chaque Encounter.
#
# RefCounted (pas Resource) car la Party référence des Nodes Player et
# représente un état runtime, pas un asset sérialisé en .tres.
class_name Party
extends RefCounted

var players: Array[Player]
var formation: FightingFormation


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
