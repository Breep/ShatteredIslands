class_name ChickenLordDescPanel
extends Control

## Panel de description de la famille Chicken Lord.
## Accepte un Hero en entrée pour adapter dynamiquement :
##   - Le passif : highlight du niveau actuel, valeurs depuis ChickenLordManager
##   - Les stats courants (avec bonus cartes)
##   - Les stats des poulets (depuis FamilyChickenLordStats)
##   - Les poulets gifted débloqués (familles >= 1)
##   - La jauge ancestrale (depuis hero.data_memory)

const ACTIVE_MODULATE := Color(1, 1, 1, 1.0)
const INACTIVE_MODULATE := Color(1, 1, 1, 0.478)

## Mapping famille → nom affiché pour les gifted
const GIFTED_NAMES: Dictionary[Family.Type, String] = {
	Family.Type.WARRIOR: "Warrior Chicken",
	Family.Type.ARDENT_CELESTIAL: "Ardent Celestial Chicken",
	Family.Type.ENGINEER: "Engineer Chicken",
	Family.Type.STORM_CALLER: "Storm Caller Chicken",
	Family.Type.LIGHT: "Light Chicken",
	Family.Type.COLOSSUS: "Colossus Chicken",
	Family.Type.POISON: "Poison Chicken",
	Family.Type.NECROSIS: "Necrosis Chicken",
}

const GIFTED_COLORS: Dictionary[Family.Type, String] = {
	Family.Type.WARRIOR: "red",
	Family.Type.ARDENT_CELESTIAL: "orange",
	Family.Type.ENGINEER: "brown",
	Family.Type.STORM_CALLER: "cyan",
	Family.Type.LIGHT: "yellow",
	Family.Type.COLOSSUS: "green",
	Family.Type.POISON: "purple",
	Family.Type.NECROSIS: "gray",
}

#region ============================== Node References ==============================
@onready var _passive_levels: Array[Node] = [
	$MainPanel/MarginContainer/VBoxContainer/Passive/Level0,
	$MainPanel/MarginContainer/VBoxContainer/Passive/Level1,
	$MainPanel/MarginContainer/VBoxContainer/Passive/Level2,
	$MainPanel/MarginContainer/VBoxContainer/Passive/Level3,
	$MainPanel/MarginContainer/VBoxContainer/Passive/Level4,
]

@onready var _current_row: HBoxContainer = $"MainPanel/MarginContainer/VBoxContainer/Current Stats/Current"
@onready var _current_periodic: RichTextLabel = $"MainPanel/MarginContainer/VBoxContainer/Current Stats/Current/ShieldValue"
@onready var _current_start: RichTextLabel = $"MainPanel/MarginContainer/VBoxContainer/Current Stats/Current/ShieldPowerValue"
@onready var _current_gifted: RichTextLabel = $"MainPanel/MarginContainer/VBoxContainer/Current Stats/Current/GiftedChanceValue"

@onready var _chicken_stats_levels: Array[Node] = [
	$MainPanel/MarginContainer/VBoxContainer/ChickenStats/Level0,
	$MainPanel/MarginContainer/VBoxContainer/ChickenStats/Level1,
	$MainPanel/MarginContainer/VBoxContainer/ChickenStats/Level2,
	$MainPanel/MarginContainer/VBoxContainer/ChickenStats/Level3,
	$MainPanel/MarginContainer/VBoxContainer/ChickenStats/Level4,
]

@onready var _gifted_label: RichTextLabel = $MainPanel/MarginContainer/VBoxContainer/UnlockedGiftedChicken/Title/SpawnChanceLabel
@onready var _ancestral_bar: ProgressBar = $MainPanel/MarginContainer/VBoxContainer/UnlockedGiftedChicken2/AncestralGaugeProgressBar
@onready var _ancestral_label: Label = $MainPanel/MarginContainer/VBoxContainer/UnlockedGiftedChicken2/AncestralGaugeProgressBar/AncestralGaugeLabel
#endregion


#region ============================== Public API ==============================
func set_hero(hero: Entity) -> void:
	var families_level := hero.get_families_level()
	var level: int = families_level.get(Family.Type.CHICKEN_LORD, 0)
	var stats: FamilyChickenLordStats = hero.families_stats.chicken_lord

	_update_passive(level)
	_update_passive_values()
	_update_current_stats(level, stats)
	_update_chicken_stats()
	_update_gifted_unlocks(families_level)
	_update_ancestral_gauge(hero)
#endregion


#region ============================== Passif ==============================
func _update_passive(level: int) -> void:
	for i in _passive_levels.size():
		_passive_levels[i].modulate = ACTIVE_MODULATE if i == level else INACTIVE_MODULATE


