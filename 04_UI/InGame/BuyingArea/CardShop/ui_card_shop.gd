class_name UICardShop
extends Control

# ============================== Private variables ==============================

var _card_displayed: Array[Card]
var _local_player: Player

var _is_active: bool = true
var _is_locked: bool

signal card_bought(card: Card)

# ============================== Local scene nodes ==============================

var _card_shop: PlayerCardShop
@export var _card_buttons: Array[CardButton]

@onready var _refresh_button: Button = %RefreshButton
@onready var _random_card_button: Button = %RandomCardButton

@onready var _xp_gain_label: Label = %XPGainLabel
@onready var _buy_xp_price_label: Label = %BuyXPPriceLabel

# ============================== Node base functions ==============================

func _ready() -> void:
	if GameManager.game_type != GameManager.GameType.SOLO and multiplayer.is_server():
		queue_free()
		return
	
	_local_player = PlayerManager.get_local_player()
	_local_player.death.connect(_on_local_player_death)
	_card_shop = _local_player.get_node("CardShop") as PlayerCardShop
	
	_card_shop.shop_refreshed.connect(_on_card_shop_shop_refreshed)
	_card_shop.card_bought.connect(_on_card_shop_card_bought)
	
	_card_shop.shop_tried_to_refresh.connect(_on_card_shop_shop_tried_to_refresh)
	_card_shop.shop_tried_to_buy_random_card.connect(_on_card_shop_shop_tried_to_buy_random_card)
	_card_shop.shop_tried_to_buy_card.connect(_on_card_shop_shop_tried_to_buy_card)
	
	for card_button in _card_buttons:
		card_button.card_selected.connect(_on_card_shop_button_pressed, CONNECT_ONE_SHOT)
	
	_refresh_button.pressed.connect(_on_refresh_button_pressed, CONNECT_ONE_SHOT)
	_random_card_button.pressed.connect(_on_random_card_button_pressed, CONNECT_ONE_SHOT)
	
	_xp_gain_label.text = "+" + str(GameManager.game_rules.xp_per_oracle_buy) + " XP"
	_buy_xp_price_label.text = str(GameManager.game_rules.buy_xp_price)

# ============================== Public functions ==============================

func set_active() -> void:
	if _is_active or _is_locked: return
	_is_active = true
	show()


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	hide()

# ============================== Private functions ==============================

func _adapt_cards_lvl_to_player() -> void:
	for card in _card_displayed:
		card.lvl = _local_player.deck.get_card_lvl(card) + 1


func _disconnect_from_cards_signals() -> void:
	for card_button in _card_buttons:
		if card_button.card_selected.is_connected(_on_card_shop_button_pressed):
			card_button.card_selected.disconnect(_on_card_shop_button_pressed)


func _reconnect_to_cards_signals() -> void:
	for card_button in _card_buttons:
		if not card_button.card_selected.is_connected(_on_card_shop_button_pressed):
			card_button.card_selected.connect(_on_card_shop_button_pressed, CONNECT_ONE_SHOT)


func _update_shop_cards_displayed_visual(cards: Array[Card]) -> void:
	for i in _card_buttons.size():
		_card_buttons[i].hide()
	for i in cards.size():
		_card_buttons[i].update_visual(cards[i])
		_card_buttons[i].show()


# ============================== Callbacks ==============================

func _on_card_shop_button_pressed(_card_button_selected: CardButton, card: Card) -> void:
	_disconnect_from_cards_signals()
	_card_shop.try_buy_card(card)


func _on_card_shop_shop_refreshed(new_cards: Array[Card]) -> void:
	_update_shop_cards_displayed_visual(new_cards)


func _on_card_shop_card_bought(card: Card) -> void:
	card_bought.emit(card)


func _on_local_player_death(_player: Player) -> void:
	Verbose.debug("Lock card shop for " + _local_player.player_name, Verbose.Category.CARD_SHOP)
	set_inactive()
	_is_locked = true


func _on_card_shop_shop_tried_to_refresh() -> void:
	_refresh_button.pressed.connect(_on_refresh_button_pressed, CONNECT_ONE_SHOT)
	_refresh_button.disabled = false


func _on_card_shop_shop_tried_to_buy_random_card() -> void:
	_random_card_button.pressed.connect(_on_random_card_button_pressed, CONNECT_ONE_SHOT)
	_random_card_button.disabled = false


func _on_card_shop_shop_tried_to_buy_card() -> void:
	_reconnect_to_cards_signals()

# ============================== Buttons Callbacks ==============================

func _on_close_button_pressed() -> void:
	set_inactive()


func _on_refresh_button_pressed() -> void:
	_refresh_button.disabled = true
	_card_shop.try_refresh_shop_cards()


func _on_random_card_button_pressed() -> void:
	_random_card_button.disabled = true
	_card_shop.try_buy_random_card()


func _on_buy_xp_button_pressed() -> void:
	ServerOracleShop.try_buy_xp(_local_player)
