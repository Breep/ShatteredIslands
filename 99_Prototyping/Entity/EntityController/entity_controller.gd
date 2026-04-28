extends Node

@export var entity_owner: Entity
@export var spawn_summon_localizer: Node3D

@onready var _entity_name_label: Label = %EntityNameLabel

@onready var _direct_damage_edit: TextEdit = %DirectAttackEdit
@onready var _direct_damage_percent_edit: TextEdit = %DirectAttackPercentEdit
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

@onready var _projectile_type_choice: OptionButton = %ProjectileTypeChoice

@onready var _speed_text_edit: TextEdit = %SpeedTextEdit
@onready var _bounce_text_edit: TextEdit = %BounceTextEdit

@onready var _spell_type_choice: OptionButton = %SpellTypeChoice
@onready var _spell_param1_label: Label = %Param1Label
@onready var _spell_param1_edit: TextEdit = %Param1TextEdit
@onready var _spell_param2_label: Label = %Param2Label
@onready var _spell_param2_edit: TextEdit = %Param2TextEdit
@onready var _spell_param3_label: Label = %Param3Label
@onready var _spell_param3_edit: TextEdit = %Param3TextEdit
@onready var _spell_param4_label: Label = %Param4Label
@onready var _spell_param4_edit: TextEdit = %Param4TextEdit

@onready var _entity_type_choice: OptionButton = %EntityTypeChoice
@onready var _spawn_type_choice: OptionButton = %SpawnTypeChoice

@onready var _entity_param1_label: Label = %EntityParam1Label
@onready var _entity_param1_edit: TextEdit = %EntityParam1TextEdit
@onready var _entity_param2_label: Label = %EntityParam2Label
@onready var _entity_param2_edit: TextEdit = %EntityParam2TextEdit
@onready var _entity_param3_label: Label = %EntityParam3Label
@onready var _entity_param3_edit: TextEdit = %EntityParam3TextEdit
@onready var _entity_param4_label: Label = %EntityParam4Label
@onready var _entity_param4_edit: TextEdit = %EntityParam4TextEdit
@onready var _entity_param5_label: Label = %EntityParam5Label
@onready var _entity_param5_edit: TextEdit = %EntityParam5TextEdit
@onready var _entity_param6_label: Label = %EntityParam6Label
@onready var _entity_param6_edit: TextEdit = %EntityParam6TextEdit

@onready var _summon_count_edit: TextEdit = %SummonCountTextEdit

@onready var _random_radius_edit: TextEdit = %RandomRadiusTextEdit
@onready var _entity_choice: OptionButton = %EntityChoice
@onready var _team_edit: TextEdit = %TeamTextEdit
@onready var _spawn_localizer_show_button: CheckButton = %SpawnLocalizerShowButton

@onready var _inflict_status_choice: OptionButton = %StatusTypeChoice
@onready var _inflict_status_duration_edit: TextEdit = %InflictStatusDurationEdit

var _target: Entity
var _all_entities: Array[Entity] = [] # Cached list of all entities for entity choice dropdown

