class_name WarriorCrushingBlow
extends CardEffect

## Guerrier / Colossus — toutes les X attaques, inflige un bonus de dégâts
## physiques égal à un pourcentage des PV max de la cible.

@export var _attack_number: Array[int]
@export var _hp_percent: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var hp_pct: float = _hp_percent[card_lvl - 1]
	var atk_threshold: int = _attack_number[card_lvl - 1]
	var state := {&"count": 0, &"proc_active": false}

	var aa_mod := AutoAttackModifier.new()
	aa_mod.id = card_name
	aa_mod.tags = [Modifier.TagType.CARD]
	aa_mod.is_one_time_effect = false
	aa_mod.damage_modifier_callback = func(_cb_vars: Dictionary) -> void:
		state[&"count"] += 1
		if state[&"count"] >= atk_threshold:
			state[&"count"] = 0
			state[&"proc_active"] = true
	aa_mod.additional_effect_callback = func(cb_vars: Dictionary) -> void:
		if not state.get(&"proc_active", false): return
		state[&"proc_active"] = false
		var target: Entity = cb_vars.get(AutoAttackModifier.VarType.TARGET)
		if not is_instance_valid(target): return
		var bonus: float = target.stats.health_max * hp_pct / 100.0
		owner.damage.direct(target, bonus, Utils.ActionType.DAMAGE_PHYSICAL, card_name)

	owner.battle_callback_registry.register_battle_start(card_name, func() -> void:
		state[&"count"] = 0
		state[&"proc_active"] = false
		owner.auto_attack_modifier_registry.register_modifier(aa_mod)
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.battle_callback_registry.unregister_all(card_name)


func get_description(card_lvl: int) -> String:
	return "Toutes les " + _value(_attack_number[card_lvl - 1]) + " attaques, inflige " \
		+ _value(_hp_percent[card_lvl - 1]) + "% des PV max de la cible en [[PHYSICAL_DAMAGE]] bonus."
