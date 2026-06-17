class_name SE_Maintenance
extends SkillEffect

# Talent "Maintenance": au spawn, donne +_mana Mana à un bâtiment allié aléatoire.

@export var _mana: float = 2.0


func apply(ctx: SkillContext) -> void:
	var chicken: Entity = ctx.entity
	var building: Entity = chicken.target.get_target(TargetComponent.TargettingStrategy.RANDOM_BUILDING_ALLY)
	if is_instance_valid(building):
		building.stats.mana += _mana


func get_description() -> String:
	return "À son apparition, donne +" + _value(_mana) + " [[MANA]] à un bâtiment allié aléatoire."