func _ready() -> void:
	# Clear all dropdowns to prevent duplicates
	_targeting_strat_choice.clear()
	_damage_choice.clear()
	_damage_choice_percent.clear()
	_stack_type_choice.clear()
	_percent_modifier_choice.clear()
	_health_percent_modifier_choice.clear()
	_projectile_type_choice.clear()
	_spell_type_choice.clear()
	
	# Populate targeting strategy dropdown
	var i: int = 0
	for targeting_strategy: String in TargetComponent.TargettingStrategy.keys():
		_targeting_strat_choice.add_item(targeting_strategy, i)
		i += 1
	
	# Populate damage type dropdowns
	i = 0
	for damage_type: String in Utils.ActionType.keys():
		_damage_choice.add_item(damage_type, i)
		_damage_choice_percent.add_item(damage_type, i)
		i += 1
	
	# Populate stack type dropdown
	for stack_type: Alteration.Type in Alteration.STACK_TYPES:
		_stack_type_choice.add_item(Alteration.Type.keys()[stack_type], stack_type)
	
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
	
	# Populate projectile type dropdown
	i = 0
	for projectile_type: String in Projectile.Type.keys():
		_projectile_type_choice.add_item(projectile_type, i)
		i += 1
	
	# Populate spell type dropdown
	i = 0
	for spell_type: String in Spell.Type.keys():
		_spell_type_choice.add_item(spell_type, i)
		i += 1
	
	# Populate entity type dropdown
	i = 0
	for entity_type: String in Entity.EntityType.keys():
		_entity_type_choice.add_item(entity_type, i)
		i += 1
	
	# Populate spawn type dropdown
	i = 0
	for spawn_type: String in SpawnLocationConfig.LocationType.keys():
		_spawn_type_choice.add_item(spawn_type, i)
		i += 1
	
	# Populate inflict status dropdown (both timed and state alterations)
	for status_type: Alteration.Type in Alteration.TIMED_TYPES:
		_inflict_status_choice.add_item(Alteration.Type.keys()[status_type], status_type)
	for status_type: Alteration.Type in Alteration.STATE_TYPES:
		_inflict_status_choice.add_item(Alteration.Type.keys()[status_type], status_type)
	
	# Initialize spell parameters with default (METEOR)
	_update_spell_parameters(Spell.Type.METEOR)
	
	# Initialize entity parameters with default (SNAKE_BARREL)
	_update_entity_parameters(Entity.EntityType.SNAKE_BARREL)
	
	# Initialize spawn parameters with default (EXACT)
	_update_spawn_parameters(SpawnLocationConfig.LocationType.EXACT)
	
	# Hide spawn_summon_localizer by default and uncheck the button
	if spawn_summon_localizer != null:
		spawn_summon_localizer.visible = false
	_spawn_localizer_show_button.button_pressed = false
	
	if entity_owner != null:
		_entity_name_label.text = entity_owner.entity_name
	
	Events.entity_clicked.connect(_on_entity_clicked)


func _refresh_target() -> void:
	"""Refreshes the target based on the currently selected targeting strategy."""
	if entity_owner == null or entity_owner.target == null:
		printerr("EntityController: entity_owner or target is null")
		_target_label.text = "Error: No entity_owner"
		_target = null
		return
	
	var targeting_strategy: TargetComponent.TargettingStrategy = _targeting_strat_choice.get_selected_id() as TargetComponent.TargettingStrategy
	_target = entity_owner.target.get_target(targeting_strategy)
	
	if _target != null:
		_target_label.text = "Target: " + _target.entity_name + " [ID:" + str(_target.uid) + "]"
		print("DEBUG: Target refreshed - ", _target.entity_name, " using strategy: ", TargetComponent.TargettingStrategy.keys()[targeting_strategy])
	else:
		_target_label.text = "[color=red]<undefined>[/color]"
		print("DEBUG: No target found using strategy: ", TargetComponent.TargettingStrategy.keys()[targeting_strategy])


func _on_attack_button_pressed() -> void:
	_refresh_target()
	
	if _target == null:
		printerr("EntityController: No target selected for direct_damage")
		return
	
	var damage_text: String = _direct_damage_edit.text.strip_edges()
	if damage_text.is_empty():
		printerr("EntityController: No damage value provided")
		return
	
	var damage: float = damage_text.to_float()
	var damage_type: Utils.ActionType = _damage_choice.get_selected_id() as Utils.ActionType
	var action_id: StringName = &"test_direct_damage"
	
	entity_owner.damage.direct(_target, damage, damage_type, action_id)
	print("DEBUG: direct_damage called - Target: ", _target.entity_name, " | Damage: ", damage, " | Type: ", Utils.ActionType.keys()[damage_type])


