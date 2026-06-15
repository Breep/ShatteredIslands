extends Control

# Proto du UiModifiersViewer : crée une entité détachée (registry de stats dispo
# via _init), empile des StatModifier sur la stat sélectionnée et exerce
# bind / refresh / clear du viewer.

#region ============================== Constants ==============================
# Mono stats exposées par le proto (id OptionButton = valeur du StatType).
const _STATS: Array[Dictionary] = [
	{"name": "AD", "type": EntityStats.StatType.AD},
	{"name": "AP", "type": EntityStats.StatType.AP},
	{"name": "Vie max", "type": EntityStats.StatType.HEALTH_MAX},
	{"name": "Vitesse d'attaque", "type": EntityStats.StatType.AS},
	{"name": "Armure", "type": EntityStats.StatType.ARMOR},
	{"name": "Résist. magique", "type": EntityStats.StatType.MAGIC_RESIST},
	{"name": "Esquive", "type": EntityStats.StatType.DODGE},
]
#endregion

#region ============================== Onready ==============================
@onready var _viewer: UiModifiersViewer = %UiModifiersViewer
@onready var _stat_option: OptionButton = %StatOption
@onready var _add_flat_button: Button = %AddFlatButton
@onready var _add_mult_button: Button = %AddMultButton
@onready var _clear_button: Button = %ClearButton
@onready var _refresh_button: Button = %RefreshButton
#endregion

#region ============================== Private variables ==============================
var _entity: Entity = null
var _counter: int = 0
#endregion

#region ============================== Node base functions ==============================
func _ready() -> void:
	_viewer.top_level = false # le proto affiche le viewer inline, pas en popup flottant

	_entity = Entity.new()
	_entity.stat_modifiers_registry.update_base_stats(EntityStats.new())

	for stat: Dictionary in _STATS:
		_stat_option.add_item(stat["name"], stat["type"])

	_stat_option.item_selected.connect(_on_stat_selected)
	_add_flat_button.pressed.connect(_on_add_flat_pressed)
	_add_mult_button.pressed.connect(_on_add_mult_pressed)
	_clear_button.pressed.connect(_on_clear_pressed)
	_refresh_button.pressed.connect(_viewer.refresh)

	_rebind()


func _exit_tree() -> void:
	if _entity != null:
		_entity.free()
#endregion

#region ============================== Private functions ==============================
func _selected_stat() -> EntityStats.StatType:
	return _stat_option.get_selected_id()


func _rebind() -> void:
	_viewer.bind(_selected_stat(), _entity)


func _register(calc_type: StatModifier.CalcType, value: float) -> void:
	var mod := StatModifier.new()
	mod.id = &"mod_%d" % _counter
	mod.tags = [Modifier.TagType.CARD]
	mod.stat_type = _selected_stat()
	mod.calc_type = calc_type
	mod.value = value
	_entity.stat_modifiers_registry.register_modifier(mod)
	_counter += 1
	_viewer.refresh()
#endregion

#region ============================== Callbacks ==============================
func _on_stat_selected(_index: int) -> void:
	_rebind()


func _on_add_flat_pressed() -> void:
	_register(StatModifier.CalcType.ADD, 10.0)


func _on_add_mult_pressed() -> void:
	_register(StatModifier.CalcType.MULT, 0.25)


func _on_clear_pressed() -> void:
	for mod: StatModifier in _entity.stat_modifiers_registry.get_modifiers(_selected_stat()):
		_entity.stat_modifiers_registry.unregister_modifier(mod)
	_viewer.refresh()
#endregion
