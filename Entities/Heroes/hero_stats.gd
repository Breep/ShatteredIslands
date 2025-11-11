class_name HeroStats
extends Resource

@export var health_max: int = 2000
@export var mana_max: int = 100
@export var mana_regen: float = 2.0
@export var attack_damage: int = 20
@export var attack_speed: float = 0.5
@export var critical_chance: Dictionary[EntityStats.CritType, float] = {
	EntityStats.CritType.ALL: 0.0,
	EntityStats.CritType.ALL_DAMAGE: 0.0,
	EntityStats.CritType.PHYSICAL_DAMAGE: 10.0,
	EntityStats.CritType.MAGICAL_DAMAGE: 0.0,
	EntityStats.CritType.POISON_DAMAGE: 0.0,
	EntityStats.CritType.HEAL: 0.0,
	EntityStats.CritType.STUN: 0.0,
	EntityStats.CritType.CLEANSE: 0.0,
	EntityStats.CritType.PURIFY: 0.0,
	EntityStats.CritType.ALL_STACK: 0.0,
	EntityStats.CritType.ARMOR_STACK: 75.0,
	EntityStats.CritType.IGNITE_STACK: 75.0,
	EntityStats.CritType.POISON_STACK: 75.0,
	EntityStats.CritType.REGEN_STACK: 75.0,
	EntityStats.CritType.NECROSIS_STACK: 0.0
}

@export var critical_multiplier: Dictionary[EntityStats.CritType, float] = {
	EntityStats.CritType.ALL: 0.0,
	EntityStats.CritType.ALL_DAMAGE: 0.0,
	EntityStats.CritType.PHYSICAL_DAMAGE: 100.0,
	EntityStats.CritType.MAGICAL_DAMAGE: 0.0,
	EntityStats.CritType.POISON_DAMAGE: 0.0,
	EntityStats.CritType.HEAL: 0.0,
	EntityStats.CritType.STUN: 0.0,
	EntityStats.CritType.CLEANSE: 0.0,
	EntityStats.CritType.PURIFY: 0.0,
	EntityStats.CritType.ALL_STACK: 0.0,
	EntityStats.CritType.ARMOR_STACK: 100.0,
	EntityStats.CritType.IGNITE_STACK: 100.0,
	EntityStats.CritType.POISON_STACK: 100.0,
	EntityStats.CritType.REGEN_STACK: 100.0,
	EntityStats.CritType.NECROSIS_STACK: 0.0
}
@export var dodge: float
