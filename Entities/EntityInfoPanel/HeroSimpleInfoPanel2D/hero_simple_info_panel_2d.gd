class_name HeroSimpleInfoPanel2D
extends SimpleInfoPanel2D

#region ============================== Export ==============================
@export_group("External Nodes")
@export var _hero_entity: Hero
@export var _info_panel_spawn: Marker3D
@export var _info_panel_spawn_tavern: Marker3D
#endregion

@onready var _health_bar: ColorRect = %HealthBar
@onready var _shield_bar: ColorRect = %ShieldBar
@onready var _grid_bar: ColorRect = %GridBar
@onready var _block_bar: ColorRect = %BlockBar

@onready var _mana_bar: ColorRect = %ManaBar

@onready var _debug_values: Control = %DebugValues
@onready var _health_label: Label = %HealthLabel
@onready var _shield_label: Label = %ShieldLabel

@onready var _ignite_label: Label = %IgniteLabel
@onready var _poison_label: Label = %PoisonLabel
@onready var _necrosis_label: Label = %NecrosisLabel
@onready var _regen_label: Label = %RegenLabel
@onready var _block_label: Label = %BlockLabel

@onready var _block_texture: TextureRect = %BlockTextureRect

@onready var _player_name_label: RichTextLabel = %PlayerNameLabel

var _taunt_visual: Node3D
var _current_spawn: Marker3D
const TAUNT_VISUAL_SCENE: PackedScene = preload("res://Entities/EntityInfoPanel/_Shared/taunt_status_visual.tscn")

#region ============================== Node base functions ==============================
func _ready() -> void:
	if _health_bar and _health_bar.material:
		_health_bar.material = _health_bar.material.duplicate()
		_set_health_bar_color_by_team()
	if _shield_bar and _shield_bar.material:
		_shield_bar.material = _shield_bar.material.duplicate()
	if _grid_bar and _grid_bar.material:
		_grid_bar.material = _grid_bar.material.duplicate()
	if _mana_bar and _mana_bar.material:
		_mana_bar.material = _mana_bar.material.duplicate()

	var stats = _hero_entity.stats
	var conditions = _hero_entity.conditions
	
	_update_health_bar(stats.health, stats.health_max)
	_update_shield_bar(conditions.shield_stacks, stats.health_max)
	_update_mana_bar(stats.mana, stats.mana_max)
	_update_stack_label(conditions.ignite_stacks, _ignite_label)
	_update_stack_label(conditions.poison_stacks, _poison_label)
	_update_stack_label(conditions.necrosis_stacks, _necrosis_label)
	_update_stack_label(conditions.regen_stacks, _regen_label)
	_update_block_label(conditions.block_stacks)
	
	stats.health_changed.connect(_on_health_changed)
	stats.health_max_changed.connect(_on_health_max_changed)
	conditions.shield_stacks_changed.connect(_on_shield_changed)
	stats.mana_changed.connect(_on_mana_changed)
	stats.mana_max_changed.connect(_on_mana_max_changed)
	conditions.ignite_stacks_changed.connect(_update_stack_label.bind(_ignite_label))
	conditions.poison_stacks_changed.connect(_update_stack_label.bind(_poison_label))
	conditions.necrosis_stacks_changed.connect(_update_stack_label.bind(_necrosis_label))
	conditions.regen_stacks_changed.connect(_update_stack_label.bind(_regen_label))
	conditions.block_stacks_changed.connect(_update_block_label)
	
	_hero_entity.status_module.taunted_changed.connect(_update_taunt_visual)
	
	if _hero_entity.player != null:
		_player_name_label.text = _hero_entity.player.player_name
	else:
		_player_name_label.text = _hero_entity.entity_name
	
	if _debug_values != null:
		_debug_values.visible = DebugHealthBarOverlay.is_visible()
	DebugHealthBarOverlay.register(_on_debug_overlay_toggled)


func _exit_tree() -> void:
	DebugHealthBarOverlay.unregister(_on_debug_overlay_toggled)


