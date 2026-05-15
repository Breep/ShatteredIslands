# Autoload qui détient la Party active de la session courante.
# Point d'accès central, cohérent avec PlayerManager / GameManager.
extends Node

var current: Party  # null si pas de Run en cours


# Crée une Party à partir d'un template de formation + des scènes des unités joueur.
# Utilisé pour le démarrage d'une Run.
func init_for_run(players: Array[Player], default_formation: FightingFormation, hero_scenes: Array[PackedScene], acolyte_scenes: Array[PackedScene]) -> void:
	if default_formation == null:
		Verbose.error("PartyManager.init_for_run: default_formation null", Verbose.Category.ENCOUNTER_RUNNER)
		return
	current = Party.new()
	current.players = players
	current.formation = default_formation.populate_with(hero_scenes, acolyte_scenes)


func clear() -> void:
	current = null
