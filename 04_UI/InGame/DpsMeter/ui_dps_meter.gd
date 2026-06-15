class_name UIDPSMeter
extends Control

@onready var _tab_bar: HBoxContainer = $MainVBox/TabBar
@onready var _global_bds_viewers_container: UIBDSViewersContainer = %GlobalBDSViewersContainer
@onready var _hero_bds_viewers_container: UIBDSViewersContainer = %HeroBDSViewersContainer

var _heroes: Array[Entity]
var _selected_hero: Entity
var _current_bds_type: BattleDataStat.Type = BattleDataStat.Type.DAMAGE_DONE
var _viewer_to_hero: Dictionary[UIBDSViewer, Entity]


#region ============================== Node base functions ==============================
func _ready() -> void:
	_first_clear_all()
	_tab_bar.bds_type_changed.connect(_on_tab_bar_bds_type_changed)
#endregion



#region ============================== Public functions ==============================
func set_heroes(heroes: Array[Entity]) -> void:
	_disconnect_heroes()
	_heroes = heroes
	_connect_heroes()
	_rebuild_global_bds_viewers()
	_rebuild_hero_bds_viewers(null)
#endregion



#region ============================== Private functions ==============================
func _first_clear_all() -> void:
	for child in _global_bds_viewers_container.get_children():
		child.queue_free()
	for child in _hero_bds_viewers_container.get_children():
		child.queue_free()
	_global_bds_viewers_container.set_show_percent(false)
	_hero_bds_viewers_container.set_show_percent(false)
	_global_bds_viewers_container.set_selectable(true)
	_global_bds_viewers_container.viewer_selected.connect(_on_global_viewer_selected)


func _connect_heroes() -> void:
	for hero: Entity in _heroes:
		if not is_instance_valid(hero): return
		if not hero.bds_registry.new_bds_added.is_connected(_on_new_bds_added):
			hero.bds_registry.new_bds_added.connect(_on_new_bds_added)


func _disconnect_heroes() -> void:
	for hero: Entity in _heroes:
		if not is_instance_valid(hero): return
		if hero.bds_registry.new_bds_added.is_connected(_on_new_bds_added):
			hero.bds_registry.new_bds_added.disconnect(_on_new_bds_added)


func _rebuild_global_bds_viewers() -> void:
	_global_bds_viewers_container.clear()
	_viewer_to_hero.clear()
	for hero: Entity in _heroes:
		var global_bds: BattleDataStat = hero.bds_registry.get_or_create_global_bds(_current_bds_type)
		_global_bds_viewers_container.add_battle_data_stat(global_bds, hero.entity_name)
		var viewer: UIBDSViewer = _global_bds_viewers_container._battle_data_stat_viewers.back()
		_viewer_to_hero[viewer] = hero


func _rebuild_hero_bds_viewers(hero: Entity) -> void:
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


func _on_global_viewer_selected(viewer: UIBDSViewer) -> void:
	if viewer == null:
		_rebuild_hero_bds_viewers(null)
		return
	var hero: Entity = _viewer_to_hero.get(viewer)
	if hero == null: return
	_rebuild_hero_bds_viewers(hero)


func _on_new_bds_added(bds: BattleDataStat) -> void:
	if _selected_hero == null: return
	if bds.type != _current_bds_type: return
	if not _selected_hero.bds_registry.data_stat_dictionaries[_current_bds_type].battle_data_stats.values().has(bds): return
	_hero_bds_viewers_container.add_battle_data_stat(bds)
#endregion
