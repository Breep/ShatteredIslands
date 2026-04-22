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
		var candidates: Array[Alteration.Type] = []
		if _owner.alterations_module.ignite_stacks >= 1: candidates.append(Alteration.Type.IGNITE)
		if _owner.alterations_module.poison_stacks >= 1: candidates.append(Alteration.Type.POISON)
		if _owner.alterations_module.necrosis_stacks >= 1: candidates.append(Alteration.Type.NECROSIS)
		if candidates.is_empty():
			break
		var stack_chosen: Alteration.Type = candidates[randi() % candidates.size()]
		var to_remove: int = min(CLEANSE_PACK_SIZE, remaining)
		match stack_chosen:
			Alteration.Type.IGNITE:
				to_remove = min(to_remove, _owner.alterations_module.ignite_stacks)
				_owner.alterations_module.remove_stack(Alteration.Type.IGNITE, to_remove)
			Alteration.Type.POISON:
				to_remove = min(to_remove, _owner.alterations_module.poison_stacks)
				_owner.alterations_module.remove_stack(Alteration.Type.POISON, to_remove)
			Alteration.Type.NECROSIS:
				to_remove = min(to_remove, _owner.alterations_module.necrosis_stacks)
				_owner.alterations_module.remove_stack(Alteration.Type.NECROSIS, to_remove)
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
		var candidates: Array[Alteration.Type] = []
		if _owner.alterations_module.shield_stacks >= 1: candidates.append(Alteration.Type.SHIELD)
		if _owner.alterations_module.regen_stacks >= 1: candidates.append(Alteration.Type.REGEN)
		if candidates.is_empty():
			break
		var stack_chosen: Alteration.Type = candidates[randi() % candidates.size()]
		var to_remove: int = min(DISPELL_PACK_SIZE, remaining)
		match stack_chosen:
			Alteration.Type.SHIELD:
				to_remove = min(to_remove, _owner.alterations_module.shield_stacks)
				_owner.alterations_module.remove_stack(Alteration.Type.SHIELD, to_remove)
			Alteration.Type.REGEN:
				to_remove = min(to_remove, _owner.alterations_module.regen_stacks)
				_owner.alterations_module.remove_stack(Alteration.Type.REGEN, to_remove)
		remaining -= to_remove
		removed += to_remove
	
	_owner.action_received.emit(source, Utils.ActionType.UTILITY_CLEANSE, action_id, removed, is_critical)
	return removed
