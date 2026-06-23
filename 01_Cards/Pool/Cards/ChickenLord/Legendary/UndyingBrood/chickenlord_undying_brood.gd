class_name ChickenLordUndyingBrood
extends CardEffect

## Chicken Lord (Légendaire) — à leur apparition, les summons du héros ont une
## chance de devenir « renaissables » (can_revive). À leur mort, un DeathModifier
## les fait ressusciter après un délai avec une fraction de leurs PV max.
## Le dé est lancé au spawn ; can_revive empêche aussi le despawn entre-temps.

const RESPAWN_DELAY: float = 3.0

@export var _respawn_chance: Array[float]
@export var _hp_percent: Array[float]

var _on_detected: Callable

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var chance: float = _respawn_chance[card_lvl - 1]
	var hp_percent: float = _hp_percent[card_lvl - 1]

	_on_detected = func(summon: Entity) -> void:
		if not (is_instance_valid(summon) and summon.is_summoned() and owner.summon.is_summoner_of(summon)): return
		# Lancer de dé au spawn : ce summon pourra-t-il renaître ?
		summon.can_revive = Utils.is_randomize_modifier_active(chance, owner.battle_id)
		if not summon.can_revive: return

		var mod := DeathModifier.new()
		mod.id = card_name
		mod.after_action_logic_callback = func(_cb_vars: Dictionary) -> void:
			if not is_instance_valid(summon) or not summon.can_revive: return
			if not is_instance_valid(owner): return
			owner.battle_callback_registry.register_oneshot(RESPAWN_DELAY, func() -> void:
				if not is_instance_valid(summon): return
				summon.can_revive = false
				summon.resurrect(hp_percent)
			, StringName(String(card_name) + "_" + str(summon.uid)))
		summon.death_modifiers_registry.register_modifier(mod)
	owner.target.new_entity_detected.connect(_on_detected)


func revert(ctx: CardContext, _card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	if _on_detected.is_valid() and owner.target.new_entity_detected.is_connected(_on_detected):
		owner.target.new_entity_detected.disconnect(_on_detected)


func get_description(card_lvl: int) -> String:
	return "Mort de [[SUMMON]] : " + _value(_respawn_chance[card_lvl - 1]) + "% de chance qu'il réapparaisse " \
		+ _value(RESPAWN_DELAY) + "s plus tard au même endroit avec " + _value(_hp_percent[card_lvl - 1]) + "% PV."
