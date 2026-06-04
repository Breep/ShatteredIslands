class_name PoisonContagion
extends CardEffect

@export var _percent: Array[float]
@export var _radius: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		printerr("Contagion: Wrong card_lvl: ", card_lvl)
		return

	var percent: float = _percent[card_lvl - 1]
	var radius: float = _radius[card_lvl - 1]

	ctx.battle_callbacks.register_battle_start(&"Contagion", func() -> void:
		var spell_modifier: Dictionary = {
			Spell.ContagionModifier.RADIUS: radius,
			Spell.ContagionModifier.SPREAD_PERCENT: percent
		}
		ctx.hero.spell.cast_spell(ctx.hero, Spell.Type.CONTAGION, spell_modifier)
	)


func revert_card(ctx: CardContext, _card_lvl: int) -> void:
	ctx.battle_callbacks.unregister_all(&"Contagion")


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		printerr("Contagion: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "When an enemy dies, it speads " + str(_percent[cardlvl - 1]) + "% of its [[POISON_STACK]] to nearby enemies in a " \
			+ str(_radius[cardlvl - 1]) + "m radius"
