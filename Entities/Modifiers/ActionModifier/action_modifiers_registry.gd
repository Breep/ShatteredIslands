class_name ActionModifiersRegistry
extends Resource

# Hold all kind of callbacks that wil be called when the entity do something (attack, inflict_condition, heal, move, die, dodge)

var _action_modifiers_dictionaries: Dictionary [Utils.ActionCategory, ActionModifiersDictionary]

func _init() -> void:
	_action_modifiers_dictionaries = {
		Utils.ActionCategory.DAMAGE: ActionModifiersDictionary.new(),
		Utils.ActionCategory.STACK: ActionModifiersDictionary.new(),
		Utils.ActionCategory.HEAL: ActionModifiersDictionary.new(),
		Utils.ActionCategory.DODGE: ActionModifiersDictionary.new(),
	}
	GameManager.game_state_changed.connect(_on_game_manager_game_state_changed)

func register_modifier(action_modifier: ActionModifier) -> void:
	var action_type: Utils.ActionCategory = action_modifier.action_type
	_action_modifiers_dictionaries[action_type].register_modifier(action_modifier)


func update_modifier(action_modifier: ActionModifier) -> void:
	var action_type: Utils.ActionCategory = action_modifier.action_type
	_action_modifiers_dictionaries[action_type].update_modifier(action_modifier)


func unregister_modifier(action_modifier: ActionModifier) -> void:
	var action_type: Utils.ActionCategory = action_modifier.action_type
	_action_modifiers_dictionaries[action_type].unregister_modifier(action_modifier)


func get_all_modifiers(action_type: Utils.ActionCategory) -> Array[ActionModifier]:
	return _action_modifiers_dictionaries[action_type].get_all_modifiers()


func consume_all_modifiers(action_type: Utils.ActionCategory) -> Array[ActionModifier]:
	return _action_modifiers_dictionaries[action_type].consume_all_modifiers()
	
# ============================== Private functions ==============================

func _auto_cleanup_all() -> void:
	for smd: ActionModifiersDictionary in _action_modifiers_dictionaries.values():
		smd.auto_cleanup()

# ============================== Callbacks ==============================

func _on_game_manager_game_state_changed(game_state: GameManager.GameState) -> void:
	match game_state:
		GameManager.GameState.ENDING_ROUND:
			_auto_cleanup_all()
