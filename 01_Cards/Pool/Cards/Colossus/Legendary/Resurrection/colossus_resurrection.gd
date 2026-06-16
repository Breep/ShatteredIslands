class_name ColossusResurrection
extends CardEffect

## Colossus — à la mort, le héros explose (dégâts AoE en % des PV max), puis
## ressuscite après un délai avec un pourcentage de ses PV max.

const EXPLOSION_VFX_SCENE = preload("res://22_VFX/VFX_Explosion_B.tscn")

@export var _time_before_revive: Array[float]
@export var _damage_percent: Array[float]
@export var _size_increase: Array[float]
@export var _hp_max_revive: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	owner.can_revive = true

	var mod := DeathModifier.new()
	mod.id = card_name
	mod.after_action_logic_callback = func(_cb_vars: Dictionary) -> void:
		var tween = owner.create_tween()

		var start_pos = owner.global_position
		var up_pos = start_pos + Vector3(0, 5, 0)

		var rise_time: float = _time_before_revive[card_lvl - 1]
		tween.tween_property(owner, "global_position", up_pos, rise_time)\
			.set_trans(Tween.TRANS_EXPO)\
			.set_ease(Tween.EASE_OUT)
		tween.tween_property(owner, "global_position", start_pos, 0.2)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_IN)

		await tween.finished
		var hit_marker: Node3D = EXPLOSION_VFX_SCENE.instantiate()
		owner.get_tree().current_scene.add_child(hit_marker)
		hit_marker.global_position = owner.global_position
		var anim_player: AnimationPlayer = hit_marker.get_node("AnimationPlayer")
		if anim_player:
			anim_player.play("Init")
		owner.resurrect(_hp_max_revive[card_lvl - 1])

		var targets: Array[Entity] = owner.target.get_targets(
			TargetComponent.MultipleTargettingStrategy.ENEMIES
		)
		if targets.is_empty():
			return

		var max_hp: float = owner.stats.health_max
		var damage: float = max_hp * (_damage_percent[card_lvl - 1] / 100.0)
		if damage <= 0:
			return

		for target in targets:
			if target != null and is_instance_valid(target):
				owner.damage.direct(target, damage, Utils.ActionType.DAMAGE_PHYSICAL, card_name)

		var size_mod := StatModifier.new()
		size_mod.id = card_name
		size_mod.stat_type = EntityStats.StatType.SCALE
		size_mod.calc_type = StatModifier.CalcType.ADD
		size_mod.value = (_size_increase[card_lvl - 1] / 100)
		owner.stat_modifiers_registry.register_modifier(size_mod)

		# La résurrection (modifier one-shot) est consommée : une prochaine mort
		# doit despawn / éliminer normalement.
		owner.can_revive = false

	owner.death_modifiers_registry.register_modifier(mod)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.can_revive = false
	var mod := DeathModifier.new()
	mod.id = card_name
	ctx.entity_owner.death_modifiers_registry.unregister_modifier(mod)


func get_description(card_lvl: int) -> String:
	var hp: String = str(_hp_max_revive[card_lvl - 1])
	var size: String = str(_size_increase[card_lvl - 1])
	var damage: String = str(_damage_percent[card_lvl - 1])
	var delay: String = str(_time_before_revive[card_lvl - 1])

	return "Ressuscite après " + delay + "s avec " + hp + "% PV" + "Explose et inflige " + damage + "% des PV max en [[PHYSICAL_DAMAGE]] dans une zone.\n" \
