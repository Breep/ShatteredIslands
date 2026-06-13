# UIHeroOverviewPanel — Aperçu d'un héros dans le menu de sélection : portrait,
# catégorie/archétype, icônes des 8 slots de skills, stats de niveau 1 et lore.
# Le héros affiché est poussé via l'API update(hero_desc). Seule interaction : le clic
# sur une icône de skill bascule le panneau central entre les stats et la description
# du skill (re-clic du même slot => retour aux stats). Aperçu pur : c'est toujours un
# héros et tous ses talents sont montrés, sans notion de déblocage ni de choix.
class_name UIHeroOverviewPanel
extends Control

#region ============================== Constants ==============================
const _PREVIEW_LEVEL: int = 1
const _PLACEHOLDER_SIZE := Vector2i(256, 256)

# { ItemList unique-name : [StatType...] }
# L'ordre DOIT suivre l'ordre des icônes posées dans la scène.
const _STAT_LISTS: Dictionary = {
	"LifeStat": [
		EntityStats.StatType.HEALTH_MAX,
	],
	"AttackStats": [
		EntityStats.StatType.AD,
		EntityStats.StatType.AS,
		EntityStats.StatType.AP,
		EntityStats.StatType.AR,
	],
	"DefenseStats": [
		EntityStats.StatType.ARMOR,
		EntityStats.StatType.MAGIC_RESIST,
		EntityStats.StatType.POISON_RESIST,
	],
	"CriticStats": [
		EntityStats.StatType.CRIT_CHANCE,
		EntityStats.StatType.CRIT_MULT,
	],
	"ManaStats": [
		EntityStats.StatType.MANA_MAX,
		EntityStats.StatType.MANA_REGEN,
	],
	"MiscStats": [
		EntityStats.StatType.MS,
		EntityStats.StatType.DODGE,
		EntityStats.StatType.LIFESTEAL,
		EntityStats.StatType.SCALE,
	],
}

const _NO_SKILL_TEXT: String = "Compétence non disponible."
# Placeholder BBCode (rouge) quand l'effet du skill ne fournit pas de description.
const _NO_SKILL_DESC_TEXT: String = "[color=red]No description for this skill[/color]"
const _FADE_TIME: float = 0.15

# { bouton unique-name : {icon unique-name, id} }. Les 8 slots fins (BRONZE1/BRONZE2…)
# sont tous affichés : aperçu de héros, sans notion de déblocage ni de choix.
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
#endregion

#region ============================== Onready ==============================
@onready var _name_label: Label = %HeroNameLabel
@onready var _portrait: TextureRect = %HeroPortrait
@onready var _category_label: Label = %CategoryLabel
@onready var _lore_label: Label = %LoreLabel
@onready var _stats_panel: VBoxContainer = %StatsContainer
@onready var _skill_desc_panel: VBoxContainer = %SkillDescriptionContainer
@onready var _skill_name_label: Label = %SkillNameLabel
@onready var _skill_desc_label: RichTextLabel = %SkillDescriptionLabel
#endregion

#region ============================== Private variables ==============================
var _skill_buttons: Dictionary = {} # TextureButton -> {id, icon, skill}
var _showing_desc: bool = false
var _current_desc_btn: TextureButton = null
var _fade_tween: Tween
#endregion

#region ============================== Node base functions ==============================
func _ready() -> void:
	_collect_skill_buttons()
	_show_stats_instant()
#endregion

#region ============================== Public functions ==============================
func update(hero_desc: HeroDesc) -> void:
	if hero_desc == null: return
	_update_identity(hero_desc)
	_update_skills(hero_desc)
	_update_stats(hero_desc)
	# Reset : un héros précédent a pu laisser une description affichée.
	_show_stats_instant()
#endregion

#region ============================== Private functions ==============================
func _update_identity(hero_desc: HeroDesc) -> void:
	_name_label.text = hero_desc.name
	_category_label.text = hero_desc.category
	_lore_label.text = hero_desc.description
	_portrait.texture = hero_desc.portrait if hero_desc.portrait != null else _make_placeholder()


func _collect_skill_buttons() -> void:
	for btn_name: String in _SKILL_SLOTS:
		var btn: TextureButton = get_node("%" + btn_name)
		var icon: TextureRect = get_node("%" + str(_SKILL_SLOTS[btn_name]["icon"]))
		_skill_buttons[btn] = {"id": _SKILL_SLOTS[btn_name]["id"], "icon": icon, "skill": null}
		btn.pressed.connect(_on_skill_button_pressed.bind(btn))


func _update_skills(hero_desc: HeroDesc) -> void:
	for btn: TextureButton in _skill_buttons:
		var data: Dictionary = _skill_buttons[btn]
		var skill: Skill = hero_desc.hero_skills.get(data["id"])
		data["skill"] = skill
		data["icon"].texture = skill.portrait if skill != null else null


# Bascule entre la description du skill cliqué et les stats. Re-cliquer le slot déjà
# affiché ramène aux stats.
func _on_skill_button_pressed(btn: TextureButton) -> void:
	if _showing_desc and _current_desc_btn == btn:
		_show_stats()
	else:
		_show_desc(btn)


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
	_crossfade(_skill_desc_panel, _stats_panel)


func _show_stats() -> void:
	_showing_desc = false
	_current_desc_btn = null
	_crossfade(_stats_panel, _skill_desc_panel)


# Description du skill, tirée de son effet et passée au moteur de tokens des tooltips
# ([[CLE]] + {{COLOR:...}}). Placeholder rouge si l'effet ne fournit pas de texte
# (cas par défaut de SkillEffect.get_description()).
func _skill_desc_text(skill: Skill) -> String:
	var desc: String = skill.skill_effect.get_description() if skill.skill_effect != null else ""
	if desc.is_empty():
		return _NO_SKILL_DESC_TEXT
	return TooltipManager.render_bbcode(desc)


func _show_stats_instant() -> void:
	_showing_desc = false
	_current_desc_btn = null
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


func _update_stats(hero_desc: HeroDesc) -> void:
	var stats: EntityStats = hero_desc.stats.get(_PREVIEW_LEVEL)
	for list_name: String in _STAT_LISTS:
		var list: ItemList = get_node("%" + list_name)
		var entries: Array = _STAT_LISTS[list_name]
		for i: int in entries.size():
			var value: float = stats.get_stat(entries[i]) if stats != null else 0.0
			_set_item_value(list, i, value)


func _set_item_value(list: ItemList, idx: int, value: float) -> void:
	if idx >= list.item_count: return
	if is_equal_approx(value, roundf(value)):
		list.set_item_text(idx, "%d" % int(value))
	else:
		list.set_item_text(idx, "%.1f" % value)


func _make_placeholder() -> Texture2D:
	var placeholder := PlaceholderTexture2D.new()
	placeholder.size = _PLACEHOLDER_SIZE
	return placeholder
#endregion
