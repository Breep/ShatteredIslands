# Définit le "ring" d'une phase de combat : l'île à charger, plus les deux
# équipes qui s'y affrontent. Agnostique du fait que team_a soit le joueur ou
# une IA — team_a est typiquement injectée à runtime, team_b chargée depuis
# le .tres (formation mob).
class_name FightingEncounter
extends EncounterResource

@export var island_scene: PackedScene
@export var team_b_formation: FightingFormation
var team_a_formation: FightingFormation
