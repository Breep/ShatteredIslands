class_name Status
extends RefCounted

## Status types that can be applied to entities
## Each status has a specific effect on entity behavior

enum Type {
	STUN,          # All timers stop
	TAUNT,         # Prioritized target for enemies
	SILENCE,       # Cannot use spells/projectiles/summons (auto-attack OK)
	INVULNERABLE,  # Cannot take damage
	UNTARGETABLE   # Cannot be targeted (but can take AOE damage)
}
