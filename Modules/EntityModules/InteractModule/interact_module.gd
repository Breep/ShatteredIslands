class_name InteractModule
extends Module

@export var _defense_manager: DefenseManager

var _dodge_number: int = 0

# ============================== Node base functions ==============================

func _ready() -> void:
	if _defense_manager == null: printerr("InteractModule: Not linked to a DefenseManager [", get_path(), "]")
	GameManager.game_state_changed.connect(_on_game_manager_game_state_changed)

# ============================== Public function ==============================

#region ============================== Damage ==============================
func take_damage(damage: float, damage_type: Utils.DamageType, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	if _owner.stats.health <= 0 or _owner.is_dead: return 0
	var damage_before_armor: float = 0
	if multiplayer.is_server():
		if _is_dodged(Utils.damage_to_action(damage_type)):
			return 0
		damage *= _get_resistance_vulnerability_multiplier(Utils.damage_to_action(damage_type))
		
		damage_before_armor = damage
		if _defense_manager != null: damage = _defense_manager.get_reduced_damage_taken_from_armor(damage, damage_type) # Reduce flat of PHYSIC AND MAGIC damage
		if damage_before_armor - damage > 0:
			_owner.signal_damage_taken(damage_before_armor - damage, damage_type, is_critical, true)
	
	_owner.stats.health -= damage
	if damage > 0 or (damage_before_armor == 0 and damage == 0):
		_owner.signal_damage_taken(damage, damage_type, is_critical, false)
	_owner.signal_interaction_received(source, Utils.damage_to_action(damage_type), action_id, damage, is_critical)
	return damage


func take_damage_percent(damage_percent: float, percent_modifier: Utils.PercentModifier, damage_type: Utils.DamageType, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	if not multiplayer.is_server(): return 0
	var hp: float
	match percent_modifier:
		Utils.PercentModifier.MAX_HP:
			hp = _owner.stats.health_max
		Utils.PercentModifier.CURRENT_HP:
			hp = _owner.stats.health
		Utils.PercentModifier.LOST_HP:
			hp = _owner.stats.health_max - _owner.stats.health
	var damage = hp * damage_percent  / 100.0
	return take_damage(damage, damage_type, is_critical, action_id, source)
#endregion

#region ============================== Condition stacks ==============================
func take_condition_stacks(stacks_number: float, stack_type: Utils.StackType, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	if _owner.stats.health <= 0 or _owner.is_dead: return -1.0
	if _is_dodged(Utils.stack_to_action(stack_type)):
		return 0.0
	stacks_number *= _get_resistance_vulnerability_multiplier(Utils.stack_to_action(stack_type))
	_owner.signal_stack_taken(stack_type, stacks_number, is_critical)
	match stack_type:
		Utils.StackType.POISON:
			_owner.stats.poison_stacks += stacks_number
		Utils.StackType.IGNITE:
			_owner.stats.ignite_stacks += stacks_number
		Utils.StackType.ARMOR:
			_owner.stats.armor_stacks += stacks_number
		Utils.StackType.REGEN:
			_owner.stats.regen_stacks += stacks_number
	_owner.signal_interaction_received(source, Utils.stack_to_action(stack_type), action_id, stacks_number, is_critical)
	return stacks_number
#endregion

#region ============================== Heal ==============================
func take_heal(heal_amount: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	if _owner.stats.health <= 0 or _owner.is_dead: return -1.0
	if _is_dodged(Utils.ActionType.UTILITY_HEAL):
		return 0.0
	heal_amount *= _get_resistance_vulnerability_multiplier(Utils.ActionType.UTILITY_HEAL)
	_owner.stats.health += heal_amount
	_owner.signal_heal_taken(heal_amount, is_critical)
	_owner.signal_interaction_received(source, Utils.ActionType.UTILITY_HEAL, action_id, heal_amount, is_critical)
	return heal_amount
#endregion

#region ============================== Cleanse/Dispell ==============================
# Removes debufs
const CLEANSE_PACK_SIZE: int = 2
func take_cleanse(value: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	var total_to_dispell: int = int(value * _get_resistance_vulnerability_multiplier(Utils.ActionType.UTILITY_CLEANSE))
	if total_to_dispell <= 0:
		return 0.0

	var remaining: int = total_to_dispell
	var removed: int = 0
	while remaining > 0 and _owner.stats.get_debuf_stacks_number() > 0:
		var candidates: Array[Utils.StackType] = []
		if _owner.stats.ignite_stacks > 0: candidates.append(Utils.StackType.IGNITE)
		if _owner.stats.poison_stacks > 0: candidates.append(Utils.StackType.POISON)
		if candidates.is_empty():
			break
		var stack_chosen: Utils.StackType = candidates[randi() % candidates.size()]
		var to_remove: int =  min(CLEANSE_PACK_SIZE, remaining)
		match stack_chosen:
			Utils.StackType.IGNITE:
				to_remove = min(to_remove, _owner.stats.ignite_stacks)
				_owner.stats.ignite_stacks -= to_remove
			Utils.StackType.POISON:
				to_remove = min(to_remove, _owner.stats.poison_stacks)
				_owner.stats.poison_stacks -= to_remove
		remaining -= to_remove
		removed += to_remove
	_owner.signal_interaction_received(source, Utils.ActionType.UTILITY_CLEANSE, action_id, removed, is_critical)
	return float(removed)

# Removes bufs
const DISPELL_PACK_SIZE: int = 2
func take_dispell(value: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	var total_to_dispell: int = int(value * _get_resistance_vulnerability_multiplier(Utils.ActionType.UTILITY_DISPELL))
	if total_to_dispell <= 0:
		return 0.0

	var remaining: int = total_to_dispell
	var removed: int = 0
	while remaining > 0 and _owner.stats.get_buf_stacks_number() > 0:
		var candidates: Array[Utils.StackType] = []
		if _owner.stats.armor_stacks > 0: candidates.append(Utils.StackType.ARMOR)
		if _owner.stats.regen_stacks > 0: candidates.append(Utils.StackType.REGEN)
		if candidates.is_empty():
			break
		var stack_chosen: Utils.StackType = candidates[randi() % candidates.size()]
		var to_remove: int = min(CLEANSE_PACK_SIZE, remaining)
		match stack_chosen:
			Utils.StackType.ARMOR:
				to_remove = min(to_remove, _owner.stats.armor_stacks)
				_owner.stats.armor_stacks -= to_remove
			Utils.StackType.REGEN:
				to_remove = min(to_remove, _owner.stats.regen_stacks)
				_owner.stats.regen_stacks -= to_remove
		remaining -= to_remove
		removed += to_remove
	_owner.signal_interaction_received(source, Utils.ActionType.UTILITY_DISPELL, action_id, removed, is_critical)
	return float(removed)
#endregion

#region ============================== Private functions ==============================
func _is_dodged(action_type: Utils.ActionType) -> bool:
	var dodge_chance: float = _owner.stats.get_stat(EntityStats.StatType.DODGE, action_type)
	if Utils.is_randomize_modifier_active(dodge_chance):
		_dodge_number += 1
		for dodge_modifier: ActionModifier in _owner.action_modifiers_manager.consume_all_modifiers(ActionModifier.ActionType.DODGE):
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
#endregion


#region ============================== Callbacks ==============================
func _on_game_manager_game_state_changed(game_state: Game.GameState) -> void:
	match game_state:
		Game.GameState.FIGHTING_POSITIONING: _dodge_number = 0
#endregion
