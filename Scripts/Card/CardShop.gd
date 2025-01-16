extends Control
class_name CardShop

# =====================================================================
# ============================== Public ==============================
# =====================================================================



# =====================================================================
# ============================== Private ==============================
# =====================================================================

# ===== Variables =====

var playerDeck: PlayerDeck
var playerGold: int
# ============================== Public ==============================

var playerDeckUI = preload("res://Scenes/UI/PlayerDeckUI.tscn")
var _cardsDisplayed: Array[Card]
@onready var _cardShopVisual: CardShopVisual = $CardShopVisual as CardShopVisual

# ===== Local scene nodes =====

@onready var _cardContainer: HBoxContainer = %CardContainer

# ===== Node base functions =====

func _ready() -> void:
	var player: Player = GameManager.players[0]
	if player == null:
		printerr("No player !")
		return
	else:
		print("player found: ", player.name)
	_updateShopCardsDisplayed()
	# tmp connect button signals
	# TODO make it in a separate function that can handle a custom number of button
	for i in 3:
		var cardButton = _cardContainer.get_node(str(i)) as CardButton
		cardButton.connect("leftClick", _on_card_shop_button_pressed)

func _exit_tree() -> void:
	for card in _cardsDisplayed:
		GameManager.shopDeck.add_card(card)

# ===== Private functions =====

func _addCardToPlayerDeck(card: Card) -> void:
	if GameManager.players[0].deck == null:
		printerr("Can't update shop cards, there is no playerDeck")
		return
	if GameManager.players[0].gold < 100:
		return
	GameManager.players[0].gold -= 100
	GameManager.players[0].deck.add_card(card)
	var remaining_cards = []
	for i in 3:
		var cardButton = _cardContainer.get_node(str(i)) as CardButton
		if cardButton.card.name != card.name:
			remaining_cards.append(cardButton.card)
	for remaining_card in remaining_cards:
		GameManager.shopDeck.add_card(remaining_card)
	_updateShopCardsDisplayed()

func _on_back_pressed() -> void:
	print("Card shop closed")
	$".".hide()

func _on_card_shop_button_pressed(card: Card) -> void:
	print(card.lvl)
	_addCardToPlayerDeck(card)

func _on_player_deck_pressed() -> void:
	$PlayerDeckUI.show()
	playerDeckUI.show_player_cards(playerDeck)

func _updateShopCardsDisplayed() -> void:
	if GameManager.players[0].deck == null:
		printerr("Can't update shop cards, there is no playerDeck")
		return
	var cardsNumber = 3 # TODO For the moment there is no way to get more cards each time you buy, maybe in the futur
	_cardsDisplayed = GameManager.shopDeck.draw_smart(GameManager.players[0].deck.get_max_lvl_cards(), cardsNumber)
	if _cardsDisplayed.size() < 3: # DEBUG
		print(_cardsDisplayed.size())
	_adaptCardsLvlToPlayer()
	_cardShopVisual.updateShopCardsDisplayedVisual(_cardsDisplayed)

func _adaptCardsLvlToPlayer() -> void:
	for i in _cardsDisplayed.size():
		_cardsDisplayed[i].lvl = GameManager.players[0].deck.get_card_lvl(_cardsDisplayed[i])+1
