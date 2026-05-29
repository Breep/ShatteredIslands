class_name PoisonDeathSmoke
extends CardEffect

@export var _period: Array[float]
@export var _multiplier: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.LEGENDARY]:
		printerr("Death Smoke: Wrong card_lvl: ", card_lvl)
		return

	var period: float = _period[card_lvl - 1]
	var multiplier: float = _multiplier[card_lvl - 1]

	ctx.battle_callbacks.register_battle_start(&"Death Fog", func() -> void:
		var spell_modifier: Dictionary = {
			Spell.DeathFogModifier.GROW_SPEED: 0.2,
			Spell.DeathFogModifier.TICK_PERIOD: period,
			Spell.DeathFogModifier.DAMAGE_MULTIPLIER: multiplier,
		}
		ctx.hero.spell.cast_spell(ctx.hero, Spell.Type.DEATH_FOG, spell_modifier)
	)


func revert_card(ctx: CardContext, _card_lvl: int) -> void:
	ctx.battle_callbacks.unregister_all(&"Death Fog")


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.LEGENDARY]:
		printerr("Death Smoke: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "At the start of the fight, surrond the battefield with gas. Then the gas speads slowly toward the middle. Entities inside" \
			+ " takes " + str(_multiplier)
