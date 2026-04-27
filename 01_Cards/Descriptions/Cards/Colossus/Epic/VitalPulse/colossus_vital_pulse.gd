class_name ColossusVitalPulse
extends HeroUpgrade

const VITAL_PULSE_VFX: PackedScene = preload("res://VFX/VFX_3D/VFX/Scenes/VFX_Vital_Pulse.tscn")

@export var _period: Array[float]
@export var _hp_percent: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var hp_pct: float = _hp_percent[card_lvl - 1]
	var period: float = _period[card_lvl - 1]

	# Spawn the continuous floor VFX under the hero
	var vfx := VITAL_PULSE_VFX.instantiate() as Node3D
	ctx.hero.add_child(vfx)

	ctx.periodic_timers.register(&"Vital Pulse", period, func() -> void:
		var targets: Array[Entity] = ctx.hero.target_module.get_targets(
			TargetModule.MultipleTargettingStrategy.ENEMIES
		)
		if targets.is_empty():
			return

		var max_hp: float = ctx.hero.stats.health_max
		var damage: float = max_hp * hp_pct / 100.0
		if damage <= 0:
			return

		for target in targets:
			if target != null and is_instance_valid(target):
				ctx.hero.direct_damage(target, damage, Utils.ActionType.DAMAGE_PHYSICAL, &"Vital Pulse")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Vital Pulse: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	var hp = str(_hp_percent[cardlvl - 1]).pad_decimals(1)
	return "Toutes les " + str(_period[cardlvl - 1]) + "s, inflige " + hp + "% des PV max en [[PHYSICAL_DAMAGE]] à tous les ennemis."
