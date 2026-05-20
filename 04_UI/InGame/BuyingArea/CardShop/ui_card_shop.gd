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
	Verbose.trace("UICardShop._ready() BEGIN", Verbose.Category.CARD_SHOP)
	if GameManager.game_type != GameManager.GameType.SOLO and multiplayer.is_server():
		Verbose.trace("UICardShop._ready(): not SOLO + server -> queue_free", Verbose.Category.CARD_SHOP)
		queue_free()
		return

	_local_player = PlayerManager.get_local_player()
	if _local_player == null:
		Verbose.error("UICardShop._ready(): PlayerManager.get_local_player() returned null", Verbose.Category.CARD_SHOP)
		return
	Verbose.trace("UICardShop._ready(): local_player=" + _local_player.player_name, Verbose.Category.CARD_SHOP)

	_card_shop = _local_player.get_node("CardShop") as PlayerCardShop
	if _card_shop == null:
		Verbose.error("UICardShop._ready(): no PlayerCardShop child node on local player '" + _local_player.player_name + "'", Verbose.Category.CARD_SHOP)
		return
	Verbose.trace("UICardShop._ready(): PlayerCardShop bound, cards_number=" + str(_card_shop.cards_number) + " cards_displayed=" + str(_card_shop.cards_displayed.size()), Verbose.Category.CARD_SHOP)

	_card_shop.shop_refreshed.connect(_on_card_shop_shop_refreshed)
	_card_shop.card_bought.connect(_on_card_shop_card_bought)

	_card_shop.shop_tried_to_refresh.connect(_on_card_shop_shop_tried_to_refresh)
	_card_shop.shop_tried_to_buy_random_card.connect(_on_card_shop_shop_tried_to_buy_random_card)
	_card_shop.shop_tried_to_buy_card.connect(_on_card_shop_shop_tried_to_buy_card)

	if _card_buttons.is_empty():
		Verbose.warn("UICardShop._ready(): _card_buttons is empty (export not assigned?)", Verbose.Category.CARD_SHOP)
	for card_button in _card_buttons:
		card_button.card_selected.connect(_on_card_shop_button_pressed, CONNECT_ONE_SHOT)

	_refresh_button.pressed.connect(_on_refresh_button_pressed, CONNECT_ONE_SHOT)
	_random_card_button.pressed.connect(_on_random_card_button_pressed, CONNECT_ONE_SHOT)

	_xp_gain_label.text = "+" + str(GameManager.game_rules.xp_per_oracle_buy) + " XP"
	_buy_xp_price_label.text = str(GameManager.game_rules.buy_xp_price)

	Verbose.trace("UICardShop._ready(): triggering initial free refresh", Verbose.Category.CARD_SHOP)
	_card_shop.refresh_for_free()
	Verbose.trace("UICardShop._ready() END", Verbose.Category.CARD_SHOP)

# ============================== Public functions ==============================

func set_active() -> void:
	Verbose.trace("UICardShop.set_active() | is_active=" + str(_is_active) + " is_locked=" + str(_is_locked), Verbose.Category.CARD_SHOP)
	if _is_active or _is_locked: return
	_is_active = true
	show()


func set_inactive() -> void:
	Verbose.trace("UICardShop.set_inactive() | is_active=" + str(_is_active), Verbose.Category.CARD_SHOP)
	if not _is_active: return
	_is_active = false
	hide()

# ============================== Private functions ==============================

func _adapt_cards_lvl_to_player() -> void:
	Verbose.trace("UICardShop._adapt_cards_lvl_to_player() | " + str(_card_displayed.size()) + " cards", Verbose.Category.CARD_SHOP)
	for card in _card_displayed:
		card.lvl = _local_player.deck.get_card_lvl(card) + 1


