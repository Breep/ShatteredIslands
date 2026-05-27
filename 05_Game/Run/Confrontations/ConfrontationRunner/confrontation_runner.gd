# Orchestre une Confrontation : phase taverne suivie de la phase combat.
# Délègue l'exécution à un EncounterRunner (configuré via @export).
# Émet confrontation_ended quand toutes les phases sont terminées et retourne
# un ConfrontationResult (null si pas de fighting_encounter).
class_name ConfrontationRunner
extends Node

signal confrontation_ended

@export var _encounter_runner: EncounterRunner


func run(confrontation: Confrontation, party: Party) -> ConfrontationResult:
	if confrontation == null:
		Verbose.error("ConfrontationRunner.run: confrontation null", Verbose.Category.ENCOUNTER_RUNNER)
		return null
	if _encounter_runner == null:
		Verbose.error("ConfrontationRunner.run: _encounter_runner not assigned", Verbose.Category.ENCOUNTER_RUNNER)
		return null

	# Pipeline d'affixes : chaque modifier produit un clone modifié des encounters
	# avant exécution. Les .tres d'origine restent intacts.
	var ctx: RunContext = GameManager.run_context
	var tavern_enc: TavernEncounter = confrontation.tavern_encounter
	var fight_enc: FightingEncounter = confrontation.fighting_encounter
	if ctx != null:
		for modifier: EncounterModifier in ctx.encounter_modifiers:
			if modifier == null: continue
			if tavern_enc != null:
				tavern_enc = modifier.apply(tavern_enc, ctx) as TavernEncounter
			if fight_enc != null:
				fight_enc = modifier.apply(fight_enc, ctx) as FightingEncounter

	if tavern_enc != null:
		await _encounter_runner.run_tavern(tavern_enc, party)

	var result: ConfrontationResult = null
	if fight_enc != null:
		var party_formation: FightingFormation = party.formation if party != null else null
		var party_won: bool = await _encounter_runner.run_fighting(fight_enc, party_formation)
		result = ConfrontationResult.new()
		result.outcome = ConfrontationResult.Outcome.WIN if party_won else ConfrontationResult.Outcome.LOSS

	confrontation_ended.emit()
	return result
