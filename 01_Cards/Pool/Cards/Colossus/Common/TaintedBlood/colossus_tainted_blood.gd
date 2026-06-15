class_name ColossusTaintedBlood
extends CardEffect

## Colossus — périodiquement, inflige à un ennemi aléatoire des stacks de poison
## égaux à un pourcentage des PV perdus du héros.

const ORB_VISUAL = preload("res://03_SpellsAndProjectiles/Spells/TaintedBlood/Visual/tainted_blood_orb_visual.tscn")

@export var _lost_hp_percent: Array[float]
@export var _period: Array[float]

var _orb_visual: TaintedBloodOrbVisual

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var percent: float = _lost_hp_percent[card_lvl - 1]
	var period: float = _period[card_lvl - 1]

	owner.battle_callback_registry.register_battle_start(card_name, func() -> void:
		if not is_instance_valid(owner): return
		if is_instance_valid(_orb_visual):
			_orb_visual.queue_free()
		_orb_visual = ORB_VISUAL.instantiate() as TaintedBloodOrbVisual
		_orb_visual.setup(owner)
		owner.get_tree().root.add_child(_orb_visual)
	)

	owner.battle_callback_registry.register_periodic(card_name, period, func() -> void:
		var target = owner.target.get_target(TargetComponent.TargettingStrategy.RANDOM_ENEMY)
		if target == null or not is_instance_valid(target):
			return

		var lost_hp: float = owner.stats.health_max - owner.stats.health
		if lost_hp <= 0:
			return

		var stacks: float = lost_hp * (percent / 100.0)
		if stacks <= 0:
			return

		if is_instance_valid(_orb_visual):
			_orb_visual.launch_projectile(target, true)

		owner.alterations.inflict_condition_stacks(target, stacks, Alteration.Type.POISON, card_name)
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.battle_callback_registry.unregister_all(card_name)
	if is_instance_valid(_orb_visual):
		_orb_visual.queue_free()


func get_description(card_lvl: int) -> String:
	return "Toutes les " + str(_period[card_lvl - 1]) + "s, inflige " \
		+ str(_lost_hp_percent[card_lvl - 1]) + "% des PV perdus en [[POISON_STACK]] à un ennemi."
