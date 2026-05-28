class_name EngineerDeflectionShield
extends CardEffect

@export var _blocked_projectiles: Array[int]
@export var _shield_per_blocks: Array[int]
@export var _respawn_timers: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Deflection Shield: Wrong card_lvl: ", card_lvl)
		return

	var blocked_projectiles: int = _blocked_projectiles[card_lvl - 1]
	var shield_per_block: int = _shield_per_blocks[card_lvl - 1]
	var respawn_timer: float = _respawn_timers[card_lvl - 1]

	ctx.battle_callbacks.register_battle_start(&"Deflection Shield", func() -> void:
		ctx.hero.summon.summon_entity(Entity.EntityType.DEFLECTION_SHIELD, SpawnLocationConfig.create_between_center(ctx.hero, 2), {
			DeflectionShield.Modifier.BLOCKED_PROJECTILES: blocked_projectiles,
			DeflectionShield.Modifier.SHIELD_PER_BLOCK: shield_per_block,
			DeflectionShield.Modifier.RESPAWN_TIMER: respawn_timer
		})
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Deflection Shield: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	var bp: String = str(_blocked_projectiles[cardlvl - 1])
	var sb: String = str(_shield_per_blocks[cardlvl - 1])
	var respawn: String = str(_respawn_timers[cardlvl - 1])
	return "Invoque un bouclier orbital bloquant " + bp + " projectiles. Chaque blocage donne " + sb + " [[SHIELD]]. Se réactive " + respawn + "s après destruction."
