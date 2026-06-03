class_name PoisonShrooms
extends CardEffect

@export var _damage: Array[int]
@export var _life_time: Array[float]
@export var _period: Array[float]
@export var _radius: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.EPIC]:
		printerr("Shrooms: Wrong card_lvl: ", card_lvl)
		return

	var damage: int = _damage[card_lvl - 1]
	var life_time: float = _life_time[card_lvl - 1]
	var period: float = _period[card_lvl - 1]
	var radius: float = _radius[card_lvl - 1]

	ctx.battle_callbacks.register_periodic(&"Shrooms", period, func() -> void:
		var target: Entity = ctx.hero.target.get_target(TargetComponent.TargettingStrategy.RANDOM_ENEMY)
		if target == null: return
		var spell_modifier: Dictionary = {
			Spell.ShroomModifier.RADIUS: radius,
			Spell.ShroomModifier.DAMAGE: damage,
			Spell.ShroomModifier.LIFE_TIME: life_time
		}
		ctx.hero.spell.cast_spell(target, Spell.Type.SHROOM, spell_modifier)
	)


func revert_card(ctx: CardContext, _card_lvl: int) -> void:
	ctx.battle_callbacks.unregister_all(&"Shrooms")


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.EPIC]:
		printerr("Shrooms: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Every " + str(_period[cardlvl - 1]) + "s, a shroom grows on a random spot. Shrooms grow for " + str(_life_time[cardlvl - 1]) \
			+ "s. When fully grown, it explodes dealing " + str(_damage[cardlvl - 1]) + "[[POISON_DAMAGE]] in a " \
			+ str(_radius[cardlvl - 1]) + "m radius"
