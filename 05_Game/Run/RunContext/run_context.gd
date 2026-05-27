# État sauvegardable d'une run roguelite : agrège tout ce qui doit persister
# entre confrontations (chemin de Confrontations, party, règles, familles
# actives, seed RNG, métadonnées). C'est l'unité qui sera sérialisée dans
# user://saves/.
#
# Construit par GameManager au démarrage d'une partie. Sera lu/écrit
# directement (option B hybride : aucune logique métier ici, juste la donnée).
class_name RunContext
extends Resource

@export var run: Run
@export var party: Party
@export var game_rules: GameRules
@export var active_families: Array[Family]
@export var encounter_modifiers: Array[EncounterModifier]

@export var rng_seed: int = 0
@export var run_id: String = ""
@export var started_at: int = 0
@export var save_version: int = 1
@export var run_length: int = 5


func _init() -> void:
	if party == null:
		party = Party.new()
	if run == null:
		run = Run.new()


func save_to(path: String) -> Error:
	var dir_path: String = path.get_base_dir()
	if dir_path != "" and not DirAccess.dir_exists_absolute(dir_path):
		var dir_err: Error = DirAccess.make_dir_recursive_absolute(dir_path)
		if dir_err != OK:
			return dir_err
	return ResourceSaver.save(self, path)
