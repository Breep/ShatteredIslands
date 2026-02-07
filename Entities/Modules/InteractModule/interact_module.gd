class_name InteractModule
extends Module

# ============================== Enums ==============================

enum ResultKey {
	VALUE,              # Damage/heal/stacks received
	IS_CRITICAL,        # Whether the action was critical
	BLOCKED_BY_ARMOR,   # For damage only - was armor applied
	DODGED,             # True if action was dodged
}

var _dodge_number: int = 0

# ============================== Node base functions ==============================

func _ready() -> void:
	GameManager.game_state_changed.connect(_on_game_manager_game_state_changed) #TODO Remove this or add RESET

# ============================== Public function ==============================

#region ============================== Damage ==============================
func take_damage(damage: float, damage_type: Utils.DamageType, is_critical: bool, action_id: StringName, source: Entity = null) -> Dictionary:
	if _owner.stats.health <= 0 or _owner.is_dead(): return {}
	var damage_before_armor: float = 0
	if damage_type != Utils.DamageType.PURE and multiplayer.is_server():
		if _is_dodged(Utils.damage_to_action(damage_type)):
			return {ResultKey.DODGED: true}
		damage *= _get_resistance_vulnerability_multiplier(Utils.damage_to_action(damage_type))
		
		if is_critical:
			damage *= _get_crit_resistance_multiplier(Utils.damage_to_action(damage_type))
		
		damage_before_armor = damage
		damage = _owner.conditions.get_shield_reduced_damage(damage, damage_type) # Reduce flat of PHYSIC AND MAGIC damage


	_owner.stats.health -= damage
	
	return {
		ResultKey.VALUE: damage,
		ResultKey.IS_CRITICAL: is_critical,
		ResultKey.BLOCKED_BY_ARMOR: damage_before_armor > damage,
	}


func take_damage_percent(damage_percent: float, percent_modifier: Utils.PercentModifier, damage_type: Utils.DamageType, is_critical: bool, action_id: StringName, source: Entity = null) -> Dictionary:
	if not multiplayer.is_server():
		Verbose.warn("take_damage_percent() should not be called by clients", Verbose.Category.ENTITY_MODULE)
		return {}
	
	var hp: float
	match percent_modifier:
		Utils.PercentModifier.MAX_HP:
			hp = _owner.stats.health_max
		Utils.PercentModifier.CURRENT_HP:
			hp = _owner.stats.health
		Utils.PercentModifier.LOST_HP:
			hp = _owner.stats.health_max - _owner.stats.health
	var damage = hp * damage_percent / 100.0
	return take_damage(damage, damage_type, is_critical, action_id, source)
#endregion


#region ============================== Condition stacks ==============================
func take_condition_stacks(stacks_number: float, stack_type: Utils.StackType, is_critical: bool, action_id: StringName, source: Entity = null, duration: float = 5.0) -> Dictionary:
	if _owner.stats.health <= 0 or _owner.is_dead(): return {}
	if multiplayer.is_server():
		if _is_dodged(Utils.stack_to_action(stack_type)):
			return {ResultKey.DODGED: true}
		stacks_number *= _get_resistance_vulnerability_multiplier(Utils.stack_to_action(stack_type))
	
	var stack_enum: Stack.Type = _utils_stack_to_stack_type(stack_type)
	var mod: Dictionary = {}
	if stack_type == Utils.StackType.REGEN:
		mod[Stack.ModifierType.DURATION] = int(duration)
	_owner.conditions.add_stack(stack_enum, stacks_number, source, action_id, mod)
	
	return {
		ResultKey.VALUE: stacks_number,
		ResultKey.IS_CRITICAL: is_critical,
	}
#endregion


#region ============================== Heal ==============================
func take_heal(heal_amount: float, is_critical: bool, action_id: StringName, source: Entity = null) -> Dictionary:
	if _owner.stats.health <= 0 or _owner.is_dead(): return {}
	if multiplayer.is_server():
		if _is_dodged(Utils.ActionType.UTILITY_HEAL):
			return {ResultKey.DODGED: true}
		heal_amount *= _get_resistance_vulnerability_multiplier(Utils.ActionType.UTILITY_HEAL)
	
	# Necrosis logic
	var necrosis_stacks: float = _owner.conditions.necrosis_stacks
	var absorbed_by_necrosis: float = 0.0
	if necrosis_stacks > 0:
		absorbed_by_necrosis = min(heal_amount, necrosis_stacks)
		_owner.conditions.remove_stack(Stack.Type.NECROSIS, absorbed_by_necrosis)
		heal_amount -= absorbed_by_necrosis

	var initial_health: float = _owner.stats.health
	if heal_amount > 0:
		_owner.stats.health += heal_amount
	
	var effective_heal: float = _owner.stats.health - initial_health
	
	return {
		ResultKey.VALUE: effective_heal,
		ResultKey.IS_CRITICAL: is_critical,
	}
#endregion

