class_name PoisonSnakeBarrel
extends HeroUpgrade

@export var _barrel_health: Array[int]
@export var _snake_number: Array[int]
@export var _poison_stacks: Array[int]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.EPIC]:
		printerr("Snake Barrel: Wrong card_lvl: ", card_lvl)
		return

	var health: int = _barrel_health[card_lvl - 1]
	var snake_number: int = _snake_number[card_lvl - 1]
	var poison_stacks: int = _poison_stacks[card_lvl - 1]

	ctx.battle_callbacks.register_battle_start(&"Snake Barrel", func() -> void:
		var summon_modifier: Dictionary = {
			Entity.SnakeBarrelModifier.SNAKE_NUMBER: snake_number,
			Entity.SnakeBarrelModifier.SNAKE_POISON_STACKS: poison_stacks,
			Entity.SnakeBarrelModifier.MAX_HEALTH: health
		}
		var spawn_config := SpawnLocationConfig.create_arena_center()
		ctx.hero.summon_entity(Entity.EntityType.SNAKE_BARREL, spawn_config, summon_modifier)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.EPIC]:
		printerr("Snake Barrel: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "At the start of fight, place a barrel full of snakes on the batteflied. The barrel has " + str(_barrel_health[cardlvl -1]) \
			+ " hp. When the barrel brakes, it releases " + str(_snake_number[cardlvl - 1]) + " snakes that each inflict " \
			+ str(_poison_stacks[cardlvl - 1]) + " [[POISON_STACKS]]"
