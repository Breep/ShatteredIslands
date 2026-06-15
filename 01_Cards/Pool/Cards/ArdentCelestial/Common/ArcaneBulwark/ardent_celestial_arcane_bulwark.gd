class_name ArdentCelestialArcaneBulwark
extends CardEffect

## Ardent Celestial / Colossus — à chaque impact d'un projectile d'abilité du
## héros, celui-ci gagne des PV max (cumulatif, remis à zéro à chaque combat).
## Hook : ProjectileModifier filtré sur Projectile.Category.ABILITY_PROJECTILE.

@export var _hp_per_hit: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var hp_per: float = _hp_per_hit[card_lvl - 1]
	var state := {&"total": 0.0}

	var mod := ProjectileModifier.new()
	mod.id = card_name
	mod.categories = [Projectile.Category.ABILITY_PROJECTILE]
	mod.on_hit_callback = func(_cb_vars: Dictionary) -> void:
		if not is_instance_valid(owner): return
		state[&"total"] += hp_per
		owner.stat_modifiers_registry.register_modifier(_make_hp_mod(card_name, state[&"total"]))
	owner.projectile_modifiers_registry.register_modifier(mod)

	# Cumul remis à zéro au début de chaque combat.
	owner.battle_callback_registry.register_battle_start(card_name, func() -> void:
		state[&"total"] = 0.0
		if is_instance_valid(owner):
			owner.stat_modifiers_registry.register_modifier(_make_hp_mod(card_name, 0.0))
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	owner.projectile_modifiers_registry.unregister_modifier(card_name)
	owner.battle_callback_registry.unregister_all(card_name)
	owner.stat_modifiers_registry.remove_modifier(EntityStats.StatType.HEALTH_MAX, card_name)


func _make_hp_mod(id: StringName, value: float) -> StatModifier:
	var mod := StatModifier.new()
	mod.id = id
	mod.stat_type = EntityStats.StatType.HEALTH_MAX
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = value
	mod.tags = [StatModifier.TagType.CARD]
	return mod


func get_description(card_lvl: int) -> String:
	return "À chaque impact d'un projectile d'abilité, le héros gagne " \
		+ str(_hp_per_hit[card_lvl - 1]) + " PV max pour la durée du combat."
