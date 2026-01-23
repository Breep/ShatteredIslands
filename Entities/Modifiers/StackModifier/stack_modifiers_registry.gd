class_name StackModifiersRegistry
extends Resource

# Holds all stack-related modifiers (armor reduction, poison blocking, etc.)

var _stack_modifiers_dictionaries: Dictionary[StackModifier.ModifierType, StackModifiersDictionary]

func _init() -> void:
	_stack_modifiers_dictionaries = {
		StackModifier.ModifierType.ARMOR_REDUCTION: StackModifiersDictionary.new(),
		StackModifier.ModifierType.ARMOR_CONSUMPTION: StackModifiersDictionary.new(),
		StackModifier.ModifierType.POISON_BLOCKING: StackModifiersDictionary.new(),
		StackModifier.ModifierType.STACK_GAIN: StackModifiersDictionary.new(),
		StackModifier.ModifierType.STACK_LOSS: StackModifiersDictionary.new(),
	}
	GameManager.game_state_changed.connect(_on_game_manager_game_state_changed)

func register_modifier(stack_modifier: StackModifier) -> void:
	var modifier_type: StackModifier.ModifierType = stack_modifier.modifier_type
	_stack_modifiers_dictionaries[modifier_type].register_modifier(stack_modifier)


func update_modifier(stack_modifier: StackModifier) -> void:
	var modifier_type: StackModifier.ModifierType = stack_modifier.modifier_type
	_stack_modifiers_dictionaries[modifier_type].update_modifier(stack_modifier)


func unregister_modifier(stack_modifier: StackModifier) -> void:
	var modifier_type: StackModifier.ModifierType = stack_modifier.modifier_type
	_stack_modifiers_dictionaries[modifier_type].unregister_modifier(stack_modifier)


func get_all_modifiers(modifier_type: StackModifier.ModifierType) -> Array[StackModifier]:
	return _stack_modifiers_dictionaries[modifier_type].get_all_modifiers()


func consume_all_modifiers(modifier_type: StackModifier.ModifierType) -> Array[StackModifier]:
	return _stack_modifiers_dictionaries[modifier_type].consume_all_modifiers()
	
# ============================== Private functions ==============================

func _auto_cleanup_all() -> void:
	for smd: StackModifiersDictionary in _stack_modifiers_dictionaries.values():
		smd.auto_cleanup()

# ============================== Callbacks ==============================

func _on_game_manager_game_state_changed(game_state: GameManager.GameState) -> void:
	match game_state:
		GameManager.GameState.ENDING_ROUND:
			_auto_cleanup_all()
