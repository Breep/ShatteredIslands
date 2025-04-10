class_name PlayerBotAI
extends Node

# L'idée de cette IA c'est qu'elle soit totalement indépendante une fois créée
# Pour être créé elle a besoin d'être associé à un Player et d'avoir un accès à l'état de la partie



var player: Player # Player Ref this BotAI is linked to

var _game_state: Game.GameState = Game.GameState.UNDEF

enum EconomyStrategy {
	KEEPER, # Stay always above 500gold if possible
	WASTER, # Spend all its money each turn
}

func _ready() -> void:
	if player == null:
		printerr("PlayerBotAI: Can't exist without a ref to a player !")
		queue_free()
		return
	
	Events.game_state_changed.connect(_on_events_game_state_changed)


func _dumb_buying_area() -> void:
	var timer:= Timer.new()
	
	timer.wait_time = 1.0
	pass


func _on_events_game_state_changed(new_game_state: Game.GameState) -> void:
	pass
