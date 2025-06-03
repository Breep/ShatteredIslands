class_name UIFightingArea
extends Control

var _left_character: Character
@export var left_character: Character:
	get: return _left_character
	set(value):
		if _left_character != value:
			_left_character = value
			_ui_selected_character_stats_1.connect_character_stats(_left_character.stats)

var _right_character: Character
@export var right_character: Character:
	get: return _right_character
	set(value):
		if _right_character != value:
			_right_character = value
			_ui_selected_character_stats_2.connect_character_stats(_right_character.stats)

# ============================== Private variables ==============================

var _battle_id: int
var _characters: Array[Character]

# ============================== Local nodes ==============================

@export var _ui_selected_character_stats_1: UICharacterStats
@export var _ui_selected_character_stats_2: UICharacterStats

# ============================== Public functions ==============================

func start(battle_id: int) -> void:
	Events.ui_fighting_area_opened.connect(_on_events_ui_fighting_area_opened)
	_battle_id = battle_id
	_characters = _get_fighting_characters()
	_ui_selected_character_stats_1.connect_character_stats(_characters[0].stats)
	_ui_selected_character_stats_2.connect_character_stats(_characters[1].stats)
	_ui_selected_character_stats_1.show()
	_ui_selected_character_stats_2.show()

# ============================== Node base functions ==============================

func _ready() -> void:
	hide()
	#_ui_selected_character_stats_1.hide()
	#_ui_selected_character_stats_2.hide()

# ============================== Private functions ==============================

func _get_fighting_characters() -> Array[Character]:
	var characters: Array[Character]
	var entities: Dictionary[int, Entity] = Shared.entity_managers_ref[_battle_id].entities
	for entity in entities.values():
		if entity is Character:
			characters.append(entity)
	return characters

# ============================== Callbacks ==============================

func _on_events_ui_fighting_area_opened(is_opened: bool, battle_id: int) -> void:
	if battle_id != -1 and battle_id != _battle_id:
		return
	
	if is_opened:
		show()
	else:
		hide()
