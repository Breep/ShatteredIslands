class_name SE_PluieDeBraises
extends SkillEffect

# Ultimate "Pluie de braises": inflige AP x _damage_ratio dégâts magiques à la cible et lui
# applique AP x _ignite_ratio Ignite.

@export var _damage_ratio: float = 1.8
@export var _ignite_ratio: float = 1.0


func apply(ctx: SkillContext) -> void:
	var phoenix: Entity = ctx.entity
	var target: Entity = phoenix.auto_attack.get_current_target() if phoenix.auto_attack != null else null
	if not is_instance_valid(target):
		target = phoenix.target.get_target(TargetComponent.TargettingStrategy.CLOSEST_ENEMY)
	if not is_instance_valid(target):
		return
	var ap: float = phoenix.stats.get_stat(EntityStats.StatType.AP)
	phoenix.damage.direct(target, ap * _damage_ratio, Utils.ActionType.DAMAGE_MAGICAL, &"Pluie de braises")
	phoenix.alterations.direct_stack(target, ap * _ignite_ratio, Alteration.Type.IGNITE, &"Pluie de braises")


func get_description() -> String:
	return "Inflige à la cible des [[MAGICAL_DAMAGE]] égaux à " + _value(_damage_ratio * 100) \
		+ "% de sa puissance magique et lui applique des stacks d'[[IGNITE]] égaux à " \
		+ _value(_ignite_ratio * 100) + "%."
