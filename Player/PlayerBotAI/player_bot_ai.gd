class_name PlayerBotAI
extends Node

# L'idée de cette IA c'est qu'elle soit totalement indépendante une fois créée
# Pour être créé elle a besoin d'être associé à un Player et d'avoir un accès à l'état de la partie

const MIN_WAIT_TIME: float = 0.8
const MAX_WAIT_TIME: float = 2.1

var player: Player # Player Ref this BotAI is linked to

@export var _wake_up_timer: Timer # Every timer tick, bot wakes up, figure out what to do, then go to sleep again (wait_time is random)
@export var _card_shop: CardShop

var _rng: RandomNumberGenerator
var _economy_strategy: EconomyStrategy

enum EconomyStrategy {
	KEEPER, # Stay always above 500gold if possible
	WASTER, # Spend all its money each turn
}


func _enter_tree() -> void:
	_card_shop.player = player


func _ready() -> void:
	if player == null:
		Verbose.error("PlayerBotAI: Can't exist without a ref to a player !", Verbose.Category.AI)
		queue_free()
		return
	
	GameManager.game_state_changed.connect(_on_game_manager_game_state_changed)
	
	_rng = RandomNumberGenerator.new()
	_rng.randomize()
	
	_economy_strategy = EconomyStrategy.KEEPER if _rng.randi() % 2 == 0 else EconomyStrategy.WASTER
	var tmp_debug_strat_str: String = "KEEPER" if _economy_strategy == EconomyStrategy.KEEPER else "WASTER"
	Verbose.debug("PlayerBotAI: Starting AI for " + player.name + "[" + tmp_debug_strat_str + "]", Verbose.Category.AI)


func _dumb_buying_area() -> void:
	await get_tree().create_timer(1.0).timeout
	_wake_up_timer.wait_time = _rng.randf_range(MIN_WAIT_TIME, MAX_WAIT_TIME)
	_wake_up_timer.start()


func _buy_a_card() -> void:
	if _card_shop.cards_displayed.is_empty():
		return
	
	var card: Card = _card_shop.cards_displayed[_rng.randi_range(0, _card_shop.cards_displayed.size() - 1)]
	_card_shop.try_buy_card(card)


func _on_game_manager_game_state_changed(new_game_state: Game.GameState) -> void:
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



















 
