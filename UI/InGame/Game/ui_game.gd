class_name UIGame
extends Control

# ============================== Local nodes ==============================

@onready var _ui_buying_area: UIBuyingArea = %BuyingArea
@onready var _ui_fighting_area: UIFightingArea = %FightingArea
#@onready var _ui_pause_menu: UIPauseMenu = %PauseMenu
#@onready var _ui_picking_screen: UIHeroPickingScreen = %HeroPickingScreen
@onready var _ui_result: UIResult = %Result
@onready var _ui_transition_screen: UITransitionScreen = %TransitionScreen
@onready var _ui_persistant: UIPersistant = %Persistant

# ============================== Node base functions ==============================

func _ready() -> void:
	if multiplayer.is_server() and GameManager.game_type != GameManager.GameType.SOLO:
		queue_free()
	Events.local_player_is_dead.connect(_on_events_local_player_is_dead)
	GameManager.game_state_changed.connect(_on_game_manager_game_state_changed)
	Events.scene_switched.connect(_on_events_scene_switched)
	_ui_buying_area.hide()
	_ui_persistant.hide()

# ============================== Public functions ==============================


# ============================== Callbacks ==============================

func _on_events_local_player_is_dead() -> void:
	var local_player: Player = PlayerManager.get_local_player()
	var player_place: int = PlayerManager.get_player_current_place(local_player)
	_ui_result.show_result(player_place)


func _on_game_manager_game_state_changed(game_state: Game.GameState) -> void:
	match game_state:
		Game.GameState.STARTING:
			_ui_buying_area.hide()
			_ui_persistant.hide()
		Game.GameState.INITIATING_NEW_ROUND:
			_ui_persistant.show()
		Game.GameState.FIGHTING_FINISHED:
			_ui_transition_screen.start_transition(GameManager.game_rules.duration_fighting_finished * 2)
		Game.GameState.FINISHED:
			var local_player: Player = PlayerManager.get_local_player()
			var player_place: int = PlayerManager.get_player_current_place(local_player)
			_ui_result.show_result(player_place)


func _on_events_scene_switched(floating_island: FloatingIsland) -> void:
	if floating_island is BuyingIsland:
		_ui_buying_area.set_active()
		_ui_fighting_area.set_inactive()
	elif floating_island is FightingIsland:
		_ui_buying_area.set_inactive()
		_ui_fighting_area.set_active()
		_ui_fighting_area.update_content(floating_island.get_fighting_area())
