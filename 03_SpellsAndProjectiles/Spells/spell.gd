class_name Spell
extends Node3D

var spells_node: Node3D

enum Type {
	DARK_STORM = 1,
	CONTAGION = 2,
	SHROOM = 3,
	DEATH_FOG = 4,
	LIGHTNING = 5,
	CHAIN_LIGHTNING = 6,
	CLEAVE = 7,
	GOBLIN_FOCUS = 8,
	CLEARING_OF_LIFE = 9,
	FIRE_GROUND = 10,
}

enum DarkStormModifier { DAMAGE, PERIOD, LIFESPAN, PAIN_STACK_PERCENT }
enum ContagionModifier { RADIUS, SPREAD_PERCENT }
enum ShroomModifier { RADIUS, DAMAGE, LIFE_TIME }
enum DeathFogModifier { GROW_SPEED, TICK_PERIOD, DAMAGE_MULTIPLIER }
enum LightningModifier { DAMAGE }
enum ChainLightningModifier { DAMAGE, BOUNCE_COUNT, BOUNCE_RANGE, DAMAGE_DECAY_PERCENT}
enum FireGroundModifier { POSITION, RADIUS, DURATION, IGNITE_PER_TICK, TICK_PERIOD }