func _on_attack_percent_button_pressed() -> void:
	_refresh_target()
	
	if _target == null:
		printerr("EntityController: No target selected for direct_damage_percent")
		return
	
	var percent_text: String = _direct_damage_percent_edit.text.strip_edges()
	if percent_text.is_empty():
		printerr("EntityController: No percent value provided")
		return
	
	var damage_percent: float = percent_text.to_float()
	var damage_type: Utils.ActionType = _damage_choice_percent.get_selected_id() as Utils.ActionType
	var percent_modifier: Utils.PercentModifier = _percent_modifier_choice.get_selected_id() as Utils.PercentModifier
	var action_id: StringName = &"test_direct_damage_percent"
	
	entity_owner.damage.direct_percent(_target, damage_percent, damage_type, percent_modifier, action_id)
	print("DEBUG: direct_damage_percent called - Target: ", _target.entity_name, " | Percent: ", damage_percent, "% | Type: ", Utils.ActionType.keys()[damage_type], " | Modifier: ", Utils.PercentModifier.keys()[percent_modifier])


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
	
	entity_owner.heal.direct(_target, heal_amount, action_id)
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
	
	entity_owner.heal.direct_percent(_target, percent, percent_modifier, action_id)
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
	
	var stack_type: Alteration.Type = _stack_type_choice.get_selected_id() as Alteration.Type
	var stacks_number: float = parts[0].strip_edges().to_float()
	var duration: float = 5.0 if parts.size() < 2 else parts[1].strip_edges().to_float()
	var action_id: StringName = &"test_inflict_condition"

	entity_owner.alterations.inflict_condition_stacks(_target, stacks_number, stack_type, action_id, duration)
	print("DEBUG: inflict_condition_stacks called - Target: ", _target.entity_name, " | Type: ", Alteration.Type.keys()[stack_type], " | Stacks: ", stacks_number, " | Duration: ", duration)


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
	
	entity_owner.alterations.cleanse(_target, value, action_id)
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
	
	entity_owner.alterations.dispell(_target, value, action_id)
	print("DEBUG: dispell called - Target: ", _target.entity_name, " | Value: ", value)


func _on_targeting_strat_choice_item_selected(index: int) -> void:
	if entity_owner == null or entity_owner.target == null:
		printerr("EntityController: entity_owner or target is null")
		_target_label.text = "Error: No entity_owner"
		return
	
	var targeting_strategy: TargetComponent.TargettingStrategy = index as TargetComponent.TargettingStrategy
	_target = entity_owner.target.get_target(targeting_strategy)
	
	if _target != null:
		_target_label.text = "Target: " + _target.entity_name + " [ID:" + str(_target.uid) + "]"
		print("DEBUG: Target selected - ", _target.entity_name, " using strategy: ", TargetComponent.TargettingStrategy.keys()[targeting_strategy])
	else:
		_target_label.text = "Target: None (strategy returned null)"
		print("DEBUG: No target found using strategy: ", TargetComponent.TargettingStrategy.keys()[targeting_strategy])


func _on_projectile_attack_button_pressed() -> void:
	
	for i in 1:
		_refresh_target()
		if _target == null:
			printerr("EntityController: No target selected for projectile_attack")
			return
		
		if entity_owner == null:
			printerr("EntityController: No entity_owner for projectile_attack")
			return
		
		var projectile_type: Projectile.Type = _projectile_type_choice.get_selected_id() as Projectile.Type
		var projectile_spawn: Node3D = entity_owner.get_auto_attack_spawn()
		var projectile_stats: ProjectileStats = ProjectileStats.new()
		
		# Build stats from UI inputs
		var speed_text: String = _speed_text_edit.text.strip_edges()
		projectile_stats.speed = speed_text.to_int() if not speed_text.is_empty() else 20
		
		var bounce_text: String = _bounce_text_edit.text.strip_edges()
		var bounce_count: int = bounce_text.to_int() if not bounce_text.is_empty() else 0
		projectile_stats.bounces_remaining = bounce_count
		
		entity_owner.projectile_sender.projectile_attack(_target, projectile_type, projectile_spawn, projectile_stats, false)
		print("DEBUG: projectile_attack called - Target: ", _target.entity_name, " | Type: ", Projectile.Type.keys()[projectile_type])


