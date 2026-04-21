class_name ColossusStoneSkin
extends HeroUpgrade

@export var _base_thorn_values: Array[float]
@export var _bonus_thorn_factors: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:

	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Stone Skin: Wrong card_lvl: ", card_lvl)
		return

	var base_thorn: float = _base_thorn_values[card_lvl - 1]

	if ctx.hero.alterations_module == null: return
	ctx.hero.alterations_module.add_thorn_stacks(base_thorn)

	# Dynamic thorn tracked via a local delta keeper; re-applied on scale changes.
	var last_dynamic: Array[float] = [0.0]
	_apply_thorn_scaling(ctx.hero, card_lvl, last_dynamic)
	var _on_scale_changed: Callable
	_on_scale_changed = func(_scale: float) -> void:
		if is_instance_valid(ctx.hero) and not ctx.hero.is_queued_for_deletion():
			_apply_thorn_scaling(ctx.hero, card_lvl, last_dynamic)

	if not ctx.hero.stats.scale_changed.is_connected(_on_scale_changed):
		ctx.hero.stats.scale_changed.connect(_on_scale_changed)
		


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Stone Skin: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Augmente les épines de " + str(_base_thorn_values[cardlvl - 1]) + " + " + str(_bonus_thorn_factors[cardlvl - 1]) + " * [[SCALE]] du héros."


func _apply_thorn_scaling(hero: Entity, card_lvl: int, last_dynamic: Array[float]) -> void:
	if hero.alterations_module == null: return
	var bonus_thorn_factor: float = _bonus_thorn_factors[card_lvl - 1]
	var new_value: float = bonus_thorn_factor * (hero.stats.scale - 1) * 100
	var delta: float = new_value - last_dynamic[0]
	if delta > 0:
		hero.alterations_module.add_thorn_stacks(delta)
	elif delta < 0:
		hero.alterations_module.remove_thorn_stacks(-delta)
	last_dynamic[0] = new_value
