class_name ColossusDescPanel
extends Control

## Panel de description de la famille Colossus.
## Accepte un Hero en entrée pour adapter dynamiquement :
##   - Le passif : highlight du niveau actuel, les autres sont transparents
##   - Les valeurs (health max %, scale %, defense) lues depuis ColossusManager

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

@onready var _defense_row: HBoxContainer = $MainPanel/MarginContainer/VBoxContainer/Passive/Level5
@onready var _defense_value: RichTextLabel = $MainPanel/MarginContainer/VBoxContainer/Passive/Level5/DefenseValue
#endregion


#region ============================== Public API ==============================
func set_hero(hero: Entity) -> void:
	var families_level := hero.get_families_level()
	var level: int = families_level.get(Family.Type.COLOSSUS, 0)

	_update_passive(level)
	_update_values()
	_update_defense(hero)
#endregion


#region ============================== Passif ==============================
func _update_passive(level: int) -> void:
	for i in _passive_levels.size():
		_passive_levels[i].modulate = ACTIVE_MODULATE if i == level else INACTIVE_MODULATE
#endregion


#region ============================== Valeurs ==============================
## Met à jour les valeurs de chaque ligne depuis les constantes de ColossusManager.
func _update_values() -> void:
	# Level 0 : +0% pour les deux
	var row0: HBoxContainer = _passive_levels[0]
	row0.get_node("HealthMaxValue").text = _val_pct(0.0)
	row0.get_node("ScaleValue").text = _val_pct(0.0)

	# Levels 1-4 : valeurs depuis les constantes du manager
	for i in range(1, _passive_levels.size()):
		var row: HBoxContainer = _passive_levels[i]
		var hp_label: RichTextLabel = row.get_node("HealthMaxValue")
		var scale_label: RichTextLabel = row.get_node("ScaleValue")

		hp_label.text = _val_pct(ColossusManager.HP_MAX_INCREASE[i - 1])
		scale_label.text = _val_pct(ColossusManager.SCALE_INCREASE[i - 1])
#endregion


#region ============================== Defense ==============================
## Met à jour le bonus de défense actuel basé sur le scale du héro.
func _update_defense(hero: Entity) -> void:
	var current_scale: float = hero.stats.scale if hero.stats else 1.0
	var defense_bonus: float = (current_scale - 1.0) * 100.0
	_defense_value.text = _val(defense_bonus)
#endregion


#region ============================== Utils ==============================
func _fmt(value: float) -> String:
	if is_equal_approx(value, roundf(value)):
		return str(int(value))
	return "%0.1f" % value


func _val(value: float) -> String:
	return "[color=light_blue]%s[/color]" % _fmt(value)


func _val_pct(value: float) -> String:
	return "[color=light_blue]+%s%%[/color]" % _fmt(value)
#endregion
