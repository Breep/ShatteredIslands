class_name EngineerDescPanel
extends Control

## Panel de description de la famille Engineer.
## Accepte un Hero en entrée pour adapter dynamiquement :
##   - Le passif : highlight du niveau actuel, les autres sont transparents
##   - Les valeurs (shield, hp max, shield power) lues depuis EngineerManager

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
#endregion


#region ============================== Public API ==============================
func set_hero(hero: Entity) -> void:
	var families_level := hero.get_families_level()
	var level: int = families_level.get(Family.Type.ENGINEER, 0)

	_update_passive(level)
	_update_values()
#endregion


#region ============================== Passif ==============================
func _update_passive(level: int) -> void:
	for i in _passive_levels.size():
		_passive_levels[i].modulate = ACTIVE_MODULATE if i == level else INACTIVE_MODULATE
#endregion


#region ============================== Valeurs ==============================
## Met à jour les valeurs de chaque ligne depuis les constantes de EngineerManager.
func _update_values() -> void:
	for i in _passive_levels.size():
		var row: HBoxContainer = _passive_levels[i]
		var shield_label: RichTextLabel = row.get_node("ShieldValue")
		var hp_label: RichTextLabel = row.get_node("HealthMaxValue")
		var power_label: RichTextLabel = row.get_node("ShieldPowerValue")

		shield_label.text = _val(EngineerManager.P_PROTO_SHIELD_SHIELD[i])
		hp_label.text = _val(EngineerManager.P_PROTO_SHIELD_HP_MAX[i])
		power_label.text = _val(EngineerManager.P_SHIELD_POWER[i])
#endregion


#region ============================== Utils ==============================
func _fmt(value: float) -> String:
	if is_equal_approx(value, roundf(value)):
		return str(int(value))
	return "%0.1f" % value


func _val(value: float) -> String:
	return "[color=light_blue]%s[/color]" % _fmt(value)
#endregion
