class_name SE_ElevageGifted
extends SkillEffect

# Talent "Élevage gifted" (Rush): au début du combat, invoque _rush_count poulets d'un coup
# (via ChickenCoop.summon_chicken, donc niveau hérité + block si "Couvée blindée").

@export var _rush_count: int = 4


func apply(ctx: SkillContext) -> void:
	var coop: ChickenCoop = ctx.entity as ChickenCoop
	if coop == null:
		Verbose.error("SE_ElevageGifted: owner is not a ChickenCoop", Verbose.Category.ENTITY_MODULE)
		return
	coop.battle_callback_registry.register_battle_start(&"ElevageGiftedRush", func() -> void:
		for i: int in _rush_count:
			coop.summon_chicken()
	)


func get_description() -> String:
	return "Au début du combat, invoque " + _value(_rush_count) + " poulets d'un coup."
