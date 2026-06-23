# Carte Chicken Lord : ajoute un poulailler (bâtiment) au roaster du porteur.
# Le niveau du bâtiment suit le niveau de la carte. Calquée sur la carte tourelle
# lance-flammes (Engineer), même mécanique générique de construction.
class_name ChickenlordChickenCoop
extends CardEffect

@export var _building_level: Array[int]
@export var _building_desc: EntityDesc


func on_hand_enter(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	if ctx.roaster == null:
		Verbose.warn("ChickenlordChickenCoop: ctx.roaster null, skip effect", Verbose.Category.CARD)
		return
	var entry: RoasterEntry = ctx.roaster.add_building(_building_desc, card_name)
	entry.level = _building_level[card_lvl - 1]


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	if ctx.roaster == null:
		return
	ctx.roaster.remove_by_source(card_name)


func on_upgrade(ctx: CardContext, card_name: StringName, _prev_lvl: int, new_lvl: int) -> void:
	if ctx.roaster == null:
		return
	var entries: Array[RoasterEntry] = ctx.roaster.get_by_source(card_name)
	if not entries.is_empty():
		entries[0].level = _building_level[new_lvl - 1]


func get_description(card_lvl: int) -> String:
	return "[[BUILDING]] : Construit un poulailler de niveau " + _value(_building_level[card_lvl - 1])
