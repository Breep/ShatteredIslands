class_name Player
extends Resource

# ============================== Enum ==============================

enum SerializedField {
	NAME,
	ID,
	TEAM,
	HEALTH,
	MAX_HEALTH,
	DAMAGE,
	HERO,
	GOLD,
	IS_BOT,
}

# ============================== Variables ==============================

var name: String # Nickname of the player
var id: int # Multiplayer id
var team: int # Current team of the player during this round
var is_bot: bool # If the player is a fake player (a bot controlled by the server)

var ready: bool # If this player is ready to continue the game flow (Used to sync players with server)

var character_stats: CharacterStats # Stats of the player's character
var deck: PlayerDeck

var win_streak: int
var health_lost_since_last_round: int
var total_win_number: int
var total_lose_number: int
var current_damage_win_lose_diff: int # <win>-<lose> but can't go over what the rules indicate (used for damage modifier)

signal hero_changed(self_ref: Player, new_hero : Hero)
var _hero: Hero
var hero: Hero:
	get: return _hero
	set(value):
		_hero = value
		hero_changed.emit(self, _hero)

signal max_health_changed(self_ref: Player, new_max_health: int)
var _max_health: int
var max_health: int:
	get: return _max_health
	set(value):
		_max_health = value
		max_health_changed.emit(self, _max_health)

signal health_changed(self_ref: Player, new_health: int)
var _health: int
var health: int:
	get: return _health
	set(value):
		_health = value
		health_changed.emit(self, _health)

signal gold_changed(self_ref: Player, new_gold: int)
var _gold: int
var gold: int:
	get: return _gold
	set(value):
		_gold = value
		gold_changed.emit(self, _gold)

signal damage_changed(self_ref: Player, new_damage: int)
var _damage: int
var damage: int:
	get: return _damage
	set(value):
		_damage = value
		damage_changed.emit(self, _damage)

# ============================== Static functions ==============================

static func new_from_serialized(serialized_data: Dictionary) -> Player:
	var player := Player.new()
	player.name = serialized_data[SerializedField.NAME]
	player.team = serialized_data[SerializedField.TEAM]
	player.health = serialized_data[SerializedField.HEALTH]
	player.max_health = serialized_data[SerializedField.MAX_HEALTH]
	player.damage = serialized_data[SerializedField.DAMAGE]
	#player.hero = Shared.HEROES[serialized_data[SerializedField.HERO]]
	player.gold = serialized_data[SerializedField.GOLD]
	player.is_bot = serialized_data[SerializedField.IS_BOT]
	return player

# ============================== Public functions ==============================

func serialized() -> Dictionary:
	var serialized_version = {
		SerializedField.NAME: name,
		SerializedField.ID: id,
		SerializedField.TEAM: team,
		SerializedField.HEALTH: health,
		SerializedField.MAX_HEALTH: max_health,
		SerializedField.DAMAGE: damage,
		#SerializedField.HERO: hero.id,
		SerializedField.GOLD: gold,
		SerializedField.IS_BOT: is_bot
	}
	return serialized_version


func update_from_serialized(serialized_data: Dictionary) -> void:
	name = serialized_data[SerializedField.NAME]
	team = serialized_data[SerializedField.TEAM]
	health = serialized_data[SerializedField.HEALTH]
	max_health = serialized_data[SerializedField.MAX_HEALTH]
	damage = serialized_data[SerializedField.DAMAGE]
	#hero = Shared.HEROES[serialized_data[SerializedField.HERO]]
	gold = serialized_data[SerializedField.GOLD]
	is_bot = serialized_data[SerializedField.IS_BOT]


func reset_stats() -> void:
	_apply_all_cards_upgrades()


# ============================== Resource base functions ==============================

func _init() -> void:
	deck = PlayerDeck.new()
	character_stats = CharacterStats.new()
	deck.has_changed.connect(_on_deck_has_changed)

# ============================== Private functions ==============================

func _apply_all_cards_upgrades() -> void:
	if deck == null or character_stats == null or hero == null:
		printerr("Player: Can't apply cards upgrades")
		return
	character_stats.reset_stats(hero.stats)
	for card in deck.cardPile:
		card.player_upgrade.apply(character_stats, card.lvl)

# ============================== Callbacks ==============================

func _on_deck_has_changed() -> void:
	print("Player: Deck has changed")
	_apply_all_cards_upgrades()
















 