func _update_spell_parameters(spell_type: Spell.Type) -> void:
	"""Updates the parameter labels and visibility based on selected spell type."""
	var param_configs: Array[Dictionary] = []
	
	match spell_type:
		Spell.Type.METEOR:
			param_configs = [
				{"label": "Damage %", "default": "5"},
				{"label": "Radius", "default": "5"},
				{"label": "(Callbacks)", "default": "0"},
				{"label": "(Unused)", "default": "0"}
			]
		Spell.Type.DARK_STORM:
			param_configs = [
				{"label": "Damage", "default": "10"},
				{"label": "Period", "default": "1.0"},
				{"label": "Lifespan", "default": "5.0"},
				{"label": "Pain Stack %", "default": "10"}
			]
		Spell.Type.CONTAGION:
			param_configs = [
				{"label": "Radius", "default": "10"},
				{"label": "Spread %", "default": "50"},
				{"label": "(Unused)", "default": "0"},
				{"label": "(Unused)", "default": "0"}
			]
		Spell.Type.SHROOM:
			param_configs = [
				{"label": "Radius", "default": "5"},
				{"label": "Damage", "default": "20"},
				{"label": "Life Time", "default": "10.0"},
				{"label": "(Unused)", "default": "0"}
			]
		Spell.Type.DEATH_FOG:
			param_configs = [
				{"label": "Grow Speed", "default": "1.0"},
				{"label": "Tick Period", "default": "1.0"},
				{"label": "Dmg Multiplier", "default": "1.0"},
				{"label": "(Unused)", "default": "0"}
			]
		Spell.Type.LIGHTNING:
			param_configs = [
				{"label": "Damage", "default": "100"},
				{"label": "(Unused)", "default": "0"},
				{"label": "(Unused)", "default": "0"},
				{"label": "(Unused)", "default": "0"}
			]
		Spell.Type.CHAIN_LIGHTNING:
			param_configs = [
				{"label": "Damage", "default": "50"},
				{"label": "Bounce Count", "default": "3"},
				{"label": "Bounce Range", "default": "10"},
				{"label": "Dmg Decay %", "default": "20"}
			]
	
	# Apply configurations
	var labels: Array[Label] = [_spell_param1_label, _spell_param2_label, _spell_param3_label, _spell_param4_label]
	var edits: Array[TextEdit] = [_spell_param1_edit, _spell_param2_edit, _spell_param3_edit, _spell_param4_edit]
	
	for i in range(4):
		if i < param_configs.size():
			labels[i].text = param_configs[i]["label"]
			edits[i].text = param_configs[i]["default"]
			labels[i].get_parent().get_parent().visible = true
		else:
			labels[i].get_parent().get_parent().visible = false


func _on_spell_type_choice_item_selected(index: int) -> void:
	"""Called when spell type dropdown selection changes."""
	var spell_type: Spell.Type = index as Spell.Type
	_update_spell_parameters(spell_type)
	print("DEBUG: Spell type changed to: ", Spell.Type.keys()[spell_type])


