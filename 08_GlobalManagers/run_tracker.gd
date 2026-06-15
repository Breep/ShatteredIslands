extends Node

# Greffon de suivi de run : écoute le bus d'événements pour chronométrer une run
# (temps mural, du début de la 1ère taverne jusqu'à la fin de run) et compter les
# rencontres (combats) traversées. Ne pilote rien — l'écran de résultat appelle
# freeze() à la fin de run, lit le temps / le score et publie vers le Leaderboard.
# Comme seules les runs terminées sont enregistrées, "rencontres traversées" au
# moment du freeze == "rencontres vaincues".

#region ============================== Private variables ==============================
var _running: bool = false
var _frozen: bool = false
var _start_unix: int = 0
var _frozen_elapsed: int = 0
var _encounters: int = 0
var _hero_name: String = ""
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	Events.tavern_phase_started.connect(_on_tavern_phase_started)
	Events.fighting_phase_started.connect(_on_fighting_phase_started)
#endregion


#region ============================== Public functions ==============================
# Repart d'un suivi vierge. Appelé par le menu principal pour garantir un chrono
# propre au lancement d'une nouvelle run, même après un abandon (run non figée).
func reset() -> void:
	_running = false
	_frozen = false
	_start_unix = 0
	_frozen_elapsed = 0
	_encounters = 0
	_hero_name = ""


# Fige le chrono et capture le héros joué. Appelé par l'écran de résultat à la
# fin de la run (dragon vaincu). Idempotent et sans effet si aucun suivi en cours.
func freeze() -> void:
	if _frozen or not _running:
		return
	_frozen_elapsed = int(Time.get_unix_time_from_system()) - _start_unix
	_frozen = true
	_hero_name = _capture_hero_name()


func is_tracking() -> bool:
	return _running or _frozen


func get_elapsed_seconds() -> int:
	if _frozen:
		return _frozen_elapsed
	if not _running:
		return 0
	return int(Time.get_unix_time_from_system()) - _start_unix


func get_encounters_won() -> int:
	return _encounters


func get_hero_name() -> String:
	return _hero_name


# "MM:SS" (ou "H:MM:SS" au-delà d'une heure). Utilitaire d'affichage partagé par
# l'écran de résultat et la popup de classement.
func format_time(seconds: int) -> String:
	var h: int = seconds / 3600
	var m: int = (seconds % 3600) / 60
	var s: int = seconds % 60
	if h > 0:
		return "%d:%02d:%02d" % [h, m, s]
	return "%02d:%02d" % [m, s]
#endregion


#region ============================== Callbacks ==============================
func _on_tavern_phase_started() -> void:
	_start_if_needed()


func _on_fighting_phase_started() -> void:
	_start_if_needed()
	if _frozen:
		return
	_encounters += 1
#endregion


#region ============================== Private functions ==============================
# Démarre le suivi au premier signal d'une run (taverne ou combat). Sans effet si
# un suivi est déjà en cours — il faut passer par reset() pour repartir.
func _start_if_needed() -> void:
	if _running:
		return
	_running = true
	_frozen = false
	_start_unix = int(Time.get_unix_time_from_system())
	_encounters = 0
	Verbose.debug("RunTracker: chrono démarré", Verbose.Category.GAME)


func _capture_hero_name() -> String:
	var ctx: RunContext = GameManager.run_context
	if ctx == null or ctx.party == null:
		return ""
	for roaster: Roaster in ctx.party.roasters.values():
		if roaster != null and roaster.hero != null and roaster.hero.desc != null:
			return roaster.hero.desc.name
	return ""
#endregion
