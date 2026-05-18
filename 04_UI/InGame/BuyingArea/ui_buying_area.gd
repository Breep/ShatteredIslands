# Panneau UI de la phase tavern : héberge le CardShop et propage le clic "Continue"
# qui termine la phase. Piloté de l'extérieur via set_active/set_inactive.
class_name UIBuyingArea
extends Control

# ============================== Local nodes ==============================

@onready var _ui_card_shop: UICardShop = %CardShop

# ============================== Private variables ==============================

var _is_active: bool

# ============================== Public functions ==============================

func set_active() -> void:
	if _is_active: return
	_is_active = true
	show()
	show_card_shop()


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	hide_card_shop()
	hide()


func show_card_shop() -> void:
	_ui_card_shop.set_active()


func hide_card_shop() -> void:
	_ui_card_shop.set_inactive()


# ============================== Callbacks ==============================

func _on_continue_button_pressed() -> void:
	Events.signal_tavern_continue_pressed()
