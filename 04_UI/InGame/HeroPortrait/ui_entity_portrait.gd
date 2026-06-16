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
# Placeholder BBCode (rouge) quand l'effet du skill ne fournit pas de description.
const _NO_SKILL_DESC_TEXT: String = "[color=red]No description for this skill[/color]"
const _PANEL_POP_TIME: float = 0.18
const _PANEL_POP_SCALE := Vector2(0.92, 0.92)

# { ItemList unique-name : [ {stat, sig (signal float 1 arg), name (tooltip)} ] }
# L'ordre des items DOIT suivre l'ordre des icônes posées dans la scène.
const _STAT_LISTS: Dictionary = {
	"AttackStats": [
		{"stat": EntityStats.StatType.AD, "sig": &"attack_damage_changed", "name": "Dégâts d'attaque"},
		{"stat": EntityStats.StatType.AS, "sig": &"attack_speed_changed", "name": "Vitesse d'attaque"},
		{"stat": EntityStats.StatType.AP, "sig": &"attack_power_changed", "name": "Puissance magique"},
		{"stat": EntityStats.StatType.AR, "sig": &"attack_range_changed", "name": "Portée"},
	],
	"DefenseStats": [
		{"stat": EntityStats.StatType.ARMOR, "sig": &"armor_changed", "name": "Armure"},
		{"stat": EntityStats.StatType.MAGIC_RESIST, "sig": &"magic_resistance_changed", "name": "Résist. magique"},
		{"stat": EntityStats.StatType.POISON_RESIST, "sig": &"poison_resistance_changed", "name": "Résist. poison"},
	],
	"CriticStats": [
		{"stat": EntityStats.StatType.CRIT_CHANCE, "sig": &"crit_chance_changed", "name": "Chance de critique"},
		{"stat": EntityStats.StatType.CRIT_MULT, "sig": &"crit_mult_changed", "name": "Multi. critique"},
	],
	"ManaStats": [
		{"stat": EntityStats.StatType.MANA_MAX, "sig": &"mana_max_changed", "name": "Mana max"},
		{"stat": EntityStats.StatType.MANA_REGEN, "sig": &"mana_regen_changed", "name": "Régén. mana"},
	],
	"MiscStats": [
		{"stat": EntityStats.StatType.MS, "sig": &"movement_speed_changed", "name": "Vitesse de déplacement"},
		{"stat": EntityStats.StatType.DODGE, "sig": &"dodge_changed", "name": "Esquive"},
		{"stat": EntityStats.StatType.LIFESTEAL, "sig": &"lifesteal_changed", "name": "Vol de vie"},
		{"stat": EntityStats.StatType.SCALE, "sig": &"scale_changed", "name": "Taille"},
	],
}

# Tous les slots skill, keyés par SkillID (le slot fin BRONZE1/BRONZE2/... distingue
# les deux skills d'un même tier chez un héros) : { bouton unique-name : {icon, id} }
const _SKILL_SLOTS: Dictionary = {
	"PassiveButton":  {"icon": "PassiveIcon",  "id": Skill.SkillID.PASSIVE},
	"BronzeButton":   {"icon": "BronzeIcon",   "id": Skill.SkillID.BRONZE1},
	"BronzeButton2":  {"icon": "BronzeIcon2",  "id": Skill.SkillID.BRONZE2},
	"SilverButton":   {"icon": "SilverIcon",   "id": Skill.SkillID.SILVER1},
	"SilverButton2":  {"icon": "SilverIcon2",  "id": Skill.SkillID.SILVER2},
	"GoldButton":     {"icon": "GoldIcon",     "id": Skill.SkillID.GOLD1},
	"GoldButton2":    {"icon": "GoldIcon2",    "id": Skill.SkillID.GOLD2},
	"UltimateButton": {"icon": "UltimateIcon", "id": Skill.SkillID.ULTIMATE},
}

# Mapping SkillID -> Type pour résoudre dans le roaster (Type-keyé) côté non-héros.
const _SKILLID_TO_TYPE: Dictionary[Skill.SkillID, Skill.Type] = {
	Skill.SkillID.PASSIVE:  Skill.Type.PASSIVE,
	Skill.SkillID.BRONZE1:  Skill.Type.BRONZE,
	Skill.SkillID.BRONZE2:  Skill.Type.BRONZE,
	Skill.SkillID.SILVER1:  Skill.Type.SILVER,
	Skill.SkillID.SILVER2:  Skill.Type.SILVER,
	Skill.SkillID.GOLD1:    Skill.Type.GOLD,
	Skill.SkillID.GOLD2:    Skill.Type.GOLD,
	Skill.SkillID.ULTIMATE: Skill.Type.ULTIMATE,
}