func _process(_delta: float) -> void:
	var camera = get_viewport().get_camera_3d()
	if camera != null and _current_spawn != null:
		position = camera.unproject_position(_current_spawn.global_position) + Vector2(-size.x / 2, 0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("trigger_health_bar_value"):
		DebugHealthBarOverlay.toggle()
		get_viewport().set_input_as_handled()
#endregion

#region ============================== Public API ==============================
func init(entity: Entity) -> void:
	_hero_entity = entity


func setup_grid_bar(small_block: int, big_block: int) -> void:
	if _grid_bar == null or _grid_bar.material == null: return
	
	_grid_bar.material.set_shader_parameter("ShowGrid", true)
	
	if small_block >= 1:
		_grid_bar.material.set_shader_parameter("Step_X_Value", small_block)
		_grid_bar.material.set_shader_parameter("Step_X_Height", 1)
	else:
		_grid_bar.material.set_shader_parameter("Step_X_Height", 0)
	
	if big_block >= 1:
		_grid_bar.material.set_shader_parameter("Step_Y_Value", big_block)
		_grid_bar.material.set_shader_parameter("Step_Y_Height", 1)
	else:
		_grid_bar.material.set_shader_parameter("Step_Y_Height", 0)


func apply_display_mode(display_mode: Hero.DisplayMode) -> void:
	match display_mode:
		Hero.DisplayMode.BUYING_PHASE:
			_current_spawn = _info_panel_spawn_tavern
			_mana_bar.hide()
		Hero.DisplayMode.FIGHTING_PHASE:
			_current_spawn = _info_panel_spawn
#endregion

#region ============================== Private API ==============================
func _update_health_bar(health: float, health_max: float) -> void:
	if not _health_bar or not _health_bar.material:
		return
	var ratio = clamp(float(health) / float(health_max), 0.0, 1.0)
	_health_bar.material.set_shader_parameter("HealthAmount", ratio)
	_health_bar.material.set_shader_parameter("MaxHealth", float(health_max))
	_grid_bar.material.set_shader_parameter("MaxHealth", float(health_max))
	if _health_label != null:
		_health_label.text = str(health).pad_decimals(0)


func _update_shield_bar(armor_amount: float, max_health: float) -> void:
	if not _shield_bar or not _shield_bar.material:
		return
	var ratio = 0.0
	if max_health > 0:
		ratio = clamp(float(armor_amount) / float(max_health), 0.0, 1.0)
	_shield_bar.material.set_shader_parameter("fill_amount", ratio)
	if _shield_label != null:
		if armor_amount >= 1:
			_shield_label.text = str(armor_amount).pad_decimals(0)
			_shield_label.show()
		else:
			_shield_label.hide()


func _update_mana_bar(mana: float, mana_max: float) -> void:
	if not _mana_bar or not _mana_bar.material:
		return
	var ratio := 0.0
	if mana_max > 0:
		ratio = clamp(mana / mana_max, 0.0, 1.0)
	_mana_bar.material.set_shader_parameter("HealthAmount", ratio)


func _update_stack_label(new_value: float, label: Label) -> void:
	if label == null: return
	if new_value > 0:
		label.text = str(new_value).pad_decimals(0)
		label.show()
	else:
		label.hide()


func _update_block_label(new_value: float) -> void:
	if _block_label == null: return
	if new_value > 0:
		_block_label.text = str(new_value).pad_decimals(0)
		_block_label.show()
		_block_texture.show()
		_block_bar.show()
	else:
		_block_label.hide()
		_block_texture.hide()
		_block_bar.hide()


func _update_taunt_visual(is_active: bool, duration: float, infinite: bool) -> void:
	if is_active and is_instance_valid(_info_panel_spawn):
		_taunt_visual = TAUNT_VISUAL_SCENE.instantiate()
		_info_panel_spawn.add_child(_taunt_visual)
		
	elif not is_active and is_instance_valid(_taunt_visual):
		_taunt_visual.queue_free()


func _set_health_bar_color_by_team() -> void:
	if not _health_bar or not _health_bar.material or not _hero_entity:
		return
	var local_player: Player = PlayerManager.get_local_player()
	var health_color: Color
	if local_player == null or _hero_entity.team == local_player.team:
		health_color = Color.LIME_GREEN
	else:
		health_color = Color.INDIAN_RED
	_health_bar.material.set_shader_parameter("HealthColor", health_color)
#endregion

#region ============================== Callbacks ==============================
func _on_health_changed(new_health: int) -> void:
	_update_health_bar(new_health, _hero_entity.stats.health_max)


func _on_health_max_changed(new_max: int) -> void:
	_update_health_bar(_hero_entity.stats.health, new_max)
	_update_shield_bar(_hero_entity.conditions.shield_stacks, new_max)


func _on_shield_changed(new_amount: float) -> void:
	_update_shield_bar(new_amount, _hero_entity.stats.health_max)


func _on_mana_changed(new_mana: float) -> void:
	_update_mana_bar(new_mana, _hero_entity.stats.mana_max)


func _on_mana_max_changed(new_mana_max: float) -> void:
	_update_mana_bar(_hero_entity.stats.mana, new_mana_max)


func _on_debug_overlay_toggled(debug_is_visible: bool) -> void:
	if _debug_values != null:
		_debug_values.visible = debug_is_visible
#endregion
