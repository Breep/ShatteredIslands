class_name ActionModifiersManager
extends Resource

# Hold all kind of callbacks that wil be called when the entity do something (attack, inflict_condition, heal, move, die, dodge)

var _action_modifiers_dictionaries: Dictionary [ActionModifier.ActionType, ActionModifiersDictionary]

func _init() -> void:
	_action_modifiers_dictionaries = {
		ActionModifier.ActionType.DIRECT_ATTACK: ActionModifiersDictionary.new(),
		ActionModifier.ActionType.INFLICT_CONDITION: ActionModifiersDictionary.new(),
		ActionModifier.ActionType.HEAL: ActionModifiersDictionary.new(),
		ActionModifier.ActionType.DODGE: ActionModifiersDictionary.new(),
	}
	GameManager.game_state_changed.connect(_on_game_manager_game_state_changed)

func register_modifier(action_modifier: ActionModifier) -> void:
	var action_type: ActionModifier.ActionType = action_modifier.action_type
	_action_modifiers_dictionaries[action_type].register_modifier(action_modifier)


func update_modifier(action_modifier: ActionModifier) -> void:
	var action_type: ActionModifier.ActionType = action_modifier.action_type
	_action_modifiers_dictionaries[action_type].update_modifier(action_modifier)


func unregister_modifier(action_modifier: ActionModifier) -> void:
	var action_type: ActionModifier.ActionType = action_modifier.action_type
	_action_modifiers_dictionaries[action_type].unregister_modifier(action_modifier)


func get_all_modifiers(action_type: ActionModifier.ActionType) -> Array[ActionModifier]:
	return _action_modifiers_dictionaries[action_type].get_all_modifiers()


func consume_all_modifiers(action_type: ActionModifier.ActionType) -> Array[ActionModifier]:
	return _action_modifiers_dictionaries[action_type].consume_all_modifiers()
	
# ============================== Private functions ==============================

func _auto_cleanup_all() -> void:
	for smd: ActionModifiersDictionary in _action_modifiers_dictionaries.values():
		smd.auto_cleanup()

# ============================== Callbacks ==============================

func _on_game_manager_game_state_changed(game_state: Game.GameState) -> void:
	match game_state:
		Game.GameState.FIGHTING_FINISHED:
			_auto_cleanup_all()
