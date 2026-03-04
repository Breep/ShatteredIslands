class_name StormSchrodingerStorm
extends HeroUpgrade

@export var _stacks: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Schrodinger Storm: Wrong card_lvl: ", card_lvl)
		return

	var base_amount: float = _stacks[card_lvl - 1]

	var storm_stats: FamilyStormStats = ctx.hero.families_stats.storm
	storm_stats.on_rank_change_callbacks.append(
		func(_rank: StormCallerManager.Rank, rank_mult: float) -> void:
			# 50/50 chance for Ally vs Enemy
			var target_is_ally: bool = Utils.get_randf_range(0, 1, ctx.hero.battle_id, "schrodinger_storm_1") < 0.5
			var target: Entity = null

			if target_is_ally:
				target = ctx.hero.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ALLY_INCLUDING_SELF)
			else:
				target = ctx.hero.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)

			if target == null or not is_instance_valid(target) or target.is_dead: return

			var final_amount: float = base_amount * rank_mult
			var stack_type: Stack.Type

			if target_is_ally:
				if Utils.get_randf_range(0, 1, ctx.hero.battle_id, "schrodinger_storm_2") < 0.5:
					stack_type = Stack.Type.SHIELD
					final_amount *= 2.0
				else:
					stack_type = Stack.Type.REGEN
					final_amount *= 1.0
			else:
				var roll: float = Utils.get_randf_range(0, 1, ctx.hero.battle_id, "schrodinger_storm_3")
				if roll < 0.33:
					stack_type = Stack.Type.IGNITE
					final_amount *= 2.0
				elif roll < 0.66:
					stack_type = Stack.Type.NECROSIS
					final_amount *= 2.0
				else:
					stack_type = Stack.Type.POISON
					final_amount *= 0.5

			if final_amount > 0:
				ctx.hero.inflict_condition_stacks(target, final_amount, stack_type, &"Schrödinger's Storm")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Schrodinger Storm: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	var val = str(_stacks[cardlvl - 1]).pad_decimals(0)

	return "On Rank Change, inflict " + val + " random stacks to a random entity."
