extends Control
class_name CardShopVisual

# ============================== Local scene nodes ==============================

@onready var _cardContainer: HBoxContainer = %CardContainer

# ============================== Public functions ==============================

func update_shop_cards_displayed_visual(cards: Array[Card]) -> void:
	for i in 3:
		_cardContainer.get_node(str(i)).visible = false
	
	for i in cards.size():
		_cardContainer.get_node(str(i)).visible = true
		var cardButton = _cardContainer.get_node(str(i)) as CardButton
		cardButton.update_visual(cards[i])
