class_name BattleDataStat
extends Resource

signal stat_changed(action_type: Utils.ActionType, value: float)

const ACTION_COLORS: Dictionary[Utils.ActionType, Color] = {
	Utils.ActionType.DAMAGE_PHYSICAL: Color.GRAY,
	Utils.ActionType.DAMAGE_MAGICAL: Color.DARK_BLUE,
	Utils.ActionType.DAMAGE_POISON: Color.DARK_GREEN,
	Utils.ActionType.DAMAGE_PURE: Color.DARK_GOLDENROD,
	Utils.ActionType.UTILITY_HEAL: Color.MEDIUM_AQUAMARINE,
	Utils.ActionType.UTILITY_STUN: Color.WEB_PURPLE,
	Utils.ActionType.UTILITY_CLEANSE: Color.CORAL,
	Utils.ActionType.UTILITY_DISPELL: Color.ORANGE_RED,
	Utils.ActionType.STACK_SHIELD: Color.SADDLE_BROWN,
	Utils.ActionType.STACK_IGNITE: Color.DARK_RED,
	Utils.ActionType.STACK_POISON: Color.DARK_GREEN,
	Utils.ActionType.STACK_REGEN: Color.MEDIUM_AQUAMARINE,
	Utils.ActionType.STACK_NECROSIS: Color.REBECCA_PURPLE
}

const TYPE_NAMES: Dictionary[Type, String] = {
	Type.DAMAGE_DONE: "DAMAGE DONE",
	Type.DAMAGE_RECEIVED: "DAMAGE RECEIVED",
	Type.HEAL_DONE: "HEAL DONE",
	Type.HEAL_RECEIVED: "HEAL RECEIVED",
	Type.STACK_INFLICTED: "STACK INFLICTED",
	Type.STACK_RECEIVED: "STACK RECEIVED",
	Type.MISC_DONE: "MISC DONE",
	Type.MISC_RECEIVED: "MISC RECEIVED"
}

enum Type {
	DAMAGE_DONE,
	DAMAGE_RECEIVED,
	HEAL_DONE,
	HEAL_RECEIVED,
	STACK_INFLICTED,
	STACK_RECEIVED,
	MISC_DONE,
	MISC_RECEIVED
}

enum MetaType {
	ACTION,
	INTERACTION
}

var id: StringName
var type: Type
var action_meters: Dictionary[Utils.ActionType, float]

#region ============================== Node base functions ==============================
func _init(data_id: StringName, data_type: Type) -> void:
	id = data_id
	type = data_type
	for action_type: Utils.ActionType in battle_data_stat_type_to_action_types(data_type):
		action_meters[action_type] = 0.0
#endregion



#region ============================== Public functions ==============================
func register_action(action_type: Utils.ActionType, value: float) -> void:
	if not action_meters.has(action_type):
		push_error("BattleDataStat: Trying to update an incompatible action type stat [", action_type, "]")
		return
	action_meters[action_type] += value
	stat_changed.emit(action_type, value)
#endregion



#region ============================== Static functions ==============================
static func battle_data_stat_type_to_action_types(bds_type: Type) -> Array[Utils.ActionType]:
	match bds_type:
		Type.DAMAGE_DONE:     return [Utils.ActionType.DAMAGE_PHYSICAL, Utils.ActionType.DAMAGE_MAGICAL, Utils.ActionType.DAMAGE_POISON, Utils.ActionType.DAMAGE_PURE]
		Type.DAMAGE_RECEIVED: return [Utils.ActionType.DAMAGE_PHYSICAL, Utils.ActionType.DAMAGE_MAGICAL, Utils.ActionType.DAMAGE_POISON, Utils.ActionType.DAMAGE_PURE]
		Type.HEAL_DONE:     return [Utils.ActionType.UTILITY_HEAL]
		Type.HEAL_RECEIVED: return [Utils.ActionType.UTILITY_HEAL]
		Type.STACK_INFLICTED: return [Utils.ActionType.STACK_SHIELD, Utils.ActionType.STACK_IGNITE, Utils.ActionType.STACK_POISON,
										Utils.ActionType.STACK_REGEN, Utils.ActionType.STACK_NECROSIS]
		Type.STACK_RECEIVED:  return [Utils.ActionType.STACK_SHIELD, Utils.ActionType.STACK_IGNITE, Utils.ActionType.STACK_POISON,
										Utils.ActionType.STACK_REGEN, Utils.ActionType.STACK_NECROSIS]
		Type.MISC_DONE:     return [Utils.ActionType.UTILITY_STUN, Utils.ActionType.UTILITY_CLEANSE, Utils.ActionType.UTILITY_DISPELL]
		Type.MISC_RECEIVED: return [Utils.ActionType.UTILITY_STUN, Utils.ActionType.UTILITY_CLEANSE, Utils.ActionType.UTILITY_DISPELL]
		_: return []


static func action_type_to_battle_data_stat_type(action_type: Utils.ActionType, meta_type: MetaType) -> Type:
	match action_type:
		Utils.ActionType.DAMAGE_PHYSICAL: return Type.DAMAGE_DONE     if meta_type == MetaType.ACTION else Type.DAMAGE_RECEIVED
		Utils.ActionType.DAMAGE_MAGICAL:  return Type.DAMAGE_DONE     if meta_type == MetaType.ACTION else Type.DAMAGE_RECEIVED
		Utils.ActionType.DAMAGE_POISON:   return Type.DAMAGE_DONE     if meta_type == MetaType.ACTION else Type.DAMAGE_RECEIVED
		Utils.ActionType.DAMAGE_PURE:     return Type.DAMAGE_DONE     if meta_type == MetaType.ACTION else Type.DAMAGE_RECEIVED
		Utils.ActionType.UTILITY_HEAL:    return Type.HEAL_DONE       if meta_type == MetaType.ACTION else Type.HEAL_RECEIVED
		Utils.ActionType.UTILITY_STUN:    return Type.MISC_DONE       if meta_type == MetaType.ACTION else Type.MISC_RECEIVED
		Utils.ActionType.UTILITY_CLEANSE: return Type.MISC_DONE       if meta_type == MetaType.ACTION else Type.MISC_RECEIVED
		Utils.ActionType.UTILITY_DISPELL: return Type.MISC_DONE       if meta_type == MetaType.ACTION else Type.MISC_RECEIVED
		Utils.ActionType.STACK_SHIELD:     return Type.STACK_INFLICTED if meta_type == MetaType.ACTION else Type.STACK_RECEIVED
		Utils.ActionType.STACK_IGNITE:    return Type.STACK_INFLICTED if meta_type == MetaType.ACTION else Type.STACK_RECEIVED
		Utils.ActionType.STACK_POISON:    return Type.STACK_INFLICTED if meta_type == MetaType.ACTION else Type.STACK_RECEIVED
		Utils.ActionType.STACK_REGEN:     return Type.STACK_INFLICTED if meta_type == MetaType.ACTION else Type.STACK_RECEIVED
		Utils.ActionType.STACK_NECROSIS:  return Type.STACK_INFLICTED if meta_type == MetaType.ACTION else Type.STACK_RECEIVED
		_:
			push_error("BattleDataStat: action_type_to_battle_data_stat_type() -> Unknown action_type")
			return Type.DAMAGE_DONE
#endregion