# 2e choix par tier : visibles uniquement pour les héros (2 skills par tier).
const _SECONDARY_BUTTONS: Array[String] = ["BronzeButton2", "SilverButton2", "GoldButton2"]

# SkillID des 2e candidats (héros) et tiers ouverts au choix.
const _SECONDARY_IDS: Array[Skill.SkillID] = [Skill.SkillID.BRONZE2, Skill.SkillID.SILVER2, Skill.SkillID.GOLD2]
const _CHOOSABLE_TYPES: Array[Skill.Type] = [Skill.Type.BRONZE, Skill.Type.SILVER, Skill.Type.GOLD]

# États visuels d'un bouton skill : verrouillé (grisé, lisible), normal, en attente
# de choix (héros — clignote), ou écarté (candidat non retenu d'un tier tranché —
# grisé mais toujours lisible).
enum _SkillState { NORMAL, LOCKED, PENDING, DISCARDED }
const _LOCKED_MODULATE := Color(1.0, 1.0, 1.0, 0.35)
const _BLINK_MIN_ALPHA: float = 0.25
const _BLINK_TIME: float = 0.5
#endregion

#region ============================== Onready ==============================
@onready var _name_label: RichTextLabel = %EntityNameLabel
@onready var _portrait: TextureRect = %EntityPortraitTexture
@onready var _level_label: Label = %EntityLevelLabel
@onready var _stats_panel: VBoxContainer = %StatsContainer
@onready var _skill_desc_panel: VBoxContainer = %SkillDescriptionContainer
@onready var _skill_name_label: Label = %SkillNameLabel
@onready var _skill_desc_label: RichTextLabel = %SkillDescriptionLabel
@onready var _lock_skill_button: Button = %LockSkillButton
@onready var _panel: Panel = %EntityDescriptionPanel
@onready var _portrait_button: TextureButton = %PortraitButton
@onready var _health_bar: ProgressBar = %HealthBar
@onready var _health_label: Label = %HealthLabel
@onready var _health_bar_button: Button = %HealthBarButton
@onready var _modifiers_viewer: UiModifiersViewer = %UiModifiersViewer
#endregion

#region ============================== Private variables ==============================
var _entity: Entity = null
var _stat_connections: Array[Dictionary] = [] # {sig, cb} branchés sur _entity.stats
var _skill_buttons: Dictionary = {} # TextureButton -> {id, icon, skill}
var _button_tweens: Dictionary = {} # TextureButton -> Tween (feedback hover/press)
var _blink_tweens: Dictionary = {} # TextureButton -> Tween (clignotement tier pending)
var _showing_desc: bool = false
var _current_desc_btn: TextureButton = null
var _fade_tween: Tween
var _panel_open: bool = false
var _panel_tween: Tween
# Frame du dernier entity_clicked : sert à NE PAS fermer la fiche quand le clic qui
# atteint _unhandled_input correspond en fait à la sélection d'une autre entité.
var _last_entity_click_frame: int = -1
# Le clic « dans le vide » courant a servi à fermer le modifiers viewer (sur le press
# via nothing_clicked) => on ignore son release pour ne pas fermer la fiche en plus.
var _viewer_dismissed_this_click: bool = false
#endregion

#region ============================== Node base functions ==============================
func _ready() -> void:
	_collect_skill_buttons()
	_hide_secondary_buttons()
	_apply_tooltips()
	_connect_stat_clicks()
	_health_bar_button.pressed.connect(_on_health_bar_button_pressed)
	_show_stats_instant()
	_close_panel_instant()
	_portrait_button.pressed.connect(_on_portrait_button_pressed)
	_lock_skill_button.hide()
	_lock_skill_button.pressed.connect(_on_lock_skill_button_pressed)
	Events.entity_clicked.connect(_on_events_entity_clicked)
	Events.nothing_clicked.connect(_on_events_nothing_clicked)
	Events.hero_skill_chosen.connect(_on_hero_skill_chosen)


func _input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if _showing_desc and not _is_over_skill_button() and not _is_over_lock_button():
		_show_stats()


