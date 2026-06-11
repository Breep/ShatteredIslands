class_name ArdentCelestialPhoenix
extends CardEffect

## Ardent Celestial — Recrute un phoenix (ajouté au roaster en tant qu'acolyte).
## Le niveau de carte fixe le niveau du phoenix recruté.

@export var _acolyte_level: Array[int]
@export var _acolyte_desc: EntityDesc


func on_hand_enter(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	if ctx.roaster == null:
		Verbose.warn("ArdentCelestialPhoenix: ctx.roaster null, skip effect", Verbose.Category.CARD)
		return
	var entry: RoasterEntry = ctx.roaster.add_acolyte(_acolyte_desc, card_name)
	entry.level = _acolyte_level[card_lvl - 1]


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	if ctx.roaster == null:
		return
	ctx.roaster.remove_by_source(card_name)


func on_upgrade(ctx: CardContext, card_name: StringName, _prev_lvl: int, new_lvl: int) -> void:
	if ctx.roaster == null:
		return
	var entries: Array[RoasterEntry] = ctx.roaster.get_by_source(card_name)
	if not entries.is_empty():
		entries[0].level = _acolyte_level[new_lvl - 1]


func get_description(card_lvl: int) -> String:
	return "Recrute un phoenix de niveau " + str(_acolyte_level[card_lvl - 1])
