extends Node

@export var entity_owner: Entity

@onready var _entity_name_label: Label = %EntityNameLabel

@onready var _direct_attack_edit: TextEdit = %DirectAttackEdit
@onready var _direct_attack_percent_edit: TextEdit = %DirectAttackPercentEdit
@onready var _heal_edit: TextEdit = %HealEdit
@onready var _heal_percent_edit: TextEdit = %HealPercentEdit
@onready var _inflict_condition_edit: TextEdit = %InflictConditionEdit
@onready var _cleanse_dispell_edit: TextEdit = %CleanseDispellEdit

@onready var _damage_choice: OptionButton = %DamageChoice
@onready var _damage_choice_percent: OptionButton = %DamageChoicePercent
@onready var _stack_type_choice: OptionButton = %StackTypeChoice
@onready var _percent_modifier_choice: OptionButton = %PercentModifierChoice
@onready var _health_percent_modifier_choice: OptionButton = %HealthPercentModifierChoice

@onready var _targeting_strat_choice: OptionButton = %TargetingStratChoice
@onready var _target_label: RichTextLabel = %TargetLabel

var _target: Entity

func _ready() -> void:
	# Clear all dropdowns to prevent duplicates
	_targeting_strat_choice.clear()
	_damage_choice.clear()
	_damage_choice_percent.clear()
	_stack_type_choice.clear()
	_percent_modifier_choice.clear()
	_health_percent_modifier_choice.clear()
	
	# Populate targeting strategy dropdown
	var i: int = 0
	for targeting_strategy: String in TargetModule.TargettingStrategy.keys():
		_targeting_strat_choice.add_item(targeting_strategy, i)
		i += 1
	
	# Populate damage type dropdowns
	i = 0
	for damage_type: String in Utils.DamageType.keys():
		_damage_choice.add_item(damage_type, i)
		_damage_choice_percent.add_item(damage_type, i)
		i += 1
	
	# Populate stack type dropdown
	i = 0
	for stack_type: String in Utils.StackType.keys():
		_stack_type_choice.add_item(stack_type, i)
		i += 1
	
	# Populate percent modifier dropdown
	i = 0
	for percent_modifier: String in Utils.PercentModifier.keys():
		_percent_modifier_choice.add_item(percent_modifier, i)
		i += 1
	
	# Populate health percent modifier dropdown
	i = 0
	for health_percent_modifier: String in Utils.PercentModifier.keys():
		_health_percent_modifier_choice.add_item(health_percent_modifier, i)
		i += 1
	
	if entity_owner != null:
		_entity_name_label.text = entity_owner.entity_name


func _refresh_target() -> void:
	"""Refreshes the target based on the currently selected targeting strategy."""
	if entity_owner == null or entity_owner.target_module == null:
		printerr("EntityController: entity_owner or target_module is null")
		_target_label.text = "Error: No entity_owner"
		_target = null
		return
	
	var targeting_strategy: TargetModule.TargettingStrategy = _targeting_strat_choice.get_selected_id() as TargetModule.TargettingStrategy
	_target = entity_owner.target_module.get_target(targeting_strategy)
	
	if _target != null:
		_target_label.text = "Target: " + _target.entity_name + " [ID:" + str(_target.id) + "]"
		print("DEBUG: Target refreshed - ", _target.entity_name, " using strategy: ", TargetModule.TargettingStrategy.keys()[targeting_strategy])
	else:
		_target_label.text = "[color=red]<undefined>[/color]"
		print("DEBUG: No target found using strategy: ", TargetModule.TargettingStrategy.keys()[targeting_strategy])


func _on_attack_button_pressed() -> void:
	_refresh_target()
	
	if _target == null:
		printerr("EntityController: No target selected for direct_attack")
		return
	
	var damage_text: String = _direct_attack_edit.text.strip_edges()
	if damage_text.is_empty():
		printerr("EntityController: No damage value provided")
		return
	
	var damage: float = damage_text.to_float()
	var damage_type: Utils.DamageType = _damage_choice.get_selected_id() as Utils.DamageType
	var action_id: StringName = &"test_direct_attack"
	
	entity_owner.direct_attack(_target, damage, damage_type, action_id)
	print("DEBUG: direct_attack called - Target: ", _target.entity_name, " | Damage: ", damage, " | Type: ", Utils.DamageType.keys()[damage_type])


func _on_attack_percent_button_pressed() -> void:
	_refresh_target()
	
	if _target == null:
		printerr("EntityController: No target selected for direct_attack_percent")
		return
	
	var percent_text: String = _direct_attack_percent_edit.text.strip_edges()
	if percent_text.is_empty():
		printerr("EntityController: No percent value provided")
		return
	
	var damage_percent: float = percent_text.to_float()
	var damage_type: Utils.DamageType = _damage_choice_percent.get_selected_id() as Utils.DamageType
	var percent_modifier: Utils.PercentModifier = _percent_modifier_choice.get_selected_id() as Utils.PercentModifier
	var action_id: StringName = &"test_direct_attack_percent"
	
	entity_owner.direct_attack_percent(_target, damage_percent, damage_type, percent_modifier, action_id)
	print("DEBUG: direct_attack_percent called - Target: ", _target.entity_name, " | Percent: ", damage_percent, "% | Type: ", Utils.DamageType.keys()[damage_type], " | Modifier: ", Utils.PercentModifier.keys()[percent_modifier])


