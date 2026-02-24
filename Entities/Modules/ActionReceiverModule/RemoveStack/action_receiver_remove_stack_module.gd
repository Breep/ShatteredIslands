class_name ActionReceiverRemoveStackModule
extends ActionReceiverModule

const CLEANSE_PACK_SIZE: int = 2
const DISPELL_PACK_SIZE: int = 2

# ============================== Public functions ==============================
#TODO Réfléchir à améliorer l'algo de cleanse/dispell

func take_cleanse(value: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	var total_to_dispell: float = value
	
	if multiplayer.is_server():
		total_to_dispell *= _get_resistance_vulnerability_multiplier(Utils.ActionType.UTILITY_CLEANSE)
	
	var remaining: int = int(total_to_dispell)
	var removed: int = 0
	while remaining >= 1 and _owner.conditions.get_debuff_stacks() >= 1:
		var candidates: Array[Utils.StackType] = []
		if _owner.conditions.ignite_stacks >= 1: candidates.append(Utils.StackType.IGNITE)
		if _owner.conditions.poison_stacks >= 1: candidates.append(Utils.StackType.POISON)
		if _owner.conditions.necrosis_stacks >= 1: candidates.append(Utils.StackType.NECROSIS)
		if candidates.is_empty():
			break
		var stack_chosen: Utils.StackType = candidates[randi() % candidates.size()]
		var to_remove: int = min(CLEANSE_PACK_SIZE, remaining)
		match stack_chosen:
			Utils.StackType.IGNITE:
				to_remove = min(to_remove, _owner.conditions.ignite_stacks)
				_owner.conditions.remove_stack(Stack.Type.IGNITE, to_remove)
			Utils.StackType.POISON:
				to_remove = min(to_remove, _owner.conditions.poison_stacks)
				_owner.conditions.remove_stack(Stack.Type.POISON, to_remove)
			Utils.StackType.NECROSIS:
				to_remove = min(to_remove, _owner.conditions.necrosis_stacks)
				_owner.conditions.remove_stack(Stack.Type.NECROSIS, to_remove)
		remaining -= to_remove
		removed += to_remove
		
		
	_owner.interaction_received.emit(source, Utils.ActionType.UTILITY_CLEANSE, action_id, removed, is_critical)
	return removed


func take_dispell(value: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	var total_to_dispell: float = value
	if multiplayer.is_server():
		total_to_dispell *= value * _get_resistance_vulnerability_multiplier(Utils.ActionType.UTILITY_DISPELL)
	
	var remaining: int = int(total_to_dispell)
	var removed: int = 0
	while remaining >= 1 and _owner.conditions.get_debuff_stacks() >= 1:
		var candidates: Array[Utils.StackType] = []
		if _owner.conditions.shield_stacks >= 1: candidates.append(Utils.StackType.SHIELD)
		if _owner.conditions.regen_stacks >= 1: candidates.append(Utils.StackType.REGEN)
		if candidates.is_empty():
			break
		var stack_chosen: Utils.StackType = candidates[randi() % candidates.size()]
		var to_remove: int = min(DISPELL_PACK_SIZE, remaining)
		match stack_chosen:
			Utils.StackType.SHIELD:
				to_remove = min(to_remove, _owner.conditions.shield_stacks)
				_owner.conditions.remove_stack(Stack.Type.SHIELD, to_remove)
			Utils.StackType.REGEN:
				to_remove = min(to_remove, _owner.conditions.regen_stacks)
				_owner.conditions.remove_stack(Stack.Type.REGEN, to_remove)
		remaining -= to_remove
		removed += to_remove
	
	_owner.interaction_received.emit(source, Utils.ActionType.UTILITY_CLEANSE, action_id, removed, is_critical)
	return removed
