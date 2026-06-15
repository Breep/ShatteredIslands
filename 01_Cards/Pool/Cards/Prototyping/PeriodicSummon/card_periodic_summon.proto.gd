# Carte de prototypage : spawn périodiquement une entité (de type configurable
# via @export sur le CardEffect) près du porteur. Valide la chaîne
# SummonComponent.summon_entity de bout en bout :
#   SpawnLocationConfig.resolve → _consume_before_action_modifiers(SUMMON)
#   → spawn loop (avec spread si count > 1) → _consume_after_action_modifiers.
#
# Le type d'entité est paramétrable via le @export _entity_type sur le
# CardEffect (à choisir dans la .tres / éditeur Godot). Doit être un type
# supporté par SummonComponent (CHICKEN, TREX, SNAKE, SNAKE_BARREL,
# MOLTEN_GOLEM, AEGIS_BLADE, PROTO_SHIELD, FORTIFICATION_DRONE,
# DEFLECTION_SHIELD).
#
# Pour combiner avec card_summon_number.proto : ajouter les deux cartes au
# même porteur, le proto Number boostera le count des invocations
# déclenchées par cette carte.
class_name CardPrototypingPeriodicSummon
extends CardEffect

@export var _entity_type: Entity.EntityType = Entity.EntityType.CHICKEN
@export var _period: float = 5.0
## Rayon (unités monde) de randomisation de la position de spawn autour du
## porteur. 0 = spawn exactement sur le porteur.
@export var _spawn_randomization: float = 2.0


func apply(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	# Copies locales captures par la closure (snapshot au moment de l'apply).
	var entity_type: Entity.EntityType = _entity_type
	var randomization: float = _spawn_randomization

	owner.battle_callback_registry.register_periodic(card_name, _period, func() -> void:
		if not is_instance_valid(owner): return
		var spawn_config := SpawnLocationConfig.create_entity_relative(owner, randomization)
		owner.summon.summon_entity(entity_type, spawn_config, {})
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.battle_callback_registry.unregister_all(card_name)


func get_description(_card_lvl: int) -> String:
	return "Toutes les %.1fs, invoque une entité (%s) près du porteur." \
		% [_period, Entity.EntityType.find_key(_entity_type)]
