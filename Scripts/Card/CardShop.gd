extends Control

# ============================== TMP ==============================

@export var player_gold: int = 100  # Or du joueur
@export var rules: CardRules
@export var families: Array[Family]

# ============================== Local scene nodes ==============================

@onready var _backButton: Button = $Back

# ============================== Private ==============================

var shopDeck: ShopDeck = ShopDeck.new()

# ============================== Node base functions ==============================

func _ready() -> void:
	shopDeck.construct_shopDeck(families, rules)
	shopDeck.shuffle()
	updateShopCardsDisplayed()
	# tmp connect button signals
	# TODO make it in a separate function that can handle a custom number of button
	for i in 3:
		var cardButton = $CardContainer.get_node(str(i)) as CardButton
		cardButton.connect("leftClick", _on_card_shop_button_pressed)

#func _on_card_selected(card: Card) -> void:
	#if player_gold >= card.cost:
		#player_gold -= card.cost
		#print("Carte achetée :", card.name)
		## Ajouter la carte au deck du joueur
#
		#_ready()  # Rafraîchir l'interface
	#else:
		#print("Pas assez d'or pour acheter cette carte.")
		
func card_selected(card: Card) -> void:
	if player_gold >= 100:
		player_gold -= 0
		print("Carte achetée :", card.name)
		
		deck_to_player(card)
		print(str(shopDeck.size()) + " avant")
		var remaining_cards = []
		for i in 3:
			var cardButton = $CardContainer.get_node(str(i)) as CardButton
			if cardButton.card.name != card.name:
				remaining_cards.append(cardButton.card)
				
		print(str(remaining_cards) + " le tableau de card a remettre")
		for remaining_card in remaining_cards:
			shopDeck.add_card(remaining_card)
			
		print(str(shopDeck.size()) + " aprés")
		updateShopCardsDisplayed()
		
	else: 
		print("Pas assez d'or pour acheter cette carte.")




func deck_to_player(card: Card):
	pass


func _on_back_pressed() -> void:
	print("Card shop closed")
	$".".hide()

func _on_card_shop_button_pressed(card: Card) -> void:
	card_selected(card)

# ============================== Public functions ==============================
func updateShopCardsDisplayed():
	var cardsNumber = 3 # For the moment there is no way to get more cards each time you buy, maybe in the futur
	var shopCards : Array[Card] = shopDeck.draw_n_random_card(cardsNumber)
	print(shopCards)
	for i in shopCards.size():
		var cardButton = $CardContainer.get_node(str(i)) as CardButton
		cardButton.updateVisual(shopCards[i])
	pass
