class_name Status
extends RefCounted

## Status types that can be applied to entities
## Each status has a specific effect on entity behavior

enum Type {
	STUN, # All timers stop
	TAUNT, # Prioritized target for enemies
	SILENCE, # Cannot use spells/projectiles/summons (auto-attack OK)
	INVULNERABLE, # Cannot take damage
	UNTARGETABLE # Cannot be targeted (but can take AOE damage)
}


static func is_negative_status(type: Type) -> bool:
	return type in [Type.STUN, Type.TAUNT, Type.SILENCE]

static func to_action(status_type: Type) -> Utils.ActionType:
	match status_type:
		Type.STUN: return Utils.ActionType.STATUS_STUN
		Type.TAUNT: return Utils.ActionType.STATUS_TAUNT
		Type.SILENCE: return Utils.ActionType.STATUS_SILENCE
		Type.INVULNERABLE: return Utils.ActionType.STATUS_INVULNERABLE
		Type.UNTARGETABLE: return Utils.ActionType.STATUS_UNTARGETABLE
		_: return Utils.ActionType.STACK_POISON
