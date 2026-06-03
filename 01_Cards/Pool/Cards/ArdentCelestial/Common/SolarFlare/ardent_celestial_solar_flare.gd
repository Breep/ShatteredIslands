class_name ArdentCelestialSolarFlare
extends CardEffect

## Ardent Celestial — augmente l'esquive du héros ; à chaque esquive, applique
## des stacks d'ignite à l'attaquant.

@export var _dodge_increase: Array[float]
@export var _ignite_stacks: Array[float]

var _on_dodged: Callable

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner

	var mod := StatModifier.new()
	mod.id = card_name
	mod.stat_type = EntityStats.StatType.DODGE
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = _dodge_increase[card_lvl - 1]
	mod.tags = [StatModifier.TagType.CARD]
	owner.stat_modifiers_registry.register_modifier(mod)

	var ignite: float = _ignite_stacks[card_lvl - 1]
	_on_dodged = func(source: Entity, _action_type: Utils.ActionType, _value: float, _is_critical: bool) -> void:
		if not is_instance_valid(source) or source == owner: return
		owner.alterations.inflict_condition_stacks(source, ignite, Alteration.Type.IGNITE, card_name)
	owner.action_dodged.connect(_on_dodged)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	owner.stat_modifiers_registry.remove_modifier(EntityStats.StatType.DODGE, card_name)
	if _on_dodged.is_valid() and owner.action_dodged.is_connected(_on_dodged):
		owner.action_dodged.disconnect(_on_dodged)


func get_description(card_lvl: int) -> String:
	return "Augmente le [[DODGE]] de " + str(_dodge_increase[card_lvl - 1]) \
		+ ". À chaque esquive, applique " + str(_ignite_stacks[card_lvl - 1]) + " [[IGNITE]] à l'attaquant."
