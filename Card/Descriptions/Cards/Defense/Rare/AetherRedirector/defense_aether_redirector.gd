class_name DefenseAetherRedirector
extends HeroUpgrade

@export var _base_period: Array[float]
@export var _base_shield: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.RARE


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Aether Redirector: Wrong card_lvl: ", card_lvl)
		return

	var cooldown: float = _base_period[card_lvl - 1]
	var shield_amount: float = _base_shield[card_lvl - 1]
	var state := {&"ready": true, &"timer": null as Timer}

	var _on_cooldown_finished := func() -> void:
		state[&"ready"] = true

	var _on_projectile_spawned := func(
		_source: Entity, target: Entity, projectile_type: Projectile.Type,
		_modifiers: Array, projectile: Projectile
	) -> void:
		if not state[&"ready"]:
			return
		# Ignore auto-attacks
		if projectile_type == Projectile.Type.SHADOW_BOLT:
			return # TODO: change this check
		# Only redirect if target is an ally (not self)
		if target == ctx.hero or target.team != ctx.hero.team:
			return
		# Redirect projectile to self
		state[&"ready"] = false
		var timer: Timer = state[&"timer"]
		if timer != null:
			timer.start(cooldown)
		projectile.set_target(ctx.hero)
		# Gain shield
		ctx.hero.inflict_condition_stacks(ctx.hero, shield_amount, Utils.StackType.SHIELD, &"Aether Redirector")

	ctx.battle_callbacks.register_battle_start(&"Aether Redirector", func() -> void:
		state[&"ready"] = true
		# Create cooldown timer
		var timer := Timer.new()
		timer.one_shot = true
		timer.timeout.connect(_on_cooldown_finished)
		ctx.hero.add_child(timer)
		state[&"timer"] = timer
		# Connect to fighting area
		if ctx.hero.fighting_area != null:
			if not ctx.hero.fighting_area.projectile_spawned.is_connected(_on_projectile_spawned):
				ctx.hero.fighting_area.projectile_spawned.connect(_on_projectile_spawned)
	)
	ctx.battle_callbacks.register_battle_end(&"Aether Redirector", func() -> void:
		# Cleanup timer
		var timer: Timer = state[&"timer"]
		if timer != null:
			timer.queue_free()
			state[&"timer"] = null
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Aether Redirector: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Every " + str(_base_period[cardlvl - 1]) + "s, redirect the next single-target attack taken by an ally to yourself and gain " + str(_base_shield[cardlvl - 1]) + " shield"
