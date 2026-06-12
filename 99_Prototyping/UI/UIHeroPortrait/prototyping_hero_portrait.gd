#extends Control
#
## ============================== Local Nodes ==============================
#
#@export var _ui_hero_portrait: UIHeroPortrait
#@export var _cards_viewer: UICardsViewer
#
#@export var _families: Array[Family]
#@export var _hero_desc: HeroDesc
#
## ============================== Private variables ==============================
#
#@onready var _rng := RandomNumberGenerator.new()
#var _player: Player
#
#@onready var _shop_deck := ShopDeck.new()
#
## ============================== Node base functions ==============================
#
#func _enter_tree() -> void:
	#GameManager.init()
#
#
#func _ready() -> void:
	#_rng.randomize()
#
	#var player_scene: PackedScene = preload("res://Player/player.tscn")
	#_player = player_scene.instantiate()
	#_player.init_player()
	#_player.player_name = "Breep"
	#_player.name = "Player_proto"
	## _player.hero_desc supprimé en Phase 3 (vit sur HeroSpec maintenant) — proto à reworker
	#add_child(_player)
	#PlayerManager.players[multiplayer.get_unique_id()] = _player
	#
	#_ui_hero_portrait.update_content(_player)
	#
	#_shop_deck.construct_shop_deck(GameManager.get_active_families(), GameManager.game_rules)
	#_cards_viewer.update_content([])
#
## ============================== Callbacks ==============================
#
#func _on_add_victory_button_pressed() -> void:
	#_player.battle_history.append(Battle.BattleResolution.WIN)
	#_ui_hero_portrait.update_content(_player)
#
#
#func _on_add_loose_button_pressed() -> void:
	#_player.battle_history.append(Battle.BattleResolution.LOOSE)
	#_ui_hero_portrait.update_content(_player)
#
#
#func _on_add_xp_pressed() -> void:
	#_player.xp += 5
#
#
#func _on_add_card_pressed() -> void:
	#var cards: Array[Card] = _shop_deck.draw_n_cards(1, _player.hand)
	#_player.hand.add_card(cards[0])
	#_cards_viewer.update_content(_player.hand.get_active_deck())
