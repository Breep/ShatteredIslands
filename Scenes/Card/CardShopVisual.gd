extends Control
class_name CardShopVisual

# =====================================================================
# ============================== Public ==============================
# =====================================================================

# ===== Public functions =====

func updateShopCardsDisplayedVisual(cards: Array[Card]) -> void:
	for i in 3:
		_cardContainer.get_node(str(i)).visible = false
	for i in cards.size():
		_cardContainer.get_node(str(i)).visible = true
		var cardButton = _cardContainer.get_node(str(i)) as CardButton
		cardButton.updateVisual(cards[i])

# =====================================================================
# ============================== Private ==============================
# =====================================================================

# ===== Variables =====

# ===== Local scene nodes =====

@onready var _cardContainer: HBoxContainer = %CardContainer

# ===== Node base functions =====

# ===== Private functions =====
