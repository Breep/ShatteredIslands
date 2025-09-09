class_name UICardShop
extends Control

# ============================== Private variables ==============================

var _card_displayed: Array[Card]
var _local_player: Player

var _is_active: bool = true
var _is_locked: bool

signal card_bought(card: Card)

# ============================== Local scene nodes ==============================

@export var _card_shop: CardShop
@export var _card_buttons: Array[CardButton]

@onready var _refresh_button: Button = %RefreshButton

# ============================== Node base functions ==============================

func _ready() -> void:
	if GameManager.game_type != GameManager.GameType.SOLO and multiplayer.is_server():
		queue_free()
		return
	
	_local_player = PlayerManager.get_local_player()
	_local_player.death.connect(_on_local_player_death)
	_card_shop.player = _local_player
	
	_card_shop.shop_refreshed.connect(_on_card_shop_shop_refreshed)
	_card_shop.card_bought.connect(_on_card_shop_card_bought)
	_card_shop.shop_tried_to_refresh.connect(_on_card_shop_shop_tried_to_refresh)
	
	for card_button in _card_buttons:
		card_button.card_selected.connect(_on_card_shop_button_pressed, CONNECT_ONE_SHOT)
	
	_refresh_button.pressed.connect(_on_refresh_button_pressed, CONNECT_ONE_SHOT)

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

# Try to buy a card for the local player
# It will ask the server for permission, if granted, all other players will be notified
func _try_buy_card(card_button_selected: CardButton, card: Card) -> void:
	_card_shop.try_buy_card(card)
	_reconnect_to_card_signal(card_button_selected)


func _adapt_cards_lvl_to_player() -> void:
	for card in _card_displayed:
		card.lvl = _local_player.deck.get_card_lvl(card) + 1


func _reconnect_to_card_signal(card_button: CardButton) -> void:
	card_button.card_selected.connect(_on_card_shop_button_pressed, CONNECT_ONE_SHOT)


func _update_shop_cards_displayed_visual(cards: Array[Card]) -> void:
	for i in cards.size():
		_card_buttons[i].update_visual(cards[i])

# ============================== Callbacks ==============================

func _on_card_shop_button_pressed(card_button_selected: CardButton, card: Card) -> void:
	_try_buy_card(card_button_selected, card)


func _on_card_shop_shop_refreshed(new_cards: Array[Card]) -> void:
	_update_shop_cards_displayed_visual(new_cards)


func _on_card_shop_card_bought(card: Card) -> void:
	card_bought.emit(card)


func _on_local_player_death(_player: Player) -> void:
	print("CarsShop: lock card shop for ", _local_player.name)
	set_inactive()
	_is_locked = true

func _on_card_shop_shop_tried_to_refresh() -> void:
	_refresh_button.pressed.connect(_on_refresh_button_pressed, CONNECT_ONE_SHOT)
	_refresh_button.disabled = false

# ============================== Buttons Callbacks ==============================

func _on_close_button_pressed() -> void:
	set_inactive()


func _on_refresh_button_pressed() -> void:
	_refresh_button.disabled = true
	_card_shop.try_refresh_shop_cards()
