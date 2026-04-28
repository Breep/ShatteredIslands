class_name EngineerFortificationDrone
extends HeroUpgrade

@export var _drones_numbers: Array[int]
@export var _shield_per_seconds: Array[float]
@export var _drone_hps: Array[int]
@export var _drone_shields: Array[float]
@export var _respawn_timers: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Fortification Drone: Wrong card_lvl: ", card_lvl)
		return
	
	var drones_number: int = _drones_numbers[card_lvl -1]
	var shield_per_second: float = _shield_per_seconds[card_lvl - 1]
	var drone_hp: int = _drone_hps[card_lvl - 1]
	var drone_shield: float = _drone_shields[card_lvl - 1]
	var respawn_timer: float = _respawn_timers[card_lvl - 1]
	
	ctx.battle_callbacks.register_battle_start(&"Fortification Drone", func() -> void:
		for i in drones_number:
			var spawn_loc := SpawnLocationConfig.create_entity_relative(ctx.hero, 8.0)
			ctx.hero.summon.summon_entity(Entity.EntityType.FORTIFICATION_DRONE, spawn_loc, {
				FortificationDrone.Modifier.SHIELD: drone_shield,
				FortificationDrone.Modifier.HP_MAX: drone_hp,
				FortificationDrone.Modifier.SHIELD_PER_SECOND: shield_per_second,
				FortificationDrone.Modifier.RESPAWN_TIMER: respawn_timer
			})
		)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Fortification Drone: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var time: String = str(_shield_per_seconds[cardlvl - 1])
	var shield: String = str(_drone_shields[cardlvl - 1])
	var respawn: String = str(_respawn_timers[cardlvl - 1])

	return "Invoque un drone qui suit un allié et donne " + shield + " [[SHIELD]] pendant " + time + "s. Se réactive " + respawn + "s après destruction."
	
