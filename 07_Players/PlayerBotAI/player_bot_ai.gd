class_name PlayerBotAI
extends Node

# L'idée de cette IA c'est qu'elle soit totalement indépendante une fois créée
# Pour être créé elle a besoin d'être associé à un Player et d'avoir un accès à l'état de la partie

const MIN_WAIT_TIME: float = 0.8
const MAX_WAIT_TIME: float = 2.1
const WASTER_RATIO: float = 1.0 # 0.0 = tous KEEPER, 0.5 = 50/50, 1.0 = tous WASTER

const FOCUS_FAMILIES: Array[Family.Type] = [
	Family.Type.ENGINEER,
	Family.Type.ARDENT_CELESTIAL,
	Family.Type.COLOSSUS,
	Family.Type.CHICKEN_LORD,
]

var player: Player # Player Ref this BotAI is linked to

@export var _wake_up_timer: Timer # Every timer tick, bot wakes up, figure out what to do, then go to sleep again (wait_time is random)
var _card_shop: PlayerCardShop

var _rng: RandomNumberGenerator
var _economy_strategy: EconomyStrategy
var _primary_family: Family.Type
var _secondary_family: Family.Type # Family.Type.UNDEF si pas de secondaire

enum EconomyStrategy {
	KEEPER, # Stay always above 500gold if possible
	WASTER, # Spend all its money each turn
}


func _ready() -> void:
	if player == null:
		Verbose.error("PlayerBotAI: Can't exist without a ref to a player !", Verbose.Category.AI)
		queue_free()
		return

	_card_shop = get_parent().get_node("CardShop") as PlayerCardShop
	if _card_shop == null:
		Verbose.error("PlayerBotAI: No CardShop sibling found under parent Player", Verbose.Category.AI)
		queue_free()
		return

	GameManager.game_state_changed.connect(_on_game_manager_game_state_changed)

	_rng = RandomNumberGenerator.new()
	_rng.randomize()

	_economy_strategy = EconomyStrategy.WASTER if _rng.randf() < WASTER_RATIO else EconomyStrategy.KEEPER

	# Choisir une famille primaire
	_primary_family = FOCUS_FAMILIES[_rng.randi_range(0, FOCUS_FAMILIES.size() - 1)]

	# 50% de chance d'avoir une famille secondaire
	if _rng.randi() % 2 == 0:
		var remaining: Array[Family.Type] = []
		for f in FOCUS_FAMILIES:
			if f != _primary_family:
				remaining.append(f)
		_secondary_family = remaining[_rng.randi_range(0, remaining.size() - 1)]
	else:
		_secondary_family = Family.Type.UNDEF

	var strat_str: String = "KEEPER" if _economy_strategy == EconomyStrategy.KEEPER else "WASTER"
	var secondary_str: String = str(_secondary_family) if _secondary_family != Family.Type.UNDEF else "NONE"
	Verbose.debug("PlayerBotAI: Starting AI for " + player.player_name + " [" + strat_str + "] Primary: " + str(_primary_family) + " Secondary: " + secondary_str, Verbose.Category.AI)


func _dumb_buying_area() -> void:
	await get_tree().create_timer(1.0).timeout
	_wake_up_timer.wait_time = _rng.randf_range(MIN_WAIT_TIME, MAX_WAIT_TIME)
	_wake_up_timer.start()


# ============================== Card Scoring ==============================


func _score_card(card: Card) -> float:
	var score: float = 0.0

	# 1. Affinité famille (0 / 25 / 50)
	if _primary_family in card.families:
		score += 50.0
	elif _secondary_family != Family.Type.UNDEF and _secondary_family in card.families:
		score += 25.0

	# 2. Upgrade existant (-100 / +10 / +30)
	var current_lvl: int = player.deck.get_card_lvl(card)
	if current_lvl > 0:
		if card.is_max_level(): # card.lvl est déjà set au niveau post-achat par le shop
			score -= 100.0
		else:
			score += 30.0
	else:
		score += 10.0

	# 3. Bonus rareté (0 à 15)
	match card.rarity:
		Card.Rarity.LEGENDARY:
			score += 15.0
		Card.Rarity.EPIC:
			score += 10.0
		Card.Rarity.RARE:
			score += 5.0

	# 4. Proximité level-up famille : retirée avec la refonte du deck (la nouvelle
	# mécanique de familles sera rebranchée plus tard).

	return score


# ============================== Buying Logic ==============================


func _buy_best_card() -> void:
	if _card_shop.cards_displayed.is_empty():
		return

	var best_card: Card = null
	var best_score: float = -INF
	for card in _card_shop.cards_displayed:
		var score: float = _score_card(card)
		if score > best_score:
			best_score = score
			best_card = card

	if best_card != null and best_score > -100.0:
		await _card_shop.try_buy_card(best_card)


func _get_best_score() -> float:
	var best: float = -INF
	for card in _card_shop.cards_displayed:
		var score: float = _score_card(card)
		if score > best:
			best = score
	return best


func _on_game_manager_game_state_changed(new_game_state: GameManager.GameState) -> void:
	if new_game_state == GameManager.GameState.BUYING:
		_dumb_buying_area()
	else:
		_wake_up_timer.stop()


func _on_wake_up_timer_timeout() -> void:
	var gold_threshold: int = 600 if _economy_strategy == EconomyStrategy.KEEPER else 100
	if player.gold < gold_threshold:
		_wake_up_timer.wait_time = _rng.randf_range(MIN_WAIT_TIME, MAX_WAIT_TIME)
		_wake_up_timer.start()
		return

	var best_score: float = _get_best_score()

	if best_score < 10.0:
		# Aucune carte intéressante dans le shop
		if player.gold >= 120:
			await _card_shop.try_refresh_shop_cards()
		elif player.gold >= 90 and _rng.randf() < 0.3:
			await _card_shop.try_buy_random_card()
		else:
			await _buy_best_card()
	else:
		await _buy_best_card()

	_wake_up_timer.wait_time = _rng.randf_range(MIN_WAIT_TIME, MAX_WAIT_TIME)
	_wake_up_timer.start()



















 
