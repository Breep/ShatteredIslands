# UIEntityPortrait — Fiche perso de l'entité sélectionnée : portrait, niveau, skills
# et stats. Snapshot au clic (Events.entity_clicked) puis suivi live via les signaux
# de l'entité. Cliquer le portrait ouvre/ferme la fiche (EntityDescriptionPanel) ;
# le panneau central bascule entre stats et description d'un skill au clic sur une
# icône (clic en dehors d'un skill => stats, clic en dehors de la fiche => fermeture).
class_name UIEntityPortrait
extends Control

#region ============================== Constants ==============================
const _PLACEHOLDER_SIZE := Vector2i(256, 256)
const _FADE_TIME: float = 0.15
const _HOVER_SCALE := Vector2(1.1, 1.1)
const _PRESS_SCALE := Vector2(0.92, 0.92)
const _BUTTON_TWEEN_TIME: float = 0.08
const _NO_SKILL_TEXT: String = "Compétence non disponible."
const _PANEL_POP_TIME: float = 0.18
const _PANEL_POP_SCALE := Vector2(0.92, 0.92)

# { ItemList unique-name : [ {stat, sig (signal float 1 arg)} ] }
# L'ordre des items DOIT suivre l'ordre des icônes posées dans la scène.
const _STAT_LISTS: Dictionary = {
	"AttackStats": [
		{"stat": EntityStats.StatType.AD, "sig": &"attack_damage_changed"},
		{"stat": EntityStats.StatType.AS, "sig": &"attack_speed_changed"},
		{"stat": EntityStats.StatType.AP, "sig": &"attack_power_changed"},
		{"stat": EntityStats.StatType.AR, "sig": &"attack_range_changed"},
	],
	"DefenseStats": [
		{"stat": EntityStats.StatType.ARMOR, "sig": &"armor_changed"},
		{"stat": EntityStats.StatType.MAGIC_RESIST, "sig": &"magic_resistance_changed"},
		{"stat": EntityStats.StatType.POISON_RESIST, "sig": &"poison_resistance_changed"},
	],
	"CriticStats": [
		{"stat": EntityStats.StatType.CRIT_CHANCE, "sig": &"crit_chance_changed"},
		{"stat": EntityStats.StatType.CRIT_MULT, "sig": &"crit_mult_changed"},
	],
	"ManaStats": [
		{"stat": EntityStats.StatType.MANA_MAX, "sig": &"mana_max_changed"},
		{"stat": EntityStats.StatType.MANA_REGEN, "sig": &"mana_regen_changed"},
	],
	"MiscStats": [
		{"stat": EntityStats.StatType.MS, "sig": &"movement_speed_changed"},
		{"stat": EntityStats.StatType.DODGE, "sig": &"dodge_changed"},
		{"stat": EntityStats.StatType.LIFESTEAL, "sig": &"lifesteal_changed"},
		{"stat": EntityStats.StatType.SCALE, "sig": &"scale_changed"},
	],
}

# Boutons skill principaux (5, communs mobs + héros) : { bouton unique-name : {icon, type} }
const _PRIMARY_SKILLS: Dictionary = {
	"PassiveButton": {"icon": "PassiveIcon", "type": Skill.Type.PASSIVE},
	"BronzeButton": {"icon": "BronzeIcon", "type": Skill.Type.BRONZE},
	"SilverButton": {"icon": "SilverIcon", "type": Skill.Type.SILVER},
	"GoldButton": {"icon": "GoldIcon", "type": Skill.Type.GOLD},
	"UltimateButton": {"icon": "UltimateIcon", "type": Skill.Type.ULTIMATE},
}

# Boutons de 2e choix par tier : masqués tant que le skill_tree héros n'est pas conçu.
const _SECONDARY_BUTTONS: Array[String] = ["BronzeButton2", "SilverButton2", "GoldButton2"]
#endregion

#region ============================== Onready ==============================
@onready var _name_label: RichTextLabel = %EntityNameLabel
@onready var _portrait: TextureRect = %EntityPortraitTexture
@onready var _level_label: Label = %EntityLevelLabel
@onready var _stats_panel: VBoxContainer = %StatsContainer
@onready var _skill_desc_panel: VBoxContainer = %SkillDescriptionContainer
@onready var _skill_name_label: Label = %SkillNameLabel
@onready var _skill_desc_label: RichTextLabel = %SkillDescriptionLabel
@onready var _panel: Panel = %EntityDescriptionPanel
@onready var _portrait_button: TextureButton = %PortraitButton
#endregion

#region ============================== Private variables ==============================
var _entity: Entity = null
var _stat_connections: Array[Dictionary] = [] # {sig, cb} branchés sur _entity.stats
var _skill_buttons: Dictionary = {} # TextureButton -> {type, icon, ...}
var _button_tweens: Dictionary = {} # TextureButton -> Tween (feedback hover/press)
var _showing_desc: bool = false
var _current_desc_type: Skill.Type = Skill.Type.PASSIVE
var _fade_tween: Tween
var _panel_open: bool = false
var _panel_tween: Tween
#endregion

