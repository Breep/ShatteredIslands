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
var character: Character
var is_bot: bool # If the player is a fake player (a bot controlled by the server)

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

signal deck_changed(new_deck: PlayerDeck) # Faire en sorte que ça soit plus transparent
var deck: PlayerDeck

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
	player.deck = PlayerDeck.new()
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
		SerializedField.HERO: hero.id,
		SerializedField.GOLD: gold,
		SerializedField.IS_BOT: is_bot
	}
	return serialized_version
