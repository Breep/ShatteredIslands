class_name ColossusSeismicSlam
extends HeroUpgrade

const SEISMIC_DECAL_SCENE: PackedScene = preload("res://VFX/VFX_3D/SeismicSlam/vfx_seismic_slam_decal.tscn")

@export var _increase_sizes: Array[float]
@export var _periods: Array[float]
@export var _stun_durations: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Seismic Slam: Wrong card_lvl: ", card_lvl)
		return
	
	var period: float = _periods[card_lvl - 1]
	var size_gain: float = _increase_sizes[card_lvl - 1]
	var stun_duration: float = _stun_durations[card_lvl - 1]
	
	var state := {&"iteration": 1}
	ctx.periodic_timers.register(&"Seismic Slam", period, func() -> void:
		if ctx.hero == null or not is_instance_valid(ctx.hero):
			return

		# Spawn ground decal VFX
		var decal_vfx := SEISMIC_DECAL_SCENE.instantiate() as Node3D
		ctx.hero.get_tree().current_scene.add_child(decal_vfx)
		decal_vfx.global_position = ctx.hero.global_position

		# Size increase
		var mod3 := StatModifier.new()
		mod3.id = &"Seismic Slam"
		mod3.stat_type = EntityStats.StatType.SCALE
		mod3.calc_type = StatModifier.CalcType.ADD
		mod3.value = (_increase_sizes[card_lvl - 1]/100) * state[&"iteration"]
		ctx.stat_modifiers.register_modifier(mod3)
		
		# Apply stuns
		var ennemies: Array[Entity] = ctx.hero.target.get_targets(TargetComponent.MultipleTargettingStrategy.ENEMIES)
		for a: Entity in ennemies:
			if a != null and is_instance_valid(a):
				ctx.hero.alterations.inflict_status(a, Alteration.Type.STUN, stun_duration, &"Seismic Slam")
				
		state[&"iteration"] += 1
	)

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Seismic Slam: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Toutes les " + str(_periods[cardlvl - 1]) + "s, [[STUN]] tous les ennemis pendant " + str(_stun_durations[cardlvl - 1]) + " et augmente le [[SCALE]] du héros de " + str(_increase_sizes[cardlvl - 1]) + "%."
 
