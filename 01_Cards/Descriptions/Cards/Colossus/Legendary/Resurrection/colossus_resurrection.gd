class_name ColossusResurrection
extends HeroUpgrade

@export var _time_before_revive: Array[float]
@export var _damage_percent: Array[float]
@export var _size_increase: Array[float]
@export var _hp_max_revive: Array[float]
const EXPLOSION_VFX_SCENE = preload("res://VFX/VFX_Explosion_B.tscn")

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Resurrection: Wrong card_lvl: ", card_lvl)
		return
	
	var mod := ActionModifier.new()
	mod.id = &"Resurrection"
	mod.after_action_logic_callback = func(cb_vars: Dictionary) -> void:
		var tween = ctx.hero.create_tween()
	
		var start_pos = ctx.hero.global_position
		var up_pos = start_pos + Vector3(0, 5, 0) # monte de 50px
		
		# Montée lente (ease out → ralentit vers le haut)
		tween.tween_property(ctx.hero, "global_position", up_pos, 2.8)\
			.set_trans(Tween.TRANS_EXPO)\
			.set_ease(Tween.EASE_OUT)
		# Descente rapide (ease in → accélère vers le bas)
		tween.tween_property(ctx.hero, "global_position", start_pos, 0.2)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_IN)
		
		await tween.finished
		var hit_marker : Node3D = EXPLOSION_VFX_SCENE.instantiate()
		ctx.hero.get_tree().current_scene.add_child(hit_marker)
		hit_marker.global_position = ctx.hero.global_position
		var anim_player: AnimationPlayer = hit_marker.get_node("AnimationPlayer")
		if anim_player:
			anim_player.play("Init")
		ctx.hero.resurrect(_hp_max_revive[card_lvl - 1])

		var targets: Array[Entity] = ctx.hero.target.get_targets(
			TargetComponent.MultipleTargettingStrategy.ENEMIES
		)
		if targets.is_empty():
			return

		var max_hp: float = ctx.hero.stats.health_max
		var damage: float = max_hp * (_damage_percent[card_lvl - 1] / 100.0)
		if damage <= 0:
			return

		for target in targets:
			if target != null and is_instance_valid(target):
				ctx.hero.damage.direct(target, damage, Utils.ActionType.DAMAGE_PHYSICAL, &"Resurrection")
				
		var mod3 := StatModifier.new()
		mod3.id = &"Resurrection"
		mod3.stat_type = EntityStats.StatType.SCALE
		mod3.calc_type = StatModifier.CalcType.ADD
		mod3.value = (_size_increase[card_lvl - 1]/100)
		ctx.stat_modifiers.register_modifier(mod3)
		
	ctx.hero.death_modifiers_registry.register_modifier(mod)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Resurrection: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var hp: String = str(_hp_max_revive[cardlvl - 1])
	var size: String = str(_size_increase[cardlvl - 1])
	var damage: String = str(_damage_percent[cardlvl - 1])
	
	return "À la mort, ressuscite avec " + hp + "% PV et le [[SCALE]] augmente de " + size + ".\n" + "Inflige " + damage + "% des PV max à tous les ennemis."
