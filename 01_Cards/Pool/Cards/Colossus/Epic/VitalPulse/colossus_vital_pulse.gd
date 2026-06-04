class_name ColossusVitalPulse
extends CardEffect

## Colossus — pulse périodique infligeant un % des PV max en dégâts physiques
## aux ennemis dans un rayon autour du héros.

const VITAL_PULSE_VFX: PackedScene = preload("res://22_VFX/VFX_3D/VFX/Scenes/VFX_Vital_Pulse.tscn")

@export var _period: Array[float]
@export var _hp_percent: Array[float]
@export var _radius: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var hp_pct: float = _hp_percent[card_lvl - 1]
	var period: float = _period[card_lvl - 1]
	var radius: float = _radius[card_lvl - 1]

	var vfx := VITAL_PULSE_VFX.instantiate() as Node3D
	owner.add_child(vfx)

	owner.battle_callback_registry.register_periodic(card_name, period, func() -> void:
		var targets: Array[Entity] = owner.target.get_targets(
			TargetComponent.MultipleTargettingStrategy.ENEMIES
		)
		if targets.is_empty():
			return

		var max_hp: float = owner.stats.health_max
		var damage: float = max_hp * hp_pct / 100.0
		if damage <= 0:
			return

		var radius_sq: float = radius * radius
		for target in targets:
			if target == null or not is_instance_valid(target):
				continue
			if owner.global_position.distance_squared_to(target.global_position) > radius_sq:
				continue
			owner.damage.direct(target, damage, Utils.ActionType.DAMAGE_PHYSICAL, card_name)
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.battle_callback_registry.unregister_all(card_name)


func get_description(card_lvl: int) -> String:
	var hp: String = str(_hp_percent[card_lvl - 1]).pad_decimals(1)
	return "Toutes les " + str(_period[card_lvl - 1]) + "s, inflige " + hp \
		+ "% des PV max en [[PHYSICAL_DAMAGE]] aux ennemis dans un rayon de " \
		+ str(_radius[card_lvl - 1]) + "m."