#region ============================== Cleanse/Dispell ==============================
# Removes debufs
const CLEANSE_PACK_SIZE: int = 2
func take_cleanse(value: float, is_critical: bool, action_id: StringName, source: Entity = null) -> Dictionary:
	var total_to_dispell: float = value
	
	if multiplayer.is_server():
		total_to_dispell *= _get_resistance_vulnerability_multiplier(Utils.ActionType.UTILITY_CLEANSE)
	
	var remaining: int = int(total_to_dispell)
	var removed: int = 0
	while remaining > 0 and _owner.conditions.get_debuff_stacks() > 0:
		var candidates: Array[Utils.StackType] = []
		if _owner.conditions.ignite_stacks > 0: candidates.append(Utils.StackType.IGNITE)
		if _owner.conditions.poison_stacks > 0: candidates.append(Utils.StackType.POISON)
		if _owner.conditions.necrosis_stacks > 0: candidates.append(Utils.StackType.NECROSIS)
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
	
	return {
		ResultKey.VALUE: float(removed),
		ResultKey.IS_CRITICAL: is_critical,
	}

# Removes bufs
const DISPELL_PACK_SIZE: int = 2
func take_dispell(value: float, is_critical: bool, action_id: StringName, source: Entity = null) -> Dictionary:
	var total_to_dispell: float = value
	if multiplayer.is_server():
		total_to_dispell *= value * _get_resistance_vulnerability_multiplier(Utils.ActionType.UTILITY_DISPELL)
	
	var remaining: int = int(total_to_dispell)
	var removed: int = 0
	while remaining > 0 and _owner.conditions.get_buff_stacks() > 0:
		var candidates: Array[Utils.StackType] = []
		if _owner.conditions.shield_stacks > 0: candidates.append(Utils.StackType.SHIELD)
		if _owner.conditions.regen_stacks > 0: candidates.append(Utils.StackType.REGEN)
		if candidates.is_empty():
			break
		var stack_chosen: Utils.StackType = candidates[randi() % candidates.size()]
		var to_remove: int = min(CLEANSE_PACK_SIZE, remaining)
		match stack_chosen:
			Utils.StackType.SHIELD:
				to_remove = min(to_remove, _owner.conditions.shield_stacks)
				_owner.conditions.remove_stack(Stack.Type.SHIELD, to_remove)
			Utils.StackType.REGEN:
				to_remove = min(to_remove, _owner.conditions.regen_stacks)
				_owner.conditions.remove_stack(Stack.Type.REGEN, to_remove)
		remaining -= to_remove
		removed += to_remove
	
	return {
		ResultKey.VALUE: float(removed),
		ResultKey.IS_CRITICAL: is_critical,
	}
#endregion

#region ============================== Private functions ==============================
func _is_dodged(action_type: Utils.ActionType) -> bool:
	var dodge_chance: float = _owner.stats.get_stat(EntityStats.StatType.DODGE, action_type)
	if Utils.is_randomize_modifier_active(dodge_chance):
		_dodge_number += 1
		for dodge_modifier: ActionModifier in _owner.action_modifiers_registry.consume_all_modifiers(ActionModifier.ActionType.DODGE):
			if dodge_modifier.after_action_logic_callback.is_valid():
				dodge_modifier.after_action_logic_callback.call({
					ActionModifier.VarType.DODGE_NUMBER: _dodge_number
				})
		return true
	return false


func _get_resistance_vulnerability_multiplier(action_type: Utils.ActionType) -> float:
	var res: float = _owner.stats.get_stat(EntityStats.StatType.RESISTANCE, action_type)
	var vuln: float = _owner.stats.get_stat(EntityStats.StatType.VULNERABILITY, action_type)
	return (100 + vuln) / (100 + res)

func _get_crit_resistance_multiplier(action_type: Utils.ActionType) -> float:
	var res: float = _owner.stats.get_stat(EntityStats.StatType.CRIT_RESISTANCE, action_type)
	# Assuming standard resistance formula: 100 / (100 + res)
	# If we want to support "Crit Vulnerability" later, we could add it here too.
	return 100.0 / (100.0 + res)


## Helper to convert Utils.StackType to Stack.Type
func _utils_stack_to_stack_type(utils_type: Utils.StackType) -> Stack.Type:
	match utils_type:
		Utils.StackType.POISON: return Stack.Type.POISON
		Utils.StackType.IGNITE: return Stack.Type.IGNITE
		Utils.StackType.SHIELD: return Stack.Type.SHIELD
		Utils.StackType.REGEN: return Stack.Type.REGEN
		Utils.StackType.NECROSIS: return Stack.Type.NECROSIS
		_:
			printerr("InteractModule: Unknown Utils.StackType [", utils_type, "]")
			return Stack.Type.POISON
#endregion


#region ============================== Callbacks ==============================
func _on_game_manager_game_state_changed(game_state: GameManager.GameState) -> void:
	match game_state:
		GameManager.GameState.FIGHTING: _dodge_number = 0
#endregion
