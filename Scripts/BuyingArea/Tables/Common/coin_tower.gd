class_name CoinTower
extends Node3D

# ============================== Constants ==============================

const MAX_RANDOM_DISTANCE:float = 0.01 # Random movement of the coin around the Y axis

# ============================== Public variables ==============================

var _coins_number: int # Number of coin in the tower
var coins_number: int:
	get: return _coins_number
	set(value):
		_coins_number = value
		_update_visual(value)

# ============================== Private variables ==============================

var _coins: Array[Coin]

# ============================== Preload ==============================

@onready var coin_scene: PackedScene = preload("res://Scenes/BuyingArea/Tables/Common/Coin/coin.tscn")

# ============================== Node base functions ==============================

func _ready() -> void:
	for child in get_children():
		child.queue_free()

# ============================== Private functions ==============================

func _update_visual(new_coin_number) -> void:
	var rng: = RandomNumberGenerator.new()
	rng.randomize()
	
	if new_coin_number > _coins_number:
		var number_of_coins_to_add: int = new_coin_number - _coins_number
		for i in number_of_coins_to_add:
			var coin: Coin = coin_scene.instantiate()
			_coins.append(coin)
			add_child(coin)
			coin.global_position.x = rng.randf_range(0, MAX_RANDOM_DISTANCE)
			coin.global_position.y = coin.get_height() * (_coins_number + i)
			coin.global_position.z = rng.randf_range(0, MAX_RANDOM_DISTANCE)
			coin.rotate(Vector3.UP, rng.randf())
	else:
		var number_of_coins_to_remove: int = new_coin_number - _coins_number
		for i in number_of_coins_to_remove:
			_coins[_coins.size() - i - 1].queue_free()
			_coins.remove_at(_coins.size() - i - 1)