func _on_cast_spell_button_pressed() -> void:
	_refresh_target()
	
	if _target == null:
		printerr("EntityController: No target selected for cast_spell")
		return
	
	if entity_owner == null:
		printerr("EntityController: No entity_owner for cast_spell")
		return
	
	var spell_type: Spell.Type = _spell_type_choice.get_selected_id() as Spell.Type
	var spell_modifier: Dictionary = {}
	
	# Build spell_modifier dictionary based on spell type
	match spell_type:
		Spell.Type.METEOR:
			spell_modifier[Meteor.Modifier.DAMAGE_PERCENT] = _spell_param1_edit.text.to_float()
			spell_modifier[Meteor.Modifier.RADIUS] = _spell_param2_edit.text.to_float()
			# ON_HIT_CALLBACKS would be handled separately if needed
		
		Spell.Type.DARK_STORM:
			spell_modifier[Spell.DarkStormModifier.DAMAGE] = _spell_param1_edit.text.to_float()
			spell_modifier[Spell.DarkStormModifier.PERIOD] = _spell_param2_edit.text.to_float()
			spell_modifier[Spell.DarkStormModifier.LIFESPAN] = _spell_param3_edit.text.to_float()
			spell_modifier[Spell.DarkStormModifier.PAIN_STACK_PERCENT] = _spell_param4_edit.text.to_float()
		
		Spell.Type.CONTAGION:
			spell_modifier[Spell.ContagionModifier.RADIUS] = _spell_param1_edit.text.to_float()
			spell_modifier[Spell.ContagionModifier.SPREAD_PERCENT] = _spell_param2_edit.text.to_float()
		
		Spell.Type.SHROOM:
			spell_modifier[Spell.ShroomModifier.RADIUS] = _spell_param1_edit.text.to_float()
			spell_modifier[Spell.ShroomModifier.DAMAGE] = _spell_param2_edit.text.to_float()
			spell_modifier[Spell.ShroomModifier.LIFE_TIME] = _spell_param3_edit.text.to_float()
		
		Spell.Type.DEATH_FOG:
			spell_modifier[Spell.DeathFogModifier.GROW_SPEED] = _spell_param1_edit.text.to_float()
			spell_modifier[Spell.DeathFogModifier.TICK_PERIOD] = _spell_param2_edit.text.to_float()
			spell_modifier[Spell.DeathFogModifier.DAMAGE_MULTIPLIER] = _spell_param3_edit.text.to_float()
		
		Spell.Type.LIGHTNING:
			spell_modifier[Spell.LightningModifier.DAMAGE] = _spell_param1_edit.text.to_float()
		
		Spell.Type.CHAIN_LIGHTNING:
			spell_modifier[Spell.ChainLightningModifier.DAMAGE] = _spell_param1_edit.text.to_float()
			spell_modifier[Spell.ChainLightningModifier.BOUNCE_COUNT] = int(_spell_param2_edit.text.to_float())
			spell_modifier[Spell.ChainLightningModifier.BOUNCE_RANGE] = _spell_param3_edit.text.to_float()
			spell_modifier[Spell.ChainLightningModifier.DAMAGE_DECAY_PERCENT] = _spell_param4_edit.text.to_float()
	
	entity_owner.spell.cast_spell(_target, spell_type, spell_modifier)
	print("DEBUG: cast_spell called - Target: ", _target.entity_name, " | Spell: ", Spell.Type.keys()[spell_type], " | Modifiers: ", spell_modifier)


func _on_cast_ultimate_button_pressed() -> void:
	if entity_owner == null:
		printerr("EntityController: No entity_owner for cast_ultimate")
		return
	
	entity_owner.cast_ultimate()
	print("DEBUG: cast_ultimate called")


