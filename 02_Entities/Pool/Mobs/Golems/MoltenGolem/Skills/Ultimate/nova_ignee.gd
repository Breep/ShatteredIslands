class_name SE_NovaIgnee
extends SkillEffect

# Ultimate "Nova ignée": le golem saute (anim auto) puis, à l'atterrissage, inflige _stacks
# stacks d'Ignite à tous les ennemis dans un rayon _radius. L'impact est retardé de
# _impact_delay s (horloge déterministe) pour tomber sur la frame de réception du saut.

const _IMPACT_ID: StringName = &"Nova ignée"

@export var _stacks: float = 90.0
@export var _radius: float = 10.0
@export var _impact_delay: float = 1.466
@export var _impact_vfx: PackedScene


func apply(ctx: SkillContext) -> void:
	var golem: Entity = ctx.entity
	golem.battle_callback_registry.register_oneshot(_impact_delay, func() -> void:
		if not is_instance_valid(golem) or golem.is_dead(): return
		_spawn_impact_vfx(golem)
		for enemy: Entity in golem.target.get_targets(TargetComponent.MultipleTargettingStrategy.ENEMIES, _radius):
			if is_instance_valid(enemy):
				golem.alterations.inflict_condition_stacks(enemy, _stacks, Alteration.Type.IGNITE, _IMPACT_ID)
	, _IMPACT_ID)


func _spawn_impact_vfx(golem: Entity) -> void:
	if _impact_vfx == null:
		return
	var vfx := _impact_vfx.instantiate() as Node3D
	if vfx == null:
		return
	golem.get_tree().current_scene.add_child(vfx)
	vfx.global_position = golem.global_position


func get_description() -> String:
	return "Bondit puis, à l'atterrissage, applique " + _value(_stacks) + " stacks " \
		+ "d'[[IGNITE]] à tous les ennemis proches."
