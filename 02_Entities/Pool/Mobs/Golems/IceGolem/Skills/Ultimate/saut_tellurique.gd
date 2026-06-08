class_name SE_SautTellurique
extends SkillEffect

# Ultimate "Saut tellurique": le golem saute (anim auto) puis, à l'atterrissage, applique
# STUN _stun_duration s + _damage PHYSICAL_DAMAGE à tous les ennemis dans un rayon _radius.
# L'impact est retardé de _impact_delay s (horloge déterministe) pour tomber sur la frame
# de réception du saut — cf. timing JumpStart + JumpEnd de l'anim.

const _IMPACT_ID: StringName = &"Saut tellurique"

@export var _damage: float = 100.0
@export var _stun_duration: float = 3.0
@export var _radius: float = 10.0
@export var _impact_delay: float = 1.466


func apply(ctx: SkillContext) -> void:
	var golem: Entity = ctx.entity
	golem.battle_callback_registry.register_oneshot(_impact_delay, func() -> void:
		if not is_instance_valid(golem) or golem.is_dead(): return
		for enemy: Entity in golem.target.get_targets(TargetComponent.MultipleTargettingStrategy.ENEMIES, _radius):
			if not is_instance_valid(enemy):
				continue
			golem.damage.direct(enemy, _damage, Utils.ActionType.DAMAGE_PHYSICAL, _IMPACT_ID)
			golem.alterations.inflict_status(enemy, Alteration.Type.STUN, _stun_duration, _IMPACT_ID)
	, _IMPACT_ID)
