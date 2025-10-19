class_name UIGame
extends Control

# ============================== Local nodes ==============================

@export var _ui_buying_area: UIBuyingArea
@export var _ui_fighting_area: UIFightingArea
@export var _ui_pause_menu: UIPauseMenu
@export var _ui_picking_screen: UIHeroPickingScreen
@export var _ui_result: UIResult

# ============================== Node base functions ==============================

func _ready() -> void:
	Events.local_player_is_dead.connect(_on_events_local_player_is_dead)
	Events.game_state_changed.connect(_on_events_game_state_changed)
	Events.scene_switched.connect(_on_events_scene_switched)
	

# ============================== Public functions ==============================


# ============================== Callbacks ==============================

func _on_events_local_player_is_dead() -> void:
	var local_player: Player = PlayerManager.get_local_player()
	var player_place: int = PlayerManager.get_player_current_place(local_player)
	_ui_result.show_result(player_place)


func _on_events_game_state_changed(game_state: Game.GameState) -> void:
	if game_state != Game.GameState.FINISHED: return
	var local_player: Player = PlayerManager.get_local_player()
	var player_place: int = PlayerManager.get_player_current_place(local_player)
	_ui_result.show_result(player_place)


func _on_events_scene_switched(floating_island: FloatingIsland) -> void:
	if floating_island is BuyingIsland:
		_ui_buying_area.set_active()
		_ui_fighting_area.set_inactive()
	else:
		_ui_buying_area.set_inactive()
		_ui_fighting_area.set_active()
		_ui_fighting_area.update_content(floating_island.get_fighting_area())
