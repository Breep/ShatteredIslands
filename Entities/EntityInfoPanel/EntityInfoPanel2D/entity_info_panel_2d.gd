class_name EntityInfoPanel2D
extends Control

#region ============================== Constants =============================
const COLOR_PLAYER_LOCAL = Color.CADET_BLUE
const COLOR_TEAM_ALLY = Color.WEB_GREEN
const COLOR_TEAM_ENEMY = Color.DARK_RED
#endregion

#region ============================== Export ==============================
@export_group("Local Nodes")
@export var _entity_label: RichTextLabel

@export_subgroup("Bars")
@export var _health_bar: ColorRect
@export var _mana_bar: ColorRect
@export var _shield_bar: ColorRect
@export var _grid_bar: ColorRect

@export_subgroup("Stack Counters")
@export_subgroup("Stack Counters/Ignite")
@export var _ignite_control: Control
@export var _ignite_label: Label
@export_subgroup("Stack Counters/Necrosis")
@export var _necrosis_control: Control
@export var _necrosis_label: Label
@export_subgroup("Stack Counters/Poison")
@export var _poison_control: Control
@export var _poison_label: Label
@export_subgroup("Stack Counters/Regen")
@export var _regen_control: Control
@export var _regen_label: Label

@export_subgroup("Status")
@export_subgroup("Status/Stun")
@export var _stun_control: Control
@export var _stun_label: Label
@export var _stun_progress_bar: ProgressBar
@export_subgroup("Status/Taunt")
@export var _taunt_control: Control
@export var _taunt_label: Label
@export var _taunt_progress_bar: ProgressBar
@export_subgroup("Status/Silence")
@export var _silence_control: Control
@export var _silence_label: Label
@export var _silence_progress_bar: ProgressBar
@export_subgroup("Status/Invulnerability")
@export var _invulnerable_control: Control
@export var _invulnerable_label: Label
@export var _invulnerable_progress_bar: ProgressBar
@export_subgroup("Status/Untargetable")
@export var _untargetable_control: Control
@export var _untargetable_label: Label
@export var _untargetable_progress_bar: ProgressBar

@export_subgroup("Misc")
@export var _resource_points_container: HBoxContainer

@export_group("External Nodes")
@export var _owner_entity: Entity
@export var _info_panel_spawn: Marker3D
#endregion

@onready var _rank_visualizer: UIRankViewer = %RankViewer

var _stun_needs_update: bool = false
var _taunt_needs_update: bool = false
var _silence_needs_update: bool = false
var _invulnerable_needs_update: bool = false
var _untargetable_needs_update: bool = false

#region ============================== Node base functions ==============================
func _ready() -> void:
	# Connect entity signals
	_rank_visualizer.connect_entity(_owner_entity)
	
	# Hide Stacks control on start
	_ignite_control.hide()
	_necrosis_control.hide()
	_poison_control.hide()
	_regen_control.hide()
	
	# Duplicate materials to avoid shared material issues
	if _health_bar and _health_bar.material:
		_health_bar.material = _health_bar.material.duplicate()
		_set_health_bar_color_by_team()
	if _mana_bar and _mana_bar.material:
		_mana_bar.material = _mana_bar.material.duplicate()
	if _shield_bar and _shield_bar.material:
		_shield_bar.material = _shield_bar.material.duplicate()
	if _grid_bar and _grid_bar.material:
		_grid_bar.material = _grid_bar.material.duplicate()
	
	var stats = _owner_entity.stats
	var conditions = _owner_entity.conditions
	var entity_name = _owner_entity.name
	var status = _owner_entity.status_module
	
	# Initialize entity name
	_update_entity_label(entity_name)
	
	# Initialize health/mana bars
	_update_health_bar(stats.health, stats.health_max)
	_update_mana_bar(stats.mana, stats.mana_max)
	
	# Connect stat signals
	stats.health_changed.connect(_on_health_changed)
	stats.health_max_changed.connect(_on_health_max_changed)
	stats.mana_changed.connect(_on_mana_changed)
	stats.mana_max_changed.connect(_on_mana_max_changed)
	
	# Initialize stack displays
	_update_ignite_label(conditions.ignite_stacks)
	_update_necrosis_label(conditions.necrosis_stacks)
	_update_poison_label(conditions.poison_stacks)
	_update_regen_label(conditions.regen_stacks)
	_update_shield_bar(conditions.shield_stacks, stats.health_max)
	
	# Connect condition signals
	conditions.ignite_stacks_changed.connect(_update_ignite_label)
	conditions.necrosis_stacks_changed.connect(_update_necrosis_label)
	conditions.shield_stacks_changed.connect(_on_armor_changed)
	conditions.poison_stacks_changed.connect(_update_poison_label)
	conditions.regen_stacks_changed.connect(_update_regen_label)
	
	# Connect status signals
	status.stunned_changed.connect(_on_status_stunned_changed)
	status.taunted_changed.connect(_on_status_taunted_changed)
	status.silenced_changed.connect(_on_status_silenced_changed)
	status.invulnerable_changed.connect(_on_status_invulnerable_changed)
	status.untargetable_changed.connect(_on_status_untargetable_changed)

	_stun_control.hide()
	_taunt_control.hide()
	_silence_control.hide()
	_invulnerable_control.hide()
	_untargetable_control.hide()


