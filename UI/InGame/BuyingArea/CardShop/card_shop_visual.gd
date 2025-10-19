extends Control
class_name CardShopVisual

# ============================== Local scene nodes ==============================

@export_group("Local Nodes")
@export var _cardContainer: HBoxContainer

# ============================== Public functions ==============================

func update_shop_cards_displayed_visual(cards: Array[Card]) -> void:
	for i in 3:
		_cardContainer.get_node(str(i+1)).visible = false
	
	for i in cards.size():
		_cardContainer.get_node(str(i+1)).visible = true
		var cardButton = _cardContainer.get_node(str(i+1)) as CardButton
		cardButton.update_visual(cards[i])
