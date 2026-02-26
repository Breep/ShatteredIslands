class_name DefenseShieldThrow
extends HeroUpgrade

@export var _threshold: Array[float]
@export var _damage: Array[float]
@export var _shield_return: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.RARE


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Shield Throw: Wrong card_lvl: ", card_lvl)
		return

	var threshold: int = int(_threshold[card_lvl - 1])
	var damage: float = _damage[card_lvl - 1]
	var shield_return: float = _shield_return[card_lvl - 1]
	var state := {&"accumulated": 0, &"last_armor": 0}

	var _trigger_shield_throw := func() -> void:
		var target: Entity = ctx.hero.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
		if target == null:
			return
		var proj_stats := ProjectileStats.new()
		proj_stats.is_bouncing = true
		proj_stats.bounces_remaining = 20
		proj_stats.on_hit_logic_callbacks.append(func(cb_vars: Dictionary) -> void:
			if not cb_vars.has(AutoAttackModifier.VarType.TARGET):
				return
			var hit_target: Entity = cb_vars[AutoAttackModifier.VarType.TARGET]
			if hit_target == null or not is_instance_valid(hit_target):
				return
			if damage > 0:
				ctx.hero.direct_damage(hit_target, damage, Utils.DamageType.MAGICAL, &"Shield Throw")
			if shield_return > 0:
				ctx.hero.inflict_condition_stacks(ctx.hero, shield_return, Utils.StackType.SHIELD, &"Shield Throw")
				state[&"last_armor"] = ctx.hero.conditions.shield_stacks
		)
		ctx.hero.projectile_attack(target, Projectile.Type.SHIELD_THROW, ctx.hero._turret._projectile_spawn_point, proj_stats)

	var _on_shield_changed: Callable
	_on_shield_changed = func(new_val: int) -> void:
		var gain: int = new_val - state[&"last_armor"]
		state[&"last_armor"] = new_val
		if gain <= 0:
			return
		state[&"accumulated"] += gain
		if threshold > 0 and state[&"accumulated"] >= threshold:
			while state[&"accumulated"] >= threshold:
				state[&"accumulated"] -= threshold
				_trigger_shield_throw.call()

	ctx.battle_callbacks.register_battle_start(&"Shield Throw", func() -> void:
		state[&"accumulated"] = 0
		state[&"last_armor"] = ctx.hero.conditions.shield_stacks
		if not ctx.hero.conditions.shield_stacks_changed.is_connected(_on_shield_changed):
			ctx.hero.conditions.shield_stacks_changed.connect(_on_shield_changed)
	)
	ctx.battle_callbacks.register_battle_end(&"Shield Throw", func() -> void:
		if ctx.hero.conditions.shield_stacks_changed.is_connected(_on_shield_changed):
			ctx.hero.conditions.shield_stacks_changed.disconnect(_on_shield_changed)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Shield Throw: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Every " + str(_threshold[cardlvl - 1]) + " [[SHIELD]] generated, throw a shield. Deal " + str(_damage[cardlvl - 1]) + " [[MAGICAL_DAMAGE]] and bounce between all enemies. Generate " + str(_shield_return[cardlvl - 1]) + " [[SHIELD]] for each enemy hit."
