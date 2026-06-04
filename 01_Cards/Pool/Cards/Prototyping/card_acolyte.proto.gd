class_name CardPrototypingAcolyte
extends CardEffect

## Add/Remove an acolyte

@export var acolyte_desc: EntityDesc

var _roaster_entry: RoasterEntry

func apply(ctx: CardContext, _card_name: StringName, _card_lvl: int) -> void:
	var roaster: Roaster = ctx.roaster
	roaster.add(RoasterEntry.from_desc(acolyte_desc))


func revert(ctx: CardContext, _card_name: StringName, _card_lvl: int) -> void:
	ctx.roaster.remove(_roaster_entry)


func get_description(_card_lvl: int) -> String:
	return "Invoque un acolyte"