#region ============================== Node base functions ==============================
func _ready() -> void:
	_collect_skill_buttons()
	_hide_secondary_buttons()
	_show_stats_instant()
	_close_panel_instant()
	_portrait_button.pressed.connect(_on_portrait_button_pressed)
	Events.entity_clicked.connect(_on_events_entity_clicked)


func _input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	var mouse: Vector2 = get_global_mouse_position()
	if _panel_open and not _panel.get_global_rect().has_point(mouse) \
			and not _portrait_button.get_global_rect().has_point(mouse):
		_close_panel()
		return
	if _showing_desc and not _is_over_skill_button():
		_show_stats()


func _exit_tree() -> void:
	_unbind()
#endregion

#region ============================== Public functions ==============================
func bind(entity: Entity) -> void:
	if entity == null: return
	_unbind()
	_entity = entity
	_show_stats_instant()
	_update_identity()
	_bind_stats()
	_bind_level()
	_bind_skills()
	if not entity.died.is_connected(_on_entity_died):
		entity.died.connect(_on_entity_died)
#endregion

#region ============================== Private functions — binding ==============================
func _update_identity() -> void:
	_name_label.text = _entity.entity_name
	var desc: EntityDesc = _entity.entity_desc
	if desc != null and desc.portrait != null:
		_portrait.texture = desc.portrait
	else:
		_portrait.texture = _make_placeholder()


func _bind_stats() -> void:
	var stats: EntityStats = _entity.stats
	for list_name: String in _STAT_LISTS:
		var list: ItemList = get_node("%" + list_name)
		var entries: Array = _STAT_LISTS[list_name]
		for i: int in entries.size():
			_set_item_value(list, i, stats.get_stat(entries[i]["stat"]))
			var sig: StringName = entries[i]["sig"]
			var cb: Callable = _on_stat_changed.bind(list, i)
			stats.connect(sig, cb)
			_stat_connections.append({"sig": sig, "cb": cb})


func _bind_level() -> void:
	if _entity.progression == null: return
	_level_label.text = str(_entity.progression.level)
	if not _entity.progression.level_changed.is_connected(_on_level_changed):
		_entity.progression.level_changed.connect(_on_level_changed)


func _bind_skills() -> void:
	var skill_comp: SkillComponent = _entity.skill
	for btn: TextureButton in _skill_buttons:
		var data: Dictionary = _skill_buttons[btn]
		var skill: Skill = skill_comp.roaster.get(data["type"]) if skill_comp != null else null
		var icon: TextureRect = data["icon"]
		icon.texture = skill.portrait if skill != null else null


func _unbind() -> void:
	if is_instance_valid(_entity):
		var stats: EntityStats = _entity.stats
		for connection: Dictionary in _stat_connections:
			if stats.is_connected(connection["sig"], connection["cb"]):
				stats.disconnect(connection["sig"], connection["cb"])
		if _entity.progression != null and _entity.progression.level_changed.is_connected(_on_level_changed):
			_entity.progression.level_changed.disconnect(_on_level_changed)
		if _entity.died.is_connected(_on_entity_died):
			_entity.died.disconnect(_on_entity_died)
	_stat_connections.clear()
	_entity = null
#endregion

#region ============================== Private functions — skill panel swap ==============================
func _show_desc(skill_type: Skill.Type) -> void:
	_current_desc_type = skill_type
	_showing_desc = true
	var skill_comp: SkillComponent = _entity.skill if is_instance_valid(_entity) else null
	var skill: Skill = skill_comp.roaster.get(skill_type) if skill_comp != null else null
	var unlocked: bool = skill_comp.unlocked_skills.get(skill_type, false) if skill_comp != null else false
	if skill != null and unlocked:
		_skill_name_label.text = skill.name
		_skill_desc_label.text = skill.description
	else:
		_skill_name_label.text = ""
		_skill_desc_label.text = _NO_SKILL_TEXT
	_crossfade(_skill_desc_panel, _stats_panel)


func _show_stats() -> void:
	_showing_desc = false
	_crossfade(_stats_panel, _skill_desc_panel)


func _show_stats_instant() -> void:
	_showing_desc = false
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_stats_panel.show()
	_stats_panel.modulate.a = 1.0
	_skill_desc_panel.hide()
	_skill_desc_panel.modulate.a = 1.0


func _crossfade(node_in: CanvasItem, node_out: CanvasItem) -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	node_in.show()
	node_in.modulate.a = 0.0
	_fade_tween = create_tween()
	_fade_tween.set_parallel(true)
	_fade_tween.tween_property(node_in, "modulate:a", 1.0, _FADE_TIME)
	_fade_tween.tween_property(node_out, "modulate:a", 0.0, _FADE_TIME)
	_fade_tween.set_parallel(false)
	_fade_tween.tween_callback(node_out.hide)
