class_name ColossusVitalPulse
extends CardEffect

## Colossus — pulse périodique infligeant un % des PV max en dégâts physiques
## aux ennemis dans un rayon autour du héros.

const VITAL_PULSE_VFX: PackedScene = preload("res://22_VFX/VFX_3D/VFX/Scenes/VFX_Vital_Pulse.tscn")

## Rayon (en unités) couvert par le VFX à scale 1 : le plan fait 1×1 mis à l'échelle
## ×8 dans la scène → demi-largeur = 4. Sert à mettre le visuel à l'échelle du rayon de dégâts.
const VFX_NOMINAL_RADIUS: float = 4.0

@export var _period: Array[float]
@export var _hp_percent: Array[float]
@export var _radius: Array[float]

var _vfx: Node3D

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var hp_pct: float = _hp_percent[card_lvl - 1]
	var period: float = _period[card_lvl - 1]
	var radius: float = _radius[card_lvl - 1]

	# Spawn le VFX de sol continu sous le héros au début du combat, et le retire
	# en fin de combat (rattaché au cycle de vie de la carte).
	owner.battle_callback_registry.register_battle_start(card_name, func() -> void:
		if not is_instance_valid(owner): return
		if is_instance_valid(_vfx):
			_vfx.queue_free()
		_vfx = VITAL_PULSE_VFX.instantiate() as Node3D
		owner.add_child(_vfx)
		# Met le visuel à l'échelle du rayon de dégâts.
		_vfx.scale = Vector3.ONE * (radius / VFX_NOMINAL_RADIUS)
	)
	owner.battle_callback_registry.register_battle_end(card_name, func() -> void:
		if is_instance_valid(_vfx):
			_vfx.queue_free()
	)

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
	if is_instance_valid(_vfx):
		_vfx.queue_free()


func get_description(card_lvl: int) -> String:
	return "Toutes les " + _value(_period[card_lvl - 1]) + "s : " + _value(_hp_percent[card_lvl - 1]) \
		+ "% des PV max en [[PHYSICAL_DAMAGE]] aux ennemis (" \
		+ _value(_radius[card_lvl - 1]) + "m)."
