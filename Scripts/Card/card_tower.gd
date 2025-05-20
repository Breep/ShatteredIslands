class_name CardTower
extends Node3D

# ============================== Constants ==============================

const MAX_RANDOM_DISTANCE:float = 0.04 # Random movement of the card around the Y axis
const MAX_RANDOM_ROTATION:float = 5.0 * 3.14159 / 180.0 # Random movement of the card around the Y axis

# ============================== Public variables ==============================

var card_family: Family.FamilyType

var _cards_number: int # Number of coin in the tower
var cards_number: int:
	get: return _cards_number
	set(value):
		if _cards_number == value: return
		_update_visual(value)
		_cards_number = value

# ============================== Private variables ==============================

var _cards3d: Array[Card3D]
var _rng := RandomNumberGenerator.new()

# ============================== Preload ==============================

@onready var _card_scene: PackedScene = preload("res://Scenes/Card/card_3d.tscn")

# ============================== Node base functions ==============================

func _ready() -> void:
	_rng.randomize()
	for child in get_children():
		child.queue_free()

# ============================== Private functions ==============================

func _update_visual(new_cards_number) -> void:
	print("Updating visual of a card tower: ", card_family, " - ", cards_number)
	if new_cards_number < 0:
		printerr("CoinTower: Can't have less than 0 cards in the tower")
	
	if new_cards_number > _cards_number:
		var number_of_coins_to_add: int = new_cards_number - _cards_number
		for i in number_of_coins_to_add:
			var card: Card3D = _card_scene.instantiate()
			_cards3d.append(card)
			add_child(card)
			card.position.x = _rng.randf_range(0, MAX_RANDOM_DISTANCE)
			card.position.y = card.get_height() * (_cards_number + i)
			card.position.z = _rng.randf_range(0, MAX_RANDOM_DISTANCE)
			card.name = "Card_" + str(_cards_number + i)
			card.set_color(Family.COLORS[card_family])
			card.rotate(Vector3.UP, _rng.randf_range(-MAX_RANDOM_ROTATION, MAX_RANDOM_ROTATION))
	else:
		var number_of_cards_to_remove: int = _cards_number - new_cards_number
		for i in number_of_cards_to_remove:
			_cards3d[_cards3d.size() - i - 1].queue_free()
			_cards3d.remove_at(_cards3d.size() - i - 1)
