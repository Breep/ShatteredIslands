class_name EngineerAegisResonator
extends HeroUpgrade

@export var _period: Array[float]
@export var _shared_shields: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Aegis Resonator: Wrong card_lvl: ", card_lvl)
		return
	
	var period: float = _period[card_lvl - 1]
	var shield: float = _shared_shields[card_lvl - 1]
	
	ctx.periodic_timers.register(&"Aegis Resonator", period, func() -> void:
		if not is_instance_valid(ctx.hero): return
		
		var allies: Array[Entity] = ctx.hero.target.get_targets(TargetModule.MultipleTargettingStrategy.ALLIES)
		var shield_distribution: Array[float] = Utils.get_randf_distribution(shield, allies.size(), ctx.hero.battle_id)
		for i in allies.size():
			var shield_gain: float = shield_distribution[i]
			ctx.hero.alterations.inflict_condition_stacks(allies[i], shield_gain, Alteration.Type.SHIELD, &"Aegis Resonator")
			ShieldVfxSpawner.spawn_on(allies[i])
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Aegis Resonator: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var p: String = str(_period[cardlvl - 1]).pad_decimals(1)
	var shield: String = str(_shared_shields[cardlvl - 1]).pad_decimals(0)
	return "Toutes les " + p + "s, gagne " + shield + " [[SHIELD]] partagé avec tous les alliés."
