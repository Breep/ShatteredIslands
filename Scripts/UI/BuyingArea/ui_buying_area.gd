class_name UIBuyingArea
extends Control

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
	
	if not multiplayer.is_server():
		Events.card_shop_opened.connect(_on_event_card_shop_opened)

# ============================== Callbacks ==============================

func _on_event_card_shop_opened(is_opened: bool) -> void:
	if is_opened:
		_card_shop.show()
	else:
		_card_shop.hide()
