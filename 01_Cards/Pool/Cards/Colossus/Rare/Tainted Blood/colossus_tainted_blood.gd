class_name ColossusTaintedBlood
extends CardEffect

const ORB_VISUAL = preload("res://03_SpellsAndProjectiles/Spells/TaintedBlood/Visual/tainted_blood_orb_visual.tscn")

@export var _lost_hp_percent: Array[float]
@export var _period: Array[float]

var _orb_visual: TaintedBloodOrbVisual

func apply_card(ctx: CardContext, card_lvl: int) -> void:

	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Tainted Blood: Wrong card_lvl: ", card_lvl)
		return

	var percent: float = _lost_hp_percent[card_lvl - 1]
	var period: float = _period[card_lvl - 1]

	# Spawn orb visual on battle start
	ctx.battle_callbacks.register_battle_start(&"Tainted Blood", func() -> void:
		if not is_instance_valid(ctx.hero): return
		if is_instance_valid(_orb_visual):
			_orb_visual.queue_free()
		_orb_visual = ORB_VISUAL.instantiate() as TaintedBloodOrbVisual
		_orb_visual.setup(ctx.hero)
		ctx.hero.get_tree().root.add_child(_orb_visual)
	)

	ctx.battle_callbacks.register_periodic(&"Tainted Blood", period, func() -> void:
		var target = ctx.hero.target.get_target(TargetComponent.TargettingStrategy.RANDOM_ENEMY)
		if target == null or not is_instance_valid(target):
			return

		var max_hp: float = ctx.hero.stats.health_max
		var current_hp: float = ctx.hero.stats.health
		var lost_hp: float = max_hp - current_hp
		if lost_hp <= 0:
			return

		var stacks: float = lost_hp * (percent / 100.0)
		if stacks <= 0:
			return

		var is_poison: bool
		var stack_type: Alteration.Type
		if Utils.get_randi_range(1, 2, ctx.hero.battle_id) % 2 == 0:
			stack_type = Alteration.Type.POISON
			is_poison = true
		else:
			stack_type = Alteration.Type.IGNITE
			stacks *= 3
			is_poison = false

		# Launch projectile from the correct orb
		if is_instance_valid(_orb_visual):
			_orb_visual.launch_projectile(target, is_poison)

		ctx.hero.alterations.inflict_condition_stacks(target, stacks, stack_type, &"Tainted Blood")
	)


func revert_card(ctx: CardContext, _card_lvl: int) -> void:
	ctx.battle_callbacks.unregister_all(&"Tainted Blood")
	if is_instance_valid(_orb_visual):
		_orb_visual.queue_free()


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Tainted Blood: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Toutes les " + str(_period[cardlvl - 1]) + "s, inflige " + str(_lost_hp_percent[cardlvl - 1]) + "% des PV perdus en [[POISON_STACK]] ou [[IGNITE]] à la cible."
