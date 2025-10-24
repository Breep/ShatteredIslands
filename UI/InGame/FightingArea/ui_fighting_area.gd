class_name UIFightingArea
extends Control

# ============================== Local nodes ==============================

#region Layout 1v1
@onready var _layout_1v1: Control = %Layout_1v1
@onready var _ui_entity_stats_left: UIEntityStats = %EntityStatsLeft
@onready var _ui_entity_stats_right: UIEntityStats = %EntityStatsRight
#endregion

#region Layout 2v2
@onready var _layout_2v2: Control = %Layout_2v2
@onready var _ui_entity_stats_left1: UIEntityStats = %EntityStatsLeft1
@onready var _ui_entity_stats_left2: UIEntityStats = %EntityStatsLeft2
@onready var _ui_entity_stats_right1: UIEntityStats = %EntityStatsRight1
@onready var _ui_entity_stats_right2: UIEntityStats = %EntityStatsRight2
#endregion

# ============================== Private variables ==============================

var _is_active: bool = false

# ============================== Node base functions ==============================

func _ready() -> void:
	hide()

# ============================== Public functions ==============================

func update_content(fighting_area: FightingArea) -> void:
	var battle_type: Battle.BattleType = fighting_area.get_battle_type()
	var characters: Array[Character] = fighting_area.get_fighting_characters()
	match battle_type:
		Battle.BattleType.VS_1: _set_layout_1v1(characters)
		Battle.BattleType.VS_2: _set_layout_2v2(characters)


func set_active() -> void:
	if _is_active: return
	_is_active = true
	show()


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	hide()

# ============================== Private functions ==============================

func _set_layout_1v1(characters: Array[Character]) -> void:
	if characters.is_empty():
		push_warning("UIFightingArea: There is no characters in the 1v1 fighting area")
		return
	_layout_1v1.show()
	_layout_2v2.hide()
	_ui_entity_stats_left.connect_entity(characters[0])
	_ui_entity_stats_right.connect_entity(characters[1])


func _set_layout_2v2(characters: Array[Character]) -> void:
	if characters.is_empty():
		push_warning("UIFightingArea: There is no characters in the 2v2 fighting area")
		return
	_layout_2v2.show()
	_layout_1v1.hide()
	_ui_entity_stats_left1.connect_entity(characters[0])
	_ui_entity_stats_left2.connect_entity(characters[1])
	_ui_entity_stats_right1.connect_entity(characters[2])
	_ui_entity_stats_right2.connect_entity(characters[3])

# ============================== Callbacks ==============================








 
