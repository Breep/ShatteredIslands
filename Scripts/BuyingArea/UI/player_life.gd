extends Control

@export var player_test : Array[Player]
var _tween: Tween = null 

var players_life_info: Array[PlayerLifeInfo]
var position_initial: Array[Vector2]

func _ready() -> void:

	for i in range(1,9):
		players_life_info.append(get_node_or_null("%J" + str(i))) 
		<
	call_deferred("_late_ready") 
	update_visual(_get_players_ordered_by_health())
	
func _late_ready() -> void:
	for player_life_info in players_life_info:
		position_initial.append(player_life_info.position)

	
func update_visual(players: Array[Player]):
	var i = 0
	for player_life_info in players_life_info:
		player_life_info.update_visual(players[i])
		player_life_info.connect("mouse_entered_player_life", _on_progressbar_mouse_entered_player_life)
		player_life_info.connect("mouse_exited_player_life", _on_progressbar_mouse_exited_player_life)
		i += 1

func _on_progressbar_mouse_entered_player_life(number: int):
	if _tween and _tween.is_running():
		_tween.kill()
	
	_tween = get_tree().create_tween().set_parallel(true)
	
	var duration = 0.5
	
	
	for i in range(0, number-1): 
		_tween.tween_property(players_life_info[i], "position:y", position_initial[i].y - 30, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_progressbar_mouse_exited_player_life(number: int):
	if _tween and _tween.is_running():
		_tween.kill()
	
	_tween = get_tree().create_tween().set_parallel(true)
	var duration = 0.5
	
	for i in range(0, 8): 
		_tween.tween_property(players_life_info[i], "position:y", position_initial[i].y, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	
func _get_players_ordered_by_health() -> Array[Player]:
	var array_sorted = player_test.duplicate()
	array_sorted.sort_custom(_compare_player_health)
	return array_sorted

func _compare_player_health(player1: Player, player2: Player) -> bool:
	return player2.health < player1.health
