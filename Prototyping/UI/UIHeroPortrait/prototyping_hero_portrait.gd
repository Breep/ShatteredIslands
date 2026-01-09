extends Control

# ============================== Local Nodes ==============================

@export var _ui_hero_portrait: UIHeroPortrait
@export var _cards_viewer: UICardsViewer

@export var _families: Array[Family]
@export var _hero_desc: HeroDesc

# ============================== Private variables ==============================

@onready var _rng := RandomNumberGenerator.new()
@onready var _player := Player.new()

@onready var _shop_deck := ShopDeck.new()

# ============================== Node base functions ==============================

func _enter_tree() -> void:
	GameManager.init()


func _ready() -> void:
	_rng.randomize()
	
	_player.name = "Breep"
	_player.deck = PlayerDeck.new(_player)
	_player.hero_desc = _hero_desc
	_player.Hero = Hero.new()
	_player.skill_manager = SkillManager.new()
	_player.skill_manager.init(_player)
	PlayerManager.players[multiplayer.get_unique_id()] = _player
	
	_ui_hero_portrait.update_content(_player)
	
	_shop_deck.construct_shop_deck(GameManager.get_active_families(), GameManager.game_rules)
	_cards_viewer.update_content([])

# ============================== Callbacks ==============================

func _on_add_victory_button_pressed() -> void:
	_player.battle_history.append(Battle.BattleResolution.WIN)
	_ui_hero_portrait.update_content(_player)


func _on_add_loose_button_pressed() -> void:
	_player.battle_history.append(Battle.BattleResolution.LOOSE)
	_ui_hero_portrait.update_content(_player)


func _on_add_xp_pressed() -> void:
	_player.xp += 5


func _on_add_card_pressed() -> void:
	var cards:Array[Card] = _shop_deck.draw_n_cards(1, _player.deck)
	_player.deck.add_card(cards[0])
	_cards_viewer.update_content(_player.deck.get_active_deck())
