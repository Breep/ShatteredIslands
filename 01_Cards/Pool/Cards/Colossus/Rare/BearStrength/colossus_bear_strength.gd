class_name ColossusBearStrength
extends CardEffect

## Colossus — réduit la vitesse d'attaque mais convertit un pourcentage des PV
## max en dégâts d'attaque (AD), recalculé quand les PV max changent.

@export var _as_reduction: Array[float]
@export var _hp_to_ad_percents: Array[float]

var _hp_cb: Callable

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner

	var as_mod := StatModifier.new()
	as_mod.id = card_name
	as_mod.stat_type = EntityStats.StatType.AS
	as_mod.calc_type = StatModifier.CalcType.MULT
	as_mod.value = -(_as_reduction[card_lvl - 1] / 100.0)
	as_mod.tags = [Modifier.TagType.CARD]
	owner.stat_modifiers_registry.register_modifier(as_mod)

	var hp_to_ad: float = _hp_to_ad_percents[card_lvl - 1]
	_update_ad_modifier(owner, hp_to_ad, card_name)

	_hp_cb = func(_hp_max: float) -> void:
		if is_instance_valid(owner):
			_update_ad_modifier(owner, hp_to_ad, card_name)
	owner.stats.health_max_changed.connect(_hp_cb)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	if _hp_cb.is_valid() and owner.stats.health_max_changed.is_connected(_hp_cb):
		owner.stats.health_max_changed.disconnect(_hp_cb)
	owner.stat_modifiers_registry.remove_modifier(EntityStats.StatType.AS, card_name)
	owner.stat_modifiers_registry.remove_modifier(EntityStats.StatType.AD, card_name)


func _update_ad_modifier(owner: Entity, hp_to_ad_percent: float, card_name: StringName) -> void:
	var ad_mod := StatModifier.new()
	ad_mod.id = card_name
	ad_mod.stat_type = EntityStats.StatType.AD
	ad_mod.calc_type = StatModifier.CalcType.ADD
	ad_mod.value = owner.stats.health_max * (hp_to_ad_percent / 100.0)
	ad_mod.tags = [Modifier.TagType.CARD]
	owner.stat_modifiers_registry.register_modifier(ad_mod)


func get_description(card_lvl: int) -> String:
	return "Réduit la vitesse d'attaque de " + _value(_as_reduction[card_lvl - 1]) \
		+ "%. Convertit " + _value(_hp_to_ad_percents[card_lvl - 1]) + "% des PV max en [[AD]]."
