class_name ColossusStoneSkin
extends CardEffect

@export var _base_thorn_values: Array[float]
@export var _bonus_thorn_factors: Array[float]

var _scale_cb: Callable

func apply_card(ctx: CardContext, card_lvl: int) -> void:

	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Stone Skin: Wrong card_lvl: ", card_lvl)
		return

	var base_thorn: float = _base_thorn_values[card_lvl - 1]

	if ctx.hero.alterations == null: return
	ctx.hero.alterations.add_stack(Alteration.Type.THORN, base_thorn)

	# Dynamic thorn tracked via a local delta keeper; re-applied on scale changes.
	var last_dynamic: Array[float] = [0.0]
	_apply_thorn_scaling(ctx.hero, card_lvl, last_dynamic)
	_scale_cb = func(_scale: float) -> void:
		if is_instance_valid(ctx.hero) and not ctx.hero.is_queued_for_deletion():
			_apply_thorn_scaling(ctx.hero, card_lvl, last_dynamic)

	if not ctx.hero.stats.scale_changed.is_connected(_scale_cb):
		ctx.hero.stats.scale_changed.connect(_scale_cb)
		


func revert_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		return
	if _scale_cb.is_valid() and ctx.hero.stats.scale_changed.is_connected(_scale_cb):
		ctx.hero.stats.scale_changed.disconnect(_scale_cb)
	if ctx.hero.alterations == null:
		return
	var base_thorn: float = _base_thorn_values[card_lvl - 1]
	var dynamic_thorn: float = _bonus_thorn_factors[card_lvl - 1] * (ctx.hero.stats.scale - 1) * 100
	ctx.hero.alterations.remove_stack(Alteration.Type.THORN, base_thorn + maxf(0.0, dynamic_thorn))


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Stone Skin: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Augmente les épines de " + str(_base_thorn_values[cardlvl - 1]) + " + " + str(_bonus_thorn_factors[cardlvl - 1]) + " * [[SCALE]] du héros."


func _apply_thorn_scaling(hero: Entity, card_lvl: int, last_dynamic: Array[float]) -> void:
	if hero.alterations == null: return
	var bonus_thorn_factor: float = _bonus_thorn_factors[card_lvl - 1]
	var new_value: float = bonus_thorn_factor * (hero.stats.scale - 1) * 100
	var delta: float = new_value - last_dynamic[0]
	if delta > 0:
		hero.alterations.add_stack(Alteration.Type.THORN, delta)
	elif delta < 0:
		hero.alterations.remove_stack(Alteration.Type.THORN, -delta)
	last_dynamic[0] = new_value
