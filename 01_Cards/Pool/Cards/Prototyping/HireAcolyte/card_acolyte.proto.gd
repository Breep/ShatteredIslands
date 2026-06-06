class_name CardPrototypingAcolyte
extends CardEffect

## Recrute card_lvl acolytes dans le roaster du joueur. Chaque acolyte recruté
## est tagué avec card_name comme source_id ; revert / on_upgrade retrouvent
## ainsi leurs entries via Roaster.get_by_source — pas d'état stocké côté
## CardEffect (Resource partagée).

@export var acolyte_desc: EntityDesc


func on_hand_enter(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	if ctx.roaster == null:
		Verbose.warn("CardPrototypingAcolyte: ctx.roaster null, effet skip", Verbose.Category.CARD)
		return
	_add_acolytes(ctx.roaster, card_name, card_lvl)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	if ctx.roaster == null:
		return
	ctx.roaster.remove_by_source(card_name)


# Override de on_upgrade : on N'écrase PAS revert/apply (no-op pour cette carte).
# On ajoute seulement le delta d'acolytes — les acolytes déjà recrutés gardent
# leur position de combat. Si delta < 0 (rare, dégrade), on retire les derniers
# ajoutés (les plus récents) pour rester intuitif.
func on_upgrade(ctx: CardContext, card_name: StringName, prev_lvl: int, new_lvl: int) -> void:
	if ctx.roaster == null:
		return
	var delta: int = new_lvl - prev_lvl
	if delta > 0:
		_add_acolytes(ctx.roaster, card_name, delta)
	elif delta < 0:
		var owned: Array[RoasterEntry] = ctx.roaster.get_by_source(card_name)
		var to_remove: int = mini(-delta, owned.size())
		for i in to_remove:
			ctx.roaster.remove(owned[owned.size() - 1 - i])


func get_description(card_lvl: int) -> String:
	return "Recrute " + str(card_lvl) + " Acolytes"


func _add_acolytes(roaster: Roaster, source: StringName, count: int) -> void:
	for i in count:
		roaster.add_acolyte(acolyte_desc, source)
