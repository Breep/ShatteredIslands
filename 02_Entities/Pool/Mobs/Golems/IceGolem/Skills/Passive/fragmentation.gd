class_name SE_Fragmentation
extends SkillEffect

# Passif "Fragmentation": à la mort, explose et inflige _damage PHYSICAL_DAMAGE + STUN
# _stun_duration s à tous les ennemis dans un rayon _radius.

@export var _damage: float = 200.0
@export var _stun_duration: float = 2.0
@export var _radius: float = 3.0
@export var _death_vfx: PackedScene


func apply(ctx: SkillContext) -> void:
	var golem: Entity = ctx.entity
	var modifier := DeathModifier.new()
	modifier.id = &"Fragmentation"
	modifier.after_action_logic_callback = func(_cb_vars: Dictionary) -> void:
		_play_death_vfx(golem)
		for enemy: Entity in golem.target.get_targets(TargetComponent.MultipleTargettingStrategy.ENEMIES, _radius):
			golem.damage.direct(enemy, _damage, Utils.ActionType.DAMAGE_PHYSICAL, &"Fragmentation")
			golem.alterations.direct_status(enemy, Alteration.Type.STUN, _stun_duration, &"Fragmentation")
	golem.death_modifiers_registry.register_modifier(modifier)


func get_description() -> String:
	return "À sa mort, explose et inflige " + _value(_damage) + " de [[PHYSICAL_DAMAGE]] " \
		+ "+ [[STUN]] " + _value(_stun_duration) + " s à tous les ennemis proches."


func _play_death_vfx(golem: Entity) -> void:
	if _death_vfx == null:
		return
	var vfx := _death_vfx.instantiate() as Node3D
	if vfx == null:
		return
	golem.get_tree().current_scene.add_child(vfx)
	vfx.global_position = golem.global_position
