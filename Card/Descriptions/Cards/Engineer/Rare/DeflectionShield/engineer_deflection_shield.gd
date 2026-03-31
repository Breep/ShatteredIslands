class_name EngineerDeflectionShield
extends HeroUpgrade

@export var _shield_numbers: Array[int]
@export var _blocked_projectiles: Array[int]
@export var _shield_per_blocks: Array[int]
@export var _periods: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Toxic Filtration Layer: Wrong card_lvl: ", card_lvl)
		return

	var shield_number: int = _shield_numbers[card_lvl - 1]
	var blocked_projectiles: int = _blocked_projectiles[card_lvl - 1]
	var shield_per_block: int = _shield_per_blocks[card_lvl - 1]
	var period: float = _periods[card_lvl - 1]

	ctx.periodic_timers.register(&"Toxic Filtration Layer", period, func() -> void:
		ctx.hero.summon_entity(Entity.EntityType.DEFLECTION_SHIELD, SpawnLocationConfig.create_between_center(ctx.hero, 2), {
			DeflectionShield.Modifier.BLOCKED_PROJECTILES: blocked_projectiles,
			DeflectionShield.Modifier.SHIELD_PER_BLOCK: shield_per_block
		})
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Toxic Filtration Layer: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var bp: String = str(_blocked_projectiles[cardlvl - 1])
	var sb: String = str(_shield_per_blocks[cardlvl - 1])
	return "Summon an orbiting shield blocking " + bp + " projectiles. Each block, hero gain " + sb + " [[SHIELD]]."
