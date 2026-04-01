class_name UIEntityBDSRegistry
extends Control

@export var _ui_battle_data_stats_panels: Dictionary[BattleDataStat.Type, UIBattleDataStatsPanel]

@export var _entity_owner: Entity

var _entity_bds_registry: EntityBDSRegistry
var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO

func connect_entity_bds_registry(entity_bds_registry: EntityBDSRegistry) -> void:
	if _entity_bds_registry != null:
		_disconnect_signals()
	_entity_bds_registry = entity_bds_registry
	_clear_panels()
	_populate_panels_from_existing_registry()
	_connect_signals()


func _clear_panels() -> void:
	for panel: UIBattleDataStatsPanel in _ui_battle_data_stats_panels.values():
		panel.clear()


func _populate_panels_from_existing_registry() -> void:
	for bds_type: BattleDataStat.Type in _entity_bds_registry.data_stat_dictionaries.keys():
		if not _ui_battle_data_stats_panels.has(bds_type):
			continue
		for bds: BattleDataStat in _entity_bds_registry.data_stat_dictionaries[bds_type].battle_data_stats.values():
			_ui_battle_data_stats_panels[bds_type].add_battle_data_stat(bds)


func _ready() -> void:
	visible = false
	for bds_type: BattleDataStat.Type in _ui_battle_data_stats_panels.keys():
		_ui_battle_data_stats_panels[bds_type].battle_data_stat_type = bds_type
	Events.entity_clicked.connect(_on_entity_clicked)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("trigger_dps_meter"):
		visible = not visible


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_dragging = true
				_drag_offset = event.global_position - global_position
			else:
				_dragging = false
	elif event is InputEventMouseMotion and _dragging:
		global_position = event.global_position - _drag_offset


func _disconnect_signals() -> void:
	if _entity_bds_registry.new_bds_added.is_connected(_on_entity_bds_registry_new_bds_added):
		_entity_bds_registry.new_bds_added.disconnect(_on_entity_bds_registry_new_bds_added)


func _connect_signals()  -> void:
	if not _entity_bds_registry.new_bds_added.is_connected(_on_entity_bds_registry_new_bds_added):
		_entity_bds_registry.new_bds_added.connect(_on_entity_bds_registry_new_bds_added)


func _on_entity_bds_registry_new_bds_added(bds: BattleDataStat) -> void:
	if not _ui_battle_data_stats_panels.has(bds.type):
		push_error("UIEntityBDSRegistry: adding a battle data stat with unknown type")
		return
	_ui_battle_data_stats_panels[bds.type].add_battle_data_stat(bds)


func _on_entity_clicked(entity: Entity) -> void:
	_entity_owner = entity
	connect_entity_bds_registry(entity.bds_registry)
	
