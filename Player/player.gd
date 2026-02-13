class_name Player
extends Node

#region ============================== Variables ==============================
var player_name: String # Nickname of the player
var id: int # Multiplayer id

var is_bot: bool # If the player is a fake player (a bot controlled by the server)

var deck: PlayerDeck
var hero: Hero
var fighting_island: FightingIsland

var win_streak: int
var health_lost_since_last_round: int
var total_win_number: int
var total_lose_number: int
var current_damage_win_lose_diff: int # <win>-<lose> but can't go over what the rules indicate (used for damage modifier)
var battle_history: Array[Battle.BattleResolution]

var is_dead: bool = false # True if the player is dead and signaled it
var round_of_death: int = -1 # The round when the player died (if dead)

var skill_manager: SkillManager

var _team: int # Current team of the player during this round
var team: int:
	get: return _team
	set(value):
		_team = value
		if hero != null: hero.team = _team

signal lvl_changed(self_ref: Player, new_lvl: int)
var _lvl: int = 1
var lvl: int:
	get: return _lvl
	set(value):
		if _lvl == value: return
		_lvl = clampi(value, 1, 10)
		lvl_changed.emit(self, _lvl)

signal xp_changed(self_ref: Player, new_xp: int)
var _xp: int
var xp: int:
	get: return _xp
	set(value):
		if _xp == value: return
		_xp = value
		_check_lvl_up()
		xp_changed.emit(self, _xp)

signal hero_changed(self_ref: Player, new_hero: HeroDesc)
var _hero_desc: HeroDesc
var hero_desc: HeroDesc:
	get: return _hero_desc
	set(value):
		if _hero_desc == value: return
		_hero_desc = value
		if _hero_desc != null:
			_hero_desc_id = _hero_desc.id
		hero_changed.emit(self, _hero_desc)

# Synced integer representation of hero_desc for MultiplayerSynchronizer
var _hero_desc_id: int = 0
var hero_desc_id: int:
	get: return _hero_desc_id
	set(value):
		if _hero_desc_id == value: return
		_hero_desc_id = value
		if _hero_desc_id != 0 and Shared.HEROES.has(_hero_desc_id):
			hero_desc = Shared.HEROES[_hero_desc_id]

signal max_health_changed(self_ref: Player, new_max_health: int)
var _max_health: int
var max_health: int:
	get: return _max_health
	set(value):
		if _max_health == value: return
		_max_health = clampi(value, 0, 100) # TODO la valeur de 100 est purement arbitraire
		max_health_changed.emit(self, _max_health)

signal death(self_ref: Player)
signal health_changed(self_ref: Player, new_health: int)
var _health: int
var health: int:
	get: return _health
	set(value):
		if _health == value: return
		_health = clampi(value, -100, 100)
		health_changed.emit(self, _health)
		if _health <= 0: # TODO Change this by a pile of corpse is funnier
			death.emit(self)
			# Hero cleanup is now handled by global lifecycle management

signal gold_changed(self_ref: Player, new_gold: int)
var _gold: int
var gold: int:
	get: return _gold
	set(value):
		if _gold == value: return
		_gold = clampi(value, 0, 10000)
		gold_changed.emit(self, _gold)

signal damage_changed(self_ref: Player, new_damage: int)
var _damage: int
var damage: int:
	get: return _damage
	set(value):
		if _damage == value: return
		_damage = value
		damage_changed.emit(self, _damage)
#endregion

#region ============================== Public functions ==============================
func init_player() -> void:
	deck = PlayerDeck.new().init(self)
	deck.has_changed.connect(_on_deck_has_changed)


func setup_components() -> void:
	var is_server := multiplayer.is_server()
	var is_local := (id == multiplayer.get_unique_id())

	# CardShop: local human player OR bot on server
	if (is_local and not is_bot) or (is_bot and is_server):
		var card_shop: CardShop = preload("res://Game/CardShop/card_shop.tscn").instantiate()
		card_shop.name = "CardShop"
		card_shop.player = self
		add_child(card_shop)

	# Bot AI: only on server for bots
	if is_bot and is_server:
		var bot_ai: PlayerBotAI = preload("res://Player/PlayerBotAI/player_bot_ai.tscn").instantiate()
		bot_ai.player = self
		bot_ai.name = "PlayerBotAI"
		add_child(bot_ai)
#endregion

# ============================== Private functions ==============================

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
	while xp >= GameManager.game_rules.xp_per_levels[_lvl]:
		xp -= GameManager.game_rules.xp_per_levels[_lvl]
		lvl += 1
		if _lvl == GameManager.game_rules.xp_max_player_level:
			return

# ============================== Callbacks ==============================

func _on_deck_has_changed() -> void:
	_apply_all_cards_upgrades()
