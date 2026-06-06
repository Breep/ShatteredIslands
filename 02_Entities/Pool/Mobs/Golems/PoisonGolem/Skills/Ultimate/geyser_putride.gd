class_name SE_GeyserPutride
extends SkillEffect

# Ultimate "Geyser putride": le golem saute (anim auto) et inflige _stacks stacks de Poison
# à tous les ennemis dans un rayon _radius.

@export var _stacks: float = 90.0
@export var _radius: float = 10.0


func apply(ctx: SkillContext) -> void:
	var golem: Entity = ctx.entity
	for enemy: Entity in golem.target.get_targets(TargetComponent.MultipleTargettingStrategy.ENEMIES, _radius):
		if is_instance_valid(enemy):
			golem.alterations.inflict_condition_stacks(enemy, _stacks, Alteration.Type.POISON, &"Geyser putride")
