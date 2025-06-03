class_name Tavern
extends Node3D

@export var _tarven_center: TavernCenter

@onready var _shop_deck_3d_visual: ShopDeck3DVisual = %ShopDeck3DVisual

func _ready() -> void:
	_shop_deck_3d_visual.connect_to_shop_deck()


func put_tables_according_to_battles(battles: Array[Battle]) -> void:
	_tarven_center.put_tables_according_to_battles(battles)
