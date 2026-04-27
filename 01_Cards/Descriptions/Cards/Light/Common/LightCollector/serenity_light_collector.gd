class_name SerenityLightCollector
extends HeroUpgrade

@export var _regen_per_card: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Light Collector: Wrong card_lvl: ", card_lvl)
		return

	#var regen_amount: float = _regen_per_card[card_lvl - 1]
#
	#ctx.battle_callbacks.register_battle_start(&"Light Collector", func() -> void:
		#if ctx.hero.deck == null:
			#push_warning("Light Collector: deck is null")
			#return
		#var count: int = ctx.hero.deck.get_unique_card_count(Family.Type.LIGHT)
		#var total_regen: float = count * regen_amount
		#if total_regen <= 0: return
#
		#var allies: Array[Entity] = ctx.hero.target.get_targets(TargetModule.MultipleTargettingStrategy.ALLIES)
		#for ally: Entity in allies:
			#if ally != null and is_instance_valid(ally) and not ally.is_dead:
				#ctx.hero.alterations.inflict_condition_stacks(ally, total_regen, Alteration.Type.REGEN, &"Light Collector")
	#)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Light Collector: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	var val = str(_regen_per_card[cardlvl - 1]).pad_decimals(1)

	return "Apply " + val + " [[REGEN_STACK]] to ALL allies at the start of combat for each unique Light card you possess."
