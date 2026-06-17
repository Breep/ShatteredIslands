class_name EngineerCommandAura
extends CardEffect

## Engineer — aura : tous les alliés gagnent de l'armure et de l'AP par bâtiment
## allié en vie, recalculé en temps réel (apparition / mort d'un bâtiment).
## Pattern aura dynamique (cf. CLAUDE.md §9).

@export var _armor_per_building: Array[float]
@export var _ap_per_building: Array[float]

var _on_entity_detected: Callable

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	if owner.aura == null: return
	
	var armor_per: float = _armor_per_building[card_lvl - 1]
	var ap_per: float = _ap_per_building[card_lvl - 1]
	var ap_id := StringName(String(card_name) + "_ap")
	
	var refresh := func() -> void:
		if not is_instance_valid(owner) or owner.aura == null: return
		var n: int = _count_living_buildings(owner)
		owner.aura.update_modifier(_make_mod(card_name, EntityStats.StatType.ARMOR, n * armor_per))
		owner.aura.update_modifier(_make_mod(ap_id, EntityStats.StatType.AP, n * ap_per))
	
	var n0: int = _count_living_buildings(owner)
	owner.aura.add_modifier(_make_mod(card_name, EntityStats.StatType.ARMOR, n0 * armor_per))
	owner.aura.add_modifier(_make_mod(ap_id, EntityStats.StatType.AP, n0 * ap_per))
	
	_on_entity_detected = func(e: Entity) -> void:
		if e != null and is_instance_valid(e) and e.category == Entity.Category.BUILDING:
			e.died.connect(func() -> void: refresh.call(), CONNECT_ONE_SHOT | CONNECT_DEFERRED)
			refresh.call()
	owner.target.new_entity_detected.connect(_on_entity_detected)
	
	for ally in owner.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES):
		if ally != null and is_instance_valid(ally) and ally.category == Entity.Category.BUILDING:
			ally.died.connect(func() -> void: refresh.call(), CONNECT_ONE_SHOT | CONNECT_DEFERRED)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	if _on_entity_detected.is_valid() and owner.target.new_entity_detected.is_connected(_on_entity_detected):
		owner.target.new_entity_detected.disconnect(_on_entity_detected)
	if owner.aura != null:
		owner.aura.remove_modifier(card_name)
		owner.aura.remove_modifier(StringName(String(card_name) + "_ap"))


func _make_mod(id: StringName, stat: EntityStats.StatType, value: float) -> StatModifier:
	var mod := StatModifier.new()
	mod.id = id
	mod.stat_type = stat
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = value
	mod.tags = [StatModifier.TagType.CARD]
	return mod


func _count_living_buildings(owner: Entity) -> int:
	var count: int = 0
	for ally in owner.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES):
		if ally != null and is_instance_valid(ally) and ally.category == Entity.Category.BUILDING:
			count += 1
	return count


func get_description(card_lvl: int) -> String:
	return "Aura : +" + _value(_armor_per_building[card_lvl - 1]) + " armure et +" \
		+ _value(_ap_per_building[card_lvl - 1]) + " [[AP]] par bâtiment allié en vie."
