extends Control

@export var _ui_all_families_portrait: UIAllFamiliesPortrait

@export var _families: Array[Family]

@onready var _rng := RandomNumberGenerator.new()
var _player: Player

func _ready() -> void:
	GameManager.init()
	_rng.randomize()
	_ui_all_families_portrait.init_portait_families(_families)

	var player_scene: PackedScene = preload("res://07_Players/player.tscn")
	_player = player_scene.instantiate()
	_player.init_player()
	_player.name = "Player_family_proto"
	add_child(_player)
	for family: Family in _families:
		_player.deck._families_count[family.family_type] = 0

func _on_add_random_card_button_pressed() -> void:
	var randi: int = _rng.randi_range(0, _families.size() - 1)
	var rand_family: Family = _families[randi]
	_player.deck._families_count[rand_family.family_type] += 1
	_player.deck.has_changed.emit()
