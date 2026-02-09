class_name EntityInfoPanel2D
extends Control

#region ============================== Constants =============================
const COLOR_TEAM_LOCAL = Color(1, 1, 1, 1)
const COLOR_TEAM_ENEMY = Color(1, 1, 1, 1)
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
@export var _stunned_control: Control
@export var _stunned_label: Label
@export_subgroup("Status/Taunt")
@export var _taunted_control: Control
@export var _taunted_label: Label
@export_subgroup("Status/Silence")
@export var _silenced_control: Control
@export var _silenced_label: Label
@export_subgroup("Status/Invulnerability")
@export var _invulnerable_control: Control
@export var _invulnerable_label: Label
@export_subgroup("Status/Untargetable")
@export var _untargetable_control: Control
@export var _untargetable_label: Label


@export_subgroup("Misc")
@export var _resource_points_container: HBoxContainer

@export_group("External Nodes")
@export var _owner_entity: Entity
#endregion

@onready var _rank_visualizer: UIRankViewer = %RankViewer

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

func _on_status_stunned_changed(is_active: bool) -> void:
	if not _stunned_control: return
	if is_active: _stunned_control.show()
	else: _stunned_control.hide()

func _on_status_taunted_changed(is_active: bool) -> void:
	if not _taunted_control: return
	if is_active: _taunted_control.show()
	else: _taunted_control.hide()

func _on_status_silenced_changed(is_active: bool) -> void:
	if not _silenced_control: return
	if is_active: _silenced_control.show()
	else: _silenced_control.hide()

func _on_status_invulnerable_changed(is_active: bool) -> void:
	if not _invulnerable_control: return
	if is_active: _invulnerable_control.show()
	else: _invulnerable_control.hide()

func _on_status_untargetable_changed(is_active: bool) -> void:
	if not _untargetable_control: return
	if is_active: _untargetable_control.show()
	else: _untargetable_control.hide()
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
	
	# Determine the color based on team affiliation
	var health_color: Color
	var local_player: Player = PlayerManager.get_local_player()
	
	if local_player == null:
		# Fallback to default green if no local player
		health_color = Color(0.11, 0.64, 0.08, 1.0)
	elif _owner_entity is Hero:
		var hero: Hero = _owner_entity as Hero
		# Check if this hero belongs to the local player
		if local_player.hero == hero:
			# Local player: green-yellow
			health_color = Color.GREEN_YELLOW
		elif hero.team == local_player.team:
			# Ally: green
			health_color = Color(0.11, 0.64, 0.08, 1.0)
		else:
			# Enemy: red
			health_color = Color(0.8, 0.1, 0.1, 1.0)
	else:
		# For non-hero entities, use team-based logic only
		if _owner_entity.team == local_player.team:
			health_color = Color(0.11, 0.64, 0.08, 1.0)  # Ally green
		else:
			health_color = Color(0.8, 0.1, 0.1, 1.0)  # Enemy red
	
	_health_bar.material.set_shader_parameter("HealthColor", health_color)
