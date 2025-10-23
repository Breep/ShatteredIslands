@tool

class_name UIEntityStats
extends Control

var _mirrored: bool
@export var mirrored: bool:
	get: return _mirrored
	set(value):
		_mirrored = value
		_mirror_ui(_mirrored)
	

# ============================== Local Nodes ==============================

#region Local Nodes
@onready var _player_name_label: Label = %PlayerNameLabel
@onready var _health_bar: UIHealthBar = %HealthBar
@onready var _popups_node: Control = %Popups

@onready var _mana_progress_bar: FlexibleProgressBar = %ManaProgressBar
@onready var _mana_bar_container: HBoxContainer = %ManaBarContainer
@onready var _mana_bar_empty_space: Control = %ManaBarEmptySpace
@onready var _mana_bar_viewport_texture: TextureRect = %ManaBarViewportTexture
#endregion

# ============================== Private variables ==============================

var _entity: Entity

# ============================== Node base functions ==============================

func _ready() -> void:
	pass

# ============================== Public functions ==============================

func connect_entity(entity: Entity) -> void:
	_entity = entity
	_disconnect_old_signals()
	_connect_new_signals()
	_update_layout()

# ============================== Private functions ==============================

#region Signals
func _disconnect_old_signals() -> void:
	if _entity == null: return
	if _entity.stats.health_changed.is_connected(_on_entity_health_changed):
		_entity.stats.health_changed.disconnect(_on_entity_health_changed)
	if _entity.stats.health_max_changed.is_connected(_on_entity_max_health_changed):
		_entity.stats.health_max_changed.disconnect(_on_entity_max_health_changed)
	if _entity.stats.mana_changed.is_connected(_on_entity_mana_changed):
		_entity.stats.mana_changed.disconnect(_on_entity_mana_changed)
	if _entity.stats.mana_max_changed.is_connected(_on_entity_mana_max_changed):
		_entity.stats.mana_max_changed.disconnect(_on_entity_mana_max_changed)
	if _entity.stats.poison_stacks_changed.is_connected(_on_entity_poison_stacks_changed):
		_entity.stats.poison_stacks_changed.disconnect(_on_entity_poison_stacks_changed)
	if _entity.stats.armor_stacks_changed.is_connected(_on_entity_armor_stacks_changed):
		_entity.stats.armor_stacks_changed.disconnect(_on_entity_armor_stacks_changed)
	if _entity.stats.ignite_stacks_changed.is_connected(_on_entity_ignite_stacks_changed):
		_entity.stats.ignite_stacks_changed.disconnect(_on_entity_ignite_stacks_changed)
	if _entity.damage_taken.is_connected(_on_entity_damage_taken):
		_entity.damage_taken.disconnect(_on_entity_damage_taken)
	if _entity.heal_taken.is_connected(_on_entity_heal_taken):
		_entity.heal_taken.disconnect(_on_entity_heal_taken)


func _connect_new_signals() -> void:
	if _entity == null: return
	_entity.stats.health_changed.connect(_on_entity_health_changed)
	_entity.stats.health_max_changed.connect(_on_entity_max_health_changed)
	_entity.stats.mana_changed.connect(_on_entity_mana_changed)
	_entity.stats.mana_max_changed.connect(_on_entity_mana_max_changed)
	_entity.stats.poison_stacks_changed.connect(_on_entity_poison_stacks_changed)
	_entity.stats.armor_stacks_changed.connect(_on_entity_armor_stacks_changed)
	_entity.stats.ignite_stacks_changed.connect(_on_entity_ignite_stacks_changed)
	_entity.damage_taken.connect(_on_entity_damage_taken)
	_entity.heal_taken.connect(_on_entity_heal_taken)
	_entity.stack_taken.connect(_on_entity_stack_taken)
#endregion


func _update_layout() -> void:
	if _entity == null: return
	_health_bar.max_health = _entity.stats.health_max
	_health_bar.current_health = _entity.stats.health
	_health_bar.poison_stacks = _entity.stats.poison_stacks
	_health_bar.armor_stacks = _entity.stats.armor_stacks


func _mirror_ui(is_mirrored: bool) -> void:
	if not is_node_ready(): return
	if is_mirrored:
		_player_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_player_name_label.text = _player_name_label.text.trim_prefix(" ").trim_suffix(" ") # TODO REMOVE this (Text clipping with current font)
		_player_name_label.text = _player_name_label.text + " "
		_mana_bar_container.move_child(_mana_bar_empty_space, 0)
		_mana_bar_viewport_texture.flip_h = true
	else:
		_player_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		_player_name_label.text = _player_name_label.text.trim_prefix(" ").trim_suffix(" ") # TODO REMOVE this (Text clipping with current font)
		_player_name_label.text = " " + _player_name_label.text
		_mana_bar_container.move_child(_mana_bar_viewport_texture, 0)
		_mana_bar_viewport_texture.flip_h = false

# ============================== Callbacks ==============================

#region Callbacks
func _on_entity_health_changed(health: int) -> void:
	_health_bar.current_health = health


func _on_entity_max_health_changed(max_health: int) -> void:
	_health_bar.max_health = max_health


func _on_entity_mana_changed(mana: int) -> void:
	_mana_progress_bar.set_bar_value(mana)


func _on_entity_mana_max_changed(max_mana: int) -> void:
	_mana_progress_bar.set_max_value(max_mana)


func _on_entity_poison_stacks_changed(poison_stacks: int) -> void:
	_health_bar.poison_stacks = poison_stacks


func _on_entity_armor_stacks_changed(armor_stacks: int) -> void:
	_health_bar.armor_stacks = armor_stacks


func _on_entity_ignite_stacks_changed(ignite_stacks: int) -> void:
	_health_bar.ignite_stacks = ignite_stacks
#endregion


func _on_entity_damage_taken(_entity_ref: Entity, damage: int, damage_type: Utils.DamageType, is_critical: bool, blocked_by_armor) -> void:
	var popup_pos: Vector2
	if blocked_by_armor:
		popup_pos = _health_bar.get_armor_popup_global_pos()
	else:
		popup_pos = _health_bar.get_health_popup_global_position()
	var popup := UIDamagePopup.new().setup_damage(damage, damage_type, popup_pos, is_critical, blocked_by_armor)
	_popups_node.add_child(popup)


func _on_entity_heal_taken(_entity_ref: Entity, heal_amount: int) -> void:
	var popup_pos: Vector2 = _health_bar.get_health_popup_global_position()
	var popup := UIDamagePopup.new().setup_damage(heal_amount, Utils.DamageType.HEAL, popup_pos)
	_popups_node.add_child(popup)


func _on_entity_stack_taken(_entity_ref: Entity, stack_type: Utils.StackType, stack_number: int) -> void:
	var popup_pos: Vector2 = _health_bar.get_armor_popup_global_pos()
	var popup := UIDamagePopup.new().setup_stack(stack_number, stack_type, popup_pos)
	_popups_node.add_child(popup)
