class_name ChickenLordGuardianHatch
extends CardEffect

## Chicken Lord — à l'apparition d'un summon allié du héros, applique des stacks
## de Block à un allié aléatoire.

@export var _block_amount: Array[float]

var _on_detected: Callable

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var block: float = _block_amount[card_lvl - 1]

	_on_detected = func(e: Entity) -> void:
		if not _is_owned_summon(e, owner): return
		var ally: Entity = owner.target.get_target(TargetComponent.TargettingStrategy.RANDOM_ALLY_INCLUDING_SELF)
		if ally != null and is_instance_valid(ally) and ally.alterations != null:
			ally.alterations.add_stack(Alteration.Type.BLOCK, block)
	owner.target.new_entity_detected.connect(_on_detected)


func revert(ctx: CardContext, _card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	if _on_detected.is_valid() and owner.target.new_entity_detected.is_connected(_on_detected):
		owner.target.new_entity_detected.disconnect(_on_detected)


func _is_owned_summon(e: Entity, owner: Entity) -> bool:
	return e != null and is_instance_valid(e) and e.is_summoned() and e.summoner == owner


func get_description(card_lvl: int) -> String:
	return "À l'apparition d'un summon, applique " + str(_block_amount[card_lvl - 1]) \
		+ " [[BLOCK]] à un allié aléatoire."
