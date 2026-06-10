class_name EntityStatsViewer
extends Node

## Viewer invoqué à la demande (Alt + clic gauche court sur une entité) : affiche
## les stats Mono de l'entité dans un ItemList projeté à l'écran à côté d'elle
## (comme la healthbar). Chaque item = icône + valeur, nom de la stat au survol
## (tooltip). Les valeurs suivent les stats en live via les signaux *_changed.
## Les items (icône + "0") sont déjà présents dans la scène pour visualisation en
## éditeur — leur ordre DOIT suivre l'ordre de _STATS.
## En mode prototyping, les items deviennent cliquables et deux panneaux (stat
## modifier + level) permettent de bricoler l'entité en direct.

#region ============================== Constants ==============================
const _SCREEN_OFFSET: Vector2 = Vector2(40, -140)

# Id du StatModifier injecté par le panneau de prototyping (un seul par stat).
const PROTOTYPING_MODIFIER_ID: StringName = &"Prototyping"

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
	EntityStats.StatType.AOE_SIZE:        {"name": "Taille des AoE",         "sig": &"aoe_size_changed"},
}
#endregion

#region ============================== Prototyping ==============================
@export var _prototyping: bool = false
#endregion

#region ============================== Onready ==============================
@onready var _main: Panel = %MainControl
@onready var _list: ItemList = %ItemList
@onready var _stat_name_label: Label = %StatNameLabel
@onready var _stat_modifier_text_edit: TextEdit = %StatModifierTextEdit
@onready var _entity_stats_writer: Control = %EntityStatsWriter
@onready var _entity_level_writer: Control = %EntityLevelWriter
@onready var _level_value_label: Label = %LevelValueLabel
#endregion

#region ============================== Private variables ==============================
var _entity: Entity = null
var _connections: Array[Dictionary] = []
var _selected_stat_type: EntityStats.StatType = EntityStats.StatType.HEALTH_MAX
#endregion

#region ============================== Node base functions ==============================
func _ready() -> void:
	_apply_tooltips()
	_main.hide()
	Events.entity_alt_clicked.connect(_on_entity_alt_clicked)

	_entity_stats_writer.visible = _prototyping
	_entity_level_writer.visible = _prototyping
	for i: int in _list.item_count:
		_list.set_item_selectable(i, _prototyping)
	if _prototyping:
		_list.item_clicked.connect(_on_item_clicked)


func _process(_delta: float) -> void:
	if not _main.visible: return
	if not is_instance_valid(_entity):
		_unbind()
		return
	var camera := get_viewport().get_camera_3d()
	if camera != null:
		_main.position = _panel_position(camera.unproject_position(_entity.global_position))


# Position écran du panneau à partir de la position projetée de l'entité.
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
	if not entity.progression.level_changed.is_connected(_on_entity_progression_level_changed):
		entity.progression.level_changed.connect(_on_entity_progression_level_changed)
	_on_entity_progression_level_changed(entity.progression.level)
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
		if _entity.progression.level_changed.is_connected(_on_entity_progression_level_changed):
			_entity.progression.level_changed.disconnect(_on_entity_progression_level_changed)
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


# Sélection d'une stat (prototyping) : le panneau modifier affiche le nom de la stat
# et la valeur actuelle de son modifier "Prototyping" (0 si aucun).
func _on_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	if not is_instance_valid(_entity): return
	if index < 0 or index >= _STATS.size(): return
	_selected_stat_type = _STATS.keys()[index]
	_stat_name_label.text = _STATS[_selected_stat_type]["name"]
	var current: float = _entity.stat_modifiers_registry.get_modifier_value(_selected_stat_type, PROTOTYPING_MODIFIER_ID)
	_stat_modifier_text_edit.text = str(current)


func _on_apply_stat_modifier_button_pressed() -> void:
	if not is_instance_valid(_entity): return
	var mod := StatModifier.new()
	mod.id = PROTOTYPING_MODIFIER_ID
	mod.value = float(_stat_modifier_text_edit.text)
	mod.stat_type = _selected_stat_type
	mod.calc_type = StatModifier.CalcType.ADD
	_entity.stat_modifiers_registry.register_modifier(mod)


func _on_clear_stat_modifier_button_pressed() -> void:
	if not is_instance_valid(_entity): return
	_entity.stat_modifiers_registry.remove_modifier(_selected_stat_type, PROTOTYPING_MODIFIER_ID)


func _on_plus_level_button_pressed() -> void:
	if _entity == null: return
	if _entity.progression.level >= 20: return
	_entity.progression.level += 1


func _on_minus_level_button_pressed() -> void:
	if _entity == null: return
	if _entity.progression.level <= 1: return
	_entity.progression.level -= 1


func _on_entity_progression_level_changed(level: int) -> void:
	_level_value_label.text = str(level)
#endregion
