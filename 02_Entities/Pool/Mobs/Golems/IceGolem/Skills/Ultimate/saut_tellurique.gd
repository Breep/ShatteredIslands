class_name SE_SautTellurique
extends SkillEffect

# Ultimate "Saut tellurique": le golem saute (anim auto) et applique STUN _stun_duration s
# + _damage PHYSICAL_DAMAGE à tous les ennemis dans un rayon _radius.

@export var _damage: float = 100.0
@export var _stun_duration: float = 3.0
@export var _radius: float = 10.0


func apply(ctx: SkillContext) -> void:
	var golem: Entity = ctx.entity
	for enemy: Entity in golem.target.get_targets(TargetComponent.MultipleTargettingStrategy.ENEMIES, _radius):
		if not is_instance_valid(enemy):
			continue
		golem.damage.direct(enemy, _damage, Utils.ActionType.DAMAGE_PHYSICAL, &"Saut tellurique")
		golem.alterations.inflict_status(enemy, Alteration.Type.STUN, _stun_duration, &"Saut tellurique")
