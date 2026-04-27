class_name StormChainLightning
extends HeroUpgrade

@export var _dist_factor: Array[float]
@export var _chance_percent: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Chain Lightning: Wrong card_lvl: ", card_lvl)
		return

	var factor: float = _dist_factor[card_lvl - 1]
	var chance: float = _chance_percent[card_lvl - 1]

	var storm_stats: FamilyStormCallerStats = ctx.hero.families_stats.storm_caller
	storm_stats.on_crit_callbacks.append(
		func(target: Entity, _base_value: float, real_value: float) -> void:
			if not Utils.is_randomize_modifier_active(chance, ctx.hero.battle_id): return
			if target == null or not is_instance_valid(target): return

			var enemies: Array[Entity] = ctx.hero.target.get_targets(TargetModule.MultipleTargettingStrategy.ENEMIES)
			if enemies.is_empty(): return

			var furthest_enemy: Entity = null
			var max_dist_sq: float = -1.0
			var victim_pos = target.global_position

			for enemy in enemies:
				if is_instance_valid(enemy) and enemy != target and not enemy.is_dead:
					var dist_sq = victim_pos.distance_squared_to(enemy.global_position)
					if dist_sq > max_dist_sq:
						max_dist_sq = dist_sq
						furthest_enemy = enemy

			if furthest_enemy == null: return
			var distance: float = sqrt(max_dist_sq)
			distance = min(distance, 50.0)
			var rank_mult: float = StormCallerManager.RANK_VALUE_MULTIPLIERS.get(storm_stats.current_rank, 1.0)
			var damage_multiplier: float = (factor * distance) / 100.0
			var final_damage: float = real_value * damage_multiplier * rank_mult

			var spell_modifiers: Dictionary = {
				Spell.ChainLightningModifier.DAMAGE: final_damage,
				Spell.ChainLightningModifier.BOUNCE_COUNT: 3,
				Spell.ChainLightningModifier.BOUNCE_RANGE: 150.0,
				Spell.ChainLightningModifier.DAMAGE_DECAY_PERCENT: 10.0,
				"start_position": victim_pos
			}
			ctx.hero.spell_sender.cast_spell(furthest_enemy, Spell.Type.CHAIN_LIGHTNING, spell_modifiers)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Chain Lightning: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "On crit, have " + str(_chance_percent[cardlvl - 1]) + "% chance to generate an electric arc spreading to furthest enemy. Deals " + str(_dist_factor[cardlvl - 1]) + " * distance % of original damage."
