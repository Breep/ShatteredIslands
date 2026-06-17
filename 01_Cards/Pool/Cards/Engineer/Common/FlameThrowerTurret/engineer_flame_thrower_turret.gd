class_name EngineerFlameThrowerTurret
extends CardEffect

## Engineer — Construit une tourelle
# TODO g&érer les level
@export var _turret_level: Array[int]
@export var _turret_desc: EntityDesc

func on_hand_enter(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	if ctx.roaster == null:
		Verbose.warn("EngineerFlameThrowerTurret: ctx.roaster null, skip effect", Verbose.Category.CARD)
		return
	var entry: RoasterEntry = ctx.roaster.add_building(_turret_desc, card_name)
	entry.level = _turret_level[card_lvl - 1]


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	if ctx.roaster == null:
		return
	ctx.roaster.remove_by_source(card_name)


func on_upgrade(ctx: CardContext, card_name: StringName, _prev_lvl: int, new_lvl: int) -> void:
	if ctx.roaster == null:
		return
	var entries: Array[RoasterEntry] = ctx.roaster.get_by_source(card_name)
	if not entries.is_empty():
		entries[0].level = _turret_level[new_lvl - 1]

func get_description(card_lvl: int) -> String:
	return "[[BUILDING]] : Place une tourelle lance-flamme de niveau " + str(_turret_level[card_lvl - 1])
