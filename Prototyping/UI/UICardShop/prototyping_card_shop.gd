extends Control

@export var _ui_card_shop: UICardShop

func _ready() -> void:
	_ui_card_shop.show()

func _on_ui_card_shop_mouse_entered() -> void:
	print("UICardShop mouse_entered()")


func _on_ui_card_shop_mouse_exited() -> void:
	print("UICardShop mouse_exited()")
