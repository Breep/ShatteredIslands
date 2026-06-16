class_name ChickenLordBeastBond
extends CardEffect

## Seigneur Poulet / Colossus — augmente les résistances (armure, magique, poison)
## d'une valeur par summon allié en vie, mis à jour en temps réel (apparition /
## mort des summons).
## NOTE: le déblocage « Colosse Surdoué » (Gifted Colossus) n'est pas géré ici —
## à brancher sur le système de progression/unlock.

const RESIST_STATS: Array[EntityStats.StatType] = [
	EntityStats.StatType.ARMOR,
	EntityStats.StatType.MAGIC_RESIST,
	EntityStats.StatType.POISON_RESIST,
]

@export var _resist_per_summon: Array[float]

var _on_entity_detected: Callable

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var per_summon: float = _resist_per_summon[card_lvl - 1]

	_on_entity_detected = func(entity: Entity) -> void:
		if not (is_instance_valid(entity) and entity.is_summoned() and owner.summon.is_summoner_of(entity)): return
		entity.died.connect(func() -> void: _refresh(owner, per_summon, card_name), CONNECT_ONE_SHOT)
		_refresh(owner, per_summon, card_name)
	owner.target.new_entity_detected.connect(_on_entity_detected)

	for ally in owner.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES):
		if is_instance_valid(ally) and ally.is_summoned() and owner.summon.is_summoner_of(ally):
			ally.died.connect(func() -> void: _refresh(owner, per_summon, card_name), CONNECT_ONE_SHOT)

	_refresh(owner, per_summon, card_name)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	if _on_entity_detected.is_valid() and owner.target.new_entity_detected.is_connected(_on_entity_detected):
		owner.target.new_entity_detected.disconnect(_on_entity_detected)
	for stat_type in RESIST_STATS:
		owner.stat_modifiers_registry.remove_modifier(stat_type, card_name)


func _refresh(owner: Entity, per_summon: float, card_name: StringName) -> void:
	if not is_instance_valid(owner): return
	var resist_value: float = _count_living_summons(owner) * per_summon
	for stat_type in RESIST_STATS:
		var mod := StatModifier.new()
		mod.id = card_name
		mod.stat_type = stat_type
		mod.calc_type = StatModifier.CalcType.ADD
		mod.value = resist_value
		mod.tags = [Modifier.TagType.CARD]
		owner.stat_modifiers_registry.register_modifier(mod)


func _count_living_summons(owner: Entity) -> int:
	var count: int = 0
	for ally in owner.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES):
		if is_instance_valid(ally) and ally.is_summoned() and owner.summon.is_summoner_of(ally):
			count += 1
	return count


func get_description(card_lvl: int) -> String:
	return "Augmente les résistances de " + str(_resist_per_summon[card_lvl - 1]) \
		+ " par summon allié en vie.\nDébloque : Colosse Surdoué."