# Un clic qui atteint _unhandled_input n'a été consommé ni par le GUI ni par une
# entité (ClickableComponent) => clic « dans le vide ». On réagit sur le RELEASE
# (même phase que le set_input_as_handled du clickable) et on diffère la fermeture :
# si un entity_clicked survient la même frame, c'est une re-sélection => on garde
# ouvert. Le deferred s'exécute après tous les _unhandled_input + l'émission du
# signal, donc l'ordre d'appel des handlers n'a pas d'importance.
# Priorité : le modifiers viewer se ferme avant la fiche (un clic dans le vide ne
# ferme qu'une couche à la fois).
func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if _viewer_dismissed_this_click:
		_viewer_dismissed_this_click = false
		return
	if _modifiers_viewer.visible:
		_modifiers_viewer.hide()
		return
	if _panel_open:
		_maybe_close_panel.call_deferred()


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
	_bind_health()
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


func _apply_tooltips() -> void:
	for list_name: String in _STAT_LISTS:
		var list: ItemList = get_node("%" + list_name)
		var entries: Array = _STAT_LISTS[list_name]
		for i: int in entries.size():
			if i < list.item_count:
				list.set_item_tooltip(i, entries[i]["name"])


func _connect_stat_clicks() -> void:
	for list_name: String in _STAT_LISTS:
		var list: ItemList = get_node("%" + list_name)
		list.item_clicked.connect(_on_stat_item_clicked.bind(list_name))


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


func _bind_health() -> void:
	var stats: EntityStats = _entity.stats
	_update_health_display(stats.health, stats.health_max)
	if not stats.health_changed.is_connected(_on_health_changed):
		stats.health_changed.connect(_on_health_changed)
	if not stats.health_max_changed.is_connected(_on_health_max_changed):
		stats.health_max_changed.connect(_on_health_max_changed)


func _update_health_display(health: float, health_max: float) -> void:
	_health_bar.max_value = health_max
	_health_bar.value = health
	_health_label.text = "%d/%d" % [roundi(health), roundi(health_max)]


func _bind_level() -> void:
	if _entity.progression == null: return
	_level_label.text = str(_entity.progression.level)
	if not _entity.progression.level_changed.is_connected(_on_level_changed):
		_entity.progression.level_changed.connect(_on_level_changed)


func _bind_skills() -> void:
	var skill_comp: SkillComponent = _entity.skill
	if skill_comp != null and not skill_comp.unlocked_skills_changed.is_connected(_on_unlocked_skills_changed):
		skill_comp.unlocked_skills_changed.connect(_on_unlocked_skills_changed)
	_refresh_skills()


# (Re)calcule pour chaque bouton sa visibilité, son icône et son état visuel.
# Appelé au bind et à chaque changement de déblocage/choix du héros bindé.
func _refresh_skills() -> void:
	var skill_comp: SkillComponent = _entity.skill
	var hero_comp: HeroSkillComponent = skill_comp as HeroSkillComponent
	for btn: TextureButton in _skill_buttons:
		var data: Dictionary = _skill_buttons[btn]
		var id: Skill.SkillID = data["id"]
		if not _is_button_shown(id, hero_comp):
			_stop_blink(btn)
			btn.hide()
			data["skill"] = null
			continue
		var skill: Skill = _resolve_skill(id, hero_comp != null)
		data["skill"] = skill
		data["icon"].texture = skill.portrait if skill != null else null
		btn.show()
		_apply_skill_state(btn, _skill_state(id, hero_comp, skill_comp))
	if _showing_desc and _current_desc_btn != null:
		_update_lock_button(_current_desc_btn)


# Héros : skills d'affichage dans HeroDesc.hero_skills (8 slots fins). Autres entités :
# roaster du SkillComponent (Type-keyé, une skill par tier).
func _resolve_skill(id: Skill.SkillID, is_hero: bool) -> Skill:
	if is_hero:
		return (_entity.entity_desc as HeroDesc).hero_skills.get(id)
	var skill_comp: SkillComponent = _entity.skill
	return skill_comp.roaster.get(_SKILLID_TO_TYPE[id]) if skill_comp != null else null


# Mob : seulement les 5 boutons primaires. Héros : les 2 candidats d'un tier à choix
# restent toujours affichés (le non-retenu sera grisé via _skill_state).
func _is_button_shown(id: Skill.SkillID, hero_comp: HeroSkillComponent) -> bool:
	var is_secondary: bool = id in _SECONDARY_IDS
	if hero_comp == null:
		return not is_secondary
	if _SKILLID_TO_TYPE[id] in _CHOOSABLE_TYPES:
		return true
	return not is_secondary


