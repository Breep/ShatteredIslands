class_name HeroStats
extends Resource

@export var health_max: int = 2000
@export var mana_max: int = 100
@export var mana_regen: float = 2.0
@export var attack_damage: int = 20
@export var attack_speed: float = 0.5
@export var critical_chances: Dictionary[Utils.ActionType, float] = {
	Utils.ActionType.DAMAGE_PHYSICAL: 50,
	Utils.ActionType.DAMAGE_MAGICAL: 0,
	Utils.ActionType.DAMAGE_POISON: 0,
	Utils.ActionType.UTILITY_HEAL: 0,
	Utils.ActionType.UTILITY_STUN: 0,
	Utils.ActionType.UTILITY_CLEANSE: 0,
	Utils.ActionType.UTILITY_DISPELL: 0,
	Utils.ActionType.STACK_SHIELD: 0,
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
	Utils.ActionType.UTILITY_DISPELL: 100,
	Utils.ActionType.STACK_SHIELD: 100,
	Utils.ActionType.STACK_IGNITE: 100,
	Utils.ActionType.STACK_POISON: 100,
	Utils.ActionType.STACK_REGEN: 100,
	Utils.ActionType.STACK_NECROSIS: 100,
}

@export var resistances: Dictionary[Utils.ActionType, float] = {
	Utils.ActionType.DAMAGE_PHYSICAL: 30,
	Utils.ActionType.DAMAGE_MAGICAL: 0,
	Utils.ActionType.DAMAGE_POISON: 0,
	Utils.ActionType.UTILITY_HEAL: 0,
	Utils.ActionType.UTILITY_STUN: 0,
	Utils.ActionType.UTILITY_CLEANSE: 0,
	Utils.ActionType.UTILITY_DISPELL: 0,
	Utils.ActionType.STACK_SHIELD: 0,
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
	Utils.ActionType.UTILITY_DISPELL: 0,
	Utils.ActionType.STACK_SHIELD: 0,
	Utils.ActionType.STACK_IGNITE: 0,
	Utils.ActionType.STACK_POISON: 0,
	Utils.ActionType.STACK_REGEN: 0,
	Utils.ActionType.STACK_NECROSIS: 0,
}

@export var dodges: Dictionary[Utils.ActionType, float] = {
	Utils.ActionType.DAMAGE_PHYSICAL: 0,
	Utils.ActionType.DAMAGE_MAGICAL: 0,
	Utils.ActionType.DAMAGE_POISON: 0,
	Utils.ActionType.UTILITY_HEAL: 0,
	Utils.ActionType.UTILITY_STUN: 0,
	Utils.ActionType.UTILITY_CLEANSE: 0,
	Utils.ActionType.UTILITY_DISPELL: 0,
	Utils.ActionType.STACK_SHIELD: 0,
	Utils.ActionType.STACK_IGNITE: 0,
	Utils.ActionType.STACK_POISON: 0,
	Utils.ActionType.STACK_REGEN: 0,
	Utils.ActionType.STACK_NECROSIS: 0,
}

@export var strength: Dictionary[Utils.ActionType, float] = {
	Utils.ActionType.DAMAGE_PHYSICAL: 0,
	Utils.ActionType.DAMAGE_MAGICAL: 0,
	Utils.ActionType.DAMAGE_POISON: 0,
	Utils.ActionType.UTILITY_HEAL: 0,
	Utils.ActionType.UTILITY_STUN: 0,
	Utils.ActionType.UTILITY_CLEANSE: 0,
	Utils.ActionType.UTILITY_DISPELL: 0,
	Utils.ActionType.STACK_SHIELD: 0,
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
	Utils.ActionType.UTILITY_DISPELL: 0,
	Utils.ActionType.STACK_SHIELD: 0,
	Utils.ActionType.STACK_IGNITE: 0,
	Utils.ActionType.STACK_POISON: 0,
	Utils.ActionType.STACK_REGEN: 0,
	Utils.ActionType.STACK_NECROSIS: 0,
}

@export var crit_resistances: Dictionary[Utils.ActionType, float] = {
	Utils.ActionType.DAMAGE_PHYSICAL: 0,
	Utils.ActionType.DAMAGE_MAGICAL: 0,
	Utils.ActionType.DAMAGE_POISON: 0,
	Utils.ActionType.UTILITY_HEAL: 0,
	Utils.ActionType.UTILITY_STUN: 0,
	Utils.ActionType.UTILITY_CLEANSE: 0,
	Utils.ActionType.UTILITY_DISPELL: 0,
	Utils.ActionType.STACK_SHIELD: 0,
	Utils.ActionType.STACK_IGNITE: 0,
	Utils.ActionType.STACK_POISON: 0,
	Utils.ActionType.STACK_REGEN: 0,
	Utils.ActionType.STACK_NECROSIS: 0,
}

func apply_json_data(data: Dictionary) -> void:
	for key in data:
		if not key in self:
			continue
		var value = data[key]
		if typeof(value) != TYPE_DICTIONARY:
			set(key, value)
		else:
			var target_dict: Dictionary = get(key)
			var source_dict: Dictionary = value
			for action_name in source_dict:
				if action_name in Utils.ActionType:
					var enum_index = Utils.ActionType[action_name]
					target_dict[enum_index] = source_dict[action_name]
				else:
					push_warning("ActionType inconnu : " + action_name)
