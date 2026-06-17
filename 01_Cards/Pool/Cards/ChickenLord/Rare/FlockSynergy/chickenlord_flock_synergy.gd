class_name ChickenLordFlockSynergy
extends CardEffect

## Chicken Lord — chaque summon allié vivant octroie +AD et +AP à tous les summons
## du héros, recalculé en temps réel (apparition / mort d'un summon).

@export var _ad_per_summon: Array[float]
@export var _ap_per_summon: Array[float]

var _on_detected: Callable

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var ad_per: float = _ad_per_summon[card_lvl - 1]
	var ap_per: float = _ap_per_summon[card_lvl - 1]
	var ap_id := StringName(String(card_name) + "_ap")

	var refresh := func() -> void:
		if not is_instance_valid(owner): return
		var summons: Array[Entity] = _living_summons(owner)
		var n: int = summons.size()
		for s in summons:
			s.stat_modifiers_registry.register_modifier(_make_mod(card_name, EntityStats.StatType.AD, n * ad_per))
			s.stat_modifiers_registry.register_modifier(_make_mod(ap_id, EntityStats.StatType.AP, n * ap_per))

	_on_detected = func(e: Entity) -> void:
		if not (is_instance_valid(e) and e.is_summoned() and owner.summon.is_summoner_of(e)): return
		e.died.connect(func() -> void: refresh.call(), CONNECT_ONE_SHOT | CONNECT_DEFERRED)
		refresh.call()
	owner.target.new_entity_detected.connect(_on_detected)

	for ally in _living_summons(owner):
		ally.died.connect(func() -> void: refresh.call(), CONNECT_ONE_SHOT | CONNECT_DEFERRED)
	refresh.call()


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	if _on_detected.is_valid() and owner.target.new_entity_detected.is_connected(_on_detected):
		owner.target.new_entity_detected.disconnect(_on_detected)
	var ap_id := StringName(String(card_name) + "_ap")
	for s in _living_summons(owner):
		s.stat_modifiers_registry.remove_modifier(EntityStats.StatType.AD, card_name)
		s.stat_modifiers_registry.remove_modifier(EntityStats.StatType.AP, ap_id)


func _make_mod(id: StringName, stat: EntityStats.StatType, value: float) -> StatModifier:
	var mod := StatModifier.new()
	mod.id = id
	mod.stat_type = stat
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = value
	mod.tags = [Modifier.TagType.CARD]
	return mod


func _living_summons(owner: Entity) -> Array[Entity]:
	var result: Array[Entity] = []
	for ally in owner.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES):
		if is_instance_valid(ally) and ally.is_summoned() and owner.summon.is_summoner_of(ally):
			result.append(ally)
	return result


func get_description(card_lvl: int) -> String:
	return "Les [[SUMMON]] gagnent +" + str(_ad_per_summon[card_lvl - 1]) + " [[AD]] et +" \
		+ str(_ap_per_summon[card_lvl - 1]) + " [[AP]] par [[SUMMON]] allié vivant."