func _on_heal_button_pressed() -> void:
	_refresh_target()
	
	if _target == null:
		printerr("EntityController: No target selected for heal")
		return
	
	var heal_text: String = _heal_edit.text.strip_edges()
	if heal_text.is_empty():
		printerr("EntityController: No heal value provided")
		return
	
	var heal_amount: float = heal_text.to_float()
	var action_id: StringName = &"test_heal"
	
	entity_owner.heal(_target, heal_amount, action_id)
	print("DEBUG: heal called - Target: ", _target.entity_name, " | Amount: ", heal_amount)


func _on_heal_percent_button_pressed() -> void:
	_refresh_target()
	
	if _target == null:
		printerr("EntityController: No target selected for heal_percent")
		return
	
	var percent_text: String = _heal_percent_edit.text.strip_edges()
	if percent_text.is_empty():
		printerr("EntityController: No percent value provided")
		return
	
	var percent: float = percent_text.to_float()
	var percent_modifier: Utils.PercentModifier = _health_percent_modifier_choice.get_selected_id() as Utils.PercentModifier
	var action_id: StringName = &"test_heal_percent"
	
	entity_owner.heal_percent(_target, percent, percent_modifier, action_id)
	print("DEBUG: heal_percent called - Target: ", _target.entity_name, " | Percent: ", percent, "% | Modifier: ", Utils.PercentModifier.keys()[percent_modifier])


func _on_inflict_condition_button_pressed() -> void:
	_refresh_target()
	
	if _target == null:
		printerr("EntityController: No target selected for inflict_condition_stacks")
		return
	
	var condition_text: String = _inflict_condition_edit.text.strip_edges()
	if condition_text.is_empty():
		printerr("EntityController: No condition value provided (format: stacks_number,duration)")
		return
	
	# Parse format: "stacks_number,duration" (e.g., "10,5.0")
	var parts: PackedStringArray = condition_text.split(",")
	if parts.size() < 1:
		printerr("EntityController: Invalid format. Use: stacks_number[,duration]")
		return
	
	var stack_type: Utils.StackType = _stack_type_choice.get_selected_id() as Utils.StackType
	var stacks_number: float = parts[0].strip_edges().to_float()
	var duration: float = 5.0 if parts.size() < 2 else parts[1].strip_edges().to_float()
	var action_id: StringName = &"test_inflict_condition"
	
	entity_owner.inflict_condition_stacks(_target, stacks_number, stack_type, action_id, duration)
	print("DEBUG: inflict_condition_stacks called - Target: ", _target.entity_name, " | Type: ", Utils.StackType.keys()[stack_type], " | Stacks: ", stacks_number, " | Duration: ", duration)


func _on_cleanse_button_pressed() -> void:
	_refresh_target()
	
	if _target == null:
		printerr("EntityController: No target selected for cleanse")
		return
	
	var cleanse_text: String = _cleanse_dispell_edit.text.strip_edges()
	if cleanse_text.is_empty():
		printerr("EntityController: No cleanse value provided")
		return
	
	var value: float = cleanse_text.to_float()
	var action_id: StringName = &"test_cleanse"
	
	entity_owner.cleanse(_target, value, action_id)
	print("DEBUG: cleanse called - Target: ", _target.entity_name, " | Value: ", value)


func _on_dispell_button_pressed() -> void:
	_refresh_target()
	
	if _target == null:
		printerr("EntityController: No target selected for dispell")
		return
	
	var dispell_text: String = _cleanse_dispell_edit.text.strip_edges()
	if dispell_text.is_empty():
		printerr("EntityController: No dispell value provided")
		return
	
	var value: float = dispell_text.to_float()
	var action_id: StringName = &"test_dispell"
	
	entity_owner.dispell(_target, value, action_id)
	print("DEBUG: dispell called - Target: ", _target.entity_name, " | Value: ", value)


func _on_targeting_strat_choice_item_selected(index: int) -> void:
	if entity_owner == null or entity_owner.target_module == null:
		printerr("EntityController: entity_owner or target_module is null")
		_target_label.text = "Error: No entity_owner"
		return
	
	var targeting_strategy: TargetModule.TargettingStrategy = index as TargetModule.TargettingStrategy
	_target = entity_owner.target_module.get_target(targeting_strategy)
	
	if _target != null:
		_target_label.text = "Target: " + _target.entity_name + " [ID:" + str(_target.id) + "]"
		print("DEBUG: Target selected - ", _target.entity_name, " using strategy: ", TargetModule.TargettingStrategy.keys()[targeting_strategy])
	else:
		_target_label.text = "Target: None (strategy returned null)"
		print("DEBUG: No target found using strategy: ", TargetModule.TargettingStrategy.keys()[targeting_strategy])
