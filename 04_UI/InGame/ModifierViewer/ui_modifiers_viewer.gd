class_name UiModifiersViewer
extends PanelContainer

# Viewer de debug : pour une mono stat d'une entité, liste la valeur de base puis
# tous les StatModifier appliqués. Chaque ligne est un UiModifierViewerRow (icône
# + libellé + valeur) ; la première ligne est la base, présentée comme un modifier.

#region ============================== Constants ==============================
const _ROW_SCENE: PackedScene = preload("res://04_UI/InGame/ModifierViewer/ModifierViewerRow/ui_modifier_viewer_row.tscn")

const _ICONS_DIR: String = "res://04_UI/_Themes/Data/Icons/"

# StatType -> icône colorée de la stat (ligne de base).
const _STAT_ICONS: Dictionary = {
	EntityStats.StatType.HEALTH_MAX: "EntityStats/health_max_colored.svg",
	EntityStats.StatType.MANA_MAX: "EntityStats/mana_max_colored.svg",
	EntityStats.StatType.MANA_REGEN: "EntityStats/mana_regen_colored.svg",
	EntityStats.StatType.AD: "EntityStats/attack_damage_colored.svg",
	EntityStats.StatType.AP: "EntityStats/attack_power_colored.svg",
	EntityStats.StatType.AS: "EntityStats/attack_speed_colored.svg",
	EntityStats.StatType.AR: "EntityStats/attack_range_colored.svg",
	EntityStats.StatType.MS: "EntityStats/move_speed_colored.svg",
	EntityStats.StatType.SCALE: "EntityStats/scale_colored.svg",
	EntityStats.StatType.CRIT_CHANCE: "EntityStats/crit_chance_colored.svg",
	EntityStats.StatType.CRIT_MULT: "EntityStats/crit_mult_colored.svg",
	EntityStats.StatType.CRIT_RESISTANCE: "EntityStats/crit_res_colored.svg",
	EntityStats.StatType.DODGE: "EntityStats/dodge_colored.svg",
	EntityStats.StatType.LIFESTEAL: "EntityStats/life_steal_colored.svg",
	EntityStats.StatType.ARMOR: "EntityStats/armor_colored.svg",
	EntityStats.StatType.MAGIC_RESIST: "EntityStats/magic_resist_colored.svg",
	EntityStats.StatType.POISON_RESIST: "EntityStats/poison_resist_colored.svg",
}

# Source du modifier -> icône.
const _SOURCE_ICONS: Dictionary = {
	Modifier.TagType.CARD: "Misc/card_bonus_icon.svg",
	Modifier.TagType.SKILL: "Misc/skill_bonus_icon.svg",
}
const _UNKNOWN_SOURCE_ICON: String = "Misc/unknown_bonus_icon.svg"

const _BONUS_COLOR: Color = Color("8bc34a")
const _MALUS_COLOR: Color = Color("e5534b")
#endregion

#region ============================== Onready ==============================
@onready var _modifier_list: VBoxContainer = %ModifierList
#endregion

#region ============================== Private variables ==============================
var _entity: Entity = null
var _stat_type: EntityStats.StatType = EntityStats.StatType.AD
#endregion

#region ============================== Node base functions ==============================
func _ready() -> void:
	top_level = true # positionnement libre à la souris, hors layout du parent
	hide()
	resized.connect(_clamp_to_viewport) # la taille se finalise après l'ajout des lignes
	Events.entity_stat_clicked.connect(_on_entity_stat_clicked)
#endregion

#region ============================== Public functions ==============================
func bind(stat_type: EntityStats.StatType, entity: Entity) -> void:
	if entity == null:
		Verbose.warn("UiModifiersViewer.bind() - null entity", Verbose.Category.STAT_MODIFIER)
		return
	_stat_type = stat_type
	_entity = entity
	refresh()
	show()


func refresh() -> void:
	if not is_instance_valid(_entity):
		clear()
		return
	_clear_rows()
	var registry: EntityStatModifiersRegistry = _entity.stat_modifiers_registry
	_add_row(
		_load_icon(_STAT_ICONS.get(_stat_type, "")),
		"Base " + _stat_name(_stat_type),
		_format_number(registry.get_base_stat(_stat_type)))
	for modifier: StatModifier in registry.get_modifiers(_stat_type):
		_add_row(_source_icon(modifier), str(modifier.id), _format_value(modifier), _value_color(modifier))


func clear() -> void:
	_entity = null
	_clear_rows()
#endregion

#region ============================== Private functions ==============================
func _add_row(icon: Texture2D, label: String, value: String, value_color: Variant = null) -> void:
	var row: UiModifierViewerRow = _ROW_SCENE.instantiate()
	_modifier_list.add_child(row)
	row.setup(icon, label, value, value_color)


func _clear_rows() -> void:
	for child: Node in _modifier_list.get_children():
		_modifier_list.remove_child(child)
		child.queue_free()


func _stat_name(stat_type: EntityStats.StatType) -> String:
	var key: Variant = EntityStats.StatType.find_key(stat_type)
	return str(key) if key != null else str(stat_type)


func _source_icon(modifier: StatModifier) -> Texture2D:
	var path: String = _UNKNOWN_SOURCE_ICON
	if not modifier.tags.is_empty():
		path = _SOURCE_ICONS.get(modifier.tags[0], _UNKNOWN_SOURCE_ICON)
	return _load_icon(path)


func _load_icon(relative_path: String) -> Texture2D:
	if relative_path.is_empty():
		return null
	return load(_ICONS_DIR + relative_path)


func _format_value(modifier: StatModifier) -> String:
	var sign_prefix: String = "+" if modifier.value >= 0.0 else ""
	if modifier.calc_type == StatModifier.CalcType.MULT:
		return sign_prefix + _format_number(modifier.value * 100.0) + "%"
	return sign_prefix + _format_number(modifier.value)


func _format_number(value: float) -> String:
	if is_equal_approx(value, roundf(value)):
		return str(roundi(value))
	return str(value).pad_decimals(1)


func _value_color(modifier: StatModifier) -> Color:
	if modifier.value > 0.0:
		return _BONUS_COLOR
	if modifier.value < 0.0:
		return _MALUS_COLOR
	return Color.WHITE


# Garde le panel entièrement dans le viewport (décale vers le haut/gauche au besoin).
func _clamp_to_viewport() -> void:
	if not visible: return
	var vp: Vector2 = get_viewport_rect().size
	global_position = Vector2(
		clampf(global_position.x, 0.0, maxf(0.0, vp.x - size.x)),
		clampf(global_position.y, 0.0, maxf(0.0, vp.y - size.y)))
#endregion

#region ============================== Callbacks ==============================
func _on_entity_stat_clicked(entity: Entity, stat_type: EntityStats.StatType) -> void:
	bind(stat_type, entity)
	global_position = get_global_mouse_position()
	_clamp_to_viewport()
#endregion
