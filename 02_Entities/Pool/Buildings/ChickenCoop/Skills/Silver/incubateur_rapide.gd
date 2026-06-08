class_name SE_IncubateurRapide
extends SkillEffect

# Talent "Incubateur rapide": le passif "Production continue" passe à _period s.
# Réenregistre le même périodique que SE_ProductionContinue (même id → le remplace).

@export var _period: float = 4.0


func apply(ctx: SkillContext) -> void:
	var coop: ChickenCoop = ctx.entity as ChickenCoop
	if coop == null:
		Verbose.error("SE_IncubateurRapide: owner is not a ChickenCoop", Verbose.Category.ENTITY_MODULE)
		return
	coop.battle_callback_registry.register_periodic(SE_ProductionContinue.PRODUCTION_TIMER_ID, _period, coop.summon_chicken, true)