func _disconnect_from_cards_signals() -> void:
	Verbose.trace("UICardShop._disconnect_from_cards_signals()", Verbose.Category.CARD_SHOP)
	for card_button in _card_buttons:
		if card_button.card_selected.is_connected(_on_card_shop_button_pressed):
			card_button.card_selected.disconnect(_on_card_shop_button_pressed)


func _reconnect_to_cards_signals() -> void:
	Verbose.trace("UICardShop._reconnect_to_cards_signals()", Verbose.Category.CARD_SHOP)
	for card_button in _card_buttons:
		if not card_button.card_selected.is_connected(_on_card_shop_button_pressed):
			card_button.card_selected.connect(_on_card_shop_button_pressed, CONNECT_ONE_SHOT)


func _update_shop_cards_displayed_visual(cards: Array[Card]) -> void:
	Verbose.trace("UICardShop._update_shop_cards_displayed_visual() | " + str(cards.size()) + " cards, " + str(_card_buttons.size()) + " buttons", Verbose.Category.CARD_SHOP)
	for i in _card_buttons.size():
		_card_buttons[i].hide()
	for i in cards.size():
		_card_buttons[i].update_visual(cards[i])
		_card_buttons[i].show()


# ============================== Callbacks ==============================

func _on_card_shop_button_pressed(_card_button_selected: CardButton, card: Card) -> void:
	Verbose.trace("UICardShop._on_card_shop_button_pressed() | card=" + (card.name if card != null else "<null>"), Verbose.Category.CARD_SHOP)
	_disconnect_from_cards_signals()
	_card_shop.try_buy_card(card)


func _on_card_shop_shop_refreshed(new_cards: Array[Card]) -> void:
	Verbose.trace("UICardShop._on_card_shop_shop_refreshed() | " + str(new_cards.size()) + " new cards", Verbose.Category.CARD_SHOP)
	_update_shop_cards_displayed_visual(new_cards)


func _on_card_shop_card_bought(card: Card) -> void:
	Verbose.trace("UICardShop._on_card_shop_card_bought() | card=" + (card.name if card != null else "<null>"), Verbose.Category.CARD_SHOP)
	card_bought.emit(card)


func _on_card_shop_shop_tried_to_refresh() -> void:
	Verbose.trace("UICardShop._on_card_shop_shop_tried_to_refresh()", Verbose.Category.CARD_SHOP)
	_refresh_button.pressed.connect(_on_refresh_button_pressed, CONNECT_ONE_SHOT)
	_refresh_button.disabled = false


func _on_card_shop_shop_tried_to_buy_random_card() -> void:
	Verbose.trace("UICardShop._on_card_shop_shop_tried_to_buy_random_card()", Verbose.Category.CARD_SHOP)
	_random_card_button.pressed.connect(_on_random_card_button_pressed, CONNECT_ONE_SHOT)
	_random_card_button.disabled = false


func _on_card_shop_shop_tried_to_buy_card() -> void:
	Verbose.trace("UICardShop._on_card_shop_shop_tried_to_buy_card()", Verbose.Category.CARD_SHOP)
	_reconnect_to_cards_signals()

# ============================== Buttons Callbacks ==============================

func _on_close_button_pressed() -> void:
	Verbose.trace("UICardShop._on_close_button_pressed()", Verbose.Category.CARD_SHOP)
	set_inactive()


func _on_refresh_button_pressed() -> void:
	Verbose.trace("UICardShop._on_refresh_button_pressed()", Verbose.Category.CARD_SHOP)
	_refresh_button.disabled = true
	_card_shop.try_refresh_shop_cards()


func _on_random_card_button_pressed() -> void:
	Verbose.trace("UICardShop._on_random_card_button_pressed()", Verbose.Category.CARD_SHOP)
	_random_card_button.disabled = true
	_card_shop.try_buy_random_card()


func _on_buy_xp_button_pressed() -> void:
	Verbose.trace("UICardShop._on_buy_xp_button_pressed()", Verbose.Category.CARD_SHOP)
	ServerOracleShop.try_buy_xp(_local_player)
