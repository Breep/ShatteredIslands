# Carte de prototypage : à chaque invocation faite par le porteur, donne une
# chance d'invoquer une entité supplémentaire. Probabilité = 50 + (card_lvl × 5) %.
# Pour card_lvl 1..5 : 55 / 60 / 65 / 70 / 75 %.
#
# Valide la chaîne ActionModifier(SUMMON, before_action_logic_callback) →
# mutation de ActionModifier.VarType.COUNT → SummonComponent.summon_entity
# loope `count` fois avec spread spatial (cf. SummonComponent).
#
# La carte n'invoque rien par elle-même — elle ne fait que muter le count des
# invocations DÉCLENCHÉES par d'autres cartes / skills / family managers du
# porteur. Si rien d'autre ne summon, la carte est silencieuse.
class_name CardPrototypingSummonNumber
extends CardEffect


func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var extra_chance_percent: float = 50.0 + float(card_lvl) * 5.0

	var mod := ActionModifier.new()
	mod.id = card_name
	mod.action_type = Utils.ActionCategory.SUMMON
	mod.is_one_time_effect = false
	mod.before_action_logic_callback = func(cb_vars: Dictionary) -> void:
		if randf() * 100.0 < extra_chance_percent:
			cb_vars[ActionModifier.VarType.COUNT] += 1
	owner.action_modifiers_registry.register_modifier(mod)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	# ActionModifiersRegistry.unregister_modifier prend une instance mais
	# n'utilise que .id et .action_type — stub avec les bons champs.
	var stub := ActionModifier.new()
	stub.id = card_name
	stub.action_type = Utils.ActionCategory.SUMMON
	ctx.entity_owner.action_modifiers_registry.unregister_modifier(stub)


func get_description(card_lvl: int) -> String:
	return "%d%% de chance d'invoquer une entité supplémentaire à chaque invocation." \
		% int(50 + card_lvl * 5)
