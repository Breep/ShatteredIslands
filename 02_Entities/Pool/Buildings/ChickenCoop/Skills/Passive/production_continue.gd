class_name SE_ProductionContinue
extends SkillEffect

# Passif "Production continue": invoque 1 poulet toutes les _period s (toujours actif).
# Le talent "Incubateur rapide" réenregistre ce même périodique (même id) avec une
# période plus courte.

const PRODUCTION_TIMER_ID := &"ChickenProduction"

@export var _period: float = 6.0


func apply(ctx: SkillContext) -> void:
	var coop: ChickenCoop = ctx.entity as ChickenCoop
	if coop == null:
		Verbose.error("SE_ProductionContinue: owner is not a ChickenCoop", Verbose.Category.ENTITY_MODULE)
		return
	coop.battle_callback_registry.register_periodic(PRODUCTION_TIMER_ID, _period, coop.summon_chicken, true)


func get_description() -> String:
	return "Invoque 1 poulet toutes les " + _value(_period) + " s."
