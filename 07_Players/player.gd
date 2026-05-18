# Représente un joueur dans une session : identité réseau (id, name, team) et
# mécanique runtime (signals, clamps, level-up, death). Les données de run
# sauvegardables vivent dans `state: PlayerState`.
class_name Player
extends Node

#region ============================== Variables ==============================
var player_name: String # Nickname of the player
var id: int # Multiplayer id

var is_bot: bool # If the player is a fake player (a bot controlled by the server)

var state: PlayerState

var hero: Hero
var fighting_island: FightingIsland

var health_lost_since_last_round: int
var battle_history: Array[Battle.BattleResolution]

var skill_manager: SkillManager

var _team: int # Current team of the player during this round
var team: int:
	get: return _team
	set(value):
		_team = value
		if hero != null: hero.team = _team

var deck: PlayerDeck:
	get: return state.deck
	set(value): state.deck = value

var data_memory: NestedRegistry:
	get: return state.data_memory
	set(value): state.data_memory = value

var win_streak: int:
	get: return state.win_streak
	set(value): state.win_streak = value

var total_win_number: int:
	get: return state.total_win_number
	set(value): state.total_win_number = value

var total_lose_number: int:
	get: return state.total_lose_number
	set(value): state.total_lose_number = value

var current_damage_win_lose_diff: int:
	get: return state.current_damage_win_lose_diff
	set(value): state.current_damage_win_lose_diff = value

var is_dead: bool:
	get: return state.is_dead
	set(value): state.is_dead = value

var round_of_death: int:
	get: return state.round_of_death
	set(value): state.round_of_death = value

signal lvl_changed(self_ref: Player, new_lvl: int)
var lvl: int:
	get: return state.lvl
	set(value):
		var clamped := clampi(value, 1, 10)
		if state.lvl == clamped: return
		state.lvl = clamped
		lvl_changed.emit(self, state.lvl)

signal xp_changed(self_ref: Player, new_xp: int)
var xp: int:
	get: return state.xp
	set(value):
		if state.xp == value: return
		state.xp = value
		_check_lvl_up()
		xp_changed.emit(self, state.xp)

signal hero_changed(self_ref: Player, new_hero: HeroDesc)
var hero_desc: HeroDesc:
	get:
		if state.hero_desc_id != 0 and Shared.HEROES.has(state.hero_desc_id):
			return Shared.HEROES[state.hero_desc_id]
		return null
	set(value):
		var new_id: int = value.id if value != null else 0
		if state.hero_desc_id == new_id: return
		state.hero_desc_id = new_id
		hero_changed.emit(self, value)

# Synced integer representation of hero_desc for MultiplayerSynchronizer
var hero_desc_id: int:
	get: return state.hero_desc_id
	set(value):
		if state.hero_desc_id == value: return
		state.hero_desc_id = value
		var new_hero: HeroDesc = null
		if value != 0 and Shared.HEROES.has(value):
			new_hero = Shared.HEROES[value]
		hero_changed.emit(self, new_hero)

signal max_health_changed(self_ref: Player, new_max_health: int)
var max_health: int:
	get: return state.max_health
	set(value):
		var clamped := clampi(value, 0, 100) # TODO la valeur de 100 est purement arbitraire
		if state.max_health == clamped: return
		state.max_health = clamped
		max_health_changed.emit(self, state.max_health)

signal death(self_ref: Player)
signal health_changed(self_ref: Player, new_health: int)
var health: int:
	get: return state.health
	set(value):
		var clamped := clampi(value, -100, 100)
		if state.health == clamped: return
		state.health = clamped
		health_changed.emit(self, state.health)
		if state.health <= 0: # TODO Change this by a pile of corpse is funnier
			death.emit(self)
			# Hero cleanup is now handled by global lifecycle management

signal gold_changed(self_ref: Player, new_gold: int)
var gold: int:
	get: return state.gold
	set(value):
		var clamped := clampi(value, 0, 10000)
		if state.gold == clamped: return
		state.gold = clamped
		gold_changed.emit(self, state.gold)

signal damage_changed(self_ref: Player, new_damage: int)
var damage: int:
	get: return state.damage
	set(value):
		if state.damage == value: return
		state.damage = value
		damage_changed.emit(self, state.damage)
#endregion

#region ============================== Public functions ==============================
func init_player() -> void:
	state.deck = PlayerDeck.new().init(player_name)
	state.deck.has_changed.connect(_on_deck_has_changed)


func setup_components() -> void:
	var is_server := multiplayer.is_server()
	var is_local := (id == multiplayer.get_unique_id())

	# CardShop: local human player OR bot on server
	if (is_local and not is_bot) or (is_bot and is_server):
		var card_shop: PlayerCardShop = preload("res://05_Game/CardShop/player_card_shop.tscn").instantiate()
		card_shop.name = "CardShop"
		card_shop.player = self
		add_child(card_shop)

	# Bot AI: only on server for bots
	if is_bot and is_server:
		var bot_ai: PlayerBotAI = preload("res://07_Players/PlayerBotAI/player_bot_ai.tscn").instantiate()
		bot_ai.player = self
		bot_ai.name = "PlayerBotAI"
		add_child(bot_ai)
#endregion

# ============================== Private functions ==============================
func _init() -> void:
	state = PlayerState.new()
	skill_manager = SkillManager.new()
	skill_manager.init(self)


func _apply_all_cards_upgrades() -> void:
	if deck == null or hero == null:
		printerr("Player: Can't apply cards upgrades")
		return
	if hero.is_node_ready():
		var ctx: CardContext = hero.get_card_context()
		for card in deck.get_active_deck():
			card.player_upgrade.apply_card(ctx, card.lvl)
	else:
		hero.deck = deck


func _check_lvl_up() -> void:
	while xp >= GameManager.game_rules.xp_per_levels[lvl]:
		xp -= GameManager.game_rules.xp_per_levels[lvl]
		lvl += 1
		if lvl == GameManager.game_rules.xp_max_player_level:
			return

# ============================== Callbacks ==============================

func _on_deck_has_changed() -> void:
	_apply_all_cards_upgrades()