#endregion

#region ============================== Private functions — description panel ==============================
func _open_panel() -> void:
	_panel_open = true
	if _panel_tween != null and _panel_tween.is_valid():
		_panel_tween.kill()
	_panel.show()
	_panel.pivot_offset = _panel.size * 0.5
	_panel.modulate.a = 0.0
	_panel.scale = _PANEL_POP_SCALE
	_panel_tween = create_tween()
	_panel_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_panel_tween.set_parallel(true)
	_panel_tween.tween_property(_panel, "scale", Vector2.ONE, _PANEL_POP_TIME)
	_panel_tween.tween_property(_panel, "modulate:a", 1.0, _PANEL_POP_TIME)


func _close_panel() -> void:
	_panel_open = false
	if _panel_tween != null and _panel_tween.is_valid():
		_panel_tween.kill()
	_panel.pivot_offset = _panel.size * 0.5
	_panel_tween = create_tween()
	_panel_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_panel_tween.set_parallel(true)
	_panel_tween.tween_property(_panel, "scale", _PANEL_POP_SCALE, _PANEL_POP_TIME)
	_panel_tween.tween_property(_panel, "modulate:a", 0.0, _PANEL_POP_TIME)
	_panel_tween.set_parallel(false)
	_panel_tween.tween_callback(_panel.hide)


func _close_panel_instant() -> void:
	_panel_open = false
	if _panel_tween != null and _panel_tween.is_valid():
		_panel_tween.kill()
	_panel.hide()
	_panel.scale = Vector2.ONE
	_panel.modulate.a = 1.0
#endregion

#region ============================== Private functions — buttons ==============================
func _collect_skill_buttons() -> void:
	for btn_name: String in _PRIMARY_SKILLS:
		var btn: TextureButton = get_node("%" + btn_name)
		var icon: TextureRect = get_node("%" + str(_PRIMARY_SKILLS[btn_name]["icon"]))
		_skill_buttons[btn] = {"type": _PRIMARY_SKILLS[btn_name]["type"], "icon": icon}
		btn.pressed.connect(_on_skill_button_pressed.bind(btn))
		btn.mouse_entered.connect(_on_button_hover.bind(btn, true))
		btn.mouse_exited.connect(_on_button_hover.bind(btn, false))
		btn.button_down.connect(_on_button_down.bind(btn))
		btn.button_up.connect(_on_button_up.bind(btn))


func _hide_secondary_buttons() -> void:
	for btn_name: String in _SECONDARY_BUTTONS:
		var btn: Control = get_node_or_null("%" + btn_name)
		if btn != null:
			btn.hide()


func _is_over_skill_button() -> bool:
	var mouse: Vector2 = get_global_mouse_position()
	for btn: Control in _skill_buttons:
		if btn.get_global_rect().has_point(mouse):
			return true
	return false


func _tween_button_scale(btn: Control, target: Vector2) -> void:
	var prev: Variant = _button_tweens.get(btn)
	if prev is Tween and prev.is_valid():
		prev.kill()
	btn.pivot_offset = btn.size * 0.5
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(btn, "scale", target, _BUTTON_TWEEN_TIME)
	_button_tweens[btn] = tween
#endregion

#region ============================== Private functions — misc ==============================
func _make_placeholder() -> Texture2D:
	var placeholder := PlaceholderTexture2D.new()
	placeholder.size = _PLACEHOLDER_SIZE
	return placeholder


func _set_item_value(list: ItemList, idx: int, value: float) -> void:
	if idx >= list.item_count: return
	if is_equal_approx(value, roundf(value)):
		list.set_item_text(idx, "%d" % int(value))
	else:
		list.set_item_text(idx, "%.1f" % value)
#endregion

#region ============================== Callbacks ==============================
func _on_events_entity_clicked(entity: Entity) -> void:
	bind(entity)


func _on_portrait_button_pressed() -> void:
	if _panel_open:
		_close_panel()
	else:
		_open_panel()


func _on_stat_changed(value: float, list: ItemList, idx: int) -> void:
	_set_item_value(list, idx, value)


func _on_level_changed(new_level: int) -> void:
	_level_label.text = str(new_level)


func _on_entity_died(_self_ref: Entity) -> void:
	_unbind()


func _on_skill_button_pressed(btn: TextureButton) -> void:
	var skill_type: Skill.Type = _skill_buttons[btn]["type"]
	if _showing_desc and _current_desc_type == skill_type:
		_show_stats()
	else:
		_show_desc(skill_type)


func _on_button_hover(btn: Control, entered: bool) -> void:
	_tween_button_scale(btn, _HOVER_SCALE if entered else Vector2.ONE)


func _on_button_down(btn: Control) -> void:
	_tween_button_scale(btn, _PRESS_SCALE)


func _on_button_up(btn: Control) -> void:
	_tween_button_scale(btn, _HOVER_SCALE)
#endregion
