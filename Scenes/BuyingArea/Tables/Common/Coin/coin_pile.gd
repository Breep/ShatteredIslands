class_name CoinPile
extends Node3D

const GOLD_PER_COIN: int = 50 # Number of gold that represent a 3d coin
const MAX_TOWER_HEIGHT_DIFF: int = 5 # Max coin (or height) diff between the highest and lowest tower

@export var _coin_towers: Array[CoinTower]

var _old_player_gold: int 

func connect_to_player(player: Player) -> void:
	player.gold_changed.connect(_on_player_gold_changed)


func _update_visual(new_player_gold: int) -> void:
	var rng: = RandomNumberGenerator.new()
	rng.randomize()
	if new_player_gold >= _old_player_gold + GOLD_PER_COIN:
		var number_of_coin_to_add: int = (new_player_gold - _old_player_gold) / GOLD_PER_COIN
		for i in number_of_coin_to_add:
			var coin_tower = _coin_towers[rng.randi_range(0, _coin_towers.size() - 1)]
			coin_tower.coins_number += 1
	elif new_player_gold <= _old_player_gold - GOLD_PER_COIN:
		var number_of_coin_to_remove: int = (new_player_gold - _old_player_gold) / GOLD_PER_COIN
		for i in number_of_coin_to_remove:
			var coin_tower = _coin_towers[rng.randi_range(0, _coin_towers.size() - 1)]
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


func _on_player_gold_changed(new_player_gold: int) -> void:
	_update_visual(new_player_gold)
