class_name UIBuyingArea
extends Control

@onready var _all_families_portrait = %AllFamiliesPortrait
@onready var _all_players_portrait: UIAllPlayersPortrait = %AllPlayersPortrait
@onready var _self_character_stats = %SelfCharacterStats
@onready var _continous_timer: UIContinousTimer = %ContinousTimer

func _ready() -> void:
	_all_players_portrait.connect_all_players(PlayerManager.players.values())
