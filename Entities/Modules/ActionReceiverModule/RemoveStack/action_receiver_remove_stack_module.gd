class_name ActionReceiverRemoveStackModule
extends ActionReceiverModule

const CLEANSE_PACK_SIZE: int = 2
const DISPELL_PACK_SIZE: int = 2

# ============================== Public functions ==============================
#TODO Réfléchir à améliorer l'algo de cleanse/dispell

func take_cleanse(value: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	var total_to_dispell: float = value
	
	if multiplayer.is_server():
		total_to_dispell *= _get_resistance_exposure_multiplier(Utils.ActionType.UTILITY_CLEANSE)
	
	var remaining: int = int(total_to_dispell)
	var removed: int = 0
	while remaining > _owner.alterations_module.get_debuff_stacks():
		var candidates: Array[Stack.Type] = []
		if _owner.alterations_module.ignite_stacks >= 1: candidates.append(Stack.Type.IGNITE)
		if _owner.alterations_module.poison_stacks >= 1: candidates.append(Stack.Type.POISON)
		if _owner.alterations_module.necrosis_stacks >= 1: candidates.append(Stack.Type.NECROSIS)
		if candidates.is_empty():
			break
		var stack_chosen: Stack.Type = candidates[randi() % candidates.size()]
		var to_remove: int = min(CLEANSE_PACK_SIZE, remaining)
		match stack_chosen:
			Stack.Type.IGNITE:
				to_remove = min(to_remove, _owner.alterations_module.ignite_stacks)
				_owner.alterations_module.remove_stack(Stack.Type.IGNITE, to_remove)
			Stack.Type.POISON:
				to_remove = min(to_remove, _owner.alterations_module.poison_stacks)
				_owner.alterations_module.remove_stack(Stack.Type.POISON, to_remove)
			Stack.Type.NECROSIS:
				to_remove = min(to_remove, _owner.alterations_module.necrosis_stacks)
				_owner.alterations_module.remove_stack(Stack.Type.NECROSIS, to_remove)
		remaining -= to_remove
		removed += to_remove
	
	_owner.action_received.emit(source, Utils.ActionType.UTILITY_CLEANSE, action_id, removed, is_critical)
	return removed


func take_dispell(value: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	var total_to_dispell: float = value
	if multiplayer.is_server():
		total_to_dispell *= value * _get_resistance_exposure_multiplier(Utils.ActionType.UTILITY_DISPELL)
	
	var remaining: int = int(total_to_dispell)
	var removed: int = 0
	while remaining > _owner.alterations_module.get_buff_stacks():
		var candidates: Array[Stack.Type] = []
		if _owner.alterations_module.shield_stacks >= 1: candidates.append(Stack.Type.SHIELD)
		if _owner.alterations_module.regen_stacks >= 1: candidates.append(Stack.Type.REGEN)
		if candidates.is_empty():
			break
		var stack_chosen: Stack.Type = candidates[randi() % candidates.size()]
		var to_remove: int = min(DISPELL_PACK_SIZE, remaining)
		match stack_chosen:
			Stack.Type.SHIELD:
				to_remove = min(to_remove, _owner.alterations_module.shield_stacks)
				_owner.alterations_module.remove_stack(Stack.Type.SHIELD, to_remove)
			Stack.Type.REGEN:
				to_remove = min(to_remove, _owner.alterations_module.regen_stacks)
				_owner.alterations_module.remove_stack(Stack.Type.REGEN, to_remove)
		remaining -= to_remove
		removed += to_remove
	
	_owner.action_received.emit(source, Utils.ActionType.UTILITY_CLEANSE, action_id, removed, is_critical)
	return removed
