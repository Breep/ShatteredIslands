class_name UIDPSMeter
extends Control

@onready var _tab_bar: HBoxContainer = $MainVBox/TabBar
@onready var _global_bds_viewers_container: UIBDSViewersContainer = %GlobalBDSViewersContainer
@onready var _hero_bds_viewers_container: UIBDSViewersContainer = %HeroBDSViewersContainer

var _heroes: Array[Hero]
var _selected_hero: Hero
var _current_bds_type: BattleDataStat.Type = BattleDataStat.Type.DAMAGE_DONE


#region ============================== Node base functions ==============================
func _ready() -> void:
	_tab_bar.bds_type_changed.connect(_on_tab_bar_bds_type_changed)
#endregion



#region ============================== Public functions ==============================
func set_heroes(heroes: Array[Hero]) -> void:
	_disconnect_heroes()
	_heroes = heroes
	_connect_heroes()
	_rebuild_global_bds_viewers()
#endregion



#region ============================== Private functions ==============================
func _connect_heroes() -> void:
	for hero: Hero in _heroes:
		if not hero.bds_registry.new_global_bds_added.is_connected(_on_new_global_bds_added):
			hero.bds_registry.new_global_bds_added.connect(_on_new_global_bds_added)
		if not hero.bds_registry.new_bds_added.is_connected(_on_new_bds_added):
			hero.bds_registry.new_bds_added.connect(_on_new_bds_added)


func _disconnect_heroes() -> void:
	for hero: Hero in _heroes:
		if hero.bds_registry.new_global_bds_added.is_connected(_on_new_global_bds_added):
			hero.bds_registry.new_global_bds_added.disconnect(_on_new_global_bds_added)
		if hero.bds_registry.new_bds_added.is_connected(_on_new_bds_added):
			hero.bds_registry.new_bds_added.disconnect(_on_new_bds_added)


func _rebuild_global_bds_viewers() -> void:
	_global_bds_viewers_container.clear()
	for hero: Hero in _heroes:
		var global_bds: BattleDataStat = hero.bds_registry.global_data_stats.get(_current_bds_type)
		if global_bds != null:
			_global_bds_viewers_container.add_battle_data_stat(global_bds)


func _rebuild_hero_bds_viewers(hero: Hero) -> void:
	_selected_hero = hero
	_hero_bds_viewers_container.clear()
	if _selected_hero == null: return
	var bds_dict: EntityBDSRegistry.BattleDataStatDictionary = _selected_hero.bds_registry.data_stat_dictionaries[_current_bds_type]
	for bds: BattleDataStat in bds_dict.battle_data_stats.values():
		_hero_bds_viewers_container.add_battle_data_stat(bds)
#endregion



#region ============================== Callbacks ==============================
func _on_tab_bar_bds_type_changed(new_bds_type: BattleDataStat.Type) -> void:
	_current_bds_type = new_bds_type
	_rebuild_global_bds_viewers()
	_rebuild_hero_bds_viewers(_selected_hero)


func _on_new_global_bds_added(bds: BattleDataStat) -> void:
	if bds.type != _current_bds_type: return
	_global_bds_viewers_container.add_battle_data_stat(bds)


func _on_new_bds_added(bds: BattleDataStat) -> void:
	if _selected_hero == null: return
	if bds.type != _current_bds_type: return
	if not _selected_hero.bds_registry.data_stat_dictionaries[_current_bds_type].battle_data_stats.values().has(bds): return
	_hero_bds_viewers_container.add_battle_data_stat(bds)
#endregion
