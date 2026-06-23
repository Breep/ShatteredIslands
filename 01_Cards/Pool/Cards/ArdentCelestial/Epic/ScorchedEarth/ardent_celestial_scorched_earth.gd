class_name ArdentCelestialScorchedEarth
extends CardEffect

## Ardent Celestial — à l'impact d'un projectile d'abilité, laisse un sol enflammé
## pendant une durée : les ennemis présents dans la zone reçoivent des stacks
## d'ignite par seconde.

@export var _ignite_per_tick: Array[float]
@export var _duration: Array[float]
@export var _radius: Array[float]
@export var _tick_period: float = 1.0

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var ignite: float = _ignite_per_tick[card_lvl - 1]
	var duration: float = _duration[card_lvl - 1]
	var radius: float = _radius[card_lvl - 1]
	var tick: float = _tick_period

	var mod := ProjectileModifier.new()
	mod.id = card_name
	mod.categories = [Projectile.Category.ABILITY_PROJECTILE]
	mod.on_hit_callback = func(cb_vars: Dictionary) -> void:
		if not is_instance_valid(owner) or owner.spell == null: return
		# Le projectile remplit cb_vars avec les clés ProjectileStats.VarType.
		var pos: Vector3 = cb_vars.get(ProjectileStats.VarType.POSITION, owner.global_position)
		var target: Entity = cb_vars.get(ProjectileStats.VarType.TARGET)
		owner.spell.cast_spell(target, Spell.Type.FIRE_GROUND, {
			Spell.FireGroundModifier.POSITION: pos,
			Spell.FireGroundModifier.RADIUS: radius,
			Spell.FireGroundModifier.DURATION: duration,
			Spell.FireGroundModifier.IGNITE_PER_TICK: ignite,
			Spell.FireGroundModifier.TICK_PERIOD: tick,
		})
	owner.projectile_modifiers_registry.register_modifier(mod)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.projectile_modifiers_registry.unregister_modifier(card_name)


func get_description(card_lvl: int) -> String:
	return "À l'impact, les [[ABILITY_PROJECTILE]] laissent un sol enflammé " \
		+ _value(_duration[card_lvl - 1]) + "s : " + _value(_ignite_per_tick[card_lvl - 1]) \
		+ " [[IGNITE]]/s aux ennemis dans la zone."
