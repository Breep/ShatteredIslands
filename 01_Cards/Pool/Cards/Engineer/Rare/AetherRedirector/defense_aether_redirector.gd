class_name DefenseAetherRedirector
extends CardEffect

@export var _base_period: Array[float]
@export var _base_shield: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Aether Redirector: Wrong card_lvl: ", card_lvl)
		return
	
	var period: float = _base_period[card_lvl - 1]
	var shield_amount: float = _base_shield[card_lvl - 1]
	
	var _scan_and_redirect := func() -> void:
		if not is_instance_valid(ctx.hero) or ctx.hero.is_dead():
			return
		if ctx.hero.spawn_manager == null:
			return
		for node: Node in ctx.hero.spawn_manager.get_live_projectiles():
			if not node is Projectile:
				continue
			var projectile: Projectile = node as Projectile
			var target: Entity = projectile.get_target()
			if target == null or not is_instance_valid(target):
				continue
			if target == ctx.hero or target.team != ctx.hero.team or target.is_dead():
				continue
			projectile.retarget(ctx.hero)
			ctx.hero.alterations.inflict_condition_stacks(
				ctx.hero, shield_amount, Alteration.Type.SHIELD,
				&"Aether Redirector"
			)
			return
	
	ctx.battle_callbacks.register_periodic(&"Aether Redirector", period, _scan_and_redirect)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Aether Redirector: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Toutes les " + str(_base_period[cardlvl - 1]) \
		+ "s, redirige la prochaine attaque mono-cible d'un allié " \
		+ "vers vous et gagne " + str(_base_shield[cardlvl - 1]) + " [[SHIELD]]."