func _update_entity_parameters(entity_type: Entity.EntityType) -> void:
	"""Updates the parameter labels and visibility based on selected entity type."""
	var param_configs: Array[Dictionary] = []

	match entity_type:
		Entity.EntityType.HERO:
			param_configs = []

		Entity.EntityType.SNAKE_BARREL:
			param_configs = [
				{"label": "SNAKE_NUMBER", "default": "3"},
				{"label": "SNAKE_POISON_STACKS", "default": "5"},
				{"label": "MAX_HEALTH", "default": "100"},
			]

		Entity.EntityType.SNAKE:
			param_configs = []

		Entity.EntityType.FIELD_GENERATOR:
			param_configs = [
				{"label": "MAX_HEALTH", "default": "200"},
				{"label": "SHIELD_AMOUNT", "default": "50"},
				{"label": "SHIELD_INTERVAL", "default": "3.0"},
				{"label": "INITIAL_SHIELD", "default": "1"},
				{"label": "TARGET_COUNT", "default": "3"},
			]

		Entity.EntityType.CHICKEN:
			param_configs = []

		Entity.EntityType.PROTO_SHIELD:
			param_configs = [
				{"label": "SHIELD", "default": "100"},
				{"label": "HP_MAX", "default": "1"},
			]

		Entity.EntityType.FORTIFICATION_DRONE:
			param_configs = [
				{"label": "SHIELD", "default": "100"},
				{"label": "HP_MAX", "default": "1"},
				{"label": "SHIELD_PER_SECOND", "default": "1"},
				{"label": "RESPAWN_TIMER", "default": "10.0"},
			]

		Entity.EntityType.AEGIS_BLADE:
			param_configs = [
				{"label": "AD", "default": "50"},
				{"label": "AS", "default": "1"},
				{"label": "SHIELD_AD_MAX", "default": "100"},
				{"label": "SHIELD_AD_TAU", "default": "500"},
				{"label": "DAMAGE_AS_SHIELD", "default": "0.5"},
			]

		Entity.EntityType.TREX:
			param_configs = [
				{"label": "GIFTED_SPAWN_PERIOD", "default": "5.0"},
				{"label": "GIFTED_SPAWN_NUMBER", "default": "1"},
				{"label": "HP_BONUS", "default": "0"},
			]

		Entity.EntityType.DEFLECTION_SHIELD:
			param_configs = [
				{"label": "BLOCKED_PROJECTILES", "default": "3"},
				{"label": "SHIELD_PER_BLOCK", "default": "10"},
			]
	
	# Apply configurations
	var labels: Array[Label] = [
		_entity_param1_label, _entity_param2_label, _entity_param3_label,
		_entity_param4_label, _entity_param5_label, _entity_param6_label
	]
	var edits: Array[TextEdit] = [
		_entity_param1_edit, _entity_param2_edit, _entity_param3_edit,
		_entity_param4_edit, _entity_param5_edit, _entity_param6_edit
	]
	
	for i in range(6):
		if i < param_configs.size():
			labels[i].text = param_configs[i]["label"]
			edits[i].text = param_configs[i]["default"]
			labels[i].get_parent().get_parent().visible = true
		else:
			labels[i].get_parent().get_parent().visible = false


func _on_entity_type_choice_item_selected(index: int) -> void:
	"""Called when entity type dropdown selection changes."""
	var entity_type: Entity.EntityType = index as Entity.EntityType
	_update_entity_parameters(entity_type)
	print("DEBUG: Entity type changed to: ", Entity.EntityType.keys()[entity_type])


func _on_spawn_type_choice_item_selected(index: int) -> void:
	"""Called when spawn type dropdown selection changes."""
	var spawn_type: SpawnLocationConfig.LocationType = index as SpawnLocationConfig.LocationType
	_update_spawn_parameters(spawn_type)
	print("DEBUG: Spawn type changed to: ", SpawnLocationConfig.LocationType.keys()[spawn_type])


func _update_spawn_parameters(spawn_type: SpawnLocationConfig.LocationType) -> void:
	"""Updates the spawn parameter visibility based on selected spawn type."""
	# Get references to parameter containers
	var random_radius_container: Control = _random_radius_edit.get_parent().get_parent()
	var entity_choice_container: Control = _entity_choice.get_parent().get_parent()
	var team_container: Control = _team_edit.get_parent().get_parent()
	
	# Hide all by default
	random_radius_container.visible = false
	entity_choice_container.visible = false
	team_container.visible = false
	
	match spawn_type:
		SpawnLocationConfig.LocationType.EXACT:
			# Show random radius only
			random_radius_container.visible = true
		
		SpawnLocationConfig.LocationType.ARENA_CENTER:
			# Show random radius only
			random_radius_container.visible = true
		
		SpawnLocationConfig.LocationType.TEAM_ZONE:
			# Show random radius and team
			random_radius_container.visible = true
			team_container.visible = true
		
		SpawnLocationConfig.LocationType.ENTITY:
			# Show random radius and entity choice
			random_radius_container.visible = true
			entity_choice_container.visible = true
			# Populate entity choice dropdown
			_populate_entity_choices()
		
		SpawnLocationConfig.LocationType.RANDOM_ARENA:
			# Show random radius only
			random_radius_container.visible = true


