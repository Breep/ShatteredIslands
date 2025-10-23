class_name UIEntityStats
extends Control

# ============================== Local Nodes ==============================

#region Local Nodes
@onready var _player_name_label: Label = %PlayerNameLabel
@onready var _health_bar: UIHealthBar = %HealthBar
@onready var _mana_progress_bar: FlexibleProgressBar = %ManaProgressBar
@onready var _popups_node: Control = %Popups
#endregion

# ============================== Private variables ==============================

var _entity: Entity

# ============================== Public functions ==============================

func connect_entity(entity: Entity) -> void:
	_entity = entity
	_disconnect_old_signals()
	_connect_new_signals()
	_update_layout()

# ============================== Private functions ==============================

#region Private functions
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


func _update_layout() -> void:
	if _entity == null: return
	_health_bar.max_health = _entity.stats.health_max
	_health_bar.current_health = _entity.stats.health
	_health_bar.poison_stacks = _entity.stats.poison_stacks
	_health_bar.armor_stacks = _entity.stats.armor_stacks
#endregion

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


func _on_entity_damage_taken(_entity_ref: Entity, damage: int, damage_type: Utils.DamageType, is_critical: bool) -> void:
	var popup_pos: Vector2 = _health_bar.get_damage_popup_global_position(damage_type)
	var popup := UIDamagePopup.new().setup(damage, damage_type, popup_pos, is_critical)
	_popups_node.add_child(popup)


func _on_entity_heal_taken(_entity_ref: Entity, heal_amount: int) -> void:
	var popup_pos: Vector2 = _health_bar.get_damage_popup_global_position(Utils.DamageType.HEAL)
	var popup := UIDamagePopup.new().setup(heal_amount, Utils.DamageType.HEAL, popup_pos)
	_popups_node.add_child(popup)
