class_name Spell
extends Node

enum Type {
	METEOR,
	DARK_STORM,
	CONTAGION,
	SHROOM,
	DEATH_FOG,
	LIGHTNING,
	CHAIN_LIGHTNING
}

enum MeteorModifier { DAMAGE_PERCENT, RADIUS, ON_HIT_CALLBACKS }
enum DarkStormModifier { DAMAGE, PERIOD, LIFESPAN, PAIN_STACK_PERCENT }
enum ContagionModifier { RADIUS, SPREAD_PERCENT }
enum ShroomModifier { RADIUS, DAMAGE, LIFE_TIME }
enum DeathFogModifier { GROW_SPEED, TICK_PERIOD, DAMAGE_MULTIPLIER }
enum LightningModifier { DAMAGE }
enum ChainLightningModifier { DAMAGE, BOUNCE_COUNT, BOUNCE_RANGE, DAMAGE_DECAY_PERCENT}
