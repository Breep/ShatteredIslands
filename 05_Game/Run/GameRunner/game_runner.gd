# Parcourt un Run : exécute chaque Confrontation dans l'ordre via le
# ConfrontationRunner enfant. Top-level orchestrateur de la session de jeu.
# Applique aussi les règles économiques (RunRules) : gold de départ, revenu
# par confrontation, bonus de victoire, intérêts.
class_name GameRunner
extends Node

@export var _confrontation_runner: ConfrontationRunner


func run(the_run: Run, party: Party) -> void:
	if the_run == null:
		Verbose.error("GameRunner.run: the_run null", Verbose.Category.ENCOUNTER_RUNNER)
		return
	if _confrontation_runner == null:
		Verbose.error("GameRunner.run: _confrontation_runner not assigned", Verbose.Category.ENCOUNTER_RUNNER)
		return

	var rules: RunRules = the_run.rules
	if rules == null:
		Verbose.warn("GameRunner.run: the_run.rules null — payout désactivé", Verbose.Category.ENCOUNTER_RUNNER)
	else:
		_apply_starting_gold(rules)

	the_run.current_index = 0
	while not the_run.is_finished():
		var player_roaster: Roaster = party.roasters.get(PlayerState.Slot.PLAYER_1)
		player_roaster.hero.level = rules.tmp_hero_levels[the_run.current_index]
		var confrontation: Confrontation = the_run.get_current()
		if confrontation == null:
			break
		var result: ConfrontationResult = await _confrontation_runner.run(confrontation, party)
		if rules != null and result != null:
			_apply_confrontation_payout(rules, confrontation, result)
		the_run.advance()


# Écriture via Player.gold setter (et non PlayerState.gold) pour émettre
# gold_changed et garder l'UI synchro. Le PlayerState référencé par chaque
# Player est le même objet que celui de Party.players (cf. GameManager
# _build_new_run_context), donc la sérialisation reste correcte.
func _apply_starting_gold(rules: RunRules) -> void:
	for player: Player in PlayerManager.players.values():
		player.gold = rules.gold_starting_run


# Intérêts calculés sur le gold détenu AVANT le gain de la confrontation
# (convention autobattler classique : économiser entre les rounds est valorisé).
func _apply_confrontation_payout(rules: RunRules, confrontation: Confrontation, result: ConfrontationResult) -> void:
	for player: Player in PlayerManager.players.values():
		var interest: int = mini(player.gold / rules.interest_gold_threshold, rules.interest_max)
		var gain: int = rules.gold_per_confrontation + interest
		if result.outcome == ConfrontationResult.Outcome.WIN:
			gain += confrontation.gold_on_win
		player.gold += gain
