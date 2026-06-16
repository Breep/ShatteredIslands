class_name ChickenLordArmoredBrood
extends CardEffect

## Chicken Lord — les summons du héros gagnent des stacks de Block à leur apparition.

@export var _block_amount: Array[float]

var _on_detected: Callable

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var block: float = _block_amount[card_lvl - 1]

	_on_detected = func(e: Entity) -> void:
		if not (is_instance_valid(e) and e.is_summoned() and owner.summon.is_summoner_of(e)): return
		if e.alterations != null:
			e.alterations.add_stack(Alteration.Type.BLOCK, block)
	owner.target.new_entity_detected.connect(_on_detected)


func revert(ctx: CardContext, _card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	if _on_detected.is_valid() and owner.target.new_entity_detected.is_connected(_on_detected):
		owner.target.new_entity_detected.disconnect(_on_detected)


func get_description(card_lvl: int) -> String:
	return "Les summons gagnent " + str(_block_amount[card_lvl - 1]) + " [[BLOCK]] à l'apparition."