func _process(_delta: float) -> void:
	var camera = get_viewport().get_camera_3d()
	if camera != null and _info_panel_spawn != null:
		position = camera.unproject_position(_info_panel_spawn.global_position) + Vector2(-size.x/2, 0)
	_update_stun_info()
	_update_taunt_info()
	_update_silence_info()
	_update_invulnerable_info()
	_update_untargetable_info()
#endregion

#region ============================== Public API ==============================
func init(entity: Entity) -> void:
	_owner_entity = entity
#endregion

#region ============================== Private API =============================
func _update_health_bar(health: float, health_max: float) -> void:
	if not _health_bar or not _health_bar.material:
		return
	var ratio = clamp(float(health) / float(health_max), 0.0, 1.0)
	_health_bar.material.set_shader_parameter("HealthAmount", ratio)
	_health_bar.material.set_shader_parameter("MaxHealth", float(health_max))
	_grid_bar.material.set_shader_parameter("MaxHealth", float(health_max))

func _update_mana_bar(mana: float, mana_max: float) -> void:
	if not _mana_bar or not _mana_bar.material:
		return
	var ratio = clamp(float(mana) / float(mana_max), 0.0, 1.0)
	_mana_bar.material.set_shader_parameter("HealthAmount", ratio)
	_mana_bar.material.set_shader_parameter("MaxHealth", float(mana_max))

func _update_shield_bar(armor_amount: float, max_health: float) -> void:
	if not _shield_bar or not _shield_bar.material: return
	var ratio = 0.0
	if max_health > 0:
		ratio = clamp(float(armor_amount) / float(max_health), 0.0, 1.0)
	_shield_bar.material.set_shader_parameter("fill_amount", ratio)

func _update_ignite_label(amount: int) -> void:
	if not _ignite_label: return
	if amount > 0:
		_ignite_label.text = str(amount)
		_ignite_label.show()
		_ignite_control.show()
	else:
		_ignite_control.hide()
		_ignite_label.hide()

func _update_necrosis_label(amount: int) -> void:
	if not _necrosis_label:
		return
	if amount > 0:
		_necrosis_label.text = str(amount)
		_necrosis_label.show()
		_necrosis_control.show()
	else:
		_necrosis_label.hide()
		_necrosis_label.hide()

func _update_poison_label(amount: float) -> void:
	if not _poison_label: return
	if amount > 0:
		_poison_label.text = str(int(amount))
		_poison_label.show()
		_poison_control.show()
	else:
		_poison_label.hide()
		_poison_control.hide()

func _update_regen_label(amount: float) -> void:
	if not _regen_label: return
	if amount > 0:
		_regen_label.text = str(int(amount))
		_regen_label.show()
		_regen_control.show()
	else:
		_regen_label.hide()
		_regen_control.hide()


func _update_entity_label(entity_name: String) -> void:
	if not _entity_label: return
	_entity_label.text = entity_name


func _update_stun_info() -> void:
	if not _stun_needs_update: return
	var status: AlterationsModule = _owner_entity.status_module
	var duration: float = status.get_remaining_time(Status.Type.STUN)
	_stun_label.text = str(duration).pad_decimals(1)
	_stun_progress_bar.value = duration


func _update_taunt_info() -> void:
	if not _taunt_needs_update: return
	var status: AlterationsModule = _owner_entity.status_module
	var duration: float = status.get_remaining_time(Status.Type.TAUNT)
	_taunt_label.text = str(duration).pad_decimals(1)
	_taunt_progress_bar.value = duration


func _update_silence_info() -> void:
	if not _silence_needs_update: return
	var status: AlterationsModule = _owner_entity.status_module
	var duration: float = status.get_remaining_time(Status.Type.SILENCE)
	_silence_label.text = str(duration).pad_decimals(1)
	_silence_progress_bar.value = duration


func _update_invulnerable_info() -> void:
	if not _invulnerable_needs_update: return
	var status: AlterationsModule = _owner_entity.status_module
	var duration: float = status.get_remaining_time(Status.Type.INVULNERABLE)
	_invulnerable_label.text = str(duration).pad_decimals(1)
	_invulnerable_progress_bar.value = duration


func _update_untargetable_info() -> void:
	if not _untargetable_needs_update: return
	var status: AlterationsModule = _owner_entity.status_module
	var duration: float = status.get_remaining_time(Status.Type.UNTARGETABLE)
	_untargetable_label.text = str(duration).pad_decimals(1)
	_untargetable_progress_bar.value = duration