func _update_passive_values() -> void:
	for i in _passive_levels.size():
		var row: HBoxContainer = _passive_levels[i]
		var periodic_label: RichTextLabel = row.get_node("ShieldValue")
		var start_label: RichTextLabel = row.get_node("ShieldPowerValue")
		var gifted_label: RichTextLabel = row.get_node("GiftedChanceValue")

		var count: int = ChickenLordManager.P_PERIODIC_SPAWN_CHICKEN_NUMBERS[i]
		var period: float = ChickenLordManager.P_PERIODIC_SPAWN_PERIODS[i]
		periodic_label.text = "%s / %s" % [_val(count), _val_suffix(period, "s")]

		start_label.text = _val(ChickenLordManager.P_START_CHICKENS[i])
		gifted_label.text = "%s%%" % _val_raw(ChickenLordManager.GIFTED_CHANCES[i])
#endregion


#region ============================== Current Stats ==============================
func _update_current_stats(level: int, stats: FamilyChickenLordStats) -> void:
	# Periodic : nombre + période ajustée par les cartes
	var count: int = ChickenLordManager.P_PERIODIC_SPAWN_CHICKEN_NUMBERS[level]
	var period: float = ChickenLordManager.P_PERIODIC_SPAWN_PERIODS[level] - stats.spawn_period_decrease
	_current_periodic.text = "%s / %s" % [_val(count), _val_suffix(period, "s")]

	# At start : base + bonus cartes
	var start_count: int = ChickenLordManager.P_START_CHICKENS[level] + stats.spawn_number_increase
	_current_start.text = _val(start_count)

	# Gifted chance : base + bonus cartes
	var gifted_chance: float = ChickenLordManager.GIFTED_CHANCES[level] + stats.gifted_chance_increase
	_current_gifted.text = "%s%%" % _val_raw(gifted_chance)
#endregion


#region ============================== Chicken Stats ==============================
func _update_chicken_stats() -> void:
	for i in _chicken_stats_levels.size():
		var row: HBoxContainer = _chicken_stats_levels[i]
		# Noms des nodes dans le tscn : SpawnChanceLabel=HP, DamageLabel=AD,
		# DamageLabel2=Armor, DamageLabel3=CritChance, DamageLabel4=CritMulti
		row.get_node("SpawnChanceLabel").text = _val(FamilyChickenLordStats.HP[i])
		row.get_node("DamageLabel").text = _val(FamilyChickenLordStats.AD[i])
		row.get_node("DamageLabel2").text = _val(FamilyChickenLordStats.ARMOR[i])
		row.get_node("DamageLabel3").text = _val(FamilyChickenLordStats.CRIT_CHANCE[i])
		row.get_node("DamageLabel4").text = _val(FamilyChickenLordStats.CRIT_MULTI[i])
#endregion


#region ============================== Gifted Unlocks ==============================
func _update_gifted_unlocks(families_level: Dictionary[Family.Type, int]) -> void:
	var parts: Array[String] = []
	for family_type in GIFTED_NAMES:
		var fam_level: int = families_level.get(family_type, 0)
		var color: String = GIFTED_COLORS.get(family_type, "white")
		var name_text: String = GIFTED_NAMES[family_type]
		if fam_level >= 1:
			parts.append("[color=%s]%s[/color]" % [color, name_text])
		else:
			parts.append("[color=dark_gray]%s[/color]" % name_text)
	_gifted_label.text = " | ".join(parts)
#endregion


#region ============================== Ancestral Gauge ==============================
func _update_ancestral_gauge(hero: Entity) -> void:
	var gauge_value: float = hero.data_memory.get_data(
		ChickenLordManager.FAMILY_NAME,
		ChickenLordManager.ANCESTRAL_GAUGE_NAME,
		0
	)
	var threshold: float = ChickenLordManager.ANCESTRAL_GAUCHE_THRESHOLD
	_ancestral_bar.max_value = threshold
	_ancestral_bar.value = minf(gauge_value, threshold)
	_ancestral_label.text = "%s/%s" % [_fmt(gauge_value), _fmt(threshold)]
#endregion


#region ============================== Utils ==============================
func _fmt(value: float) -> String:
	if is_equal_approx(value, roundf(value)):
		return str(int(value))
	return "%0.1f" % value


func _val(value: float) -> String:
	return "[color=light_blue]%s[/color]" % _fmt(value)


func _val_raw(value: float) -> String:
	return "[color=light_blue]%s[/color]" % _fmt(value)


func _val_suffix(value: float, suffix: String) -> String:
	return "[color=light_blue]%s%s[/color]" % [_fmt(value), suffix]
#endregion
