class_name ChickenLordYinYang
extends CardEffect

## Chicken Lord — Ying & Yang : quand un summon allié apparaît, une chance
## d'appliquer du Strength à tous les alliés ; quand un summon meurt, une chance
## d'appliquer de la Vulnerability à tous les ennemis.
## Strength/Vulnerability ne sont pas typés : ils affectent les 3 types de
## dégâts (physique, magique, poison) via add_stack.

@export var _strength_chance: Array[float]
@export var _vulnerable_chance: Array[float]
@export var _strength_stacks: Array[float]
@export var _vulnerable_stacks: Array[float]

var _on_detected: Callable

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var s_chance: float = _strength_chance[card_lvl - 1]
	var v_chance: float = _vulnerable_chance[card_lvl - 1]
	var s_stacks: float = _strength_stacks[card_lvl - 1]
	var v_stacks: float = _vulnerable_stacks[card_lvl - 1]

	_on_detected = func(e: Entity) -> void:
		if not (is_instance_valid(e) and e.is_summoned() and owner.summon.is_summoner_of(e)): return
		# Spawn → Strength aux alliés.
		if Utils.is_randomize_modifier_active(s_chance, owner.battle_id):
			for ally in owner.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES):
				if ally != null and is_instance_valid(ally) and ally.alterations != null:
					ally.alterations.add_stack(Alteration.Type.STRENGTH, s_stacks)
		# Mort → Vulnerability aux ennemis.
		e.died.connect(func() -> void:
			if not is_instance_valid(owner): return
			if not Utils.is_randomize_modifier_active(v_chance, owner.battle_id): return
			for enemy in owner.target.get_targets(TargetComponent.MultipleTargettingStrategy.ENEMIES):
				if enemy != null and is_instance_valid(enemy) and enemy.alterations != null:
					enemy.alterations.add_stack(Alteration.Type.VULNERABILITY, v_stacks)
		, CONNECT_ONE_SHOT)
	owner.target.new_entity_detected.connect(_on_detected)


func revert(ctx: CardContext, _card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	if _on_detected.is_valid() and owner.target.new_entity_detected.is_connected(_on_detected):
		owner.target.new_entity_detected.disconnect(_on_detected)


func get_description(card_lvl: int) -> String:
	return "[[SUMMON]] créé : " + _value(_strength_chance[card_lvl - 1]) + "% → " \
		+ _value(_strength_stacks[card_lvl - 1]) + " [[STRENGTH]]\n" \
		+ "[[SUMMON]] mort : " + _value(_vulnerable_chance[card_lvl - 1]) + "% → " \
		+ _value(_vulnerable_stacks[card_lvl - 1]) + " [[VULNERABILITY]]"
