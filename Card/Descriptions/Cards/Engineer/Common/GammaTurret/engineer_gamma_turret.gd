class_name EngineerGammaTurret
extends HeroUpgrade

@export var _ad: Array[float]
@export var _shield: Array[int]
@export var _as: Array[float]
@export var _hp: Array[int]
@export var _nb_turret: Array[int]
@export var _periods: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Gamma Turret: Wrong card_lvl: ", card_lvl)
		return

	var ad: float = _ad[card_lvl - 1]
	var shield: int = _shield[card_lvl - 1]
	var attack_speed: float = _as[card_lvl - 1]
	var hp: int = _hp[card_lvl - 1]
	var nb_turret: int = _nb_turret[card_lvl - 1]
	var period: float = _periods[card_lvl - 1]

	ctx.periodic_timers.register(&"Gamma Turret", period, func() -> void:
		for turret in nb_turret:
			var targets: Array[Entity] = ctx.hero.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ALLIES)
			var target: Entity = targets.filter(func(e:Entity) -> bool: return not e is GammaTurret).pick_random() #TODO rendre déterministe
			
			ctx.hero.summon_entity(Entity.EntityType.GAMMA_TURRET, SpawnLocationConfig.create_entity_relative(target, 2), {
				GammaTurret.Modifier.TURRET_AD: ad,
				GammaTurret.Modifier.TURRET_SHIELD: shield,
				GammaTurret.Modifier.TURRET_AS: attack_speed,
				GammaTurret.Modifier.TURRET_HP: hp,
				GammaTurret.Modifier.MASTER: target
			})
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Gamma Turret: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var nb_turret: String = str(_nb_turret[cardlvl - 1])
	var shield: String = str(_shield[cardlvl - 1])
	var ad: String = str(_ad[cardlvl - 1])
	
	return "Invoque " + nb_turret + " tourelle avec " + ad + " AD et " + shield + " [[SHIELD]] qui suit un allié aléatoire."
