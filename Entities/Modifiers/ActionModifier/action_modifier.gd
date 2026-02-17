class_name ActionModifier
extends Node

enum TagType {
	CARD,
	HERO,
	QUEST,
	EVENT
}

enum VarType { # Variable types of the callbacks dictionary
	VISUAL_POS,
	PHYSICAL_DAMAGE,
	STACK_VALUE,
	STACK_TYPE,
	TARGET,
	DODGE_NUMBER,
	HEAL_AMOUNT,
	DURATION
}

enum ActionType {
	DIRECT_ATTACK,
	INFLICT_CONDITION,
	HEAL,
	DODGE,
	UNDEF
}

static func utils_action_to_action_modifier_action(utils_action: Utils.ActionType) -> ActionType: # TODO il faut arreter avec tous ces enums différents qui parlent de la même chose
	match utils_action:
		Utils.ActionType.DAMAGE_PHYSICAL: return ActionType.DIRECT_ATTACK
		Utils.ActionType.DAMAGE_MAGICAL: return ActionType.DIRECT_ATTACK
		Utils.ActionType.DAMAGE_POISON: return ActionType.DIRECT_ATTACK
		Utils.ActionType.DAMAGE_PURE: return ActionType.DIRECT_ATTACK
		Utils.ActionType.UTILITY_HEAL: return ActionType.HEAL
		Utils.ActionType.UTILITY_STUN: return ActionType.UNDEF
		Utils.ActionType.UTILITY_CLEANSE: return ActionType.UNDEF
		Utils.ActionType.UTILITY_DISPELL: return ActionType.UNDEF
		Utils.ActionType.STACK_SHIELD: return ActionType.INFLICT_CONDITION
		Utils.ActionType.STACK_IGNITE: return ActionType.INFLICT_CONDITION
		Utils.ActionType.STACK_POISON: return ActionType.INFLICT_CONDITION
		Utils.ActionType.STACK_REGEN: return ActionType.INFLICT_CONDITION
		Utils.ActionType.STACK_NECROSIS: return ActionType.INFLICT_CONDITION
		Utils.ActionType.STATUS_STUN: return ActionType.UNDEF
		Utils.ActionType.STATUS_TAUNT: return ActionType.UNDEF
		Utils.ActionType.STATUS_SILENCE: return ActionType.UNDEF
		Utils.ActionType.STATUS_INVULNERABLE: return ActionType.UNDEF
		Utils.ActionType.STATUS_UNTARGETABLE: return ActionType.UNDEF
		_: return ActionType.UNDEF

var id: StringName
var action_type: ActionType
var tags: Array[TagType]
var is_one_time_effect: bool = true
var auto_cleanup: bool = true

var before_action_logic_callback := Callable() # var: Dictionary
var after_action_logic_callback := Callable() # var: Dictionary
var visual_callback := Callable() # var: Dictionary
