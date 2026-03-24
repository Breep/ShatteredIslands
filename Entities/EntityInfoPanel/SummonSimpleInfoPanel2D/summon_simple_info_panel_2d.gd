class_name SummonSimpleInfoPanel2D
extends Control

#region ============================== Export ==============================
@export_group("External Nodes")
@export var _owner_entity: Entity
@export var _info_panel_spawn: Marker3D
#endregion

@onready var _health_bar: ColorRect = %HealthBar
@onready var _shield_bar: ColorRect = %ShieldBar
@onready var _grid_bar: ColorRect = %GridBar

#region ============================== Node base functions ==============================
func _ready() -> void:
	if _health_bar and _health_bar.material:
		_health_bar.material = _health_bar.material.duplicate()
		_set_health_bar_color_by_team()
	if _shield_bar and _shield_bar.material:
		_shield_bar.material = _shield_bar.material.duplicate()
	if _grid_bar and _grid_bar.material:
		_grid_bar.material = _grid_bar.material.duplicate()

	var stats = _owner_entity.stats
	var conditions = _owner_entity.conditions

	_update_health_bar(stats.health, stats.health_max)
	_update_shield_bar(conditions.shield_stacks, stats.health_max)

	stats.health_changed.connect(_on_health_changed)
	stats.health_max_changed.connect(_on_health_max_changed)
	conditions.shield_stacks_changed.connect(_on_shield_changed)


func _process(_delta: float) -> void:
	var camera = get_viewport().get_camera_3d()
	if camera != null and _info_panel_spawn != null:
		position = camera.unproject_position(_info_panel_spawn.global_position) + Vector2(-size.x / 2, 0)
#endregion

#region ============================== Public API ==============================
func init(entity: Entity) -> void:
	_owner_entity = entity


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
#endregion

#region ============================== Private API ==============================
func _update_health_bar(health: float, health_max: float) -> void:
	if not _health_bar or not _health_bar.material:
		return
	var ratio = clamp(float(health) / float(health_max), 0.0, 1.0)
	_health_bar.material.set_shader_parameter("HealthAmount", ratio)
	_health_bar.material.set_shader_parameter("MaxHealth", float(health_max))
	_grid_bar.material.set_shader_parameter("MaxHealth", float(health_max))


func _update_shield_bar(armor_amount: float, max_health: float) -> void:
	if not _shield_bar or not _shield_bar.material:
		return
	var ratio = 0.0
	if max_health > 0:
		ratio = clamp(float(armor_amount) / float(max_health), 0.0, 1.0)
	_shield_bar.material.set_shader_parameter("fill_amount", ratio)


func _set_health_bar_color_by_team() -> void:
	if not _health_bar or not _health_bar.material or not _owner_entity:
		return
	var local_player: Player = PlayerManager.get_local_player()
	var health_color: Color
	if local_player == null or _owner_entity.team == local_player.team:
		health_color = Color.LIME_GREEN
	else:
		health_color = Color.INDIAN_RED
	_health_bar.material.set_shader_parameter("HealthColor", health_color)
#endregion

#region ============================== Callbacks ==============================
func _on_health_changed(new_health: int) -> void:
	_update_health_bar(new_health, _owner_entity.stats.health_max)


func _on_health_max_changed(new_max: int) -> void:
	_update_health_bar(_owner_entity.stats.health, new_max)
	_update_shield_bar(_owner_entity.conditions.shield_stacks, new_max)


func _on_shield_changed(new_amount: float) -> void:
	_update_shield_bar(new_amount, _owner_entity.stats.health_max)
#endregion
