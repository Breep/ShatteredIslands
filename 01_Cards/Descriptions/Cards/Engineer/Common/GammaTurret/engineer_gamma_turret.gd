class_name EngineerGammaTurret
extends HeroUpgrade

@export var _ad: Array[float]
@export var _shield: Array[int]
@export var _as: Array[float]
@export var _hp: Array[int]
@export var _respawn_timers: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Gamma Turret: Wrong card_lvl: ", card_lvl)
		return

	var ad: float = _ad[card_lvl - 1]
	var shield: int = _shield[card_lvl - 1]
	var attack_speed: float = _as[card_lvl - 1]
	var hp: int = _hp[card_lvl - 1]
	var respawn_timer: float = _respawn_timers[card_lvl - 1]

	ctx.battle_callbacks.register_battle_start(&"Gamma Turret", func() -> void:
		var targets: Array[Entity] = ctx.hero.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES)
		var target: Entity = targets.filter(func(e:Entity) -> bool: return not e is GammaTurret).pick_random()

		ctx.hero.summon_sender.summon_entity(Entity.EntityType.GAMMA_TURRET, SpawnLocationConfig.create_entity_relative(target, 2), {
			GammaTurret.Modifier.TURRET_AD: ad,
			GammaTurret.Modifier.TURRET_SHIELD: shield,
			GammaTurret.Modifier.TURRET_AS: attack_speed,
			GammaTurret.Modifier.TURRET_HP: hp,
			GammaTurret.Modifier.MASTER: target,
			GammaTurret.Modifier.RESPAWN_TIMER: respawn_timer
		})
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Gamma Turret: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	var shield: String = str(_shield[cardlvl - 1])
	var ad: String = str(_ad[cardlvl - 1])
	var respawn: String = str(_respawn_timers[cardlvl - 1])

	return "Invoque une tourelle avec " + ad + " AD et " + shield + " [[SHIELD]] qui suit un allié. Se réactive " + respawn + "s après destruction."
