class_name HealthBarComponent
extends EntityComponent

## Shared Hero/NPC info-panel base class. Drives the health/shield/block/grid
## bars on the main bar, the taunt 3D visual, and a dynamic container of
## AlterationIcon widgets (populated from the owner's alterations via
## the aggregate `alteration_changed` signal — no per-type wiring required).

#region ============================== Export ==============================
@export_group("External Nodes")
@export var _spawn: Marker3D
#endregion

#region ============================== Onready ==============================
@onready var _health_bar: ColorRect = %HealthBar
@onready var _shield_bar: ColorRect = %ShieldBar
@onready var _grid_bar: ColorRect = %GridBar
@onready var _block_bar: ColorRect = %BlockBar

# Custom-display state visuals — only present in the LargeHealthBar scene.
@onready var _metal_bar: ColorRect = get_node_or_null("%MetalBar")
@onready var _taunt_shield_icon: TextureRect = get_node_or_null("%TauntShieldIcon")

@onready var _debug_values: Control = %DebugValues
@onready var _health_label: Label = %HealthLabel
@onready var _shield_label: Label = %ShieldLabel
@onready var _level_label: Label = %LevelLabel

@onready var _alterations_container: Container = %AlterationsContainer

@onready var _main_control: Control = %MainControl
#endregion

const TAUNT_VISUAL_SCENE: PackedScene = preload("res://02_Entities/_Shared/Components/HealthBar/Data/taunt_status_visual.tscn")
const ALTERATION_ICON_SCENE: PackedScene = preload("res://02_Entities/_Shared/Components/Alterations/AlterationIcon/alteration_icon.tscn")

var _taunt_visual: Node3D
var _alteration_icons: Dictionary[Alteration.Type, AlterationIcon] = {}


#region ============================== Node base functions ==============================
func _enter_tree() -> void:
	if _owner == null: return
	if _owner.health_bar != null and _owner.health_bar != self:
		Verbose.trace("Override: HealthBarComponent on [" + _owner.entity_name + "]", Verbose.Category.ENTITY_MODULE)
		_owner.health_bar.queue_free()
	_owner.health_bar = self

func _ready() -> void:
	if _health_bar and _health_bar.material:
		_health_bar.material = _health_bar.material.duplicate()
		_set_health_bar_color_by_team()
	if _shield_bar and _shield_bar.material:
		_shield_bar.material = _shield_bar.material.duplicate()
	if _grid_bar and _grid_bar.material:
		_grid_bar.material = _grid_bar.material.duplicate()
	if _metal_bar and _metal_bar.material:
		_metal_bar.material = _metal_bar.material.duplicate()

	var stats := _owner.stats
	var am := _owner.alterations

	_update_health_bar(stats.health, stats.health_max)
	_update_shield_bar(am.shield_stacks, stats.health_max)
	_update_block_bar(am.block_stacks)
	_update_level_value(_owner.progression.level)

	for alteration_type: Alteration.Type in Alteration.Type.values():
		_refresh_icon_for(alteration_type)

	stats.health_changed.connect(_on_health_changed)
	stats.health_max_changed.connect(_on_health_max_changed)
	am.alteration_changed.connect(_on_alteration_changed)
	am.taunted_changed.connect(_update_taunt_visual)
	am.taunted_changed.connect(_update_taunt_shield_icon)
	am.invulnerable_changed.connect(_update_invulnerable_overlay)
	_owner.progression.level_changed.connect(_on_owner_progression_level_changed)

	if _debug_values != null:
		_debug_values.visible = DebugHealthBarOverlay.is_visible()
	DebugHealthBarOverlay.register(_on_debug_overlay_toggled)


func _exit_tree() -> void:
	DebugHealthBarOverlay.unregister(_on_debug_overlay_toggled)


