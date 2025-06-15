class_name UIFightingArea
extends Control

#var _left_character: Character
#@export var left_character: Character:
	#get: return _left_character
	#set(value):
		#if _left_character != value:
			#_left_character = value
			#_ui_selected_character_stats_1.connect_character_stats(_left_character.stats)
#
#var _right_character: Character
#@export var right_character: Character:
	#get: return _right_character
	#set(value):
		#if _right_character != value:
			#_right_character = value
			#_ui_selected_character_stats_2.connect_character_stats(_right_character.stats)

# ============================== Local nodes ==============================

@onready var _continuous_timer: UIContinousTimer = %ContinousTimer
@onready var _countdown: UICountdown = %Countdown

# ============================== Private variables ==============================

var _battle_id: int
#var _characters: Array[Character]
var _is_active: bool = false

# ============================== Node base functions ==============================

func _ready() -> void:
	hide()
	GlobalFightingManager.countdown_started.connect(_on_global_fighting_manager_countdown_started)
	_continuous_timer.connect_timer(GlobalFightingManager.timer)

# ============================== Public functions ==============================

func start(battle_id: int) -> void:
	_battle_id = battle_id
	#_characters = _get_fighting_characters()
	#_ui_selected_character_stats_1.connect_character_stats(_characters[0].stats)
	#_ui_selected_character_stats_2.connect_character_stats(_characters[1].stats)
	#_ui_selected_character_stats_1.show()
	#_ui_selected_character_stats_2.show()


func set_active() -> void:
	if _is_active: return
	_is_active = true
	show()


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	hide()

# ============================== Private functions ==============================

#func _get_fighting_characters() -> Array[Character]:
	#var characters: Array[Character]
	#var entities: Dictionary[int, Entity] = Shared.entity_managers_ref[_battle_id].entities
	#for entity in entities.values():
		#if entity is Character:
			#characters.append(entity)
	#return characters

# ============================== Callbacks ==============================

func _on_global_fighting_manager_countdown_started(countdown_value: int, endword: String) -> void:
	_countdown.start(countdown_value, endword)
