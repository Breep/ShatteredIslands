class_name Player
extends Resource

# ============================== Enum ==============================

enum SerializedField {
	NAME,
	ID,
	TEAM,
	HEALTH,
	MAX_HEALTH,
	HERO,
	GOLD,
	IS_BOT,
}

# ============================== Variables ==============================

var name: String # Nickname of the player
var id: int # Multiplayer id
var team: int # Current team of the player during this round
var is_bot: bool # If the player is a fake player (a bot controlled by the server)


var character_stats: CharacterStats # Stats of the player's character
var deck: PlayerDeck

signal hero_changed(new_hero : Hero)
var _hero: Hero
var hero: Hero:
	get: return _hero
	set(value):
		_hero = value
		hero_changed.emit(_hero)

signal max_health_changed(new_max_health: int)
var _max_health: int
var max_health: int:
	get: return _max_health
	set(value):
		_max_health = value
		max_health_changed.emit(_max_health)

signal health_changed(new_health: int)
var _health: int
var health: int:
	get: return _health
	set(value):
		_health = value
		health_changed.emit(_health)

signal gold_changed(new_gold: int)
var _gold: int
var gold: int:
	get: return _gold
	set(value):
		_gold = value
		gold_changed.emit(_gold)

# ============================== Static functions ==============================

# Get the player conresponding of the serialized_data id in the GameManager
# Update some values inside the player TODO: C'est moche que cette fonciton modifie des valeurs de player, il faut en avoir une autre à côté qui fait ça
static func get_from_serialized(serialized_data: Dictionary) -> Player:
	var player = PlayerManager.players[serialized_data[SerializedField.ID]]
	player.team = serialized_data[SerializedField.TEAM]
	return player


static func new_from_serialized(serialized_data: Dictionary) -> Player:
	var player := Player.new()
	player.name = serialized_data[SerializedField.NAME]
	player.team = serialized_data[SerializedField.TEAM]
	player.health = serialized_data[SerializedField.HEALTH]
	player.max_health = serialized_data[SerializedField.MAX_HEALTH]
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
		#SerializedField.HERO: hero.id,
		SerializedField.GOLD: gold,
		SerializedField.IS_BOT: is_bot
	}
	return serialized_version

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
















 
