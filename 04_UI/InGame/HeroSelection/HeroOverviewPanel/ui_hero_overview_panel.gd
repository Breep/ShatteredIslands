# UIHeroOverviewPanel — Aperçu statique d'un héros dans le menu de sélection :
# portrait, catégorie/archétype, icônes des 8 slots de skills, stats de niveau 1
# et lore. Pas de binding signaux ni d'interaction (panneau de preview pur) :
# tout passe par l'API update(hero_desc).
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

# { TextureRect icon unique-name : Skill.SkillID }
const _SKILL_ICONS: Dictionary = {
	"PassiveIcon":  Skill.SkillID.PASSIVE,
	"BronzeIcon":   Skill.SkillID.BRONZE1,
	"BronzeIcon2":  Skill.SkillID.BRONZE2,
	"SilverIcon":   Skill.SkillID.SILVER1,
	"SilverIcon2":  Skill.SkillID.SILVER2,
	"GoldIcon":     Skill.SkillID.GOLD1,
	"GoldIcon2":    Skill.SkillID.GOLD2,
	"UltimateIcon": Skill.SkillID.ULTIMATE,
}
#endregion

#region ============================== Onready ==============================
@onready var _name_label: Label = %HeroNameLabel
@onready var _portrait: TextureRect = %HeroPortrait
@onready var _category_label: Label = %CategoryLabel
@onready var _lore_label: Label = %LoreLabel
#endregion

#region ============================== Public functions ==============================
func update(hero_desc: HeroDesc) -> void:
	if hero_desc == null: return
	_update_identity(hero_desc)
	_update_skills(hero_desc)
	_update_stats(hero_desc)
#endregion

#region ============================== Private functions ==============================
func _update_identity(hero_desc: HeroDesc) -> void:
	_name_label.text = hero_desc.name
	_category_label.text = hero_desc.category
	_lore_label.text = hero_desc.description
	_portrait.texture = hero_desc.portrait if hero_desc.portrait != null else _make_placeholder()


func _update_skills(hero_desc: HeroDesc) -> void:
	for icon_name: String in _SKILL_ICONS:
		var icon: TextureRect = get_node("%" + icon_name)
		var skill: Skill = hero_desc.hero_skills.get(_SKILL_ICONS[icon_name])
		icon.texture = skill.portrait if skill != null else null


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
