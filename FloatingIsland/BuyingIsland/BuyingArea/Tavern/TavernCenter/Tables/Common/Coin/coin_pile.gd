class_name CoinPile
extends Node3D

# ============================== Constants ==============================

const GOLD_PER_COIN: int = 10 # Number of gold that represent a 3d coin
const MAX_TOWER_HEIGHT_DIFF: int = 2 # Max coin (or height) diff between the highest and lowest tower

# ============================== Export ==============================

@export var _coin_towers: Array[CoinTower]

# ============================== Private variables ==============================

var _old_player_gold: int 
var _rng := RandomNumberGenerator.new()

# ============================== Node base functions ==============================

func _ready() -> void:
	_rng.randomize()

# ============================== Public functions ==============================

func connect_to_player(player: Player) -> void:
	player.gold_changed.connect(_on_player_gold_changed)
	_update_visual(player.gold)

# ============================== Private functions ==============================

func _update_visual(new_player_gold: int) -> void:
	if new_player_gold >= _old_player_gold + GOLD_PER_COIN:
		var number_of_coin_to_add: int = (new_player_gold - _old_player_gold) / GOLD_PER_COIN
		for i in number_of_coin_to_add:
			var coin_tower = _coin_towers[_rng.randi_range(0, _coin_towers.size() - 1)]
			coin_tower.coins_number += 1
	elif new_player_gold <= _old_player_gold - GOLD_PER_COIN:
		var number_of_coin_to_remove: int = (_old_player_gold - new_player_gold) / GOLD_PER_COIN
		for i in number_of_coin_to_remove:
			var coin_tower_index = _rng.randi_range(0, _coin_towers.size() - 1)
			var coin_tower = _coin_towers[coin_tower_index]
			var j:int = 1
			while coin_tower.coins_number <= 0:
				coin_tower = _coin_towers[(coin_tower_index + j) % _coin_towers.size()]
				j += 1
			coin_tower.coins_number -= 1
	
	_old_player_gold = (new_player_gold / GOLD_PER_COIN) * GOLD_PER_COIN
	_check_height_diff()


func _check_height_diff() -> void:
	var highest_tower = _coin_towers[0]
	var lowest_tower = _coin_towers[0]
	for tower in _coin_towers:
		if tower.coins_number > highest_tower.coins_number:
			highest_tower = tower
		if tower.coins_number < lowest_tower.coins_number:
			lowest_tower = tower
	
	if highest_tower.coins_number > lowest_tower.coins_number + MAX_TOWER_HEIGHT_DIFF:
		highest_tower.coins_number -= 1
		lowest_tower.coins_number += 1
		_check_height_diff()

# ============================== Callback functions ==============================

func _on_player_gold_changed(_unused, new_player_gold: int) -> void:
	_update_visual(new_player_gold)
