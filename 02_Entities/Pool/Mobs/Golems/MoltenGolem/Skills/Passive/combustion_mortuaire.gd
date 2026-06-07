class_name SE_CombustionMortuaire
extends SkillEffect

# Passif "Combustion mortuaire": à la mort, explose et inflige _stacks stacks d'Ignite à
# tous les ennemis dans un rayon _radius, et joue le VFX d'explosion _death_vfx.

@export var _stacks: float = 90.0
@export var _radius: float = 3.0
@export var _death_vfx: PackedScene


func apply(ctx: SkillContext) -> void:
	var golem: Entity = ctx.entity
	var modifier := DeathModifier.new()
	modifier.id = &"CombustionMortuaire"
	modifier.after_action_logic_callback = func(_cb_vars: Dictionary) -> void:
		_play_death_vfx(golem)
		for enemy: Entity in golem.target.get_targets(TargetComponent.MultipleTargettingStrategy.ENEMIES, _radius):
			golem.alterations.inflict_condition_stacks(enemy, _stacks, Alteration.Type.IGNITE, &"Combustion mortuaire")
	golem.death_modifiers_registry.register_modifier(modifier)


func _play_death_vfx(golem: Entity) -> void:
	if _death_vfx == null:
		return
	var vfx := _death_vfx.instantiate() as Node3D
	if vfx == null:
		return
	golem.get_tree().current_scene.add_child(vfx)
	vfx.global_position = golem.global_position
