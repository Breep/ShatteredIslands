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

func _on_add_random_card_button_pressed() -> void:
	_player.deck.has_changed.emit()
