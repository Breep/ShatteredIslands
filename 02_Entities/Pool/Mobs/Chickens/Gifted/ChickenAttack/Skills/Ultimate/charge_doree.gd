class_name SE_ChargeDoree
extends SkillEffect

# Ultimate "Charge dorée": bondit sur la cible (anim auto) et inflige AD x _ad_mult dégâts
# physiques.

@export var _ad_mult: float = 2.5


func apply(ctx: SkillContext) -> void:
	var chicken: Entity = ctx.entity
	var target: Entity = chicken.auto_attack.get_current_target() if chicken.auto_attack != null else null
	if not is_instance_valid(target):
		target = chicken.target.get_target(TargetComponent.TargettingStrategy.CLOSEST_ENEMY)
	if not is_instance_valid(target):
		return
	var damage: float = chicken.stats.get_stat(EntityStats.StatType.AD) * _ad_mult
	chicken.damage.direct(target, damage, Utils.ActionType.DAMAGE_PHYSICAL, &"Charge dorée")