func _populate_entity_choices() -> void:
	"""Populates the entity choice dropdown with all available entities."""
	_entity_choice.clear()
	_all_entities.clear()
	
	if entity_owner == null or entity_owner.target == null:
		printerr("EntityController: Cannot populate entity choices - entity_owner or target is null")
		return
	
	# Get all entities using the target module
	var all_entities: Array[Entity] = entity_owner.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALL)
	
	if all_entities.is_empty():
		print("DEBUG: No entities found for entity choice dropdown")
		_entity_choice.add_item("<No entities available>", -1)
		return
	
	# Store entities and add each to the dropdown
	_all_entities = all_entities
	for i in range(_all_entities.size()):
		var entity: Entity = _all_entities[i]
		var display_name: String = entity.entity_name + " [ID:" + str(entity.uid) + "]"
		_entity_choice.add_item(display_name, i)
	
	print("DEBUG: Populated entity choice with ", _all_entities.size(), " entities")


func _on_spawn_localizer_show_button_toggled(toggled_on: bool) -> void:
	"""Called when the spawn localizer show button is toggled."""
	if spawn_summon_localizer != null:
		spawn_summon_localizer.visible = toggled_on
		print("DEBUG: Spawn localizer visibility set to: ", toggled_on)
	else:
		print("DEBUG: spawn_summon_localizer is null, cannot toggle visibility")


