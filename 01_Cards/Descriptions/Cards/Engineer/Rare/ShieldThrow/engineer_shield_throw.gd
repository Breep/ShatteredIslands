class_name EngineerShieldThrow
extends HeroUpgrade

@export var _threshold: Array[float]
@export var _damage: Array[float]
@export var _shield_return: Array[float]
@export var _bounces: Array[float]

enum {
	ACCUMULATED_LOSS,
	LAST_ARMOR
}

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Shield Throw: Wrong card_lvl: ", card_lvl)
		return

	var threshold: int = int(_threshold[card_lvl - 1])
	var damage: float = _damage[card_lvl - 1]
	var shield_return: float = _shield_return[card_lvl - 1]
	var bounce: float = _bounces[card_lvl - 1]
	var state := {ACCUMULATED_LOSS: 0, LAST_ARMOR: 0}

	var _trigger_shield_throw := func() -> void:
		var target: Entity = ctx.hero.target.get_target(TargetComponent.TargettingStrategy.CLOSEST_ENEMY)
		if target == null: return
		var proj_stats := ProjectileStats.new()
		proj_stats.bounces_remaining = bounce
		proj_stats.on_hit_callbacks.append(func(cb_vars: Dictionary) -> void:
			if not cb_vars.has(AutoAttackModifier.VarType.TARGET):
				return
			var hit_target: Entity = cb_vars[AutoAttackModifier.VarType.TARGET]
			if hit_target == null or not is_instance_valid(hit_target):
				return
			if damage > 0:
				ctx.hero.damage.direct(hit_target, damage, Utils.ActionType.DAMAGE_MAGICAL, &"Shield Throw")
			if shield_return > 0:
				ctx.hero.alterations.inflict_condition_stacks(ctx.hero, shield_return, Alteration.Type.SHIELD, &"Shield Throw")
		)
		ctx.hero.projectile_sender.projectile_attack(target, Projectile.Type.SHIELD_THROW, ctx.hero, proj_stats)

	var _on_shield_changed: Callable
	_on_shield_changed = func(new_val: int) -> void:
		var loss: int = state[LAST_ARMOR] - new_val
		state[LAST_ARMOR] = new_val
		if loss <= 0:
			return
		state[ACCUMULATED_LOSS] += loss
		if threshold > 0 and state[ACCUMULATED_LOSS] >= threshold:
			while state[ACCUMULATED_LOSS] >= threshold:
				state[ACCUMULATED_LOSS] -= threshold
				_trigger_shield_throw.call()

	ctx.battle_callbacks.register_battle_start(&"Shield Throw", func() -> void:
		state[ACCUMULATED_LOSS] = 0
		state[LAST_ARMOR] = ctx.hero.alterations.shield_stacks
		if not ctx.hero.alterations.shield_stacks_changed.is_connected(_on_shield_changed):
			ctx.hero.alterations.shield_stacks_changed.connect(_on_shield_changed)
	)
	ctx.battle_callbacks.register_battle_end(&"Shield Throw", func() -> void:
		if ctx.hero.alterations.shield_stacks_changed.is_connected(_on_shield_changed):
			ctx.hero.alterations.shield_stacks_changed.disconnect(_on_shield_changed)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Shield Throw: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var s: String = str(_threshold[cardlvl - 1]).pad_decimals(0)
	var d: String = str(_damage[cardlvl - 1]).pad_decimals(0)
	var b: String = str(_bounces[cardlvl - 1]).pad_decimals(1)
	var sr: String = str(_shield_return[cardlvl - 1]).pad_decimals(0)
	return "Tous les " + s + " [[SHIELD]] perdus, lance un bouclier. Inflige " + d + " [[MAGICAL_DAMAGE]], " + b + " rebonds. Génère " + sr + " [[SHIELD]] par ennemi touché."