func _skill_state(id: Skill.SkillID, hero_comp: HeroSkillComponent, skill_comp: SkillComponent) -> _SkillState:
	var type: Skill.Type = _SKILLID_TO_TYPE[id]
	var unlocked: bool = skill_comp.unlocked_skills.get(type, true) if skill_comp != null else true
	if not unlocked:
		return _SkillState.LOCKED
	if hero_comp != null and type in _CHOOSABLE_TYPES:
		var chosen: Skill = hero_comp.get_chosen_skill(type)
		if chosen == null:
			return _SkillState.PENDING
		return _SkillState.NORMAL if _resolve_skill(id, true) == chosen else _SkillState.DISCARDED
	return _SkillState.NORMAL


func _apply_skill_state(btn: TextureButton, state: _SkillState) -> void:
	_stop_blink(btn)
	match state:
		_SkillState.LOCKED, _SkillState.DISCARDED:
			btn.modulate = _LOCKED_MODULATE
		_SkillState.PENDING:
			btn.modulate = Color.WHITE
			_start_blink(btn)
		_:
			btn.modulate = Color.WHITE


func _start_blink(btn: TextureButton) -> void:
	var tween: Tween = create_tween().set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(btn, "modulate:a", _BLINK_MIN_ALPHA, _BLINK_TIME)
	tween.tween_property(btn, "modulate:a", 1.0, _BLINK_TIME)
	_blink_tweens[btn] = tween


func _stop_blink(btn: TextureButton) -> void:
	var prev: Variant = _blink_tweens.get(btn)
	if prev is Tween and prev.is_valid():
		prev.kill()
	_blink_tweens.erase(btn)


func _unbind() -> void:
	if is_instance_valid(_entity):
		var stats: EntityStats = _entity.stats
		for connection: Dictionary in _stat_connections:
			if stats.is_connected(connection["sig"], connection["cb"]):
				stats.disconnect(connection["sig"], connection["cb"])
		if stats.health_changed.is_connected(_on_health_changed):
			stats.health_changed.disconnect(_on_health_changed)
		if stats.health_max_changed.is_connected(_on_health_max_changed):
			stats.health_max_changed.disconnect(_on_health_max_changed)
		if _entity.progression != null and _entity.progression.level_changed.is_connected(_on_level_changed):
			_entity.progression.level_changed.disconnect(_on_level_changed)
		if _entity.died.is_connected(_on_entity_died):
			_entity.died.disconnect(_on_entity_died)
		if _entity.skill != null and _entity.skill.unlocked_skills_changed.is_connected(_on_unlocked_skills_changed):
			_entity.skill.unlocked_skills_changed.disconnect(_on_unlocked_skills_changed)
	for btn: TextureButton in _skill_buttons:
		_stop_blink(btn)
		btn.modulate = Color.WHITE
	_stat_connections.clear()
	_entity = null
#endregion

#region ============================== Private functions — skill panel swap ==============================
func _show_desc(btn: TextureButton) -> void:
	_current_desc_btn = btn
	_showing_desc = true
	var skill: Skill = _skill_buttons[btn]["skill"]
	if skill != null:
		_skill_name_label.text = skill.name
		_skill_desc_label.text = _skill_desc_text(skill)
	else:
		_skill_name_label.text = ""
		_skill_desc_label.text = _NO_SKILL_TEXT
	_update_lock_button(btn)
	_crossfade(_skill_desc_panel, _stats_panel)


# Le bouton « lock » (re)propose le choix du tier décrit : visible seulement si ce
# tier est encore en attente de choix sur le héros bindé.
func _update_lock_button(btn: TextureButton) -> void:
	var hero_comp: HeroSkillComponent = _entity.skill as HeroSkillComponent if is_instance_valid(_entity) else null
	var type: Skill.Type = _SKILLID_TO_TYPE[_skill_buttons[btn]["id"]]
	_lock_skill_button.visible = hero_comp != null and hero_comp.is_choice_pending(type)


# Description du skill, tirée de son effet et passée au moteur de tokens des
# tooltips ([[CLE]] + {{COLOR:...}}). Placeholder rouge si l'effet ne fournit pas
# de texte (cas par défaut de SkillEffect.get_description()).
func _skill_desc_text(skill: Skill) -> String:
	var desc: String = skill.skill_effect.get_description() if skill.skill_effect != null else ""
	if desc.is_empty():
		return _NO_SKILL_DESC_TEXT
	return TooltipManager.render_bbcode(desc)


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


func _maybe_close_panel() -> void:
	if Engine.get_process_frames() == _last_entity_click_frame:
		return
	_close_panel()
#endregion