func _on_summon_entity_button_pressed() -> void:
	if entity_owner == null:
		printerr("EntityController: No entity_owner for summon_entity")
		return

	var summon_count: int = max(1, _summon_count_edit.text.to_int())

	for i in summon_count:
		var entity_type: Entity.EntityType = _entity_type_choice.get_selected_id() as Entity.EntityType
		var spawn_type: SpawnLocationConfig.LocationType = _spawn_type_choice.get_selected_id() as SpawnLocationConfig.LocationType

		# Build SpawnLocationConfig
		var spawn_config := SpawnLocationConfig.new()
		spawn_config.location_type = spawn_type

		# Configure spawn parameters based on spawn type
		var random_radius: float = _random_radius_edit.text.to_float()
		spawn_config.randomization_radius = random_radius

		match spawn_type:
			SpawnLocationConfig.LocationType.EXACT:
				if spawn_summon_localizer == null:
					printerr("EntityController: spawn_summon_localizer is required for EXACT spawn type")
					return
				spawn_config.exact_position = spawn_summon_localizer.global_position

			SpawnLocationConfig.LocationType.ARENA_CENTER:
				pass

			SpawnLocationConfig.LocationType.TEAM_ZONE:
				var team: int = _team_edit.text.to_int()
				spawn_config.team = team

			SpawnLocationConfig.LocationType.ENTITY:
				var selected_index: int = _entity_choice.get_selected_id()
				if selected_index >= 0 and selected_index < _all_entities.size():
					spawn_config.target_entity = _all_entities[selected_index]
				else:
					printerr("EntityController: Invalid entity selection for ENTITY spawn type")
					spawn_config.target_entity = spawn_summon_localizer

			SpawnLocationConfig.LocationType.RANDOM_ARENA:
				pass

		# Build entity_modifier dictionary based on entity type
		var entity_modifier: Dictionary = {}
		var edits: Array[TextEdit] = [
			_entity_param1_edit, _entity_param2_edit, _entity_param3_edit,
			_entity_param4_edit, _entity_param5_edit, _entity_param6_edit
		]

		match entity_type:
			Entity.EntityType.HERO:
				pass

			Entity.EntityType.SNAKE_BARREL:
				entity_modifier[SnakeBarrel.Modifier.SNAKE_NUMBER] = int(edits[0].text.to_float())
				entity_modifier[SnakeBarrel.Modifier.SNAKE_POISON_STACKS] = edits[1].text.to_float()
				entity_modifier[SnakeBarrel.Modifier.MAX_HEALTH] = edits[2].text.to_float()

			Entity.EntityType.SNAKE:
				pass

			Entity.EntityType.FIELD_GENERATOR:
				entity_modifier[FieldGenerator.Modifier.MAX_HEALTH] = edits[0].text.to_float()
				entity_modifier[FieldGenerator.Modifier.SHIELD_AMOUNT] = edits[1].text.to_float()
				entity_modifier[FieldGenerator.Modifier.SHIELD_INTERVAL] = edits[2].text.to_float()
				entity_modifier[FieldGenerator.Modifier.INITIAL_SHIELD] = int(edits[3].text.to_float())
				entity_modifier[FieldGenerator.Modifier.TARGET_COUNT] = int(edits[4].text.to_float())

			Entity.EntityType.CHICKEN:
				pass

			Entity.EntityType.PROTO_SHIELD:
				entity_modifier[ProtoShield.Modifier.SHIELD] = edits[0].text.to_float()
				entity_modifier[ProtoShield.Modifier.HP_MAX] = int(edits[1].text.to_float())

			Entity.EntityType.FORTIFICATION_DRONE:
				entity_modifier[FortificationDrone.Modifier.SHIELD] = edits[0].text.to_float()
				entity_modifier[FortificationDrone.Modifier.HP_MAX] = int(edits[1].text.to_float())
				entity_modifier[FortificationDrone.Modifier.SHIELD_PER_SECOND] = edits[2].text.to_float()
				entity_modifier[FortificationDrone.Modifier.RESPAWN_TIMER] = edits[3].text.to_float()

			Entity.EntityType.AEGIS_BLADE:
				entity_modifier[AegisBlade.Modifier.AD] = edits[0].text.to_float()
				entity_modifier[AegisBlade.Modifier.AS] = edits[1].text.to_float()
				entity_modifier[AegisBlade.Modifier.SHIELD_AD_MAX] = edits[2].text.to_float()
				entity_modifier[AegisBlade.Modifier.SHIELD_AD_TAU] = edits[3].text.to_float()
				entity_modifier[AegisBlade.Modifier.DAMAGE_AS_SHIELD] = edits[4].text.to_float()

			Entity.EntityType.TREX:
				entity_modifier[TRex.Modifier.PRIMAL_SHAKE_PERIOD] = edits[0].text.to_float()
				entity_modifier[TRex.Modifier.PRIMAL_SHAKE_NUMBER] = int(edits[1].text.to_float())
				entity_modifier[TRex.Modifier.HP_BONUS] = edits[2].text.to_float()

			Entity.EntityType.DEFLECTION_SHIELD:
				entity_modifier[DeflectionShield.Modifier.BLOCKED_PROJECTILES] = int(edits[0].text.to_float())
				entity_modifier[DeflectionShield.Modifier.SHIELD_PER_BLOCK] = edits[1].text.to_float()

		entity_owner.summon.summon_entity(entity_type, spawn_config, entity_modifier)
		print("DEBUG: summon_entity called - Type: ", Entity.EntityType.keys()[entity_type],
			" | Spawn: ", SpawnLocationConfig.LocationType.keys()[spawn_type],
			" | Modifiers: ", entity_modifier)


func _on_auto_attack_button_pressed() -> void:
	if entity_owner == null:
		printerr("EntityController: No entity_owner for cast_ultimate")
		return
	
	_refresh_target()
	entity_owner.auto_attack.execute_auto_attack(_target)
	print("DEBUG: auto_attack called")


func _on_inflict_status_button_pressed() -> void:
	_refresh_target()
	
	if _target == null:
		printerr("EntityController: No target selected for inflict_status")
		return
	
	var status_text: String = _inflict_status_duration_edit.text.strip_edges()
	if status_text.is_empty():
		printerr("EntityController: No status duration provided")
		return
	
	var status_type: Alteration.Type = _inflict_status_choice.get_selected_id() as Alteration.Type
	var status_duration: float = status_text.to_float()
	var action_id: StringName = &"test_inflict_status"

	entity_owner.alterations.inflict_status(_target, status_type, status_duration, action_id)
	print("DEBUG: inflict_status called - Target: ", _target.entity_name, " | Type: ", Alteration.Type.keys()[status_type], " | Duration: ", status_duration)


func _on_entity_clicked(entity: Entity) -> void:
	if is_instance_valid(entity_owner):
		entity_owner.clickable.deselect()
	entity_owner = entity
	entity_owner.clickable.select()
