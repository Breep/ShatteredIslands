extends Control

# ============================== Local nodes ==============================

@onready var timer: Timer = $Timer
@onready var playerDeckUI: PlayerDeckUI = $PlayerDeckUI
# ============================== Public ==============================

# ============================== Node base functions ==============================

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)

# ============================== Signal callbacks ==============================

func _on_timer_timeout() -> void:
	GameManager.gameSwitchTo(GameManager.GameState.Fighting)



func _on_player_deck_button_pressed() -> void:
	playerDeckUI.show()
	playerDeckUI.show_player_cards(GameManager.players[0].deck.cardPile)


func _on_stats_character_pressed() -> void:
	var ui = %UIPlayer
	%CloseStatsCharacter.show()
	%StatsCharacter.hide()
	ui.show()
	


func _on_close_stats_character_pressed() -> void:
	var ui = %UIPlayer
	ui.hide()
	%StatsCharacter.show()
	%CloseStatsCharacter.hide()
