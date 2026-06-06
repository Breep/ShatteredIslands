class_name ProjectileModifier
extends Modifier

enum VarType { # Variable types of the callbacks dictionary
	SOURCE,
	TARGET,
	POSITION,
	DAMAGE,
	DAMAGE_ADD,
	DAMAGE_MUL,
	PROJECTILE
}

var additional_effect: Callable
