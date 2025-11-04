class_name Spell
extends Node

enum Type {
	METEOR,
	DARK_STORM,
	CONTAGION
}

enum MeteorModifier {
	IGNITE_STACKS,
	DAMAGE_PER_STACK
}

enum DarkStormModifier {
	DAMAGE,
	PERIOD,
	LIFESPAN,
	PAIN_STACK_PERCENT
}

enum ContagionModifier {
	RADIUS,
	SPREAD_PERCENT
}