#region ============================== Private functions — buttons ==============================
func _collect_skill_buttons() -> void:
	for btn_name: String in _SKILL_SLOTS:
		var btn: TextureButton = get_node("%" + btn_name)
		var icon: TextureRect = get_node("%" + str(_SKILL_SLOTS[btn_name]["icon"]))
		_skill_buttons[btn] = {"id": _SKILL_SLOTS[btn_name]["id"], "icon": icon, "skill": null}
		btn.pressed.connect(_on_skill_button_pressed.bind(btn))
		btn.mouse_entered.connect(_on_button_hover.bind(btn, true))
		btn.mouse_exited.connect(_on_button_hover.bind(btn, false))
		btn.button_down.connect(_on_button_down.bind(btn))
		btn.button_up.connect(_on_button_up.bind(btn))


# État initial (avant tout bind) : les 2e candidats restent cachés. Après bind,
# c'est _refresh_skills qui pilote la visibilité au cas par cas.
func _hide_secondary_buttons() -> void:
	for btn_name: String in _SECONDARY_BUTTONS:
		var btn: Control = get_node_or_null("%" + btn_name)
		if btn != null:
			btn.hide()


func _is_over_skill_button() -> bool:
	var mouse: Vector2 = get_global_mouse_position()
	for btn: Control in _skill_buttons:
		if not btn.visible: continue
		if btn.get_global_rect().has_point(mouse):
			return true
	return false


func _is_over_lock_button() -> bool:
	return _lock_skill_button.visible and _lock_skill_button.get_global_rect().has_point(get_global_mouse_position())


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
	_last_entity_click_frame = Engine.get_process_frames()
	if visible == false:
		show()
	if _panel_open == false:
		_open_panel()


func _on_events_nothing_clicked() -> void:
	# 1er clic dans le vide : on ne ferme que le modifiers viewer (la fiche reste).
	if _modifiers_viewer.visible:
		_modifiers_viewer.hide()
		_viewer_dismissed_this_click = true
		return
	hide()


func _on_portrait_button_pressed() -> void:
	if _panel_open:
		_close_panel()
	else:
		_open_panel()


func _on_stat_changed(value: float, list: ItemList, idx: int) -> void:
	_set_item_value(list, idx, value)


func _on_stat_item_clicked(index: int, _at_position: Vector2, mouse_button_index: int, list_name: String) -> void:
	if mouse_button_index != MOUSE_BUTTON_LEFT: return
	if not is_instance_valid(_entity): return
	var entries: Array = _STAT_LISTS[list_name]
	if index < 0 or index >= entries.size(): return
	Events.entity_stat_clicked.emit(_entity, entries[index]["stat"])


func _on_health_bar_button_pressed() -> void:
	if not is_instance_valid(_entity): return
	Events.entity_stat_clicked.emit(_entity, EntityStats.StatType.HEALTH_MAX)


func _on_health_changed(new_health: float) -> void:
	_update_health_display(new_health, _entity.stats.health_max)


func _on_health_max_changed(new_health_max: float) -> void:
	_update_health_display(_entity.stats.health, new_health_max)


func _on_level_changed(new_level: int) -> void:
	_level_label.text = str(new_level)


func _on_entity_died(_self_ref: Entity) -> void:
	_unbind()


func _on_skill_button_pressed(btn: TextureButton) -> void:
	if _showing_desc and _current_desc_btn == btn:
		_show_stats()
	else:
		_show_desc(btn)


func _on_button_hover(btn: Control, entered: bool) -> void:
	_tween_button_scale(btn, _HOVER_SCALE if entered else Vector2.ONE)


func _on_button_down(btn: Control) -> void:
	_tween_button_scale(btn, _PRESS_SCALE)


func _on_button_up(btn: Control) -> void:
	_tween_button_scale(btn, _HOVER_SCALE)


func _on_lock_skill_button_pressed() -> void:
	if _current_desc_btn == null: return
	var hero_comp: HeroSkillComponent = _entity.skill as HeroSkillComponent if is_instance_valid(_entity) else null
	if hero_comp == null: return
	var type: Skill.Type = _SKILLID_TO_TYPE[_skill_buttons[_current_desc_btn]["id"]]
	hero_comp.request_choice(type)


func _on_unlocked_skills_changed() -> void:
	if is_instance_valid(_entity):
		_refresh_skills()


func _on_hero_skill_chosen(comp: HeroSkillComponent, _skill_id: Skill.SkillID) -> void:
	if is_instance_valid(_entity) and _entity.skill == comp:
		_refresh_skills()
#endregion
