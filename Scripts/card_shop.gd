extends Control

@export var player_gold: int = 100  # Or du joueur
@export var rules: CardRules
@export var families: Array[Family]

func _ready() -> void:
	var deck: ShopDeck = ShopDeck.new()
	deck.construct_shopDeck(families, rules)
	deck.shuffle()
	var shopCards : Array[Card] = deck.draw_n_random_card(4)
	print(shopCards)
	for i in shopCards.size():
		var card = $CardContainer.get_node(str(i)) as CardUI
		print(card)
		card.update_visual_card(shopCards[i])
		


func _on_card_selected(card: Card) -> void:
	if player_gold >= card.cost:
		player_gold -= card.cost
		print("Carte achetée :", card.name)
		# Ajouter la carte au deck du joueur

		_ready()  # Rafraîchir l'interface
	else:
		print("Pas assez d'or pour acheter cette carte.")


func _on_back_pressed() -> void:
	print("Achat annulé.")
	$".".hide()
	$CardShopButton.show()

func _on_card_shop_button_pressed() -> void:
	$".".show()
