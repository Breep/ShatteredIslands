class_name ColossusColossalTitan
extends CardEffect

const AXE_VISUAL = preload("res://03_SpellsAndProjectiles/Spells/ColossalTitan/Visual/colossal_titan_visual.tscn")
const DEPLOY_TIME: float = 0.7

@export var _periods: Array[float]
@export var _damage_factors: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:

	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Colossal Titan: Wrong card_lvl: ", card_lvl)
		return

	var period: float = _periods[card_lvl - 1]

	ctx.battle_callbacks.register_periodic(&"Colossal Titan", period, func() -> void:
		if ctx.hero == null or not is_instance_valid(ctx.hero):
			return

		var ennemy: Entity = ctx.hero.target.get_target(TargetComponent.TargettingStrategy.RANDOM_ENEMY)
		if ennemy == null or not is_instance_valid(ennemy):
			return

		# Spawn axe visual on target
		var axe_vfx := AXE_VISUAL.instantiate() as Node3D
		ctx.hero.get_tree().root.add_child(axe_vfx)
		axe_vfx.global_position = ennemy.global_position

		# Delay damage to sync with axe impact
		var damage_factor: float = _damage_factors[card_lvl - 1]
		ctx.battle_callbacks.register_oneshot(DEPLOY_TIME, func() -> void:
			if not is_instance_valid(ennemy): return
			var damage: float = (ctx.hero.stats.scale - 1) * 100 * damage_factor
			ctx.hero.damage.direct(ennemy, damage, Utils.ActionType.DAMAGE_PHYSICAL, &"Colossal Titan")
		)
	)

func revert_card(ctx: CardContext, _card_lvl: int) -> void:
	ctx.battle_callbacks.unregister_all(&"Colossal Titan")


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Colossal Titan: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Toutes les " + str(_periods[cardlvl - 1]) + "s, un ennemi aléatoire subit " + str(_damage_factors[cardlvl - 1]) + " * bonus [[SCALE]] du héros."
