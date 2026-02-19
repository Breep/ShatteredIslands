class_name FireMeteor
extends HeroUpgrade

@export var _period: float
@export var _ignite_stacks: Array[int]
@export var _damage_per_stack: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > 3:
		printerr("Wrong card_lvl: ", card_lvl, " - ", get_class())
		return

	var fire_stats: FamilyFireStats = ctx.hero.families_stats.fire
	fire_stats.meteor_damage_percent = _damage_per_stack[card_lvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > 3:
		printerr("Wrong cardlvl: ", cardlvl, " - ", get_class())
		return "ERROR"

	return ""
