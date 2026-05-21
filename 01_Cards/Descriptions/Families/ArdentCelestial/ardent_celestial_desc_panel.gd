class_name ArdentCelestialDescPanel
extends Control

## Panel de description de la famille Ardent Celestial.
## Accepte un Hero en entrée pour adapter dynamiquement :
##   1. Le passif : highlight du niveau actuel, les autres sont transparents
##   2. Les stats du météor : chance, dégâts, rayon, effets supplémentaires

const ACTIVE_MODULATE := Color(1, 1, 1, 1.0)
const INACTIVE_MODULATE := Color(1, 1, 1, 0.478)

#region ============================== Node References ==============================
@onready var _passive_levels: Array[Node] = [
	$MainPanel/MarginContainer/VBoxContainer/Passive/Level0,
	$MainPanel/MarginContainer/VBoxContainer/Passive/Level1,
	$MainPanel/MarginContainer/VBoxContainer/Passive/Level2,
	$MainPanel/MarginContainer/VBoxContainer/Passive/Level3,
	$MainPanel/MarginContainer/VBoxContainer/Passive/Level4,
]

@onready var _spawn_chance_label: RichTextLabel = $MainPanel/MarginContainer/VBoxContainer/MeteorStats/SpawnChance/SpawnChanceValueLabel
@onready var _damage_label: RichTextLabel = $MainPanel/MarginContainer/VBoxContainer/MeteorStats/Damage/DamageValueLabel
@onready var _radius_label: RichTextLabel = $MainPanel/MarginContainer/VBoxContainer/MeteorStats/Radius/RadiusValueLabel
@onready var _meteor_stats_container: VBoxContainer = $MainPanel/MarginContainer/VBoxContainer/MeteorStats
#endregion

var _additional_effect_nodes: Array[Node] = []


#region ============================== Public API ==============================
## Point d'entrée principal : passe un Hero pour adapter tout le panneau.
func set_hero(hero: Entity) -> void:
	var families_level := hero.get_families_level()
	var level: int = families_level.get(Family.Type.ARDENT_CELESTIAL, 0)
	var stats: FamilyArdentCelestialStats = hero.families_stats.ardent_celestial
	_update_passive(level)
	_update_meteor_stats(hero, level, stats)
#endregion


#region ============================== Passif ==============================
## Highlight le niveau actuel, rend les autres semi-transparents.
func _update_passive(level: int) -> void:
	for i in _passive_levels.size():
		_passive_levels[i].modulate = ACTIVE_MODULATE if i == level else INACTIVE_MODULATE
#endregion


#region ============================== Meteor Stats ==============================
func _update_meteor_stats(hero: Entity, level: int, stats: FamilyArdentCelestialStats) -> void:
	_update_spawn_chance(level, stats)
	_update_damage(level, stats)
	_update_radius(stats)
	_clear_additional_effects()
	_populate_additional_effects(hero)


func _update_spawn_chance(level: int, stats: FamilyArdentCelestialStats) -> void:
	var base_chance: float = stats.meteor_chance[level]
	var total_chance: float = base_chance + stats.end_of_the_world_bonus_meteor_chance + stats.apocalypse_bonus_meteor_chance
	_spawn_chance_label.text = "[color=light_blue]%s%%[/color]" % _fmt(total_chance)


func _update_damage(level: int, stats: FamilyArdentCelestialStats) -> void:
	var flat: float = stats.meteor_damage_flat[level]
	var percent: float = stats.meteor_damage_percent[level]
	_damage_label.text = "[color=light_blue]%s[/color] + [color=light_blue]%s%%[/color] MAX HP" % [_fmt(flat), _fmt(percent)]


func _update_radius(stats: FamilyArdentCelestialStats) -> void:
	_radius_label.text = "[color=light_blue]%sm[/color]" % _fmt(stats.meteor_radius)
#endregion


#region ============================== Additional Effects ==============================
func _clear_additional_effects() -> void:
	for node in _additional_effect_nodes:
		node.queue_free()
	_additional_effect_nodes.clear()


func _populate_additional_effects(hero: Entity) -> void:
	if hero.deck == null:
		return
	var cards := hero.deck.get_cards_by_type(Family.Type.ARDENT_CELESTIAL)
	for card in cards:
		var lvl: int = hero.deck.get_card_lvl(card)
		if lvl < 1:
			continue
		var upgrade := card.player_upgrade
		if upgrade is FireScorpius:
			_add_effect_row("[[POISON_STACK]]", _val(upgrade._poison_stacks[lvl - 1]))
		elif upgrade is ArdentCelestialQuasar:
			_add_effect_row("Max HP", "%s / meteor" % _val(upgrade._hp_amount[lvl - 1]))
		elif upgrade is FireKuiperBelt:
			_add_effect_row("[[SHIELD]]", "%s / meteor" % _val(upgrade._shield_amount[lvl - 1]))
		elif upgrade is ArdentCelestialCelestialCulling:
			_add_effect_row("Execute", "%s%%" % _fmt(upgrade._thresholds[lvl - 1]))
		elif upgrade is FireConsumingTheStar:
			_add_effect_row("[[MANA]] burn", _val(upgrade._mana_burn[lvl - 1]))
		elif upgrade is ArdentCelestialXenoEgg:
			_add_effect_row("Spawn Egg", "%s%%" % _fmt(upgrade._proc_chances[lvl - 1]))
		elif upgrade is ArdentCelestialArmagedheal:
			_add_effect_row("Heal", "%s | %s%%" % [_val(upgrade._heal[lvl - 1]), _fmt(upgrade._proc_chance[lvl - 1])])


func _add_effect_row(label_text: String, value_bbcode: String) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 25)

	var label := SmartTextLabel.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.text_raw = label_text
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(label)

	var separator := VSeparator.new()
	row.add_child(separator)

	var value_label := RichTextLabel.new()
	value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_label.bbcode_enabled = true
	value_label.text = value_bbcode
	value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	value_label.scroll_active = false
	row.add_child(value_label)

	_meteor_stats_container.add_child(row)
	_additional_effect_nodes.append(row)
#endregion


#region ============================== Utils ==============================
## Formate un float : enlève le ".0" si c'est un entier, sinon 1 décimale.
func _fmt(value: float) -> String:
	if is_equal_approx(value, roundf(value)):
		return str(int(value))
	return "%0.1f" % value


## Formate une valeur avec la couleur light_blue.
func _val(value: float) -> String:
	return "[color=light_blue]%s[/color]" % _fmt(value)
#endregion
