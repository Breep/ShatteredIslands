class_name HeroStats
extends Resource

@export var health_max: int = 2000
@export var mana_max: int = 100
@export var mana_regen: float = 2.0
@export var attack_damage: int = 20
@export var attack_speed: float = 0.5
@export var critical_chances: Dictionary[Utils.ActionType, float] = {
	Utils.ActionType.DAMAGE_PHYSICAL: 15,
	Utils.ActionType.DAMAGE_MAGICAL: 0,
	Utils.ActionType.DAMAGE_POISON: 0,
	Utils.ActionType.UTILITY_HEAL: 0,
	Utils.ActionType.UTILITY_STUN: 0,
	Utils.ActionType.UTILITY_CLEANSE: 0,
	Utils.ActionType.UTILITY_PURIFY: 0,
	Utils.ActionType.STACK_ARMOR: 0,
	Utils.ActionType.STACK_IGNITE: 0,
	Utils.ActionType.STACK_POISON: 0,
	Utils.ActionType.STACK_REGEN: 0,
	Utils.ActionType.STACK_NECROSIS: 0,
}

@export var critical_multipliers: Dictionary[Utils.ActionType, float] = {
	Utils.ActionType.DAMAGE_PHYSICAL: 100,
	Utils.ActionType.DAMAGE_MAGICAL: 100,
	Utils.ActionType.DAMAGE_POISON: 100,
	Utils.ActionType.UTILITY_HEAL: 100,
	Utils.ActionType.UTILITY_STUN: 100,
	Utils.ActionType.UTILITY_CLEANSE: 100,
	Utils.ActionType.UTILITY_PURIFY: 100,
	Utils.ActionType.STACK_ARMOR: 100,
	Utils.ActionType.STACK_IGNITE: 100,
	Utils.ActionType.STACK_POISON: 100,
	Utils.ActionType.STACK_REGEN: 100,
	Utils.ActionType.STACK_NECROSIS: 100,
}

@export var resistances: Dictionary[Utils.ActionType, float] = {
	Utils.ActionType.DAMAGE_PHYSICAL: 50,
	Utils.ActionType.DAMAGE_MAGICAL: 0,
	Utils.ActionType.DAMAGE_POISON: 80,
	Utils.ActionType.UTILITY_HEAL: 0,
	Utils.ActionType.UTILITY_STUN: 0,
	Utils.ActionType.UTILITY_CLEANSE: 0,
	Utils.ActionType.UTILITY_PURIFY: 0,
	Utils.ActionType.STACK_ARMOR: 0,
	Utils.ActionType.STACK_IGNITE: 0,
	Utils.ActionType.STACK_POISON: 0,
	Utils.ActionType.STACK_REGEN: 0,
	Utils.ActionType.STACK_NECROSIS: 0,
}

@export var vulnerabilities: Dictionary[Utils.ActionType, float] = {
	Utils.ActionType.DAMAGE_PHYSICAL: 0,
	Utils.ActionType.DAMAGE_MAGICAL: 0,
	Utils.ActionType.DAMAGE_POISON: 0,
	Utils.ActionType.UTILITY_HEAL: 0,
	Utils.ActionType.UTILITY_STUN: 0,
	Utils.ActionType.UTILITY_CLEANSE: 0,
	Utils.ActionType.UTILITY_PURIFY: 0,
	Utils.ActionType.STACK_ARMOR: 0,
	Utils.ActionType.STACK_IGNITE: 0,
	Utils.ActionType.STACK_POISON: 0,
	Utils.ActionType.STACK_REGEN: 0,
	Utils.ActionType.STACK_NECROSIS: 0,
}

@export var dodges: Dictionary[Utils.ActionType, float] = {
	Utils.ActionType.DAMAGE_PHYSICAL: 50,
	Utils.ActionType.DAMAGE_MAGICAL: 0,
	Utils.ActionType.DAMAGE_POISON: 0,
	Utils.ActionType.UTILITY_HEAL: 0,
	Utils.ActionType.UTILITY_STUN: 0,
	Utils.ActionType.UTILITY_CLEANSE: 0,
	Utils.ActionType.UTILITY_PURIFY: 0,
	Utils.ActionType.STACK_ARMOR: 0,
	Utils.ActionType.STACK_IGNITE: 0,
	Utils.ActionType.STACK_POISON: 0,
	Utils.ActionType.STACK_REGEN: 0,
	Utils.ActionType.STACK_NECROSIS: 0,
}

@export var strenght: Dictionary[Utils.ActionType, float] = {
	Utils.ActionType.DAMAGE_PHYSICAL: 0,
	Utils.ActionType.DAMAGE_MAGICAL: 0,
	Utils.ActionType.DAMAGE_POISON: 0,
	Utils.ActionType.UTILITY_HEAL: 0,
	Utils.ActionType.UTILITY_STUN: 0,
	Utils.ActionType.UTILITY_CLEANSE: 0,
	Utils.ActionType.UTILITY_PURIFY: 0,
	Utils.ActionType.STACK_ARMOR: 0,
	Utils.ActionType.STACK_IGNITE: 0,
	Utils.ActionType.STACK_POISON: 0,
	Utils.ActionType.STACK_REGEN: 0,
	Utils.ActionType.STACK_NECROSIS: 0,
}

@export var weakness: Dictionary[Utils.ActionType, float] = {
	Utils.ActionType.DAMAGE_PHYSICAL: 0,
	Utils.ActionType.DAMAGE_MAGICAL: 0,
	Utils.ActionType.DAMAGE_POISON: 0,
	Utils.ActionType.UTILITY_HEAL: 0,
	Utils.ActionType.UTILITY_STUN: 0,
	Utils.ActionType.UTILITY_CLEANSE: 0,
	Utils.ActionType.UTILITY_PURIFY: 0,
	Utils.ActionType.STACK_ARMOR: 0,
	Utils.ActionType.STACK_IGNITE: 0,
	Utils.ActionType.STACK_POISON: 0,
	Utils.ActionType.STACK_REGEN: 0,
	Utils.ActionType.STACK_NECROSIS: 0,
}
