class_name SE_TraineeCeleste
extends SkillEffect

# Talent "Traînée céleste": au spawn, applique _ignite stacks d'Ignite à l'ennemi le plus
# proche.

@export var _ignite: float = 15.0


func apply(ctx: SkillContext) -> void:
	var chicken: Entity = ctx.entity
	var enemy: Entity = chicken.target.get_target(TargetComponent.TargettingStrategy.CLOSEST_ENEMY)
	if is_instance_valid(enemy):
		chicken.alterations.inflict_condition_stacks(enemy, _ignite, Alteration.Type.IGNITE, &"Traînée céleste")


func get_description() -> String:
	return "À son apparition, applique " + _value(_ignite) + " [[IGNITE]] à l'ennemi le plus proche."
