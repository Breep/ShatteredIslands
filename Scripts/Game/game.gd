class_name Game
extends Node3D

# ============================== Enum ==============================

enum GameState {
	Starting,
	Buying,
	Fighting
}

var _game_state: GameState = GameState.Starting

var _fighting_area_scene: PackedScene = preload("res://Scenes/FightingArea/fighting_area.tscn")
var _test_big_map_scene: PackedScene = preload("res://Scenes/FightingArea/Maps/island_phare.tscn")

var _families_ref: Dictionary # Reference Dictionary to all families
var _active_families: Array[Family] # Array of all families activated for this game only
var _rules: GameRules

var _current_round_battles: Array[Battle]

@onready var _buying_area: BuyingArea = %BuyingArea

var _fighting_areas: Array[FightingArea]
@export var _fighting_area_spawns: Array[Node3D]

func _ready() -> void:
	_buying_area.phase_ended.connect(_on_buying_area_phase_ended)
	
	_start_game()


func _start_game() -> void:
	# Start hero selection
	# Start first round
	_start_new_round()


func _start_new_round() ->void:
	_current_round_battles = await RoundManager.get_current_round_battles()
	_start_buying_phase()


func _spawn_all_fighting_areas(battles: Array[Battle]) -> void:
	for i in battles.size():
		var fighting_area: FightingArea = _fighting_area_scene.instantiate()
		get_tree().current_scene.add_child(fighting_area)
		fighting_area.position = _fighting_area_spawns[i].position


func _start_buying_phase() -> void:
	_buying_area.start_round(_current_round_battles)
	_spawn_all_fighting_areas(_current_round_battles)


func _start_fighting_phase() -> void:
	print("Start fights !")


func _on_buying_area_phase_ended():
	_start_fighting_phase()
