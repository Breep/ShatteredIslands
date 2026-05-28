class_name EntityStatsViewer
extends Node

## Viewer invoqué à la demande (Alt + clic gauche court sur une entité) : affiche
## les stats Mono de l'entité dans un ItemList projeté à l'écran à côté d'elle
## (comme la healthbar). Chaque item = icône + valeur, nom de la stat au survol
## (tooltip). Les valeurs suivent les stats en live via les signaux *_changed.
## Les items (icône + "0") sont déjà présents dans la scène pour visualisation en
## éditeur — leur ordre DOIT suivre l'ordre de _STATS.

#region ============================== Constants ==============================
const _SCREEN_OFFSET: Vector2 = Vector2(40, -140)

# Ordre = ordre des items dans la scène. { StatType: { name (tooltip), sig (signal float 1 arg) } }
const _STATS: Dictionary = {
	EntityStats.StatType.HEALTH_MAX:      {"name": "Vie max",                "sig": &"health_max_changed"},
	EntityStats.StatType.MANA_MAX:        {"name": "Mana max",               "sig": &"mana_max_changed"},
	EntityStats.StatType.MANA_REGEN:      {"name": "Régén. mana",            "sig": &"mana_regen_changed"},
	EntityStats.StatType.AD:              {"name": "Dégâts d'attaque",       "sig": &"attack_damage_changed"},
	EntityStats.StatType.AS:              {"name": "Vitesse d'attaque",      "sig": &"attack_speed_changed"},
	EntityStats.StatType.AP:              {"name": "Puissance",              "sig": &"attack_power_changed"},
	EntityStats.StatType.AR:              {"name": "Portée",                 "sig": &"attack_range_changed"},
	EntityStats.StatType.MS:              {"name": "Vitesse de déplacement", "sig": &"movement_speed_changed"},
	EntityStats.StatType.ARMOR:           {"name": "Armure",                 "sig": &"armor_changed"},
	EntityStats.StatType.MAGIC_RESIST:    {"name": "Résist. magique",        "sig": &"magic_resistance_changed"},
	EntityStats.StatType.POISON_RESIST:   {"name": "Résist. poison",         "sig": &"poison_resistance_changed"},
	EntityStats.StatType.CRIT_CHANCE:     {"name": "Chance de critique",     "sig": &"crit_chance_changed"},
	EntityStats.StatType.CRIT_MULT:       {"name": "Multi. critique",        "sig": &"crit_mult_changed"},
	EntityStats.StatType.CRIT_RESISTANCE: {"name": "Résist. critique",       "sig": &"crit_resistance_changed"},
	EntityStats.StatType.DODGE:           {"name": "Esquive",                "sig": &"dodge_changed"},
	EntityStats.StatType.LIFESTEAL:       {"name": "Vol de vie",             "sig": &"lifesteal_changed"},
	EntityStats.StatType.SCALE:           {"name": "Taille",                 "sig": &"scale_changed"},
}
#endregion

#region ============================== Onready ==============================
@onready var _main: PanelContainer = %MainControl
@onready var _list: ItemList = %ItemList
#endregion

#region ============================== Private variables ==============================
var _entity: Entity = null
var _connections: Array[Dictionary] = []
#endregion

#region ============================== Node base functions ==============================
func _ready() -> void:
	return
	_apply_tooltips()
	_main.hide()
	Events.entity_alt_clicked.connect(_on_entity_alt_clicked)


func _process(_delta: float) -> void:
	return
	if not _main.visible: return
	if not is_instance_valid(_entity):
		_unbind()
		return
	var camera := get_viewport().get_camera_3d()
	if camera != null:
		_main.position = _panel_position(camera.unproject_position(_entity.global_position))


# Position écran du panneau à partir de la position projetée de l'entité.
# Surchargé par EntityStatsWriter pour s'ancrer à gauche au lieu de droite.
func _panel_position(entity_screen_pos: Vector2) -> Vector2:
	return entity_screen_pos + _SCREEN_OFFSET
#endregion

#region ============================== Public functions ==============================
func bind(entity: Entity) -> void:
	if entity == null: return
	_unbind()
	_entity = entity
	var stats: EntityStats = entity.stats
	var idx: int = 0
	for stat_type: EntityStats.StatType in _STATS:
		_set_item_value(idx, stats.get_stat(stat_type))
		var sig: StringName = _STATS[stat_type]["sig"]
		var callback: Callable = _on_stat_changed.bind(idx)
		stats.connect(sig, callback)
		_connections.append({"sig": sig, "cb": callback})
		idx += 1
	if not entity.died.is_connected(_on_entity_died):
		entity.died.connect(_on_entity_died)
	_main.show()


func close() -> void:
	_unbind()
#endregion

#region ============================== Private functions ==============================
func _apply_tooltips() -> void:
	var idx: int = 0
	for stat_type: EntityStats.StatType in _STATS:
		if idx < _list.item_count:
			_list.set_item_tooltip(idx, _STATS[stat_type]["name"])
		idx += 1


func _set_item_value(idx: int, value: float) -> void:
	if idx >= _list.item_count: return
	if is_equal_approx(value, roundf(value)):
		_list.set_item_text(idx, "%d" % int(value))
	else:
		_list.set_item_text(idx, "%.1f" % value)


func _unbind() -> void:
	if is_instance_valid(_entity):
		var stats: EntityStats = _entity.stats
		for connection: Dictionary in _connections:
			if stats.is_connected(connection["sig"], connection["cb"]):
				stats.disconnect(connection["sig"], connection["cb"])
		if _entity.died.is_connected(_on_entity_died):
			_entity.died.disconnect(_on_entity_died)
	_connections.clear()
	_entity = null
	_main.hide()
#endregion

#region ============================== Callbacks ==============================
func _on_stat_changed(value: float, idx: int) -> void:
	_set_item_value(idx, value)


func _on_entity_alt_clicked(entity: Entity) -> void:
	# Re-clic sur la même entité => toggle off ; sinon on bascule sur la nouvelle.
	if _main.visible and entity == _entity:
		_unbind()
	else:
		bind(entity)


func _on_entity_died(_self_ref: Entity) -> void:
	_unbind()
#endregion


func _on_apply_button_pressed() -> void:
	pass # Replace with function body.


func _on_clear_button_pressed() -> void:
	pass # Replace with function body.
