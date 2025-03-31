class_name UIBuyingArea
extends Control

@export var _round_timer: Timer

# ============================== Local nodes ==============================

@onready var _all_families_portrait = %AllFamiliesPortrait
@onready var _all_players_portrait: UIAllPlayersPortrait = %AllPlayersPortrait
@onready var _self_character_stats: UICharacterStats = %SelfCharacterStats
@onready var _continous_timer: UIContinousTimer = %ContinousTimer
@onready var _card_shop: CardShop = %CardShop

# ============================== Private variables ==============================

var _selected_player: Player


func connect_self_character_stats() -> void:
	if multiplayer.is_server() and _selected_player != null:
		_self_character_stats.connect_character_stats(_selected_player.character_stats)
	elif not multiplayer.is_server():
		_self_character_stats.connect_character_stats(PlayerManager.get_local_player().character_stats)


func _ready() -> void:
	_all_players_portrait.connect_all_players(PlayerManager.players.values())
	
	if multiplayer.is_server() and _selected_player != null:
		_self_character_stats.connect_character_stats(_selected_player.character_stats)
	elif not multiplayer.is_server():
		_self_character_stats.connect_character_stats(PlayerManager.get_local_player().character_stats)
	
	Events.hero_interacted.connect(_on_events_hero_interacted)
	Events.ui_buying_area_opened.connect(_on_events_ui_buying_area_opened)
	
	_continous_timer.connect_timer(_round_timer)

# ============================== Callbacks ==============================

func _on_events_hero_interacted(hero_id: Hero.HeroId) -> void:
	for player in PlayerManager.players.values():
		if player.hero.id == hero_id:
			_selected_player = player
			break
	connect_self_character_stats()


func _on_events_ui_buying_area_opened(is_opened: bool) -> void:
	if is_opened:
		show()
	else:
		hide()


















 
