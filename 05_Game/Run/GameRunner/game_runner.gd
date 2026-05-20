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
		_apply_starting_gold(party, rules)

	the_run.current_index = 0
	while not the_run.is_finished():
		var confrontation: Confrontation = the_run.get_current()
		if confrontation == null:
			break
		var result: ConfrontationResult = await _confrontation_runner.run(confrontation, party)
		if rules != null and result != null:
			_apply_confrontation_payout(party, rules, confrontation, result)
		the_run.advance()


func _apply_starting_gold(party: Party, rules: RunRules) -> void:
	if party == null: return
	for player_state: PlayerState in party.players:
		player_state.gold = rules.gold_starting_run


# Intérêts calculés sur le gold détenu AVANT le gain de la confrontation
# (convention autobattler classique : économiser entre les rounds est valorisé).
func _apply_confrontation_payout(party: Party, rules: RunRules, confrontation: Confrontation, result: ConfrontationResult) -> void:
	if party == null: return
	for player_state: PlayerState in party.players:
		var interest: int = mini(player_state.gold / rules.interest_gold_threshold, rules.interest_max)
		var gain: int = rules.gold_per_confrontation + interest
		if result.outcome == ConfrontationResult.Outcome.WIN:
			gain += confrontation.gold_on_win
		player_state.gold += gain