func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	var tracked := _get_tracked_spawn()
	if camera != null and tracked != null:
		_main_control.position = camera.unproject_position(tracked.global_position) - Vector2(_main_control.size.x / 2, 0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("trigger_health_bar_value"):
		DebugHealthBarOverlay.toggle()
		get_viewport().set_input_as_handled()
#endregion


#region ============================== Public API ==============================
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


#region ============================== Virtual hooks ==============================
## Marker tracked in _process to project the panel on screen.
## Heroes override to toggle between fight/tavern markers via apply_display_mode.
func _get_tracked_spawn() -> Marker3D:
	return _spawn
#endregion


#region ============================== Private API ==============================
func _update_health_bar(health: float, health_max: float) -> void:
	if not _health_bar or not _health_bar.material:
		return
	var ratio: float = clamp(float(health) / float(health_max), 0.0, 1.0)
	_health_bar.material.set_shader_parameter("HealthAmount", ratio)
	_health_bar.material.set_shader_parameter("MaxHealth", float(health_max))
	if _grid_bar != null and _grid_bar.material != null:
		_grid_bar.material.set_shader_parameter("MaxHealth", float(health_max))
	if _health_label != null:
		_health_label.text = str(health).pad_decimals(0)


func _update_shield_bar(shield: float, max_health: float) -> void:
	if not _shield_bar or not _shield_bar.material:
		return
	var ratio: float = 0.0
	if max_health > 0:
		ratio = clamp(float(shield) / float(max_health), 0.0, 1.0)
	_shield_bar.material.set_shader_parameter("fill_amount", ratio)
	if _shield_label != null:
		if shield >= 1:
			_shield_label.text = str(shield).pad_decimals(0)
			_shield_label.show()
		else:
			_shield_label.hide()


func _update_block_bar(new_value: float) -> void:
	if _block_bar == null: return
	_block_bar.visible = new_value > 0


func _update_taunt_visual(is_active: bool, _duration: float, _infinite: bool) -> void:
	if is_active and is_instance_valid(_spawn):
		_taunt_visual = TAUNT_VISUAL_SCENE.instantiate()
		_spawn.add_child(_taunt_visual)
	elif not is_active and is_instance_valid(_taunt_visual):
		_taunt_visual.queue_free()


## Gold metallic sheen over the whole bar while the owner is invulnerable.
func _update_invulnerable_overlay(is_active: bool, _duration: float, _infinite: bool) -> void:
	if _metal_bar == null: return
	_metal_bar.visible = is_active


## 2D shield badge on the left of the bar while the owner is taunted,
## complementing the 3D taunt marker.
func _update_taunt_shield_icon(is_active: bool, _duration: float, _infinite: bool) -> void:
	if _taunt_shield_icon == null: return
	_taunt_shield_icon.visible = is_active


func _set_health_bar_color_by_team() -> void:
	if not _health_bar or not _health_bar.material or not _owner:
		return
	var local_player: Player = PlayerManager.get_local_player()
	var health_color: Color
	if local_player == null or _owner.team == local_player.team:
		health_color = Color.LIME_GREEN
	else:
		health_color = Color.INDIAN_RED
	_health_bar.material.set_shader_parameter("HealthColor", health_color)


## Create, update, or remove the AlterationIcon for `alteration_type` depending
## on whether the alteration is currently active on the owner.
func _refresh_icon_for(alteration_type: Alteration.Type) -> void:
	if _alterations_container == null or _owner == null: return
	var am := _owner.alterations
	if am == null: return

	var alteration: Alteration = am.get_alteration(alteration_type)
	if alteration == null: return
	if alteration.display_mode == Alteration.DisplayMode.CUSTOM: return

	var existing: AlterationIcon = _alteration_icons.get(alteration_type)
	if _is_alteration_active(alteration):
		if existing == null:
			existing = ALTERATION_ICON_SCENE.instantiate() as AlterationIcon
			_alterations_container.add_child(existing)
			existing.bind(alteration)
			_alteration_icons[alteration_type] = existing
		existing.set_value(_alteration_display_value(alteration))
	elif existing != null:
		existing.queue_free()
		_alteration_icons.erase(alteration_type)


func _update_level_value(level: int) -> void:
	if _level_label != null:
		_level_label.text = str(level)

static func _is_alteration_active(alteration: Alteration) -> bool:
	if alteration is StackAlteration:
		return (alteration as StackAlteration).stacks > 0
	if alteration is TimedAlteration:
		return (alteration as TimedAlteration).is_active
	if alteration is StateAlteration:
		return (alteration as StateAlteration).is_active
	return false


static func _alteration_display_value(alteration: Alteration) -> Variant:
	if alteration is StackAlteration:
		return (alteration as StackAlteration).stacks
	if alteration is TimedAlteration:
		var t := alteration as TimedAlteration
		if t.is_infinite: return true
		return ceil(t.time_left)
	if alteration is StateAlteration:
		return true
	return null
#endregion


#region ============================== Callbacks ==============================
func _on_health_changed(new_health: int) -> void:
	_update_health_bar(new_health, _owner.stats.health_max)


func _on_health_max_changed(new_max: int) -> void:
	_update_health_bar(_owner.stats.health, new_max)
	_update_shield_bar(_owner.alterations.shield_stacks, new_max)


func _on_alteration_changed(alteration_type: Alteration.Type, _payload: Variant) -> void:
	if alteration_type == Alteration.Type.SHIELD:
		_update_shield_bar(_owner.alterations.shield_stacks, _owner.stats.health_max)
	elif alteration_type == Alteration.Type.BLOCK:
		_update_block_bar(_owner.alterations.block_stacks)
	_refresh_icon_for(alteration_type)


func _on_debug_overlay_toggled(is_visible: bool) -> void:
	if _debug_values != null:
		_debug_values.visible = is_visible


func _on_owner_progression_level_changed(level: int) -> void:
	_update_level_value(level)
#endregion
