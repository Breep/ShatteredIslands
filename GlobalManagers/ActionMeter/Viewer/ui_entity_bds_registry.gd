class_name UIEntityBDSRegistry
extends Control

@export var _ui_battle_data_stats_panels: Dictionary[BattleDataStat.Type, UIBattleDataStatsPanel]

var _entity_bds_registry: EntityBDSRegistry

func connect_entity_bds_registry(entity_bds_registry: EntityBDSRegistry) -> void:
	if _entity_bds_registry != null:
		_disconnect_signals()
	_entity_bds_registry = entity_bds_registry
	_connect_signals()


func _ready() -> void:
	for bds_type: BattleDataStat.Type in _ui_battle_data_stats_panels.keys():
		_ui_battle_data_stats_panels[bds_type].battle_data_stat_type = bds_type


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