#endregion

#region ============================== Callbacks =============================
func _on_mana_changed(new_value: int) -> void:
	_update_mana_bar(new_value, _owner_entity.stats.mana_max)


func _on_mana_max_changed(new_max: int) -> void:
	_update_mana_bar(_owner_entity.stats.mana, new_max)


func _on_armor_changed(new_amount: float) -> void:
	_update_shield_bar(new_amount, _owner_entity.stats.health_max)


func _on_health_changed(new_health: int) -> void:
	_update_health_bar(new_health, _owner_entity.stats.health_max)


func _on_health_max_changed(new_max: int) -> void:
	_update_health_bar(_owner_entity.stats.health, new_max)
	_update_shield_bar(_owner_entity.conditions.shield_stacks, new_max)


func _on_status_stunned_changed(is_active: bool, duration: float, infinite: bool) -> void:
	if not _stun_control: return
	if is_active:
		_stun_control.show()
		_stun_progress_bar.max_value = duration
		if infinite:
			_stun_needs_update = false
			_stun_label.text = "INF"
		else:
			_stun_needs_update = true
	else:
		_stun_control.hide()
		_stun_needs_update = false
	_stun_progress_bar.value = duration


func _on_status_taunted_changed(is_active: bool, duration: float, infinite: bool) -> void:
	if not _taunt_control: return
	if is_active:
		_taunt_control.show()
		_taunt_progress_bar.max_value = duration
		if infinite:
			_taunt_needs_update = false
			_taunt_label.text = "INF"
		else:
			_taunt_needs_update = true
	else:
		_taunt_control.hide()
		_taunt_needs_update = false


func _on_status_silenced_changed(is_active: bool, duration: float, infinite: bool) -> void:
	if not _silence_control: return
	if is_active:
		_silence_control.show()
		_silence_progress_bar.max_value = duration
		if infinite:
			_silence_needs_update = false
			_silence_label.text = "INF"
		else:
			_silence_needs_update = true
	else:
		_silence_control.hide()
		_silence_needs_update = false


func _on_status_invulnerable_changed(is_active: bool, duration: float, infinite: bool) -> void:
	if not _invulnerable_control: return
	if is_active:
		_invulnerable_control.show()
		_invulnerable_progress_bar.max_value = duration
		if infinite:
			_invulnerable_needs_update = false
			_invulnerable_label.text = "INF"
		else:
			_invulnerable_needs_update = true
	else:
		_invulnerable_control.hide()
		_invulnerable_needs_update = false


func _on_status_untargetable_changed(is_active: bool, duration: float, infinite: bool) -> void:
	if not _untargetable_control: return
	if is_active:
		_untargetable_control.show()
		_untargetable_progress_bar.max_value = duration
		if infinite:
			_untargetable_needs_update = false
			_untargetable_label.text = "INF"
		else:
			_untargetable_needs_update = true
	else:
		_untargetable_control.hide()
		_untargetable_needs_update = false
#endregion

#region ============================== Resources Visualization ==============================
# TODO MONSTRUOSITE A DETRUIRE
## Update the resource points display (e.g. for Dark Knight combo points)
## Creates simple visual points if needed.
func update_resource_points(current: int, max_val: int) -> void:
	if not _resource_points_container: return
	
	# Create points if count mismatch
	var child_count = _resource_points_container.get_child_count()
	if child_count != max_val:
		for child in _resource_points_container.get_children():
			child.queue_free()
		
		# Create new points
		for i in range(max_val):
			var point = ColorRect.new()
			point.custom_minimum_size = Vector2(10, 10)
			point.color = Color.GRAY
			# Optional: make it round if we had a texture or shader, sticking to simple rect for now
			# unless I add a stylebox.
			_resource_points_container.add_child(point)
	
	# Update status
	var children = _resource_points_container.get_children()
	for i in range(children.size()):
		var point: ColorRect = children[i] as ColorRect
		if i < current:
			point.color = Color.ORANGE # Active Color
		else:
			point.color = Color(0.2, 0.2, 0.2, 0.5) # Inactive Color

# ============================== Private ==============================

func _set_health_bar_color_by_team() -> void:
	if not _health_bar or not _health_bar.material or not _owner_entity:
		return
	
	var health_color: Color
	var local_player: Player = PlayerManager.get_local_player()
	if local_player == null:
		health_color = COLOR_TEAM_ALLY
	elif _owner_entity is Hero:
		var hero: Hero = _owner_entity as Hero
		if local_player.hero == hero: health_color = COLOR_PLAYER_LOCAL
		elif hero.team == local_player.team: health_color = COLOR_TEAM_ALLY
		else: health_color = COLOR_TEAM_ENEMY
	else:
		if _owner_entity.team == local_player.team: health_color = COLOR_TEAM_ALLY
		else: health_color = COLOR_TEAM_ENEMY
	
	_health_bar.material.set_shader_parameter("HealthColor", health_color)
