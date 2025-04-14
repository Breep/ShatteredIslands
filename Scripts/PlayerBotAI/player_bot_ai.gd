class_name PlayerBotAI
extends Node

# L'idée de cette IA c'est qu'elle soit totalement indépendante une fois créée
# Pour être créé elle a besoin d'être associé à un Player et d'avoir un accès à l'état de la partie

const MIN_WAIT_TIME: float = 1
const MAX_WAIT_TIME: float = 8

var player: Player # Player Ref this BotAI is linked to

var _game_state: Game.GameState = Game.GameState.UNDEF
var _wake_up_timer: Timer # Every timer tick, bot wakes up, figure out what to do, then go to sleep again (wait_time is random)
var _rng: RandomNumberGenerator
var _economy_strategy: EconomyStrategy
var _card_shop: CardShop

enum EconomyStrategy {
	KEEPER, # Stay always above 500gold if possible
	WASTER, # Spend all its money each turn
}

func _ready() -> void:
	if player == null:
		printerr("PlayerBotAI: Can't exist without a ref to a player !")
		queue_free()
		return
	
	return # TMP TODO TO REMOVE (DEV)
	
	Events.game_state_changed.connect(_on_events_game_state_changed)
	
	_wake_up_timer = Timer.new()
	_wake_up_timer.one_shot = true
	_wake_up_timer.autostart = false
	_wake_up_timer.timeout.connect(_on_wake_up_timer_timeout)
	_wake_up_timer.name = "WakeUpTimer"
	add_child(_wake_up_timer)
	
	_card_shop = CardShop.new()
	_card_shop.player = player
	_card_shop.name = "CardShop"
	add_child(_card_shop)
	
	_rng = RandomNumberGenerator.new()
	_rng.randomize()
	
	_economy_strategy = EconomyStrategy.KEEPER if _rng.randi() % 2 == 0 else EconomyStrategy.WASTER
	var tmp_debug_strat_str: String = "KEEPER" if _economy_strategy == EconomyStrategy.KEEPER else "WASTER"
	print("PlayerBotAI: Starting AI for ", player.name, "[", tmp_debug_strat_str, "]")


func _dumb_buying_area() -> void:
	await get_tree().create_timer(1.0).timeout
	_wake_up_timer.wait_time = _rng.randf_range(MIN_WAIT_TIME, MAX_WAIT_TIME)
	_wake_up_timer.start()


func _buy_a_card() -> void:
	if _card_shop.cards_displayed.is_empty():
		return
	
	var card: Card = _card_shop.cards_displayed[_rng.randi_range(0, _card_shop.cards_displayed.size() - 1)]
	_card_shop.try_buy_card(card)


func _on_events_game_state_changed(new_game_state: Game.GameState) -> void:
	if new_game_state == Game.GameState.BUYING:
		_dumb_buying_area()
	else:
		_wake_up_timer.stop()


func _on_wake_up_timer_timeout() -> void:
	if _economy_strategy == EconomyStrategy.KEEPER and player.gold >= 600:
		_buy_a_card()
	elif _economy_strategy == EconomyStrategy.WASTER and player.gold >= 100:
		_buy_a_card()
	
	_wake_up_timer.wait_time = _rng.randf_range(MIN_WAIT_TIME, MAX_WAIT_TIME)
	_wake_up_timer.start()



















 
