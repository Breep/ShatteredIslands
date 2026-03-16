class_name FireCosmicBolt
extends HeroUpgrade

@export var _damage_per_stack: Array[float]
@export var _bounce_chance_per_stack: Array[float]
@export var _period: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Cosmic Bolt: Wrong card_lvl: ", card_lvl)
		return
	
	var dmg_per_stack: float = _damage_per_stack[card_lvl - 1]
	var bounce_chance: float = _bounce_chance_per_stack[card_lvl - 1]
	var period: float = _period[card_lvl - 1]
	
	ctx.periodic_timers.register(&"Cosmic Bolt", period, func() -> void:
		var target: Entity = ctx.hero.target_module.get_target(TargetModule.TargettingStrategy.HIGHEST_HP_ENEMY)
		if target == null: return
		if target == null or not is_instance_valid(target): return
		var proj_stats := ProjectileStats.new()
		proj_stats.on_hit_callbacks.append(func(cb_vars: Dictionary) -> void:
			if not cb_vars.has(ProjectileStats.VarType.TARGET): return
			var hit_target: Entity = cb_vars[ProjectileStats.VarType.TARGET]
			if hit_target == null or not is_instance_valid(hit_target) or hit_target.is_queued_for_deletion(): return
			
			var ignite_stacks: float = hit_target.conditions.ignite_stacks
			var damage: float = ignite_stacks * dmg_per_stack
			if damage > 0:
				ctx.hero.direct_damage(hit_target, damage, Utils.ActionType.DAMAGE_MAGICAL, &"Cosmic Bolt")
			
			var bc: float = float(ignite_stacks) * bounce_chance
			if Utils.is_randomize_modifier_active(bc, ctx.hero.battle_id):
				var projectile: Projectile = cb_vars[ProjectileStats.VarType.PROJECTILE]
				projectile.add_bounce(1)
		)
		ctx.hero.projectile_attack(target, Projectile.Type.COSMIC_BOLT, ctx.hero, proj_stats)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Cosmic Bolt: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Every " + str(_period[cardlvl - 1]) + "s, fire a bolt. Deals " + str(_damage_per_stack[cardlvl - 1]) + " damage per [[IGNITE]] stack. " + str(_bounce_chance_per_stack[cardlvl - 1]) + "% chance per [[IGNITE]] stack to bounce."
